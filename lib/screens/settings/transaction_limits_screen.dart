import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../store/auth_store.dart';

class TransactionLimitsScreen extends ConsumerWidget {
  const TransactionLimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final tier = user?.tier?.toLowerCase() ?? 'bronze';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.backgroundLight;

    final limits = _limitsForTier(tier);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Transaction Limits')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed_rounded, color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 8),
                      Text('Your Account Level', style: AppTypography.bodySemibold),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _tierColor(tier).withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tier.toUpperCase(), style: TextStyle(
                          color: _tierColor(tier),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        )),
                      ),
                      const SizedBox(width: 12),
                      Text(limits['name'] as String, style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Daily Limits', style: AppTypography.h4.copyWith(
              color: isDark ? Colors.white : AppColors.jetBlack,
            )),
            const SizedBox(height: 10),
            _limitRow('Send Money', limits['daily_send'] as String, Icons.send_rounded, isDark),
            _limitRow('Receive Money', limits['daily_receive'] as String, Icons.download_rounded, isDark),
            _limitRow('Card Spending', limits['daily_card'] as String, Icons.credit_card_rounded, isDark),
            _limitRow('ATM Withdrawal', limits['daily_atm'] as String, Icons.atm_rounded, isDark),
            const SizedBox(height: 24),
            Text('Monthly Limits', style: AppTypography.h4.copyWith(
              color: isDark ? Colors.white : AppColors.jetBlack,
            )),
            const SizedBox(height: 10),
            _limitRow('Total Transactions', limits['monthly_total'] as String, Icons.swap_horiz_rounded, isDark),
            _limitRow('Deposits', limits['monthly_deposits'] as String, Icons.account_balance_rounded, isDark),
            _limitRow('Withdrawals', limits['monthly_withdrawals'] as String, Icons.download_rounded, isDark),
            const SizedBox(height: 24),
            Center(
              child: Text('Upgrade your account to increase limits',
                style: AppTypography.small.copyWith(
                  color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _limitRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 12,
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryGold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: AppTypography.body.copyWith(
                color: isDark ? Colors.white : AppColors.jetBlack,
              )),
            ),
            Text(value, style: AppTypography.bodySemibold.copyWith(
              color: AppColors.primaryGold,
            )),
          ],
        ),
      ),
    );
  }

  Color _tierColor(String tier) {
    switch (tier) {
      case 'bronze': return const Color(0xFFCD7F32);
      case 'silver': return const Color(0xFF9CA3AF);
      case 'gold': return AppColors.primaryGold;
      default: return AppColors.primaryGold;
    }
  }

  Map<String, dynamic> _limitsForTier(String tier) {
    switch (tier) {
      case 'bronze':
        return {
          'name': 'Basic Account',
          'daily_send': '\$1,000',
          'daily_receive': '\$5,000',
          'daily_card': '\$500',
          'daily_atm': '\$300',
          'monthly_total': '\$10,000',
          'monthly_deposits': '\$15,000',
          'monthly_withdrawals': '\$5,000',
        };
      case 'silver':
        return {
          'name': 'Enhanced Account',
          'daily_send': '\$10,000',
          'daily_receive': '\$25,000',
          'daily_card': '\$5,000',
          'daily_atm': '\$2,000',
          'monthly_total': '\$50,000',
          'monthly_deposits': '\$100,000',
          'monthly_withdrawals': '\$30,000',
        };
      case 'gold':
        return {
          'name': 'Premium Account',
          'daily_send': '\$50,000',
          'daily_receive': '\$100,000',
          'daily_card': '\$25,000',
          'daily_atm': '\$10,000',
          'monthly_total': '\$500,000',
          'monthly_deposits': '\$1,000,000',
          'monthly_withdrawals': '\$250,000',
        };
      default:
        return {
          'name': 'Basic Account',
          'daily_send': '\$1,000',
          'daily_receive': '\$5,000',
          'daily_card': '\$500',
          'daily_atm': '\$300',
          'monthly_total': '\$10,000',
          'monthly_deposits': '\$15,000',
          'monthly_withdrawals': '\$5,000',
        };
    }
  }
}
