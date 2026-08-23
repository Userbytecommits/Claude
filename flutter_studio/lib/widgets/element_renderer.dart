import 'package:flutter/material.dart';
import '../models/canvas_element.dart';

/// Rendert ein [CanvasElement] als echtes Flutter-Widget. Wird identisch
/// vom Editor-Canvas und von der Vorschau verwendet, damit WYSIWYG gilt.
class ElementRenderer extends StatelessWidget {
  final CanvasElement element;

  const ElementRenderer({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final p = element.properties;
    switch (element.type) {
      case 'text':
        final align = p['textAlign'] == 'center'
            ? TextAlign.center
            : p['textAlign'] == 'right'
                ? TextAlign.right
                : TextAlign.left;
        return Text(
          (p['text'] ?? '') as String,
          textAlign: align,
          style: TextStyle(
            fontSize: (p['fontSize'] as num?)?.toDouble() ?? 16,
            fontWeight: p['bold'] == true ? FontWeight.bold : FontWeight.normal,
            fontStyle: p['italic'] == true ? FontStyle.italic : FontStyle.normal,
            color: Color(p['color'] as int? ?? 0xFF000000),
          ),
        );
      case 'button':
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(p['backgroundColor'] as int? ?? 0xFF3F51B5),
            foregroundColor: Color(p['color'] as int? ?? 0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular((p['borderRadius'] as num?)?.toDouble() ?? 12),
            ),
          ),
          child: Text(
            (p['text'] ?? 'Button') as String,
            style: TextStyle(fontSize: (p['fontSize'] as num?)?.toDouble() ?? 16),
          ),
        );
      case 'container':
        return Opacity(
          opacity: (p['opacity'] as num?)?.toDouble() ?? 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Color(p['backgroundColor'] as int? ?? 0xFFE0E0E0),
              borderRadius:
                  BorderRadius.circular((p['borderRadius'] as num?)?.toDouble() ?? 8),
              border: Border.all(
                color: Color(p['borderColor'] as int? ?? 0xFF000000),
                width: (p['borderWidth'] as num?)?.toDouble() ?? 0,
              ),
            ),
          ),
        );
      case 'image':
        final fit = p['fit'] == 'contain' ? BoxFit.contain : BoxFit.cover;
        return ClipRRect(
          borderRadius:
              BorderRadius.circular((p['borderRadius'] as num?)?.toDouble() ?? 8),
          child: Image.network(
            (p['imageUrl'] ?? '') as String,
            fit: fit,
            errorBuilder: (c, e, s) => Container(
              color: const Color(0xFFE0E0E0),
              child: const Icon(Icons.broken_image),
            ),
          ),
        );
      case 'icon':
        return Icon(
          IconData(p['iconCodePoint'] as int? ?? Icons.star.codePoint,
              fontFamily: 'MaterialIcons'),
          size: (p['size'] as num?)?.toDouble() ?? 40,
          color: Color(p['color'] as int? ?? 0xFF000000),
        );
      case 'textfield':
        return TextField(
          decoration: InputDecoration(
            hintText: (p['hint'] ?? '') as String,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular((p['borderRadius'] as num?)?.toDouble() ?? 8),
            ),
          ),
        );
      case 'switch':
        return Switch(
          value: p['value'] as bool? ?? true,
          activeColor: Color(p['activeColor'] as int? ?? 0xFF3F51B5),
          onChanged: (_) {},
        );
      case 'checkbox':
        return Checkbox(
          value: p['value'] as bool? ?? true,
          activeColor: Color(p['activeColor'] as int? ?? 0xFF3F51B5),
          onChanged: (_) {},
        );
      case 'slider':
        return Slider(
          value: (p['value'] as num?)?.toDouble() ?? 0.5,
          activeColor: Color(p['activeColor'] as int? ?? 0xFF3F51B5),
          onChanged: (_) {},
        );
      case 'card':
        return Card(
          color: Color(p['backgroundColor'] as int? ?? 0xFFFFFFFF),
          elevation: (p['elevation'] as num?)?.toDouble() ?? 4,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular((p['borderRadius'] as num?)?.toDouble() ?? 12),
          ),
          child: const SizedBox.expand(),
        );
      case 'listtile':
        return Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(IconData(p['iconCodePoint'] as int? ?? Icons.person.codePoint,
                fontFamily: 'MaterialIcons')),
            title: Text((p['title'] ?? '') as String),
            subtitle: Text((p['subtitle'] ?? '') as String),
          ),
        );
      case 'divider':
        return Divider(
          color: Color(p['color'] as int? ?? 0xFF9E9E9E),
          thickness: (p['thickness'] as num?)?.toDouble() ?? 1,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
