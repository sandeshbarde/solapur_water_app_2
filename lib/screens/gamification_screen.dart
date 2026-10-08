import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/leaderboard_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';

/// Screen 10: Gamification & Civic Rewards
/// Job: "Track citizen water conservation points, community rank, and redeem civic rebates."
class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final accent = AppColors.accent(context);

    final List<Map<String, dynamic>> leaderboard = [
      {'rank': 1, 'name': 'Aditya R.', 'ward': 'Ward 02 (Budhwar Peth)', 'points': 1420},
      {'rank': 2, 'name': 'You (Citizen)', 'ward': 'Ward 04 (Navi Peth)', 'points': 1250, 'isMe': true},
      {'rank': 3, 'name': 'Sneha K.', 'ward': 'Ward 15 (Jule Solapur)', 'points': 1180},
      {'rank': 4, 'name': 'Rajesh M.', 'ward': 'Ward 07 (Bhavani Peth)', 'points': 960},
      {'rank': 5, 'name': 'Pooja V.', 'ward': 'Ward 12 (Ashok Chowk)', 'points': 890},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.waterRewards.toUpperCase()),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: ListView(
            children: [
              // 1. HERO AREA: Answer First - Points & Tier
              HeroFactCard(
                categoryTag: 'CIVIC CONSERVATION REWARDS',
                primaryFact: '1,250 JalPoints • Rank #2',
                supportingDetail: 'You saved approximately 4,200 Litres of drinking water this month through prompt leak reporting and responsible usage.',
                statusPill: const StatusPill(label: 'Tier: Gold Rakshak', type: StatusType.ok),
                icon: Icons.emoji_events_outlined,
              ),
              const SizedBox(height: AppSpacing.s16),

              // 2. CIVIC BADGES ROW
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border(context), width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBadge(context, Icons.verified_outlined, '4 Verified', 'Leak Reports'),
                    _buildBadge(context, Icons.bolt, '14 Day', 'Saving Streak'),
                    _buildBadge(context, Icons.eco_outlined, '840 EcoPts', 'Carbon Saved'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // 3. LEADERBOARD LIST
              SectionHeader(
                title: 'SOLAPUR CITIZEN LEADERBOARD',
                subtitle: 'Top water guardians across municipal wards',
              ),
              ...leaderboard.map(
                (u) => LeaderboardCard(
                  rank: u['rank'] as int,
                  name: u['name'] as String,
                  ward: u['ward'] as String,
                  points: u['points'] as int,
                  isCurrentUser: u['isMe'] == true,
                ),
              ),
              const SizedBox(height: AppSpacing.s28),

              // 4. MAX 1 PRIMARY ACTION: Redeem Tax Rebate
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          side: BorderSide(color: AppColors.border(context)),
                        ),
                        title: const Text('Redeem Solapur Water Tax Rebate'),
                        content: const Text(
                          'You have 1,250 JalPoints available. You can redeem 1,000 points for a ₹250 deduction on your upcoming Solapur Municipal Corporation water utility bill.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.statusOk(context),
                                  content: const Text('Rebate coupon applied to your SMC water bill!'),
                                ),
                              );
                            },
                            child: const Text('Apply Rebate'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.card_giftcard, size: 20),
                  label: const Text(
                    'REDEEM MUNICIPAL TAX REBATE',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String title, String subtitle) {
    final accent = AppColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
