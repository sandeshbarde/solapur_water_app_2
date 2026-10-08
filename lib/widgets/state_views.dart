import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Loading skeleton placeholder for screens
class AppLoadingSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const AppLoadingSkeleton({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = AppRadius.card,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF16233B) : const Color(0xFFE2E8F0);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return RepaintBoundary(
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1.0),
        ),
      ),
    );
  }
}

/// Empty state view
class AppEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withOpacity(isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.25), width: 1.0),
              ),
              child: Icon(icon, size: 30, color: accent),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.s20),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state view with actionable retry
class AppErrorView extends StatelessWidget {
  final String title;
  final String errorMessage;
  final VoidCallback onRetry;
  final String retryLabel;

  const AppErrorView({
    super.key,
    this.title = 'Unable to Load Data',
    required this.errorMessage,
    required this.onRetry,
    this.retryLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.statusCriticalDark : AppColors.statusCriticalLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: errorColor.withOpacity(isDark ? 0.18 : 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: errorColor.withOpacity(0.3), width: 1.0),
              ),
              child: Icon(Icons.error_outline, size: 30, color: errorColor),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offline / Stale data indicator banner
class AppOfflineBanner extends StatelessWidget {
  final String? lastUpdatedText;
  final VoidCallback? onRefresh;

  const AppOfflineBanner({
    super.key,
    this.lastUpdatedText,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final warnColor = isDark ? AppColors.statusAttentionDark : AppColors.statusAttentionLight;
    final warnBg = isDark ? AppColors.statusAttentionContainerDark : AppColors.statusAttentionContainerLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: warnBg,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: warnColor.withOpacity(0.3), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: warnColor),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              lastUpdatedText != null
                  ? 'Offline • Showing cached data from $lastUpdatedText'
                  : 'Offline mode • Showing cached municipal data',
              style: theme.textTheme.bodySmall?.copyWith(
                color: warnColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: Icon(Icons.refresh, size: 16, color: warnColor),
              onPressed: onRefresh,
              tooltip: 'Check connection',
            ),
        ],
      ),
    );
  }
}
