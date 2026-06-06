import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final LinearGradient? gradient;
  final bool noPadding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.margin,
    this.gradient,
    this.noPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      padding: noPadding ? EdgeInsets.zero : (padding ?? const EdgeInsets.all(AppSpacing.md)),
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: gradient,
        color: isDark ? AppColors.glassDark : AppColors.glassWhite,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(26)
              : AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(50) : Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(30) : Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
          child: card,
        ),
      );
    }

    return card;
  }
}
