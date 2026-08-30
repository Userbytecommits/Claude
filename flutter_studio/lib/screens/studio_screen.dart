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

/// Der eigentliche Editor: oben die freie Arbeitsfläche (Workspace) mit
/// Zoom/Pan per Fingergeste, unten wechselt der Bereich zwischen
/// Widget-Katalog und den erweiterten Einstellungen des gerade
/// ausgewählten Elements. Enthält Undo/Redo, Snap-to-Grid, Ebenen-Liste
/// und Schnellaktionen (Duplizieren, Anordnen) für ein flüssigeres,
/// einfacheres Bauen.
class StudioScreen extends StatefulWidget {
  final Project project;

  const StudioScreen({super.key, required this.project});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  static const double _gridSize = 20;

  final _projectService = ProjectService();
  final _canvasKey = GlobalKey();
  final _transformController = TransformationController();
  late Project _project;
  String? _selectedId;
  bool _dirty = false;
  bool _snapEnabled = true;

  final List<List<Map<String, dynamic>>> _undoStack = [];
  final List<List<Map<String, dynamic>>> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  CanvasElement? get _selected => _selectedId == null
      ? null
      : _project.elements.where((e) => e.id == _selectedId).firstOrNull;

  // ---------- Undo / Redo ----------

  List<Map<String, dynamic>> _snapshot() =>
      _project.elements.map((e) => e.toJson()).toList();

  void _restore(List<Map<String, dynamic>> snap) {
    _project.elements = snap.map((j) => CanvasElement.fromJson(j)).toList();
  }

