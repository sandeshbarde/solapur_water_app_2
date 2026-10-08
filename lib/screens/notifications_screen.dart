import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/section_header.dart';
import '../widgets/state_views.dart';
import '../widgets/status_pill.dart';

/// Screen 8: Citizen & Municipal Notifications
/// Job: "Review critical water supply alerts, scheduled cutoffs, and complaint updates."
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleBroadcast() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill both title and message body for broadcast.')),
      );
      return;
    }

    // UX Rule 6: Confirm broadcast action
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Confirm Municipal Broadcast',
      actionDescription: 'You are broadcasting an official push alert to all registered citizens of Solapur.',
      consequences: [
        'Alert will be published immediately to all citizen devices.',
        'Registered users will receive an in-app banner.',
        'This transmission will be logged in the municipal audit trail.',
      ],
      confirmLabel: 'Broadcast Alert',
      cancelLabel: 'Cancel',
      isDestructive: false,
    );

    if (confirmed == true && mounted) {
      final notifService = Provider.of<NotificationService>(context, listen: false);
      notifService.sendBroadcast(
        _titleController.text.trim(),
        _bodyController.text.trim(),
      );

      _titleController.clear();
      _bodyController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusOk(context),
          content: const Text('Broadcast notification dispatched to Solapur citizens!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);
    final isAdmin = authService.isAdmin;
    final notifService = Provider.of<NotificationService>(context);
    final notifications = notifService.notifications;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isAdmin ? 'MUNICIPAL BROADCAST' : l10n.notifications.toUpperCase()),
        actions: [
          if (notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () => notifService.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 16),
              label: const Text('Read All'),
            ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: ListView(
            children: [
              // 1. HERO AREA: Notification summary
              HeroFactCard(
                categoryTag: 'OFFICIAL MUNICIPAL NOTICES',
                primaryFact: notifications.isNotEmpty
                    ? '${notifications.length} Active Notice(s)'
                    : 'All Systems Normal',
                supportingDetail: notifications.isNotEmpty
                    ? 'Review latest updates on pipeline maintenance, supply timings, and repair progress.'
                    : 'No pending alerts for your ward. Water delivery operates on standard schedule.',
                statusPill: StatusPill(
                  label: notifications.isNotEmpty ? 'Active Alerts' : 'Clear',
                  type: notifications.isNotEmpty ? StatusType.info : StatusType.ok,
                ),
                icon: Icons.campaign_outlined,
              ),
              const SizedBox(height: AppSpacing.s20),

              // 2. ADMIN BROADCAST FORM
              if (isAdmin) ...[
                SectionHeader(
                  title: 'BROADCAST CIVIC ALERT',
                  subtitle: 'Dispatch announcements to citizen dashboards',
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
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Announcement Title',
                          hintText: 'e.g. Scheduled Pipe Maintenance in Ward 4',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      TextFormField(
                        controller: _bodyController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Message Body',
                          hintText: 'Details on affected timings, zones, or tanker alternatives...',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleBroadcast,
                          icon: const Icon(Icons.send, size: 18),
                          label: const Text('SEND BROADCAST ALERT'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
              ],

              // 3. NOTIFICATION LIST
              SectionHeader(
                title: 'RECENT NOTICES',
              ),
              if (notifications.isEmpty)
                const AppEmptyView(
                  icon: Icons.notifications_none,
                  title: 'No Notifications',
                  message: 'You have no unread water alerts or scheduled outage warnings.',
                )
              else
                ...notifications.reversed.map((n) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                    padding: const EdgeInsets.all(AppSpacing.s16),
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
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppRadius.control),
                          ),
                          child: Icon(Icons.campaign_outlined, color: accent, size: 22),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.body,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }
}
