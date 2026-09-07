import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm_model.dart';

/// Verwaltet die persistierte Liste von [AlarmModel]s und hält die
/// tatsächlich beim `alarm`-Plugin registrierten Alarme synchron.
class AlarmRepository {
  AlarmRepository._();
  static final AlarmRepository instance = AlarmRepository._();

  static const _storageKey = 'alarms_v1';

  Future<List<AlarmModel>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => AlarmModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
  }

  Future<void> saveAlarms(List<AlarmModel> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(alarms.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  /// Berechnet den nächsten Zeitpunkt, an dem dieser Alarm klingeln soll.
  DateTime nextOccurrence(AlarmModel alarm, {DateTime? from}) {
    final now = from ?? DateTime.now();
    var candidate =
        DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);

    if (!alarm.isRepeating) {
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }

    for (var i = 0; i < 8; i++) {
      final day = candidate.add(Duration(days: i));
      final weekday = day.weekday; // 1 = Montag ... 7 = Sonntag
      final isToday = i == 0;
      if (alarm.repeatDays.contains(weekday) &&
          (!isToday || day.isAfter(now))) {
        return DateTime(day.year, day.month, day.day, alarm.hour, alarm.minute);
      }
    }
    // Fallback, sollte nie erreicht werden.
    return candidate.add(const Duration(days: 1));
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.enabled) {
      await Alarm.stop(alarm.id);
      return;
    }
    final dateTime = nextOccurrence(alarm);
    final settings = AlarmSettings(
      id: alarm.id,
      dateTime: dateTime,
      assetAudioPath: 'assets/alarm.wav',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      allowAlarmOverlap: false,
      androidStopAlarmOnTermination: false,
      // Kernstück der gewünschten Funktion: Ton geht bevorzugt an
      // verbundene Kopfhörer/Bluetooth, nicht zusätzlich an den Lautsprecher.
      preferConnectedAudioDevice: alarm.headphonesOnly,
      androidSnoozeDuration: Duration(minutes: alarm.snoozeMinutes),
      notificationSettings: NotificationSettings(
        title: alarm.label.isEmpty ? 'Wecker' : alarm.label,
        body: 'Alarm um '
            '${alarm.hour.toString().padLeft(2, '0')}:'
            '${alarm.minute.toString().padLeft(2, '0')} Uhr',
        stopButton: 'Stopp',
        androidSnoozeButton: 'Schlummern',
      ),
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 5),
        volumeEnforced: true,
      ),
    );
    await Alarm.set(alarmSettings: settings);
  }

  /// Zeitpunkt des nächsten aktiven Alarms aus der Liste, oder `null` wenn
  /// keiner aktiviert ist.
  DateTime? nextActiveOccurrence(List<AlarmModel> alarms) {
    DateTime? earliest;
    for (final alarm in alarms.where((a) => a.enabled)) {
      final occurrence = nextOccurrence(alarm);
      if (earliest == null || occurrence.isBefore(earliest)) {
        earliest = occurrence;
      }
    }
    return earliest;
  }

  Future<void> cancelAlarm(int id) => Alarm.stop(id);

  Future<void> rescheduleAll(List<AlarmModel> alarms) async {
    for (final alarm in alarms) {
      if (alarm.enabled) {
        await scheduleAlarm(alarm);
      } else {
        await cancelAlarm(alarm.id);
      }
    }
  }
}