  void _pushHistory() {
    _undoStack.add(_snapshot());
    if (_undoStack.length > 50) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _redoStack.add(_snapshot());
      _restore(_undoStack.removeLast());
      _selectedId = null;
      _dirty = true;
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _undoStack.add(_snapshot());
      _restore(_redoStack.removeLast());
      _selectedId = null;
      _dirty = true;
    });
  }

  // ---------- Persistenz ----------

  Future<void> _save({bool silent = false}) async {
    await _projectService.upsert(_project);
    setState(() => _dirty = false);
    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Projekt gespeichert'), duration: Duration(seconds: 1)));
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    await _save(silent: true);
    return true;
  }

  // ---------- Element-Mutationen ----------

  double _clampSnap(double v, double lower, double upper) {
    final clamped = v.clamp(lower, upper).toDouble();
    if (!_snapEnabled) return clamped;
    final snapped = (clamped / _gridSize).round() * _gridSize;
    return snapped.toDouble().clamp(lower, upper).toDouble();
  }

  void _addElement(CatalogItem item, Offset localPosition) {
    final w = item.defaultWidth;
    final h = item.defaultHeight;
    final x = _clampSnap(localPosition.dx - w / 2, 0, CanvasElement.designWidth - w);
    final y = _clampSnap(localPosition.dy - h / 2, 0, CanvasElement.designHeight - h);
    final element = CanvasElement(
      id: _projectService.newId(),
      type: item.type,
      x: x,
      y: y,
      width: w,
      height: h,
      properties: item.defaultProperties(),
    );
    _pushHistory();
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
      updated.x = _clampSnap(updated.x, 0, CanvasElement.designWidth - updated.width);
      updated.y = _clampSnap(updated.y, 0, CanvasElement.designHeight - updated.height);
      final idx = _project.elements.indexWhere((e) => e.id == updated.id);
      if (idx != -1) _project.elements[idx] = updated;
      _dirty = true;
    });
  }

  void _deleteSelected() {
    if (_selectedId == null) return;
    _pushHistory();
    setState(() {
      _project.elements.removeWhere((e) => e.id == _selectedId);
      _selectedId = null;
      _dirty = true;
    });
  }

  void _deleteElement(String id) {
    _pushHistory();
    setState(() {
      _project.elements.removeWhere((e) => e.id == id);
      if (_selectedId == id) _selectedId = null;
      _dirty = true;
    });
  }

  void _duplicateSelected() {
    final e = _selected;
    if (e == null) return;
    _pushHistory();
    final copy = CanvasElement(
      id: _projectService.newId(),
      type: e.type,
      x: (e.x + 16).clamp(0, CanvasElement.designWidth - e.width).toDouble(),
      y: (e.y + 16).clamp(0, CanvasElement.designHeight - e.height).toDouble(),
      width: e.width,
      height: e.height,
      properties: Map<String, dynamic>.from(e.properties),
    );
    setState(() {
      _project.elements.add(copy);
      _selectedId = copy.id;
      _dirty = true;
    });
  }

  void _bringToFront() {
    final id = _selectedId;
    if (id == null) return;
    _pushHistory();
    setState(() {
      final idx = _project.elements.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final e = _project.elements.removeAt(idx);
        _project.elements.add(e);
      }
      _dirty = true;
    });
  }

  void _sendToBack() {
    final id = _selectedId;
    if (id == null) return;
    _pushHistory();
    setState(() {
      final idx = _project.elements.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final e = _project.elements.removeAt(idx);
        _project.elements.insert(0, e);
      }
      _dirty = true;
    });
  }

  void _reorderLayers(int oldIndex, int newIndex) {
    _pushHistory();
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final e = _project.elements.removeAt(oldIndex);
      _project.elements.insert(newIndex, e);
      _dirty = true;
    });
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  void _openLayers() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final items = _project.elements;
            return SizedBox(
              height: 420,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Ebenen (unten = ganz hinten)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(child: Text('Keine Elemente'))
                        : ReorderableListView.builder(
                            itemCount: items.length,
                            onReorder: (oldIndex, newIndex) {
                              _reorderLayers(oldIndex, newIndex);
                              setSheetState(() {});
                            },
                            itemBuilder: (context, index) {
                              final e = items[items.length - 1 - index];
                              return ListTile(
                                key: ValueKey(e.id),
                                leading: Icon(
                                    IconData(catalogItemFor(e.type).iconCodePoint,
                                        fontFamily: 'MaterialIcons')),
                                title: Text(catalogItemFor(e.type).label),
                                selected: e.id == _selectedId,
                                onTap: () {
                                  setState(() => _selectedId = e.id);
                                  Navigator.pop(context);
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    _deleteElement(e.id);
                                    setSheetState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------- UI ----------

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
          _buildToolbar(),
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
                    onDuplicate: _duplicateSelected,
                    onBringToFront: _bringToFront,
                    onSendToBack: _sendToBack,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Rückgängig',
            onPressed: _undoStack.isEmpty ? null : _undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Wiederholen',
            onPressed: _redoStack.isEmpty ? null : _redo,
          ),
          const VerticalDivider(width: 8),
          IconButton(
            icon: Icon(_snapEnabled ? Icons.grid_on : Icons.grid_off),
            tooltip: 'Am Raster ausrichten',
            onPressed: () => setState(() => _snapEnabled = !_snapEnabled),
          ),
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Ebenen',
            onPressed: _openLayers,
          ),
          const Spacer(),
          Text('${_project.elements.length} Elemente',
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Zoom zurücksetzen',
            onPressed: _resetZoom,
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

          return DragTarget<CatalogItem>(
            onAcceptWithDetails: (details) {
              final box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
              final local = box.globalToLocal(details.offset);
              _addElement(details.data, local);
            },
            builder: (context, candidateData, rejectedData) {
              return InteractiveViewer(
                transformationController: _transformController,
                minScale: 1,
                maxScale: 5,
                boundaryMargin: const EdgeInsets.all(60),
                child: Center(
                  child: Container(
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
                            children: [
                              if (_snapEnabled)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _GridPainter(gridSize: _gridSize),
                                    ),
                                  ),
                                ),
                              if (_project.elements.isEmpty)
                                const Positioned.fill(
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Text(
                                          'Ziehe ein Widget aus dem Katalog\nhierher, um zu starten',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black38, fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ..._project.elements.map((e) {
                                return CanvasElementWidget(
                                  key: ValueKey(e.id),
                                  element: e,
                                  selected: e.id == _selectedId,
                                  scale: scale == 0 ? 1.0 : scale,
                                  onTap: () => setState(() => _selectedId = e.id),
                                  onInteractionStart: () {
                                    _pushHistory();
                                    if (_selectedId != e.id) {
                                      setState(() => _selectedId = e.id);
                                    }
                                  },
                                  onMove: (delta) => _updateElement(
                                      e.copyWith(x: e.x + delta.dx, y: e.y + delta.dy)),
                                  onResize: (delta) => _updateElement(e.copyWith(
                                      width: e.width + delta.dx,
                                      height: e.height + delta.dy)),
                                  onDuplicate: () {
                                    _selectedId = e.id;
                                    _duplicateSelected();
                                  },
                                  onDelete: () => _deleteElement(e.id),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double gridSize;

  _GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
