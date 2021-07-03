// MyApp.dart is the main layout of how the app looks
import 'package:flutter/material.dart';
import 'package:freegapp/TheMap.dart';
import 'package:freegapp/Sell.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freegap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyStatefulWidget(key: Key('default')),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key? key})
      : super(key: key); // Initializes key for subclasses.
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // for bottom navigation bar
  int _selectedIndex = 0;
  // Widget array for bottom navigation bar
  static final List<Widget> _widgetOptions = <Widget>[
    TheMap(key: Key('TheMap')),
    Sell(key: Key('Sell')),
  ];
  // for bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // body:
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'icon',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
