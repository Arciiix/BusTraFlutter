import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_location/background_location.dart';
import 'package:bustra/models/bus_stop.dart';
import 'package:bustra/select_bus_stop.dart';
import 'package:bustra/small_info.dart';
import 'package:bustra/tracking.dart';
import 'package:bustra/utils/generate_unique_id.dart';
import 'package:bustra/utils/get_permissions.dart';
import 'package:bustra/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

//import 'package:flutter_geofence/Geolocation.dart';
//import 'package:flutter_geofence/geofence.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? osVersion;

  BusStop? selectedBusStop;

  MapController _mapController = MapController();
  bool _isTracking = false;

  LatLng? _currPosition;
  double? _distanceToDestination;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  @override
  void initState() {
    super.initState();

    //Geofence.initialize();
    //Geofence.requestPermissions();

    _showNotificationWarn();
  }

  void _showNotificationWarn() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    osVersion = androidInfo.version.sdkInt;
    print("RUNNING ON SDK $osVersion");

    if (osVersion! >= 30) {
      if (!(await isLocationInBackgroundGranted())) {
        AlertDialog notificationDialogAndroid11 = AlertDialog(
          title: Text("Uprawnienia"),
          content: Text(
              'Android 11 nie umożliwia zezwolenia na lokalizację w tle z poziomu aplikacji. Wejdź w ustawienia swojego urządzenia i przy lokalizacji zaznacz "Zawsze"'),
          actions: [
            TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return notificationDialogAndroid11;
            });
        //DEV
        //TODO: Maybe throw an error?
      }
    }
  }

  void _selectBusStop(BuildContext context) async {
    var instance = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new SelectBusStop(),
            fullscreenDialog: true));

    if (instance != null) {
      setState(() {
        selectedBusStop = instance;
      });
      print("SELECTED ${selectedBusStop?.name}");
    } else {
      print("NOTHING SELECTED");
    }
  }

  void _startTracking() {
    if (selectedBusStop == null) {
      showSnackBar(context, "Wybierz swój przystanek");
      return;
    }

    Tracking.startTracking(
        LatLng(selectedBusStop!.destinationBusStopLatitude,
            selectedBusStop!.destinationBusStopLongitude),
        LatLng(selectedBusStop!.previousBusStopLatitude,
            selectedBusStop!.previousBusStopLongitude),
        (currPos, distanceToDestination) {
      print("CALLBACK");
      setState(() {
        _currPosition = currPos;
        _distanceToDestination = distanceToDestination;
        _mapController.move(currPos!, _mapController.zoom);
        _isTracking = true;
      });
    });
  }

  void _stopTracking() {
    Tracking.stopTracking();
    setState(() {
      _currPosition = null;
      _isTracking = false;
    });
  }

  Widget buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(center: LatLng(50, 18.5), zoom: 10),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(
            markers: selectedBusStop != null
                ? [
                    Marker(
                        width: 100,
                        height: 100,
                        point: LatLng(
                            selectedBusStop!.destinationBusStopLatitude,
                            selectedBusStop!.destinationBusStopLongitude),
                        builder: (ctx) =>
                            Container(child: Icon(Icons.directions_bus))),
                    Marker(
                        width: 100,
                        height: 100,
                        point: LatLng(selectedBusStop!.previousBusStopLatitude,
                            selectedBusStop!.previousBusStopLongitude),
                        builder: (ctx) =>
                            Container(child: Icon(Icons.bus_alert))),
                    Marker(
                        //marker
                        width: 100,
                        height: 100,
                        point: _currPosition ?? LatLng(0, 0), //DEV
                        builder: (context) {
                          return _currPosition != null
                              ? Container(
                                  child: Icon(Icons.my_location,
                                      color: Colors.blue[400]),
                                )
                              : Container();
                        })
                  ]
                : []),
        CircleLayerOptions(
            circles: selectedBusStop != null
                ? [
                    CircleMarker(
                        point: LatLng(
                            selectedBusStop!.destinationBusStopLatitude,
                            selectedBusStop!.destinationBusStopLongitude),
                        color: Colors.blue.withOpacity(0.3),
                        borderStrokeWidth: 3.0,
                        borderColor: Colors.blue,
                        radius: 20),
                    CircleMarker(
                        point: LatLng(selectedBusStop!.previousBusStopLatitude,
                            selectedBusStop!.previousBusStopLongitude), //DEV
                        color: Colors.blue.withOpacity(0.3),
                        borderStrokeWidth: 3.0,
                        borderColor: Colors.blue,
                        radius: 20),
                    CircleMarker(
                        point: _currPosition ?? LatLng(0, 0), //DEV
                        color: Colors.blue.withOpacity(0.3),
                        borderStrokeWidth: _currPosition != null ? 3 : 0,
                        borderColor: Colors.blue,
                        radius: _currPosition != null ? 20 : 0),
                  ]
                : [])
      ],
    );
  }

  Widget buildInfo() {
    return Container(
        padding: EdgeInsets.only(top: 10),
        child: Column(children: [
          Text(
              "${_distanceToDestination != null ? _distanceToDestination.toString() : "0"} m",
              style: TextStyle(fontSize: 48)),
          Row(
            children: [
              Expanded(child: SmallInfo(icon: Icons.timelapse, value: "00:00")),
            ],
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onTap: () {
                if (!_isTracking) {
                  _selectBusStop(context);
                }
              },
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        selectedBusStop != null
                            ? selectedBusStop?.name ?? "Przystanek bez nazwy"
                            : "Wybierz przystanek",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      )),
                      Icon(
                        Icons.expand_more,
                      )
                    ],
                  ))),
          actions: [
            TextButton(
              child: Text(_isTracking ? "PRZERWIJ" : "ROZPOCZNIJ",
                  style: TextStyle(color: Colors.white)),
              onPressed: () => _isTracking ? _stopTracking() : _startTracking(),
            )
          ],
        ),
        body: Container(
          child: Center(
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 18, child: buildMap()),
                    Expanded(flex: 5, child: buildInfo()),
                    //DEV - VERSION
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.only(left: 10, bottom: 10),
                        child: Banner(
                          message: "DEV 1.0-121221",
                          location: BannerLocation.bottomStart,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ));
  }
}
