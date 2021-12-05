import 'package:bustra/transactions.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/bus_stop.dart';

class SelectBusStop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(title: const Text("Wybierz przystanek")),
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
      return Center(
          child: Text(
        'Brak przystanków!',
        style: TextStyle(fontSize: 24),
      ));
    } else {
      return Column(children: [
        Expanded(
            child: ListView.builder(
                itemCount: busStops.length,
                itemBuilder: (BuildContext context, int index) {
                  final busStop = busStops[index];

                  return buildBusStop(context, busStop);
                }))
      ]);
    }
  }

  Widget buildBusStop(BuildContext context, BusStop busStop) {
    //TODO: Make the card display the name, destination bus stop, previous bus stop and the edit and delete button (and make them work)
    return Padding(
        padding: EdgeInsets.all(10),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  busStop.name ?? "",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    //TODO: Fix - the text musn't overflow the screen
                                    fontSize: 24,
                                  ),
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.label_outlined),
                                        Text(
                                          "${busStop.destinationBusStopLatitude}, ${busStop.destinationBusStopLongitude}",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ]),
                                      Row(children: [
                                        Icon(Icons.flag_outlined),
                                        Text(
                                          "${busStop.previousBusStopLatitude}, ${busStop.previousBusStopLongitude}",
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
                          onPressed: () => print("DELETE"),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => print("EDIT"),
                        ),
                      ],
                    ))
              ],
            )));
  }
}
