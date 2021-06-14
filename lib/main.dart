import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:freegapp/MyApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();

  runApp(MyApp());
}
