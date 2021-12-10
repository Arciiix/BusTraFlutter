import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bustra/select_bus_stop.dart';
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

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  @override
  void initState() {
    super.initState();
    /*
    Geofence.initialize();
    Geofence.requestPermissions();
  */

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
                    onPressed: () async {
                      print("CREATE NOTIFICATION");
                      AwesomeNotifications().createNotification(
                          content: NotificationContent(
                            id: generateUniqueId(),
                            channelKey: 'bustra_notifications',
                            title: 'Testowe powiadomienie',
                            body: 'Lorem ipsum dolor sit amet',
                          ),
                          actionButtons: [
                            NotificationActionButton(
                                key: "STOP_TRACKING",
                                label: "Przerwij trackowanie")
                          ]);
                    },
                    child: const Text("Rozpocznij")),
              ],
            )),
      ),
    ));
  }
}
