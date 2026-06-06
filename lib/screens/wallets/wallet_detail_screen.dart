import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/transaction_row.dart';
import '../../widgets/skeleton_loader.dart';
import '../../providers.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';

final _walletDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uuid) async {
  final api = ref.read(apiServiceProvider);
  final wallet = await api.getWallet(uuid);
  final transactions = await api.getTransactions(walletId: uuid);
  return {'wallet': wallet, 'transactions': transactions};
});

class WalletDetailScreen extends ConsumerWidget {
  final String uuid;

  const WalletDetailScreen({super.key, required this.uuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_walletDetailProvider(uuid));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Wallet Details')),
      body: detailAsync.when(
        data: (data) {
          final wallet = data['wallet'] as Wallet;
          final transactions = data['transactions'] as List<Transaction>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${wallet.currency} Wallet',
                        style: AppTypography.h3),
                      const SizedBox(height: 8),
                      Text(wallet.formattedBalance,
                        style: AppTypography.amountLarge),
                      if (wallet.accountNumber != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Text('Account: ', style: AppTypography.body.copyWith(
                              color: AppColors.charcoalGray)),
                            Text(wallet.accountNumber!,
                              style: AppTypography.bodySemibold),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                  text: wallet.accountNumber!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied!')),
                                );
                              },
                              child: Icon(Icons.copy_rounded,
                                size: 18, color: AppColors.primaryGold),
                            ),
                          ],
                        ),
                      ],
                      if (wallet.bankName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(wallet.bankName!,
                            style: AppTypography.body.copyWith(
                              color: AppColors.charcoalGray)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Transactions', style: AppTypography.h4),
                const SizedBox(height: AppSpacing.sm),
                if (transactions.isEmpty)
                  GlassCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text('No transactions',
                          style: AppTypography.body.copyWith(
                            color: AppColors.lightGray)),
                      ),
                    ),
                  )
                else
                  GlassCard(
                    child: Column(
                      children: transactions.map((tx) => TransactionRow(
                        transaction: tx,
                      )).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(children: List.generate(5, (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SkeletonLoader(height: 76, borderRadius: AppSpacing.radiusMd),
          ))),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: AppTypography.body.copyWith(
            color: AppColors.errorRed)),
        ),
      ),
    );
  }
}
