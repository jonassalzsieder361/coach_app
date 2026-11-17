# coach_app

Coach-App für Training und Ernährung auf Basis der eigenen Garmin-Daten. Local first, iOS zuerst.

- Was gebaut wird: `docs/PRODUCT_SHEET.md`
- Wie und in welcher Reihenfolge: `docs/BUILD_SHEET.md`
- Regeln für Claude Code: `CLAUDE.md`

## Prüfen

```
dart format .
flutter analyze
flutter test
cd packages/coach_engine && dart test
```
