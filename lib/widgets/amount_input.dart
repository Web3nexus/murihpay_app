import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AmountInput extends StatefulWidget {
  final String currency;
  final double? initialAmount;
  final ValueChanged<double>? onChanged;
  final String? hintText;

  const AmountInput({
    super.key,
    required this.currency,
    this.initialAmount,
    this.onChanged,
    this.hintText,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  final _controller = TextEditingController();
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    switch (widget.currency) {
      case 'NGN': _currencySymbol = '₦'; break;
      case 'USD': _currencySymbol = '\$'; break;
      case 'GBP': _currencySymbol = '£'; break;
      case 'CAD': _currencySymbol = 'C\$'; break;
    }
    if (widget.initialAmount != null) {
      _controller.text = widget.initialAmount.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            _currencySymbol,
            style: AppTypography.amountLarge.copyWith(
              color: AppColors.charcoalGray,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style: AppTypography.amountLarge.copyWith(
                color: AppColors.jetBlack,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText ?? '0.00',
                hintStyle: AppTypography.amountLarge.copyWith(
                  color: AppColors.lightGray.withAlpha(128),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null && widget.onChanged != null) {
                  widget.onChanged!(parsed);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
