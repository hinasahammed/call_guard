import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('contacts');
  runApp(const IncomingCallApp());
}

class IncomingCallApp extends StatefulWidget {
  const IncomingCallApp({super.key});

  @override
  _IncomingCallAppState createState() => _IncomingCallAppState();
}

class _IncomingCallAppState extends State<IncomingCallApp> {
  static const MethodChannel _methodChannel = MethodChannel('call_channel');
  late Box _contactsBox;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _contactsBox = Hive.box('contacts');
    _methodChannel.invokeMethod('initialize');
    _methodChannel.setMethodCallHandler(_onIncomingCall);
    _addSampleContacts(); // Optional: Add sample data
  }

 Future<void> _requestPermissions() async {
  if (await Permission.phone.isDenied) {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      print("Phone permission granted");
    } else {
      print("Phone permission denied");
    }
  } else {
    print("Phone permission already granted");
  }
}


  Future<void> _addSampleContacts() async {
    // Add sample data if not already present
    if (_contactsBox.isEmpty) {
      _contactsBox.put('+919567403045', 'Diya shajith k');
      _contactsBox.put('0987654321', 'Jane Smith');
    }
  }

  Future<void> _onIncomingCall(MethodCall call) async {
  if (call.method == 'onIncomingCall') {
    final phoneNumber = call.arguments as String?;
    if (phoneNumber != null) {
      log('Incoming call detected: $phoneNumber'); // Flutter debug
      final name = _contactsBox.get(phoneNumber);
      if (name != null) {
        log('Caller name found: $name');
        _showNotification(name);
      } else {
        log('Caller not found in contacts');
      }
    } else {
      log('No phone number received');
    }
  }
}


  void _showNotification(String name) async {
    const androidDetails = AndroidNotificationDetails(
      'call_channel',
      'Incoming Call',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Incoming Call',
      'Caller: $name',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Incoming Call Detector')),
        body: const Center(child: Text('Listening for incoming calls...')),
      ),
    );
  }
}
