import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  static const _categories = [
    _BillCategory(Icons.bolt_rounded, 'Electricity', AppColors.warningAmber, '/electricity'),
    _BillCategory(Icons.wifi_rounded, 'Internet', AppColors.infoBlue, '/internet'),
    _BillCategory(Icons.phone_android_rounded, 'Mobile', AppColors.successGreen, '/airtime'),
  ];

  static const _comingSoon = [
    _BillCategory(Icons.live_tv_rounded, 'TV/Cable', AppColors.withdrawPurple, null),
    _BillCategory(Icons.water_drop_rounded, 'Water', AppColors.infoBlue, null),
    _BillCategory(Icons.shield_rounded, 'Insurance', AppColors.errorRed, null),
    _BillCategory(Icons.school_rounded, 'Education', AppColors.primaryGold, null),
    _BillCategory(Icons.miscellaneous_services_rounded, 'Other', AppColors.charcoalGray, null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Pay Bills')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGold.withAlpha(26), Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGold.withAlpha(51)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Bill Pay', style: AppTypography.bodySemibold),
                        Text('Pay all your bills in one place',
                          style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Select a category', style: AppTypography.h4),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      return GestureDetector(
                        onTap: () => context.push(cat.route!),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [cat.color.withAlpha(40), cat.color.withAlpha(10)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 26),
                            ),
                            const SizedBox(height: 6),
                            Text(cat.label,
                              style: AppTypography.small.copyWith(fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (_comingSoon.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('More services coming soon', style: AppTypography.bodySmall.copyWith(color: AppColors.charcoalGray)),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _comingSoon.length,
                      itemBuilder: (_, i) {
                        final cat = _comingSoon[i];
                        return Opacity(
                          opacity: 0.4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [cat.color.withAlpha(40), cat.color.withAlpha(10)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(cat.icon, color: cat.color, size: 26),
                              ),
                              const SizedBox(height: 6),
                              Text(cat.label,
                                style: AppTypography.small.copyWith(fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillCategory {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  const _BillCategory(this.icon, this.label, this.color, [this.route]);
}
