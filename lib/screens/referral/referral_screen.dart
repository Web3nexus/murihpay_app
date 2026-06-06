import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';

final _referralProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(apiServiceProvider).getReferralStats();
});

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_referralProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Refer & Earn', style: AppTypography.h4),
      ),
      body: async.when(
        data: (data) => _buildContent(context, ref, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildContent(context, ref, {
          'referral_code': '------',
          'referral_link': '',
          'total_referrals': 0,
          'active_referrals': 0,
          'referrals': [],
        }),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    final code = data['referral_code']?.toString() ?? '';
    final link = data['referral_link']?.toString() ?? '';
    final total = data['total_referrals'] ?? 0;
    final active = data['active_referrals'] ?? 0;
    final referrals = (data['referrals'] as List? ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGold, Color(0xFFD4A504)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text('Invite Friends, Earn Rewards', style: AppTypography.h3.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('Get \$5 for every friend who joins and verifies their identity',
                  style: AppTypography.body.copyWith(color: Colors.white.withAlpha(200)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              Expanded(child: _statCard('Total Referrals', total.toString(), Icons.people_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Verified', active.toString(), Icons.verified_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Earned', '\$${(total * 5).toStringAsFixed(0)}', Icons.monetization_on_rounded)),
            ],
          ),
          const SizedBox(height: 20),

          // Referral Code
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Referral Code', style: AppTypography.bodySemibold),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGold.withAlpha(51)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(code, style: AppTypography.h2.copyWith(letterSpacing: 4)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copied!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                if (link.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Referral link copied!')),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Invite Link'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Referred Users
          Text('Your Referrals', style: AppTypography.h4),
          const SizedBox(height: 12),
          if (referrals.isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.person_add_alt_1, size: 48, color: AppColors.lightGray),
                  const SizedBox(height: 12),
                  Text('No referrals yet', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                  Text('Share your code to start earning', style: AppTypography.small.copyWith(color: AppColors.lightGray)),
                ],
              ),
            )
          else
            ...referrals.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryGold.withAlpha(26),
                      child: Text(
                        (r['name']?.toString() ?? '?')[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['name']?.toString() ?? '', style: AppTypography.bodySemibold),
                          Text(r['email']?.toString() ?? '', style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: r['kyc_status'] == 'verified'
                            ? const Color(0xFF10B981).withAlpha(20)
                            : AppColors.warningAmber.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        r['kyc_status'] == 'verified' ? 'Verified' : 'Pending',
                        style: AppTypography.caption.copyWith(
                          color: r['kyc_status'] == 'verified'
                              ? const Color(0xFF10B981)
                              : AppColors.warningAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 22),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.h4),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.charcoalGray)),
        ],
      ),
    );
  }
}
