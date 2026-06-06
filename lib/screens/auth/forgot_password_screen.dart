import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _api = ApiClient();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _api.post('/auth/forgot-password', data: {'email': email});
      setState(() { _sent = true; });
    } on Exception catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  void dispose() { _emailController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_read_rounded, size: 64, color: AppColors.primaryGold),
                  const SizedBox(height: 16),
                  Text('Check your inbox', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text('If an account exists, you\'ll receive a reset link shortly.',
                      style: AppTypography.body.copyWith(color: AppColors.charcoalGray), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextButton(onPressed: () => context.go('/login'), child: const Text('Back to login')),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Forgot password?', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text('Enter your email to receive a reset link.',
                      style: AppTypography.body.copyWith(color: AppColors.charcoalGray)),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Container(width: double.infinity, padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.errorRed.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                      child: Text(_error!, style: const TextStyle(color: AppColors.errorRed, fontSize: 13))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email address'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send reset link'),
                  )),
                ],
              ),
      ),
    );
  }
}
