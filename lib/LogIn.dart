import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  LogIn({Key? key}) : super(key: key); // Initializes key for subclasses.
  @override
  _LogIn createState() => _LogIn();
}

class _LogIn extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Log in page',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}
