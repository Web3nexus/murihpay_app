import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ref.read(apiServiceProvider).getAdminDashboard();
      if (mounted) {
        setState(() {
          _data = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatMoney(double value) {
    if (value >= 1000000000) {
      return '\$${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatCount(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Admin')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
              const SizedBox(height: AppSpacing.sm),
              Text('Failed to load dashboard', style: AppTypography.h4),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _error!,
                style: AppTypography.small.copyWith(color: AppColors.charcoalGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                onPressed: _fetch,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final volumes = _data?['volumes'] as Map<String, dynamic>? ?? {};
    final monthlyVolume = (volumes['monthly_volume'] as num?)?.toDouble() ?? 0;
    final reconciliation = _data?['reconciliation_summary'] as Map<String, dynamic>? ?? {};
    final pendingAudits = (reconciliation['pending_audits'] as num?)?.toInt() ?? 0;
    final systemBalances = _data?['system_balances'] as Map<String, dynamic>? ?? {};
    final usdBalance = (systemBalances['USD'] as num?)?.toDouble() ?? 0;
    final recentTxns = _data?['recent_transactions'] as List<dynamic>? ?? [];
    final userCount = recentTxns
        .map((t) => (t as Map<String, dynamic>)['user'] as Map<String, dynamic>?)
        .where((u) => u != null)
        .map((u) => u!['email'] as String?)
        .whereType<String>()
        .toSet()
        .length;

    return RefreshIndicator(
      onRefresh: _fetch,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statCard('Users', _formatCount(userCount), Icons.people_rounded, AppColors.infoBlue),
                const SizedBox(width: 12),
                _statCard('Volume', _formatMoney(monthlyVolume), Icons.trending_up_rounded, AppColors.successGreen),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard('Pending KYC', _formatCount(pendingAudits), Icons.pending_actions_rounded, AppColors.warningAmber),
                const SizedBox(width: 12),
                _statCard('Reserves', _formatMoney(usdBalance), Icons.account_balance_rounded, AppColors.primaryGold),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Quick Actions', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push('/admin/kyc'),
              child: const ListTile(
                leading: Icon(Icons.verified_user_rounded, color: AppColors.primaryGold),
                title: Text('KYC Queue', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push('/admin/users'),
              child: const ListTile(
                leading: Icon(Icons.people_rounded, color: AppColors.infoBlue),
                title: Text('User Management', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              onTap: () => context.push('/admin-notifications'),
              child: const ListTile(
                leading: Icon(Icons.campaign_rounded, color: AppColors.accentPurple),
                title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Create & manage in-app announcements'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(value, style: AppTypography.h3),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
          ],
        ),
      ),
    );
  }
}
