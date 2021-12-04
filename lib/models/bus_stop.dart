import 'package:hive/hive.dart';

import 'package:latlong2/latlong.dart';

part 'bus_stop.g.dart';

@HiveType(typeId: 0)
class BusStop extends HiveObject {
  @HiveField(0)
  late String? name;

  @HiveField(1)
  late double destinationBusStopLatitude;
  @HiveField(2)
  late double destinationBusStopLongitude;

  @HiveField(3)
  late double previousBusStopLatitude;
  @HiveField(4)
  late double previousBusStopLongitude;
}
