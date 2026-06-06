import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/amount_input.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _recipientController = TextEditingController();
  final _noteController = TextEditingController();
  String _currency = 'USD';
  bool _loading = false;
  double? _amount;

  @override
  void dispose() {
    _recipientController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_recipientController.text.isEmpty) return;
    final amount = _amount;
    if (amount == null || amount <= 0) return;
    setState(() => _loading = true);
    try {
      await ref.read(apiServiceProvider).transfer(
        recipient: _recipientController.text,
        amount: amount,
        currency: _currency,
        description: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer submitted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Send Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send to', style: AppTypography.h4),
            const SizedBox(height: 8),
            GlassCard(
              onTap: () => context.push('/beneficiaries'),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add_alt_rounded,
                      color: AppColors.primaryGold, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text('Select Beneficiary', style: AppTypography.bodySemibold),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.charcoalGray),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Or enter email / account number',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('USD'),
                  selected: _currency == 'USD',
                  onSelected: (_) => setState(() => _currency = 'USD'),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _currency == 'USD' ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('NGN'),
                  selected: _currency == 'NGN',
                  onSelected: (_) => setState(() => _currency = 'NGN'),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _currency == 'NGN' ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('GBP'),
                  selected: _currency == 'GBP',
                  onSelected: (_) => setState(() => _currency = 'GBP'),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _currency == 'GBP' ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Amount', style: AppTypography.h4),
            const SizedBox(height: 8),
            AmountInput(
              currency: _currency,
              onChanged: (value) => setState(() => _amount = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  Icon(Icons.info_outlined, size: 20, color: AppColors.infoBlue),
                  const SizedBox(width: 12),
                  Text('Fee: 1.5%',
                    style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _send,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send Money'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
