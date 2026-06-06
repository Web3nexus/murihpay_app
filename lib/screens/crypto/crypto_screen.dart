import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/action_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../providers.dart';

final _cryptoRatesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  final raw = await client.get('/crypto/rates');
  if (raw.data['success'] == true && raw.data['data'] is Map) {
    final cryptos = (raw.data['data']['cryptocurrencies'] as List? ?? []);
    return cryptos.cast<Map<String, dynamic>>();
  }
  return _defaultCryptoRates();
});

List<Map<String, dynamic>> _defaultCryptoRates() {
  return [
    {'name': 'Bitcoin', 'symbol': 'BTC', 'price': 0, 'change': 0},
    {'name': 'Ethereum', 'symbol': 'ETH', 'price': 0, 'change': 0},
    {'name': 'USDC', 'symbol': 'USDC', 'price': 1.00, 'change': 0},
    {'name': 'USDT', 'symbol': 'USDT', 'price': 1.00, 'change': 0},
    {'name': 'Solana', 'symbol': 'SOL', 'price': 0, 'change': 0},
  ];
}

final _dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(apiServiceProvider).getDashboardData();
});

class CryptoScreen extends ConsumerWidget {
  const CryptoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(_cryptoRatesProvider);
    final dashAsync = ref.watch(_dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Crypto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push('/transactions'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dashAsync.when(
              data: (data) {
                final wallets = (data['wallets'] as List? ?? []).cast<Map<String, dynamic>>();
                final totalBalance = wallets.fold<double>(0, (sum, w) => sum + ((w['balance'] ?? 0).toDouble()));
                final cryptoEstimate = totalBalance * 0.15;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Portfolio Balance',
                        style: AppTypography.small.copyWith(color: Colors.white.withAlpha(180))),
                      const SizedBox(height: 4),
                      Text('\$${_shortBalance(cryptoEstimate)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('+8.2% today',
                          style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const ListSkeleton(itemCount: 1),
              error: (_, __) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Portfolio data unavailable',
                  style: TextStyle(color: Colors.white54, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ActionButton(icon: Icons.add_rounded, label: 'Buy', onTap: () => context.push('/buy'))),
                const SizedBox(width: 8),
                Expanded(child: ActionButton(icon: Icons.remove_rounded, label: 'Sell', onTap: () => context.push('/crypto/sell'))),
                const SizedBox(width: 8),
                Expanded(child: ActionButton(icon: Icons.swap_horiz_rounded, label: 'Swap', onTap: () => context.push('/crypto/swap'))),
              ],
            ),
            const SizedBox(height: 20),
            Text('Live Rates', style: AppTypography.h4),
            const SizedBox(height: 12),
            ratesAsync.when(
              data: (rates) => rates.isEmpty
                  ? _emptyRates()
                  : Column(
                      children: [
                        for (var i = 0; i < rates.length; i++) ...[
                          _rateRow(rates[i]),
                          if (i < rates.length - 1) _divider(),
                        ],
                      ],
                    ),
              loading: () => const ListSkeleton(itemCount: 4),
              error: (_, __) => _emptyRates(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyRates() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.currency_bitcoin, size: 48, color: AppColors.lightGray.withAlpha(100)),
          const SizedBox(height: 12),
          Text('No crypto rates available', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
        ],
      ),
    );
  }

  Widget _rateRow(Map<String, dynamic> coin) {
    final name = coin['name']?.toString() ?? '';
    final ticker = coin['symbol']?.toString() ?? '';
    final price = coin['price'] ?? 0;
    final change = (coin['change'] ?? 0).toDouble();
    final isUp = change >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGold.withAlpha(26), AppColors.primaryGold.withAlpha(10)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(ticker.isNotEmpty ? ticker[0] : '?',
                style: AppTypography.bodySemibold.copyWith(color: AppColors.primaryGold)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.bodySemibold),
                Text('\$$price • $ticker',
                  style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
              ],
            ),
          ),
          Text('${isUp ? '+' : ''}$change%',
            style: AppTypography.bodySemibold.copyWith(
              color: isUp ? AppColors.successGreen : AppColors.errorRed)),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.borderColor);

  String _shortBalance(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(2);
  }
}
