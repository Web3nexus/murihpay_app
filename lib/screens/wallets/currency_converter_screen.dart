import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/amount_input.dart';
import '../../providers.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  ConsumerState<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends ConsumerState<CurrencyConverterScreen> {
  String _from = 'USD';
  String _to = 'NGN';
  double _amount = 1;
  double? _rate;
  bool _converting = false;

  final _currencies = ['USD', 'NGN', 'GBP', 'CAD'];

  @override
  void initState() {
    super.initState();
    _fetchRate();
  }

  Future<void> _fetchRate() async {
    try {
      final api = ref.read(apiServiceProvider);
      final rate = await api.getRate(_from, _to);
      setState(() => _rate = rate.rate);
    } catch (_) {
      setState(() {
        if (_from == 'USD' && _to == 'NGN') {
          _rate = 1550;
        } else if (_from == 'USD' && _to == 'GBP') {
          _rate = 0.79;
        } else if (_from == 'USD' && _to == 'CAD') {
          _rate = 1.36;
        } else if (_from == 'NGN' && _to == 'USD') {
          _rate = 0.00065;
        } else {
          _rate = 1;
        }
      });
    }
  }

  Future<void> _convert() async {
    if (_amount <= 0) return;
    setState(() => _converting = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.convertCurrency(from: _from, to: _to, amount: _amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversion successful')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _converting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final converted = _amount * (_rate ?? 1);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Currency Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: _currencies.map((c) => ChoiceChip(
                label: Text(c),
                selected: _from == c,
                onSelected: (_) {
                  setState(() => _from = c);
                  _fetchRate();
                },
                selectedColor: AppColors.primaryGold,
                labelStyle: TextStyle(
                  color: _from == c ? Colors.white : AppColors.charcoalGray,
                  fontWeight: FontWeight.w600,
                ),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            AmountInput(
              currency: _from,
              onChanged: (v) => setState(() => _amount = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: IconButton(
                icon: const Icon(Icons.swap_vert_rounded, size: 32),
                color: AppColors.primaryGold,
                onPressed: () {
                  setState(() {
                    final tmp = _from;
                    _from = _to;
                    _to = tmp;
                  });
                  _fetchRate();
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('To', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: _currencies.map((c) => ChoiceChip(
                label: Text(c),
                selected: _to == c,
                onSelected: (_) {
                  setState(() => _to = c);
                  _fetchRate();
                },
                selectedColor: AppColors.primaryGold,
                labelStyle: TextStyle(
                  color: _to == c ? Colors.white : AppColors.charcoalGray,
                  fontWeight: FontWeight.w600,
                ),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Converted Amount',
                          style: AppTypography.small.copyWith(
                            color: AppColors.charcoalGray)),
                        const SizedBox(height: 4),
                        Text(
                          '$converted',
                          style: AppTypography.amount,
                        ),
                      ],
                    ),
                  ),
                  if (_rate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rate',
                          style: AppTypography.small.copyWith(
                            color: AppColors.charcoalGray)),
                        const SizedBox(height: 4),
                        Text('1 $_from = $_rate $_to',
                          style: AppTypography.small.copyWith(
                            fontWeight: FontWeight.w600)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _converting ? null : _convert,
                child: _converting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Convert Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
