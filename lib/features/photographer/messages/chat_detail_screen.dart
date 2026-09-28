import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatDetailScreen extends StatefulWidget {
  final String id;
  const ChatDetailScreen({super.key, required this.id});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isAiEnabled = false;

  // Mock messages (reversed for ListView)
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'm3',
      'text': 'Tuyệt vời, vậy mình chốt lịch lúc 9h sáng nhé!',
      'senderId': 'client',
      'sentAt': '09:05',
      'isAI': false,
    },
    {
      'id': 'm2',
      'text': 'Chào bạn, gói này mình hỗ trợ chụp 2 tiếng, bạn có thể tham khảo thêm trên profile.',
      'senderId': 'me',
      'sentAt': '09:02',
      'isAI': true, // Mocking AI reply
    },
    {
      'id': 'm1',
      'text': 'Chào bạn, gói chụp ngoại cảnh có bao gồm trang phục không ạ?',
      'senderId': 'client',
      'sentAt': '09:00',
      'isAI': false,
    },
  ];

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': _msgCtrl.text.trim(),
        'senderId': 'me',
        'sentAt':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'isAI': false,
      });
      _msgCtrl.clear();
    });

    _scrollCtrl.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.obsidian),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Nguyễn Văn A',
                    style: TextStyle(
                      color: AppColors.obsidian,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Khách hàng',
                    style: TextStyle(color: AppColors.steel, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: _isAiEnabled ? AppColors.ember : AppColors.steel,
                size: 20,
              ),
              Switch(
                value: _isAiEnabled,
                activeColor: AppColors.snow,
                activeTrackColor: AppColors.ember,
                inactiveThumbColor: AppColors.snow,
                inactiveTrackColor: AppColors.pebble,
                onChanged: (val) {
                  setState(() {
                    _isAiEnabled = val;
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_isAiEnabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.ember.withOpacity(0.1),
              child: Row(
                children: const [
                  Icon(Icons.smart_toy, color: AppColors.ember, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Trợ lý AI đang tự động trả lời khách trong hội thoại này.',
                      style: TextStyle(
                        color: AppColors.ember,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.5, end: 0).fade(),

          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              reverse: true,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['senderId'] == 'me';
                final isAi = msg['isAI'] == true;

                return ChatBubbleWidget(
                  text: msg['text'] as String,
                  isMe: isMe,
                  isAi: isAi,
                  sentAt: msg['sentAt'] as String,
                ).animate().scale(begin: const Offset(0.9, 0.9)).fade();
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.all(16)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: AppColors.snow,
        border: Border(top: BorderSide(color: AppColors.pebble)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: const TextStyle(color: AppColors.steel),
                filled: true,
                fillColor: AppColors.mist,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.obsidian,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: AppColors.snow, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubbleWidget extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool isAi;
  final String sentAt;

  const ChatBubbleWidget({
    super.key,
    required this.text,
    required this.isMe,
    required this.isAi,
    required this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    // 3 states: isAi (right, ember light), isMe (right, obsidian), theirs (left, mist/fog)
    final isRight = isMe;

    Color bgColor = AppColors.mist;
    Color textColor = AppColors.obsidian;
    Border? border;

    if (isAi) {
      bgColor = AppColors.ember.withOpacity(0.1);
      textColor = AppColors.obsidian;
      border = Border.all(color: AppColors.ember.withOpacity(0.3));
    } else if (isMe) {
      bgColor = AppColors.obsidian;
      textColor = AppColors.snow;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isRight)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: border,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isRight
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                      bottomLeft: !isRight
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAi)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.smart_toy,
                                size: 14,
                                color: AppColors.ember,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Trợ lý AI',
                                style: TextStyle(
                                  color: AppColors.ember,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sentAt,
                  style: const TextStyle(fontSize: 11, color: AppColors.steel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
