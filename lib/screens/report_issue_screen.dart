import 'package:flutter/material.dart';
import 'issue_reporting_screen.dart';

/// Legacy alias forwarding to canonical Aqua Civic IssueReportingScreen
class ReportIssueScreen extends StatelessWidget {
  const ReportIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const IssueReportingScreen();
  }
}
