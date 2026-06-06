import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';
import '../../models/savings_setting.dart';

final _spendSaveProvider = FutureProvider<SavingsSetting>((ref) async {
  return ref.read(apiServiceProvider).getSpendSave();
});

class SpendSavePage extends ConsumerStatefulWidget {
  const SpendSavePage({super.key});

  @override
  ConsumerState<SpendSavePage> createState() => _SpendSavePageState();
}

class _SpendSavePageState extends ConsumerState<SpendSavePage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingAsync = ref.watch(_spendSaveProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      appBar: AppBar(title: const Text('Spend & Save')),
      body: settingAsync.when(
        data: (setting) => _buildContent(context, isDark, setting),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.charcoalGray.withAlpha(120)),
                const SizedBox(height: 12),
                Text('Could not load settings', style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(_spendSaveProvider),
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

  Widget _buildContent(BuildContext context, bool isDark, SavingsSetting setting) {
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
                colors: [AppColors.infoBlue, AppColors.infoBlue.withAlpha(200)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spend & Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('Save automatically on every transaction', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12)),
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
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    setting.spendSaveActive ? Icons.check_circle_rounded : Icons.savings_rounded,
                    color: AppColors.infoBlue, size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  setting.spendSaveActive ? 'Auto-Save Active' : 'Save While You Spend',
                  style: AppTypography.h4,
                ),
                const SizedBox(height: 4),
                Text(
                  setting.spendSaveActive
                      ? '${setting.spendSavePercentage.toInt()}% of every transaction is saved'
                      : 'Set a percentage to save on each purchase',
                  style: AppTypography.small.copyWith(color: AppColors.charcoalGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (!setting.spendSaveActive) ...[
                  _percentageSelector(setting),
                  const SizedBox(height: 12),
                  _currencySelector(setting),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _toggle(setting),
                    icon: Icon(setting.spendSaveActive ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
                    label: Text(setting.spendSaveActive ? 'Deactivate' : 'Activate Auto-Save'),
                    style: FilledButton.styleFrom(
                      backgroundColor: setting.spendSaveActive ? AppColors.errorRed : AppColors.infoBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How It Works', style: AppTypography.bodySemibold),
                const SizedBox(height: 12),
                _step('1', 'Choose a save percentage (1-50%)'),
                _step('2', 'Select your preferred currency'),
                _step('3', 'Every time you spend, that % is saved'),
                _step('4', 'Funds go to your savings wallet'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _percentageSelector(SavingsSetting setting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Save Percentage', style: AppTypography.bodySemibold),
            Text('${setting.spendSavePercentage.toInt()}%', style: AppTypography.bodySemibold),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: setting.spendSavePercentage,
          min: 1,
          max: 50,
          divisions: 49,
          label: '${setting.spendSavePercentage.toInt()}%',
          onChanged: (v) async {
            await ref.read(apiServiceProvider).updateSpendSave({
              'spend_save_percentage': v,
            });
            ref.invalidate(_spendSaveProvider);
          },
          activeColor: AppColors.primaryGold,
        ),
        Row(
          children: [5, 10, 15, 20, 25].map((p) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$p%', style: const TextStyle(fontSize: 12)),
              selected: setting.spendSavePercentage == p,
              onSelected: (_) async {
                await ref.read(apiServiceProvider).updateSpendSave({
                  'spend_save_percentage': p.toDouble(),
                });
                ref.invalidate(_spendSaveProvider);
              },
              selectedColor: AppColors.primaryGold,
              labelStyle: TextStyle(
                color: setting.spendSavePercentage == p ? Colors.white : AppColors.charcoalGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _currencySelector(SavingsSetting setting) {
    return DropdownButtonFormField<String>(
      value: setting.defaultSaveCurrency,
      decoration: const InputDecoration(
        labelText: 'Save Currency',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: ['USD', 'NGN', 'GBP', 'EUR', 'CAD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) async {
        if (v == null) return;
        await ref.read(apiServiceProvider).updateSpendSave({
          'default_save_currency': v,
        });
        ref.invalidate(_spendSaveProvider);
      },
    );
  }

  Future<void> _toggle(SavingsSetting setting) async {
    await ref.read(apiServiceProvider).updateSpendSave({
      'spend_save_active': !setting.spendSaveActive,
      'spend_save_percentage': setting.spendSavePercentage,
      'default_save_currency': setting.defaultSaveCurrency,
    });
    ref.invalidate(_spendSaveProvider);
  }

  Widget _step(String num, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: AppColors.infoBlue, shape: BoxShape.circle),
            child: Center(child: Text(num, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: AppTypography.body.copyWith(color: AppColors.charcoalGray))),
        ],
      ),
    );
  }
}
