import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GlowingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final bool isFullWidth;

  const GlowingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final btnColor = color ?? AppColors.accent(context);

    final child = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: (color != null && color != AppColors.accent(context))
            ? Colors.white
            : (isDark ? AppColors.bgDark : Colors.white),
        elevation: 0,
        minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          side: BorderSide(color: btnColor.withOpacity(0.3), width: 1.0),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.s8),
          ],
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }
}
