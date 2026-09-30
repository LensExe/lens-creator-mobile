import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/creator_avatar.dart';
import '../../../providers/data_providers.dart';

class PhotographerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const PhotographerAppBar({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 27,
            decoration: BoxDecoration(
              color: AppColors.ember,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LENS',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.1,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'CREATOR',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.steel,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ...actions,
        if (profile != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Cài đặt hồ sơ',
              onPressed: () => context.push('/photographer_home/settings'),
              icon: CreatorAvatar(
                name: profile.name,
                imageUrl: profile.avatar,
                size: 36,
              ),
            ),
          ),
      ],
    );
  }
}
