import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bustra/notification.dart';
import 'package:bustra/utils/generate_unique_id.dart';
import 'package:flutter/material.dart';
import "dart:async";
import 'package:background_location/background_location.dart';

import 'package:latlong2/latlong.dart';

const Distance distance = Distance();

bool didSendNotification = false;

void startTracking() async {
  didSendNotification = false;
  BackgroundLocation.setAndroidNotification(
    title: "BusTra - tracking",
    message: "Aplikacja BusTra działa w tle.",
  );

  BackgroundLocation.setAndroidConfiguration(5000);
  BackgroundLocation.startLocationService();
  BackgroundLocation.getLocationUpdates((location) {
    print("${location.latitude}, ${location.longitude}");
    if (location.latitude != null && location.longitude != null) {
      bool isNearTheBusStop = calculateGeofence(
          LatLng(location.latitude as double, location.longitude as double),
          //DEV
          LatLng(0, 0),
          400);

      if (isNearTheBusStop && !didSendNotification) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: generateUniqueId(),
              channelKey: 'bustra_notifications',
              title: 'BusTra - przystanek docelowy',
              body: 'Zbliżasz się do przystanku docelowego.',
            ),
            actionButtons: [
              NotificationActionButton(
                  key: "STOP_TRACKING", label: "Przerwij trackowanie")
            ]);
        didSendNotification = true;
      }
    } else {
      print("NULL LOCATION");
    }
  });
}

bool calculateGeofence(
    LatLng currentLocation, LatLng regionCenter, double radius) {
  //Using Pythagorean theorem to determine if the user is inside the circle with radius equal to the variable radius and center equal to variable regionCetner

  double distanceUserToCenter =
      distance.as(LengthUnit.Meter, currentLocation, regionCenter);

  print(distanceUserToCenter);

  if (radius >= distanceUserToCenter) {
    return true;
  }
  return false;
}
