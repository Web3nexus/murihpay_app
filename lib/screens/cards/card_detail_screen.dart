import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';
import '../../models/card_model.dart';
import '../../models/transaction.dart';

final _cardDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uuid) async {
  final api = ref.read(apiServiceProvider);
  final cards = await api.getCards();
  final card = cards.firstWhere((c) => c.uuid == uuid);
  final txs = await api.getTransactions();
  return {'card': card, 'transactions': txs};
});

class CardDetailScreen extends ConsumerStatefulWidget {
  final String uuid;

  const CardDetailScreen({super.key, required this.uuid});

  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends ConsumerState<CardDetailScreen> {
  bool _freezing = false;

  String _formatBalance(double balance, String currency) {
    String symbol;
    switch (currency) {
      case 'NGN': symbol = '₦'; break;
      case 'GBP': symbol = '£'; break;
      case 'CAD': symbol = 'C\$'; break;
      default: symbol = '\$';
    }
    return '$symbol${NumberFormat('#,##0.00').format(balance)}';
  }

  Future<void> _toggleFreeze(CardModel card) async {
    setState(() => _freezing = true);
    try {
      await ref.read(apiServiceProvider).freezeCard(card.uuid);
      ref.invalidate(_cardDetailProvider(widget.uuid));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(card.isFrozen ? 'Card unfrozen' : 'Card frozen')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _freezing = false);
    }
  }

  void _showLimits() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Card Limits'),
        content: const Text('Daily limit: \$10,000\nTransaction limit: \$2,500'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(_cardDetailProvider(widget.uuid));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Card Details')),
      body: detailAsync.when(
        data: (data) {
          final card = data['card'] as CardModel;
          final txs = data['transactions'] as List<Transaction>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardFront(card: card, balanceDisplay: _formatBalance(card.balance, card.currency)),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _ActionChip(
                        icon: card.isFrozen
                            ? Icons.check_circle_outline
                            : Icons.pause_circle_outline,
                        label: card.isFrozen ? 'Unfreeze' : 'Freeze',
                        color: card.isFrozen ? AppColors.successGreen : AppColors.warningAmber,
                        loading: _freezing,
                        onTap: () => _toggleFreeze(card),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionChip(
                        icon: Icons.edit_outlined,
                        label: 'Limits',
                        color: AppColors.infoBlue,
                        onTap: _showLimits,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Card Settings', style: AppTypography.h4),
                const SizedBox(height: AppSpacing.sm),
                GlassCard(
                  child: Column(
                    children: [
                      _SettingRow(icon: Icons.lock_outline, label: 'Change PIN'),
                      const Divider(),
                      _SettingRow(icon: Icons.block_outlined, label: 'Block Card'),
                      const Divider(),
                      _SettingRow(icon: Icons.phone_android_outlined, label: 'Add to Google Pay'),
                      const Divider(),
                      _SettingRow(icon: Icons.apple_outlined, label: 'Add to Apple Pay'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Recent Transactions', style: AppTypography.h4),
                const SizedBox(height: AppSpacing.sm),
                if (txs.isEmpty)
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text('No transactions',
                        style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                    ),
                  )
                else
                  GlassCard(
                    child: Column(
                      children: txs.take(5).map((tx) => _MiniTransactionRow(tx: tx)).toList(),
                    ),
                  ),
              ],
            ),
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

class _CardFront extends StatelessWidget {
  final CardModel card;
  final String balanceDisplay;

  const _CardFront({required this.card, required this.balanceDisplay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withAlpha(51),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${card.currency} Card',
                style: AppTypography.body.copyWith(color: Colors.white70)),
              Icon(Icons.wifi, color: Colors.white, size: 24),
            ],
          ),
          Text(balanceDisplay, style: AppTypography.amountLarge.copyWith(color: Colors.white)),
          Text(card.maskedNumber,
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white, letterSpacing: 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card.cardholderName,
                style: AppTypography.bodySemibold.copyWith(color: Colors.white)),
              Text(card.expiryDate,
                style: AppTypography.bodySemibold.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              if (loading)
                SizedBox(height: 24, width: 24, child: CircularProgressIndicator(
                  strokeWidth: 2, color: color,
                ))
              else
                Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label, style: AppTypography.small.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SettingRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.charcoalGray),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTypography.body)),
            Icon(Icons.chevron_right, color: AppColors.lightGray, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MiniTransactionRow extends StatelessWidget {
  final Transaction tx;
  const _MiniTransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(tx.description.isNotEmpty ? tx.description : tx.type,
              style: AppTypography.bodySemibold, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(tx.amountDisplay,
            style: AppTypography.bodySemibold.copyWith(
              color: tx.isCredit ? AppColors.successGreen : AppColors.errorRed)),
        ],
      ),
    );
  }
}
