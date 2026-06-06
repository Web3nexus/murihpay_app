import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';

final _fixedDepositProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(apiServiceProvider).getFixedDeposits();
});

class FixedPage extends ConsumerStatefulWidget {
  const FixedPage({super.key});

  @override
  ConsumerState<FixedPage> createState() => _FixedPageState();
}

class _FixedPageState extends ConsumerState<FixedPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fdAsync = ref.watch(_fixedDepositProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      appBar: AppBar(title: const Text('Fixed Deposit')),
      body: fdAsync.when(
        data: (data) => _buildContent(context, isDark, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.charcoalGray.withAlpha(120)),
                const SizedBox(height: 12),
                Text('Could not load fixed deposits', style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(_fixedDepositProvider),
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

  Widget _buildContent(BuildContext context, bool isDark, Map<String, dynamic> data) {
    final totalDeposited = (data['total_deposited'] ?? 0).toDouble();
    final deposits = (data['deposits'] as List? ?? []).cast<Map<String, dynamic>>();
    final plans = (data['available_plans'] as List? ?? []).cast<Map<String, dynamic>>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brandNavy, const Color(0xFF0A2E6E)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fixed Deposit', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('Earn guaranteed returns', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Total Deposited', style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 4),
                Text('\$${_format(totalDeposited)}', style: AppTypography.h1.copyWith(color: AppColors.primaryGold, fontSize: 36)),
                const SizedBox(height: 4),
                Text('${deposits.length} active deposits', style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showCreateSheet(context, plans),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text('Create Fixed Deposit'),
                  ),
                ),
              ],
            ),
          ),
          if (deposits.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Your Deposits', style: AppTypography.h4),
            const SizedBox(height: 12),
            ...deposits.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: (d['status'] == 'active' ? AppColors.successGreen : AppColors.charcoalGray).withAlpha(26),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        d['status'] == 'active' ? Icons.schedule_rounded : Icons.check_circle_rounded,
                        color: d['status'] == 'active' ? AppColors.successGreen : AppColors.charcoalGray,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d['name']?.toString() ?? '', style: AppTypography.bodySemibold),
                          Text('${d['currency'] ?? 'USD'} ${_format((d['amount'] ?? 0).toDouble())}',
                            style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                          if (d['maturity_date'] != null)
                            Text('Matures: ${d['maturity_date']}', style: AppTypography.small.copyWith(fontSize: 10, color: AppColors.charcoalGray)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${d['interest_rate'] ?? 0}% APY', style: AppTypography.small.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.successGreen,
                      )),
                    ),
                  ],
                ),
              ),
            )),
          ],
          const SizedBox(height: 20),
          Text('Available Plans', style: AppTypography.h4),
          const SizedBox(height: 12),
          ...plans.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withAlpha(26),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.schedule_rounded, color: AppColors.primaryGold, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan['duration']?.toString() ?? '', style: AppTypography.bodySemibold),
                        Text('Min \$${_format((plan['min_amount'] ?? 0).toDouble())}',
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
                    child: Text('${plan['apy'] ?? 0}% APY', style: AppTypography.small.copyWith(
                      fontWeight: FontWeight.w700, color: AppColors.successGreen,
                    )),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context, List<Map<String, dynamic>> plans) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String currency = 'USD';
    int durationDays = 90;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Fixed Deposit', style: AppTypography.h4),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Deposit Name', border: OutlineInputBorder()),),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      value: currency,
                      decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder()),
                      items: ['USD', 'NGN'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => currency = v ?? 'USD',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: durationDays,
                decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
                items: plans.map((p) => DropdownMenuItem(
                  value: (p['duration'] as String?)?.split(' ').first.isNotEmpty == true
                      ? int.tryParse((p['duration'] as String?)?.split(' ').first ?? '90') ?? 90
                      : 90,
                  child: Text('${p['duration']} — ${p['apy']}% APY (min \$${_format((p['min_amount'] ?? 0).toDouble())})'),
                )).toList(),
                onChanged: (v) => durationDays = v ?? 90,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                    Navigator.of(ctx).pop();
                    await ref.read(apiServiceProvider).createFixedDeposit({
                      'name': nameCtrl.text,
                      'amount': double.parse(amountCtrl.text),
                      'currency': currency,
                      'duration_days': durationDays,
                    });
                    ref.invalidate(_fixedDepositProvider);
                  },
                  child: const Text('Create Deposit'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _format(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(2);
  }
}
