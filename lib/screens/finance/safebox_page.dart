import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';

final _safeboxProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(apiServiceProvider).getSafebox();
});

class SafeboxPage extends ConsumerStatefulWidget {
  const SafeboxPage({super.key});

  @override
  ConsumerState<SafeboxPage> createState() => _SafeboxPageState();
}

class _SafeboxPageState extends ConsumerState<SafeboxPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeboxAsync = ref.watch(_safeboxProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      appBar: AppBar(title: const Text('Safebox')),
      body: safeboxAsync.when(
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
                Text('Could not load safebox', style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(_safeboxProvider),
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
    final totalLocked = (data['total_locked'] ?? 0).toDouble();
    final savings = (data['savings'] as List? ?? []).cast<Map<String, dynamic>>();

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
                colors: [const Color(0xFF10B981), const Color(0xFF10B981).withAlpha(200)],
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
                      Text('Secure Your Savings', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('Lock funds and earn up to 15% APY', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Text('\$${_format(totalLocked)}', style: AppTypography.h2.copyWith(color: const Color(0xFF10B981))),
                const SizedBox(height: 4),
                Text('Total Locked Savings', style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showLockSheet(context),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text('Lock New Savings'),
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ),
          if (savings.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Locked Savings', style: AppTypography.h4),
            const SizedBox(height: 12),
            ...savings.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: (s['status'] == 'active' ? const Color(0xFF10B981) : AppColors.charcoalGray).withAlpha(26),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        s['status'] == 'active' ? Icons.lock_rounded : Icons.lock_open_rounded,
                        color: s['status'] == 'active' ? const Color(0xFF10B981) : AppColors.charcoalGray,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['name']?.toString() ?? '', style: AppTypography.bodySemibold),
                          Text('${s['currency'] ?? 'USD'} ${_format((s['amount'] ?? 0).toDouble())}',
                            style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                          if (s['maturity_date'] != null)
                            Text('Matures: ${s['maturity_date']}', style: AppTypography.small.copyWith(fontSize: 10, color: AppColors.charcoalGray)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (s['status'] == 'active' ? const Color(0xFF10B981) : AppColors.charcoalGray).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${s['interest_rate'] ?? 12}%', style: AppTypography.small.copyWith(
                        fontWeight: FontWeight.w700,
                        color: s['status'] == 'active' ? const Color(0xFF10B981) : AppColors.charcoalGray,
                      )),
                    ),
                  ],
                ),
              ),
            )),
          ],
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How Safebox Works', style: AppTypography.bodySemibold),
                const SizedBox(height: 12),
                _step('1', 'Choose an amount to lock away'),
                _step('2', 'Select your lock period (7-365 days)'),
                _step('3', 'Earn up to 15% APY paid at maturity'),
                _step('4', 'Funds are returned automatically'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLockSheet(BuildContext context) {
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
              Text('Lock Savings', style: AppTypography.h4),
              const SizedBox(height: 4),
              Text('Select currency and lock period', style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Savings Name', border: OutlineInputBorder()),),
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
                      items: ['USD', 'NGN', 'GBP', 'EUR', 'CAD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => currency = v ?? 'USD',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: durationDays,
                decoration: const InputDecoration(labelText: 'Lock Period', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 30, child: Text('30 Days - 8.5% APY')),
                  DropdownMenuItem(value: 60, child: Text('60 Days - 10.0% APY')),
                  DropdownMenuItem(value: 90, child: Text('90 Days - 10.0% APY')),
                  DropdownMenuItem(value: 180, child: Text('180 Days - 12.5% APY')),
                  DropdownMenuItem(value: 365, child: Text('365 Days - 15.0% APY')),
                ],
                onChanged: (v) => durationDays = v ?? 90,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                    Navigator.of(ctx).pop();
                    await ref.read(apiServiceProvider).createSafebox({
                      'name': nameCtrl.text,
                      'amount': double.parse(amountCtrl.text),
                      'currency': currency,
                      'duration_days': durationDays,
                    });
                    ref.invalidate(_safeboxProvider);
                  },
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  child: const Text('Lock Savings'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _step(String num, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
            child: Center(child: Text(num, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: AppTypography.body.copyWith(color: AppColors.charcoalGray))),
        ],
      ),
    );
  }

  String _format(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(2);
  }
}
