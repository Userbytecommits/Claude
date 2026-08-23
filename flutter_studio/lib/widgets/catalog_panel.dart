import 'package:flutter/material.dart';
import '../models/canvas_element.dart';

/// Katalog aller verfügbaren Widgets, aus dem per Drag & Drop auf die
/// Arbeitsfläche gezogen werden kann.
class CatalogPanel extends StatelessWidget {
  final List<CatalogItem> items;

  const CatalogPanel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Katalog — ziehe ein Widget in den Workspace',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Draggable<CatalogItem>(
                data: item,
                feedback: _CatalogChip(item: item, dragging: true),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: _CatalogChip(item: item),
                ),
                child: _CatalogChip(item: item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatalogChip extends StatelessWidget {
  final CatalogItem item;
  final bool dragging;

  const _CatalogChip({required this.item, this.dragging = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: dragging ? 76 : null,
        decoration: BoxDecoration(
          color: dragging ? Colors.indigo.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: dragging ? Colors.indigo : Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(IconData(item.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Colors.indigo),
            const SizedBox(height: 4),
            Text(item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
