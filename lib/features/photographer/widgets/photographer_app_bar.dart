import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/creator_avatar.dart';
import '../../../core/widgets/lens_logo.dart';
import '../../../providers/data_providers.dart';

class PhotographerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const PhotographerAppBar({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myPhotographerProvider);
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: const Color(0xFFF8F8F9),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 12,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: Color(0x0D1A1C1D)),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3.5,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A00),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LensLogo(width: 44, height: 26),
              SizedBox(height: 2),
              Text(
                'STUDIO WORKSPACE',
                style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8D91),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ...actions,
        if (actions.isEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Thông báo',
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                color: const Color(0xFF474649),
                onPressed: () => context.push('/photographer_home/messages'),
                icon: const Icon(Icons.notifications_outlined),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A00),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF8F8F9),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (profile != null)
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 2),
            child: GestureDetector(
              onTap: () => context.push('/photographer_home/settings'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CreatorAvatar(
                    name: profile.name,
                    imageUrl: profile.avatar,
                    size: 32,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF8F8F9),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
