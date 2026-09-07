import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vollbild-Anzeige, während ein Alarm klingelt.
class RingScreen extends StatefulWidget {
  const RingScreen({super.key, required this.alarmSettings});

  final AlarmSettings alarmSettings;

  @override
  State<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alarmSettings = widget.alarmSettings;
    final title = alarmSettings.notificationSettings.title;
    final snoozeDuration = alarmSettings.androidSnoozeDuration;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulse,
                child: const Icon(Icons.alarm, size: 96, color: Colors.white),
              ),
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
              if (snoozeDuration != null)
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
                        HapticFeedback.mediumImpact();
                        // Kein eigenständiges Alarm.snooze() in diesem Plugin:
                        // Alarm stoppen und mit neuer Zeit neu registrieren.
                        final snoozeUntil = DateTime.now().add(snoozeDuration);
                        await Alarm.stop(alarmSettings.id);
                        await Alarm.set(
                          alarmSettings: alarmSettings.copyWith(
                            dateTime: snoozeUntil,
                          ),
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: Text(
                        'Schlummern (${snoozeDuration.inMinutes} Min.)',
                      ),
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
                    HapticFeedback.mediumImpact();
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
