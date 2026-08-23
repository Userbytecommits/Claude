import 'package:flutter/material.dart';
import '../models/canvas_element.dart';
import 'element_renderer.dart';

/// Ein frei bewegliches und skalierbares Element auf der Arbeitsfläche.
/// Tippen wählt es aus, Ziehen verschiebt es, der Griff unten rechts
/// verändert die Größe.
class CanvasElementWidget extends StatelessWidget {
  final CanvasElement element;
  final bool selected;
  final double scale;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMove;
  final ValueChanged<Offset> onResize;

  const CanvasElementWidget({
    super.key,
    required this.element,
    required this.selected,
    required this.scale,
    required this.onTap,
    required this.onMove,
    required this.onResize,
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
                    onPanUpdate: (details) => onResize(details.delta / scale),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.open_in_full,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
