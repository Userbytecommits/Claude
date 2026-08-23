import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/auth_service.dart';
import '../services/project_service.dart';
import 'login_screen.dart';
import 'studio_screen.dart';

class ProjectsScreen extends StatefulWidget {
  final String userEmail;

  const ProjectsScreen({super.key, required this.userEmail});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _projectService = ProjectService();
  final _auth = AuthService();
  List<Project> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final projects = await _projectService.loadForUser(widget.userEmail);
    setState(() {
      _projects = projects;
      _loading = false;
    });
  }

  Future<void> _createProject() async {
    final name = await _promptName('Neues Projekt', 'Mein Projekt');
    if (name == null || name.trim().isEmpty) return;
    final now = DateTime.now();
    final project = Project(
      id: _projectService.newId(),
      name: name.trim(),
      ownerEmail: widget.userEmail,
      createdAt: now,
      updatedAt: now,
    );
    await _projectService.upsert(project);
    await _refresh();
    if (!mounted) return;
    _openStudio(project);
  }

  Future<void> _rename(Project project) async {
    final name = await _promptName('Projekt umbenennen', project.name);
    if (name == null || name.trim().isEmpty) return;
    project.name = name.trim();
    await _projectService.upsert(project);
    await _refresh();
  }

  Future<String?> _promptName(String title, String initial) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Projektname'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _delete(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Projekt löschen?'),
        content: Text('"${project.name}" wird endgültig gelöscht.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Löschen')),
        ],
      ),
    );
    if (confirmed == true) {
      await _projectService.delete(project.id);
      await _refresh();
    }
  }

  void _openStudio(Project project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StudioScreen(project: project)),
    );
    _refresh();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projekte — ${widget.userEmail}'),
        actions: [
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Abmelden'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: Colors.black26),
                      const SizedBox(height: 12),
                      const Text('Noch keine Projekte'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _createProject,
                        icon: const Icon(Icons.add),
                        label: const Text('Neues Projekt'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final p = _projects[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.phone_android)),
                        title: Text(p.name),
                        subtitle: Text(
                            '${p.elements.length} Elemente · aktualisiert ${_formatDate(p.updatedAt)}'),
                        onTap: () => _openStudio(p),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'rename') _rename(p);
                            if (value == 'delete') _delete(p);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'rename', child: Text('Umbenennen')),
                            PopupMenuItem(value: 'delete', child: Text('Löschen')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProject,
        icon: const Icon(Icons.add),
        label: const Text('Neu'),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
