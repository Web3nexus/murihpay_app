import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../models/app_notification.dart';
import '../../providers.dart';

final _notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  return ref.read(apiServiceProvider).getNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(_notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(apiServiceProvider).markAllNotificationsRead();
              ref.invalidate(_notificationsProvider);
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: notifAsync.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.lightGray.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final n = notifs[i];
              return _notificationCard(context, n, () async {
                await ref.read(apiServiceProvider).markNotificationRead(n.id);
                ref.invalidate(_notificationsProvider);
                if (context.mounted) {
                  context.push('/notifications/${n.id}', extra: n);
                }
              }, isDark);
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ListSkeleton(itemCount: 5),
        ),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
              const SizedBox(height: 12),
              Text('Could not load notifications', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => ref.invalidate(_notificationsProvider), child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationCard(BuildContext context, AppNotification n, VoidCallback onTap, bool isDark) {
    final icon = _typeIcon(n.type);
    final color = _typeColor(n.type);
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(n.title, style: AppTypography.bodySemibold.copyWith(
                        color: isDark ? Colors.white : AppColors.jetBlack,
                        fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                      )),
                    ),
                    if (!n.isRead)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n.body, style: AppTypography.small.copyWith(
                  color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                ), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (n.publishedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(_formatDate(n.publishedAt!), style: AppTypography.caption.copyWith(
                    color: AppColors.primaryGold.withAlpha(153),
                  )),
                ],
              ],
            ),
          ),
        ],
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

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return date;
    }
  }
}
