import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bustra/models/bus_stop.dart';
import 'package:bustra/select_bus_stop.dart';
import 'package:bustra/tracking.dart';
import 'package:bustra/utils/generate_unique_id.dart';
import 'package:bustra/utils/get_permissions.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

//import 'package:flutter_geofence/Geolocation.dart';
//import 'package:flutter_geofence/geofence.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? osVersion;

  BusStop? selectedBusStop;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Expanded(
              child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onTap: () => _selectBusStop(context),
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            selectedBusStop != null
                                ? selectedBusStop?.name ??
                                    "Przystanek bez nazwy"
                                : "Wybierz przystanek",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                          )),
                          Icon(
                            Icons.expand_more,
                          )
                        ],
                      )))),
          actions: [
            TextButton(
              child: Text("ROZPOCZNIJ", style: TextStyle(color: Colors.white)),
              onPressed: () => print("START_TRACKING"),
            )
          ],
        ),
        body: Container(
          child: Center(
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Hello?")],
                )),
          ),
        ));
  }
}
