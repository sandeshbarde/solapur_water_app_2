import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import '../widgets/responsive_layout.dart';

/// Screen: Citizen Complaint Status & History
class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final complaintService = Provider.of<ComplaintService>(context);
    final complaints = complaintService.complaints;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('MY COMPLAINTS & TICKETS'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: complaintService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : complaints.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.statusOk(context)),
                          const SizedBox(height: 16),
                          const Text('No Active Complaints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(
                            'You have not filed any water issues recently.',
                            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => complaintService.fetchComplaints(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        itemCount: complaints.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = complaints[index];
                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: AppColors.border(context)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '#${c.id}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                    ),
                                    _buildStatusBadge(context, c.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.category,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary(context)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        c.address,
                                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (c.officerNote != null && c.officerNote!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surface2Dark : const Color(0xFFF0F6FC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFD0E2F5)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.engineering, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Officer Note: ${c.officerNote}',
                                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ComplaintStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case ComplaintStatus.inProgress:
        bg = AppColors.statusAttentionContainer(context);
        fg = AppColors.statusAttention(context);
        label = 'IN PROGRESS';
        break;
      case ComplaintStatus.resolved:
        bg = AppColors.statusOkContainer(context);
        fg = AppColors.statusOk(context);
        label = 'RESOLVED';
        break;
      case ComplaintStatus.rejected:
        bg = AppColors.statusCriticalContainer(context);
        fg = AppColors.statusCritical(context);
        label = 'REJECTED';
        break;
      case ComplaintStatus.pending:
      default:
        bg = const Color(0xFFE8F2FA);
        fg = AppColors.primary;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
