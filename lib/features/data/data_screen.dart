import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/design/design.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabData)),
      body: PlaceholderView(
        icon: Icons.insights_outlined,
        message: l10n.dataPlaceholder,
      ),
    );
  }
}
