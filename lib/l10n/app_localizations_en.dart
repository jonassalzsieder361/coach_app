// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coach';

  @override
  String get tabToday => 'Today';

  @override
  String get tabTraining => 'Training';

  @override
  String get tabMeals => 'Food';

  @override
  String get tabData => 'Data';

  @override
  String get todayPlaceholder =>
      'Your suggestion for today will appear here soon.';

  @override
  String get trainingPlaceholder =>
      'Your training week and goal will appear here soon.';

  @override
  String get mealsPlaceholder => 'Your weekly meal plan will appear here soon.';

  @override
  String get dataPlaceholder =>
      'You will soon be able to view your Garmin data here.';
}
