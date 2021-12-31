import 'package:flutter/material.dart';
import 'package:freegapp/src/food.dart';

import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'cart.dart';
import 'cart_model.dart';
import 'package:provider/provider.dart';

class MyCatalog extends StatefulWidget {
  MyCatalog({required this.foodList});
  final List<Food> foodList;

  @override
  _MyCatalogState createState() => _MyCatalogState();
}

class _MyCatalogState extends State<MyCatalog> {
  List<int> counters = [];
  @override
  void initState() {
    super.initState();
    counters = List.filled(widget.foodList.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Consumer<CartModel>(
                              builder: (context, cartModel, _) => Cart(),
                            )),
                  ))
        ],
      ),
      body: CustomScrollView(slivers: [
        // Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
        // child:
        SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            return GestureDetector(
              key: Key(widget.foodList[index].documentID),
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
                          base64Decode(widget.foodList[index].image1),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0 / 4),
                    child: Text(
                      // products is out demo list
                      widget.foodList[index].title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(widget.foodList[index].description),
                  Text(
                    '\$${widget.foodList[index].cost}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    key: Key('$index'),
                    children: <Widget>[
                      OutlinedButton(
                        child: Icon(Icons.remove),
                        onPressed: () {
                          if (counters[index] > 1) {
                            setState(() {
                              counters[index]--;
                              widget.foodList[index].amount = counters[index];
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20 / 2),
                        child: Text(
                          // if our item is less  then 10 then  it shows 01 02 like that
                          counters[index].toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      OutlinedButton(
                          child: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              counters[index]++;
                              widget.foodList[index].amount = counters[index];
                            });
                          }),
                    ],
                  )
                ],
              ),
            );
          }, childCount: widget.foodList.length),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
            childAspectRatio: 0.75,
          ),
        ),
        // ),
        SliverToBoxAdapter(
            child: ElevatedButton(
          onPressed: () {
            // We are using context.read() here because the callback
            // is executed whenever the user taps the button. In other
            // words, it is executed outside the build method.
            var cart = context.read<CartModel>();
            var addToCart = <Food>[];
            var counter = 0;
            for (final count in counters) {
              if (count > 0) {
                print(widget.foodList[counter].title);
                print(counter);
                print(count);
                addToCart.add(widget.foodList[counter]);
              }
              counter++;
            }
            if (addToCart.isNotEmpty) {
              cart.add(addToCart);
            }
          },
          child: Text('add to Cart'),
        )),
      ]),
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
