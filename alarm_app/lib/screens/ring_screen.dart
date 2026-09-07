import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

/// Vollbild-Anzeige, während ein Alarm klingelt.
class RingScreen extends StatelessWidget {
  const RingScreen({super.key, required this.alarmSettings});

  final AlarmSettings alarmSettings;

  @override
  Widget build(BuildContext context) {
    final title = alarmSettings.notificationSettings.title;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm, size: 96, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (alarmSettings.androidSnoozeDuration != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        // Kein eigenständiges Alarm.snooze() in diesem Plugin:
                        // Alarm stoppen und mit neuer Zeit neu registrieren.
                        final snoozeUntil = DateTime.now()
                            .add(alarmSettings.androidSnoozeDuration!);
                        await Alarm.stop(alarmSettings.id);
                        await Alarm.set(
                          alarmSettings: alarmSettings.copyWith(
                            dateTime: snoozeUntil,
                          ),
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text('Schlummern (9 Min.)'),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    await Alarm.stop(alarmSettings.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Stopp', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
