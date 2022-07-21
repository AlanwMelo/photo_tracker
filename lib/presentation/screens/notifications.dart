import 'package:flutter/cupertino.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('Notificações')),
    );
  }
}
