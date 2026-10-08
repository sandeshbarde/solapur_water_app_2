import 'package:flutter/material.dart';

class AppShadows {
  static final List<BoxShadow> primary = [
    BoxShadow(
      color: const Color(0xFF0B6EB8).withValues(alpha: 0.08),
      offset: const Offset(0, 6),
      blurRadius: 20,
    ),
  ];

  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 10,
    ),
  ];

  static final List<BoxShadow> floating = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -2,
    ),
  ];

  static final List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      offset: const Offset(0, -4),
      blurRadius: 16,
    ),
  ];
}
