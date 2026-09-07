import 'package:flutter/material.dart';

import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: AnimatedBuilder(
        animation: ThemeService.instance,
        builder: (context, _) {
          final mode = ThemeService.instance.mode;
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  'Erscheinungsbild',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                subtitle: const Text('Folgt der Handy-Einstellung'),
                value: ThemeMode.system,
                groupValue: mode,
                onChanged: (value) => ThemeService.instance.setMode(value!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Hell'),
                value: ThemeMode.light,
                groupValue: mode,
                onChanged: (value) => ThemeService.instance.setMode(value!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dunkel'),
                value: ThemeMode.dark,
                groupValue: mode,
                onChanged: (value) => ThemeService.instance.setMode(value!),
              ),
            ],
          );
        },
      ),
    );
  }
}
