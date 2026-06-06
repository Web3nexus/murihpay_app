import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../store/auth_store.dart';

class AccountUpgradeScreen extends ConsumerWidget {
  const AccountUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final currentTier = user?.tier?.toLowerCase() ?? 'bronze';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Account Upgrade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose your account tier to unlock higher limits and more features.',
              style: AppTypography.body.copyWith(
                color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
              )),
            const SizedBox(height: 20),
            _tierCard(
              context, 'Bronze', Icons.looks_one_rounded,
              'Basic Account',
              ['Email verification', 'Phone number', 'Personal information'],
              '\$1,000 / day · \$10,000 / month',
              const Color(0xFFCD7F32),
              currentTier == 'bronze',
              currentTier == 'bronze' ? 'Current' : null,
              () => context.push('/kyc'),
            ),
            const SizedBox(height: 14),
            _tierCard(
              context, 'Silver', Icons.looks_two_rounded,
              'Enhanced Account',
              ['All Bronze requirements', 'Government-issued ID', 'Selfie verification (SmileID)', 'Proof of address (utility bill)'],
              '\$10,000 / day · \$50,000 / month',
              AppColors.charcoalGray,
              currentTier == 'silver',
              currentTier == 'silver' ? 'Current' : (currentTier == 'bronze' ? 'Upgrade' : null),
              () => context.push('/kyc'),
            ),
            const SizedBox(height: 14),
            _tierCard(
              context, 'Gold', Icons.looks_3_rounded,
              'Premium Account',
              ['All Silver requirements', 'Source of funds declaration', 'Proof of income / statements', 'Video verification call'],
              '\$50,000 / day · \$500,000 / month',
              AppColors.primaryGold,
              currentTier == 'gold',
              currentTier == 'gold' ? 'Current' : (currentTier == 'silver' ? 'Upgrade' : 'Locked'),
              currentTier == 'silver' ? () => context.push('/kyc') : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tierCard(
    BuildContext context,
    String name,
    IconData icon,
    String subtitle,
    List<String> requirements,
    String limits,
    Color color,
    bool isCurrent,
    String? actionLabel,
    VoidCallback? onAction,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isCurrent
            ? LinearGradient(
                colors: [color.withAlpha(20), color.withAlpha(5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isCurrent ? null : (isDark ? AppColors.glassDark : AppColors.glassWhite),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? color.withAlpha(128) : (isDark ? Colors.white.withAlpha(20) : Colors.white.withAlpha(120)),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(40) : Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(20) : Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.h4.copyWith(
                      color: isDark ? Colors.white : AppColors.jetBlack,
                    )),
                    Text(subtitle, style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                    )),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Active', style: AppTypography.small.copyWith(
                    color: AppColors.successGreen, fontWeight: FontWeight.w700,
                  )),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ...requirements.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: AppColors.successGreen),
                const SizedBox(width: 8),
                Expanded(child: Text(r, style: AppTypography.small.copyWith(
                  color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                ))),
              ],
            ),
          )),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.speed_rounded, size: 14, color: AppColors.primaryGold),
              const SizedBox(width: 6),
              Text(limits, style: AppTypography.small.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGold,
              )),
            ],
          ),
          if (actionLabel != null && !isCurrent) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: color.withAlpha(40),
                  disabledBackgroundColor: Colors.grey.withAlpha(26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(actionLabel, style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                )),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
