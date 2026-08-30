import 'package:flutter/material.dart';
import '../models/canvas_element.dart';
import '../models/catalog.dart';

/// Katalog aller verfügbaren Widgets, aus dem per Drag & Drop auf die
/// Arbeitsfläche gezogen werden kann. Bietet Suche und Kategorien, damit
/// man das gewünschte Widget auch bei vielen Optionen schnell findet.
class CatalogPanel extends StatefulWidget {
  final List<CatalogItem> items;

  const CatalogPanel({super.key, required this.items});

  @override
  State<CatalogPanel> createState() => _CatalogPanelState();
}

class _CatalogPanelState extends State<CatalogPanel> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      final matchesQuery =
          _query.isEmpty || item.label.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory = _category == null || item.category == _category;
      return matchesQuery && matchesCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Widget suchen...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _categoryChip(null, 'Alle'),
              const SizedBox(width: 6),
              for (final c in kCategories) ...[
                _categoryChip(c, c),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('Kein Widget gefunden',
                      style: TextStyle(color: Colors.black45)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
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

  Widget _categoryChip(String? value, String label) {
    final selected = _category == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => setState(() => _category = value),
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
