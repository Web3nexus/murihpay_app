import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/amount_input.dart';
import '../../providers.dart';
import '../../services/api_client.dart';

class BuyScreen extends ConsumerStatefulWidget {
  const BuyScreen({super.key});

  @override
  ConsumerState<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends ConsumerState<BuyScreen> {
  final _amountCtrl = TextEditingController();
  String _currency = 'USD';
  bool _loading = false;

  final _currencies = ['USD', 'NGN', 'GBP', 'CAD'];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchDashboard() async {
    final response = await ref.read(apiClientProvider).get('/dashboard');
    return response.data['data'] ?? response.data;
  }

  Future<void> _buy() async {
    if (_amountCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final dash = await _fetchDashboard();
      final wallets = (dash['wallets'] as List? ?? []).cast<Map<String, dynamic>>();
      final match = wallets.cast<Map<String, dynamic>>().firstWhere(
        (w) => (w['currency']?.toString() ?? '') == _currency,
        orElse: () => <String, dynamic>{},
      );
      final walletId = match['id'];
      if (walletId == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No wallet found for this currency')),
        );
        return;
      }
      await ref.read(apiClientProvider).post('/transactions/fund', data: {
        'amount': double.parse(_amountCtrl.text),
        'wallet_id': walletId,
        'currency': _currency,
        'payment_method': 'card',
      });
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
      appBar: AppBar(title: const Text('Buy / Fund Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Currency', style: AppTypography.h4),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _currencies.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: _currency == c,
                    onSelected: (_) => setState(() => _currency = c),
                    selectedColor: AppColors.primaryGold,
                    labelStyle: TextStyle(
                      color: _currency == c ? Colors.black : AppColors.charcoalGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text('Amount', style: AppTypography.h4),
            const SizedBox(height: 8),
            AmountInput(currency: _currency),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _buy,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Continue to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
