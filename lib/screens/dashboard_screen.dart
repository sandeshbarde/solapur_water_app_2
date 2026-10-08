import 'package:flutter/material.dart';
import 'citizen_dashboard.dart';

/// Legacy alias forwarding to canonical Aqua Civic CitizenDashboard
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CitizenDashboard();
  }
}
