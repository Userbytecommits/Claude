import 'package:flutter/material.dart';
import '../models/canvas_element.dart';
import '../models/project.dart';
import '../widgets/element_renderer.dart';

/// Vollbild-Vorschau: rendert das Projekt exakt so, wie die exportierte
/// App später aussehen wird — ohne Editier-Rahmen oder Griffe.
class PreviewScreen extends StatelessWidget {
  final Project project;

  const PreviewScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vorschau — ${project.name}')),
      backgroundColor: Color(project.backgroundColor),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double scale = (constraints.maxWidth / CanvasElement.designWidth)
                  .clamp(0.0, constraints.maxHeight / CanvasElement.designHeight)
                  .toDouble();
              return SizedBox(
                width: CanvasElement.designWidth * scale,
                height: CanvasElement.designHeight * scale,
                child: Transform.scale(
                  scale: scale == 0 ? 1.0 : scale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: CanvasElement.designWidth,
                    height: CanvasElement.designHeight,
                    child: Stack(
                      children: project.elements
                          .map((e) => Positioned(
                                left: e.x,
                                top: e.y,
                                width: e.width,
                                height: e.height,
                                child: ElementRenderer(element: e),
                              ))
                          .toList(),
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
