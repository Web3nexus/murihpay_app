import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../services/auth_service.dart';
import '../../providers.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  bool _loading2FA = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadState());
  }

  Future<void> _loadState() async {
    try {
      final authService = AuthService(ref.read(apiClientProvider));
      final storage = ref.read(storageServiceProvider);
      final tfa = await authService.twoFactorStatus();
      final bio = await storage.getBiometricEnabled();
      if (mounted) setState(() { _twoFactorEnabled = tfa; _biometricEnabled = bio; });
    } catch (_) {}
  }

  Future<void> _toggle2FA(bool value) async {
    setState(() => _loading2FA = true);
    try {
      final authService = AuthService(ref.read(apiClientProvider));
      if (value) {
        await authService.setup2FA();
        await authService.enable2FA();
      } else {
        await authService.disable2FA();
      }
      if (mounted) {
        setState(() => _twoFactorEnabled = value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(value ? '2FA enabled' : '2FA disabled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading2FA = false);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    try {
      final storage = ref.read(storageServiceProvider);
      await storage.setBiometricEnabled(value);
      if (mounted) {
        setState(() => _biometricEnabled = value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(value ? 'Biometric login enabled' : 'Biometric login disabled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Security')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                children: [
                  _switchRow(
                    'Two-Factor Authentication',
                    'Add an extra layer of security',
                    _twoFactorEnabled,
                    _loading2FA ? null : (v) => _toggle2FA(v),
                  ),
                  const Divider(),
                  _switchRow(
                    'Biometric Login',
                    'Use Face ID / fingerprint to log in',
                    _biometricEnabled,
                    (v) => _toggleBiometric(v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 22, color: AppColors.charcoalGray),
                    const SizedBox(width: 14),
                    Expanded(child: Text('Change Password', style: AppTypography.body)),
                    const Icon(Icons.chevron_right, size: 20, color: AppColors.lightGray),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(String title, String subtitle, bool value, ValueChanged<bool>? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body),
                Text(subtitle, style: AppTypography.small.copyWith(color: AppColors.charcoalGray)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryGold,
          ),
        ],
      ),
    );
  }
}
