import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:call_guard/services/call_services.dart';
import 'package:call_guard/view/add_number.dart';

class IncomingCall extends StatefulWidget {
  const IncomingCall({super.key});

  @override
  State<IncomingCall> createState() => _IncomingCallState();
}

class _IncomingCallState extends State<IncomingCall> {
  late CallServices _callHandler;

  @override
  void initState() {
    super.initState();
    _requestOverlayPermission();
    _callHandler = CallServices(context);
    _callHandler.initialize();
  }

  Future<void> _requestOverlayPermission() async {
    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    if (!status) {
      final bool permissionGranted = await FlutterOverlayWindow.requestPermission()??false;
      if (permissionGranted) {
        log("Overlay permission granted");
      } else {
        log("Overlay permission denied");
      }
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Call Detector')),
      body: const Center(child: Text('Listening for incoming calls...')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => const AddNumber(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
