import 'package:flutter/material.dart';
import '../models/canvas_element.dart';
import 'element_renderer.dart';

/// Ein frei bewegliches und skalierbares Element auf der Arbeitsfläche.
/// Tippen wählt es aus, Ziehen verschiebt es, der Griff unten rechts
/// verändert die Größe. Im ausgewählten Zustand gibt es Schnellzugriffe
/// zum Duplizieren und Löschen direkt am Element.
class CanvasElementWidget extends StatelessWidget {
  final CanvasElement element;
  final bool selected;
  final double scale;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMove;
  final ValueChanged<Offset> onResize;
  final VoidCallback onInteractionStart;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const CanvasElementWidget({
    super.key,
    required this.element,
    required this.selected,
    required this.scale,
    required this.onTap,
    required this.onMove,
    required this.onResize,
    required this.onInteractionStart,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: element.x,
      top: element.y,
      width: element.width,
      height: element.height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onPanStart: (_) => onInteractionStart(),
        onPanUpdate: (details) => onMove(details.delta / scale),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.indigo : Colors.transparent,
              width: 2,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: element.width,
                      height: element.height,
                      child: ElementRenderer(element: element),
                    ),
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: GestureDetector(
                    onPanStart: (_) => onInteractionStart(),
                    onPanUpdate: (details) => onResize(details.delta / scale),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.open_in_full,
                          size: 13, color: Colors.white),
                    ),
                  ),
                ),
              if (selected)
                Positioned(
                  right: 0,
                  top: -34,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _quickButton(
                        icon: Icons.copy_rounded,
                        onTap: onDuplicate,
                      ),
                      const SizedBox(width: 6),
                      _quickButton(
                        icon: Icons.delete_outline,
                        onTap: onDelete,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.indigo,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}
