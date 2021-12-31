import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'dart:convert';

class Cart extends StatefulWidget {
  Cart();

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: CartList(),
              ),
            ),
          ],
        ));
  }
}

class CartList extends StatefulWidget {
  CartList();
  @override
  _CartListState createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  @override
  Widget build(BuildContext context) {
    var itemNameStyle = Theme.of(context).textTheme.headline6;
    // This gets the current state of CartModel and also tells Flutter
    // to rebuild this widget when CartModel notifies listeners (in other words,
    // when it changes).
    var cart = context.watch<CartModel>();

    return ListView.builder(
        itemCount: cart.foodList.length,
        itemBuilder: (context, index) {
          var numOfItems = cart.foodList[index].amount!;
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0)),
                child: Image.memory(
                  base64Decode(cart.foodList[index].image1),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                  child: SizedBox(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cart.foodList[index].title),
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 2.0, bottom: 2.0),
                              child: Text(
                                cart.foodList[index].description,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                              )),
                          Text(
                            cart.foodList[index].cost.toString(),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                          )
                        ],
                      )),
                      Row(children: [
                        IconButton(
                          onPressed: () {
                            if (numOfItems > 1) {
                              setState(() {
                                numOfItems--;
                              });
                            }
                          },
                          icon: Icon(Icons.remove_circle),
                        ),
                        Text('$numOfItems'),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              numOfItems++;
                            });
                          },
                          icon: Icon(Icons.add_circle),
                        ),
                      ]),
                    ])),
              ))
            ],
          );
        });
  }
}
