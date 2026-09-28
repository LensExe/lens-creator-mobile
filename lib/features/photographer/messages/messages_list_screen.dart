import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final conversations = [
      {
        'id': 'conv-1',
        'participantName': 'Nguyễn Văn A',
        'participantAvatar': 'https://i.pravatar.cc/150?img=11',
        'lastMessage': 'Cảm ơn bạn, mình nhận được ảnh rồi nhé!',
        'lastMessageAt': 'Vừa xong',
        'unreadCount': 2,
      },
      {
        'id': 'conv-2',
        'participantName': 'Trần Thị B',
        'participantAvatar': 'https://i.pravatar.cc/150?img=5',
        'lastMessage': 'Gói chụp này có hỗ trợ trang phục không?',
        'lastMessageAt': '5 phút trước',
        'unreadCount': 1,
      },
      {
        'id': 'conv-3',
        'participantName': 'Lê Hoàng C',
        'participantAvatar': 'https://i.pravatar.cc/150?img=33',
        'lastMessage': 'Ok chốt lịch 9h sáng chủ nhật nha.',
        'lastMessageAt': 'Hôm qua',
        'unreadCount': 0,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Tin nhắn',
          style: TextStyle(
            color: AppColors.obsidian,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conv = conversations[index];
          final unread = conv['unreadCount'] as int;
          final isUnread = unread > 0;

          return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(
                    conv['participantAvatar'] as String,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        conv['participantName'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.obsidian,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      conv['lastMessageAt'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnread ? AppColors.ember : AppColors.steel,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv['lastMessage'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUnread
                                ? AppColors.obsidian
                                : AppColors.steel,
                            fontWeight: isUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.ember,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                              color: AppColors.snow,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                onTap: () {
                  context.push('/photographer_home/messages/${conv['id']}');
                },
              )
              .animate()
              .fade(duration: 300.ms, delay: (index * 50).ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
