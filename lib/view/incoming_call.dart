import 'package:call_guard/services/call_services.dart';
import 'package:call_guard/view/add_number.dart';
import 'package:flutter/material.dart';

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
    _callHandler = CallServices(context);
    _callHandler.initialize();
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
