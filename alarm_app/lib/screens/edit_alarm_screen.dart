import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import '../widgets/weekday_selector.dart';

/// Anlegen/Bearbeiten eines Alarms. Gibt bei "Speichern" das aktualisierte
/// [AlarmModel] zurück, bei "Löschen" ein [_DeleteResult].
class EditAlarmScreen extends StatefulWidget {
  const EditAlarmScreen({super.key, required this.alarm, this.isNew = false});

  final AlarmModel alarm;
  final bool isNew;

  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  late TimeOfDay _time;
  late TextEditingController _labelController;
  late Set<int> _repeatDays;
  late bool _headphonesOnly;

  @override
  void initState() {
    super.initState();
    _time = TimeOfDay(hour: widget.alarm.hour, minute: widget.alarm.minute);
    _labelController = TextEditingController(text: widget.alarm.label);
    _repeatDays = Set<int>.from(widget.alarm.repeatDays);
    _headphonesOnly = widget.alarm.headphonesOnly;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  void _save() {
    final updated = widget.alarm.copyWith(
      hour: _time.hour,
      minute: _time.minute,
      label: _labelController.text.trim(),
      repeatDays: _repeatDays,
      headphonesOnly: _headphonesOnly,
      enabled: true,
    );
    Navigator.of(context).pop(updated);
  }

  void _delete() {
    Navigator.of(context).pop(const _DeleteResult());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Neuer Wecker' : 'Wecker bearbeiten'),
        actions: [
          if (!widget.isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: TextButton(
              onPressed: _pickTime,
              child: Text(
                _time.format(context),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Bezeichnung',
              hintText: 'z. B. Aufstehen',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Wiederholung', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          WeekdaySelector(
            selectedDays: _repeatDays,
            onChanged: (days) => setState(() => _repeatDays = days),
          ),
          const SizedBox(height: 8),
          Text(
            _repeatDays.isEmpty
                ? 'Einmaliger Alarm'
                : 'Wiederholt sich an ${_repeatDays.length} Tag(en) pro Woche',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: 32),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Nur über Kopfhörer'),
            subtitle: const Text(
              'Wenn Kopfhörer/Bluetooth verbunden sind, klingelt der Wecker '
              'ausschließlich dort statt zusätzlich über den Lautsprecher. '
              'Ohne verbundene Kopfhörer läuft der Ton wie gewohnt über den '
              'Lautsprecher.',
            ),
            value: _headphonesOnly,
            onChanged: (value) => setState(() => _headphonesOnly = value),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Speichern'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteResult {
  const _DeleteResult();
}

/// Hilfsfunktion, um im Home-Screen zwischen "gespeichert" und "gelöscht"
/// zu unterscheiden, ohne einen weiteren Export nötig zu machen.
bool isDeleteResult(Object? result) => result is _DeleteResult;
