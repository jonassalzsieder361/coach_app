# Build Sheet: Coach-App für Training und Ernährung

Nov 17, 2026 · @Jonas

## Überblick

Dieses Build Sheet führt Schritt für Schritt vom leeren Repo zur fertigen Coach-App. **Was** gebaut wird, steht im Product Sheet (`docs/PRODUCT_SHEET.md`), **wie** es gebaut wird, steht hier.

**Jeder Schritt hat drei Teile:** Ziel · Auftrag für Claude Code · Fertig, wenn …

**Faustregeln**

- Ein Schritt = eine Claude-Code-Sitzung = ein Commit mit Tests.
- Größere Schritte erst im Plan-Modus (Shift+Tab) planen lassen, Plan lesen, dann freigeben.
- Zwischen Schritten `/clear`. Die `CLAUDE.md` wird trotzdem immer geladen.
- Erst die Fachlogik mit Tests, dann die Oberfläche.

**Reihenfolge**

| Block | Inhalt | Ergebnis |
| --- | --- | --- |
| Vorbereitung | Voraussetzungen, Repo, Struktur, `CLAUDE.md` | leere App läuft im Simulator |
| Meilenstein 1 | Garmin-Daten (MVP) | deine Garmin-Daten der letzten 60 Tage in der App |
| Meilenstein 2 | Coach (Running + Kraft) | täglicher Vorschlag, Wochenplan, Ziele |
| Meilenstein 3 | Essensplan | Wochenplan mit Einkaufsliste |
| Alltag | iPhone-Installation, 4 Wochen Nutzung | Schwellen nachjustiert |

**Wer macht was:** Claude Code schreibt Code, Tests und Specs. Du gibst Pläne frei, führst Garmin-Skripte mit deinem Key aus, testest auf dem iPhone und prüfst Texte.

## Voraussetzungen

Das meiste ist durch die nola-Garmin-Integration schon da. Haken setzen, was steht.

**Windows (Entwicklung)**

- [ ] Flutter ≥ 3.44 unter `C:\Users\jonas\dev\flutter`, im PATH (`flutter --version` in einem **neuen** Terminal)
- [ ] Git und GitHub-Zugang
- [ ] Claude Code (`claude` startet)
- [ ] Editor zum Mitlesen, z. B. VS Code mit Flutter-Erweiterung

**MacBook (Bauen und Installieren)**

- [ ] Xcode mit iOS-Plattform, `sudo xcodebuild -runFirstLaunch` ausgeführt
- [ ] Flutter ≥ 3.44 und CocoaPods
- [ ] `flutter doctor` zeigt bei Flutter und Xcode einen Haken

**Konten**

- [ ] Garmin Personal API Key (in Garmin Connect, 1 Jahr Laufzeit), gespeichert im Passwortmanager
- [ ] Apple Developer Program (99 € pro Jahr) empfohlen, sonst läuft die App nur 7 Tage
- [ ] Privates GitHub-Repo für die neue App

**Entscheidungen vor dem Start** (aus dem Product Sheet)

- [ ] Name der App (Arbeitstitel im Build Sheet: `coach_app`)
- [ ] Code aus nola-next übernehmen oder neu bauen? Mit deinem Partner klären. Dieses Build Sheet geht vom **Neubau** aus.

## Schritt 0: Repo und Projekt anlegen

**Ziel:** Ein leeres Flutter-Projekt mit Paketen, Ordnerstruktur und Regeln, das auf dem Mac im iOS-Simulator startet.

**0a. Ordner und Doku (du, in PowerShell)**

```powershell
mkdir C:\Users\jonas\Projekte\coach_app
cd C:\Users\jonas\Projekte\coach_app
git init -b main
mkdir docs
```

- Das Product Sheet und dieses Build Sheet als Markdown exportieren und als `docs/PRODUCT_SHEET.md` und `docs/BUILD_SHEET.md` ablegen.
- Die `CLAUDE.md` aus dem Abschnitt weiter unten ins Hauptverzeichnis legen.
- Auf GitHub ein **privates** Repo anlegen (z. B. `coach_app`), dann:

