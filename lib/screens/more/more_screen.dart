import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static final _items = [
    const _MoreItem('Cards', Icons.credit_card_rounded, '/cards'),
    const _MoreItem('Crypto', Icons.currency_bitcoin_rounded, '/crypto'),
    const _MoreItem('Investments', Icons.trending_up_rounded, '/investments'),
    const _MoreItem('Fund', Icons.add_card_rounded, '/buy'),
    const _MoreItem('Withdraw', Icons.download_rounded, '/withdraw'),
    const _MoreItem('Swap', Icons.swap_horiz_rounded, '/convert'),
    const _MoreItem('Bills', Icons.receipt_rounded, '/bills'),
    const _MoreItem('Airtime', Icons.wifi_rounded, '/airtime'),
    const _MoreItem('Internet', Icons.language_rounded, '/internet'),
    const _MoreItem('Electricity', Icons.electric_bolt_rounded, '/electricity'),
    const _MoreItem('Gift Cards', Icons.card_giftcard_rounded, '/gift-cards'),
    const _MoreItem('Refer & Earn', Icons.share_rounded, '/referrals'),
    const _MoreItem('Transactions', Icons.swap_horiz_rounded, '/transactions'),
    const _MoreItem('Beneficiaries', Icons.people_rounded, '/beneficiaries'),
    const _MoreItem('Help Center', Icons.help_outline_rounded, '/help'),
    const _MoreItem('Settings', Icons.settings_rounded, '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: Text('More', style: AppTypography.h4)),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final item = _items[i];
          return GestureDetector(
            onTap: () => context.push(item.route),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(item.icon, color: AppColors.primaryGold, size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: AppTypography.small.copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  final String label;
  final IconData icon;
  final String route;

  const _MoreItem(this.label, this.icon, this.route);
}
