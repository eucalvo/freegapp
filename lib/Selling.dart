import 'package:flutter/material.dart';
import 'package:freegapp/AddFoodCustomForm.dart';

class Selling extends StatefulWidget {
  Selling({required this.logout, Key? key})
      : super(key: key); // Initializes key for subclasses.
  final void Function() logout;

  @override
  _SellingState createState() => _SellingState();
}

class _SellingState extends State<Selling> {
  static const _appTitle = 'Food Up For Sell';

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
      body: Column(children: [
        Column(),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFoodCustomForm()),
              );
            },
            child: Icon(Icons.add)),
        ElevatedButton(onPressed: () {}, child: Text('Go live'))
      ]),
    );
  }
}