```powershell
git add CLAUDE.md docs
git commit -m "docs: Product Sheet, Build Sheet und Regeln"
git remote add origin https://github.com/<dein-konto>/coach_app.git
git push -u origin main
```

Dieser erste Commit ist der einzige, der direkt auf `main` landet. Danach auf GitHub unter Settings → Branches für `main` „Require a pull request before merging“ einschalten.

**0b. Projekt-Setup (Claude Code)**

```powershell
git checkout -b chore/project-setup
claude
```

**Auftrag** (im Plan-Modus):

```
Lies CLAUDE.md, docs/PRODUCT_SHEET.md und docs/BUILD_SHEET.md. Prüfe, dass wir auf chore/project-setup sind.
Lege im aktuellen Ordner ein Flutter-Projekt an (flutter create ., Plattformen ios und android, org de.jonas, Name coach_app).
Lege das reine Dart-Paket packages/coach_engine an (ohne Flutter-Abhängigkeit) und binde es per Pfad ein.
Füge die Pakete aus dem Tech Stack hinzu (flutter_riverpod, drift + Drift-Werkzeuge, go_router, http,
flutter_secure_storage, workmanager, flutter_local_notifications, freezed, json_serializable, fl_chart,
flutter_localizations, mocktail) in aktuellen stabilen Versionen. Lege die Ordnerstruktur aus BUILD_SHEET an,
dazu ein schlankes Theme (lib/shared/design/) mit Farben, Abständen und Schriftrollen als Tokens,
ARB-Dateien für de und en und eine leere App mit vier Tabs (Heute, Training, Essen, Daten).
Richte flutter_lints ein, lege eine .gitattributes mit "* text=auto eol=lf" an und trage .garmin-probe/ in die .gitignore ein. Keine Fachlogik, noch kein Garmin. Danach flutter analyze, flutter test und dart test
in packages/coach_engine. Committe und pushe nur auf chore/project-setup, dann Pull Request gegen main.
```

**Fertig, wenn** `flutter analyze` ohne Meldung läuft, alle Tests grün sind und die App auf dem Mac im iOS-Simulator mit vier leeren Tabs startet (`open -a Simulator`, dann `flutter run`). Pull Request mergen.

## Projektstruktur

Fachlogik und Oberfläche sind getrennt: Alles, was rechnet, liegt im reinen Dart-Paket `coach_engine`, die App zeigt nur Ergebnisse an.

```
coach_app/
├── CLAUDE.md
├── l10n.yaml                          ← Konfiguration der ARB-Generierung (Vorlage: Deutsch)
├── docs/
│   ├── PRODUCT_SHEET.md
│   ├── BUILD_SHEET.md
│   └── features/                      ← Specs und Befunde je Feature
│       ├── garmin/   (bestandsaufnahme.md, bekannte-testfehler.md …)
│       ├── coach/
│       └── meal-plan/
├── packages/
│   └── coach_engine/                  ← reines Dart, keine Flutter-Abhängigkeit
│       ├── lib/src/
│       │   ├── models/                (Tageswerte, Schlaf, Aktivität, Ziel, Einheit …)
│       │   ├── coach/core/            (load, baselines, sleep, readiness, week_orchestrator)
│       │   ├── coach/modules/running/ (goals, feasibility, periodization, week_planner, daily_adjuster)
│       │   ├── coach/modules/strength/(placement_rules, progression)
│       │   └── nutrition/             (targets, optimizer, shopping_list, replanner)
│       └── test/                      (Fixtures, Beispieltage, Ziel-Szenarien)
├── lib/
│   ├── main.dart
│   ├── app/                           (App, Router, Tabs)
│   ├── data/
│   │   ├── db/                        (Drift: Tabellen, Migrationen)
│   │   ├── garmin/                    (Client, Credentials, Sync-Plan, Normalizer)
│   │   └── repositories/
│   ├── features/
│   │   ├── today/  training/  meals/  data/  onboarding/  settings/
│   ├── shared/design/                 (Tokens, Komponenten)
│   └── l10n/                          (app_de.arb, app_en.arb, daraus generiert app_localizations*.dart)
├── assets/
│   ├── config/  (coach_config.json, goal_profiles.json, nutrition_config.json)
│   ├── strength_exercises.json
│   └── food.sqlite                    (Rezepte, Zutaten, BLS-Nährwerte, Preise)
├── tool/                              (garmin_probe.dart, garmin_anonymize.dart, bls_import.dart)
└── test/
    └── fixtures/garmin/               (nur anonymisierte Antworten)
```

