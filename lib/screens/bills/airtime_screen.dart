import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers.dart';

class AirtimeScreen extends ConsumerStatefulWidget {
  const AirtimeScreen({super.key});

  @override
  ConsumerState<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends ConsumerState<AirtimeScreen> {
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _network = 'mtn';
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _purchase() async {
    if (_phoneCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(apiClientProvider).post('/transactions/bill-pay', data: {
        'bill_type': _network,
        'recipient': _phoneCtrl.text,
        'amount': double.parse(_amountCtrl.text),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Airtime purchase submitted')),
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
      appBar: AppBar(title: const Text('Buy Airtime')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network', style: AppTypography.h4),
            const SizedBox(height: 8),
            Row(
              children: ['mtn', 'airtel', 'glo', '9mobile'].map((n) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(n.toUpperCase()),
                  selected: _network == n,
                  onSelected: (_) => setState(() => _network = n),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _network == n ? Colors.black : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Text('Phone Number', style: AppTypography.h4),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(hintText: '08012345678'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Text('Amount', style: AppTypography.h4),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(hintText: '100'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _purchase,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Buy Airtime'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
