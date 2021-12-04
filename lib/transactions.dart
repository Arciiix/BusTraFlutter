import "package:hive/hive.dart";
import "package:bustra/models/bus_stop.dart";

class Transactions {
  static Box<BusStop> getBusStop() => Hive.box<BusStop>('busStops');
}
