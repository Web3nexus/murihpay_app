import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../../providers.dart';

final _adminNotifProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(apiServiceProvider).getAdminNotifications();
});

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends ConsumerState<AdminNotificationsScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _type = 'info';
  bool _showForm = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) return;
    await ref.read(apiServiceProvider).createNotification({
      'type': _type,
      'title': _titleCtrl.text.trim(),
      'body': _bodyCtrl.text.trim(),
    });
    _titleCtrl.clear();
    _bodyCtrl.clear();
    setState(() => _showForm = false);
    ref.invalidate(_adminNotifProvider);
  }

  Future<void> _publish(int id) async {
    await ref.read(apiServiceProvider).publishNotification(id);
    ref.invalidate(_adminNotifProvider);
  }

  Future<void> _delete(int id) async {
    await ref.read(apiServiceProvider).deleteNotification(id);
    ref.invalidate(_adminNotifProvider);
  }

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(_adminNotifProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Manage Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm) _buildForm(isDark),
          Expanded(
            child: notifAsync.when(
              data: (notifs) {
                if (notifs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none, size: 48, color: AppColors.lightGray.withAlpha(100)),
                        const SizedBox(height: 12),
                        Text('No notifications', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final n = notifs[i] as Map<String, dynamic>;
                    final published = n['is_published'] == true;
                    return GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: published ? AppColors.successGreen.withAlpha(26) : AppColors.warningAmber.withAlpha(26),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(published ? 'Published' : 'Draft', style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: published ? AppColors.successGreen : AppColors.warningAmber,
                                )),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.infoBlue.withAlpha(26),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text((n['type'] ?? 'info').toString().toUpperCase(), style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.infoBlue,
                                )),
                              ),
                              const Spacer(),
                              PopupMenuButton(
                                icon: Icon(Icons.more_vert, size: 18, color: isDark ? AppColors.lightGray : AppColors.charcoalGray),
                                itemBuilder: (_) => [
                                  if (!published)
                                    PopupMenuItem(
                                      child: const Text('Publish'),
                                      onTap: () => _publish(n['id'] is int ? n['id'] : int.parse(n['id'].toString())),
                                    ),
                                  PopupMenuItem(
                                    child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                                    onTap: () => _delete(n['id'] is int ? n['id'] : int.parse(n['id'].toString())),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(n['title']?.toString() ?? '', style: AppTypography.bodySemibold.copyWith(
                            color: isDark ? Colors.white : AppColors.jetBlack,
                          )),
                          const SizedBox(height: 4),
                          Text(n['body']?.toString() ?? '', style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                          ), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Padding(padding: EdgeInsets.all(16), child: ListSkeleton(itemCount: 4)),
              error: (_, __) => const Center(child: Text('Could not load notifications')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.pureWhite,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(10))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Type: ', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _type,
                items: ['info', 'warning', 'promotion', 'banner', 'newsletter'].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (v) => setState(() => _type = v ?? 'info'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title', isDense: true)),
          const SizedBox(height: 8),
          TextField(controller: _bodyCtrl, decoration: const InputDecoration(labelText: 'Body', isDense: true), maxLines: 3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _create,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGold),
                  child: const Text('Create', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _showForm = false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
