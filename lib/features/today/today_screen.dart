import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/design/design.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabToday)),
      body: PlaceholderView(
        icon: Icons.wb_sunny_outlined,
        message: l10n.todayPlaceholder,
      ),
    );
  }
}