`.garmin-probe/` (Rohdaten) steht von Anfang an in der `.gitignore`.

## CLAUDE.md für das neue Repo

Der Inhalt liegt als `CLAUDE.md` im Hauptverzeichnis. Claude Code liest ihn bei jeder Sitzung.

## Meilenstein 1: Garmin-Daten (MVP)

**Ergebnis:** Deine Garmin-Daten der letzten 60 Tage liegen lokal in der App, mit Bestandsaufnahme, Aktualisieren und Trennen. Branch: `feature/garmin-data`, ein Pull Request am Ende des Meilensteins.

```powershell
git checkout main
git pull
git checkout -b feature/garmin-data
```

### 1.1 Modelle und Tabellen

**Auftrag:**

```
Lies Product Sheet "Feature 1" und "Datenmodell" (Bereich Garmin). Lege in coach_engine unveränderliche Modelle an
(DailyWellness, SleepSession, BodyBatterySample, Activity, SyncState) und in lib/data/db die Drift-Tabellen
daily_wellness, sleep_session, body_battery_sample, activity, sync_state, garmin_connection, garmin_field_inventory.
Alle Messwerte nullable. Repository mit Upsert pro Tabelle (Tageswerte feldweise ergänzen), Aktivität eindeutig
per garmin_activity_id, RPE wird vom Sync nie überschrieben, Gewicht mit Quelle garmin/manual (Garmin hat Vorrang,
leerer Abruf überschreibt nie manuell), deleteAll. Tests für alles davon.
```

**Fertig, wenn** die Tests für Upsert, Dubletten, null statt 0, Gewichtsregel und deleteAll grün sind.

### 1.2 Garmin-Client

**Auftrag:**

```
Baue nach Product Sheet "Feature 1" (Zugang, Endpunkte, Sync): Credentials-Store mit flutter_secure_storage
(Key und Token, ohne Backup), Token-Tausch (POST .../personal-api-key/token, Authorization: ApiKey), Ablauf aus
dem JWT, Neutausch 1 h vor Ablauf und einmal bei 401, Stopp mit key_rejected bei 4xx im Token-Tausch.
API-Client mit 500 ms Pause, bis zu 4 Versuchen mit Backoff bei 429/5xx/Netzfehler (Retry-After hat Vorrang).
Sync-Plan als reine Funktion: 60 Tage Erstimport in Fenstern je Endpunkt (180/28/7/365 Tage, Aktivitäten
seitenweise zu 50), danach die letzten 3 Tage. Sync-Policy: max. 1 Sync pro 5 min, automatisch nach > 15 min.
Fehler nur als Code speichern. Endpunkt-Pfade aus Garmins Python-Client garmin/connect-personal-api-python.
Tests mit MockClient, auch dafür, dass Key und Token in keiner Fehlermeldung auftauchen.
```

**Fertig, wenn** alle Tests grün sind und kein Key im Code oder Test steht.

### 1.3 Probe und Anonymisierung (du führst aus)

**Auftrag:**

```
Schreibe tool/garmin_probe.dart (Key aus GARMIN_PERSONAL_API_KEY, pro Endpunkt die letzten 3 Tage bzw.
5 Aktivitäten plus ein Detail, Rohantworten nach .garmin-probe/, Ausgabe nur Status, Größe, Form und
"Key: n Zeichen", nie Key, Token oder Inhalte; Fehler pro Endpunkt protokollieren und weitermachen)
und tool/garmin_anonymize.dart (IDs, UUIDs, Gerätekennungen konsistent ersetzen, Namen, Texte, GPS,
Zeitzone und Altersgruppe neutralisieren, Daten um ganze Wochen verschieben, bei Leck nichts schreiben,
am Ende verbliebene Textfelder auflisten). Lies .garmin-probe/ nie. Gib mir die PowerShell-Befehle.
```

**Du dann** in einem **separaten** PowerShell-Fenster (dort nie `claude` starten):

