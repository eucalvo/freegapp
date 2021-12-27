// import 'dart:async';
// import 'dart:collection';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class Product {
//   Product({required this.name, required this.cost});
//   final String name;
//   final double cost;
// }

// class Cart with ChangeNotifier {
//   List<Product> products = [];

//   double get total {
//     return products.fold(0.0, (double currentTotal, Product nextProduct) {
//       return currentTotal + nextProduct.cost;
//     });
//   }

//   void addToCart(Product product) => products.add(product);
//   void removeFromCart(Product product) {
//     products.remove(product);
//     notifyListeners();
//   }
// }

// class User {
//   User({required this.name, required this.cart});
//   final String name;
//   final Cart cart;
// }

// class Store {
//   Store() {
//     _streamController.add(<Product>[]);
//     _initialize();
//   }

//   final StreamController<List<Product>> _streamController =
//       StreamController<List<Product>>();
//   Stream<List<Product>> get allProductsForSale => _streamController.stream;

//   void _initialize() {
//     MockDatabase().getProductsBatched().listen((List<Product> products) {
//       _streamController.add(products);
//     });
//   }

//   void dispose() {
//     _streamController.close();
//   }
// }

// class MockDatabase {
//   factory MockDatabase() {
//     return _instance;
//   }
//   MockDatabase._internal();

//   static final MockDatabase _instance = MockDatabase._internal();

//   Future<User> login() async {
//     return await Future.delayed(Duration(seconds: 1), () {
//       return User(name: 'Yohan', cart: Cart());
//     });
//   }

//   Stream<List<Product>> getProductsBatched() async* {
//     var allProducts = List<Product>.filled(
//         0, Product(name: 'sample', cost: 0.99),
//         growable: true);

//     var i = 0;
//     while (i < 10) {
//       await Future.delayed(Duration(seconds: 1), () {
//         allProducts.add(_productsInDatabase[i]);
//       });
//       i++;
//       yield allProducts;
//     }
//   }

//   final List<Product> _productsInDatabase = [
//     Product(name: 'Carrot', cost: 1.0),
//     Product(name: 'Potatoes', cost: 1.0),
//     Product(name: 'Tomato', cost: 0.5),
//     Product(name: 'Cheese', cost: 1.5),
//     Product(name: 'Beans', cost: 1.5),
//     Product(name: 'Lettuce', cost: 1.5),
//     Product(name: 'Flour', cost: 1.5),
//     Product(name: 'Honey', cost: 1.5),
//     Product(name: 'Chocolate', cost: 1.5),
//     Product(name: 'Asparagus', cost: 1.5),
//     Product(name: 'Bread', cost: 1.5),
//   ];
// }

// void main() async {
//   final user = await MockDatabase().login();

//   runApp(
//     MultiProvider(
//       providers: [
//         Provider<User>.value(value: user),
//         Provider<Store>(create: (_) => Store()),
//         ChangeNotifierProvider<Cart>(create: (_) => Cart()),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ProductsPage(),
//     );
//   }
// }

// class ProductsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Grocery Store'),
//         actions: <Widget>[
//           Stack(
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(Icons.shopping_cart),
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (BuildContext context) {
//                         return CartPage();
//                       },
//                     ),
//                   );
//                 },
//               ),
//               Positioned(
//                 top: 10.0,
//                 left: 10.0,
//                 child: Container(
//                   height: 10.0,
//                   width: 10.0,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.red,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: StreamProvider<List<Product>>(
//         initialData: [],
//         create: (_) => Provider.of<Store>(context).allProductsForSale,
//         catchError: (BuildContext context, error) => <Product>[],
//         updateShouldNotify: (List<Product> last, List<Product> next) =>
//             last.length == next.length,
//         builder: (BuildContext context, List<Product> items, Widget child) {
//           final items = context.watch<List<Product>>();
//           return ListView.builder(
//             itemCount: items.length,
//             itemBuilder: (BuildContext context, int index) {
//               if (items.isEmpty) {
//                 return Text('no products for sale, check back later');
//               }
//               final item = items[index];
//               return ListTile(
//                 title: Text(item.name ?? ''),
//                 subtitle: Text('cost: ${item.cost.toString() ?? 'free'}'),
//                 trailing: Text('Add to Cart'),
//                 onTap: () {
//                   context.read<Cart>().addToCart(item);
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class CartPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(context.watch<User>().name + 's Cart'),
//       ),
//       body: Consumer<Cart>(
//         builder: (BuildContext context, Cart cart, Widget child) {
//           return Column(
//             children: <Widget>[
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: cart.products.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     if (cart.products.isEmpty) {
//                       return Text('no products in cart');
//                     }
//                     final item = cart.products[index];
//                     return ListTile(
//                       title: Text(item.name ?? ''),
//                       subtitle: Text('cost: ${item.cost.toString() ?? 'free'}'),
//                       trailing: Text('tap to remove from cart'),
//                       onTap: () {
//                         context.read<Cart>().removeFromCart(item);
//                       },
//                     );
//                   },
//                 ),
//               ),
//               Divider(),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   'TOTAL: ${context.select((Cart c) => c.total)}',
//                   style: Theme.of(context).textTheme.headline3,
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
