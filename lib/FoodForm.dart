import 'package:flutter/material.dart';
import 'package:freegapp/src/SellStuff/ImageBar.dart';
import 'package:freegapp/src/SellStuff/CustomForm.dart';

class FoodForm extends StatefulWidget {
  FoodForm({Key? key}) : super(key: key); // Initializes key for subclasses.

  @override
  _FoodFormState createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      ImageBar(),
      CustomForm(),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('CANCEL'),
      ),
    ]));
  }
}
