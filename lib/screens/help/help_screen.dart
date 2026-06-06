import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  int? _expandedIndex;

  final _faqs = [
    _FaqItem('How do I send money?', 'Go to Transfers, select a beneficiary or enter recipient details, enter the amount, and confirm.'),
    _FaqItem('How do I fund my wallet?', 'Navigate to Wallets, select the wallet you want to fund, tap "Fund" and follow the payment instructions.'),
    _FaqItem('What is KYC verification?', 'KYC (Know Your Customer) is a verification process required to access all features including transfers, cards, and higher limits.'),
    _FaqItem('How long do transfers take?', 'Internal transfers are instant. External transfers may take 1-3 business days depending on the destination.'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Help Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search help articles...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.pureWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Frequently Asked Questions', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: _faqs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final faq = entry.value;
                  return Column(
                    children: [
                      if (i > 0) const Divider(),
                      InkWell(
                        onTap: () => setState(() => _expandedIndex = _expandedIndex == i ? null : i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(faq.question, style: AppTypography.bodySemibold),
                              ),
                              Icon(
                                _expandedIndex == i
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.charcoalGray,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_expandedIndex == i)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(faq.answer,
                            style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}
