import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String actionDescription;
  final List<String> consequences;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.actionDescription,
    required this.consequences,
    this.confirmLabel = 'Confirm Action',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String actionDescription,
    required List<String> consequences,
    String confirmLabel = 'Confirm Action',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfirmActionDialog(
        title: title,
        actionDescription: actionDescription,
        consequences: consequences,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDestructive
        ? (isDark ? AppColors.statusCriticalDark : AppColors.statusCriticalLight)
        : (isDark ? AppColors.statusAttentionDark : AppColors.statusAttentionLight);

    return AlertDialog(
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: AppColors.border(context), width: 1.0),
      ),
      titlePadding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s20, AppSpacing.s20, AppSpacing.s12),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      actionsPadding: const EdgeInsets.all(AppSpacing.s16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: color.withOpacity(0.3), width: 1.0),
            ),
            child: Icon(
              isDestructive ? Icons.warning_amber_rounded : Icons.info_outline,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              actionDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            if (consequences.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s12),
              Text(
                'WHAT WILL HAPPEN:',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              ...consequences.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, AppSpacing.minTouchTarget),
          ),
          onPressed: onConfirm,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
