# coach_app – Regeln für Claude Code

Diese Regeln gelten immer.

## Quellen der Wahrheit
- Was gebaut wird: docs/PRODUCT_SHEET.md. Wie und in welcher Reihenfolge: docs/BUILD_SHEET.md.
- Feature-Specs und Befunde liegen unter docs/features/<feature>/.
- Vor jeder Aufgabe die passenden Abschnitte lesen und sich darauf beziehen.
- Weicht die Umsetzung ab oder wird eine offene Frage geklärt: Sheet bzw. Spec im selben Commit anpassen.

## Git
- Pro Schritt ein eigener Branch (feature/..., chore/...), kein Fork.
- Nie auf main committen oder pushen. Pull Request gegen main, nicht selbst mergen.
- Vor jedem Commit prüfen, dass der richtige Branch aktiv ist.
- Keine Befehle, die ungesicherte Arbeit verwerfen oder verstecken (stash, reset, checkout/restore
  von Dateien, clean, rebase), ohne vorher zu fragen. Für Vergleiche einen separaten git worktree nutzen.
- Ein Schritt aus dem Build Sheet = ein Commit, mit Tests.

## Architektur
- Local first: alle Daten nur auf dem Gerät. Kein eigener Server, keine Cloud-Datenbank, keine Analytics.
  Netzwerkverkehr nur zur Garmin Personal API.
- Alle Fachlogik (Belastung, Bereitschaft, Planung, Essensplan) im Paket packages/coach_engine:
  reines Dart, deterministisch, ohne Flutter, mit Unit-Tests.
- Kein LLM entscheidet Einheiten oder rechnet Nährwerte.
- Schwellen und Startwerte nur in assets/config/*.json, nie im Code.
- Coach und Essensplan lesen nur normalisierte Tabellen, nie Garmin-JSON.
- Fehlende Werte sind null, nie 0.

## Garmin und Gesundheitsdaten
- Garmin-Key und Token nur im Keychain/Keystore. Nie in Code, Repo, Logs, Tests oder Fehlermeldungen.
- Die Probe- und Anonymisierungs-Skripte führt der Nutzer selbst in einem separaten Terminal aus.
  Niemals Dateien in .garmin-probe/ lesen, nur die anonymisierten Fixtures in test/fixtures/garmin/.
- Vor jedem Commit nach versehentlichen Keys oder Tokens im Diff suchen.
- Die Personal API ist nur lesend und nur für die eigenen Daten.

## UI
- Nur Tokens und Komponenten aus lib/shared/design/. Fehlt eine Komponente: dort anlegen und im PR nennen.
- Texte nur über ARB-Dateien (de zuerst, en mitpflegen). Deutsch: duzen, ruhig, Einladungen statt Befehle,
  keine Gedankenstriche.
- Bedienbar bei 200 % Textgröße, Status nie nur über Farbe.

## Prüfen vor jedem Commit
- dart format, flutter analyze ohne Meldung, flutter test, dart test in packages/coach_engine.
