import 'package:bustra/select_bus_stop.dart';
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

  void _selectBusStop(BuildContext context) async {
    var instance = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new SelectBusStop(),
            fullscreenDialog: true));

    if (instance != null) {
      print("SELECTED: ");
      print(instance);
    } else {
      print("NOTHING SELECTED");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //TODO: Change the button to a widget that displays the selected bus stop
                ElevatedButton(
                    onPressed: () => _selectBusStop(context),
                    child: const Text("Wybierz przystanek")),
                ElevatedButton(
                    onPressed: () => print("TODO: Start the tracking"),
                    child: const Text("Rozpocznij")),
              ],
            )),
      ),
    ));
  }
}
