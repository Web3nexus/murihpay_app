import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../store/app_lock_provider.dart';
import '../../providers.dart';
import '../../services/biometric_service.dart';
import '../../services/screenshot_service.dart';
import '../../widgets/pin_keypad.dart';

final _biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String? _error;
  bool _bioAttempted = false;

  @override
  void initState() {
    super.initState();
    ScreenshotService.enableProtection();
    _tryBiometric();
  }

  @override
  void dispose() {
    ScreenshotService.disableProtection();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final storage = ref.read(storageServiceProvider);
    final bioEnabled = await storage.getBiometricEnabled();
    if (!bioEnabled) return;
    final bio = ref.read(_biometricServiceProvider);
    final canBio = await bio.canAuthenticate;
    if (!canBio) return;
    setState(() => _bioAttempted = true);
    final success = await bio.authenticate(reason: 'Unlock Murihpay');
    if (!mounted) return;
    if (success) {
      ref.read(isAppLockedProvider.notifier).state = false;
    }
  }

  Future<void> _onPinCompleted(String pin) async {
    final storage = ref.read(storageServiceProvider);
    final valid = await storage.verifyAppPin(pin);
    if (!mounted) return;
    if (valid) {
      ref.read(isAppLockedProvider.notifier).state = false;
    } else {
      setState(() => _error = 'Incorrect PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock_outline, color: AppColors.primaryGold, size: 32),
              ),
              const SizedBox(height: 24),
              Text('App Locked', style: AppTypography.h3.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Enter your PIN to continue', style: AppTypography.body.copyWith(
                color: AppColors.lightGray,
              )),
              const SizedBox(height: 32),
              PinKeypad(
                pinLength: 4,
                error: _error,
                onCompleted: _onPinCompleted,
              ),
              const SizedBox(height: 24),
              if (_bioAttempted)
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint, color: AppColors.primaryGold),
                  label: const Text('Use Face ID / Fingerprint', style: TextStyle(color: AppColors.primaryGold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
