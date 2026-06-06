import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';
import '../../models/savings_goal.dart';

final _goalsProvider = FutureProvider<List<SavingsGoal>>((ref) async {
  return ref.read(apiServiceProvider).getSavingsGoals();
});

class TargetsPage extends ConsumerStatefulWidget {
  const TargetsPage({super.key});

  @override
  ConsumerState<TargetsPage> createState() => _TargetsPageState();
}

class _TargetsPageState extends ConsumerState<TargetsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsAsync = ref.watch(_goalsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      appBar: AppBar(title: const Text('Savings Targets')),
      body: goalsAsync.when(
        data: (goals) => goals.isEmpty ? _buildEmpty(context, isDark) : _buildContent(context, isDark, goals),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.charcoalGray.withAlpha(120)),
                const SizedBox(height: 12),
                Text('Could not load targets', style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(_goalsProvider),
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

  Widget _buildContent(BuildContext context, bool isDark, List<SavingsGoal> goals) {
    final active = goals.where((g) => g.status == 'active').toList();
    final completed = goals.where((g) => g.status == 'completed').toList();

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
                colors: [AppColors.accentPurple, AppColors.accentPurple.withAlpha(200)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${active.length} Active Targets', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('${completed.length} completed · Track your progress', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Targets', style: AppTypography.h4),
              FilledButton.tonalIcon(
                onPressed: () => _showCreateGoalSheet(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Goal'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGold.withAlpha(26),
                  foregroundColor: AppColors.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (active.isEmpty && completed.isEmpty)
            _buildEmpty(context, isDark)
          else ...[
            ...active.map((goal) => _goalCard(goal, isDark)),
            if (completed.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Completed', style: AppTypography.h4),
              const SizedBox(height: 12),
              ...completed.map((goal) => _goalCard(goal, isDark)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _goalCard(SavingsGoal goal, bool isDark) {
    final color = _parseColor(goal.color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_goalIcon(goal.icon), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name, style: AppTypography.bodySemibold),
                      Text('${goal.currency} ${_format(goal.currentAmount)} of ${_format(goal.targetAmount)}',
                        style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                    ],
                  ),
                ),
                if (goal.status == 'completed')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.successGreen.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goal.progress / 100,
                backgroundColor: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${goal.progress.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
                if (goal.deadline != null)
                  Text('Due ${goal.deadline}', style: AppTypography.small.copyWith(fontSize: 11, color: AppColors.charcoalGray)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.flag_rounded, size: 64, color: AppColors.charcoalGray.withAlpha(80)),
            const SizedBox(height: 16),
            Text('No savings targets yet', style: AppTypography.h4.copyWith(color: AppColors.charcoalGray)),
            const SizedBox(height: 8),
            Text('Create your first savings goal', style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _showCreateGoalSheet(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Target'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGoalSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    String currency = 'USD';
    String selectedIcon = 'flag';

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
              Text('New Savings Target', style: AppTypography.h4),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Target Name', border: OutlineInputBorder()),),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder()),),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || targetCtrl.text.isEmpty) return;
                    Navigator.of(ctx).pop();
                    await ref.read(apiServiceProvider).createSavingsGoal({
                      'name': nameCtrl.text,
                      'target_amount': double.parse(targetCtrl.text),
                      'currency': currency,
                      'icon': selectedIcon,
                    });
                    ref.invalidate(_goalsProvider);
                  },
                  child: const Text('Create Target'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _parseColor(String? color) {
    switch (color) {
      case 'purple': return AppColors.accentPurple;
      case 'green': return AppColors.successGreen;
      case 'blue': return AppColors.infoBlue;
      case 'amber': return AppColors.warningAmber;
      case 'red': return AppColors.errorRed;
      default: return AppColors.accentPurple;
    }
  }

  IconData _goalIcon(String? icon) {
    switch (icon) {
      case 'home': return Icons.home_rounded;
      case 'savings': return Icons.savings_rounded;
      case 'flight': return Icons.flight_rounded;
      case 'car': return Icons.directions_car_rounded;
      case 'school': return Icons.school_rounded;
      case 'favorite': return Icons.favorite_rounded;
      default: return Icons.flag_rounded;
    }
  }

  String _format(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(2);
  }
}
