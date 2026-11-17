import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../shared/design/design.dart';
import 'router.dart';

class CoachApp extends StatefulWidget {
  const CoachApp({super.key, this.locale});

  /// Feste Sprache, sonst die des Systems.
  final Locale? locale;

  @override
  State<CoachApp> createState() => _CoachAppState();
}

class _CoachAppState extends State<CoachApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
