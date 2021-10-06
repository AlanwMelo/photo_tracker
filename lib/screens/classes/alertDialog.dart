import 'package:flutter/material.dart';

class MyAlertDialog extends AlertDialog {
  final String alertTitle;
  final String alertText;
  final String alertButton1Text;
  final String alertButton2Text;
  final Function(int) answer;

  MyAlertDialog(
      {required this.alertTitle,
      required this.alertText,
      required this.alertButton1Text,
      required this.alertButton2Text,
      required this.answer});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _button1(String text) {
      return TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            answer(1);
          },
          child: Text(text));
    }

    _button2(String text) {
      return TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            answer(2);
          },
          child: Text(text));
    }

    return AlertDialog(
      title: Text(alertTitle),
      content: Text(alertText),
      actions: [
        _button1(alertButton1Text),
        _button2(alertButton2Text),
      ],
    );
  }
}
