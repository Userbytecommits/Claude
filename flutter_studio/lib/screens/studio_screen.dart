import 'package:flutter/material.dart';
import '../models/canvas_element.dart';
import '../models/catalog.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../widgets/canvas_element_widget.dart';
import '../widgets/catalog_panel.dart';
import '../widgets/properties_panel.dart';
import 'export_screen.dart';
import 'preview_screen.dart';

/// Der eigentliche Editor: oben die freie Arbeitsfläche (Workspace),
/// unten wechselt der Bereich zwischen Widget-Katalog und den
/// erweiterten Einstellungen des gerade ausgewählten Elements.
class StudioScreen extends StatefulWidget {
  final Project project;

  const StudioScreen({super.key, required this.project});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  final _projectService = ProjectService();
  final _canvasKey = GlobalKey();
  late Project _project;
  String? _selectedId;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  CanvasElement? get _selected => _selectedId == null
      ? null
      : _project.elements.where((e) => e.id == _selectedId).firstOrNull;

  Future<void> _save({bool silent = false}) async {
    await _projectService.upsert(_project);
    setState(() => _dirty = false);
    if (!silent && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Projekt gespeichert'), duration: Duration(seconds: 1)));
    }
  }

  void _addElement(CatalogItem item, Offset localPosition) {
    final w = item.defaultWidth;
    final h = item.defaultHeight;
    double x = (localPosition.dx - w / 2)
        .clamp(0, CanvasElement.designWidth - w)
        .toDouble();
    double y = (localPosition.dy - h / 2)
        .clamp(0, CanvasElement.designHeight - h)
        .toDouble();
    final element = CanvasElement(
      id: _projectService.newId(),
      type: item.type,
      x: x,
      y: y,
      width: w,
      height: h,
      properties: item.defaultProperties(),
    );
    setState(() {
      _project.elements.add(element);
      _selectedId = element.id;
      _dirty = true;
    });
  }

  void _updateElement(CanvasElement updated) {
    setState(() {
      updated.width = updated.width.clamp(16, CanvasElement.designWidth).toDouble();
      updated.height = updated.height.clamp(16, CanvasElement.designHeight).toDouble();
      updated.x =
          updated.x.clamp(0, CanvasElement.designWidth - updated.width).toDouble();
      updated.y =
          updated.y.clamp(0, CanvasElement.designHeight - updated.height).toDouble();
      final idx = _project.elements.indexWhere((e) => e.id == updated.id);
      if (idx != -1) _project.elements[idx] = updated;
      _dirty = true;
    });
  }

  void _deleteSelected() {
    if (_selectedId == null) return;
    setState(() {
      _project.elements.removeWhere((e) => e.id == _selectedId);
      _selectedId = null;
      _dirty = true;
    });
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    await _save(silent: true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_project.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Zurück',
            onPressed: () async {
              await _confirmLeave();
              if (mounted) Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined),
              tooltip: 'Vorschau',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PreviewScreen(project: _project)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Exportieren / Builder',
              onPressed: () async {
                await _save(silent: true);
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ExportScreen(project: _project)),
                );
              },
            ),
            IconButton(
              icon: Icon(_dirty ? Icons.save : Icons.save_outlined),
              tooltip: 'Speichern',
              onPressed: () => _save(),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(flex: 3, child: _buildWorkspace()),
            const Divider(height: 1),
            Expanded(
              flex: 2,
              child: _selected == null
                  ? CatalogPanel(items: kCatalogItems)
                  : PropertiesPanel(
                      element: _selected!,
                      onChange: _updateElement,
                      onDelete: _deleteSelected,
                      onClose: () => setState(() => _selectedId = null),
                    ),
            ),
          ],
        ),
    );
  }

  Widget _buildWorkspace() {
    return Container(
      color: const Color(0xFFEFEFF4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scaleW = constraints.maxWidth / CanvasElement.designWidth;
          final scaleH = constraints.maxHeight / CanvasElement.designHeight;
          final scale = scaleW < scaleH ? scaleW : scaleH;

          return Center(
            child: DragTarget<CatalogItem>(
              onAcceptWithDetails: (details) {
                final box =
                    _canvasKey.currentContext!.findRenderObject() as RenderBox;
                final local = box.globalToLocal(details.offset);
                _addElement(details.data, local);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: CanvasElement.designWidth * scale,
                  height: CanvasElement.designHeight * scale,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selectedId = null),
                      child: Container(
                        key: _canvasKey,
                        width: CanvasElement.designWidth,
                        height: CanvasElement.designHeight,
                        color: Color(_project.backgroundColor),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: _project.elements.map((e) {
                            return CanvasElementWidget(
                              key: ValueKey(e.id),
                              element: e,
                              selected: e.id == _selectedId,
                              scale: scale == 0 ? 1.0 : scale,
                              onTap: () => setState(() => _selectedId = e.id),
                              onMove: (delta) => _updateElement(
                                  e.copyWith(x: e.x + delta.dx, y: e.y + delta.dy)),
                              onResize: (delta) => _updateElement(e.copyWith(
                                  width: e.width + delta.dx,
                                  height: e.height + delta.dy)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
