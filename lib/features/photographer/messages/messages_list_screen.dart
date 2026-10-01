import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_page_header.dart';
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
  bool refreshing = false;
  String? refreshError;
  String search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    setState(() {
      refreshing = true;
      refreshError = null;
    });
    try {
      await ref.read(conversationsProvider.notifier).refresh();
    } catch (error) {
      if (mounted) setState(() => refreshError = '$error');
    } finally {
      if (mounted) setState(() => refreshing = false);
    }
  }

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
      backgroundColor: AppColors.snow,
      appBar: AppBar(title: const Text('Tin nhắn')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 26),
            children: [
              if (refreshing) ...[
                const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: 12),
              ],
              if (refreshError != null) ...[
                TextButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('Không thể tải tin nhắn. Thử lại: $refreshError'),
                ),
              ],
              CreatorPageHeader(
                title: 'Trò chuyện',
                subtitle: unread > 0
                    ? '$unread cuộc trò chuyện chưa đọc'
                    : 'Trao đổi với khách hàng và cộng tác viên',
              ),
              const SizedBox(height: 20),
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
                  fillColor: AppColors.mist,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              MessagesFilterBar(
                unreadOnly: unreadOnly,
                unreadCount: unread,
                onChanged: (value) => setState(() => unreadOnly = value),
              ),
              const SizedBox(height: 18),
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
                  const Divider(height: 1),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
