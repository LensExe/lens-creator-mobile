import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/models/models.dart';
import '../conversation_provider.dart';
import 'conversation_avatar.dart';

void showConversationInfoSheet({
  required BuildContext context,
  required StudioConversation conversation,
  required List<Booking> bookings,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) =>
        _ConversationInfoSheet(conversation: conversation, bookings: bookings),
  );
}

class _ConversationInfoSheet extends StatelessWidget {
  const _ConversationInfoSheet({
    required this.conversation,
    required this.bookings,
  });

  final StudioConversation conversation;
  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusCard),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 9),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.pebble,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Row(
                children: [
                  ConversationAvatar(
                    name: conversation.participantName,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.participantName,
                          style: const TextStyle(
                            color: AppColors.obsidian,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          conversation.participantIsPhotographer
                              ? 'Nhiếp ảnh gia'
                              : 'Khách hàng',
                          style: const TextStyle(
                            color: AppColors.steel,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.steel,
                    tooltip: 'Đóng',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.fog),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Lịch chụp liên quan',
                      style: TextStyle(
                        color: AppColors.obsidian,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${bookings.length}',
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (bookings.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chưa có lịch chụp liên quan.',
                    style: TextStyle(color: AppColors.steel, fontSize: 11),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Material(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(
                        AppTokens.radiusInput,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTokens.radiusInput,
                          ),
                        ),
                        title: Text(
                          booking.style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.obsidian,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          booking.date,
                          style: const TextStyle(
                            color: AppColors.steel,
                            fontSize: 10,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.ash,
                        ),
                        onTap: () {
                          final router = GoRouter.of(context);
                          Navigator.pop(context);
                          router.push(
                            '/photographer_home/booking/${booking.id}',
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.pop(context);
                    router.go('/photographer_home/bookings');
                  },
                  icon: const Icon(Icons.calendar_month_outlined, size: 17),
                  label: const Text('Xem yêu cầu đặt lịch'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
