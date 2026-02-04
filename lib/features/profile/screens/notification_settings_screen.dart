import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool email = true;
  bool push = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Email Notifications'),
            value: email,
            onChanged: (v) => setState(() => email = v),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: push,
            onChanged: (v) => setState(() => push = v),
          ),
        ],
      ),
    );
  }
}
