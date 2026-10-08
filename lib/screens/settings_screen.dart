import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';

/// Screen 7: Profile & Settings
/// Job: "Manage language (English/Hindi/Marathi), high-contrast theme, notifications, offline cache, profile, and logout."
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;
    final isAdmin = auth.isAdmin;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settings.toUpperCase()),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: ListView(
            children: [
              // 1. HERO AREA: Profile Card with Role & Status
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border(context), width: 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(isDark ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
                      ),
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: accent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? (isAdmin ? 'Municipal Engineer' : 'Citizen'),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAdmin
                                ? 'Solapur Municipal Corporation • Admin ID: SOL-01'
                                : 'Ward ${user?.wardNumber ?? 4} • JalPoints: ${user?.jalPoints ?? 1250}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(
                      label: isAdmin ? 'Admin' : 'Verified',
                      type: StatusType.ok,
                      isCompact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // 2. LANGUAGE SETTINGS
              SectionHeader(
                title: l10n.language,
                subtitle: 'Choose your preferred language',
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border(context), width: 1.0),
                ),
                child: Column(
                  children: [
                    _buildLanguageTile(
                      context: context,
                      title: 'English',
                      sub: 'Default System Language',
                      code: 'en',
                      currentLocale: localeProvider.locale,
                      onSelect: () => localeProvider.setLocale(const Locale('en')),
                    ),
                    Divider(color: AppColors.border(context), height: 1),
                    _buildLanguageTile(
                      context: context,
                      title: 'हिंदी (Hindi)',
                      sub: 'राष्ट्रीय भाषा',
                      code: 'hi',
                      currentLocale: localeProvider.locale,
                      onSelect: () => localeProvider.setLocale(const Locale('hi')),
                    ),
                    Divider(color: AppColors.border(context), height: 1),
                    _buildLanguageTile(
                      context: context,
                      title: 'मराठी (Marathi)',
                      sub: 'स्थानिक सोलापूर भाषा',
                      code: 'mr',
                      currentLocale: localeProvider.locale,
                      onSelect: () => localeProvider.setLocale(const Locale('mr')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // 3. APPEARANCE & DISPLAY
              SectionHeader(
                title: 'APPEARANCE & THEME',
                subtitle: 'High contrast Aqua Civic design system',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border(context), width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                          color: accent,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.themeMode,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isDark ? 'Navy dark surface mode' : 'Blue-tinted light surface mode',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: isDark,
                      activeColor: accent,
                      onChanged: (val) => themeProvider.toggleTheme(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // 4. CIVIC HELPLINE & INFORMATION
              SectionHeader(
                title: 'MUNICIPAL INFORMATION',
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border(context), width: 1.0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.apartment_outlined, size: 20, color: accent),
                        const SizedBox(width: AppSpacing.s12),
                        const Expanded(
                          child: Text('Solapur Municipal Corporation (SMC)'),
                        ),
                        const Text('Peth Ward', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Row(
                      children: [
                        Icon(Icons.headset_mic_outlined, size: 20, color: accent),
                        const SizedBox(width: AppSpacing.s12),
                        const Expanded(
                          child: Text('Water Supply Helpline'),
                        ),
                        const Text('1800-233-1555', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Row(
                      children: [
                        Icon(Icons.verified_outlined, size: 20, color: AppColors.statusOk(context)),
                        const SizedBox(width: AppSpacing.s12),
                        const Expanded(
                          child: Text('App Version'),
                        ),
                        const Text('v1.0.0 (Aqua Civic)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s28),

              // 5. DESTRUCTIVE ACTION: Log Out with In-App Confirmation
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusCritical(context),
                    side: BorderSide(color: AppColors.statusCritical(context).withOpacity(0.5)),
                  ),
                  onPressed: () async {
                    final confirmed = await ConfirmActionDialog.show(
                      context,
                      title: 'Log Out of JalNirnay AI',
                      actionDescription: 'You will need to sign in again to view your personalized ward schedule and submit verified water tickets.',
                      consequences: [
                        'Session will be cleared from this device.',
                        'Any unsubmitted complaints will be discarded.',
                      ],
                      confirmLabel: 'Log Out',
                      cancelLabel: 'Stay Signed In',
                      isDestructive: true,
                    );

                    if (confirmed == true && context.mounted) {
                      auth.logout();
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(l10n.logout.toUpperCase()),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String title,
    required String sub,
    required String code,
    required Locale currentLocale,
    required VoidCallback onSelect,
  }) {
    final isSelected = currentLocale.languageCode == code;
    final accent = AppColors.accent(context);

    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? accent : null,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: accent, size: 20)
            else
              Icon(Icons.radio_button_unchecked, color: AppColors.border(context), size: 20),
          ],
        ),
      ),
    );
  }
}
