import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/data_providers.dart';

class PhotographerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const PhotographerAppBar({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.ember.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.ember,
              size: 19,
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
                'CREATOR STUDIO',
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
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.fog,
                foregroundImage: profile.avatar.isEmpty
                    ? null
                    : NetworkImage(profile.avatar),
                onForegroundImageError: profile.avatar.isEmpty
                    ? null
                    : (_, _) {},
                child: Text(
                  profile.name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
