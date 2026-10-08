import 'package:flutter/material.dart';

class AppRadius {
  // ── Raw values ────────────────────────────────────────────────────────────
  static const double cards     = 20.0;
  static const double cardSmall = 12.0;
  static const double buttons   = 14.0;
  static const double button    = 14.0;
  static const double chip      = 999.0;
  static const double pill      = 999.0;
  static const double sheets    = 24.0;
  static const double controls  = 12.0;

  // ── Semantic aliases used across screens & components ────────────────────
  static const double card    = cards;
  static const double control = controls;

  // ── BorderRadius helpers ──────────────────────────────────────────────────
  static final BorderRadius cardRadius      = BorderRadius.circular(cards);
  static final BorderRadius cardSmallRadius = BorderRadius.circular(cardSmall);
  static final BorderRadius buttonRadius    = BorderRadius.circular(buttons);
  static final BorderRadius chipRadius      = BorderRadius.circular(chip);
  static final BorderRadius pillRadius      = BorderRadius.circular(pill);
  static final BorderRadius controlRadius   = BorderRadius.circular(controls);

  /// ShapeBorder for BottomSheetThemeData
  static const RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(sheets)),
  );

  static const BorderRadius sheetRadius =
      BorderRadius.vertical(top: Radius.circular(sheets));
}
