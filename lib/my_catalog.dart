import 'package:flutter/material.dart';
import 'package:freegapp/src/food.dart';

import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'cart.dart';
import 'cart_model.dart';
import 'package:provider/provider.dart';

class MyCatalog extends StatefulWidget {
  MyCatalog({required this.foodBeingSoldByUserId});
  final List<Food> foodBeingSoldByUserId;

  @override
  _MyCatalogState createState() => _MyCatalogState();
}

class _MyCatalogState extends State<MyCatalog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
      ),
      body: Column(
          children: [FoodCatalog(foodList: widget.foodBeingSoldByUserId)]),
    );
  }
}

class _MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Catalog', style: Theme.of(context).textTheme.headline1),
      floating: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }
}

class FoodCatalog extends StatefulWidget {
  FoodCatalog({required this.foodList});
  final List<Food> foodList;

  @override
  _FoodCatalogState createState() => _FoodCatalogState();
}

class _FoodCatalogState extends State<FoodCatalog> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.builder(
                itemCount: widget.foodList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  var numOfItems = 1;
                  final item = widget.foodList[index];
                  return GestureDetector(
                    key: Key(item.documentID),
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            // padding: EdgeInsets.all(5.0),
                            // decoration: BoxDecoration(
                            //   color: Color(0xFF3D82AE),
                            //   borderRadius: BorderRadius.circular(16),
                            // ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                base64Decode(item.image1),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 20.0 / 4),
                          child: Text(
                            // products is out demo list
                            item.title,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(item.description),
                        Text(
                          '\$${item.cost}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            OutlinedButton(
                              child: Icon(Icons.remove),
                              onPressed: () {
                                if (numOfItems > 1) {
                                  setState(() {
                                    numOfItems--;
                                    item.amount = numOfItems;
                                  });
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20 / 2),
                              child: Text(
                                // if our item is less  then 10 then  it shows 01 02 like that
                                numOfItems.toString().padLeft(2, '0'),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            OutlinedButton(
                                child: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    numOfItems++;
                                    item.amount = numOfItems;
                                  });
                                }),
                            FloatingActionButton(
                              onPressed: () {
                                // We are using context.read() here because the callback
                                // is executed whenever the user taps the button. In other
                                // words, it is executed outside the build method.
                                var cart = context.read<CartModel>();
                                cart.add(item);
                              },
                              child: Text('add to Cart'),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                })));
  }
}
