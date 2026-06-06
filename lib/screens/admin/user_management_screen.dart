import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';
import '../../models/user.dart';

final _adminUsersProvider = FutureProvider<List<User>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getAdminUsers();
});

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(_adminUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Text('No users found',
                style: AppTypography.body.copyWith(color: AppColors.lightGray)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: users.length,
            itemBuilder: (_, i) {
              final user = users[i];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold.withAlpha(26),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: AppTypography.bodySemibold.copyWith(
                        color: AppColors.primaryGold),
                    ),
                  ),
                  title: Text(user.name, style: AppTypography.bodySemibold),
                  subtitle: Text(user.email,
                    style: AppTypography.small.copyWith(
                      color: AppColors.charcoalGray)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user.kycApproved
                              ? AppColors.successGreen
                              : AppColors.warningAmber,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(user.kycStatus,
                        style: AppTypography.caption.copyWith(
                          color: user.kycApproved
                              ? AppColors.successGreen
                              : AppColors.warningAmber,
                          fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
            style: AppTypography.body.copyWith(color: AppColors.errorRed)),
        ),
      ),
    );
  }
}
