import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers.dart';

class CryptoSellScreen extends ConsumerStatefulWidget {
  const CryptoSellScreen({super.key});

  @override
  ConsumerState<CryptoSellScreen> createState() => _CryptoSellScreenState();
}

class _CryptoSellScreenState extends ConsumerState<CryptoSellScreen> {
  final _amountCtrl = TextEditingController();
  String _cryptoCurrency = 'BTC';
  String _fiatCurrency = 'NGN';
  double? _rate;
  bool _loading = false;

  final _cryptoOptions = ['BTC', 'ETH', 'USDT', 'SOL'];
  final _fiatOptions = ['NGN', 'USD', 'GBP', 'EUR', 'CAD'];

  Future<void> _fetchRate() async {
    if (_amountCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await ref.read(apiClientProvider).post('/crypto/sell', data: {
        'crypto_currency': _cryptoCurrency,
        'fiat_currency': _fiatCurrency,
        'crypto_amount': double.parse(_amountCtrl.text),
      });
      setState(() => _rate = res.data['rate'] ?? res.data['quote'] ?? 0);
    } catch (e) {
      setState(() => _rate = 1.0);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final estimated = amount * (_rate ?? 0);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Sell Crypto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You Sell', style: AppTypography.h4),
            const SizedBox(height: 8),
            Row(
              children: _cryptoOptions.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: _cryptoCurrency == c,
                  onSelected: (_) => setState(() => _cryptoCurrency = c),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _cryptoCurrency == c ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(hintText: 'Amount in crypto'),
              keyboardType: TextInputType.number,
              onChanged: (_) { setState(() {}); _fetchRate(); },
            ),
            const SizedBox(height: 24),
            Text('You Receive', style: AppTypography.h4),
            const SizedBox(height: 8),
            Row(
              children: _fiatOptions.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _fiatCurrency == f,
                  onSelected: (_) => setState(() => _fiatCurrency = f),
                  selectedColor: AppColors.primaryGold,
                  labelStyle: TextStyle(
                    color: _fiatCurrency == f ? Colors.white : AppColors.charcoalGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_rate != null)
                    Text('Rate: 1 $_cryptoCurrency = $_rate $_fiatCurrency',
                      style: AppTypography.bodySemibold),
                  const SizedBox(height: 4),
                  Text('Estimated: $estimated $_fiatCurrency',
                    style: AppTypography.h4.copyWith(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _fetchRate,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Sell'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
