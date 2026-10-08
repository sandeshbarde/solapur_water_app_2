import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @smartMap.
  ///
  /// In en, this message translates to:
  /// **'Smart Map'**
  String get smartMap;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'JalAI Assistant'**
  String get aiAssistant;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @jalPoints.
  ///
  /// In en, this message translates to:
  /// **'JalPoints'**
  String get jalPoints;

  /// No description provided for @ecoPoints.
  ///
  /// In en, this message translates to:
  /// **'EcoPoints'**
  String get ecoPoints;

  /// No description provided for @wardInequalityScore.
  ///
  /// In en, this message translates to:
  /// **'Ward Equality Score'**
  String get wardInequalityScore;

  /// No description provided for @pressureStatus.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressureStatus;

  /// No description provided for @tankLevel.
  ///
  /// In en, this message translates to:
  /// **'Tank Level'**
  String get tankLevel;

  /// No description provided for @municipalityUpdates.
  ///
  /// In en, this message translates to:
  /// **'Municipality Updates'**
  String get municipalityUpdates;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @leak.
  ///
  /// In en, this message translates to:
  /// **'Leak / Burst'**
  String get leak;

  /// No description provided for @illegalConnection.
  ///
  /// In en, this message translates to:
  /// **'Illegal Connection'**
  String get illegalConnection;

  /// No description provided for @lowPressure.
  ///
  /// In en, this message translates to:
  /// **'Low Pressure'**
  String get lowPressure;

  /// No description provided for @waterTheft.
  ///
  /// In en, this message translates to:
  /// **'Water Theft'**
  String get waterTheft;

  /// No description provided for @issueWarning.
  ///
  /// In en, this message translates to:
  /// **'Note: False reports will result in penalties. Verified reports earn rewards.'**
  String get issueWarning;

  /// No description provided for @reportViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Report via WhatsApp'**
  String get reportViaWhatsApp;

  /// No description provided for @rainfallForecast.
  ///
  /// In en, this message translates to:
  /// **'Rainfall & Forecast'**
  String get rainfallForecast;

  /// No description provided for @waterRewards.
  ///
  /// In en, this message translates to:
  /// **'Water Rewards'**
  String get waterRewards;

  /// No description provided for @statusOk.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusOk;

  /// No description provided for @statusAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get statusAttention;

  /// No description provided for @statusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get statusCritical;

  /// No description provided for @pipelinePressure.
  ///
  /// In en, this message translates to:
  /// **'Pipeline Pressure'**
  String get pipelinePressure;

  /// No description provided for @flowRate.
  ///
  /// In en, this message translates to:
  /// **'Flow Rate'**
  String get flowRate;

  /// No description provided for @waterQuality.
  ///
  /// In en, this message translates to:
  /// **'Water Quality'**
  String get waterQuality;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @autoLocationDetected.
  ///
  /// In en, this message translates to:
  /// **'Auto Location Detected'**
  String get autoLocationDetected;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseGallery;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submitComplaint;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @tanker.
  ///
  /// In en, this message translates to:
  /// **'Tanker'**
  String get tanker;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @rainfall.
  ///
  /// In en, this message translates to:
  /// **'Rainfall'**
  String get rainfall;

  /// No description provided for @requestTanker.
  ///
  /// In en, this message translates to:
  /// **'Request Tanker'**
  String get requestTanker;

  /// No description provided for @trackComplaint.
  ///
  /// In en, this message translates to:
  /// **'Track Complaint'**
  String get trackComplaint;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @dataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Data currently unavailable'**
  String get dataUnavailable;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @demoData.
  ///
  /// In en, this message translates to:
  /// **'DEMO DATA'**
  String get demoData;

  /// No description provided for @liveData.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveData;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @acknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get acknowledged;

  /// No description provided for @safeToUse.
  ///
  /// In en, this message translates to:
  /// **'Safe to Use'**
  String get safeToUse;

  /// No description provided for @safetyWarning.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get safetyWarning;

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// No description provided for @noPressure.
  ///
  /// In en, this message translates to:
  /// **'No Pressure'**
  String get noPressure;

  /// No description provided for @supplyNormal.
  ///
  /// In en, this message translates to:
  /// **'Supply Normal'**
  String get supplyNormal;

  /// No description provided for @supplyDelayed.
  ///
  /// In en, this message translates to:
  /// **'Supply Delayed'**
  String get supplyDelayed;

  /// No description provided for @supplyInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Supply Interrupted'**
  String get supplyInterrupted;

  /// No description provided for @noWater.
  ///
  /// In en, this message translates to:
  /// **'No Water'**
  String get noWater;

  /// No description provided for @leakage.
  ///
  /// In en, this message translates to:
  /// **'Water Leakage'**
  String get leakage;

  /// No description provided for @pipelineDamage.
  ///
  /// In en, this message translates to:
  /// **'Pipeline Damage'**
  String get pipelineDamage;

  /// No description provided for @overflow.
  ///
  /// In en, this message translates to:
  /// **'Overflow'**
  String get overflow;

  /// No description provided for @tankerIssue.
  ///
  /// In en, this message translates to:
  /// **'Tanker Issue'**
  String get tankerIssue;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @waterSupply.
  ///
  /// In en, this message translates to:
  /// **'Water Supply'**
  String get waterSupply;

  /// No description provided for @nextSupply.
  ///
  /// In en, this message translates to:
  /// **'Next Supply'**
  String get nextSupply;

  /// No description provided for @quickServices.
  ///
  /// In en, this message translates to:
  /// **'Quick Services'**
  String get quickServices;

  /// No description provided for @waterStatus.
  ///
  /// In en, this message translates to:
  /// **'Water Status'**
  String get waterStatus;

  /// No description provided for @findWaterPoint.
  ///
  /// In en, this message translates to:
  /// **'Find Water Point'**
  String get findWaterPoint;

  /// No description provided for @recentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent Updates'**
  String get recentUpdates;

  /// No description provided for @waterInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Water Infrastructure'**
  String get waterInfrastructure;

  /// No description provided for @searchLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search location, ward or place…'**
  String get searchLocationPlaceholder;

  /// No description provided for @tanks.
  ///
  /// In en, this message translates to:
  /// **'Tanks'**
  String get tanks;

  /// No description provided for @pipelines.
  ///
  /// In en, this message translates to:
  /// **'Pipelines'**
  String get pipelines;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @safeForDrinking.
  ///
  /// In en, this message translates to:
  /// **'Safe for drinking'**
  String get safeForDrinking;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @whatIsProblem.
  ///
  /// In en, this message translates to:
  /// **'What is the problem?'**
  String get whatIsProblem;

  /// No description provided for @dirtyWater.
  ///
  /// In en, this message translates to:
  /// **'Dirty Water'**
  String get dirtyWater;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report Submitted'**
  String get reportSubmitted;

  /// No description provided for @reportSubmittedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been successfully submitted.'**
  String get reportSubmittedDesc;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @yourWaterAssistant.
  ///
  /// In en, this message translates to:
  /// **'Your Water Assistant'**
  String get yourWaterAssistant;

  /// No description provided for @howCanIHelp.
  ///
  /// In en, this message translates to:
  /// **'How can I help you?'**
  String get howCanIHelp;

  /// No description provided for @moderateRainfall.
  ///
  /// In en, this message translates to:
  /// **'Moderate Rainfall'**
  String get moderateRainfall;

  /// No description provided for @reservoirImpact.
  ///
  /// In en, this message translates to:
  /// **'Reservoir Impact'**
  String get reservoirImpact;

  /// No description provided for @floodRisk.
  ///
  /// In en, this message translates to:
  /// **'Flood Risk'**
  String get floodRisk;

  /// No description provided for @savedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocations;

  /// No description provided for @myAchievements.
  ///
  /// In en, this message translates to:
  /// **'My Achievements'**
  String get myAchievements;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @housing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get housing;

  /// No description provided for @commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial / Hotel'**
  String get commercial;

  /// No description provided for @industry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industry;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @adminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage water network'**
  String get adminSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
