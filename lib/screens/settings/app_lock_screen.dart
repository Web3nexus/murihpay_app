import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';
import '../../services/biometric_service.dart';

final _bioServiceProvider = Provider<BiometricService>((ref) => BiometricService());

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _lockEnabled = false;
  bool _hasPin = false;
  bool _loading = true;
  bool _biometricEnabled = false;
  bool _bioSupported = false;
  String _bioLabel = 'Biometric';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final storage = ref.read(storageServiceProvider);
    final enabled = await storage.getAppLockEnabled();
    final hasPin = await storage.hasAppPin();
    final bioEnabled = await storage.getBiometricEnabled();
    final bio = ref.read(_bioServiceProvider);
    final supported = await bio.canAuthenticate;
    final label = await bio.biometricLabel;
    if (mounted) {
      setState(() {
        _lockEnabled = enabled;
        _hasPin = hasPin;
        _biometricEnabled = bioEnabled;
        _bioSupported = supported;
        _bioLabel = label;
        _loading = false;
      });
    }
  }

  Future<void> _savePin() async {
    final newPin = _newPinController.text.trim();
    final confirm = _confirmPinController.text.trim();

    if (newPin.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits');
      return;
    }
    if (newPin != confirm) {
      setState(() => _error = 'PINs do not match');
      return;
    }

    final storage = ref.read(storageServiceProvider);
    await storage.setAppPin(newPin);
    await storage.setAppLockEnabled(true);
    if (!mounted) return;
    setState(() {
      _hasPin = true;
      _lockEnabled = true;
      _error = null;
      _newPinController.clear();
      _confirmPinController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App lock enabled')),
    );
  }

  Future<void> _toggleLock(bool v) async {
    final storage = ref.read(storageServiceProvider);
    if (!v && _hasPin) {
      await storage.removeAppPin();
      setState(() => _lockEnabled = false);
    } else if (v && !_hasPin) {
      setState(() { _lockEnabled = false; _error = 'Set a PIN first'; });
    } else {
      await storage.setAppLockEnabled(v);
      setState(() => _lockEnabled = v);
    }
  }

  Future<void> _toggleBiometric(bool v) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setBiometricEnabled(v);
    setState(() => _biometricEnabled = v);
  }

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('App Lock')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SwitchListTile(
                      title: Text('Require PIN on app open', style: AppTypography.body),
                      subtitle: Text('Lock the app when it goes to background', style: AppTypography.small.copyWith(
                        color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                      )),
                      value: _lockEnabled,
                      onChanged: _toggleLock,
                      activeColor: AppColors.primaryGold,
                    ),
                  ),
                ),
                if (_bioSupported) ...[
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SwitchListTile(
                        title: Text('$_bioLabel Lock', style: AppTypography.body),
                        subtitle: Text('Use $_bioLabel to unlock the app', style: AppTypography.small.copyWith(
                          color: isDark ? AppColors.lightGray : AppColors.charcoalGray,
                        )),
                        value: _biometricEnabled,
                        onChanged: _lockEnabled ? _toggleBiometric : null,
                        activeColor: AppColors.primaryGold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: AppColors.errorRed, fontSize: 13)),
                  ),
                Text('Set App PIN', style: AppTypography.bodySemibold.copyWith(
                  color: isDark ? Colors.white : AppColors.jetBlack,
                )),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'New PIN',
                    prefixIcon: Icon(Icons.lock_outline),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Confirm PIN',
                    prefixIcon: Icon(Icons.lock_outline),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _savePin,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save PIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
                if (_hasPin) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove PIN?'),
                            content: const Text('This will disable the app lock.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () async {
                                  await ref.read(storageServiceProvider).removeAppPin();
                                  if (!mounted) return;
                                  setState(() { _hasPin = false; _lockEnabled = false; });
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Remove', style: TextStyle(color: AppColors.errorRed)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Remove PIN'),
                    ),
                  ),
                ],
              ],
            ),
          ),
    );
  }
}
