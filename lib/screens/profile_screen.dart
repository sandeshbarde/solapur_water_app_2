import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/complaint_service.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/confirm_action_dialog.dart';
import 'gamification_screen.dart';
import 'housing_detail_screen.dart';
import 'hotel_detail_screen.dart';
import 'industry_detail_screen.dart';
import 'my_complaints_screen.dart';

/// Screen: Comprehensive Civic Profile & Utility Management
/// Includes verified user details, Housing / Hotel / Industry management, civic achievements, theme & language switches.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final accent = AppColors.accent(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.me.toUpperCase()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech_outlined),
            tooltip: 'Civic Rewards',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GamificationScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. User Header Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user?.name ?? 'Solapur Citizen',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: AppColors.primary, size: 18),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${user?.phone ?? "+91 9890123456"}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ward: Ward 4 (Bhavani Peth) • Consumer #SLP-8842',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 2. Property Portals (Housing, Hotel, Industry)
                Text(
                  'Connected Property Portals',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: AppSpacing.s12),

                _buildPropertyCard(
                  context,
                  title: 'Housing Society / Building',
                  subtitle: '48 Flats • Siddheshwar CHS • Meter Active',
                  icon: Icons.apartment_outlined,
                  tag: 'RESIDENTIAL',
                  tagColor: AppColors.normal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HousingDetailScreen()),
                  ),
                ),
                const SizedBox(height: 10),

                _buildPropertyCard(
                  context,
                  title: 'Hotel & Commercial Facility',
                  subtitle: 'Balaji Grand Residency • 36 Rooms • Tanker Standby',
                  icon: Icons.hotel_outlined,
                  tag: 'COMMERCIAL',
                  tagColor: AppColors.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HotelDetailScreen()),
                  ),
                ),
                const SizedBox(height: 10),

                _buildPropertyCard(
                  context,
                  title: 'Industrial Manufacturing Unit',
                  subtitle: 'Solapur Textile Processors • ETP Active (ZLD)',
                  icon: Icons.factory_outlined,
                  tag: 'INDUSTRIAL',
                  tagColor: AppColors.info,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IndustryDetailScreen()),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 3. Quick Actions (Complaints, Rewards)
                Text(
                  'Civic Services',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: AppSpacing.s12),

                _buildActionTile(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'My Complaints & Tickets',
                  subtitle: 'Track live status, engineer notes & resolution history',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyComplaintsScreen()),
                  ),
                ),
                const SizedBox(height: 8),

                _buildActionTile(
                  context,
                  icon: Icons.card_giftcard_outlined,
                  title: 'Civic Rewards & Tax Vouchers',
                  subtitle: '${user?.jalPoints ?? 120} Points • Level 2 Guardian',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GamificationScreen()),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 4. Preferences & Settings
                Text(
                  'Preferences',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: AppSpacing.s12),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(themeProvider.isDarkMode ? 'Dark theme active' : 'Light theme active'),
                        secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          localeProvider.locale.languageCode == 'mr'
                              ? 'मराठी (Marathi)'
                              : localeProvider.locale.languageCode == 'hi'
                                  ? 'हिंदी (Hindi)'
                                  : 'English',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLanguageDialog(context, localeProvider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // 5. Logout Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusCritical(context),
                    side: BorderSide(color: AppColors.statusCritical(context)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final confirmed = await ConfirmActionDialog.show(
                      context,
                      title: 'Logout from JalNirnay',
                      actionDescription: 'Are you sure you want to end your current session?',
                      consequences: const ['You will need to sign in again to access your account.'],
                      confirmLabel: 'Logout',
                      cancelLabel: 'Cancel',
                    );
                    if (confirmed == true && context.mounted) {
                      await authService.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('LOGOUT FROM ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: AppSpacing.s20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String tag,
    required Color tagColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tagColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Application Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('मराठी (Marathi)'),
              trailing: provider.locale.languageCode == 'mr' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                provider.setLocale(const Locale('mr'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('हिंदी (Hindi)'),
              trailing: provider.locale.languageCode == 'hi' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                provider.setLocale(const Locale('hi'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: provider.locale.languageCode == 'en' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                provider.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
