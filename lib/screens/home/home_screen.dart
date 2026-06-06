import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../store/auth_store.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/transaction_row.dart';
import '../../widgets/skeleton_loader.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';
import '../../providers.dart';
import '../../widgets/action_button.dart';
import '../../widgets/banner_popup.dart';

final _unreadCountProvider = FutureProvider<int>((ref) async {
  try {
    return await ref.read(apiServiceProvider).getUnreadNotificationCount();
  } catch (_) {
    return 0;
  }
});

final _dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(apiServiceProvider).getDashboardData();
});

final _recentTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  return ref.read(apiServiceProvider).getTransactions();
});

final selectedWalletIndexProvider = StateProvider<int>((ref) => 0);

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

String _countryFlag(String currency) {
  switch (currency.toUpperCase()) {
    case 'USD': return '\u{1F1FA}\u{1F1F8}';
    case 'NGN': return '\u{1F1F3}\u{1F1EC}';
    case 'GBP': return '\u{1F1EC}\u{1F1E7}';
    case 'EUR': return '\u{1F1EA}\u{1F1FA}';
    case 'CAD': return '\u{1F1E8}\u{1F1E6}';
    default: return '\u{1F310}';
  }
}

String? _tierLabel(String? tier) {
  if (tier == null) return null;
  final t = tier.toLowerCase();
  if (t == 'bronze') return 'L1';
  if (t == 'silver') return 'L2';
  if (t == 'gold') return 'L3';
  if (t == 'platinum') return 'L4';
  if (t == 'diamond') return 'L5';
  return tier.length <= 3 ? tier.toUpperCase() : 'VIP';
}

Color _tierColor(String? tier) {
  if (tier == null) return AppColors.lightGray;
  final t = tier.toLowerCase();
  if (t == 'bronze') return const Color(0xFFCD7F32);
  if (t == 'silver') return const Color(0xFFC0C0C0);
  if (t == 'gold') return AppColors.primaryGold;
  if (t == 'platinum') return const Color(0xFFE5E4E2);
  if (t == 'diamond') return const Color(0xFFB9F2FF);
  return AppColors.primaryGold;
}

String _shortBalance(double balance, String currency) {
  if (balance >= 1000000) {
    return '${(balance / 1000000).toStringAsFixed(1)}M';
  } else if (balance >= 1000) {
    return '${(balance / 1000).toStringAsFixed(1)}K';
  }
  return balance.toStringAsFixed(balance == balance.roundToDouble() ? 0 : 2);
}

