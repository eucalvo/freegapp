import 'package:freegapp/cart_model.dart';
import 'package:freegapp/catalog_model.dart';
import 'package:freegapp/my_catalog.dart';
import 'package:freegapp/src/food.dart';
import 'package:freegapp/src/coordinate_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'cart.dart';

import 'package:provider/provider.dart';

class TheMap extends StatefulWidget {
  TheMap(
      {Key? key,
      required this.coordinateInfoList,
      required this.foodList,
      required this.userIdSellingFood})
      : super(key: key); // Initializes key for subclasses.
  final List<CoordinateInfo> coordinateInfoList;
  final List<Food> foodList;
  final Set<String> userIdSellingFood;
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<TheMap> {
  // Controller for a single GoogleMap instance running on the host platform.
  late final GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();
  final LatLng _center = const LatLng(45.521563, -122.677433);

  Set<Marker> getMarkerOfPeopleSelling() {
    // CoordinateInfo? coordinateElement;
    var peopleSellingFood = <Marker>{};
    widget.userIdSellingFood.forEach((userIdString) {
      var coordinateInfoOfUserId = widget.coordinateInfoList
          .firstWhere((element) => element.userId == userIdString);
      var foodBeingSoldByUserId = widget.foodList
          .where((element) => element.userId == userIdString)
          .toList();
      peopleSellingFood.add(Marker(
          infoWindow: InfoWindow(onTap: () {}),
          markerId: MarkerId(coordinateInfoOfUserId.userId),
          position: LatLng(coordinateInfoOfUserId.latitude,
              coordinateInfoOfUserId.longitude),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    // MultiProvider(
                    //     providers: [
                    // In this sample app, CatalogModel never changes, so a simple Provider
                    // is sufficient.
                    // Provider(
                    //     create: (context) =>
                    //         CatalogModel(foodList: foodBeingSoldByUserId)),
                    // CartModel is implemented as a ChangeNotifier, which calls for the use
                    // of ChangeNotifierProvider. Moreover, CartModel depends
                    // // on CatalogModel, so a ProxyProvider is needed.
                    // ChangeNotifierProxyProvider<CatalogModel, CartModel>(
                    //   create: (context) => CartModel(),
                    //   update: (context, catalog, cart) {
                    //     if (cart == null) throw ArgumentError.notNull('cart');
                    //     cart.catalog = catalog;
                    //     return cart;
                    //   },
                    // ),
                    // ],
                    // child:
                    MyCatalog(
                  foodList: foodBeingSoldByUserId,
                )
                // )
                ,
              ))));
    });
    return peopleSellingFood;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: getMarkerOfPeopleSelling(),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 11.0,
      ),
    );
  }
}
