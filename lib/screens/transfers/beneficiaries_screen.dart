import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';
import '../../models/beneficiary.dart';

final _beneficiariesProvider = FutureProvider<List<Beneficiary>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getBeneficiaries();
});

class BeneficiariesScreen extends ConsumerWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final benAsync = ref.watch(_beneficiariesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Beneficiaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: benAsync.when(
        data: (beneficiaries) {
          if (beneficiaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.lightGray),
                  const SizedBox(height: 16),
                  Text('No beneficiaries',
                    style: AppTypography.h3.copyWith(color: AppColors.charcoalGray)),
                  const SizedBox(height: 8),
                  Text('Add your first beneficiary',
                    style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: beneficiaries.length,
            itemBuilder: (_, i) {
              final b = beneficiaries[i];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold.withAlpha(26),
                    child: Text(
                      b.name.isNotEmpty ? b.name[0].toUpperCase() : '?',
                      style: AppTypography.bodySemibold.copyWith(
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                  title: Text(b.name, style: AppTypography.bodySemibold),
                  subtitle: b.accountNumber != null
                      ? Text(b.accountNumber!,
                          style: AppTypography.small.copyWith(
                            color: AppColors.charcoalGray))
                      : null,
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
                    onPressed: () {
                      ref.read(apiServiceProvider).deleteBeneficiary(b.id);
                      ref.invalidate(_beneficiariesProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
