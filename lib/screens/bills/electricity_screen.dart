import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers.dart';

class ElectricityScreen extends ConsumerStatefulWidget {
  const ElectricityScreen({super.key});

  @override
  ConsumerState<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends ConsumerState<ElectricityScreen> {
  final _meterCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _disco = 'ikeja-electric';
  bool _loading = false;

  @override
  void dispose() {
    _meterCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_meterCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(apiClientProvider).post('/transactions/bill-pay', data: {
        'bill_type': _disco,
        'recipient': _meterCtrl.text,
        'amount': double.parse(_amountCtrl.text),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Electricity payment submitted')),
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
      appBar: AppBar(title: const Text('Pay Electricity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribution Company', style: AppTypography.h4),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['ikeja-electric', 'eko-electric', 'abuja-electric', 'ibadan-electric', 'kano-electric', 'portharcourt-electric'].map((n) => ChoiceChip(
                label: Text(n.split('-')[0].toUpperCase()),
                selected: _disco == n,
                onSelected: (_) => setState(() => _disco = n),
                selectedColor: AppColors.primaryGold,
                labelStyle: TextStyle(
                  color: _disco == n ? Colors.black : AppColors.charcoalGray,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Text('Meter Number', style: AppTypography.h4),
            const SizedBox(height: 8),
            TextField(
              controller: _meterCtrl,
              decoration: const InputDecoration(hintText: '01234567890'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text('Amount', style: AppTypography.h4),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(hintText: '5000'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _pay,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Pay Electricity'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
