import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/amount_input.dart';
import '../../providers.dart';
import '../../services/api_client.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _amountCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _acctCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _bankCtrl.dispose();
    _acctCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    if (_amountCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final dash = await ref.read(apiClientProvider).get('/dashboard');
      final wallets = ((dash.data['data']?['wallets'] as List?) ?? (dash.data['wallets'] as List? ?? [])).cast<Map<String, dynamic>>();
      final walletId = wallets.isNotEmpty ? wallets.first['id'] : null;
      if (walletId == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No wallet available')),
        );
        return;
      }
      await ref.read(apiClientProvider).post('/transactions/payout', data: {
        'wallet_id': walletId,
        'amount': double.parse(_amountCtrl.text),
        'bank_name': _bankCtrl.text,
        'account_number': _acctCtrl.text,
        'account_name': _nameCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal submitted')),
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
      appBar: AppBar(title: const Text('Withdraw')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount', style: AppTypography.h4),
            const SizedBox(height: 8),
            AmountInput(currency: 'USD'),
            const SizedBox(height: 20),
            Text('Bank Name', style: AppTypography.h4),
            const SizedBox(height: 8),
            TextField(controller: _bankCtrl, decoration: const InputDecoration(hintText: 'e.g. Access Bank')),
            const SizedBox(height: 16),
            Text('Account Number', style: AppTypography.h4),
            const SizedBox(height: 8),
            TextField(controller: _acctCtrl, decoration: const InputDecoration(hintText: '0123456789'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Text('Account Name', style: AppTypography.h4),
            const SizedBox(height: 8),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Full name on account')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _withdraw,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Withdraw'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
