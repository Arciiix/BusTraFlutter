import "package:hive/hive.dart";
import "package:bustra/models/bus_stop.dart";
import 'models/tag.dart';

class Transactions {
  static Box<BusStop> getBusStop() => Hive.box<BusStop>('busStops');
  static Box<Tag> getTag() => Hive.box<Tag>('tags');
}
