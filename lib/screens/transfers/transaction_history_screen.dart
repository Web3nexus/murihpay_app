import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/transaction_row.dart';
import '../../widgets/skeleton_loader.dart';
import '../../providers.dart';
import '../../models/transaction.dart';

final _allTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getTransactions();
});

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(_allTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: ['All', 'Income', 'Expense'].map((f) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _filter == f ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: txAsync.when(
              data: (txs) {
                var filtered = txs;
                if (_filter == 'Income') {
                  filtered = txs.where((t) => t.isCredit).toList();
                } else if (_filter == 'Expense') {
                  filtered = txs.where((t) => t.isDebit).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                          size: 64, color: AppColors.lightGray),
                        const SizedBox(height: 16),
                        Text('No transactions',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.charcoalGray)),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    GlassCard(
                      child: Column(
                        children: filtered.map((tx) => TransactionRow(
                          transaction: tx,
                        )).toList(),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const ListSkeleton(),
              error: (e, _) => Center(
                child: Text('Error: $e',
                  style: AppTypography.body.copyWith(color: AppColors.errorRed)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
