import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class LeaderboardCard extends StatelessWidget {
  final int rank;
  final String name;
  final String ward;
  final int points;
  final bool isCurrentUser;

  const LeaderboardCard({
    super.key,
    required this.rank,
    required this.name,
    required this.ward,
    required this.points,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);
    final surface = isCurrentUser
        ? accent.withOpacity(isDark ? 0.18 : 0.08)
        : AppColors.surface(context);
    final border = isCurrentUser ? accent : AppColors.border(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: border, width: isCurrentUser ? 1.5 : 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank, context).withOpacity(0.16),
              shape: BoxShape.circle,
              border: Border.all(color: _getRankColor(rank, context), width: 1.0),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: _getRankColor(rank, context),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? accent : null,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('YOU', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(
                  ward,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$points pts',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank, BuildContext context) {
    if (rank == 1) return AppColors.statusAttention(context);
    if (rank == 2) return AppColors.accent(context);
    if (rank == 3) return Colors.brown.shade400;
    return AppColors.textSecondary(context);
  }
}
