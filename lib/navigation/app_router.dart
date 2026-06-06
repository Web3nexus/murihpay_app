import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../store/auth_store.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_tab_shell.dart';
import '../screens/wallets/wallets_screen.dart';
import '../screens/wallets/wallet_detail_screen.dart';
import '../screens/wallets/fund_wallet_screen.dart';
import '../screens/wallets/currency_converter_screen.dart';
import '../screens/transfers/send_money_screen.dart';
import '../screens/transfers/withdraw_screen.dart';
import '../screens/transfers/buy_screen.dart';
import '../screens/transfers/transaction_history_screen.dart';
import '../screens/transfers/beneficiaries_screen.dart';
import '../screens/cards/cards_screen.dart';
import '../screens/cards/card_detail_screen.dart';
import '../screens/crypto/crypto_screen.dart';
import '../screens/crypto/crypto_sell_screen.dart';
import '../screens/crypto/crypto_swap_screen.dart';
import '../screens/finance/finance_screen.dart';
import '../screens/finance/wealth_page.dart';
import '../screens/finance/targets_page.dart';
import '../screens/finance/safebox_page.dart';
import '../screens/finance/fixed_page.dart';
import '../screens/finance/spend_save_page.dart';
import '../screens/investments/investments_screen.dart';
import '../screens/bills/bills_screen.dart';
import '../screens/bills/airtime_screen.dart';
import '../screens/bills/internet_screen.dart';
import '../screens/bills/electricity_screen.dart';
import '../screens/gift_cards/gift_cards_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/security_screen.dart';
import '../screens/settings/account_upgrade_screen.dart';
import '../screens/settings/app_lock_screen.dart';
import '../screens/settings/transaction_limits_screen.dart';
import '../screens/settings/live_rates_screen.dart';
import '../screens/kyc/kyc_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/referral/referral_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/notifications/notification_detail_screen.dart';
import '../screens/admin/admin_notifications_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/kyc_queue_screen.dart';
import '../screens/admin/user_management_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _authRefreshNotifier = ValueNotifier<int>(0);

void refreshRouter() {
  _authRefreshNotifier.value++;
}

final routerProvider = Provider<GoRouter>((ref) {
  ref.onDispose(() => _authRefreshNotifier.dispose());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: _authRefreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isAdmin = state.matchedLocation.startsWith('/admin');

      if (isSplash || isOnboarding) return null;

      if (!isLoggedIn && !isAuth) return '/login';
      if (isLoggedIn && isAuth) return '/home';

      if (isAdmin && !(authState.user?.isAdmin ?? false)) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (_, __) => const RegisterScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainTabShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/wallets',
            builder: (_, __) => const WalletsScreen(),
          ),
          GoRoute(
            path: '/transfers',
            builder: (_, __) => const SendMoneyScreen(),
          ),
          GoRoute(
            path: '/finance',
            builder: (_, __) => const FinanceScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/wallet/:uuid',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => WalletDetailScreen(
          uuid: state.pathParameters['uuid']!,
        ),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const NotificationsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, __) => const NotificationDetailScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin-notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: '/fund-wallet',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const FundWalletScreen(),
      ),
      GoRoute(
        path: '/convert',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CurrencyConverterScreen(),
      ),
      GoRoute(
        path: '/send',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SendMoneyScreen(),
      ),
      GoRoute(
        path: '/transactions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/beneficiaries',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const BeneficiariesScreen(),
      ),
      GoRoute(
        path: '/cards',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CardsScreen(),
      ),
      GoRoute(
        path: '/card/:uuid',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => CardDetailScreen(
          uuid: state.pathParameters['uuid']!,
        ),
      ),
      GoRoute(
        path: '/crypto',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CryptoScreen(),
        routes: [
          GoRoute(
            path: 'sell',
            builder: (_, __) => const CryptoSellScreen(),
          ),
          GoRoute(
            path: 'swap',
            builder: (_, __) => const CryptoSwapScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/investments',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const InvestmentsScreen(),
      ),
      GoRoute(
        path: '/bills',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const BillsScreen(),
      ),
      GoRoute(
        path: '/gift-cards',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const GiftCardsScreen(),
      ),
      GoRoute(
        path: '/wealth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const WealthPage(),
      ),
      GoRoute(
        path: '/targets',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const TargetsPage(),
      ),
      GoRoute(
        path: '/safebox',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SafeboxPage(),
      ),
      GoRoute(
        path: '/fixed',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const FixedPage(),
      ),
      GoRoute(
        path: '/spend-save',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SpendSavePage(),
      ),
      GoRoute(
        path: '/referrals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'security',
            builder: (_, __) => const SecurityScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/kyc',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const KycScreen(),
      ),
      GoRoute(
        path: '/account-upgrade',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AccountUpgradeScreen(),
      ),
      GoRoute(
        path: '/app-lock',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AppLockScreen(),
      ),
      GoRoute(
        path: '/transaction-limits',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const TransactionLimitsScreen(),
      ),
      GoRoute(
        path: '/live-rates',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LiveRatesScreen(),
      ),
      GoRoute(
        path: '/more',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const MoreScreen(),
      ),
      GoRoute(
        path: '/withdraw',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const WithdrawScreen(),
      ),
      GoRoute(
        path: '/buy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const BuyScreen(),
      ),
      GoRoute(
        path: '/airtime',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AirtimeScreen(),
      ),
      GoRoute(
        path: '/internet',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const InternetScreen(),
      ),
      GoRoute(
        path: '/electricity',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ElectricityScreen(),
      ),
      GoRoute(
        path: '/help',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const HelpScreen(),
      ),
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'kyc',
            builder: (_, __) => const KycQueueScreen(),
          ),
          GoRoute(
            path: 'users',
            builder: (_, __) => const UserManagementScreen(),
          ),
        ],
      ),
    ],
  );
});
