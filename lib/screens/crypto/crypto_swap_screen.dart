import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers.dart';

class CryptoSwapScreen extends ConsumerStatefulWidget {
  const CryptoSwapScreen({super.key});

  @override
  ConsumerState<CryptoSwapScreen> createState() => _CryptoSwapScreenState();
}

class _CryptoSwapScreenState extends ConsumerState<CryptoSwapScreen> {
  final _amountCtrl = TextEditingController();
  String _from = 'USDC';
  String _to = 'USDT';
  bool _loading = false;

  final _coins = ['USDC', 'USDT', 'DAI', 'BUSD'];

  Future<void> _swap() async {
    if (_amountCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(apiClientProvider).post('/crypto/swap', data: {
        'from_currency': _from,
        'to_currency': _to,
        'amount': double.parse(_amountCtrl.text),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Swap submitted')),
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

  void _swapDirections() {
    setState(() {
      final temp = _from;
      _from = _to;
      _to = temp;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Swap Crypto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From', style: AppTypography.h4),
            const SizedBox(height: 8),
            Row(
              children: _coins.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: _from == c,
                  onSelected: (_) => setState(() => _from = c),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _from == c ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(hintText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Center(
              child: IconButton(
                icon: const Icon(Icons.swap_vert_rounded, size: 32, color: AppColors.primaryGold),
                onPressed: _swapDirections,
              ),
            ),
            const SizedBox(height: 12),
            Text('To', style: AppTypography.h4),
            const SizedBox(height: 8),
            Row(
              children: _coins.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: _to == c,
                  onSelected: (_) => setState(() => _to = c),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _to == c ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _swap,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Swap $_from to $_to'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