```powershell
cd C:\Users\jonas\Projekte\coach_app
$sec = Read-Host "Garmin API-Key" -AsSecureString
$env:GARMIN_PERSONAL_API_KEY = [System.Net.NetworkCredential]::new('', $sec).Password
Remove-Variable sec
dart run tool/garmin_probe.dart
Remove-Item Env:GARMIN_PERSONAL_API_KEY
dart run tool/garmin_anonymize.dart
```

Die **komplette Ausgabe** beider Skripte an Claude Code geben und die Textfeld-Liste auf Namen, Geräte und Orte prüfen.

**Fertig, wenn** alle Endpunkte 200 liefern, die Fixtures in `test/fixtures/garmin/` liegen und geprüft sind.

### 1.4 Normalisierung und Bestandsaufnahme

**Auftrag:**

```
Baue den Normalizer (Garmin-JSON zu Modellen, UTC plus local_date, fehlende Werte null, falsche Grundform =
unexpected_shape), die abgeleiteten Body-Battery-Werte nach Product Sheet (morgens, abends, aktuell), den
Sync-Service (Abruf, Normalisierung, Upsert, sync_state, liefert geänderte Tage) und die Bestandsaufnahme
(Tage mit Daten von 60, erste und letzte Messung pro Metrik, Feldnamen-Liste). Tests gegen die Fixtures,
zweimal Sync ergibt keine Dubletten. Trage die echten Feldnamen in docs/features/garmin/ ein.
```

**Fertig, wenn** die Tests gegen deine anonymisierten Daten grün sind.

### 1.5 Oberfläche

**Auftrag:**

```
Baue nach Product Sheet "Feature 1 – Verbinden und Trennen" und "Screens": Verbinden in 3 Schritten
(Anleitung, Datenschutz und Einwilligung, Key einfügen und sofort prüfen, optional Ablaufdatum),
Tab "Daten" mit Stand, Jetzt aktualisieren (plus Pull-to-Refresh, 5-min-Sperre), Bestandsaufnahme,
14-Tage-Detail je Kennzahl, Hinweisen (Nachtdaten fehlen, Key läuft ab, Key abgelehnt, offline),
Trennen mit "Daten behalten" oder "alles löschen". VO2max nur zeigen, wenn Werte da sind.
Nur Komponenten aus lib/shared/design. Zeig mir alle deutschen Texte als Liste, bevor du committest.
```

**Fertig, wenn** du die Texte freigegeben hast und die Widget-Tests (inkl. 200 % Schrift) grün sind.

### 1.6 Test auf dem iPhone und Pull Request

Auf dem Mac installieren (Abschnitt „Testen auf dem iPhone“), Key in der App eingeben, Testliste durchgehen.

**Auftrag danach:**

```
Hier die Bestandsaufnahme vom iPhone: [Zahlen einfügen]. Schreib sie nach docs/features/garmin/bestandsaufnahme.md.
Streiche die Stress- und Schritte-Abrufe, falls die Tageswerte reichen. Pushe feature/garmin-data und
erstelle einen Pull Request gegen main mit Zusammenfassung, Testanleitung und Screenshots.
```

**Fertig, wenn** der Pull Request gemergt ist und die App mit deinen echten Daten läuft.

## Meilenstein 2: Coach (Running + Kraft)

**Ergebnis:** Jeden Morgen ein begründeter Vorschlag, ein Wochenplan zum Ziel und laufende Neuplanung. Zwei Pull Requests: erst die Logik (`feature/coach-engine`, Schritte 2.1–2.6), dann die Oberfläche (`feature/coach-ui`, 2.7–2.8). Alle Logik-Schritte finden in `packages/coach_engine` statt und brauchen nur Tests, keine Oberfläche.

### 2.1 Config und Belastung

**Auftrag:**

```
Lies Product Sheet "Feature 2a". Lege assets/config/coach_config.json mit allen Schwellen an (Startwerte aus
dem Sheet) und einen Loader in coach_engine. Baue Belastung als reine Funktionen: TRIMP (Banister, m/w),
Session-RPE für Kraft und Aktivitäten ohne Puls, Tageslast, ATL 7, CTL 42, TSB, ACWR, Beinbelastung 48 h.
Baselines: HRV ln(RMSSD) 60 Tage ± 1 SD mit 7-Tage-Schnitt, ab 14 Nächten; Ruhepuls 30-Tage-Median.
```

