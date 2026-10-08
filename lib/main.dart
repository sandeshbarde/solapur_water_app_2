import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/complaint_service.dart';
import 'services/sensor_stream_service.dart';
import 'services/device_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/citizen_dashboard.dart';
import 'screens/smart_water_map.dart';
import 'screens/sensor_monitoring.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/issue_reporting_screen.dart';
import 'screens/rainfall_monitoring_screen.dart';
import 'screens/ai_governance_dashboard.dart';
import 'screens/pressure_control_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/digital_twin_simulation.dart';
import 'screens/gamification_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_ai_control_screen.dart';
import 'screens/iot_device_manager_screen.dart';
import 'screens/water_supply_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/profile_screen.dart';

// Import generated localizations once flutter gen-l10n is run
// In this case, we'll continue using a manually bridge for the provided .arb content
// for the user to be able to run it immediately without gen-l10n if needed,
// but we'll set it up correctly.
import 'l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
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
}

class JalNirnayApp extends StatelessWidget {
  const JalNirnayApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    var localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'JalNirnay AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainNavigator(),
        '/report_issue': (context) => const IssueReportingScreen(),
        '/rainfall': (context) => const RainfallMonitoringScreen(),
        '/ai_governance': (context) => const AIGovernanceDashboard(),
        '/pressure_control': (context) => const PressureControlScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/simulation': (context) => const DigitalTwinSimulation(),
        '/gamification': (context) => const GamificationScreen(),
        '/admin_ai_control': (context) => const AdminAIControlScreen(),
        '/iot_devices': (context) => const IoTDeviceManagerScreen(),
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode');
    if (index != null) {
      _themeMode = ThemeMode.values[index];
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('locale_lang');
    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale loc) async {
    _locale = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_lang', loc.languageCode);
    notifyListeners();
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context);
    final isAdmin = authService.isAdmin;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> citizenTabs = const [
      CitizenDashboard(),
      SmartWaterMap(),
      WaterSupplyScreen(),
      AlertsScreen(),
      ProfileScreen(),
    ];

    final List<Widget> adminTabs = const [
      AIGovernanceDashboard(),
      SmartWaterMap(),
      SensorMonitoringScreen(),
      AdminAIControlScreen(),
      SettingsScreen(),
    ];

    final List<Widget> currentTabs = isAdmin ? adminTabs : citizenTabs;

    final navDestinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: isAdmin ? 'Hub' : l10n.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.map_outlined),
        selectedIcon: const Icon(Icons.map),
        label: l10n.smartMap,
      ),
      NavigationDestination(
        icon: isAdmin ? const Icon(Icons.sensors_outlined) : const Icon(Icons.water_drop_outlined),
        selectedIcon: isAdmin ? const Icon(Icons.sensors) : const Icon(Icons.water_drop),
        label: isAdmin ? l10n.sensors : l10n.water,
      ),
      NavigationDestination(
        icon: isAdmin ? const Icon(Icons.tune_outlined) : const Icon(Icons.notifications_outlined),
        selectedIcon: isAdmin ? const Icon(Icons.tune) : const Icon(Icons.notifications),
        label: isAdmin ? 'Control' : l10n.alerts,
      ),
      NavigationDestination(
        icon: isAdmin ? const Icon(Icons.settings_outlined) : const Icon(Icons.person_outline),
        selectedIcon: isAdmin ? const Icon(Icons.settings) : const Icon(Icons.person),
        label: isAdmin ? l10n.settings : l10n.me,
      ),
    ];

    final railDestinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: Text(isAdmin ? 'Hub' : l10n.home),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.map_outlined),
        selectedIcon: const Icon(Icons.map),
        label: Text(l10n.smartMap),
      ),
      NavigationRailDestination(
        icon: isAdmin ? const Icon(Icons.sensors_outlined) : const Icon(Icons.water_drop_outlined),
        selectedIcon: isAdmin ? const Icon(Icons.sensors) : const Icon(Icons.water_drop),
        label: Text(isAdmin ? l10n.sensors : l10n.water),
      ),
      NavigationRailDestination(
        icon: isAdmin ? const Icon(Icons.tune_outlined) : const Icon(Icons.notifications_outlined),
        selectedIcon: isAdmin ? const Icon(Icons.tune) : const Icon(Icons.notifications),
        label: Text(isAdmin ? 'Control' : l10n.alerts),
      ),
      NavigationRailDestination(
        icon: isAdmin ? const Icon(Icons.settings_outlined) : const Icon(Icons.person_outline),
        selectedIcon: isAdmin ? const Icon(Icons.settings) : const Icon(Icons.person),
        label: Text(isAdmin ? l10n.settings : l10n.me),
      ),
    ];

    DateTime? lastBackPressTime;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // If on non-home tab, pop back to home tab (index 0)
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }

        // On Home tab: double press to exit
        final now = DateTime.now();
        if (lastBackPressTime == null || now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
          lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit JalNirnay'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Allow app to exit
          Navigator.of(context).pop();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;
          final isMedium = constraints.maxWidth >= 600 && constraints.maxWidth < 1100;
          final isExpanded = constraints.maxWidth >= 1100;

          if (isCompact) {
            return Scaffold(
              body: IndexedStack(
                index: _selectedIndex,
                children: currentTabs,
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.0,
                    ),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  destinations: navDestinations,
                ),
              ),
            );
          }

          return Scaffold(
            body: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                    extended: isExpanded,
                    minWidth: 72,
                    minExtendedWidth: 220,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent(context).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.accent(context).withValues(alpha: 0.3)),
                            ),
                            child: Icon(Icons.water_drop, color: AppColors.accent(context), size: 22),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'JalNirnay AI',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  isAdmin ? 'Solapur Admin' : 'Solapur Citizen',
                                  style: theme.textTheme.labelSmall?.copyWith(color: AppColors.accent(context)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    destinations: railDestinations,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMedium ? 760 : 1240,
                      ),
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: currentTabs,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
