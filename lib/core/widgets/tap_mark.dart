import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small numbered badge used to mark where to tap in the UI.
class TapMark extends StatelessWidget {
  const TapMark(this.number, {super.key, this.tooltip});

  final int number;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    if (tooltip == null) return badge;
    return Tooltip(message: tooltip!, child: badge);
  }
}

/// Hint row: numbered mark + short instruction.
class TapHint extends StatelessWidget {
  const TapHint({
    super.key,
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TapMark(number),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
