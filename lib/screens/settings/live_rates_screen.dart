import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../models/exchange_rate.dart';
import '../../providers.dart';

final _ratesProvider = FutureProvider<List<ExchangeRate>>((ref) async {
  return ref.read(apiServiceProvider).getRates();
});

class LiveRatesScreen extends ConsumerWidget {
  const LiveRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(_ratesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Live Exchange Rates')),
      body: ratesAsync.when(
        data: (rates) {
          if (rates.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up_rounded, size: 48, color: AppColors.lightGray.withAlpha(100)),
                  const SizedBox(height: 12),
                  Text('No rates available', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final rate = rates[i];
              final change = rate.change;
              final isUp = change != null && change >= 0;
              return GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 14,
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.infoBlue.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('${rate.from}/${rate.to}', style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.infoBlue,
                        )),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${rate.from}/${rate.to}', style: AppTypography.bodySemibold.copyWith(
                            color: isDark ? Colors.white : AppColors.jetBlack,
                          )),
                          Text('1 ${rate.from} = ${rate.rate.toStringAsFixed(4)} ${rate.to}',
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                            )),
                        ],
                      ),
                    ),
                    if (change != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isUp ? AppColors.successGreen : AppColors.errorRed).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14, color: isUp ? AppColors.successGreen : AppColors.errorRed),
                            const SizedBox(width: 2),
                            Text('${change.toStringAsFixed(2)}%', style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isUp ? AppColors.successGreen : AppColors.errorRed,
                            )),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ListSkeleton(itemCount: 5),
        ),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
              const SizedBox(height: 12),
              Text('Could not load rates', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(_ratesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
