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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () => print("TODO: Start the tracking"),
                    child: const Text("Rozpocznij")),
                ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, "/addBusStop"),
                    child: const Text("Dodaj przystanek"))
              ],
            )),
      ),
    ));
  }
}
