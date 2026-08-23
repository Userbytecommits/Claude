import '../models/canvas_element.dart';
import '../models/project.dart';

/// Erzeugt aus einem [Project] ein vollständiges, eigenständiges und
/// kompilierbares Flutter-Projekt (main.dart + pubspec.yaml). Das ist der
/// "Builder", der aus dem visuellen Entwurf eine echte App macht: die Datei
/// kann 1:1 in ein `flutter create`-Projekt kopiert und mit
/// `flutter build apk` / `flutter run` gebaut werden.
class CodeGenerator {
  String _escape(String s) =>
      s.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\n', '\\n');

  String _colorLit(int argb) =>
      'const Color(0x${argb.toRadixString(16).padLeft(8, '0').toUpperCase()})';

  String _widgetFor(CanvasElement e) {
    final p = e.properties;
    switch (e.type) {
      case 'text':
        final align = p['textAlign'] == 'center'
            ? 'TextAlign.center'
            : p['textAlign'] == 'right'
                ? 'TextAlign.right'
                : 'TextAlign.left';
        return "Text('${_escape(p['text'] ?? '')}', "
            "textAlign: $align, "
            "style: TextStyle(fontSize: ${p['fontSize'] ?? 16.0}, "
            "fontWeight: ${p['bold'] == true ? 'FontWeight.bold' : 'FontWeight.normal'}, "
            "fontStyle: ${p['italic'] == true ? 'FontStyle.italic' : 'FontStyle.normal'}, "
            "color: ${_colorLit(p['color'] ?? 0xFF000000)}))";
      case 'button':
        return "ElevatedButton("
            "onPressed: () {}, "
            "style: ElevatedButton.styleFrom("
            "backgroundColor: ${_colorLit(p['backgroundColor'] ?? 0xFF3F51B5)}, "
            "foregroundColor: ${_colorLit(p['color'] ?? 0xFFFFFFFF)}, "
            "shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(${p['borderRadius'] ?? 12.0}))), "
            "child: Text('${_escape(p['text'] ?? 'Button')}', style: TextStyle(fontSize: ${p['fontSize'] ?? 16.0})))";
      case 'container':
        return "Opacity(opacity: ${p['opacity'] ?? 1.0}, child: Container("
            "decoration: BoxDecoration("
            "color: ${_colorLit(p['backgroundColor'] ?? 0xFFE0E0E0)}, "
            "borderRadius: BorderRadius.circular(${p['borderRadius'] ?? 8.0}), "
            "border: Border.all(color: ${_colorLit(p['borderColor'] ?? 0xFF000000)}, width: ${p['borderWidth'] ?? 0.0})"
            ")))";
      case 'image':
        final fit = p['fit'] == 'contain' ? 'BoxFit.contain' : 'BoxFit.cover';
        return "ClipRRect(borderRadius: BorderRadius.circular(${p['borderRadius'] ?? 8.0}), "
            "child: Image.network('${_escape(p['imageUrl'] ?? '')}', fit: $fit, "
            "errorBuilder: (c, e, s) => Container(color: const Color(0xFFE0E0E0), child: const Icon(Icons.broken_image))))";
      case 'icon':
        return "Icon(IconData(${p['iconCodePoint'] ?? 0xe838}, fontFamily: 'MaterialIcons'), "
            "size: ${p['size'] ?? 40.0}, color: ${_colorLit(p['color'] ?? 0xFF000000)})";
      case 'textfield':
        return "TextField(decoration: InputDecoration("
            "hintText: '${_escape(p['hint'] ?? '')}', "
            "border: OutlineInputBorder(borderRadius: BorderRadius.circular(${p['borderRadius'] ?? 8.0}))))";
      case 'switch':
        return "Switch(value: ${p['value'] ?? true}, activeColor: ${_colorLit(p['activeColor'] ?? 0xFF3F51B5)}, onChanged: (_) {})";
      case 'checkbox':
        return "Checkbox(value: ${p['value'] ?? true}, activeColor: ${_colorLit(p['activeColor'] ?? 0xFF3F51B5)}, onChanged: (_) {})";
      case 'slider':
        return "Slider(value: ${p['value'] ?? 0.5}, activeColor: ${_colorLit(p['activeColor'] ?? 0xFF3F51B5)}, onChanged: (_) {})";
      case 'card':
        return "Card(color: ${_colorLit(p['backgroundColor'] ?? 0xFFFFFFFF)}, elevation: ${p['elevation'] ?? 4.0}, "
            "shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(${p['borderRadius'] ?? 12.0})), "
            "child: const SizedBox.expand())";
      case 'listtile':
        return "Material(child: ListTile("
            "leading: Icon(IconData(${p['iconCodePoint'] ?? 0xe7fd}, fontFamily: 'MaterialIcons')), "
            "title: Text('${_escape(p['title'] ?? '')}'), "
            "subtitle: Text('${_escape(p['subtitle'] ?? '')}')))";
      case 'divider':
        return "Divider(color: ${_colorLit(p['color'] ?? 0xFF9E9E9E)}, thickness: ${p['thickness'] ?? 1.0})";
      default:
        return 'const SizedBox.shrink()';
    }
  }

  String _positioned(CanvasElement e) {
    return 'Positioned(left: ${e.x}, top: ${e.y}, width: ${e.width}, height: ${e.height}, '
        'child: ${_widgetFor(e)}),';
  }

  /// Generiert den kompletten Inhalt einer `lib/main.dart`.
  String generateMainDart(Project project) {
    final children = project.elements.map(_positioned).join('\n            ');
    final bg = _colorLit(project.backgroundColor);
    final appName = _escape(project.name);

    return '''
// Automatisch generiert von Flutter Studio.
// Projekt: ${project.name}
// Dieses File ist eine vollständige, lauffähige Flutter-App.
import 'package:flutter/material.dart';

void main() {
  runApp(const GeneratedApp());
}

class GeneratedApp extends StatelessWidget {
  const GeneratedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$appName',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const GeneratedScreen(),
    );
  }
}

class GeneratedScreen extends StatelessWidget {
  const GeneratedScreen({super.key});

  static const double designWidth = ${CanvasElement.designWidth};
  static const double designHeight = ${CanvasElement.designHeight};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $bg,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double scale = (constraints.maxWidth / designWidth)
                  .clamp(0.0, constraints.maxHeight / designHeight)
                  .toDouble();
              return SizedBox(
                width: designWidth * scale,
                height: designHeight * scale,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: designWidth,
                    height: designHeight,
                    child: Stack(
                      children: [
            $children
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
''';
  }

  String generatePubspec(Project project) {
    final safeName = project.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final name = safeName.isEmpty ? 'generated_app' : safeName;
    return '''
name: $name
description: Mit Flutter Studio erstellte App.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6

flutter:
  uses-material-design: true
''';
  }
}
