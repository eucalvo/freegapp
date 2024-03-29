import 'package:flutter/material.dart';
import 'dart:io';
import 'package:freegapp/src/application_state_firebase.dart';
import 'package:freegapp/src/mocks/application_state_firebase_mock.dart';
import 'package:freegapp/src/food.dart';
import 'dart:convert';
import 'package:freegapp/add_food_custom_form.dart';
import 'package:provider/provider.dart';

class Selling extends StatefulWidget {
  const Selling({required this.logout, Key? key})
      : super(key: key); // Initializes key for subclasses.
  final void Function() logout;

  @override
  State<Selling> createState() => _SellingState();
}

class _SellingState extends State<Selling> {
  static const _appTitle = 'Food Up For Sell';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(onPressed: () {}, child: const Text('Go live')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddFoodCustomForm(
                            key: Key('AddFoodCustomForm'),
                          )),
                );
              },
              child: const Icon(Icons.add)),
          ElevatedButton(
            onPressed: widget.logout,
            child: const Text('Logout'),
          ),
        ],
        title: const Text(_appTitle),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Platform.environment.containsKey('FLUTTER_TEST') == true
            ? Consumer<ApplicationStateFirebaseMock>(
                builder: (context, appState, _) =>
                    FoodWidget(foodList: appState.foodList))
            : Consumer<ApplicationStateFirebase>(
                builder: (context, appState, _) =>
                    FoodWidget(foodList: appState.foodList)),
      ),
    );
  }
}

class FoodWidget extends StatefulWidget {
  const FoodWidget({super.key, required this.foodList});
  final List<Food> foodList;
  @override
  State<FoodWidget> createState() => _FoodWidgetState();
}

class _FoodWidgetState extends State<FoodWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.foodList.length,
        itemBuilder: (context, index) {
          final item = widget.foodList[index];
          return Dismissible(
              key: Key(item.documentID),
              onDismissed: (direction) {
                var appState = ApplicationStateFirebase();
                var mockAppState = ApplicationStateFirebaseMock();
                if (Platform.environment.containsKey('FLUTTER_TEST') == true) {
                  mockAppState.seeYouSpaceCowboy(item.documentID);
                } else {
                  appState.seeYouSpaceCowboy(item.documentID);
                }
                setState(() {
                  widget.foodList.removeAt(index);
                });
                var title = item.title;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$title deleted')));
              },
              child: _previewItems(item.title, item.description, item.cost,
                  item.image1, item.image2, item.image3));
        });
  }

  Widget _previewItems(title, description, cost, image1, image2, image3) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 2.0,
                blurRadius: 5.0,
              )
            ]),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0)),
              child: Image.memory(
                base64Decode(image1),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                        child: Text(
                          description,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                        )),
                    Text(
                      '$cost',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  String toJson(title, description, cost, image1, image2, image3) {
    var data = <String, String>{};
    data['title'] = title;
    data['description'] = description;
    data['cost'] = cost;
    data['image1'] = image1;
    data['image2'] = image2;
    data['image3'] = image3;
    return json.encode(data);
  }
}
