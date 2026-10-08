import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Refined for Aqua Civic: solid surfaces + hairline borders, no neon glow.
class HolographicPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? glowColor;

  const HolographicPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s16),
    this.borderRadius = AppRadius.card,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(context);
    final border = glowColor ?? AppColors.border(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: border,
          width: 1.0,
        ),
      ),
      child: child,
    );
  }
}
