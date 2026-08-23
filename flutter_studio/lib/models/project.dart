import 'canvas_element.dart';

class Project {
  String id;
  String name;
  String ownerEmail;
  DateTime createdAt;
  DateTime updatedAt;
  int backgroundColor;
  List<CanvasElement> elements;

  Project({
    required this.id,
    required this.name,
    required this.ownerEmail,
    required this.createdAt,
    required this.updatedAt,
    this.backgroundColor = 0xFFFFFFFF,
    List<CanvasElement>? elements,
  }) : elements = elements ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ownerEmail': ownerEmail,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'backgroundColor': backgroundColor,
        'elements': elements.map((e) => e.toJson()).toList(),
      };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerEmail: json['ownerEmail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      backgroundColor: json['backgroundColor'] as int? ?? 0xFFFFFFFF,
      elements: (json['elements'] as List)
          .map((e) => CanvasElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
