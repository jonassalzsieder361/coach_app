import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/design/design.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMeals)),
      body: PlaceholderView(
        icon: Icons.restaurant_outlined,
        message: l10n.mealsPlaceholder,
      ),
    );
  }
}
