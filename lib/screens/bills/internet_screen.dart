import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers.dart';

class InternetScreen extends ConsumerStatefulWidget {
  const InternetScreen({super.key});

  @override
  ConsumerState<InternetScreen> createState() => _InternetScreenState();
}

class _InternetScreenState extends ConsumerState<InternetScreen> {
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _provider = 'mtn-data';
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
        'bill_type': _provider,
        'recipient': _phoneCtrl.text,
        'amount': double.parse(_amountCtrl.text),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data purchase submitted')),
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
      appBar: AppBar(title: const Text('Buy Internet Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider', style: AppTypography.h4),
            const SizedBox(height: 8),
            Row(
              children: ['mtn-data', 'airtel-data', 'glo-data', '9mobile-data'].map((n) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(n.split('-')[0].toUpperCase()),
                  selected: _provider == n,
                  onSelected: (_) => setState(() => _provider = n),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _provider == n ? Colors.black : AppColors.charcoalGray,
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
              decoration: const InputDecoration(hintText: '1000'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _purchase,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Buy Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
