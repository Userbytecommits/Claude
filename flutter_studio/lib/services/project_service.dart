import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

class ProjectService {
  static const _projectsKey = 'fs_projects_v1';

  String newId() {
    final rnd = Random();
    return '${DateTime.now().microsecondsSinceEpoch}_${rnd.nextInt(999999)}';
  }

  Future<List<Project>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_projectsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Project>> loadForUser(String email) async {
    final all = await loadAll();
    return all.where((p) => p.ownerEmail == email).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _saveAll(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, raw);
  }

  Future<void> upsert(Project project) async {
    final all = await loadAll();
    final idx = all.indexWhere((p) => p.id == project.id);
    project.updatedAt = DateTime.now();
    if (idx == -1) {
      all.add(project);
    } else {
      all[idx] = project;
    }
    await _saveAll(all);
  }

  Future<void> delete(String projectId) async {
    final all = await loadAll();
    all.removeWhere((p) => p.id == projectId);
    await _saveAll(all);
  }
}
