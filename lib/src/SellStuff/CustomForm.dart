import 'package:flutter/material.dart';

class CustomForm extends StatefulWidget {
  CustomForm({Key? key}) : super(key: key); // Initializes key for subclasses.

  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        decoration:
            InputDecoration(border: OutlineInputBorder(), hintText: 'title'),
      ),
      TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(), hintText: 'description'),
      ),
      TextField(
        decoration:
            InputDecoration(border: OutlineInputBorder(), hintText: 'cost'),
      )
    ]);
  }
}
