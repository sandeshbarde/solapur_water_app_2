import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/sensor_stream_service.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/status_pill.dart';
import '../widgets/data_stat_card.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/state_views.dart';

/// Screen 1: Citizen Home Dashboard
/// Job: "Is water coming today, when, and is something wrong?"
class CitizenDashboard extends StatelessWidget {
  const CitizenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;
    final isAdmin = auth.isAdmin;
    final notifications = Provider.of<NotificationService>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOLAPUR MUNICIPAL CORPORATION',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.accent(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              user?.name != null ? 'Namaste, ${user!.name}' : 'JalNirnay AI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Notifications, ${notifications.unreadCount} unread',
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: l10n.notifications,
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                ),
                if (notifications.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.statusCriticalDark,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        notifications.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: StreamBuilder<Map<String, dynamic>>(
            stream: Provider.of<SensorStreamService>(context, listen: false).sensorStream,
            builder: (context, snapshot) {
              final sensorData = snapshot.data ?? {'pressure': 42.0, 'tankLevel': 84.0};
              final pressure = (sensorData['pressure'] as num?)?.toDouble() ?? 42.0;
              final tankLevel = (sensorData['tankLevel'] as num?)?.toDouble() ?? 84.0;
              final isSupplyNormal = pressure >= 35.0;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // 1. HERO AREA: Answer First - Is water coming today & when?
                  HeroFactCard(
                    categoryTag: 'TODAY\'S SUPPLY • WARD ${user?.wardNumber ?? 4}',
                    primaryFact: isSupplyNormal
                        ? 'Water Supply: 4:30 PM - 7:00 PM'
                        : 'Delayed: Low Pressure in Sector 3',
                    supportingDetail: isSupplyNormal
                        ? 'Next delivery starts in 2h 45m. Water pressure is optimal across your ward line.'
                        : 'Municipal engineering team is addressing pipeline pressure drop. Tankers on standby.',
                    lastUpdated: 'Live sync 2m ago',
                    statusPill: StatusPill(
                      label: isSupplyNormal ? l10n.statusOk : l10n.statusAttention,
                      type: isSupplyNormal ? StatusType.ok : StatusType.attention,
                    ),
                    icon: Icons.water_drop,
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // 2. SUPPORTING DETAIL: High-Contrast Civic Stats Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isWide ? 4 : 2,
                        childAspectRatio: isWide ? 1.5 : 1.25,
                        crossAxisSpacing: AppSpacing.s12,
                        mainAxisSpacing: AppSpacing.s12,
                        children: [
                          DataStatCard(
                            title: l10n.pressureStatus,
                            value: '${pressure.toStringAsFixed(1)} PSI',
                            icon: Icons.speed,
                            color: isSupplyNormal ? AppColors.statusOk(context) : AppColors.statusAttention(context),
                            subtitle: isSupplyNormal ? 'Optimal' : 'Low',
                          ),
                          DataStatCard(
                            title: l10n.tankLevel,
                            value: '${tankLevel.toInt()}%',
                            icon: Icons.opacity,
                            color: AppColors.accent(context),
                            subtitle: 'Reservoir Stable',
                          ),
                          DataStatCard(
                            title: l10n.jalPoints,
                            value: user?.jalPoints.toString() ?? '1,250',
                            icon: Icons.verified,
                            color: AppColors.accent(context),
                            subtitle: 'Tier: Rakshak',
                          ),
                          DataStatCard(
                            title: l10n.ecoPoints,
                            value: user?.ecoPoints.toString() ?? '840',
                            icon: Icons.eco,
                            color: AppColors.statusOk(context),
                            subtitle: '+5% this week',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // 3. MUNICIPALITY UPDATES
                  SectionHeader(
                    title: l10n.municipalityUpdates,
                    subtitle: 'Solapur water authority notifications',
                    trailing: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/notifications'),
                      child: Text(l10n.viewAll),
                    ),
                  ),
                  if (notifications.notifications.isNotEmpty)
                    ...notifications.notifications.reversed.take(1).map((n) => Container(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                          decoration: BoxDecoration(
                            color: AppColors.surface(context),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: AppColors.border(context), width: 1.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent(context).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.control),
                                ),
                                child: Icon(Icons.campaign_outlined, color: AppColors.accent(context), size: 20),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.body,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border(context), width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.accent(context), size: 20),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Text(
                              'Regular water distribution underway across all sectors of Ward ${user?.wardNumber ?? 4}.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppSpacing.s16),

                  // 4. SECONDARY ACTIONS: Quick Action Tiles
                  SectionHeader(
                    title: l10n.quickActions,
                  ),
                  QuickActionTile(
                    title: l10n.reportViaWhatsApp,
                    subtitle: 'Chat directly with Solapur Water Bot 24x7',
                    icon: Icons.chat_outlined,
                    iconColor: AppColors.statusOk(context),
                    onTap: () async {
                      final url = Uri.parse(
                          "https://wa.me/919322242762?text=${Uri.encodeComponent('Hi JalNirnay AI, I need assistance with Solapur water supply.')}");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  QuickActionTile(
                    title: l10n.rainfallForecast,
                    subtitle: 'Ujani Dam levels & monsoon prediction',
                    icon: Icons.umbrella_outlined,
                    iconColor: AppColors.accent(context),
                    onTap: () => Navigator.pushNamed(context, '/rainfall'),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  QuickActionTile(
                    title: l10n.waterRewards,
                    subtitle: 'Track saved water & redeem civic rebates',
                    icon: Icons.emoji_events_outlined,
                    iconColor: AppColors.statusAttention(context),
                    onTap: () => Navigator.pushNamed(context, '/gamification'),
                  ),

                  // Admin Shortcut if logged in as municipal admin
                  if (isAdmin) ...[
                    const SizedBox(height: AppSpacing.s20),
                    SectionHeader(title: 'ADMIN OPERATIONAL SHORTCUTS'),
                    QuickActionTile(
                      title: 'Pressure / Valve Control',
                      subtitle: 'Regulate sector pressure and pump schedule',
                      icon: Icons.tune,
                      onTap: () => Navigator.pushNamed(context, '/pressure_control'),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    QuickActionTile(
                      title: 'Digital Twin Simulation',
                      subtitle: 'Hydraulic simulation & demand modeling',
                      icon: Icons.model_training,
                      onTap: () => Navigator.pushNamed(context, '/simulation'),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.s28),

                  // 5. MAX 1 PRIMARY ACTION: Thumb-Zone Main CTA (Report Water Issue)
                  Semantics(
                    button: true,
                    label: l10n.reportIssue,
                    child: SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent(context),
                          foregroundColor: isDark ? AppColors.bgDark : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.control),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/report_issue'),
                        icon: const Icon(Icons.report_problem_outlined, size: 20),
                        label: Text(
                          l10n.reportIssue.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
