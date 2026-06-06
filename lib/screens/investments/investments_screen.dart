import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../providers.dart';
import '../../models/investment.dart';

final _investmentsProvider = FutureProvider<List<Investment>>((ref) async {
  return ref.read(apiServiceProvider).getInvestments();
});

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invAsync = ref.watch(_investmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Investments')),
      body: invAsync.when(
        data: (investments) {
          final totalInvested = investments.fold<double>(0, (sum, i) => sum + (i.totalInvested ?? 0));
          final avgRoi = investments.isEmpty ? 0.0 : investments.fold<double>(0, (sum, i) => sum + i.apy) / investments.length;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _metricCard('Total Invested', '\$${_format(totalInvested)}', Icons.trending_up, AppColors.successGreen),
                    const SizedBox(width: 12),
                    _metricCard('Avg. Return', '${avgRoi.toStringAsFixed(1)}%', Icons.show_chart, AppColors.infoBlue),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Your Investments', style: AppTypography.h4),
                const SizedBox(height: 12),
                if (investments.isEmpty)
                  GlassCard(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up_rounded, size: 48, color: AppColors.lightGray.withAlpha(100)),
                        const SizedBox(height: 12),
                        Text('No investments yet', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                      ],
                    ),
                  )
                else
                  ...investments.map((inv) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withAlpha(26),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.trending_up_rounded, color: AppColors.successGreen, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(inv.name, style: AppTypography.bodySemibold),
                                Text(inv.description.isNotEmpty ? inv.description : '\$${_format(inv.totalInvested ?? 0)} invested',
                                  style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${inv.apy?.toStringAsFixed(1) ?? '0.0'}% APY',
                              style: AppTypography.small.copyWith(
                                color: AppColors.successGreen, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          );
        },
        loading: () => const ListSkeleton(itemCount: 3),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.charcoalGray.withAlpha(120)),
                const SizedBox(height: 12),
                Text('Could not load investments', style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(_investmentsProvider),
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

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTypography.h3),
            Text(label, style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
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
}
