// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Coach';

  @override
  String get tabToday => 'Heute';

  @override
  String get tabTraining => 'Training';

  @override
  String get tabMeals => 'Essen';

  @override
  String get tabData => 'Daten';

  @override
  String get todayPlaceholder =>
      'Hier siehst du bald deinen Vorschlag für heute.';

  @override
  String get trainingPlaceholder =>
      'Hier findest du bald deine Trainingswoche und dein Ziel.';

  @override
  String get mealsPlaceholder =>
      'Hier entsteht bald dein Essensplan für die Woche.';

  @override
  String get dataPlaceholder =>
      'Hier kannst du bald deine Garmin-Daten ansehen.';
}
