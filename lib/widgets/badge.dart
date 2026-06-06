import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
  });

  factory StatusBadge.fromStatus(String status) {
    Color c;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
      case 'success':
        c = AppColors.successGreen;
        break;
      case 'pending':
      case 'processing':
        c = AppColors.warningAmber;
        break;
      case 'rejected':
      case 'failed':
      case 'declined':
        c = AppColors.errorRed;
        break;
      default:
        c = AppColors.lightGray;
    }
    return StatusBadge(label: status.toUpperCase(), color: c);
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.lightGray;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: c.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: c,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
