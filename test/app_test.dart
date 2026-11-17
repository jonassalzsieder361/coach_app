import 'package:coach_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() => const ProviderScope(child: CoachApp(locale: Locale('de')));

Finder _tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  testWidgets('zeigt die vier Tabs mit deutschen Namen', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    for (final label in ['Heute', 'Training', 'Essen', 'Daten']) {
      expect(_tab(label), findsOneWidget);
    }
    expect(
      find.text('Hier siehst du bald deinen Vorschlag für heute.'),
      findsOneWidget,
    );
  });

  testWidgets('Tab-Wechsel zeigt den passenden Inhalt', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    const expected = {
      'Training': 'Hier findest du bald deine Trainingswoche und dein Ziel.',
      'Essen': 'Hier entsteht bald dein Essensplan für die Woche.',
      'Daten': 'Hier kannst du bald deine Garmin-Daten ansehen.',
      'Heute': 'Hier siehst du bald deinen Vorschlag für heute.',
    };
    for (final entry in expected.entries) {
      await tester.tap(_tab(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('bleibt bei 200 % Textgröße ohne Überlauf bedienbar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final context = tester.element(find.byType(NavigationBar));
    expect(MediaQuery.textScalerOf(context).scale(10), 20);

    for (final label in ['Training', 'Essen', 'Daten', 'Heute']) {
      await tester.tap(_tab(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
