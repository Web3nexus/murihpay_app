import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/badge.dart';
import '../../providers.dart';
import '../../models/kyc.dart';

final _kycQueueProvider = FutureProvider<List<KycSubmission>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getAdminKycQueue();
});

class KycQueueScreen extends ConsumerWidget {
  const KycQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(_kycQueueProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('KYC Queue')),
      body: queueAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_rounded, size: 64, color: AppColors.successGreen),
                  const SizedBox(height: 16),
                  Text('All clear!',
                    style: AppTypography.h3.copyWith(color: AppColors.charcoalGray)),
                  const SizedBox(height: 8),
                  Text('No pending KYC submissions',
                    style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: submissions.length,
            itemBuilder: (_, i) {
              final kyc = submissions[i];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(kyc.documentType, style: AppTypography.bodySemibold),
                        StatusBadge.fromStatus(kyc.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Submitted ${kyc.createdAt.toString().substring(0, 10)}',
                      style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.errorRed,
                                side: const BorderSide(color: AppColors.errorRed),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Reject', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: FilledButton(
                              onPressed: () {
                                ref.read(apiServiceProvider).approveKyc(kyc.id);
                                ref.invalidate(_kycQueueProvider);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Approve', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
            style: AppTypography.body.copyWith(color: AppColors.errorRed)),
        ),
      ),
    );
  }
}
