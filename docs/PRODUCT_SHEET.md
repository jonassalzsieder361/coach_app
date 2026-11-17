# Product Sheet: Coach-App für Training und Ernährung

Nov 17, 2026 · @Jonas

## Überblick

Eine neue, eigenständige App (Arbeitstitel offen) schlägt jeden Morgen die passende Trainingseinheit vor und plant dazu einen Wochen-Essensplan. Grundlage sind die Garmin-Daten der Uhr. Sie übernimmt alle Anforderungen, die für den Coach und den Essensplan in nola erarbeitet wurden, ist aber **nicht** Teil der nola-App.

|  |  |
| --- | --- |
| **Kernversprechen** | „Heute lieber locker, morgen Intervalle und danach 25 Minuten Kraft“, mit kurzer, nachvollziehbarer Begründung, und ein Essensplan, der sich daran anpasst |
| **Nutzer Phase 1** | nur Jonas, mit seinen eigenen Garmin-Daten (Forerunner 265, iPhone) |
| **Nutzer später** | weitere Läufer und Läuferinnen, erst nach eigener Entscheidung (siehe Offene Fragen: Garmin-Zugang für andere) |
| **Datenquelle** | Garmin Personal API, direkt aus der App abgerufen |
| **Plattform** | iOS zuerst (Flutter, Android später ohne Neubau möglich) |
| **Datenhaltung** | local first: alles auf dem Gerät, kein eigener Server |

## Produktprinzipien und Abgrenzung zu nola

Die fachlichen Entscheidungen aus nola gelten weiter, die nola-spezifischen Vorgaben (Marke, Design System, Positionierung) nicht.

**Gilt weiter (verbindlich):**

1. **Local first:** Alle Daten bleiben auf dem Gerät. Kein eigener Server, keine Übertragung von Gesundheitsdaten außer von Garmin aufs Gerät.
2. **Regeln statt Black Box:** Bereitschaft, Trainingsplan und Essensplan entstehen aus festen, testbaren Regeln. Ein LLM legt nie eine Einheit fest und rechnet nie Nährwerte.
3. **Jede Empfehlung ist begründet**, mit mindestens einem konkreten Signal („HRV unter deinem Normalbereich, nur 5:40 h Schlaf“).
4. **Bereitschaft geht vor Plan:** „Heute Pause“ ist ein vollwertiger Vorschlag. Verpasste Einheiten werden nicht nachgeholt.
5. **Ziele sind Konfiguration:** Jeder setzt sein eigenes Ziel. Keine fest eingebauten Pläne, keine Sonderfälle im Code.
6. **Stabile Pläne:** Updates ändern nur, was sich wirklich ändert (Schwelle 15 %, höchstens 2 Gerichtswechsel pro Update).
7. **Sporternährung, keine Diät:** kein Abnehm-Modus, kein Tracking dessen, was gegessen wurde.
8. **Kein medizinischer Rat**, klare Hinweise bei Krankheit, Schmerzen und Warnzeichen.
9. **Quellenunabhängige Datenschicht:** Coach und Essensplan lesen nur normalisierte Tabellen, nie Garmin-JSON. Weitere Quellen (Apple Health, Health Connect) kommen später ohne Umbau dazu.
10. **Konfiguration statt Code:** Alle Schwellen und Startwerte liegen in JSON-Dateien und werden nach 4 bis 6 Wochen echter Nutzung nachjustiert.

**Fällt weg, weil es nola-spezifisch war:**

- nola Design System, Storybook-Export und nola-Schreibregeln: Die neue App bekommt ein eigenes, schlankes Design System (siehe Tech Stack).
- Einordnung als Opt-in im nola-Fokus „Movement“ und die nola-Personas: Die neue App ist für Menschen gebaut, die gezielt trainieren.
- Kopplung an nolas Supplement-Tracking: Ersetzt durch ein einfaches Verpflegungs-Log (Gels, Getränke) im Essensplan.

**Neu zu entscheiden:**

- **Zahlen sichtbar:** Vorschlag: Bereitschaft in Worten („gut erholt“), die Werte dahinter (Schlaf, HRV, Body Battery, Belastung) offen sichtbar statt eingeklappt, weil die Zielgruppe gezielt trainiert.
- **Code aus nola-next:** Die Garmin-Anbindung wurde im nola-Repo gebaut, das du dir mit deinem Partner teilst. Vor einer Übernahme klären, ob ihr den Code dafür freigebt. Sonst wird sie in der neuen App neu gebaut, mit diesem Sheet als Vorlage.

## Feature-Übersicht und Release-Phasen

Gebaut wird in drei Stufen, jede für sich nutzbar: erst die Daten, dann der Coach, dann der Essensplan.

| Feature | MVP (Daten) | v1 (Coach) | v1.1 (Essen) | Später |
| --- | --- | --- | --- | --- |
| Garmin-Anbindung (Personal API) | ✓ |  |  | weitere Quellen: Apple Health, Health Connect |
| „Meine Daten“ mit Bestandsaufnahme | ✓ |  |  |  |
| Bereitschaft und Heute-Karte |  | ✓ |  |  |
| Ziele, Zwischenziele, Machbarkeits-Check |  | ✓ |  |  |
| Wochenplan Laufen mit Periodisierung |  | ✓ |  | Workouts auf die Uhr schicken |
| Modul Kraft |  | ✓ |  | weitere Module: Aktiv im Alltag, Rad, Triathlon |
| Tägliches Update und Neuplanung | Abruf | Coach | Essen | Hintergrund-Abruf am Morgen |
| Wochen-Essensplan mit Einkaufsliste |  |  | ✓ | Wünsche in freier Sprache |
| Gewicht manuell erfassen |  |  | ✓ |  |
| Verpflegungs-Log (Gels, Getränke) |  |  | ✓ |  |
| Weitere Nutzer |  |  |  | nur mit eigener Entscheidung zum Garmin-Zugang |

## Feature 1: Garmin-Datenanbindung

Die App holt die Garmin-Daten direkt über die **Garmin Personal API** ab, ohne Server dazwischen. Im nola-Prototyp kamen am 27.10.2026 alle 26 Probe-Abrufe mit Status 200 zurück.

