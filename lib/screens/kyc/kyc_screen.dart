import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  String? _selectedDocType;
  String? _frontImagePath;
  String? _backImagePath;
  String? _selfiePath;
  bool _isSubmitting = false;
  final _picker = ImagePicker();

  final _docTypes = ['Passport', "Driver's License", 'National ID', 'NIN', 'BVN'];

  Future<void> _pickImage(String type) async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        if (type == 'front') {
          _frontImagePath = file.path;
        } else if (type == 'back') {
          _backImagePath = file.path;
        } else if (type == 'selfie') {
          _selfiePath = file.path;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedDocType == null) {
      _showSnackBar('Please select a document type.', Colors.red);
      return;
    }
    if (_frontImagePath == null) {
      _showSnackBar('Please upload the front of your document.', Colors.red);
      return;
    }
    if (_selfiePath == null) {
      _showSnackBar('Please upload a selfie.', Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(apiServiceProvider).submitKyc(
        documentType: _selectedDocType!,
        frontImagePath: _frontImagePath,
        backImagePath: _backImagePath,
        selfiePath: _selfiePath,
      );
      if (mounted) {
        _showSnackBar('KYC submitted successfully!', Colors.green);
        setState(() {
          _selectedDocType = null;
          _frontImagePath = null;
          _backImagePath = null;
          _selfiePath = null;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Submission failed: ${e.toString()}', Colors.red);
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Verify Identity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Row(
                children: [
                  Icon(Icons.info_outlined, size: 20, color: AppColors.infoBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verify your identity to unlock all features including transfers, cards, and higher limits.',
                      style: AppTypography.small.copyWith(color: AppColors.charcoalGray),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Document Type', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _docTypes.map((d) => ChoiceChip(
                label: Text(d),
                selected: _selectedDocType == d,
                onSelected: (_) => setState(() => _selectedDocType = d),
                selectedColor: AppColors.primaryGold,
                labelStyle: TextStyle(
                  color: _selectedDocType == d ? Colors.white : AppColors.charcoalGray,
                  fontWeight: FontWeight.w600,
                ),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Upload Documents', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            _uploadBox('Front of Document', Icons.document_scanner_outlined, 'front', _frontImagePath),
            const SizedBox(height: AppSpacing.sm),
            _uploadBox('Back of Document', Icons.document_scanner_outlined, 'back', _backImagePath),
            const SizedBox(height: AppSpacing.sm),
            _uploadBox('Selfie', Icons.camera_alt_outlined, 'selfie', _selfiePath),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit for Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadBox(String label, IconData icon, String type, String? imagePath) {
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: imagePath != null ? AppColors.primaryGold : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                imagePath != null ? '$label \u2713' : label,
                style: AppTypography.body.copyWith(
                  color: imagePath != null ? AppColors.primaryGold : null,
                ),
              ),
            ),
            Icon(
              imagePath != null ? Icons.check_circle_outline : Icons.camera_alt_outlined,
              color: imagePath != null ? AppColors.primaryGold : AppColors.lightGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
