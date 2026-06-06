import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers.dart';

final _totalSavedProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(apiServiceProvider).getTotalSaved();
});

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      appBar: AppBar(title: Text('Finance', style: AppTypography.h4)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalSaveCard(context, ref),
            const SizedBox(height: 16),
            _buildAssetBreakdown(context, ref),
            const SizedBox(height: 24),
            _buildFeatureGrid(context),
            const SizedBox(height: 24),
            _buildBanners(context),
            const SizedBox(height: 24),
            _buildQuickGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSaveCard(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(_totalSavedProvider);

    return savedAsync.when(
      data: (data) {
        final totalSaved = (data['total_saved'] ?? 0).toDouble();
        final growthRate = (data['growth_rate'] ?? 0).toDouble();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandNavy, Color(0xFF0A2E6E)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.brandNavy.withAlpha(60), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withAlpha(180), size: 20),
                  const SizedBox(width: 8),
                  Text('Total Saved', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              Text('\$${_format(totalSaved)}', style: AppTypography.display.copyWith(color: Colors.white, fontSize: 34)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 14, color: Colors.greenAccent),
                  const SizedBox(width: 4),
                  Text('${growthRate >= 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}% this month',
                    style: TextStyle(color: Colors.greenAccent.withAlpha(200), fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.brandNavy, Color(0xFF0A2E6E)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.brandNavy.withAlpha(60), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withAlpha(180), size: 20),
                const SizedBox(width: 8),
                Text('Total Saved', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Text('\$ --', style: AppTypography.display.copyWith(color: Colors.white, fontSize: 34)),
          ],
        ),
      ),
      error: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.brandNavy, Color(0xFF0A2E6E)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.brandNavy.withAlpha(60), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withAlpha(180), size: 20),
                const SizedBox(width: 8),
                Text('Total Saved', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Text('\$0.00', style: AppTypography.display.copyWith(color: Colors.white, fontSize: 34)),
          ],
        ),
      ),
    );
  }

  String _format(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(2);
  }

  Widget _buildAssetBreakdown(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedAsync = ref.watch(_totalSavedProvider);

    return savedAsync.when(
      data: (data) {
        final walletBalance = (data['wallet_balance'] ?? 0).toDouble();
        final investmentsTotal = (data['investments_total'] ?? 0).toDouble();
        final goalsTotal = (data['goals_total'] ?? 0).toDouble();
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withAlpha(40) : AppColors.borderColor),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 25), blurRadius: 20, offset: const Offset(0, 4)),
              BoxShadow(color: Colors.black.withAlpha(isDark ? 20 : 10), blurRadius: 6, offset: const Offset(0, 1)),
            ],
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: const Border(),
            collapsedShape: const Border(),
            leading: Icon(Icons.pie_chart_rounded, color: AppColors.primaryGold, size: 22),
            title: Text('Asset Breakdown', style: AppTypography.bodySemibold),
            subtitle: Text('Tap to expand', style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
            children: [
              _breakdownRow('Wallets', '\$${_format(walletBalance)}', Icons.account_balance_wallet_rounded, AppColors.infoBlue),
              const Divider(height: 1),
              _breakdownRow('Savings', '\$${_format(goalsTotal)}', Icons.savings_rounded, AppColors.successGreen),
              const Divider(height: 1),
              _breakdownRow('Investments', '\$${_format(investmentsTotal)}', Icons.trending_up_rounded, AppColors.accentPurple),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _breakdownRow(String label, String amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTypography.body)),
          Text(amount, style: AppTypography.bodySemibold),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _featureItem(context, Icons.account_balance_wallet_rounded, 'Wealth', AppColors.brandNavy, '/wealth')),
        const SizedBox(width: 12),
        Expanded(child: _featureItem(context, Icons.flag_rounded, 'Targets', AppColors.accentPurple, '/targets')),
        const SizedBox(width: 12),
        Expanded(child: _featureItem(context, Icons.lock_rounded, 'Safebox', AppColors.successGreen, '/safebox')),
        const SizedBox(width: 12),
        Expanded(child: _featureItem(context, Icons.schedule_rounded, 'Fixed', AppColors.warningAmber, '/fixed')),
        const SizedBox(width: 12),
        Expanded(child: _featureItem(context, Icons.savings_rounded, 'Spend&Save', AppColors.infoBlue, '/spend-save')),
      ],
    );
  }

  Widget _featureItem(BuildContext context, IconData icon, String label, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBanners(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _bannerCard('Save for Rainy Day', 'Start building your emergency fund', AppColors.brandNavy, Icons.umbrella_rounded),
          const SizedBox(width: 12),
          _bannerCard('Invest Smart', 'Earn up to 15% APY on fixed deposits', AppColors.accentPurple, Icons.trending_up_rounded),
          const SizedBox(width: 12),
          _bannerCard('Track Spending', 'Know where your money goes', AppColors.successGreen, Icons.analytics_rounded),
        ],
      ),
    );
  }

  Widget _bannerCard(String title, String subtitle, Color color, IconData icon) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _gridItem(context, 'Transactions', Icons.swap_horiz_rounded, '/transactions'),
        _gridItem(context, 'Cards', Icons.credit_card_rounded, '/cards'),
        _gridItem(context, 'Crypto', Icons.currency_bitcoin_rounded, '/crypto'),
        _gridItem(context, 'Invest', Icons.trending_up_rounded, '/investments'),
        _gridItem(context, 'Bills', Icons.receipt_rounded, '/bills'),
        _gridItem(context, 'Gift Cards', Icons.card_giftcard_rounded, '/gift-cards'),
        _gridItem(context, 'Refer', Icons.share_rounded, '/referrals'),
        _gridItem(context, 'More', Icons.grid_view_rounded, '/more'),
      ],
    );
  }

  Widget _gridItem(BuildContext context, String label, IconData icon, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTypography.small.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
