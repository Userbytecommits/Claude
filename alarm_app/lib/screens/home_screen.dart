import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/alarm_model.dart';
import '../services/alarm_repository.dart';
import 'edit_alarm_screen.dart';
import 'settings_screen.dart';

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
      HapticFeedback.mediumImpact();
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
      await _deleteAlarm(alarm);
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

  Future<void> _deleteAlarm(AlarmModel alarm) async {
    final index = _alarms.indexOf(alarm);
    await _repo.cancelAlarm(alarm.id);
    setState(() => _alarms.removeWhere((a) => a.id == alarm.id));
    await _repo.saveAlarms(_alarms);
    HapticFeedback.mediumImpact();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alarm.label.isEmpty ? 'Wecker gelöscht' : '"${alarm.label}" gelöscht',
        ),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () async {
            setState(() {
              _alarms.insert(index.clamp(0, _alarms.length), alarm);
            });
            await _persistAndReschedule();
          },
        ),
      ),
    );
  }

  Future<void> _toggleEnabled(AlarmModel alarm, bool value) async {
    HapticFeedback.selectionClick();
    setState(() => alarm.enabled = value);
    await _persistAndReschedule();
  }

  String _formatNextAlarm(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours <= 0 && minutes <= 0) return 'Wecker läutet gleich';
    final parts = <String>[];
    if (hours > 0) parts.add('$hours Std.');
    if (minutes > 0) parts.add('$minutes Min.');
    return 'Nächster Wecker in ${parts.join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    final nextAlarm = _repo.nextActiveOccurrence(_alarms);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wecker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Einstellungen',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (nextAlarm != null)
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.alarm,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatNextAlarm(nextAlarm),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _alarms.isEmpty
                      ? const Center(child: Text('Noch kein Wecker eingerichtet.'))
                      : ListView.separated(
                          itemCount: _alarms.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final alarm = _alarms[index];
                            final time =
                                '${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}';
                            return Dismissible(
                              key: ValueKey(alarm.id),
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                color: Theme.of(context).colorScheme.errorContainer,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                              onDismissed: (_) => _deleteAlarm(alarm),
                              child: ListTile(
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
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
