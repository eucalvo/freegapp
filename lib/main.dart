import 'MyApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';
import 'src/ApplicationStateLogin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationStateLogin(),
      builder: (context, _) => MyApp(),
    ),
  );
}
