import 'package:flutter/material.dart';
import 'ai_governance_dashboard.dart';

/// Legacy alias forwarding to canonical Aqua Civic AIGovernanceDashboard
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIGovernanceDashboard();
  }
}
