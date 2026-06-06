import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class CurrencyPill extends StatelessWidget {
  final String currency;
  final bool isSelected;
  final VoidCallback? onTap;

  const CurrencyPill({
    super.key,
    required this.currency,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.borderColor,
          ),
        ),
        child: Text(
          currency,
          style: AppTypography.bodySemibold.copyWith(
            color: isSelected ? Colors.white : AppColors.charcoalGray,
          ),
        ),
      ),
    );
  }
}
