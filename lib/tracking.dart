import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bustra/notification.dart';
import 'package:bustra/utils/generate_unique_id.dart';
import 'package:flutter/material.dart';
import "dart:async";
import 'package:background_location/background_location.dart';

import 'package:latlong2/latlong.dart';

class Tracking {
  static const Distance distance = Distance();

  static bool didSendNotification = false;
  static bool didSendPreviousStopNotification = false;
  static LatLng? _currentPosition;
  static LatLng? _destinationBusStop;
  static LatLng? _previousBusStop;

  static void startTracking(LatLng destBusStop, LatLng prevBusStop,
      void Function(LatLng? currPos, double? distanceToDestination) cb) async {
    _destinationBusStop = destBusStop;
    _previousBusStop = prevBusStop;

    didSendNotification = false;
    BackgroundLocation.setAndroidNotification(
      title: "BusTra - tracking",
      message: "Aplikacja BusTra działa w tle.",
    );

    BackgroundLocation.setAndroidConfiguration(5000);
    BackgroundLocation.startLocationService(distanceFilter: 10);
    BackgroundLocation.getLocationUpdates((location) {
      if (location.latitude != null && location.longitude != null) {
        _currentPosition =
            LatLng(location.latitude as double, location.longitude as double);
        print("CURRENT POS: ${_currentPosition.toString()}");

        bool isNearTheBusStop = calculateGeofence(
            LatLng(location.latitude as double, location.longitude as double),
            _destinationBusStop!,
            100);

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
                    key: "STOP_TRACKING", label: "Przerwij trackowanie"),
                NotificationActionButton(
                    key: "REMIND_ME", label: "Przypomnij za chwilę")
              ]);
          didSendNotification = true;
        }

        bool isNearThePreviousBusStop = calculateGeofence(
            LatLng(location.latitude as double, location.longitude as double),
            _previousBusStop!,
            100);

        if (isNearThePreviousBusStop && !didSendPreviousStopNotification) {
          AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: generateUniqueId(),
                channelKey: 'bustra_notifications',
                title: 'BusTra - przystanek poprzedzający',
                body: 'Jesteś 1 przystanek przed swoim celem.',
              ),
              actionButtons: [
                NotificationActionButton(
                    key: "STOP_TRACKING", label: "Przerwij trackowanie"),
                NotificationActionButton(
                    key: "REMIND_ME", label: "Przypomnij za chwilę")
              ]);
          didSendPreviousStopNotification = true;
        }
        cb(
            _currentPosition,
            distance.as(
                LengthUnit.Meter, _currentPosition!, _destinationBusStop!));

        BackgroundLocation.setAndroidNotification(
          title: "BusTra - tracking",
          message:
              "Aplikacja BusTra działa w tle. Pozostało ${distance.as(LengthUnit.Meter, _currentPosition!, _destinationBusStop!)} m",
        );
      } else {
        print("NULL LOCATION");
      }
    });
  }

  static void stopTracking() async {
    BackgroundLocation.stopLocationService();
    didSendNotification = false;
    didSendPreviousStopNotification = false;
  }

  static bool calculateGeofence(
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
}
