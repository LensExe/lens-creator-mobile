import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import 'conversation_provider.dart';

class MessagesListScreen extends ConsumerStatefulWidget {
  const MessagesListScreen({super.key});

  @override
  ConsumerState<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends ConsumerState<MessagesListScreen> {
  bool unreadOnly = false;
  String search = '';

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final unread = conversations
        .where((conversation) => conversation.unreadCount > 0)
        .length;
    final filtered = conversations.where((conversation) {
      if (unreadOnly && conversation.unreadCount == 0) return false;
      final query = search.trim().toLowerCase();
      return query.isEmpty ||
          '${conversation.participantName} ${conversation.messages.lastOrNull?.text ?? ''}'
              .toLowerCase()
              .contains(query);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Tin nhắn')),
      body: ListView(
        padding: AppTokens.pagePadding,
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm theo tên hoặc nội dung',
            ),
            onChanged: (value) => setState(() => search = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Tất cả'),
                selected: !unreadOnly,
                onSelected: (_) => setState(() => unreadOnly = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Chưa đọc ($unread)'),
                selected: unreadOnly,
                onSelected: (_) => setState(() => unreadOnly = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  search.isNotEmpty
                      ? 'Không tìm thấy cuộc trò chuyện phù hợp'
                      : 'Bạn đã đọc hết tin nhắn',
                ),
              ),
            ),
          for (final conversation in filtered)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.mist,
                  child: Text(
                    conversation.participantName.characters.first,
                    style: const TextStyle(color: AppColors.obsidian),
                  ),
                ),
                title: Text(
                  conversation.participantName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  conversation.messages.lastOrNull?.text ?? 'Chưa có tin nhắn',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: conversation.unreadCount > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.ember,
                        child: Text(
                          '${conversation.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      )
                    : null,
                onTap: () => context.push(
                  '/photographer_home/messages/${conversation.id}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
