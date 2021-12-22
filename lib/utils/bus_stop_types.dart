import 'package:bustra/models/bus_stop.dart';
import 'package:bustra/models/tag.dart';
import 'package:latlong2/latlong.dart';

class BusStopUnsaved {
  BusStop busStopObj;
  List<Tag> tags;

  BusStopUnsaved(this.busStopObj, this.tags);
}

class BusStopListDBEntry {
  final int id;
  final String friendlyId;
  final String name;
  BusStopListDBEntry(
      {required this.id, required this.friendlyId, required this.name});
}

class BusStopListEntry extends BusStopListDBEntry {
  final LatLng coordinates;

  BusStopListEntry(
      {required this.coordinates,
      required int id,
      required String friendlyId,
      required String name})
      : super(id: id, friendlyId: friendlyId, name: name);
}
