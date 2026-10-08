import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'status_pill.dart';

/// Aqua Civic Hero Fact Card
/// Implements UX Rule 1: "Answer first: opens with its single most important fact"
class HeroFactCard extends StatelessWidget {
  final String categoryTag;
  final String primaryFact;
  final String supportingDetail;
  final String? lastUpdated;
  final StatusPill? statusPill;
  final IconData? icon;
  final Widget? actionButton;
  final VoidCallback? onTap;

  const HeroFactCard({
    super.key,
    required this.categoryTag,
    required this.primaryFact,
    required this.supportingDetail,
    this.lastUpdated,
    this.statusPill,
    this.icon,
    this.actionButton,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: border, width: 1.0),
        ),
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Category tag + Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: accent),
                      const SizedBox(width: AppSpacing.s8),
                    ],
                    Text(
                      categoryTag.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                if (statusPill != null) statusPill!,
              ],
            ),
            const SizedBox(height: AppSpacing.s12),

            // Answer First: Big Bold Fact
            Text(
              primaryFact,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s8),

            // Supporting Detail
            Text(
              supportingDetail,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            if (lastUpdated != null || actionButton != null) ...[
              const SizedBox(height: AppSpacing.s16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (lastUpdated != null)
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 13,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Text(
                          lastUpdated!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  if (actionButton != null) actionButton!,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
