import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../providers.dart';
import '../../models/card_model.dart';

final _cardsProvider = FutureProvider<List<CardModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getCards();
});

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  bool _issuing = false;

  void _showCreateCardDialog() {
    String type = 'virtual';
    String currency = 'USD';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Issue New Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Card Type', style: AppTypography.bodySemibold),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['virtual', 'physical'].map((t) => ChoiceChip(
                  label: Text(t[0].toUpperCase() + t.substring(1)),
                  selected: type == t,
                  onSelected: (_) => setDialogState(() => type = t),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: type == t ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              Text('Currency', style: AppTypography.bodySemibold),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['USD', 'NGN', 'GBP', 'CAD'].map((c) => ChoiceChip(
                  label: Text(c),
                  selected: currency == c,
                  onSelected: (_) => setDialogState(() => currency = c),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: currency == c ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _issuing ? null : () => _createCard(ctx, type, currency),
              child: _issuing
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Issue Card'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCard(BuildContext dialogContext, String type, String currency) async {
    setState(() => _issuing = true);
    try {
      await ref.read(apiServiceProvider).createCard({
        'type': type,
        'currency': currency,
      });
      ref.invalidate(_cardsProvider);
      if (!mounted) return;
      if (dialogContext.mounted) Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card created successfully')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(_cardsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('My Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showCreateCardDialog,
          ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.credit_card_outlined, size: 64, color: AppColors.lightGray),
                  const SizedBox(height: 16),
                  Text('No cards yet',
                    style: AppTypography.h3.copyWith(color: AppColors.charcoalGray)),
                  const SizedBox(height: 8),
                  Text('Issue your first virtual card',
                    style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _showCreateCardDialog,
                    child: const Text('Issue Card'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: cards.length,
                  itemBuilder: (_, i) {
                    final card = cards[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: _CardFront(
                        card: card,
                        onTap: () => context.push('/card/${card.uuid}'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Card Settings', style: AppTypography.h4),
              const SizedBox(height: AppSpacing.sm),
              ...cards.map((card) => GlassCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                onTap: () => context.push('/card/${card.uuid}'),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.credit_card_rounded,
                      color: AppColors.primaryGold, size: 22),
                  ),
                  title: Text(card.maskedNumber,
                    style: AppTypography.bodySemibold),
                  subtitle: Text(card.cardholderName,
                    style: AppTypography.small.copyWith(
                      color: AppColors.charcoalGray)),
                  trailing: Icon(Icons.chevron_right, color: AppColors.charcoalGray),
                ),
              )),
            ],
          );
        },
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(children: List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SkeletonLoader(height: 76, borderRadius: AppSpacing.radiusMd),
          ))),
        ),
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
  final VoidCallback? onTap;

  const _CardFront({required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withAlpha(51),
              blurRadius: 24,
              offset: const Offset(0, 8),
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
                  style: AppTypography.bodySemibold.copyWith(color: Colors.white70)),
                Icon(Icons.wifi, color: Colors.white, size: 24),
              ],
            ),
            Text(card.maskedNumber,
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white, letterSpacing: 2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CARD HOLDER',
                      style: AppTypography.caption.copyWith(color: Colors.white60)),
                    Text(card.cardholderName,
                      style: AppTypography.bodySemibold.copyWith(color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('EXPIRES',
                      style: AppTypography.caption.copyWith(color: Colors.white60)),
                    Text(card.expiryDate,
                      style: AppTypography.bodySemibold.copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
