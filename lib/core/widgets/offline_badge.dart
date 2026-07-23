import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key, this.label = 'অফলাইন'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 14, color: AppColors.offline),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.offline,
            ),
          ),
        ],
      ),
    );
  }
}
