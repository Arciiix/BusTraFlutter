import 'package:flutter/material.dart';
import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_geofence/geofence.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Geofence.initialize();
    Geofence.requestPermissions();
    throw Exception("test 123!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Column(
          children: [
            Column(
              children: [
                ElevatedButton(
                    onPressed: () =>
                        Geofence.getCurrentLocation().then((coordinate) {
                          print(
                              "Your latitude is ${coordinate!.latitude} and longitude ${coordinate!.longitude}");
                        }),
                    child: Text("Rozpocznij"))
              ],
            )
          ],
        ),
      ),
    ));
  }
}
