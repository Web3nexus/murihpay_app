import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/wallet_row.dart';
import '../../widgets/skeleton_loader.dart';
import '../../providers.dart';
import '../../models/wallet.dart';

final _walletsProvider = FutureProvider<List<Wallet>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getWallets();
});

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(_walletsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('My Wallets', style: AppTypography.h4),
        actions: [
          TextButton(
            onPressed: () => context.push('/convert'),
            child: const Text('Convert'),
          ),
        ],
      ),
      body: walletsAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                    size: 64, color: AppColors.lightGray),
                  const SizedBox(height: 16),
                  Text('No wallets yet',
                    style: AppTypography.h3.copyWith(color: AppColors.charcoalGray)),
                  const SizedBox(height: 8),
                  Text('Create a wallet to get started',
                    style: AppTypography.body.copyWith(color: AppColors.lightGray)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: wallets.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              if (i == wallets.length) {
                return const SizedBox(height: AppSpacing.lg);
              }
              final wallet = wallets[i];
              return WalletRow(
                wallet: wallet,
                onTap: () => context.push('/wallet/${wallet.uuid}'),
              );
            },
          );
        },
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SkeletonLoader(height: 76, borderRadius: AppSpacing.radiusMd),
            )),
          ),
        ),
        error: (e, _) {
          final msg = e is Exception ? e.toString().replaceAll('Exception: ', '') : 'Could not load wallets';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: AppColors.lightGray),
                  const SizedBox(height: 12),
                  Text(msg,
                    style: AppTypography.body.copyWith(color: AppColors.lightGray),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(_walletsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
