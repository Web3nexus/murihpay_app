import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class MainTabShell extends StatelessWidget {
  final Widget child;

  const MainTabShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/wallets')) return 1;
    if (location.startsWith('/finance')) return 2;
    if (location.startsWith('/transfers')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home');
      case 1: context.go('/wallets');
      case 2: context.go('/finance');
      case 3: context.go('/transfers');
      case 4: context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 4,
          top: 4,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.pureWhite,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : Colors.black.withAlpha(10),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 8),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(5, (i) {
              final selected = index == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(context, i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryGold.withAlpha(26)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _icons[i],
                            size: 22,
                            color: selected
                                ? AppColors.primaryGold
                                : (isDark ? AppColors.lightGray : AppColors.charcoalGray),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _labels[i],
                          style: AppTypography.caption.copyWith(
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? AppColors.primaryGold
                                : (isDark ? AppColors.lightGray : AppColors.charcoalGray),
                            fontSize: selected ? 11 : 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

const _icons = [
  Icons.home_rounded,
  Icons.account_balance_wallet_rounded,
  Icons.savings_rounded,
  Icons.send_rounded,
  Icons.person_rounded,
];

const _labels = ['Home', 'Wallets', 'Finance', 'Transfers', 'Me'];
