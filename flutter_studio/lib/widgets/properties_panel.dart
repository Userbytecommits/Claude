import 'package:flutter/material.dart';
import '../models/canvas_element.dart';

const List<int> kPalette = [
  0xFF000000,
  0xFFFFFFFF,
  0xFFF44336,
  0xFFE91E63,
  0xFF9C27B0,
  0xFF3F51B5,
  0xFF2196F3,
  0xFF03A9F4,
  0xFF009688,
  0xFF4CAF50,
  0xFF8BC34A,
  0xFFFFEB3B,
  0xFFFFC107,
  0xFFFF9800,
  0xFF795548,
  0xFF9E9E9E,
];

/// Erweiterte Einstellungen für das aktuell ausgewählte Element:
/// Position, Größe, Form/Style und typ-spezifische Eigenschaften.
class PropertiesPanel extends StatelessWidget {
  final CanvasElement element;
  final ValueChanged<CanvasElement> onChange;
  final VoidCallback onDelete;
  final VoidCallback onClose;
  final VoidCallback onDuplicate;
  final VoidCallback onBringToFront;
  final VoidCallback onSendToBack;

  const PropertiesPanel({
    super.key,
    required this.element,
    required this.onChange,
    required this.onDelete,
    required this.onClose,
    required this.onDuplicate,
    required this.onBringToFront,
    required this.onSendToBack,
  });

  void _setProp(String key, dynamic value) {
    final props = Map<String, dynamic>.from(element.properties);
    props[key] = value;
    onChange(element.copyWith(properties: props));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Zurück zum Katalog',
                onPressed: onClose,
              ),
              Expanded(
                child: Text('Einstellungen: ${element.type}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Duplizieren',
                onPressed: onDuplicate,
              ),
              IconButton(
                icon: const Icon(Icons.flip_to_front),
                tooltip: 'Nach vorne',
                onPressed: onBringToFront,
              ),
              IconButton(
                icon: const Icon(Icons.flip_to_back),
                tooltip: 'Nach hinten',
                onPressed: onSendToBack,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Löschen',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _sectionTitle('Position & Größe'),
              _numberField('X', element.x, (v) => onChange(element.copyWith(x: v))),
              _numberField('Y', element.y, (v) => onChange(element.copyWith(y: v))),
              _numberField(
                  'Breite', element.width, (v) => onChange(element.copyWith(width: v))),
              _numberField('Höhe', element.height,
                  (v) => onChange(element.copyWith(height: v))),
              const Divider(height: 24),
              _sectionTitle('Form & Style'),
              ..._typeSpecificFields(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      );

  Widget _numberField(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label)),
          Expanded(
            child: Slider(
              value: value.clamp(0, 800).toDouble(),
              min: 0,
              max: 800,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(value.round().toString(), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _doubleProp(String label, String key, double value,
      {double min = 0, double max = 100}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: Slider(
              value: value.clamp(min, max).toDouble(),
              min: min,
              max: max,
              onChanged: (v) => _setProp(key, v),
            ),
          ),
          SizedBox(width: 44, child: Text(value.toStringAsFixed(1))),
        ],
      ),
    );
  }

