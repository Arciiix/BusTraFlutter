import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bustra/models/bus_stop.dart';

import 'package:bustra/home_screen.dart';
import 'package:bustra/bus_stop_form.dart';
import 'package:bustra/error.dart';
import 'package:bustra/utils/get_permissions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(BusStopAdapter());
  await Hive.openBox<BusStop>("busStops");

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
  void dispose() {
    Hive.box('transactions').close();

    super.dispose();
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
      routes: {
        "/": (contex) => HomeScreen(),
        "/addBusStop": (contex) => BusStopForm()
      },
    );
  }
}
