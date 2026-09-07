# Wecker-App (Flutter)

Eine einfache Wecker-App für Android, gebaut mit Flutter. Der Grund für diese
App: Der normale System-Wecker vieler Android-Handys spielt den Weckton auch
dann noch zusätzlich über den Lautsprecher ab, wenn Kopfhörer oder ein
Bluetooth-Gerät verbunden sind. Diese App löst genau das:

**Kernfunktion: "Nur über Kopfhörer"**
Ist beim Anlegen eines Alarms der Schalter "Nur über Kopfhörer" aktiv (Standard: an),
wird der Ton bei laufendem Alarm bevorzugt an ein verbundenes Kopfhörer- oder
Bluetooth-Gerät geschickt, **nicht** zusätzlich an den internen Lautsprecher.
Ist nichts verbunden, klingelt der Wecker ganz normal über den Lautsprecher.
Technisch nutzt das App die `preferConnectedAudioDevice`-Option des
[`alarm`-Plugins](https://pub.dev/packages/alarm).

## Funktionsumfang

- Alarme anlegen, bearbeiten, löschen (auch per Wischen nach rechts in der Liste, mit "Rückgängig")
- Uhrzeit, Bezeichnung, Wiederholung an einzelnen Wochentagen
- Ein-/Ausschalten pro Alarm
- Schlummerdauer pro Alarm wählbar (3–30 Minuten) und Stopp im Klingel-Bildschirm bzw. über die Benachrichtigung
- Alarm klingelt auch bei gesperrtem Bildschirm (Vollbild-Benachrichtigung) und auch wenn die App komplett geschlossen ist
- Pro Alarm einstellbar: "Nur über Kopfhörer" ein/aus
- Anzeige "Nächster Wecker in X Std. Y Min." auf der Startseite
- Dark Mode (System / Hell / Dunkel, unter dem Zahnrad-Symbol)
- Haptisches Feedback bei Interaktionen, dezente Animationen (Puls-Icon beim Klingeln, Zeit-Wechsel)
- Eigenes Launcher-Icon (Uhr mit Kopfhörer-Motiv statt Platzhalter)

## App bauen und aufs Handy bringen

### Variante A: Fertige APK über GitHub Actions herunterladen (kein eigenes Setup nötig)

1. Diesen Branch/Repo auf GitHub pushen (ist bereits eingerichtet).
2. Im Reiter **Actions** den Workflow **"Build Wecker APK"** abwarten (läuft automatisch bei jedem Push, oder manuell über "Run workflow" starten).
3. Nach erfolgreichem Lauf im Workflow-Ergebnis das Artefakt **`wecker-app-apk`** herunterladen – das ist eine ZIP-Datei, die die installierbare `app-release.apk` enthält.
4. ZIP entpacken, `app-release.apk` aufs Handy übertragen und installieren (in den Android-Einstellungen ggf. "Installation aus unbekannten Quellen" für den verwendeten Dateimanager/Browser erlauben).

### Variante B: Lokal selbst bauen

Voraussetzung: [Flutter SDK](https://docs.flutter.dev/get-started/install) installiert.

```bash
cd alarm_app
flutter pub get
flutter build apk --release
```

Die fertige APK liegt danach unter `build/app/outputs/flutter-apk/app-release.apk`.

## Hinweise / bekannte Einschränkungen

- Für zuverlässiges Klingeln auch bei starker Akku-Optimierung sollte die App
  in den Android-Einstellungen von der Akku-Optimierung ausgenommen werden.
- Ab Android 12 muss die Berechtigung "Exakte Alarme" ggf. einmalig manuell
  erteilt werden (App fragt danach, sofern vom Hersteller unterstützt).
- Manche Hersteller (Samsung, Xiaomi, Huawei, …) schränken Hintergrund-Apps
  zusätzlich ein – dort hilft oft ein manueller "Autostart"-Eintrag für die App.
- Diese App wurde in dieser Umgebung ohne installiertes Android-SDK erstellt
  und konnte deshalb nicht lokal kompiliert werden – der GitHub-Actions-
  Workflow übernimmt den ersten echten Build. Sollte er fehlschlagen, bitte
  den Fehler aus dem Actions-Log melden, dann wird nachgebessert.