**Fertig, wenn** Tests mit Hand-gerechneten Werten grün sind.

### 2.2 Schlaf, Body Battery und Bereitschaft

**Auftrag:**

```
Baue nach Product Sheet "Feature 2a": Schlafbedarf (Garmin sleepNeed, sonst eigener Median, Default 7:30 h),
Schlafschuld 7 Tage, Aufladung, Signale mit ok/Achtung/Warnsignal laut Tabelle, die vier Zustände mit
Gründen als Codes, Fallback auf Check-in bei < 2 Signalen. Lege ca. 20 Beispieltage als Fixtures an
(gut erholt, kurze Nacht, 3 kurze Nächte, niedrige Body Battery, krank, hohe Last, Kraft am Vortag, keine Daten …)
mit erwartetem Zustand.
```

**Fertig, wenn** alle 20 Beispieltage den erwarteten Zustand und die erwarteten Gründe liefern.

### 2.3 Ziele, Ausgangslage, Machbarkeit, Zonen

**Auftrag:**

```
Baue nach Product Sheet "Feature 2b": Zielmodell mit Hauptziel und bis zu 3 Zwischenzielen (Wettkampf oder
persönlicher Zeittrial), Ausgangslage aus den letzten 8–12 Wochen (Umfang, längster Lauf, Lauftage,
Leistungsstand aus Wettkämpfen bzw. Pace zu Puls, CTL, Pausen), Machbarkeits-Check mit den drei Stufen und
Vorschlag, Pulszonen (Karvonen) und Pace-Zonen aus dem aktuellen Leistungsstand.
```

**Fertig, wenn** dein Testfall (Marathon < 3:30, 5 km < 20:00) eine plausible Einschätzung bekommt und die Tests grün sind.

### 2.4 Periodisierung und Wochenplan

**Auftrag:**

```
Lege assets/config/goal_profiles.json an (Distanzen, Phasen, Taper, längster Lauf, spezifische Einheiten,
Kraft-Häufigkeit pro Phase). Baue die Periodisierung rückwärts vom Zieldatum, Zwischenziele mit Mini-Taper
und Fenster (nie in den letzten 4 Wochen), und den Wochenplaner mit allen Wochenregeln und Vorlagen
für 3–5 Lauftage. Tests mit drei Szenarien: Jonas-Marathon, 10-km-Einsteiger, fit bleiben.
```

**Fertig, wenn** derselbe Code für alle drei Szenarien Pläne erzeugt, die alle Regeln einhalten.

### 2.5 Modul Kraft

**Auftrag:**

```
Baue nach Product Sheet "Feature 2c": assets/strength_exercises.json mit Varianten je Ausrüstung (zuerst
Tube-Set mit Griffen, Fußschlaufen und Türanker, ohne Geräte), Einheitstypen, Häufigkeit nach Phase,
Platzierungsregeln und den Wochen-Orchestrator (erst Hauptmodul, dann Ergänzung, gemeinsame Regeln prüfen).
Startkombinationen für Jonas aus dem Sheet. Progression über "passt / zu leicht / zu schwer".
```

**Fertig, wenn** Tests zeigen: nie schwere Kraft am Tag vor Qualität, Long Run oder Wettkampf.

### 2.6 Laufende Anpassung und Update-Kette

**Auftrag:**

```
Baue nach Product Sheet "Tägliches Update": heute anpassen (tauschen, herabstufen, kürzen, Pause; Kraft
mitanpassen), restliche Woche neu verteilen mit 15-%-Schwelle und festen Terminen, plan_adjustment-Log.
Verbinde dann in der App per Riverpod: Sync → derived_daily → Coach → Oberfläche, ausgelöst bei App-Start
(> 15 min), Jetzt aktualisieren und eigenen Eingaben. Hintergrund-Abruf am Morgen mit workmanager.
Schreibe planned_session inkl. fuel_class und protein_focus für den späteren Essensplan.
Pull Request für feature/coach-engine.
```

