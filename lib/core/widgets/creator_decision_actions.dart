import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class CreatorDecisionActions extends StatelessWidget {
  const CreatorDecisionActions({
    super.key,
    required this.onDecline,
    required this.onAccept,
    this.declineLabel = 'Từ chối',
    this.acceptLabel = 'Xác nhận',
    this.busy = false,
  });

  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final String declineLabel;
  final String acceptLabel;
  final bool busy;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: busy ? null : onDecline,
          child: Text(declineLabel),
        ),
      ),
      const SizedBox(width: AppTokens.space2),
      Expanded(
        child: FilledButton(
          onPressed: busy ? null : onAccept,
          child: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.snow,
                  ),
                )
              : Text(acceptLabel),
        ),
      ),
    ],
  );
}
