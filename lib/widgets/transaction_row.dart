import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionRow({
    super.key,
    required this.transaction,
    this.onTap,
  });

  IconData get _icon {
    if (transaction.isCredit) return Icons.arrow_downward_rounded;
    switch (transaction.type) {
      case 'transfer': return Icons.send_rounded;
      case 'bill': return Icons.receipt_rounded;
      case 'card': return Icons.credit_card_rounded;
      default: return Icons.swap_horiz_rounded;
    }
  }

  Color get _iconBgColor {
    if (transaction.isCredit) return AppColors.successGreen.withAlpha(26);
    return AppColors.errorRed.withAlpha(26);
  }

  Color get _iconColor {
    if (transaction.isCredit) return AppColors.successGreen;
    return AppColors.errorRed;
  }

  Color get _amountColor {
    if (transaction.isCredit) return AppColors.successGreen;
    return AppColors.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description.isNotEmpty
                          ? transaction.description
                          : transaction.type.toUpperCase(),
                      style: AppTypography.bodySemibold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.formattedDate,
                      style: AppTypography.small.copyWith(
                        color: AppColors.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.amountDisplay,
                    style: AppTypography.bodySemibold.copyWith(
                      color: _amountColor,
                    ),
                  ),
                  if (transaction.isPending)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningAmber.withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Pending',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warningAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
