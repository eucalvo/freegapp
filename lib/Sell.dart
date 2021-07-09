import 'package:flutter/material.dart';

class Sell extends StatefulWidget {
  Sell({required this.logout, Key? key})
      : super(key: key); // Initializes key for subclasses.
  final void Function() logout;

  @override
  _SellState createState() => _SellState();
}

class _SellState extends State<Sell> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.logout,
      child: const Text('Logout'),
    );
  }
}
