import 'package:flutter/foundation.dart';
import 'package:freegapp/src/food.dart';

class CartModel extends ChangeNotifier {
  /// The private field backing [catalog].
  late Food _catalog;

  /// Internal, private state of the cart. Stores the ids of each item.
  final List<int> _itemIds = [];
  final List<Food> _foods = [];

  List<Food> get foodList => _foods;

  /// The current catalog. Used to construct items from numeric ids.
  Food get catalog => _catalog;

  set catalog(Food newCatalog) {
    _catalog = newCatalog;
    // Notify listeners, in case the new catalog provides information
    // different from the previous one. For example, availability of an item
    // might have changed.
    notifyListeners();
  }

  /// List of items in the cart.
  // List<Food> get items => _itemIds.map((id) => _catalog.getById(id)).toList();

  /// The current total price of all items.
  // int get totalPrice =>
  //     items.fold(0, (total, current) => total + current.price);

  /// Adds [item] to cart. This is the only way to modify the cart from outside.
  void add(Food item) {
    // if (item.amount == 0) {
    //   _foods.removeWhere((element) => item.amount == 0);
    // }
    if (item.amount != 0) {
      _foods.add(item);
    }
    // This line tells [Model] that it should rebuild the widgets that
    // depend on it.
    notifyListeners();
  }

  // void remove(Item item) {
  //   _itemIds.remove(item.id);
  //   // Don't forget to tell dependent widgets to rebuild _every time_
  //   // you change the model.
  //   notifyListeners();
  // }
}
