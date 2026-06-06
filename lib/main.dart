import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'store/auth_store.dart';
import 'store/app_lock_provider.dart';
import 'navigation/app_router.dart';
import 'providers.dart';
import 'screens/settings/lock_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: MurihpayApp()));
}

class MurihpayApp extends ConsumerStatefulWidget {
  const MurihpayApp({super.key});

  @override
  ConsumerState<MurihpayApp> createState() => _MurihpayAppState();
}

class _MurihpayAppState extends ConsumerState<MurihpayApp> {
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onResume,
      onPause: _onPause,
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }

  Future<void> _onResume() async {
    final storage = ref.read(storageServiceProvider);
    final enabled = await storage.getAppLockEnabled();
    if (enabled && mounted) {
      ref.read(isAppLockedProvider.notifier).state = true;
    }
  }

  void _onPause() {
    // could clear sensitive data here if needed
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final isLocked = ref.watch(isAppLockedProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.isAuthenticated != next.isAuthenticated) {
        refreshRouter();
      }
    });

    return MaterialApp.router(
      title: 'Murihpay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (isLocked) const LockScreen(),
          ],
        );
      },
    );
  }
}
