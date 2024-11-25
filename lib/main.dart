import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const CallLogApp());
}

class CallLogApp extends StatefulWidget {
  const CallLogApp({super.key});

  @override
  _CallLogAppState createState() => _CallLogAppState();
}

class _CallLogAppState extends State<CallLogApp> {
  List<CallLogEntry> callLogs = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  // Request permission to access call logs
  void _requestPermission() async {
    if (await Permission.phone.request().isGranted) {
      // Permission granted, fetch call logs
      _getCallLogs();
    } else {
      // Show an alert or notify user to grant permission
      print("Permission denied");
    }
  }

  // Fetch call logs using the call_log package
  void _getCallLogs() async {
    Iterable<CallLogEntry> logs = await CallLog.get();
    setState(() {
      callLogs = logs.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Call Logs')),
        body: callLogs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: callLogs.length,
                itemBuilder: (context, index) {
                  final callLog = callLogs[index];
                  // Provide a default value of 0 if timestamp is null
                  final timestamp = callLog.timestamp ?? 0;

                  return ListTile(
                    title: Text(callLog.name ?? "Unknown"),
                    subtitle: Text(
                        'Type: ${callLog.callType}, Date: ${DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal()}'),
                    leading: Icon(callLog.callType == CallType.incoming
                        ? Icons.call_received
                        : Icons.call_made),
                  );
                },
              ),
      ),
    );
  }
}
