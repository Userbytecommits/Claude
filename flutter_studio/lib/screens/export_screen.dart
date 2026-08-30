import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/project.dart';
import '../services/code_generator.dart';

/// "Builder": erzeugt aus dem Projekt eine echte, kompilierbare
/// Flutter-App (main.dart + pubspec.yaml) zum Kopieren oder Speichern.
class ExportScreen extends StatefulWidget {
  final Project project;

  const ExportScreen({super.key, required this.project});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _generator = CodeGenerator();
  String? _savedPath;

  late final String _mainDart;
  late final String _pubspec;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mainDart = _generator.generateMainDart(widget.project);
    _pubspec = _generator.generatePubspec(widget.project);
  }

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label in Zwischenablage kopiert')));
  }

  Future<void> _saveToDevice() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final projectDir = Directory(
          '${dir.path}/flutter_studio_export/${_sanitize(widget.project.name)}/lib');
      await projectDir.create(recursive: true);
      await File('${projectDir.path}/main.dart').writeAsString(_mainDart);
      await File('${projectDir.parent.path}/pubspec.yaml').writeAsString(_pubspec);
      setState(() => _savedPath = projectDir.parent.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Projekt gespeichert unter: ${projectDir.parent.path}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Speichern fehlgeschlagen: $e')));
    }
  }

  String _sanitize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Builder'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'main.dart'),
            Tab(text: 'pubspec.yaml'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dieser Code ist eine vollständige, echte Flutter-App. '
                  'Speichere ihn, füge ihn in ein `flutter create`-Projekt ein '
                  'und baue mit `flutter build apk` / `flutter run` eine echte App. '
                  'Enthält das Projekt Icons, ggf. mit '
                  '`flutter build apk --no-tree-shake-icons` bauen.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _saveToDevice,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Projekt auf Gerät speichern'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copy(_mainDart, 'main.dart'),
                      icon: const Icon(Icons.copy),
                      label: const Text('main.dart kopieren'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copy(_pubspec, 'pubspec.yaml'),
                      icon: const Icon(Icons.copy),
                      label: const Text('pubspec.yaml kopieren'),
                    ),
                  ],
                ),
                if (_savedPath != null) ...[
                  const SizedBox(height: 8),
                  Text('Gespeichert: $_savedPath',
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _codeView(_mainDart),
                _codeView(_pubspec),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeView(String code) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          code,
          style: const TextStyle(
              fontFamily: 'monospace', fontSize: 12, color: Color(0xFFD4D4D4)),
        ),
      ),
    );
  }
}
