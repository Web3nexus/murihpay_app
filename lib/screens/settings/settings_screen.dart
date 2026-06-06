import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../store/auth_store.dart';

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
  if (t == 'silver') return const Color(0xFF9CA3AF);
  if (t == 'gold') return AppColors.primaryGold;
  if (t == 'platinum') return const Color(0xFFE5E4E2);
  if (t == 'diamond') return const Color(0xFFB9F2FF);
  return AppColors.primaryGold;
}

String _tierName(String? tier) {
  if (tier == null) return 'Basic';
  final t = tier.toLowerCase();
  if (t == 'bronze') return 'Bronze';
  if (t == 'silver') return 'Silver';
  if (t == 'gold') return 'Gold';
  if (t == 'platinum') return 'Platinum';
  if (t == 'diamond') return 'Diamond';
  return tier;
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.backgroundLight;
    final tier = user?.tier;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text('Me', style: AppTypography.h4)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header with tier badge
            GlassCard(
              borderRadius: 16,
              onTap: () => context.push('/settings/profile'),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryGold.withAlpha(26),
                        child: Text(
                          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                          style: AppTypography.h3.copyWith(color: AppColors.primaryGold),
                        ),
                      ),
                      if (tier != null)
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _tierColor(tier),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _tierLabel(tier) ?? '',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _tierColor(tier) == AppColors.primaryGold ? Colors.black : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'User', style: AppTypography.bodySemibold.copyWith(
                          color: isDark ? Colors.white : AppColors.jetBlack,
                        )),
                        Text(_tierName(tier), style: AppTypography.small.copyWith(
                          color: _tierColor(tier),
                          fontWeight: FontWeight.w600,
                        )),
                        Text(user?.email ?? '', style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                        )),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.lightGray),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Account section
            _section(context, 'Account', [
              _Item(Icons.edit_outlined, 'Edit Profile', () => context.push('/settings/profile')),
              _Item(Icons.arrow_upward_rounded, 'Account Upgrade', () => context.push('/account-upgrade')),
              _Item(Icons.speed_rounded, 'Transaction Limits', () => context.push('/transaction-limits')),
              _Item(Icons.shield_outlined, 'Security', () => context.push('/settings/security')),
              _Item(Icons.verified_user_outlined, 'KYC Verification', () => context.push('/kyc')),
            ]),
            const SizedBox(height: 16),

            // Security section
            _section(context, 'Security', [
              _Item(Icons.lock_outline, 'App Lock (PIN)', () => context.push('/app-lock')),
              _Item(Icons.fingerprint, 'Biometric Login', () => context.push('/settings/security')),
            ]),
            const SizedBox(height: 16),

            // Finance section
            _section(context, 'Finance', [
              _Item(Icons.currency_exchange_rounded, 'Live Exchange Rates', () => context.push('/live-rates')),
              _Item(Icons.credit_card_rounded, 'Cards', () => context.push('/cards')),
              _Item(Icons.currency_bitcoin_rounded, 'Crypto', () => context.push('/crypto')),
              _Item(Icons.trending_up_rounded, 'Investments', () => context.push('/investments')),
            ]),
            const SizedBox(height: 16),

            // General section
            _section(context, 'General', [
              _Item(Icons.share_rounded, 'Refer & Earn', () => context.push('/referrals')),
              _Item(Icons.receipt_long_rounded, 'Transactions', () => context.push('/transactions')),
              _Item(Icons.people_rounded, 'Beneficiaries', () => context.push('/beneficiaries')),
              _Item(Icons.receipt_rounded, 'Bills', () => context.push('/bills')),
              _Item(Icons.card_giftcard_rounded, 'Gift Cards', () => context.push('/gift-cards')),
            ]),
            const SizedBox(height: 16),

            // Support section
            _section(context, 'Support', [
              _Item(Icons.help_outline, 'Help Center', () => context.push('/help')),
              _Item(Icons.info_outline, 'About', () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Murihpay',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text('Multi-currency fintech platform for Africa.'),
                  ],
                );
              }),
            ]),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  side: const BorderSide(color: AppColors.errorRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Log Out'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<_Item> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTypography.bodySemibold.copyWith(
            color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
          )),
        ),
        GlassCard(
          borderRadius: 14,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (i > 0) Divider(height: 1, color: isDark ? Colors.white.withAlpha(13) : AppColors.borderColor),
                  InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.vertical(
                      top: i == 0 ? const Radius.circular(14) : Radius.zero,
                      bottom: i == items.length - 1 ? const Radius.circular(14) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 20, color: AppColors.primaryGold),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(item.label, style: AppTypography.body.copyWith(
                              color: isDark ? Colors.white : AppColors.jetBlack,
                            )),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.lightGray),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Item(this.icon, this.label, this.onTap);
}
