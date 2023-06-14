import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class TheMap extends StatefulWidget {
  TheMap({Key? key}) : super(key: key); // Initializes key for subclasses.
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<TheMap> {
  // Controller for a single GoogleMap instance running on the host platform.
  late final GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 11.0,
      ),
    );
  }
}
