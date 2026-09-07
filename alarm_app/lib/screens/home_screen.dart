import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import '../services/alarm_repository.dart';
import 'edit_alarm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = AlarmRepository.instance;
  List<AlarmModel> _alarms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final alarms = await _repo.loadAlarms();
    setState(() {
      _alarms = alarms;
      _loading = false;
    });
  }

  Future<void> _persistAndReschedule() async {
    await _repo.saveAlarms(_alarms);
    await _repo.rescheduleAll(_alarms);
  }

  Future<void> _addAlarm() async {
    final now = TimeOfDay.now();
    final newAlarm = AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      hour: now.hour,
      minute: now.minute,
    );
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => EditAlarmScreen(alarm: newAlarm, isNew: true),
      ),
    );
    if (result is AlarmModel) {
      setState(() => _alarms.add(result));
      await _persistAndReschedule();
      setState(() {});
    }
  }

  Future<void> _editAlarm(AlarmModel alarm) async {
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(builder: (_) => EditAlarmScreen(alarm: alarm)),
    );
    if (result == null) return;
    if (isDeleteResult(result)) {
      await _repo.cancelAlarm(alarm.id);
      setState(() => _alarms.removeWhere((a) => a.id == alarm.id));
      await _repo.saveAlarms(_alarms);
      return;
    }
    if (result is AlarmModel) {
      setState(() {
        final index = _alarms.indexWhere((a) => a.id == alarm.id);
        _alarms[index] = result;
      });
      await _persistAndReschedule();
    }
  }

  Future<void> _toggleEnabled(AlarmModel alarm, bool value) async {
    setState(() => alarm.enabled = value);
    await _persistAndReschedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wecker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _alarms.isEmpty
              ? const Center(child: Text('Noch kein Wecker eingerichtet.'))
              : ListView.separated(
                  itemCount: _alarms.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final alarm = _alarms[index];
                    final time =
                        '${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}';
                    return ListTile(
                      onTap: () => _editAlarm(alarm),
                      title: Text(time, style: const TextStyle(fontSize: 28)),
                      subtitle: Text([
                        if (alarm.label.isNotEmpty) alarm.label,
                        alarm.isRepeating ? 'Wiederholt' : 'Einmalig',
                        if (alarm.headphonesOnly) 'Nur Kopfhörer',
                      ].join(' · ')),
                      trailing: Switch(
                        value: alarm.enabled,
                        onChanged: (value) => _toggleEnabled(alarm, value),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
