import 'package:bustra/models/bus_stop.dart';
import 'package:bustra/models/tag.dart';
import 'package:bustra/transactions.dart';

List<Tag> getBusStopTags(BusStop busStop) {
  final tagsTransaction = Transactions.getTag();
  final dbTags = tagsTransaction.values.toList();
  return dbTags
      .where((element) => element.assignedTo.contains(busStop))
      .cast<Tag>()
      .toList();
}