**Fertig, wenn** die Kette in Tests unter 3 s läuft und der Pull Request gemergt ist.

### 2.7 Oberfläche Coach

```powershell
git checkout main
git pull
git checkout -b feature/coach-ui
```

**Auftrag:**

```
Baue nach Product Sheet "Screens": Heute-Karte (Schlaf und Body Battery oben, Einheit, Kraft als zweite Zeile,
Begründung, Warum?, Anders heute), Check-in, Tab Training mit Woche, Ziel und Phasen, Einheit im Detail,
Nach dem Lauf (RPE). Geänderte Tage mit Grund markieren. Zeig mir alle deutschen Texte, bevor du committest.
```

**Fertig, wenn** du die Texte freigegeben hast und die Widget-Tests grün sind.

### 2.8 Coach-Onboarding

**Auftrag:**

```
Baue das Onboarding nach Product Sheet "Screens – Onboarding" bis zum ersten Wochenplan: Ziel und
Zwischenziele, Lauftage, Long-Run-Tag, Zeitbudget, Kraft und Ausrüstung, "So sieht es bei dir aus" mit
Ausgangslage und Machbarkeit. Ziel jederzeit änderbar unter Training. Pull Request für feature/coach-ui.
```

**Fertig, wenn** du auf dem iPhone in unter 5 Minuten vom Onboarding zum ersten Wochenplan kommst.

## Meilenstein 3: Essensplan

**Ergebnis:** Ein trainingsabhängiger Wochenplan mit Einkaufsliste, der sich bei jedem Update mitanpasst. Branch: `feature/meal-plan`. Der größte Aufwand ist hier **Inhalt** (Rezepte, Preise), nicht Code.

**Vorher klären (du):**

- [ ] Wo isst du mittags, für wie viele Personen, welches Wochenbudget, welcher Supermarkt?
- [ ] BLS 4.0: Lizenzbedingungen für die Nutzung in der App beim Max Rubner-Institut prüfen

### 3.1 Nährwerte und Preise

**Auftrag:**

```
Lies Product Sheet "Feature 3". Schreibe tool/bls_import.dart, das die BLS-4.0-Datei (lege ich unter
tool/data/ ab) in assets/food.sqlite importiert, nur die Felder, die wir brauchen. Lege ca. 150 Basiszutaten
mit BLS-Code, Packungsgröße, Supermarkt-Bereich, Saison und Allergenen an. Preise als CSV
(tool/data/prices.csv), die ich pflege und die der Import einliest.
```

**Du dann:** Preise für die Basiszutaten im Supermarkt deiner Wahl eintragen (Discounter-Niveau).

**Fertig, wenn** `food.sqlite` alle Basiszutaten mit Nährwerten und Preisen enthält.

### 3.2 Rezeptbibliothek

**Auftrag** (in mehreren Runden):

```
Entwirf 20 Abendessen nach Product Sheet "Feature 3 – Rezeptbibliothek": alltagstauglich, ≤ 30 min,
nur Zutaten aus food.sqlite, Mengen pro Portion in Gramm, Rolle je Zutat (carb_base, protein, veg, fat, other),
Tags und Schritte. Als JSON unter assets/recipes/. Zeig mir eine Liste zum Prüfen.
```

Danach weitere Runden für Mittagessen, Frühstücke (ca. 15) und Snacks vor und nach dem Lauf (ca. 20). Ziel v1: 60–100 Gerichte.

**Du:** Jedes Rezept kurz prüfen: Kochst du das wirklich? Stimmen Mengen und Zeit?

**Fertig, wenn** mindestens 60 geprüfte Rezepte vorliegen.

### 3.3 Tagesziele

**Auftrag:**

```
Lege assets/config/nutrition_config.json an und baue in coach_engine die Tagesziele: Energie
(Mifflin-St Jeor, PAL, Trainings-kcal, nie unter Alltagsbedarf), Kohlenhydrate nach fuel_class inkl. carb_load
und Vortag-Regel, Protein inkl. protein_focus, Fett ≥ 20 %. Tests mit deinem Gewicht und deiner Trainingswoche.
```

**Fertig, wenn** ein Long-Run-Tag sichtbar mehr Kohlenhydrate hat als ein Ruhetag.

