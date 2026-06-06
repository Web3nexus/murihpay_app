import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/app_notification.dart';

class NotificationDetailScreen extends ConsumerWidget {
  const NotificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = GoRouterState.of(context).extra as AppNotification?;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.backgroundLight;

    if (n == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Notification')),
        body: const Center(child: Text('Notification not found')),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Notification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _typeColor(n.type).withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_typeIcon(n.type), color: _typeColor(n.type), size: 28),
            ),
            const SizedBox(height: 16),
            Text(n.title, style: AppTypography.h3.copyWith(
              color: isDark ? Colors.white : AppColors.jetBlack,
            )),
            if (n.publishedAt != null) ...[
              const SizedBox(height: 6),
              Text(n.publishedAt!, style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
              )),
            ],
            if (n.type != 'info') ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _typeColor(n.type).withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(n.type.toUpperCase(), style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _typeColor(n.type),
                )),
              ),
            ],
            const SizedBox(height: 20),
            Text(n.body, style: AppTypography.body.copyWith(
              color: isDark ? Colors.white.withAlpha(204) : AppColors.charcoalGray,
              height: 1.6,
            )),
            if (n.actionUrl != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Learn More', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text('Dismiss', style: TextStyle(color: isDark ? AppColors.lightGray : AppColors.charcoalGray)),
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
