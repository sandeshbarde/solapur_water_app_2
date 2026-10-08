import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum StatusType { ok, attention, critical, info }

/// Aqua Civic Status Pill
/// Strictly pairs color with an icon and text label for WCAG AA compliance.
class StatusPill extends StatelessWidget {
  final String label;
  final StatusType type;
  final IconData? customIcon;
  final bool isCompact;

  const StatusPill({
    super.key,
    required this.label,
    required this.type,
    this.customIcon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color fg;
    Color bg;
    Color border;
    IconData icon;

    switch (type) {
      case StatusType.ok:
        fg = isDark ? AppColors.statusOkDark : AppColors.statusOkLight;
        bg = isDark ? AppColors.statusOkContainerDark : AppColors.statusOkContainerLight;
        border = fg.withOpacity(0.35);
        icon = Icons.check_circle_outline;
        break;
      case StatusType.attention:
        fg = isDark ? AppColors.statusAttentionDark : AppColors.statusAttentionLight;
        bg = isDark ? AppColors.statusAttentionContainerDark : AppColors.statusAttentionContainerLight;
        border = fg.withOpacity(0.35);
        icon = Icons.warning_amber_rounded;
        break;
      case StatusType.critical:
        fg = isDark ? AppColors.statusCriticalDark : AppColors.statusCriticalLight;
        bg = isDark ? AppColors.statusCriticalContainerDark : AppColors.statusCriticalContainerLight;
        border = fg.withOpacity(0.35);
        icon = Icons.error_outline;
        break;
      case StatusType.info:
        fg = isDark ? AppColors.accentDark : AppColors.accentLight;
        bg = isDark ? const Color(0xFF0C2442) : const Color(0xFFE0F2FE);
        border = fg.withOpacity(0.35);
        icon = Icons.info_outline;
        break;
    }

    if (customIcon != null) {
      icon = customIcon!;
    }

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: border, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isCompact ? 13 : 15, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: isCompact ? 11 : 12,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