  Widget _textProp(String label, String key, String value) {
    final controller = TextEditingController(text: value);
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
        onChanged: (v) => _setProp(key, v),
      ),
    );
  }

  Widget _boolProp(String label, String key, bool value) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: (v) => _setProp(key, v),
    );
  }

  Widget _colorProp(String label, String key, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kPalette.map((c) {
              final selected = c == value;
              return GestureDetector(
                onTap: () => _setProp(key, c),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.indigo : Colors.grey.shade400,
                      width: selected ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _alignProp(String label, String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'left', icon: Icon(Icons.format_align_left)),
                ButtonSegment(value: 'center', icon: Icon(Icons.format_align_center)),
                ButtonSegment(value: 'right', icon: Icon(Icons.format_align_right)),
              ],
              selected: {value},
              onSelectionChanged: (s) => _setProp(key, s.first),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _typeSpecificFields() {
    final p = element.properties;
    switch (element.type) {
      case 'text':
        return [
          _textProp('Text', 'text', p['text'] ?? ''),
          _doubleProp('Schriftgröße', 'fontSize', (p['fontSize'] as num?)?.toDouble() ?? 16,
              min: 8, max: 72),
          _boolProp('Fett', 'bold', p['bold'] == true),
          _boolProp('Kursiv', 'italic', p['italic'] == true),
          _alignProp('Ausrichtung', 'textAlign', p['textAlign'] ?? 'left'),
          _colorProp('Farbe', 'color', p['color'] ?? 0xFF000000),
        ];
      case 'button':
        return [
          _textProp('Beschriftung', 'text', p['text'] ?? ''),
          _doubleProp('Schriftgröße', 'fontSize', (p['fontSize'] as num?)?.toDouble() ?? 16,
              min: 8, max: 40),
          _doubleProp('Eckenradius', 'borderRadius',
              (p['borderRadius'] as num?)?.toDouble() ?? 12,
              min: 0, max: 48),
          _colorProp('Hintergrund', 'backgroundColor', p['backgroundColor'] ?? 0xFF3F51B5),
          _colorProp('Textfarbe', 'color', p['color'] ?? 0xFFFFFFFF),
        ];
      case 'container':
        return [
          _doubleProp('Eckenradius', 'borderRadius',
              (p['borderRadius'] as num?)?.toDouble() ?? 8,
              min: 0, max: 60),
          _doubleProp('Rahmenbreite', 'borderWidth',
              (p['borderWidth'] as num?)?.toDouble() ?? 0,
              min: 0, max: 12),
          _doubleProp('Deckkraft', 'opacity', (p['opacity'] as num?)?.toDouble() ?? 1,
              min: 0, max: 1),
          _colorProp('Hintergrund', 'backgroundColor', p['backgroundColor'] ?? 0xFFE0E0E0),
          _colorProp('Rahmenfarbe', 'borderColor', p['borderColor'] ?? 0xFF000000),
        ];
      case 'image':
        return [
          _textProp('Bild-URL', 'imageUrl', p['imageUrl'] ?? ''),
          _doubleProp('Eckenradius', 'borderRadius',
              (p['borderRadius'] as num?)?.toDouble() ?? 8,
              min: 0, max: 60),
        ];
      case 'icon':
        return [
          _doubleProp('Größe', 'size', (p['size'] as num?)?.toDouble() ?? 40,
              min: 8, max: 120),
          _colorProp('Farbe', 'color', p['color'] ?? 0xFF000000),
        ];
      case 'textfield':
        return [
          _textProp('Platzhalter', 'hint', p['hint'] ?? ''),
          _doubleProp('Eckenradius', 'borderRadius',
              (p['borderRadius'] as num?)?.toDouble() ?? 8,
              min: 0, max: 30),
        ];
      case 'switch':
      case 'checkbox':
        return [
          _boolProp('Aktiv', 'value', p['value'] == true),
          _colorProp('Akzentfarbe', 'activeColor', p['activeColor'] ?? 0xFF3F51B5),
        ];
      case 'slider':
        return [
          _doubleProp('Wert', 'value', (p['value'] as num?)?.toDouble() ?? 0.5,
              min: 0, max: 1),
          _colorProp('Akzentfarbe', 'activeColor', p['activeColor'] ?? 0xFF3F51B5),
        ];
      case 'card':
        return [
          _doubleProp('Eckenradius', 'borderRadius',
              (p['borderRadius'] as num?)?.toDouble() ?? 12,
              min: 0, max: 40),
          _doubleProp('Schatten', 'elevation', (p['elevation'] as num?)?.toDouble() ?? 4,
              min: 0, max: 24),
          _colorProp('Hintergrund', 'backgroundColor', p['backgroundColor'] ?? 0xFFFFFFFF),
        ];
      case 'listtile':
        return [
          _textProp('Titel', 'title', p['title'] ?? ''),
          _textProp('Untertitel', 'subtitle', p['subtitle'] ?? ''),
        ];
      case 'divider':
        return [
          _doubleProp('Dicke', 'thickness', (p['thickness'] as num?)?.toDouble() ?? 1,
              min: 1, max: 12),
          _colorProp('Farbe', 'color', p['color'] ?? 0xFF9E9E9E),
        ];
      default:
        return const [];
    }
  }
}
