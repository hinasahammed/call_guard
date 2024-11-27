import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

class CallServices {
  final BuildContext context;
  static const MethodChannel _methodChannel = MethodChannel('call_channel');
  late Box _contactsBox;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  CallServices(this.context);

  void initialize() async {
    await _requestPermissions();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _contactsBox = await Hive.openBox('contact');
    _methodChannel.invokeMethod('initialize');
    _methodChannel.setMethodCallHandler(_onIncomingCall);
  }

  Future<void> _requestPermissions() async {
    if (await Permission.phone.isDenied) {
      final status = await Permission.phone.request();
      if (status.isGranted) {
        log("Phone permission granted");
      } else {
        log("Phone permission denied");
      }
    } else {
      log("Phone permission already granted");
    }
  }

  Future<void> _onIncomingCall(MethodCall call) async {
    if (call.method == 'onIncomingCall') {
      final phoneNumber = call.arguments as String?;
      if (phoneNumber != null) {
        log('Incoming call detected: $phoneNumber');
        final name = _contactsBox.get(phoneNumber);
        if (name != null) {
          log('Caller name found: $name');
          showNotification(name);
          showOverlay(name);
        } else {
          log('Caller not found in contacts');
          showNotification("Unknown user");
          showOverlay("Unknown user");
        }
      } else {
        log('No phone number received');
      }
    }
  }

  void showOverlay(String name) async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }

    final box = await Hive.openBox('overlay_data');
    await box.put('caller_name', name);
    await box.flush();

    await FlutterOverlayWindow.showOverlay(
      overlayTitle: "Incoming Call",
      overlayContent: 'Incoming call from: $name',
      height: 500,
      width: 700,
      alignment: OverlayAlignment.center,
    );
  }

  void showNotification(String name) async {
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
}
