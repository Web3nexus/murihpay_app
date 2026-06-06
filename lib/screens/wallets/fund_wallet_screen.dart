import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/amount_input.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';
import '../../services/api_client.dart';

class FundWalletScreen extends ConsumerStatefulWidget {
  const FundWalletScreen({super.key});

  @override
  ConsumerState<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends ConsumerState<FundWalletScreen> {
  String _selectedCurrency = 'USD';
  final _amountController = TextEditingController();
  bool _loading = false;

  final _currencies = ['USD', 'NGN', 'GBP', 'CAD'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fund() async {
    if (_amountController.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final dash = await ref.read(apiClientProvider).get('/dashboard');
      final wallets = ((dash.data['data']?['wallets'] as List?) ?? (dash.data['wallets'] as List? ?? [])).cast<Map<String, dynamic>>();
      final match = wallets.firstWhere(
        (w) => (w['currency']?.toString() ?? '') == _selectedCurrency,
        orElse: () => <String, dynamic>{},
      );
      final walletId = match['id'];
      if (walletId == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No wallet found for this currency')),
        );
        return;
      }
      await ref.read(apiServiceProvider).fundWallet(
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funding initiated')),
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
      appBar: AppBar(title: const Text('Fund Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Currency', style: AppTypography.h4),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _currencies.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: _selectedCurrency == c,
                    onSelected: (_) => setState(() => _selectedCurrency = c),
                    selectedColor: AppColors.primaryGold,
                    labelStyle: TextStyle(
                      color: _selectedCurrency == c ? Colors.white : AppColors.charcoalGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Amount', style: AppTypography.h4),
            const SizedBox(height: 8),
            AmountInput(currency: _selectedCurrency),
            const SizedBox(height: 24),
            GlassCard(
              child: Row(
                children: [
                  Icon(Icons.info_outlined, size: 20, color: AppColors.infoBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Funds will be credited to your $_selectedCurrency wallet instantly.',
                      style: AppTypography.small.copyWith(color: AppColors.charcoalGray),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _fund,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Continue to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
