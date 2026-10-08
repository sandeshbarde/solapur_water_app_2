import 'package:flutter/material.dart';

// Re-export spacing, radius, and shadows so screens and components have full theme access
export 'app_spacing.dart';
export 'app_radius.dart';
export 'app_shadows.dart';

class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0B6EB8);
  static const Color primaryDark = Color(0xFF0A4F8F);
  static const Color teal = Color(0xFF19B5C9);

  // ── Accent ───────────────────────────────────────────────────────────────
  static const Color accentLight = Color(0xFF0B6EB8);
  static const Color accentDark  = Color(0xFF4DA6FF);

  // ── Surfaces & Backgrounds ───────────────────────────────────────────────
  static const Color background       = Color(0xFFF4F8FC);
  static const Color card             = Color(0xFFFFFFFF);
  static const Color cardLight        = Color(0xFFFFFFFF);
  static const Color cardDark         = Color(0xFF12263A);
  static const Color bgDark           = Color(0xFF0B1623);
  static const Color surfaceDark      = Color(0xFF12263A);
  static const Color surfaceLight     = Color(0xFFFFFFFF);

  // Surface 2 / Surface Variants
  static const Color surface2Light    = Color(0xFFE9F2FA);
  static const Color surface2Dark     = Color(0xFF18334E);
  static const Color surfaceVariantLight = Color(0xFFECF3FA);
  static const Color surfaceVariantDark  = Color(0xFF1A2332);

  // Borders
  static const Color borderLight      = Color(0xFFE6EEF5);
  static const Color borderDark       = Color(0xFF1E3A55);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color text               = Color(0xFF0F2A43);
  static const Color textPrimaryLight   = Color(0xFF0F2A43);
  static const Color textPrimaryDark    = Color(0xFFE8F1FA);
  static const Color textSecondaryLight = Color(0xFF6B7C8F);
  static const Color textSecondaryDark  = Color(0xFF8FA6BC);
  static const Color textMutedLight     = Color(0xFF9BAAB8);
  static const Color textMutedDark      = Color(0xFF6B7C8F);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color normal   = Color(0xFF22A861);
  static const Color warning  = Color(0xFFF5A623);
  static const Color critical = Color(0xFFE5484D);
  static const Color info     = Color(0xFF2F80ED);

  static const Color statusOkLight        = Color(0xFF22A861);
  static const Color statusOkDark         = Color(0xFF34D399);
  static const Color statusAttentionLight = Color(0xFFF5A623);
  static const Color statusAttentionDark  = Color(0xFFFBBF24);
  static const Color statusCriticalLight  = Color(0xFFE5484D);
  static const Color statusCriticalDark   = Color(0xFFF87171);
  static const Color statusInfoLight      = Color(0xFF2F80ED);
  static const Color statusInfoDark       = Color(0xFF60A5FA);

  // Status Containers (Chips, Pills, Badges)
  static const Color statusOkContainerLight        = Color(0xFFE8F7EE);
  static const Color statusOkContainerDark         = Color(0xFF123B2A);
  static const Color statusAttentionContainerLight = Color(0xFFFEF5E7);
  static const Color statusAttentionContainerDark  = Color(0xFF3E2F13);
  static const Color statusCriticalContainerLight  = Color(0xFFFDECEE);
  static const Color statusCriticalContainerDark   = Color(0xFF42171A);
  static const Color statusInfoContainerLight      = Color(0xFFEAF2FD);
  static const Color statusInfoContainerDark       = Color(0xFF132B47);

  // ── Tinted helpers (Alpha / Opacity based) ────────────────────────────────
  static Color get tintedNormal   => normal.withValues(alpha: 0.12);
  static Color get tintedWarning  => warning.withValues(alpha: 0.12);
  static Color get tintedCritical => critical.withValues(alpha: 0.12);
  static Color get tintedInfo     => info.withValues(alpha: 0.12);
  static Color get tintedPrimary  => primary.withValues(alpha: 0.12);

  static Color primaryTint(bool isDark) {
    return isDark
        ? primary.withValues(alpha: 0.15)
        : primary.withValues(alpha: 0.08);
  }

  static Color normalTint(bool isDark) {
    return isDark
        ? normal.withValues(alpha: 0.18)
        : normal.withValues(alpha: 0.10);
  }

  static Color warningTint(bool isDark) {
    return isDark
        ? warning.withValues(alpha: 0.20)
        : warning.withValues(alpha: 0.10);
  }

  static Color criticalTint(bool isDark) {
    return isDark
        ? critical.withValues(alpha: 0.20)
        : critical.withValues(alpha: 0.10);
  }

  static Color infoTint(bool isDark) {
    return isDark
        ? info.withValues(alpha: 0.18)
        : info.withValues(alpha: 0.10);
  }

  // ── Context-aware helpers ────────────────────────────────────────────────

  static Color accent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? accentDark
        : accentLight;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : card;
  }

  static Color surface2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surface2Dark
        : surface2Light;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : borderLight;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }

  static Color textMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textMutedDark
        : textMutedLight;
  }

  static Color statusOk(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? statusOkDark
        : statusOkLight;
  }

  static Color statusAttention(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? statusAttentionDark
        : statusAttentionLight;
  }

  static Color statusCritical(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? statusCriticalDark
        : statusCriticalLight;
  }

  static Color statusOkContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? statusOkContainerDark
        : statusOkContainerLight;
  }

  static Color statusAttentionContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? statusAttentionContainerDark
        : statusAttentionContainerLight;
  }

  static Color statusCriticalContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? statusCriticalContainerDark
        : statusCriticalContainerLight;
  }

  static Color statusInfo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? statusInfoDark
        : statusInfoLight;
  }

  static Color statusInfoContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? statusInfoContainerDark
        : statusInfoContainerLight;
  }
}
