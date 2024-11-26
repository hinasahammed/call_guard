import 'dart:developer';

import 'package:call_guard/view/incoming_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('contact');
  await Hive.openBox('overlay_data');
  runApp(const MyApp());
}

// Your normal app entry point
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const IncomingCall(),
    );
  }
}

@pragma("vm:entry-point")
void overlayMain() async {
  log('overlayMain started');
  await Hive.initFlutter();

  // Retry opening the box until it contains data
  final box = await Hive.openBox('overlay_data');
  for (int i = 0; i < 5; i++) {
    final String? callerName = box.get('caller_name');
    if (callerName != null) break;
    log('Waiting for caller_name data...');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  final String callerName = box.get('caller_name') ?? "Unknown User";
  log('Retrieved caller_name in overlayMain: $callerName');

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Material(
      child: Container(
        width: 650,
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(.5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      callerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple.withOpacity(.8),
                      ),
                    ),
                    Text(
                      "${TimeOfDay.now().hourOfPeriod}:${TimeOfDay.now().minute}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await FlutterOverlayWindow.closeOverlay();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "+911234566789",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Mobile",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ));
}
