import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bustra/models/bus_stop.dart';
import 'package:bustra/select_bus_stop.dart';
import 'package:bustra/settings.dart';
import 'package:bustra/small_info.dart';
import 'package:bustra/tracking.dart';
import 'package:bustra/utils/get_permissions.dart';
import 'package:bustra/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? osVersion;
  String? appVersion;
  final Battery _battery = Battery();
  int? initialBatteryLevel;
  int? currentBatteryLevel;

  BusStop? selectedBusStop;

  MapController _mapController = MapController();
  bool _isTracking = false;

  LatLng? _currPosition;
  double? _distanceToDestination;

  int uptimeSec = 0;
  String _parsedTime = "00:00";

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  @override
  void initState() {
    super.initState();

    _showNotificationWarn();

    AwesomeNotifications().actionStream.listen((event) {
      if (event.buttonKeyPressed == 'STOP_TRACKING' && _isTracking) {
        _stopTracking();
      }
      if (event.buttonKeyPressed == "REMIND_ME" && _isTracking) {
        //TODO: Set the seconds amount in settings
        Future.delayed(const Duration(seconds: 5), () {
          print("RESET NOTIFICATIONS");
          Tracking.didSendNotification = false;
          Tracking.didSendPreviousStopNotification = false;
        });
      }
    });
  }

  void _showNotificationWarn() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    osVersion = androidInfo.version.sdkInt;
    print("RUNNING ON SDK $osVersion");

    if (osVersion! >= 30) {
      if (!(await isLocationInBackgroundGranted())) {
        AlertDialog notificationDialogAndroid11 = AlertDialog(
          title: const Text("Uprawnienia"),
          content: const Text(
              'Android 11 nie umożliwia zezwolenia na lokalizację w tle z poziomu aplikacji. Wejdź w ustawienia swojego urządzenia i przy lokalizacji zaznacz "Zawsze"'),
          actions: [
            TextButton(
                child: const Text("OK"),
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
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        setState(() {
        appVersion = packageInfo.version + "/" + packageInfo.buildNumber;  
        });
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

  void _startTracking() async {
    if (selectedBusStop == null) {
      showSnackBar(context, "Wybierz swój przystanek");
      return;
    }

    uptimeSec = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking) {
        _updateTime();
      } else {
        timer.cancel();
      }
    });

    initialBatteryLevel = await _battery.batteryLevel;
    currentBatteryLevel = initialBatteryLevel;

    Tracking.startTracking(
        LatLng(selectedBusStop!.destinationBusStopLatitude,
            selectedBusStop!.destinationBusStopLongitude),
        LatLng(selectedBusStop!.previousBusStopLatitude,
            selectedBusStop!.previousBusStopLongitude),
        (currPos, distanceToDestination) {
      print("CALLBACK");
      setState(() async {
        _currPosition = currPos;
        _distanceToDestination = distanceToDestination;
        _isTracking = true;
        currentBatteryLevel = await _battery.batteryLevel;
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

  void _updateTime() {
    setState(() {
      uptimeSec++;
      _parsedTime = getParsedTime();
    });
  }

  String getParsedTime() {
    int min = uptimeSec ~/ 60;
    int sec = uptimeSec % 60;
    return "${addZero(min)}:${addZero(sec)}";
  }

  String addZero(int value) {
    return value < 10 ? "0${value.toString()}" : value.toString();
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
                            Container(child: const Icon(Icons.directions_bus))),
                    Marker(
                        width: 100,
                        height: 100,
                        point: LatLng(selectedBusStop!.previousBusStopLatitude,
                            selectedBusStop!.previousBusStopLongitude),
                        builder: (ctx) =>
                            Container(child: const Icon(Icons.bus_alert))),
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
        padding: const EdgeInsets.only(top: 10),
        child: Column(children: [
          Text(
              "${_distanceToDestination != null ? _distanceToDestination.toString() : "0"} m",
              style: const TextStyle(fontSize: 48)),
          Row(
            children: [
              Expanded(
                  child: SmallInfo(icon: Icons.timelapse, value: _parsedTime)),
              const VerticalDivider(),
              Expanded(
                  child: SmallInfo(
                      icon: Icons.battery_full,
                      value: (currentBatteryLevel != null
                                  ? initialBatteryLevel! - currentBatteryLevel!
                                  : 0)
                              .toString() +
                          "%")),
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
                  padding: const EdgeInsets.all(10),
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
                      const Icon(
                        Icons.expand_more,
                      )
                    ],
                  ))),
          actions: [
            TextButton(
              child: Text(_isTracking ? "PRZERWIJ" : "ROZPOCZNIJ",
                  style: const TextStyle(color: Colors.white)),
              onPressed: () => _isTracking ? _stopTracking() : _startTracking(),
            )
          ],
        ),
        floatingActionButton: _isTracking
            ? FloatingActionButton(
                child: const Icon(Icons.gps_fixed),
                onPressed: () {
                  if (_currPosition != null) {
                    setState(() {
                      _mapController.move(_currPosition!, 12.5);
                    });
                  }
                },
              )
            : null,
        drawer: Drawer(
          child: ListView(
            reverse: true,
            children: [
              Text("Made with ❤️ by Arciiix",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
              Text(appVersion ?? "Unknown",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
              ListTile(
                  title: Text("Ustawienia"),
                  leading: Icon(Icons.settings),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => new Settings(),
                          fullscreenDialog: true)))
            ],
          ),
        ),
        body: Container(
          child: Center(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 18, child: buildMap()),
                    Expanded(flex: 5, child: buildInfo()),
                  ],
                )),
          ),
        ));
  }
}
