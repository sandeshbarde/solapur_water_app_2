import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/hero_fact_card.dart';
import '../widgets/status_pill.dart';
import '../widgets/data_stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/confirm_action_dialog.dart';

/// Screen 11: Hydraulic Digital Twin Simulation
/// Job: "Hydraulic simulation of Solapur water grid for scenario modeling (demand spikes, pipe breaks)."
class DigitalTwinSimulation extends StatefulWidget {
  const DigitalTwinSimulation({super.key});

  @override
  State<DigitalTwinSimulation> createState() => _DigitalTwinSimulationState();
}

class _DigitalTwinSimulationState extends State<DigitalTwinSimulation> {
  bool _isSimulating = false;
  String _activeSimulation = 'None';
  double _globalPressure = 45.0;

  void _runSimulation(String type) async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: 'Run Digital Twin: $type',
      actionDescription: 'You are launching a hydraulic simulation scenario on the digital twin of Solapur pipeline network.',
      consequences: [
        'Simulated stress will model pressure waves across all sectors.',
        'No physical hardware valves will be actuated.',
        'Engineering diagnostic results will be generated.',
      ],
      confirmLabel: 'Run Simulation',
      cancelLabel: 'Cancel',
      isDestructive: false,
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isSimulating = true;
      _activeSimulation = type;
    });

    if (type == 'STRESS TEST') {
      for (int i = 0; i < 4; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) setState(() => _globalPressure += 8);
      }
    } else if (type == 'MOCK BURST') {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _globalPressure = 12.0);
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _isSimulating = false;
        _activeSimulation = 'Complete';
        _globalPressure = 45.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusOk(context),
          content: Text('$type simulation finished. Hydraulic network integrity verified.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('HYDRAULIC DIGITAL TWIN'),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: ListView(
            children: [
              // 1. HERO AREA: Active simulation fact
              HeroFactCard(
                categoryTag: 'SOLAPUR NETWORK TWIN MODEL',
                primaryFact: _isSimulating ? 'Simulation Running: $_activeSimulation' : 'Hydraulic Twin: Ready',
                supportingDetail: _isSimulating
                    ? 'Processing dynamic nodal pressure flows across 14 municipal sectors...'
                    : 'Simulate flow changes, pipe bursts, and peak summer demand to test grid resilience.',
                statusPill: StatusPill(
                  label: _isSimulating ? 'Simulating' : 'Calibrated',
                  type: _isSimulating ? StatusType.attention : StatusType.ok,
                ),
                icon: Icons.model_training,
              ),
              const SizedBox(height: AppSpacing.s16),

              // 2. SIMULATION TELEMETRY
              Row(
                children: [
                  Expanded(
                    child: DataStatCard(
                      title: 'Grid Load',
                      value: '84%',
                      icon: Icons.speed,
                      color: accent,
                      subtitle: 'Hydraulic Demand',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: DataStatCard(
                      title: 'Sim Pressure',
                      value: '${_globalPressure.toInt()} PSI',
                      icon: Icons.compress,
                      color: _globalPressure > 65
                          ? AppColors.statusCritical(context)
                          : (_globalPressure < 20 ? AppColors.statusAttention(context) : AppColors.statusOk(context)),
                      subtitle: 'Tolerance: 30-55',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              // 3. SCENARIO TRIGGERS
              SectionHeader(
                title: 'PRE-CONFIGURED SIMULATION SCENARIOS',
                subtitle: 'Select a scenario to evaluate Solapur water grid response',
              ),
              _buildScenarioCard(
                context,
                title: 'High Pressure Stress Test',
                desc: 'Simulate high pumping head (+30 PSI) to verify joint integrity in Ward 4.',
                type: 'STRESS TEST',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: AppSpacing.s12),
              _buildScenarioCard(
                context,
                title: 'Simulate Main Feeder Burst',
                desc: 'Evaluate automatic shutoff valve reaction time upon rapid pressure drop.',
                type: 'MOCK BURST',
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: AppSpacing.s12),
              _buildScenarioCard(
                context,
                title: 'Peak Morning Demand Surge',
                desc: 'Model 300% simultaneous citizen tap draw between 6:00 AM - 8:00 AM.',
                type: 'PEAK SURGE',
                icon: Icons.people_outline,
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String type,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final accent = AppColors.accent(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border(context), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(desc, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isSimulating ? null : () => _runSimulation(type),
              child: Text('RUN $type'),
            ),
          ),
        ],
      ),
    );
  }
}
