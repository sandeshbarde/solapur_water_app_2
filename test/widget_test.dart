import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solapur_water_app/main.dart';
import 'package:solapur_water_app/core/theme/app_colors.dart';
import 'package:solapur_water_app/services/auth_service.dart';
import 'package:solapur_water_app/services/notification_service.dart';
import 'package:solapur_water_app/services/complaint_service.dart';
import 'package:solapur_water_app/services/sensor_stream_service.dart';
import 'package:solapur_water_app/services/device_service.dart';

void main() {
  test('AppColors light & dark palette definitions are valid', () {
    expect(AppColors.primary, const Color(0xFF0B6EB8));
    expect(AppColors.background, const Color(0xFFF4F8FC));
    expect(AppColors.bgDark, const Color(0xFF0B1623));
    expect(AppColors.cardDark, const Color(0xFF12263A));
    expect(AppColors.borderLight, const Color(0xFFE6EEF5));
    expect(AppColors.borderDark, const Color(0xFF1E3A55));
    expect(AppColors.textPrimaryLight, const Color(0xFF0F2A43));
    expect(AppColors.textPrimaryDark, const Color(0xFFE8F1FA));
  });

  test('AppRadius tokens & shapes are properly configured', () {
    expect(AppRadius.card, 20.0);
    expect(AppRadius.control, 12.0);
    expect(AppRadius.cardSmall, 12.0);
    expect(AppRadius.button, 14.0);
    expect(AppRadius.chip, 999.0);
  });

  test('AppSpacing 4-pt grid tokens are valid', () {
    expect(AppSpacing.s4, 4.0);
    expect(AppSpacing.s8, 8.0);
    expect(AppSpacing.s16, 16.0);
    expect(AppSpacing.cardPadding, 16.0);
    expect(AppSpacing.screenPadding, 20.0);
  });

  testWidgets('JalNirnayApp initializes and renders root widget tree', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => NotificationService()),
          ChangeNotifierProvider(create: (_) => ComplaintService()),
          Provider(create: (_) => SensorStreamService()),
          ChangeNotifierProvider(create: (_) => DeviceService()),
        ],
        child: const JalNirnayApp(),
      ),
    );

    // Initial pump to load MaterialApp and Splash / Login
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
