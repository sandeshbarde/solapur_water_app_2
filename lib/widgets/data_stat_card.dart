import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class DataStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final Widget? trailing;
  final String? subtitle;

  const DataStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = color ?? AppColors.accent(context);
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);

    return Semantics(
      label: '$title: $value',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: border, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(isDark ? 0.15 : 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    border: Border.all(color: accent.withOpacity(0.25), width: 1.0),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.s4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
