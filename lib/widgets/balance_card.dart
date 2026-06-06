import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

String _countryFlag(String currency) {
  switch (currency.toUpperCase()) {
    case 'USD': return '\u{1F1FA}\u{1F1F8}';
    case 'NGN': return '\u{1F1F3}\u{1F1EC}';
    case 'GBP': return '\u{1F1EC}\u{1F1E7}';
    case 'EUR': return '\u{1F1EA}\u{1F1FA}';
    case 'CAD': return '\u{1F1E8}\u{1F1E6}';
    default: return '\u{1F310}';
  }
}

String? _stableCoinLogo(String currency) {
  switch (currency.toUpperCase()) {
    case 'USDT': return 'USDT';
    case 'USDC': return 'USDC';
    case 'DAI': return 'DAI';
    case 'BUSD': return 'BUSD';
    default: return null;
  }
}

Color? _stableCoinColor(String currency) {
  switch (currency.toUpperCase()) {
    case 'USDT': return const Color(0xFF26A17B);
    case 'USDC': return const Color(0xFF2775CA);
    case 'DAI': return const Color(0xFFF5AC37);
    case 'BUSD': return const Color(0xFFF0B90B);
    default: return null;
  }
}

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final String? cardNumber;
  final String cardholderName;
  final String? expiryDate;
  final double? height;
  final String? countryCode;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    this.cardNumber,
    required this.cardholderName,
    this.expiryDate,
    this.height,
    this.countryCode,
  });

  String get _currencySymbol {
    switch (currency) {
      case 'NGN': return '\u20A6';
      case 'USD': return '\$';
      case 'GBP': return '\u00A3';
      case 'EUR': return '\u20AC';
      case 'CAD': return 'C\$';
      default: return '\$';
    }
  }

  String get _formattedBalance {
    final n = balance;
    if (n == n.roundToDouble()) {
      return n.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return n.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final stableCoin = _stableCoinLogo(currency);
    final stableColor = _stableCoinColor(currency);

    return Container(
      width: double.infinity,
      height: height ?? 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandNavy, Color(0xFF0A2E6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandNavy.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.brandNavy.withAlpha(30),
            blurRadius: 48,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _countryFlag(currency),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text('Total Balance', style: AppTypography.caption.copyWith(
                        color: Colors.white.withAlpha(179),
                        letterSpacing: 1,
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$_currencySymbol$_formattedBalance',
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                      if (stableCoin != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: stableColor?.withAlpha(179) ?? Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(stableCoin, style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currency} Wallet',
                    style: AppTypography.small.copyWith(
                      color: Colors.white.withAlpha(153),
                    ),
                  ),
                ],
              ),
              Container(
                width: 44,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wifi, color: Colors.white, size: 22),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CARDHOLDER', style: AppTypography.caption.copyWith(
                    color: Colors.white.withAlpha(153),
                    letterSpacing: 1,
                  )),
                  const SizedBox(height: 2),
                  Text(cardholderName, style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                  )),
                ],
              ),
              if (expiryDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('EXPIRES', style: AppTypography.caption.copyWith(
                      color: Colors.white.withAlpha(153),
                      letterSpacing: 1,
                    )),
                    const SizedBox(height: 2),
                    Text(expiryDate!, style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    )),
                  ],
                ),
            ],
          ),
          if (cardNumber != null)
            Text(
              cardNumber!,
              style: GoogleFonts.shareTechMono(
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
        ],
      ),
    );
  }
}
