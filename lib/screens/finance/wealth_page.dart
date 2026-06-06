import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';

final _wealthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(apiServiceProvider).getWealth();
});

class WealthPage extends ConsumerStatefulWidget {
  const WealthPage({super.key});

  @override
  ConsumerState<WealthPage> createState() => _WealthPageState();
}

class _WealthPageState extends ConsumerState<WealthPage> {
  String _currency = 'USD';

  static const _rates = {'USD': 1.0, 'NGN': 1550.0, 'GBP': 0.79, 'EUR': 0.92, 'CAD': 1.37};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wealthAsync = ref.watch(_wealthProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      appBar: AppBar(title: const Text('Wealth')),
      body: wealthAsync.when(
        data: (data) => _buildContent(context, isDark, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.charcoalGray.withAlpha(120)),
                const SizedBox(height: 12),
                Text('Could not load wealth data', style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(_wealthProvider),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, Map<String, dynamic> data) {
    final netWorth = (data['net_worth'] ?? 0).toDouble();
    final totalBalance = (data['total_balance'] ?? 0).toDouble();
    final totalInvestments = (data['total_investments'] ?? 0).toDouble();
    final goalsTotal = (data['goals_total'] ?? 0).toDouble();
    final wallets = (data['wallets'] as List? ?? []).cast<Map<String, dynamic>>();
    final investments = (data['investments'] as List? ?? []).cast<Map<String, dynamic>>();

    final rate = _rates[_currency] ?? 1.0;
    final displayNetWorth = netWorth * rate;

    final currencySymbols = {'USD': '\$', 'NGN': '₦', 'GBP': '£', 'EUR': '€', 'CAD': 'C\$'};
    final symbol = currencySymbols[_currency] ?? '\$';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                    Text('Net Worth', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currency,
                          dropdownColor: AppColors.brandNavy,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          icon: const Icon(Icons.expand_more, color: Colors.white, size: 16),
                          items: ['USD', 'NGN', 'GBP', 'EUR', 'CAD'].map((c) => DropdownMenuItem(
                            value: c, child: Text('$c ${currencySymbols[c]}', style: const TextStyle(fontSize: 12)),
                          )).toList(),
                          onChanged: (v) => setState(() => _currency = v!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('$symbol${_format(displayNetWorth)}', style: AppTypography.display.copyWith(color: Colors.white, fontSize: 34)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _statRow(Icons.account_balance_wallet_rounded, 'Wallet Balance', '$symbol${_format(totalBalance * rate)}', AppColors.infoBlue),
                const Divider(height: 1),
                _statRow(Icons.trending_up_rounded, 'Investments', '$symbol${_format(totalInvestments * rate)}', AppColors.accentPurple),
                const Divider(height: 1),
                _statRow(Icons.flag_rounded, 'Savings Goals', '$symbol${_format(goalsTotal * rate)}', AppColors.successGreen),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Wallets', style: AppTypography.h4),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('See All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...wallets.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              child: ListTile(
                dense: true,
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primaryGold.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(w['currency']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primaryGold))),
                ),
                title: Text('${w['currency']} Wallet', style: AppTypography.bodySemibold),
                subtitle: Text('****${(w['account_number']?.toString() ?? '').substring((w['account_number']?.toString() ?? '').length > 4 ? (w['account_number']?.toString() ?? '').length - 4 : 0)}', style: AppTypography.small),
                trailing: Text('\$ ${_format((w['balance'] ?? 0).toDouble())}', style: AppTypography.bodySemibold),
              ),
            ),
          )),
          if (investments.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Investments', style: AppTypography.h4),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('See All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...investments.map((inv) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: ListTile(
                  dense: true,
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: (inv['type'] == 'LOCKED_SAVINGS' ? AppColors.successGreen : AppColors.accentPurple).withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.lock_rounded, size: 18, color: inv['type'] == 'LOCKED_SAVINGS' ? AppColors.successGreen : AppColors.accentPurple),
                  ),
                  title: Text(inv['name']?.toString() ?? '', style: AppTypography.bodySemibold),
                  subtitle: Text('${inv['currency'] ?? 'USD'} · ${inv['roi'] ?? 0}% APY', style: AppTypography.small),
                  trailing: Text('\$ ${_format((inv['amount'] ?? 0).toDouble())}', style: AppTypography.bodySemibold),
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
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
          Text(value, style: AppTypography.bodySemibold),
        ],
      ),
    );
  }

  String _format(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(2);
  }
}