### 3.4 Optimierer und Einkaufsliste

**Auftrag:**

```
Baue nach Product Sheet "Feature 3 – Plan-Erstellung": harte Filter (Allergene, Ernährungsform, Kochzeit,
No-Gos), Greedy-Optimierer mit lokaler Verbesserung (Beilage zuerst skalieren 0,5–2 ×, Kosten minimieren,
Ausgewogenheitsregeln, Budget), Nährwert-Validierung aus food.sqlite, Einkaufsliste (zusammenfassen,
Packungen runden, nach Bereichen), Meal-Prep-Hinweise. Tests für alle 14 Hauptallergene.
```

**Fertig, wenn** ein Wochenplan in unter 10 s entsteht, Protein jeden Tag und Kohlenhydrate an mindestens 6 von 7 Tagen im Zielbereich liegen und kein Allergen durchrutscht.

### 3.5 Anpassung, Tauschen, Gewicht, Verpflegung

**Auftrag:**

```
Baue die Neuplanung nach Product Sheet "Feature 3 – Anpassung": erst Portionen, dann max. 2 Gerichtswechsel
pro Update mit bevorzugt gekauften Zutaten, Anpinnen, Tauschen mit 3 Alternativen, Einkaufsliste mit
"zusätzlich kaufen" und "nicht mehr nötig". Hänge den Essensplan in die Update-Kette nach dem Coach.
Dazu manuelle Gewichtseingabe (Regel garmin/manual) und das Verpflegungs-Log.
```

**Fertig, wenn** ein vom Coach verschobener Long Run den Beilagen-Hinweis am selben Tag ändert.

### 3.6 Oberfläche Essen

**Auftrag:**

```
Baue nach Product Sheet "Screens": Tab Essen mit Woche, Mahlzeiten-Karten, Rezept, Tauschen, Anpinnen,
Einkaufsliste (teilen als Text), Meal Prep, Verpflegungs-Log, Mahlzeiten auf der Heute-Karte und das
Ernährungs-Onboarding (Allergien Pflicht, Rest überspringbar). Zeig mir alle deutschen Texte vor dem Commit.
Pull Request für feature/meal-plan.
```

**Fertig, wenn** du eine Woche lang nach dem Plan eingekauft und gekocht hast und Preise und Portionen nachjustiert sind.

## Testen auf dem iPhone und Alltag

