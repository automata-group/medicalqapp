import 'package:flutter/material.dart';

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width >= 800
          ? AppBar(
              title: const Text('Activity Logs'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1)
          : null,
      body: const Center(
        child: Text('Activity Logs Features: Track admin actions securely'),
      ),
    );
  }
}
