import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PinKeypad extends StatefulWidget {
  final int pinLength;
  final ValueChanged<String> onCompleted;
  final String? error;

  const PinKeypad({
    super.key,
    this.pinLength = 4,
    required this.onCompleted,
    this.error,
  });

  @override
  State<PinKeypad> createState() => _PinKeypadState();
}

class _PinKeypadState extends State<PinKeypad> {
  final _pin = <int>[];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _shuffleKeys();
  }

  List<int> _keys = [];

  void _shuffleKeys() {
    _keys = List.generate(10, (i) => i)..shuffle(_rng);
  }

  void _onKey(int digit) {
    if (_pin.length >= widget.pinLength) return;
    setState(() => _pin.add(digit));
    if (_pin.length == widget.pinLength) {
      final pinStr = _pin.join();
      _shuffleKeys();
      widget.onCompleted(pinStr);
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: i < _pin.length
                    ? AppColors.primaryGold
                    : (isDark ? Colors.white.withAlpha(40) : Colors.black.withAlpha(26)),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 12),
          Text(widget.error!, style: const TextStyle(color: AppColors.errorRed, fontSize: 13)),
        ],
        const SizedBox(height: 28),

        // Number keypad (3x4 grid, scrambled)
        AspectRatio(
          aspectRatio: 0.85,
          child: LayoutBuilder(
            builder: (_, constraints) {
              final btnSize = constraints.maxWidth / 3.5;
              return GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.4,
                children: [
                  for (int i = 0; i < 9; i++)
                    _keyButton(_keys[i].toString(), btnSize),
                  const SizedBox(),
                  _keyButton(_keys[9].toString(), btnSize),
                  _backButton(btnSize),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _keyButton(String label, double size) {
    final digit = int.parse(label);
    return GestureDetector(
      onTap: () => _onKey(digit),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.borderColor.withAlpha(40),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.jetBlack,
          )),
        ),
      ),
    );
  }

  Widget _backButton(double size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.borderColor.withAlpha(40),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, size: 22, color: AppColors.primaryGold),
        ),
      ),
    );
  }
}
