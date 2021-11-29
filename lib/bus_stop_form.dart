import 'package:flutter/material.dart';

class BusStopForm extends StatefulWidget {
  @override
  State<BusStopForm> createState() => _BusStopFormState();
}

class _BusStopFormState extends State<BusStopForm> {
  final bool isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _destinationBusStopLatitudeController =
      TextEditingController();
  final TextEditingController _destinationBusStopLongitudeController =
      TextEditingController();
  final TextEditingController _previousBusStopLatitudeController =
      TextEditingController();
  final TextEditingController _previousBusStopLongitudeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? "Edycja przystanku" : "Nowy przystanek"),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: "Zapisz",
              onPressed: () => print("DEV - save bus stop form"),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nazwa",
                  )),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Text(
                      "Przystanek docelowy",
                      style: TextStyle(fontSize: 32),
                      textAlign: TextAlign.left,
                    ),
                    TextField(
                        controller: _destinationBusStopLatitudeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: "Szerokość geograficzna",
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: () => print("PASTE 1.1"),
                            ))),
                    TextField(
                        controller: _destinationBusStopLongitudeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: "Długość geograficzna",
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: () => print("PASTE 1.2"),
                            ))),
                    Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                            onPressed: () => print("PASTE FULL 1"),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.paste),
                                  Text("Wklej koordynaty")
                                ])))
                  ],
                )),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Text(
                      "Przystanek poprzedzający",
                      style: TextStyle(fontSize: 32),
                      textAlign: TextAlign.left,
                    ),
                    TextField(
                        controller: _previousBusStopLatitudeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: "Szerokość geograficzna",
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: () => print("PASTE 2.1"),
                            ))),
                    TextField(
                        controller: _previousBusStopLongitudeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: "Długość geograficzna",
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: () => print("PASTE 2.2"),
                            ))),
                    Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                            onPressed: () => print("PASTE FULL 2"),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.paste),
                                  Text("Wklej koordynaty")
                                ])))
                  ],
                )),
          ])),
        ));
  }
}
