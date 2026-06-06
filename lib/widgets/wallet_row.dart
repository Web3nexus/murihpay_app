import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class WalletRow extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback? onTap;

  const WalletRow({
    super.key,
    required this.wallet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Center(
                  child: Text(
                    wallet.currency,
                    style: AppTypography.bodySemibold.copyWith(
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${wallet.currency} Wallet',
                      style: AppTypography.bodySemibold,
                    ),
                    const SizedBox(height: 2),
                    if (wallet.accountNumber != null)
                      Text(
                        wallet.accountNumber!,
                        style: AppTypography.small.copyWith(
                          color: AppColors.lightGray,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                wallet.formattedBalance,
                style: AppTypography.amount.copyWith(
                  color: AppColors.jetBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
