import 'package:flutter/material.dart';
import 'rainfall_monitoring_screen.dart';

/// Legacy alias forwarding to canonical Aqua Civic RainfallMonitoringScreen
class RainfallScreen extends StatelessWidget {
  const RainfallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RainfallMonitoringScreen();
  }
}
