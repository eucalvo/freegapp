import 'package:flutter/material.dart';
import 'package:freegapp/src/SellStuff/ImageBar.dart';

class Sell extends StatefulWidget {
  Sell({required this.logout, Key? key})
      : super(key: key); // Initializes key for subclasses.
  final void Function() logout;

  @override
  _SellState createState() => _SellState();
}

class _SellState extends State<Sell> {
  static const _appTitle = 'Food list to put up for sell';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: widget.logout,
            child: const Text('Logout'),
          ),
        ],
        title: const Text(_appTitle),
      ),
      body: ImageBar(),
    );
  }
}
