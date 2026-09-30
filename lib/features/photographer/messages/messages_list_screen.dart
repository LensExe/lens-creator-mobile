import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import 'conversation_provider.dart';
import 'widgets/conversation_preview_tile.dart';
import 'widgets/messages_empty_state.dart';
import 'widgets/messages_filter_bar.dart';

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
    final query = search.trim().toLowerCase();
    final filtered = conversations.where((conversation) {
      if (unreadOnly && conversation.unreadCount == 0) return false;
      return query.isEmpty ||
          '${conversation.participantName} ${conversation.messages.lastOrNull?.text ?? ''}'
              .toLowerCase()
              .contains(query);
    }).toList();

    final emptyTitle = conversations.isEmpty
        ? 'Chưa có cuộc trò chuyện'
        : query.isNotEmpty
        ? 'Không tìm thấy hội thoại'
        : 'Bạn đã đọc hết tin nhắn';
    final emptyDescription = conversations.isEmpty
        ? 'Các cuộc trò chuyện mới sẽ xuất hiện tại đây.'
        : query.isNotEmpty
        ? 'Thử một tên khác hoặc tìm theo nội dung tin nhắn.'
        : 'Chuyển sang “Tất cả” để xem lại các cuộc trò chuyện.';

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        backgroundColor: AppColors.mist,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 26),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Các cuộc trò chuyện',
                      style: TextStyle(
                        color: AppColors.obsidian,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (unread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9DC),
                        borderRadius: BorderRadius.circular(
                          AppTokens.radiusPill,
                        ),
                      ),
                      child: Text(
                        '$unread hội thoại chưa đọc',
                        style: const TextStyle(
                          color: AppColors.ember,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => search = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.steel,
                    size: 20,
                  ),
                  hintText: 'Tìm theo tên hoặc nội dung',
                  filled: true,
                  fillColor: AppColors.snow,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    borderSide: const BorderSide(color: AppColors.fog),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    borderSide: const BorderSide(color: AppColors.ember),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              MessagesFilterBar(
                unreadOnly: unreadOnly,
                unreadCount: unread,
                onChanged: (value) => setState(() => unreadOnly = value),
              ),
              const SizedBox(height: 13),
              if (filtered.isEmpty)
                MessagesEmptyState(
                  title: emptyTitle,
                  description: emptyDescription,
                )
              else
                for (final conversation in filtered) ...[
                  ConversationPreviewTile(
                    conversation: conversation,
                    onTap: () => context.push(
                      '/photographer_home/messages/${conversation.id}',
                    ),
                  ),
                  const SizedBox(height: 9),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
