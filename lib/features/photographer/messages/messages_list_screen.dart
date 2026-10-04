import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../providers/data_providers.dart';
import '../assistant/assistant_provider.dart';
import 'conversation_provider.dart';
import 'widgets/conversation_avatar.dart';
import 'widgets/conversation_preview_tile.dart';
import 'widgets/messages_empty_state.dart';
import 'widgets/messages_filter_bar.dart';

class MessagesListScreen extends ConsumerStatefulWidget {
  const MessagesListScreen({super.key});

  @override
  ConsumerState<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends ConsumerState<MessagesListScreen> {
  final searchController = TextEditingController();
  bool unreadOnly = false;
  bool refreshing = false;
  String? refreshError;
  String search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  void _clearSearch() {
    searchController.clear();
    setState(() => search = '');
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);
    final bookings = ref.watch(myBookingsProvider);
    final profile = ref.watch(myPhotographerProvider);
    final assistantEnabled = ref.watch(assistantProvider).enabled;
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
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 16,
        backgroundColor: const Color(0xFFF9F9FA),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.ember,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.snow,
                size: 19,
              ),
            ),
            const SizedBox(width: 9),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LENS Studio',
                  style: TextStyle(
                    color: AppColors.steel,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tin nhắn',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 17,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ConversationAvatar(
                name: profile?.name ?? 'LENS',
                imageUrl: profile?.avatar,
                size: 36,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 7, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.ember,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            unread > 0
                                ? '$unread cuộc trò chuyện cần chú ý'
                                : 'Không có cuộc trò chuyện chưa đọc',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _AssistantStatusPill(enabled: assistantEnabled),
                ],
              ),
              const SizedBox(height: 12),
              _MessageSearchField(
                controller: searchController,
                hasQuery: search.isNotEmpty,
                onChanged: (value) => setState(() => search = value),
                onClear: _clearSearch,
              ),
              const SizedBox(height: 12),
              MessagesFilterBar(
                unreadOnly: unreadOnly,
                totalCount: conversations.length,
                unreadCount: unread,
                onChanged: (value) => setState(() => unreadOnly = value),
              ),
              const SizedBox(height: 14),
              if (refreshing) ...[
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.ember,
                    backgroundColor: Color(0xFFE8E8E9),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (refreshError != null) ...[
                _RefreshErrorBanner(error: refreshError!, onRetry: _refresh),
                const SizedBox(height: 10),
              ],
              if (filtered.isEmpty)
                MessagesEmptyState(
                  title: emptyTitle,
                  description: emptyDescription,
                )
              else
                for (final conversation in filtered)
                  ConversationPreviewTile(
                    conversation: conversation,
                    assistantEnabled: assistantEnabled,
                    booking: bookings
                        .where(
                          (booking) =>
                              booking.clientId == conversation.participantId,
                        )
                        .firstOrNull,
                    onTap: () => context.push(
                      '/photographer_home/messages/${conversation.id}',
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantStatusPill extends StatelessWidget {
  const _AssistantStatusPill({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F3F4),
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      border: Border.all(color: const Color(0xFFE8E8E9)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bolt_rounded,
          size: 14,
          color: enabled ? AppColors.ember : AppColors.steel,
        ),
        const SizedBox(width: 4),
        Text(
          'AI Assistant',
          style: TextStyle(
            color: enabled ? AppColors.graphite : AppColors.steel,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _MessageSearchField extends StatelessWidget {
  const _MessageSearchField({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Tìm theo tên hoặc nội dung...',
      hintStyle: const TextStyle(color: AppColors.steel, fontSize: 13),
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: AppColors.graphite,
        size: 20,
      ),
      suffixIcon: hasQuery
          ? IconButton(
              tooltip: 'Xóa tìm kiếm',
              onPressed: onClear,
              icon: const Icon(Icons.cancel_rounded, size: 17),
            )
          : null,
      filled: true,
      fillColor: const Color(0xFFEEEEEF),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        borderSide: const BorderSide(color: AppColors.ember, width: 1.2),
      ),
    ),
  );
}

class _RefreshErrorBanner extends StatelessWidget {
  const _RefreshErrorBanner({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFFFECEA),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.destructive,
          size: 18,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Không thể tải tin nhắn: $error',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.graphite,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );
}
