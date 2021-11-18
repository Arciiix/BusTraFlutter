import 'package:flutter/material.dart';

import 'package:bustra/home_screen.dart';
import 'package:bustra/error.dart';
import 'package:bustra/utils/get_permissions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    getPermissions();
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return ErrorPage(error: errorDetails.exceptionAsString());
    };
    return MaterialApp(
      title: 'BusTra',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {"/": (contex) => HomeScreen()},
    );
  }
}
