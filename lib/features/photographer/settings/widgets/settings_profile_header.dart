import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/creator_avatar.dart';

class SettingsProfileHeader extends StatelessWidget {
  const SettingsProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.onChangeAvatar,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onChangeAvatar;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    decoration: BoxDecoration(
      color: AppColors.snow,
      border: Border.all(color: AppColors.fog),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
    ),
    child: Column(
      children: [
        Row(
          children: [
            CreatorAvatar(name: name, imageUrl: avatarUrl, size: 68),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onChangeAvatar,
            icon: const Icon(Icons.camera_alt_outlined, size: 17),
            label: const Text('Đổi ảnh đại diện'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.graphite,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      ],
    ),
  );
}