Am Ende jedes Meilensteins kommt die App per MacBook auf dein iPhone. Die ausführliche Anleitung steht in „nola: App auf Mac und iPhone testen“ (https://claude.ai/artifact/QvmF7Afm8afspaeqyjnM1E) und gilt hier genauso, nur mit dem neuen Repo.

**Kurzfassung auf dem Mac**

```bash
cd ~/Projekte
git clone https://github.com/<dein-konto>/coach_app.git   # nur beim ersten Mal
cd coach_app
git fetch
git checkout <branch>        # z. B. feature/garmin-data, nach dem Merge main
git pull
flutter pub get
cd ios && pod install && cd ..
open -a Simulator && flutter run              # Simulator, ohne Signierung
flutter run --release                         # echtes iPhone per Kabel
```

- Signierung in Xcode (`ios/Runner.xcworkspace` → Signing & Capabilities) mit deinem Apple-Developer-Team. Die Bundle-ID ist neu, es gibt keinen Konflikt mit nola.
- Den Garmin-Key über den Passwortmanager aufs iPhone bringen, nie per Mail oder Messenger.
- Auf dem Mac nichts committen, Xcode-Änderungen liegen lassen.

**Vom Test zum Alltag**

1. Nach Meilenstein 2 die App **4 Wochen täglich nutzen** und notieren, wann ein Vorschlag nicht gepasst hat.
2. Mit diesen Notizen die Schwellen in `coach_config.json` nachjustieren lassen (eigener Branch, eigener Pull Request).
3. Nach Meilenstein 3 dasselbe für Preise, Portionen und Rezepte, 2–3 Wochen.
4. Optional TestFlight einrichten, dann kommen neue Versionen ohne Kabel aufs iPhone.

## Prüfliste und Definition of Done

**Nach jedem Bericht von Claude Code** (bevor du „weiter“ schreibst):

- [ ] Commit liegt auf dem richtigen Branch, nicht auf `main`
- [ ] `flutter analyze` ohne Meldung, alle Tests grün
- [ ] Bestehender Code nur an genannten Stellen angefasst
- [ ] Abweichungen vom Product Sheet sind im Sheet bzw. in der Spec nachgetragen
- [ ] Kein Key, Token oder Rohdatum im Diff

**Ein Meilenstein ist fertig, wenn:**

- [ ] alle „Fertig, wenn“-Punkte der Schritte erfüllt sind
- [ ] die App auf deinem iPhone mit echten Daten läuft
- [ ] du alle neuen deutschen Texte gelesen hast
- [ ] der Pull Request eine Zusammenfassung, Testanleitung und Screenshots hat und gemergt ist

**Die App ist v1-fertig, wenn:**

- [ ] du sie 4 Wochen täglich genutzt hast und die Schwellen nachjustiert sind
- [ ] jeder Vorschlag eine Begründung hat und „heute Pause“ vorkommt, wenn du krank bist
- [ ] der Essensplan eine Woche Einkauf und Kochen im Budget getragen hat
- [ ] „Alle Daten löschen“ wirklich alles löscht

## Häufige Probleme

Alle diese Probleme sind bei der nola-Garmin-Integration schon einmal aufgetreten.

| Problem | Ursache | Lösung |
| --- | --- | --- |
| `flutter` wird nicht gefunden | Terminal wurde vor der Installation geöffnet | Windows Terminal komplett schließen (alle Tabs) und neu öffnen, dann `claude --continue` |
| „GARMIN_PERSONAL_API_KEY ist nicht gesetzt“ | nach `Read-Host` die zweite Zeile vergessen | `$env:GARMIN_PERSONAL_API_KEY = [System.Net.NetworkCredential]::new('', $sec).Password` ausführen |
| Token-Tausch liefert 404 | Key gelöscht, verwechselt oder unvollständig | in Garmin Connect alle Keys löschen, einen neuen erstellen, sofort im Passwortmanager speichern |
| Anonymisierung: „Mögliche Lecks gefunden“ | unbekanntes ID-Feld in den Rohdaten | den gemeldeten Feldnamen an Claude Code geben, das Skript erweitern lassen, nur die Anonymisierung neu starten |
| Weniger Fixtures als Endpunkte | Probe-Abruf lief nicht oder brach ab | Probe-Ausgabe prüfen („Fertig: N Abrufe, davon M mit 200“), Ablauf komplett wiederholen |
| Claude Code sieht nur „[Ausgabe einfügen]“ | Platzhalter statt echter Ausgabe mitgeschickt | Ausgabe im Terminal markieren, Strg+C, in die Nachricht einfügen |
| Claude Code fragt, ob eingefügter Text deine Anweisung ist | lange eingefügte Nachricht ohne eigene Zeile | Nachricht mit „Das sind meine Anweisungen:“ beginnen |
| „Login expired“ oder Nutzungslimit | Sitzung abgelaufen | `/login`, später mit `claude --continue` weitermachen; nicht committete Dateien bleiben erhalten |
| Tests mit Prüfsummen schlagen nur unter Windows fehl | Windows schreibt Zeilenenden als CRLF | in Schritt 0 eine `.gitattributes` mit `* text=auto eol=lf` anlegen lassen |
| Golden-Tests weichen unter Windows ab | Schriften werden auf Windows anders gezeichnet | Golden-Tests nur auf dem Mac erzeugen und prüfen |
| Worktree scheitert an Pfadlänge | Windows-Pfadlimit | `git config core.longpaths true` nur für dieses Repo |
| Xcode meldet Fehler zu Team oder Bundle-ID | Signierung nicht eingerichtet | in Xcode unter Settings → Accounts die Apple-ID hinzufügen und das Team wählen |
| App startet nach einer Woche nicht mehr | kostenlose Apple-ID, 7 Tage Laufzeit | neu installieren oder Apple Developer Program nutzen |
| Nachtdaten fehlen am Morgen | Uhr hat noch nicht über Garmin Connect synchronisiert | Garmin Connect kurz öffnen, dann in der App aktualisieren |