**Zugang**

- Der Nutzer erstellt den Key selbst in Garmin Connect (Web) unter [Personal API](https://connect.garmin.com/app/settings/personalApiToken), Laufzeit wählbar bis 1 Jahr. Der Key wird nur einmal angezeigt.
- Token-Tausch: `POST https://personal.connectapi.garmin.com/personalapitoken-service/personal-api/personal-api-key/token` mit Header `Authorization: ApiKey <key>`, ohne Body. Antwort: ein JWT, gültig 24 h, Ablauf aus dem `exp`-Feld.
- Token 1 h vor Ablauf neu holen, bei 401 einmal neu holen. Lehnt der Token-Tausch den Key mit 4xx ab, stoppt der Sync mit „Key nicht angenommen“.
- Nur lesen: Workouts auf die Uhr schicken geht mit der Personal API nicht.
- Garmin-Bedingungen: Der Key gilt nur für die **eigenen** Daten in selbst betriebenen Tools, nicht für Apps, die andere Menschen bedienen.

**Endpunkte** (Pfade aus Garmins offiziellem Python-Client `garmin/connect-personal-api-python`)

| Endpunkt | Liefert | Max. Zeitraum pro Abruf | Im Prototyp |
| --- | --- | --- | --- |
| daily\_summary | Ruhepuls (`heartRate.restingValue`), Kalorien, Intensitätsminuten, Atmung, Pulsoxymetrie, Body Battery des Tages, Trinkmenge | 180 Tage | 200 |
| hrv / hrv\_day | nächtliche HRV, HRV-Status mit Garmin-Feedback | 180 Tage | 200 |
| sleep / sleep\_day | Schlafphasen, Sleep Score, Schlafbedarf (`sleepNeed`, `nextSleepNeed`) | 28 Tage | 200 |
| body\_battery | Verlauf und Garmin-Feedback | 28 Tage | 200 |
| activities / activity\_detail | Sportart, Dauer, Distanz, Puls, Training Effect, Trainingsbelastung pro Aktivität (`activityTrainingLoad`) | Seiten zu 50 | 200 |
| heart\_rate\_zones | Pulszonen je Sportart | – | 200 |
| daily\_heart\_rate, spo2\_day | Tagesverläufe | – | 200 |
| fitness\_age | Fitness-Alter (VO2max möglicherweise enthalten, unbestätigt) | – | 200 |
| weight | Gewicht | 365 Tage (getestet) | 200, ohne Einträge |
| wellness\_activities, hydration | eigene Einträge | – | 200, leer |
| stress, steps | dieselben Werte wie daily\_summary | 7 Tage | **streichen**, wenn die Bestandsaufnahme das bestätigt |

**Nicht verfügbar:** Training Readiness, täglicher Training Status und Belastung, Race Predictor, Garmins Tagesvorschläge (Daily Suggested Workouts). Die App berechnet Bereitschaft und Belastung selbst (Feature 2a). VO2max ist offen, bis ein Abruf ihn findet, und wird bis dahin nicht angezeigt.

**Sync**

- Erstimport: 60 Tage, aufgeteilt nach den Zeitraum-Limits. Danach bei jedem Sync die letzten 3 Tage neu (Garmin ergänzt nachträglich), per Datum bzw. Aktivitäts-ID überschrieben.
- 500 ms Pause zwischen Abrufen. Bei 429, 5xx und Netzfehlern bis zu 4 Versuche mit wachsender Wartezeit, eine Wartevorgabe von Garmin hat Vorrang.
- Höchstens 1 Sync pro 5 Minuten. Automatisch beim Öffnen nur, wenn der letzte Sync mehr als 15 Minuten her ist.
- Fehlende Werte werden `null`, nie 0. Ohne Netz arbeitet die App mit den lokalen Daten weiter.
- Fehler werden nur als kurzer Code gespeichert, nie mit Antworttext, Key oder Token.

**Abgeleitete Werte**

- **Body Battery morgens:** erster Messpunkt innerhalb von 3 h nach dem Aufwachen.
- **Body Battery abends:** Tiefstwert von 4 h vor bis 15 min nach dem Einschlafen, eingetragen am Abend des Zubettgehens.
- **Body Battery aktuell:** Zeitpunkt aus dem Ende des Berichtszeitraums, nicht aus dem letzten Messpunkt.
- **Gewicht:** Quelle `garmin` oder `manual`. Ein Garmin-Wert hat Vorrang, ein leerer Garmin-Abruf überschreibt nie einen manuellen Wert.

**Verbinden und Trennen**

1. Anleitung: Key in Garmin Connect erstellen, ein Jahr Gültigkeit empfohlen, sofort kopieren.
2. Datenschutz und Einwilligung: was gelesen wird, wofür, dass alles auf dem Gerät bleibt.
3. Key einfügen, die App prüft ihn sofort. Gespeichert wird er erst, wenn Garmin ihn akzeptiert. Optional das Ablaufdatum eintragen.

- Key und Token liegen nur im Keychain, ohne Backup und ohne Gerätewechsel.
- Hinweis 14 Tage vor Key-Ablauf.
- Trennen mit Wahl: Daten behalten oder alles löschen (Key, Token, Daten).
- Hinweis, wenn die Nachtdaten noch fehlen: „Die Daten von heute Nacht sind noch nicht bei Garmin. Wenn du Garmin Connect kurz öffnest, kannst du hier danach aktualisieren.“

## Feature 2a: Coach-Kern

Der Kern entscheidet, **wie viel** heute geht. Die Module (Running als Hauptmodul, Kraft als Ergänzung) entscheiden, **was** konkret.

**Module**

- Genau ein Hauptmodul (v1: Running) strukturiert die Woche mit Schlüsseleinheiten und Long Run.
- Ergänzungsmodule (v1: Kraft) bekommen freie Plätze zugeteilt und halten sich an die Regeln des Hauptmoduls.
- Der Kern kennt keine Laufbegriffe. Spätere Module (Aktiv im Alltag, Rad, Triathlon) kommen ohne Änderung am Kern dazu.

**Belastung**

- Pro Aktivität ein TRIMP-Wert (Banister) aus Dauer und Durchschnittspuls: `TRIMP = Dauer_min × ΔHR × 0,64 × e^(1,92 × ΔHR)` (männlich; weiblich 0,86 und 1,67), mit `ΔHR = (HR_avg − HR_rest) / (HR_max − HR_rest)`.
- Gilt für alle Sportarten mit Puls, auch Rad und Schwimmen. Ohne Puls und bei Kraft: Session-RPE (`Dauer × RPE`).
- ATL = 7-Tage-, CTL = 42-Tage-Schnitt (exponentiell), TSB = CTL − ATL, ACWR = 7-Tage-Summe / (28-Tage-Summe / 4).
- Eigener Zähler **Beinbelastung**: schwere Bein- und Sprungübungen der letzten 48 h.
- Garmins `activityTrainingLoad` pro Aktivität dient zum Abgleich.

**Baselines**

- HRV: ln(RMSSD), Normalbereich = 60-Tage-Mittel ± 1 SD. Verglichen werden 7-Tage-Schnitt und heutiger Wert. HRV zählt erst ab 14 Nächten, voll ab etwa 30.
- Ruhepuls: 30-Tage-Median.

**Schlaf und Body Battery** sind Pflichtsignale und wirken auf drei Ebenen:

| Ebene | Regel |
| --- | --- |
| Heute | Body Battery morgens < 50 → lockere Einheit 15–20 % kürzer. Am Nachmittag aktuelle Body Battery < 25 → locker oder Mobilität statt Qualität. |
| Restliche Woche | Schlafschuld ≥ 5 h → höchstens 1 Qualitätseinheit in den nächsten 3 Tagen, Kraft nur leicht. Schlafschuld ≥ 8 h oder 3 Nächte in Folge < 6 h → 2 Tage nur locker plus Schlaf-Hinweis. Body Battery morgens 3 Tage in Folge < 40 → Entlastungswoche vorziehen. |
| Sichtbar | Heute-Karte zeigt immer Schlaf und Body Battery der Nacht, die Wochenansicht pro Tag. |

- **Schlafbedarf:** Garmins `sleepNeed` als erster Wert, sonst eigener Median vor guten Tagen, Default 7:30 h, editierbar.
- **Schlafschuld:** Summe aus (Bedarf − Schlaf) der letzten 7 Nächte, nur positive Werte.
- **Aufladung:** Body Battery morgens − abends.

**Bereitschaft:** Jedes Signal ergibt ok, Achtung oder Warnsignal.

| Signal | Achtung | Warnsignal |
| --- | --- | --- |
| HRV (7-Tage-Schnitt) | unter Normalbereich | heute < Mittel − 2 SD |
| Ruhepuls | > Baseline + 5 bpm | > Baseline + 10 bpm |
| Schlafdauer | < 85 % des Bedarfs oder < 6 h | < 5 h |
| Schlafqualität | Sleep Score < 60 | Sleep Score < 40 |
| Schlafschuld (7 Tage) | ≥ 5 h | ≥ 8 h |
| Body Battery morgens | < 35 | < 15 |
| Aufladung über Nacht | < 30 Punkte | < 15 Punkte |
| Belastung | ACWR > 1,4 oder TSB < −25 | ACWR > 1,7 |
| Check-in | Energie niedrig | „krank“ oder „Schmerzen“ |

| Zustand | Regel | Erlaubt |
| --- | --- | --- |
| Bereit („gut erholt“) | 0 × Achtung, mind. 2 Signale ok | alles inkl. Intervalle und Tempo |
| Normal | genau 1 × Achtung | locker, Long Run, Steigerungen; harte Einheit nur verkürzt |
| Schonen („eher ruhig angehen“) | ≥ 2 × Achtung oder 1 × Warnsignal | nur locker, max. 45 min |
| Erholung („heute Pause“) | krank/Schmerzen oder ≥ 2 × Warnsignal | Ruhetag oder 20–30 min Spaziergang |

- Weniger als 2 Signale verfügbar → 2-Tap-Check-in (Gefühl, Energie, krank/Schmerzen). Ohne Antwort bleibt der Plan, Hinweis „heute ohne Daten“.
- Jede Entscheidung speichert ihre Gründe als Codes (`hrv_below_range`, `short_sleep` …) für die Begründung.

## Feature 2b: Ziele und Trainingsplanung (Modul Running)

Der Nutzer setzt sein Ziel, die App liest aus der Garmin-Historie, wo er steht, und plant den Weg dorthin.

**Zielmodell**

| Feld | Werte | Pflicht |
| --- | --- | --- |
| Zieltyp | Wettkampf · Distanz schaffen (ohne Zeit) · fit bleiben (ohne Datum) | ja |
| Distanz | 5 km · 10 km · Halbmarathon · Marathon · frei in km | bei Wettkampf und Distanz |
| Zielzeit | z. B. 3:29:59 | nein |
| Datum, Name | z. B. Berlin-Marathon | Datum bei Wettkampf |
| Lauftage, Long-Run-Tag, max. Minuten an Werktagen | aus dem Onboarding | ja |
| Zwischenziele | bis zu 3, gleiche Felder, Typ Wettkampf oder persönlicher Zeittrial | nein |

**Zwischenziele**

- Kein eigener Plan: Sie verschieben in den 2–3 Wochen davor den Schwerpunkt der Qualitätseinheiten (für 5 km z. B. 5 × 1000 m oder 8 × 400 m im 5-km-Tempo).
- Mit Datum: 3–4 Tage Mini-Taper davor, 2–3 lockere Tage danach.
- Ohne Datum (persönlicher Zeittrial): Die App plant ein Fenster von 1–2 Wochen, standardmäßig am Ende der Aufbau-Phase. Der Versuch wird nur an einem Morgen mit Zustand „Bereit“ vorgeschlagen, sonst rutscht er im Fenster weiter.
- Nie in den letzten 4 Wochen vor dem Hauptziel. Passt kein Fenster, dann 4–6 Wochen nach dem Hauptziel.
- Das Ergebnis wird aus der Garmin-Aktivität gelesen und aktualisiert sofort Pace-Zonen und Machbarkeit des Hauptziels.

**Ausgangslage aus Garmin** (beim Zielsetzen und alle 4 Wochen, aus den letzten 8–12 Wochen, alles editierbar)

- Wochenumfang (Ø 4 Wochen), längster Lauf (6 Wochen), Lauftage pro Woche bisher
- Leistungsstand: aus Wettkämpfen und Testläufen (automatisch erkannt, Nutzer bestätigt), sonst aus Pace zu Puls bei lockeren Läufen
- Belastbarkeit aus CTL, Pausen > 14 Tage für vorsichtigen Wiedereinstieg
- Wenig Historie: 2–3 Fragen im Onboarding plus ein lockerer Testlauf in den ersten 2 Wochen

**Machbarkeits-Check** (beim Zielsetzen und alle 4 Wochen)

- Prüft Zeit bis zum Ziel, erreichbaren Umfang (10-%-Regel) und Abstand zwischen Form und Zielzeit.
- Ergebnis: „gut erreichbar“, „ambitioniert“ oder „sehr ambitioniert“, mit Begründung und Vorschlag („mit 5 statt 4 Lauftagen gut erreichbar“, „3:35–3:40 wäre realistisch“).
- Der Nutzer entscheidet. Trainiert wird immer vom aktuellen Stand aus, nie mit einem Tempo, das die Form noch nicht hergibt.

**Periodisierung:** Rückwärts vom Zieldatum, Werte pro Distanz in `goal_profiles.json`.

| Distanz | Ideale Vorbereitung | Taper | Längster Lauf | Spezifisch |
| --- | --- | --- | --- | --- |
| 5 km | 6–8 Wochen | 1 Woche | 10–12 km | Intervalle, 5-km-Tempo |
| 10 km | 8–10 Wochen | 1 Woche | 14–16 km | Schwelle, 10-km-Tempo |
| Halbmarathon | 10–14 Wochen | 1–2 Wochen | 18–22 km | Schwelle, HM-Tempo-Blöcke |
| Marathon | 16–20 Wochen | 2–3 Wochen | 30–32 km | Marathontempo-Läufe, Long Run mit MT-Block |

Phasen: Grundlage (wird bei Zeitmangel zuerst gekürzt) → Aufbau → wettkampfspezifisch → Taper (nie gekürzt).

**Wochenregeln**

- ca. 80 % der Zeit locker, höchstens 2 harte Einheiten, nie zwei harte Tage hintereinander, nach dem Long Run kein harter Tag
- Umfang + max. 10 % gegenüber dem 3-Wochen-Schnitt, jede 4. Woche −20 bis −30 %, Long Run ≤ 30 % des Wochenumfangs
- Nach > 14 Tagen Pause Neustart mit 50–70 % des früheren Umfangs
- Vorlagen: 3 Tage (Locker, Qualität, Long Run) · 4 Tage (+ Locker) · 5 Tage (+ Steigerungen oder 2. Qualität), Marathon mit Zeitziel: 5 Tage empfohlen
- Rad und Schwimmen werden nicht geplant, zählen aber zur Belastung

**Zonen und Einheiten**

- Pulszonen (Karvonen) steuern lockere Läufe und Long Runs, Pace-Zonen (aus Leistungsstand, alle 4 Wochen neu) steuern Renntempo, Schwelle und Intervalle.
- Einheiten: Ruhetag, Regeneration (Z1, 20–30 min), Locker (Z2, 30–60 min), Long Run (Z2, 60–150 min), Steigerungen, Tempo/Schwelle, Intervalle, Marathontempo-Lauf, Long Run mit MT-Block, Zeittrial.

**Garmins Tagesvorschläge** lassen sich nicht auslesen. Die App macht eigene Vorschläge und erkennt absolvierte Läufe an den Aktivitätsdaten, egal welchem Vorschlag gefolgt wurde.

## Feature 2c: Modul Kraft

Kraft macht Läufer ökonomischer, schneller und robuster, darf aber nie eine Laufeinheit schlechter machen.

| Typ | Inhalt | Dauer | Default-RPE | Beinbelastung |
| --- | --- | --- | --- | --- |
| Kraft schwer | Kniebeuge, einbeiniges Kreuzheben, Hip Thrust, Wadenheben, 3–4 Sätze à 4–8 | 30–40 min | 7 | hoch |
| Plyometrie | Hopserlauf, Pogo Jumps, Sprunglauf | 15–20 min | 6 | hoch |
| Leicht / Stabi | Rumpf, Hüfte, Fußgewölbe, Balance | 15–25 min | 4 | niedrig |
| Mobilität | Hüftbeuger, Waden, Brustwirbelsäule | 10–15 min | 2 | keine |

**Häufigkeit nach Phase:** Grundlage 2 × schwer · Aufbau 1–2 × schwer (mehr Sprünge bei 5-km-Ziel) + 1 × leicht · wettkampfspezifisch 1 × Erhalt + 1 × leicht · Taper: letzte schwere Einheit ca. 10 Tage vor dem Rennen. Der Nutzer kann die Häufigkeit begrenzen.

**Platzierung**

- „Kraft schwer“ bevorzugt am selben Tag wie eine Qualitätseinheit, nach dem Lauf.
- Nie schwer oder Sprünge am Tag vor Qualitätseinheit, Long Run oder Wettkampf. Mindestens 48 h zwischen zwei schweren Einheiten.
- Ruhetage bleiben Ruhetage (höchstens Mobilität). Passt Kraft nicht in die Woche, fällt sie weg.
- Bereitschaft gilt auch hier: Normal → leicht statt schwer, Schonen → 15 min Mobilität, Erholung → nichts.

**Übungsbibliothek** (`strength_exercises.json`) mit Varianten je Ausrüstung: ohne Geräte, Tube-Set mit Griffen und Türanker, Mini-Loops, lange Loop-Bänder, Kettlebell/Hanteln, Fitnessstudio. Mit Bändern arbeitet die App mit Band-Kombinationen („30 + 20“) und RPE statt Kilos.

**Erledigt und Progression:** Erkannt über eine Garmin-Kraftaktivität oder einen Tap. Alle 3–4 Wochen schlägt die App die nächste Stufe vor, der Nutzer bestätigt „passt“, „zu leicht“ oder „zu schwer“. Kein Satz-für-Satz-Tracking in v1.

## Feature 3: Wochen-Essensplan

Einmal pro Woche entsteht ein ausgewogener, günstiger Essensplan mit Einkaufsliste, der zum Trainingsplan passt. **Kernidee:** dieselben alltagstauglichen Gerichte, nur die Kohlenhydrat-Beilage (Reis, Nudeln, Kartoffeln, Brot) passt sich der Trainingslast an.

**Tagesziele**

- Energie: Grundumsatz nach Mifflin-St Jeor × PAL 1,4 + geplante Trainings-kcal. Nach 3–4 Wochen PAL mit Garmins tatsächlichem Verbrauch kalibrieren. Nie unter dem Alltagsbedarf.
- Protein: ca. 1,6 g/kg (1,4–2,0), verteilt auf 3–4 Mahlzeiten. An Krafttagen 1,8–2,0 g/kg und eine proteinreiche Mahlzeit nach der Einheit.
- Fett: mindestens 20 % der Energie.

| Trainingstag | Beispiel | Kohlenhydrate (g/kg) |
| --- | --- | --- |
| rest | Ruhetag, Regeneration | 3–4 |
| low | ≤ 45 min locker | 4–5 |
| moderate | 45–75 min oder Qualitätseinheit | 5–7 |
| high | Long Run ≥ 90 min oder 2 Einheiten | 7–8, bei Long Runs ≥ 2,5 h bis 10 |
| carb\_load | 36–48 h vor einem Marathon | 10–12 |

- Tag vor einem Long Run ≥ 90 min: eine Stufe höher. Vor einem 5-km-Ziel reicht `moderate`.
- Rennverpflegung: Start bei ca. 60 g Kohlenhydraten pro Stunde. Bei Long Runs ab ca. 25 km schlägt die App vor, die Verpflegung zu testen, und hält im Verpflegungs-Log fest, was vertragen wurde.
- Hohe Schlafschuld oder niedrige Body Battery: schnellere Gerichte oder Reste, gleiche Nährwertziele.
- Timing-Hinweise: 2–3 h vorher kohlenhydratreich und fettarm, danach innerhalb von 1–2 h Kohlenhydrate plus Protein.

**Ausgewogenheit** (DGE): mind. 5 Portionen Obst und Gemüse am Tag, ≥ 30 g Ballaststoffe, Hülsenfrüchte mind. 1 × pro Woche, Fisch 1–2 ×, Fleisch und Wurst max. ca. 300 g pro Woche, kein Hauptgericht öfter als 2 × pro Woche.

**Kosten:** eigene Preistabelle für ca. 150 Basiszutaten (Discounter-Niveau, Packungsgrößen, quartalsweise gepflegt), ganze Packungen verplanen, Saison bevorzugen, Batch Cooking, Wochenkosten und Kosten pro Portion anzeigen, Budget nie überschreiten.

**Plan-Erstellung (lokal)**

1. Tagesziele aus den geplanten Einheiten berechnen
2. Rezepte filtern: Allergien, Ernährungsform, Kochzeit, Ausrüstung, No-Gos (harte Regeln)
3. Rezepte auf Tage verteilen und Portionen skalieren, zuerst die Beilage (0,5–2 ×). Ziel: niedrigste Kosten bei Protein und Kohlenhydraten im Zielbereich, Energie ± 10 %
4. Nährwerte aus dem Bundeslebensmittelschlüssel (BLS 4.0) nachrechnen, nie aus einem LLM
5. Einkaufsliste: Zutaten zusammenfassen, auf Packungen runden, nach Supermarkt-Bereichen sortieren
6. Meal-Prep-Hinweise für Sonntag

**Rezeptbibliothek v1:** 60–100 Gerichte (≤ 30 min an Werktagen), ca. 15 Frühstücke, ca. 20 Snacks inkl. vor und nach dem Lauf. Entwürfe dürfen offline mit KI entstehen, jede Zutat wird geprüft und einem BLS-Code zugeordnet. Bibliothek, Preise und Nährwerte werden mit der App ausgeliefert.

**Anpassung während der Woche**

- Erst Portionen anpassen („Heute ruhiger als geplant. Eine kleinere Portion Reis reicht.“), dann höchstens 2 Gerichte pro Update tauschen, bevorzugt mit schon gekauften Zutaten.
- Vergangene und angepinnte Mahlzeiten bleiben fix.
- Einkaufsliste zeigt „zusätzlich kaufen“ und „nicht mehr nötig“, abgehakte Artikel gelten als gekauft.
- Gericht tauschen: 3 Alternativen mit ähnlichen Nährwerten und vorhandenen Zutaten.

**Gewicht:** aus Garmin, sonst manuell in der App. Garmin hat Vorrang, ein leerer Garmin-Abruf überschreibt nie einen manuellen Wert.

**Grenzen:** Allergien sind harte Regeln (Test für alle 14 Hauptallergene), kein Defizit-Modus, kein Ess-Tracking, kein medizinischer Rat. Supplements nur, wenn der Nutzer sie selbst einträgt.

## Tägliches Update und Neuplanung

Jedes Update läuft dieselbe Kette durch und ist nach dem Abruf in unter 3 Sekunden fertig. Die Daten kommen über Uhr → Garmin Connect App → Garmin-Cloud → App. Die App kann die Synchronisierung der Uhr nicht selbst auslösen.

| Auslöser | Wann |
| --- | --- |
| App öffnen | wenn der letzte Sync mehr als 15 min her ist |
| „Jetzt aktualisieren“ | Button auf der Heute-Karte und Pull-to-Refresh, höchstens 1 × pro 5 min |
| Hintergrund am Morgen | Wunschfenster 06:30–09:00, iOS bestimmt den Zeitpunkt (Bonus, kein Versprechen) |
| Eigene Eingabe | Check-in, Gewicht, RPE, „Anders heute“ |

**Die Kette**

1. Garmin-Daten abrufen und normalisiert speichern
2. Belastung, Baselines, Schlafschuld und Bereitschaft neu berechnen
3. Coach: heutige Einheit anpassen (tauschen, herabstufen, kürzen oder Pause), dann die restliche Woche neu verteilen
4. Essensplan: Portionen der kommenden Tage anpassen, nur wenn nötig Gerichte tauschen
5. Oberfläche: „Stand 07:12 · Daten von heute Nacht“, geänderte Einheiten und Mahlzeiten mit Grund markiert

**Regeln für die Neuplanung**

- Ein Tag ändert sich nur, wenn sich Einheitstyp oder Dauer um mehr als 15 % ändern würden.
- Long-Run-Tag und Wettkampf bleiben fix, außer im Zustand „Erholung“.
- Bereits absolvierte Einheiten und vergangene Mahlzeiten werden nicht mehr geändert.
- Jede Änderung wird mit vorher, nachher und Grund protokolliert.
- Morgen-Benachrichtigung optional und standardmäßig aus, nur wenn ein Hintergrund-Update neue Daten gebracht hat.

## Screens und Navigation

Vorschlag: vier Tabs (Heute, Training, Essen, Daten), Einstellungen über das Profil-Symbol.

| Tab | Screen | Inhalt |
| --- | --- | --- |
| Heute | Heute-Karte | Oben immer Schlaf und Body Battery der Nacht plus Stand, darunter die Einheit („45 min locker, Zone 2, Puls 130–145“), ggf. „dazu: 20 min Stabi“, eine Zeile Begründung, Buttons „Warum?“ und „Anders heute“, darunter die Mahlzeiten des Tages |
| Heute | Warum? | alle Signale mit Wert und Einordnung (Schlaf, HRV, Ruhepuls, Body Battery, Belastung) |
| Heute | Anders heute | weniger Zeit (kürzen), schlechter gefühlt (→ Schonen), krank/Schmerzen (→ Erholung), heute nicht (Ruhetag) |
| Heute | Check-in | 2 Taps: Gefühl, Energie, optional krank/Schmerzen; erscheint nur, wenn Daten fehlen oder auf Wunsch |
| Training | Woche | 7 Tage: Lauf und Kraft mit Typ und Dauer, Haken für Erledigtes, Schlaf-Balken und Body Battery je Tag, geänderte Tage markiert |
| Training | Ziel und Phasen | Hauptziel, Zwischenziele als Meilensteine, Phasen bis zum Zieldatum, Machbarkeit, Pace- und Pulszonen |
| Training | Einheit | Ablauf (Aufwärmen, Hauptteil, Auslaufen), Zielzonen; bei Kraft die Übungen mit Band-Kombination |
| Training | Nach dem Lauf | „Wie hat sich das angefühlt?“ 1–10, ein Tap, überspringbar |
| Essen | Woche | Tabs Mo–So mit Trainingslabel und Mahlzeiten-Karten („Reis: große Portion, heute Long Run“, Zeit, Kosten), Nährwerte unter „Details“ |
| Essen | Rezept, Tauschen, Anpinnen | Rezept mit skalierten Mengen, 3 Alternativen, „bleibt so“ |
| Essen | Einkaufsliste | nach Bereichen, abhakbar, Gesamtkosten, „zusätzlich kaufen“ / „nicht mehr nötig“, als Text teilen |
| Essen | Meal Prep, Verpflegungs-Log | Sonntagsliste; Gels und Getränke mit „vertragen“ / „nicht vertragen“ |
| Daten | Meine Garmin-Daten | Stand, „Jetzt aktualisieren“, Bestandsaufnahme (an wie vielen der letzten 60 Tage), Kennzahlen mit 14-Tage-Detail |
| Profil | Einstellungen | Garmin verbinden/trennen, Key-Ablauf, Gewicht, Körperdaten, Ernährung, Ausrüstung, Benachrichtigungen, alle Daten löschen |

**Onboarding** (einmalig, Reihenfolge): Garmin verbinden (Anleitung → Datenschutz → Key) → Daten laden → Ziel und Zwischenziele → Lauftage, Long-Run-Tag, Zeitbudget → Kraft und Ausrüstung → „So sieht es bei dir aus“ mit Ausgangslage und Machbarkeit → Ernährung (Allergien Pflicht, Rest überspringbar) → erster Wochenplan.

## Datenmodell

Alle Tabellen liegen lokal in einer SQLite-Datenbank. Zeiten in UTC plus `local_date` (Kalendertag in der Zeitzone des Nutzers); fehlende Werte sind `null`.

| Bereich | Tabelle | Wichtige Felder |
| --- | --- | --- |
| Garmin | `daily_wellness` | local\_date, resting\_hr, hrv\_night\_avg\_ms, hrv\_status, body\_battery\_morning / \_evening / \_max / \_min / \_current (+ Zeitpunkt), stress\_avg, steps, active\_kcal, total\_kcal, intensity\_minutes, spo2\_avg, respiration\_avg, vo2max, weight\_kg + weight\_source, source |
| Garmin | `sleep_session` | local\_date (Aufwachtag), start/end, total/deep/light/rem/awake\_min, sleep\_score, sleep\_need\_min |
| Garmin | `body_battery_sample` | timestamp, value (60 Tage Aufbewahrung) |
| Garmin | `activity` | garmin\_activity\_id (eindeutig), start, dauer, sport, distanz, höhenmeter, avg/max\_hr, hr\_zone\_seconds, pace, training\_load, kcal, rpe (manuell, wird vom Sync nie überschrieben) |
| Garmin | `sync_state`, `garmin_connection` | letzter Abruf je Endpunkt, Fehlercode, Key-Ablauf, Einwilligung |
| Garmin | `garmin_field_inventory` | Endpunkt, Feldname, zuerst/zuletzt gesehen, Anzahl (nur Namen, keine Werte) |
| Coach | `user_physiology` | Geburtsjahr, Geschlecht, Größe, hr\_max, hr\_rest, Zonen, Schwellenpace |
| Coach | `derived_daily` | training\_load, atl\_7d, ctl\_42d, acwr, leg\_load\_48h, hrv\_baseline, rhr\_baseline, sleep\_need, sleep\_debt\_7d, bb\_recharge, readiness\_state, readiness\_reasons |
| Coach | `goal`, `milestone` | Typ, Distanz, Zielzeit, Datum, Name, Fenster (Zeittrial), Status, Machbarkeit |
| Coach | `training_prefs` | Lauftage, Long-Run-Tag, max. Minuten, Kraft an/aus, Ausrüstung, Bandstärken, max. Kraft pro Woche |
| Coach | `planned_session` | Datum, Modul (running/strength), Typ, Dauer, Intensität, Zonen, est\_kcal, fuel\_class, protein\_focus, Status (geplant/angepasst/erledigt/ausgelassen) |
| Coach | `plan_adjustment` | Datum, vorher, nachher, Grund |
| Coach | `checkin` | Datum, Gefühl, Energie, krank, Schmerzen |
| Essen | `ingredient` | Name, BLS-Code, Nährwerte pro 100 g, Preis pro kg, Packungsgröße, Supermarkt-Bereich, Saison, Allergene |
| Essen | `recipe`, `recipe_ingredient` | Titel, Portionen, Zeit, Slot, Tags, Ausrüstung, Schritte; Gramm pro Portion, Rolle (carb\_base/protein/veg/fat/other) |
| Essen | `food_prefs` | Ernährungsform, Allergien, No-Gos, Budget, Kochzeit, Haushaltsgröße, Mahlzeiten-Struktur |
| Essen | `meal_plan`, `meal_plan_item` | Woche, Ziele, Kosten; Datum, Slot, Rezept, Portions- und Beilagen-Faktor, Rest von, angepinnt, Grund der letzten Änderung |
| Essen | `shopping_list_item`, `fueling_log`, `recipe_feedback` | Menge, Packungen, Kosten, abgehakt; Produkt, Menge, vertragen; Bewertung |

**Mit der App ausgeliefert** (nicht in der Nutzer-DB): `coach_config.json` (Schwellen), `goal_profiles.json` (Distanzen, Phasen, Kraft-Häufigkeit), `nutrition_config.json`, `strength_exercises.json`, Rezepte und Zutaten mit BLS-Nährwerten und Preisen als SQLite-Asset.

## Tech Stack

Empfehlung: **Flutter mit Dart**, iOS zuerst. Flutter läuft bei dir schon auf Windows und dem MacBook, die Garmin-Anbindung ist in Dart bereits einmal erprobt, und dieselbe Codebasis trägt später Android. Eine native Swift-App wäre nur besser, wenn Apple Watch oder HealthKit im Mittelpunkt stünden.

| Bereich | Wahl | Warum |
| --- | --- | --- |
| Framework | Flutter (≥ 3.44, bei dir 3.47.8 stable) mit Dart 3 | eine Codebasis für iOS und Android, schnelle UI-Iteration, gute Unterstützung durch Claude Code |
| Fachlogik | eigenes Dart-Paket `coach_engine` ohne Flutter-Abhängigkeit | Belastung, Bereitschaft, Planer und Essensplan-Optimierer als reine Funktionen, schnell testbar mit `dart test`, auch von Skripten nutzbar |
| State Management | Riverpod (`flutter_riverpod`) | die Update-Kette (Sync → Coach → Essen → UI) braucht reaktive, testbare Abhängigkeiten; reines `setState` wie in nola-next reicht dafür nicht |
| Lokale Datenbank | Drift (SQLite) | typsichere Abfragen, Migrationen und Streams direkt in die UI; viele verknüpfte Tabellen |
| Navigation | `go_router` | Tabs, Deep Links aus Benachrichtigungen |
| Netzwerk | `http` | dünne Schicht für die Garmin Personal API, testbar mit `MockClient` |
| Sicherer Speicher | `flutter_secure_storage` | Garmin-Key und Token im iOS-Keychain bzw. Android-Keystore |
| Hintergrund | `workmanager` | Morgen-Abruf (iOS entscheidet den Zeitpunkt) |
| Benachrichtigungen | `flutter_local_notifications` | lokale Morgen- und Nach-dem-Lauf-Hinweise, kein Push-Server nötig |
| Modelle | `freezed` + `json_serializable` | unveränderliche Datenklassen, JSON für Garmin-Antworten und Config-Dateien |
| Diagramme | `fl_chart` | Schlaf-Balken, Belastung, Body Battery |
| Sprache | `flutter_localizations` + ARB-Dateien | Deutsch zuerst, Englisch vorbereitet |
| Tests | `flutter_test`, `mocktail`, Fixtures | Unit-Tests für die Fachlogik, Widget-Tests für Screens, anonymisierte Garmin-Antworten als Testdaten |
| Code-Qualität | `flutter_lints` oder `very_good_analysis` | einheitlicher Stil, `flutter analyze` ohne Meldungen |
| Nährwerte | BLS 4.0 (Max Rubner-Institut), Import per Dart-Skript in ein SQLite-Asset | kostenlos, deutsche Lebensmittel; Lizenz für die App-Nutzung prüfen |

**Infrastruktur und Werkzeuge**

- Privates GitHub-Repo, Branch pro Feature, Pull Requests gegen `main`
- Entwicklung auf Windows mit Claude Code, Bauen und Installieren auf dem MacBook mit Xcode
- Apple Developer Program (99 € pro Jahr) empfohlen: Mit kostenloser Apple-ID läuft die App nur 7 Tage, für eine täglich genutzte App ist das zu umständlich. Bonus: TestFlight
- Optional GitHub Actions für `flutter analyze` und Tests bei jedem Push
- Kein Backend, keine Cloud-Datenbank, keine Analytics

Paketversionen beim Projekt-Setup auf die aktuell stabile Version prüfen.

## Architektur

_(Architektur-Diagramm siehe Product Sheet in claude.ai: App-Schichten, lokale Daten, Garmin)_

Die App holt die Daten selbst bei der Garmin-Cloud ab und speichert sie nur lokal. Die gesamte Fachlogik liegt im reinen Dart-Paket `coach_engine`, die Oberfläche zeigt nur dessen Ergebnisse.

## Nicht-funktionale Anforderungen und Workflow

**Datenschutz und Sicherheit**

- Gesundheitsdaten nur auf dem Gerät, Netzwerkverkehr nur zu Garmin.
- Garmin-Key nie im Code, Repo, Log, Test oder Crash-Report. Nur im Keychain.
- „Alle Daten löschen“ entfernt Datenbank, Key und Token vollständig.
- Datenbank-Verschlüsselung (SQLCipher) ist in v1 nicht vorgesehen, vor einer Freigabe an andere Nutzer neu entscheiden.

**Qualität**

- Die Update-Kette ist nach dem Abruf in unter 3 s fertig, ein Essensplan entsteht in unter 10 s.
- Die App funktioniert offline mit dem letzten Stand.
- Fachlogik vollständig mit Unit-Tests: ca. 20 Beispieltage für die Bereitschaft, mindestens 3 Ziel-Szenarien (Jonas-Marathon, 10-km-Einsteiger, fit bleiben), Allergen-Tests für alle 14 Hauptallergene.
- Bedienbar bei 200 % Textgröße, Status nie nur über Farbe.

**Entwicklungs-Workflow mit Claude Code** (aus der nola-Garmin-Integration übernommen)

1. Ein `CLAUDE.md` im Repo mit den Regeln dieses Sheets, die Feature-Specs unter `docs/features/<feature>/`.
2. Pro Feature ein Branch, Plan-Modus vor dem ersten Code, ein Umsetzungsschritt = ein Commit mit Tests.
3. Nie auf `main` pushen, Pull Request gegen `main`, nicht selbst mergen. Keine Git-Befehle, die ungesicherte Arbeit verwerfen (stash, reset, checkout von Dateien, clean, rebase), ohne Rückfrage.
4. Garmin-Testdaten nur über Probe- und Anonymisierungs-Skripte: Der Key steht nur in einem separaten Terminal als Umgebungsvariable, Claude Code liest nie die Rohdaten, nur die anonymisierten Fixtures.
5. Weicht die Umsetzung vom Sheet ab, wird das Sheet bzw. die Spec im selben Commit angepasst.

## Testfall Jonas

Die App wird mit diesen echten Werten gebaut und getestet. Sie sind Testdaten, kein Sonderfall im Code.

|  | Wert |
| --- | --- |
| Uhr | Garmin Forerunner 265 (HRV-Status, Body Battery, Sleep Score, Stress, SpO2) |
| Handy | iPhone, gebaut über das MacBook |
| Hauptziel | Marathon unter 3:30:00 (4:58 min/km), Datum offen |
| Zwischenziel | 5 km unter 20:00 (4:00 min/km), persönlicher Zeittrial ohne Datum |
| Erwartete Einschätzung | 5-km-Ziel eher „ambitioniert“: Es entspricht rechnerisch einer Marathonform um 3:10–3:15, deshalb mehr Schnelligkeit in der Aufbau-Phase |
| Kraft | 1–2 × pro Woche zu Hause |
| Ausrüstung | Tube-Set (Wild Instincts): 5 Bänder 10/20/30/40/50 lb, kombinierbar bis 150 lb, 2 Griffe, 2 Fußschlaufen, Türanker, 2 Karabiner; keine Mini-Loops |
| Startkombinationen | Kniebeuge 50 + 30, Bulgarian Split Squat 30 + 20, Kreuzheben 50 + 40, Hip Thrust 40 + 30, Hüftabduktion mit Fußschlaufe 10–20 |
| Gewicht | Garmin liefert derzeit keine Einträge, deshalb manuell |
| Garmin-Probe (27.10.2026) | 26 von 26 Abrufen mit 200; Body Battery morgens 60/56/41, abends 14/12/5 in den Fixtures |

## Offene Fragen

**Vor dem Start klären**

- [ ] **Name der App**
- [ ] **Nur für dich oder später für andere?** Die Personal API gilt nur für eigene Daten. Für andere Nutzer bräuchte es Garmins Stufe Starter (Antrag, Daten nur per Push an einen Server, also eine Ausnahme von local first) oder Apple Health / Health Connect ohne Body Battery.
- [ ] **Code aus nola-next übernehmen?** Mit deinem Partner klären, sonst Neubau nach diesem Sheet.
- [ ] **Apple Developer Program** (99 € pro Jahr) abschließen?

**Kann während des Baus geklärt werden**

- [ ] Welcher Marathon, an welchem Datum?
- [ ] Bereitschaft: Werte offen zeigen (Vorschlag) oder nur auf Wunsch?
- [ ] Wettkämpfe automatisch erkennen und bestätigen lassen (Vorschlag) oder nur manuell markieren?
- [ ] Rad und Schwimmen nur mitzählen (Vorschlag) oder später als Triathlon planen?
- [ ] Kraftübungen: reichen Texte, oder braucht es Bilder bzw. Videos?
- [ ] Liefert `fitness_age` VO2max?
- [ ] Stress- und Schritte-Abrufe streichen, sobald die Bestandsaufnahme bestätigt, dass die Tageswerte reichen
- [ ] Essen: Wo isst du mittags, für wie viele Personen, welches Budget, welcher Supermarkt?
- [ ] BLS 4.0: Lizenzbedingungen für die App-Nutzung
- [ ] Android: ab wann?

## Quellen

- [Garmin: Personal API](https://developer.garmin.com/gc-developer-program/personal/personal-api/) · [Swagger Docs](https://developer.garmin.com/gc-developer-program/personal/swagger-docs/)
- [DC Rainmaker: Garmin öffnet das Connect-API-Programm neu (Okt. 2026)](https://www.dcrainmaker.com/2026/10/garmin-connect-api-revamps-connect-developer.html)
- [the5krunner: Garmin Personal API](https://the5krunner.com/2026/10/22/garmin-personal-api/)
- [Sahha: Garmin API 2026, Stufen und Bedingungen](https://sahha.ai/blog/garmin-connect-api-reopened-fees/)
- [heise: Bundeslebensmittelschlüssel 4.0 kostenlos](https://heise.de/-11123877)
- ACSM, Academy of Nutrition and Dietetics und Dietitians of Canada: „Nutrition and Athletic Performance“ (2016); Deutsche Gesellschaft für Ernährung (DGE)
- Garmin-Probe und Prototyp: nola-Branch `feature/garmin-integration`, Stand 27.10.2026
