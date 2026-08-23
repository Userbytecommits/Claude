/// Ein einzelnes Widget-Element auf der Design-Fläche (Workspace).
///
/// Positionen/Größen beziehen sich immer auf ein virtuelles Design-Raster
/// von [designWidth] x [designHeight], damit Editor, Vorschau und der
/// exportierte, echte Flutter-Code exakt dasselbe Layout ergeben.
class CanvasElement {
  static const double designWidth = 360;
  static const double designHeight = 720;

  String id;
  String type;
  double x;
  double y;
  double width;
  double height;
  Map<String, dynamic> properties;

  CanvasElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};

  CanvasElement copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    Map<String, dynamic>? properties,
  }) {
    return CanvasElement(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      properties: properties ?? Map<String, dynamic>.from(this.properties),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'properties': properties,
      };

  factory CanvasElement.fromJson(Map<String, dynamic> json) {
    return CanvasElement(
      id: json['id'] as String,
      type: json['type'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      properties: Map<String, dynamic>.from(json['properties'] as Map),
    );
  }
}

/// Beschreibung eines Widget-Typs im Katalog: Anzeigename, Icon-Codepoint,
/// Default-Größe und Default-Eigenschaften für neu erstellte Elemente.
class CatalogItem {
  final String type;
  final String label;
  final String category;
  final int iconCodePoint;
  final double defaultWidth;
  final double defaultHeight;
  final Map<String, dynamic> Function() defaultProperties;

  const CatalogItem({
    required this.type,
    required this.label,
    required this.category,
    required this.iconCodePoint,
    required this.defaultWidth,
    required this.defaultHeight,
    required this.defaultProperties,
  });
}
