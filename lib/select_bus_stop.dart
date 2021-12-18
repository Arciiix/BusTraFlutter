import 'package:bustra/bus_stop_form.dart';
import 'package:bustra/transactions.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/bus_stop.dart';

import "package:bustra/utils/show_snackbar.dart";

class SelectBusStop extends StatefulWidget {
  @override
  State<SelectBusStop> createState() => _SelectBusStopState();
}

class _SelectBusStopState extends State<SelectBusStop> {
  Future<void> _createBusStop() async {
    BusStop? busStop = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => BusStopForm(),
            fullscreenDialog: true));

    if (busStop != null) {
      final transaction = Transactions.getBusStop();
      transaction.add(busStop);
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
    BusStop? editedBusStop = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => BusStopForm(baseBusStop: stop),
            fullscreenDialog: true));

    if (editedBusStop != null) {
      final transaction = Transactions.getBusStop();
      transaction.put(stop.key, editedBusStop);
      showSnackBar(context, "Zmodyfikowano przystanek!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(title: const Text("Wybierz przystanek")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _createBusStop(),
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
                        const Expanded(
                            flex: 4,
                            child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Chip(
                                  label: Text(
                                    //Think what to do if text overflows
                                    "LABEL",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))),
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
                                    ])
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
