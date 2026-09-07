import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/home_screen.dart';
import 'screens/ring_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(const WeckerApp());
}

class WeckerApp extends StatefulWidget {
  const WeckerApp({super.key});

  @override
  State<WeckerApp> createState() => _WeckerAppState();
}

class _WeckerAppState extends State<WeckerApp> {
  StreamSubscription<AlarmSet>? _ringSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _ringSubscription = Alarm.ringing.listen(_onRinging);
  }

  Future<void> _requestPermissions() async {
    if (!await Permission.notification.status.isGranted) {
      await Permission.notification.request();
    }
    if (!await Permission.scheduleExactAlarm.status.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  void _onRinging(AlarmSet alarmSet) {
    if (alarmSet.alarms.isEmpty) return;
    final settings = alarmSet.alarms.first;
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => RingScreen(alarmSettings: settings)),
    );
  }

  @override
  void dispose() {
    _ringSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Wecker',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
