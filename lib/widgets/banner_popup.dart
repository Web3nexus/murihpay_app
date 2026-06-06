import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/app_notification.dart';
import '../providers.dart';
import 'glass_card.dart';

final unreadBannersProvider = FutureProvider<List<AppNotification>>((ref) async {
  final all = await ref.read(apiServiceProvider).getNotifications();
  return all.where((n) => n.isBanner && !n.isRead).take(3).toList();
});

class BannerPopup extends ConsumerWidget {
  const BannerPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(unreadBannersProvider);
    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        return Column(
          children: banners.map((b) => _bannerCard(context, ref, b)).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _bannerCard(BuildContext context, WidgetRef ref, AppNotification banner) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 14,
        gradient: LinearGradient(
          colors: [_typeColor(banner.type).withAlpha(30), _typeColor(banner.type).withAlpha(8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: _typeColor(banner.type).withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon(banner.type), color: _typeColor(banner.type), size: 18),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(banner.title, style: AppTypography.smallMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.jetBlack,
                  )),
                  const SizedBox(height: 2),
                  Text(banner.body, style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                  ), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await ref.read(apiServiceProvider).markNotificationRead(banner.id);
                ref.invalidate(unreadBannersProvider);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.close, size: 16, color: isDark ? AppColors.lightGray : AppColors.charcoalGray),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'banner': return Icons.campaign_rounded;
      case 'newsletter': return Icons.mail_outline_rounded;
      case 'promotion': return Icons.local_offer_rounded;
      case 'warning': return Icons.warning_amber_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'banner': return AppColors.accentPurple;
      case 'newsletter': return AppColors.infoBlue;
      case 'promotion': return AppColors.successGreen;
      case 'warning': return AppColors.warningAmber;
      default: return AppColors.primaryGold;
    }
  }
}
