import 'package:bustra/bus_stop_form.dart';
import 'package:bustra/bus_stop_from_list.dart';
import 'package:bustra/transactions.dart';
import 'package:bustra/utils/bus_stop_types.dart';
import 'package:bustra/utils/get_bus_stop_tags.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import "package:bustra/utils/show_snackbar.dart";

import 'models/bus_stop.dart';
import 'models/tag.dart';

class SelectBusStop extends StatefulWidget {
  @override
  State<SelectBusStop> createState() => _SelectBusStopState();
}

class _SelectBusStopState extends State<SelectBusStop> {
  Future<void> _createBusStop({bool fromList = true}) async {
    BusStopUnsaved? busStop = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                fromList ? BusStopFromList() : BusStopForm(),
            fullscreenDialog: true));

    if (busStop != null) {
      final transaction = Transactions.getBusStop();
      int key = await transaction.add(busStop.busStopObj);

      final BusStop? addedObj = transaction.get(key);

      if (addedObj != null) {
        final tagsTransaction = await Transactions.getTag();
        final tags = tagsTransaction.values.toList();
        tags.forEach((element) {
          if (busStop.tags.contains(element) &&
              !element.assignedTo.contains(addedObj)) {
            element.assignedTo.add(addedObj);
          }
          if (!busStop.tags.contains(element) &&
              element.assignedTo.contains(addedObj)) {
            element.assignedTo.remove(addedObj);
          }
          element.save();
        });
      }

      showSnackBar(context, "Dodano nowy przystanek!");
    }
  }

  Future<void> _deleteBusStop(BusStop stop) async {
    AlertDialog removeConfirmation = AlertDialog(
      title: const Text("Usuń przystanek"),
      content: Text("Czy na pewno chcesz usunąć ${stop.name}?"),
      actions: [
        TextButton(
            child: const Text("Anuluj"),
            onPressed: () {
              Navigator.of(context).pop(false);
            }),
        TextButton(
            child: const Text("Usuń"),
            onPressed: () {
              Navigator.of(context).pop(true);
            })
      ],
    );

    bool? userResponse = await showDialog<bool?>(
        context: context,
        builder: (BuildContext context) => removeConfirmation);

    if (userResponse != null && userResponse) {
      print("REMOVE BUS STOP WITH KEY ${stop.key}");
      final transaction = Transactions.getBusStop();
      transaction.delete(stop.key);
    }
  }

  Future<void> _editBusStop(BusStop stop) async {
    BusStopUnsaved? editedBusStop = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => BusStopForm(baseBusStop: stop),
            fullscreenDialog: true));

    if (editedBusStop != null) {
      final transaction = Transactions.getBusStop();
      transaction.put(stop.key, editedBusStop.busStopObj);

      if (editedBusStop.busStopObj != null) {
        final tagsTransaction = Transactions.getTag();
        final tags = tagsTransaction.values.toList();
        tags.forEach((element) {
          if (editedBusStop.tags.contains(element) &&
              !element.assignedTo.contains(editedBusStop.busStopObj)) {
            element.assignedTo.add(editedBusStop.busStopObj);
          }
          if (!editedBusStop.tags.contains(element) &&
              element.assignedTo.contains(editedBusStop.busStopObj)) {
            element.assignedTo.remove(editedBusStop.busStopObj);
          }
          element.save();
        });
      }
      showSnackBar(context, "Zmodyfikowano przystanek!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(title: const Text("Wybierz przystanek")),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 20,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_location),
            label: "Dodaj ręcznie",
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            onTap: () => _createBusStop(fromList: false),
          ),
          SpeedDialChild(
            child: const Icon(Icons.list),
            label: "Wybierz z listy",
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            onTap: () => _createBusStop(fromList: true),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<BusStop>>(
          valueListenable: Transactions.getBusStop().listenable(),
          builder: (context, box, _) {
            final busStops = box.values.toList().cast<BusStop>();
            return buildList(busStops);
          }),
    ));
  }

  Widget buildList(List<BusStop> busStops) {
    if (busStops.isEmpty) {
      return const Center(
          child: Text(
        'Brak przystanków!',
        style: TextStyle(fontSize: 24),
      ));
    } else {
      return Column(children: [
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 60),
                itemCount: busStops.length,
                itemBuilder: (BuildContext context, int index) {
                  final busStop = busStops[index];
                  return buildBusStop(context, busStop);
                }))
      ]);
    }
  }

  Widget buildBusStop(BuildContext context, BusStop busStop) {
    final List<Tag> tags = getBusStopTags(busStop);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
            onTap: () => Navigator.pop(context, busStop),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 9,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  busStop.name ?? "",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        const Icon(Icons.label_outlined),
                                        Text(
                                          "${busStop.destinationBusStopLatitude}\n${busStop.destinationBusStopLongitude}",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ]),
                                      Row(children: [
                                        const Icon(Icons.flag_outlined),
                                        Text(
                                          "${busStop.previousBusStopLatitude}\n${busStop.previousBusStopLongitude}",
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ])
                                    ]),
                                Wrap(
                                    clipBehavior: Clip.antiAlias,
                                    direction: Axis.vertical,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: List<Widget>.generate(
                                      tags.length,
                                      (int id) {
                                        Tag tag = tags[id];
                                        return Chip(
                                          label: Text(tag.label,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color(tag.color)
                                                              .computeLuminance() >
                                                          0.5
                                                      ? Colors.black
                                                      : Colors.white)),
                                          backgroundColor:
                                              Color(tag.color).withOpacity(1),
                                        );
                                        ;
                                      },
                                    ))
                              ],
                            )),
                      ],
                    )),
                Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteBusStop(busStop),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editBusStop(busStop),
                        ),
                      ],
                    ))
              ],
            )));
  }
}
