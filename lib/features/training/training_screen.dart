import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/design/design.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabTraining)),
      body: PlaceholderView(
        icon: Icons.directions_run_outlined,
        message: l10n.trainingPlaceholder,
      ),
    );
  }
}
