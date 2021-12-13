import 'package:freegapp/src/food.dart';
import 'package:freegapp/src/coordinateInfo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
      peopleSellingFood.add(Marker(
          infoWindow: InfoWindow(onTap: () {}),
          markerId: MarkerId(coordinateInfoOfUserId.userId),
          position: LatLng(coordinateInfoOfUserId.latitude,
              coordinateInfoOfUserId.longitude),
          onTap: () {}));
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