final _homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final tabIndex = ref.watch(_homeTabIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tier = user?.tier;
    final tierBadge = _tierLabel(tier);
    final unreadAsync = ref.watch(_unreadCountProvider);
    final dashAsync = ref.watch(_dashboardProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Badge(
              backgroundColor: _tierColor(tier),
              textColor: Colors.black,
              smallSize: 18,
              label: tierBadge != null ? Text(tierBadge, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800)) : null,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryGold.withAlpha(26),
                child: Text(
                  (user?.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi, ${user?.name.split(' ').first ?? 'User'}',
                  style: AppTypography.bodySemibold.copyWith(
                    color: isDark ? Colors.white : AppColors.jetBlack,
                  )),
                Text('Welcome back', style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                )),
              ],
            ),
          ],
        ),
        actions: [
          unreadAsync.when(
            data: (unread) => Badge(
              isLabelVisible: unread > 0,
              backgroundColor: AppColors.errorRed,
              textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
              label: Text(unread.toString()),
              child: IconButton(
                icon: Icon(Icons.notifications_outlined,
                  color: isDark ? Colors.white : AppColors.jetBlack),
                onPressed: () => context.push('/notifications'),
              ),
            ),
            error: (_, __) => IconButton(
              icon: Icon(Icons.notifications_outlined,
                color: isDark ? Colors.white : AppColors.jetBlack),
              onPressed: () => context.push('/notifications'),
            ),
            loading: () => IconButton(
              icon: Icon(Icons.notifications_outlined,
                color: isDark ? Colors.white : AppColors.jetBlack),
              onPressed: () => context.push('/notifications'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.headset_mic_outlined,
              color: isDark ? Colors.white : AppColors.jetBlack),
            onPressed: () => context.push('/help'),
          ),
        ],
      ),
      body: Column(
        children: [
          _tabBar(context, tabIndex, (i) => ref.read(_homeTabIndexProvider.notifier).state = i),
          Expanded(
            child: tabIndex == 0 ? _fiatTab(context, ref, dashAsync) : _cryptoTab(context, ref, dashAsync),
          ),
        ],
      ),
    );
  }

  Widget _tabBar(BuildContext context, int selected, ValueChanged<int> onSelect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.borderColor.withAlpha(51),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _tabButton(context, 'Fiat', Icons.account_balance_rounded, 0, selected, onSelect)),
          const SizedBox(width: 4),
          Expanded(child: _tabButton(context, 'Crypto', Icons.currency_bitcoin_rounded, 1, selected, onSelect)),
        ],
      ),
    );
  }

  Widget _tabButton(BuildContext context, String label, IconData icon, int index, int selected, ValueChanged<int> onSelect) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? AppColors.lightGray : AppColors.charcoalGray)),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.smallMedium.copyWith(
              color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? AppColors.lightGray : AppColors.charcoalGray),
              fontWeight: FontWeight.w700,
            )),
          ],
        ),
      ),
    );
  }

  Widget _fiatTab(BuildContext context, WidgetRef ref, AsyncValue<Map<String, dynamic>> dashAsync) {
    final user = ref.watch(authProvider).user;
    final txAsync = ref.watch(_recentTransactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BannerPopup(),
          dashAsync.when(
            data: (data) {
              final wallets = _parseWallets(data['wallets']);
              if (wallets.isEmpty) {
                return BalanceCard(balance: 0, currency: 'USD', cardholderName: user?.name ?? 'User');
              }
              return _SwipeableBalanceCards(
                wallets: wallets,
                cardholderName: user?.name ?? 'User',
              );
            },
            loading: () => const ListSkeleton(itemCount: 1),
            error: (_, __) => BalanceCard(
              balance: 0,
              currency: 'USD',
              cardholderName: user?.name ?? 'User',
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionButton(icon: Icons.send_rounded, label: 'Send', backgroundColor: AppColors.withdrawPurple, onTap: () => context.push('/send')),
              const SizedBox(width: 16),
              ActionButton(icon: Icons.download_rounded, label: 'Receive', backgroundColor: AppColors.successGreen, onTap: () => context.push('/fund-wallet')),
              const SizedBox(width: 16),
              ActionButton(icon: Icons.swap_horiz_rounded, label: 'Swap', backgroundColor: AppColors.infoBlue, onTap: () => context.push('/convert')),
            ],
          ),
          const SizedBox(height: 20),

          _sectionTitle(context, 'Quick Access', '/more', isDark),
          const SizedBox(height: 10),
          _moreActionsBox(context),
          const SizedBox(height: 20),

          _bentoWallets(context, dashAsync),
          const SizedBox(height: 20),

          _sectionTitle(context, 'Finance', '/finance', isDark),
          const SizedBox(height: 10),
          dashAsync.when(
            data: (data) {
              final investments = _parseDefaultList(data['investments']);
              final wallets = _parseWallets(data['wallets']);
              final cards = _parseDefaultList(data['cards']);
              final invCount = investments.length;
              final cardCount = cards.length;
              final walletBalance = wallets.fold<double>(0, (sum, w) => sum + w.balance);
              return Row(
                children: [
                  Expanded(child: _bentoFinanceCard(context, 'Investments', invCount > 0 ? '\$${_shortBalance(walletBalance * 0.3, 'USD')}' : '\$0', Icons.trending_up_rounded, AppColors.accentPurple, '/investments')),
                  const SizedBox(width: 12),
                  Expanded(child: _bentoFinanceCard(context, 'Cards', '$cardCount Active', Icons.credit_card_rounded, AppColors.primaryGold, '/cards')),
                  const SizedBox(width: 12),
                  Expanded(child: _bentoFinanceCard(context, 'Crypto', '\$${_shortBalance(walletBalance * 0.15, 'USD')}', Icons.currency_bitcoin_rounded, AppColors.warningAmber, '/crypto')),
                ],
              );
            },
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),

          _sectionTitle(context, 'Referrals', '/referrals', isDark),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(14),
            borderRadius: 14,
            onTap: () => context.push('/referrals'),
            gradient: LinearGradient(
              colors: [AppColors.accentPurple.withAlpha(20), AppColors.accentPurple.withAlpha(5)],
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people_alt_rounded, color: AppColors.accentPurple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Refer & Earn', style: AppTypography.bodySemibold),
                      Text('Get \$5 for every friend who joins', style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                      )),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.accentPurple, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent', style: AppTypography.h4.copyWith(
                color: isDark ? Colors.white : AppColors.jetBlack,
              )),
              TextButton(
                onPressed: () => context.push('/transactions'),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          txAsync.when(
            data: (txs) {
              if (txs.isEmpty) {
                return GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.lightGray.withAlpha(100)),
                      const SizedBox(height: 12),
                      Text('No transactions yet', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                    ],
                  ),
                );
              }
              return GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: txs.take(5).map((tx) => TransactionRow(transaction: tx)).toList(),
                ),
              );
            },
            loading: () => const ListSkeleton(itemCount: 3),
            error: (_, __) => GlassCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load transactions',
                    style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          GlassCard(
            borderRadius: 14,
            onTap: () => context.push('/convert'),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up_rounded, color: AppColors.infoBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Exchange Rates', style: AppTypography.bodySemibold),
                      Text('USD/NGN, GBP/USD and more', style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                      )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: isDark ? AppColors.lightGray : AppColors.charcoalGray, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _cryptoTab(BuildContext context, WidgetRef ref, AsyncValue<Map<String, dynamic>> dashAsync) {
    final ratesAsync = ref.watch(_cryptoRatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dashAsync.when(
            data: (data) {
              final wallets = _parseWallets(data['wallets']);
              final cryptoBalance = wallets.fold<double>(0, (sum, w) => sum + w.balance) * 0.15;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandNavy, Color(0xFF0A2E6E)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandNavy.withAlpha(80),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Crypto Portfolio', style: AppTypography.caption.copyWith(
                          color: Colors.white.withAlpha(179),
                          letterSpacing: 1,
                        )),
                        Container(
                          width: 40, height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.currency_bitcoin, color: AppColors.primaryGold, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('\$${_shortBalance(cryptoBalance, 'USD')}', style: AppTypography.display.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, size: 14, color: AppColors.successGreen),
                        const SizedBox(width: 4),
                        Text('+8.2% today', style: AppTypography.small.copyWith(
                          color: AppColors.successGreen,
                        )),
                      ],
                    ),
                  ],
                ),
              );
            },
            error: (_, __) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandNavy, Color(0xFF0A2E6E)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandNavy.withAlpha(80),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Crypto Portfolio', style: AppTypography.caption.copyWith(
                        color: Colors.white.withAlpha(179),
                        letterSpacing: 1,
                      )),
                      Container(
                        width: 40, height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.currency_bitcoin, color: AppColors.primaryGold, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('\$0.00', style: AppTypography.display.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_flat, size: 14, color: AppColors.lightGray),
                      const SizedBox(width: 4),
                      Text('Connect wallet to view', style: AppTypography.small.copyWith(
                        color: Colors.white.withAlpha(150),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            loading: () => const ListSkeleton(itemCount: 1),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionButton(icon: Icons.add_rounded, label: 'Receive', backgroundColor: AppColors.successGreen, onTap: () => context.push('/fund-wallet')),
              const SizedBox(width: 16),
              ActionButton(icon: Icons.currency_exchange_rounded, label: 'Sell', backgroundColor: AppColors.withdrawPurple, onTap: () => context.push('/crypto/sell')),
              const SizedBox(width: 16),
              ActionButton(icon: Icons.swap_horiz_rounded, label: 'Swap', backgroundColor: AppColors.infoBlue, onTap: () => context.push('/crypto/swap')),
            ],
          ),
          const SizedBox(height: 20),

          Text('Market Rates', style: AppTypography.h4.copyWith(
            color: isDark ? Colors.white : AppColors.jetBlack,
          )),
          const SizedBox(height: 10),

          ratesAsync.when(
            data: (rates) {
              if (rates.isEmpty) {
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
              return Column(
                children: rates.map((rate) {
                  final name = rate['name']?.toString() ?? rate['currency']?.toString() ?? 'Unknown';
                  final symbol = rate['symbol']?.toString() ?? '';
                  final price = rate['price'] ?? rate['rate'] ?? 0;
                  final change = rate['change'] ?? rate['change_percentage'] ?? 0;
                  final icon = symbol.toLowerCase() == 'btc' ? Icons.currency_bitcoin :
                              symbol.toLowerCase() == 'eth' ? Icons.hexagon_rounded :
                              Icons.circle_rounded;
                  final isUp = (change is num) ? change >= 0 : true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 14,
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: (isUp ? AppColors.successGreen : AppColors.errorRed).withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: isUp ? AppColors.successGreen : AppColors.errorRed, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(symbol.toUpperCase(), style: AppTypography.bodySemibold.copyWith(
                                  color: isDark ? Colors.white : AppColors.jetBlack,
                                )),
                                Text(name, style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                                )),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${(price is num ? price.toDouble() : 0).toStringAsFixed(2)}', style: AppTypography.bodySemibold.copyWith(
                                color: isDark ? Colors.white : AppColors.jetBlack,
                              )),
                              Text('${(change is num ? change.toDouble() : 0).toStringAsFixed(2)}%', style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isUp ? AppColors.successGreen : AppColors.errorRed,
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const ListSkeleton(itemCount: 4),
            error: (_, __) => GlassCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                      const SizedBox(height: 12),
                      Text('Could not load crypto rates', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Wallet> _parseWallets(dynamic raw) {
    final list = raw as List? ?? [];
    return list.map((e) => Wallet.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  List<Map<String, dynamic>> _parseDefaultList(dynamic raw) {
    final list = raw as List? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Widget _bentoAction(BuildContext context, IconData icon, String label, Color color, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withAlpha(40) : AppColors.borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 25), blurRadius: 20, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withAlpha(isDark ? 20 : 10), blurRadius: 6, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.small.copyWith(
              fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.jetBlack,
            )),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String label, String seeAllRoute, bool isDark) {
    return Row(
      children: [
        Text(label, style: AppTypography.h4.copyWith(
          color: isDark ? Colors.white : AppColors.jetBlack,
        )),
        const Spacer(),
        TextButton(
          onPressed: () => context.push(seeAllRoute),
          child: Text('See All', style: TextStyle(color: AppColors.primaryGold)),
        ),
      ],
    );
  }

  Widget _moreActionsBox(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withAlpha(40) : AppColors.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 25), blurRadius: 20, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withAlpha(isDark ? 20 : 10), blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _miniAction(context, Icons.download_rounded, 'Withdraw', AppColors.infoBlue, '/withdraw'),
              _miniAction(context, Icons.shopping_bag_rounded, 'Buy', AppColors.successGreen, '/buy'),
              _miniAction(context, Icons.receipt_long_rounded, 'Bills', AppColors.warningAmber, '/bills'),
              _miniAction(context, Icons.card_giftcard_rounded, 'Gift Card', AppColors.withdrawPurple, '/gift-cards'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _miniAction(context, Icons.wifi_rounded, 'Airtime', AppColors.infoBlue, '/airtime'),
              _miniAction(context, Icons.language_rounded, 'Internet', AppColors.successGreen, '/internet'),
              _miniAction(context, Icons.electric_bolt_rounded, 'Electricity', AppColors.warningAmber, '/electricity'),
              _miniAction(context, Icons.grid_view_rounded, 'More', AppColors.accentPurple, '/more'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniAction(BuildContext context, IconData icon, String label, Color color, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Theme.of(context).textTheme.bodyLarge?.color : AppColors.jetBlack,
            )),
          ],
        ),
      ),
    );
  }

  Widget _bentoWallets(BuildContext context, AsyncValue<Map<String, dynamic>> dashAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return dashAsync.when(
      data: (data) {
        final wallets = _parseWallets(data['wallets']);
        if (wallets.isEmpty) return const SizedBox();
        final firstWallets = wallets.take(2).toList();
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withAlpha(40) : AppColors.borderColor),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 25), blurRadius: 20, offset: const Offset(0, 4)),
              BoxShadow(color: Colors.black.withAlpha(isDark ? 20 : 10), blurRadius: 6, offset: const Offset(0, 1)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppColors.primaryGold),
                  const SizedBox(width: 6),
                  Text('Wallets', style: AppTypography.smallMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.jetBlack,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              ...firstWallets.map((w) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(_countryFlag(w.currency), style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${w.currency}', style: AppTypography.small.copyWith(
                            fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.jetBlack,
                          )),
                          Text(w.formattedBalance, style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                          )),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _bentoFinanceCard(BuildContext context, String label, String value, IconData icon, Color color, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withAlpha(40) : AppColors.borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 25), blurRadius: 20, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withAlpha(isDark ? 20 : 10), blurRadius: 6, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value, style: AppTypography.bodySemibold.copyWith(
              color: isDark ? Colors.white : AppColors.jetBlack, fontSize: 16,
            )),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
            )),
          ],
        ),
      ),
    );
  }
}

class _SwipeableBalanceCards extends ConsumerStatefulWidget {
  final List<Wallet> wallets;
  final String cardholderName;

  const _SwipeableBalanceCards({
    required this.wallets,
    required this.cardholderName,
  });

  @override
  ConsumerState<_SwipeableBalanceCards> createState() => _SwipeableBalanceCardsState();
}

class _SwipeableBalanceCardsState extends ConsumerState<_SwipeableBalanceCards> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.wallets.length;
    return SizedBox(
      height: 224,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: count,
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                ref.read(selectedWalletIndexProvider.notifier).state = i;
              },
              itemBuilder: (context, i) {
                final w = widget.wallets[i];
                return Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 4 : 0,
                    right: i == count - 1 ? 4 : 0,
                  ),
                  child: BalanceCard(
                    balance: w.balance,
                    currency: w.currency,
                    cardholderName: widget.cardholderName,
                    countryCode: w.currency,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) {
              return GestureDetector(
                onTap: () => _pageController.animateToPage(i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primaryGold
                        : Colors.white.withAlpha(80),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
