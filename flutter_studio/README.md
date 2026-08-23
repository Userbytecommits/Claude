# Flutter Studio

Ein visueller Drag & Drop App-Builder fürs Handy, gebaut mit Flutter.

## Funktionen

- **Anmeldung/Registrierung** – lokale Konten, Projekte werden pro Nutzer verwaltet.
- **Projektverwaltung** – Projekte anlegen, umbenennen, löschen, öffnen.
- **Workspace (oben)** – freie Arbeitsfläche im Handy-Format (360×720), auf der
  Widgets frei positioniert und in der Größe verändert werden können.
- **Katalog (unten)** – alle verfügbaren Widgets (Text, Button, Box, Bild, Icon,
  Eingabefeld, Schalter, Checkbox, Slider, Karte, Listeneintrag, Trenner), die
  per Drag & Drop auf den Workspace gezogen werden.
- **Einstellungen** – tippt man ein platziertes Widget an, wechselt der untere
  Bereich vom Katalog zu erweiterten Einstellungen: Position, Größe, Form,
  Farben, Text, Ausrichtung etc.
- **Vorschau** – Vollbild-Rendering des Projekts, wie es später aussieht.
- **Export / Builder** – erzeugt aus dem Entwurf eine vollständige, echte
  Flutter-App (`main.dart` + `pubspec.yaml`), die kopiert oder auf dem Gerät
  gespeichert werden kann. Diese Dateien lassen sich direkt in ein
  `flutter create`-Projekt einfügen und mit `flutter build apk` /
  `flutter run` zu einer echten App bauen.

## Projekt starten

```bash
cd flutter_studio
flutter create .      # ergänzt einmalig die Plattform-Ordner (android/ios/...)
flutter pub get
flutter run
```

> Hinweis: Icons werden über frei wählbare Codepoints dargestellt. Beim
> Release-Build kann Flutters Icon-Tree-Shaking das verhindern — im
> Zweifel mit `flutter build apk --no-tree-shake-icons` bauen (gilt auch
> für exportierte, generierte Apps).

## Architektur

```
lib/
  models/       Datenmodelle (Project, CanvasElement, Katalog)
  services/     Auth, Projekt-Persistenz (SharedPreferences), Code-Generator
  screens/      Login, Projektübersicht, Studio-Editor, Vorschau, Export
  widgets/      Katalog-Panel, Eigenschaften-Panel, Canvas-Element, Renderer
```

`ElementRenderer` (Editor/Vorschau) und `CodeGenerator` (Export) bilden exakt
dieselbe Widget-Logik ab, damit WYSIWYG gilt: was im Studio zu sehen ist,
entspricht 1:1 der exportierten, echten App.
