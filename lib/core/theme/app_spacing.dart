import 'package:flutter/material.dart';

class AppSpacing {
  // ── 4-pt grid numeric tokens ─────────────────────────────────────────────
  static const double s2  = 2.0;
  static const double s4  = 4.0;
  static const double s8  = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // ── Semantic aliases ─────────────────────────────────────────────────────
  static const double xxs = s2;
  static const double xs  = s4;
  static const double sm  = s8;
  static const double md  = s12;
  static const double lg  = s16;
  static const double xl  = s20;
  static const double xxl = s24;
  static const double xxxl = s32;

  // Layout-specific spacing
  static const double screenPadding  = s20;
  static const double cardPadding    = s16;
  static const double minTouchTarget = 48.0;

  // ── EdgeInsets helpers ───────────────────────────────────────────────────
  static const EdgeInsets edgeInsetsScreen = EdgeInsets.all(screenPadding);
  static const EdgeInsets edgeInsetsCard   = EdgeInsets.all(cardPadding);
  static const EdgeInsets edgeInsetsXs     = EdgeInsets.all(xs);
  static const EdgeInsets edgeInsetsSm     = EdgeInsets.all(sm);
  static const EdgeInsets edgeInsetsMd     = EdgeInsets.all(md);
  static const EdgeInsets edgeInsetsLg     = EdgeInsets.all(lg);
}
