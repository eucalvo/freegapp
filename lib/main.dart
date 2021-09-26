import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';
import 'package:freegapp/TheMap.dart';
import 'package:freegapp/src/ApplicationStateFirebase.dart';
import 'package:freegapp/LoginFlow.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();
  // Open the database and store the reference.
  await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'freegapp.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      db.execute(
        'CREATE TABLE food(id TEXT PRIMARY KEY, title TEXT, description TEXT, cost REAL)',
      );
      db.execute(
        'CREATE TABLE images(id TEXT PRIMARY KEY, image TEXT)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationStateFirebase(),
      builder: (context, _) => MyApp(),
    ),
  );
}

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
    Consumer<ApplicationStateFirebase>(
      builder: (context, appState, _) => LoginFlow(
          email: appState.email,
          loginState: appState.loginState,
          startLoginFlow: appState.startLoginFlow,
          verifyEmail: appState.verifyEmail,
          signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
          cancelRegistration: appState.cancelRegistration,
          registerAccount: appState.registerAccount,
          signOut: appState.signOut,
          myUserInfo: appState.myUserInfo,
          key: Key('LoginFlow')),
    ),
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
