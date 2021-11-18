import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'error.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
