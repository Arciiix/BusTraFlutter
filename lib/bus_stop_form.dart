import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BusStopForm extends StatefulWidget {
  @override
  State<BusStopForm> createState() => _BusStopFormState();
}

class _BusStopFormState extends State<BusStopForm> {
  final bool isEditing = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _destinationBusStopLatitudeController =
      TextEditingController();
  final TextEditingController _destinationBusStopLongitudeController =
      TextEditingController();
  final TextEditingController _previousBusStopLatitudeController =
      TextEditingController();
  final TextEditingController _previousBusStopLongitudeController =
      TextEditingController();

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<String?> getClipboardData() async {
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    if (cdata == null || cdata.text == null) {
      return null;
    } else {
      return cdata.text;
    }
  }

  Future<String?> pasteCoordinatesFromClipboard() async {
    String? clipboardContent = await getClipboardData();
    if (clipboardContent == null) {
    } else {
      //Replace commas with dots for compatibility
      clipboardContent = clipboardContent.replaceAll(",", ".");
      return clipboardContent;
    }
  }

  String? validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return "Wartość nie może być pusta.";
    }
    final RegExp latitudeRegExp =
        RegExp(r"^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$");

    if (latitudeRegExp.hasMatch(value)) {
      return null;
    } else {
      return "Niepoprawna wartość";
    }
  }

  String? validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return "Wartość nie może być pusta.";
    }
    final RegExp longitudeRegExp =
        RegExp(r"^[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$");

    if (longitudeRegExp.hasMatch(value)) {
      return null;
    } else {
      return "Niepoprawna wartość";
    }
  }

  void handleSave() {
    if (validateWholeForm()) {
      print("DEV - SAVE");
    }
  }

  bool validateWholeForm() {
    return _formKey.currentState!.validate() ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? "Edycja przystanku" : "Nowy przystanek"),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: "Zapisz",
              onPressed: handleSave,
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(5),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Nazwa",
                      ),
                      validator: (val) {
                        return val == null || val.isEmpty
                            ? "Nazwa nie może być pusta"
                            : null;
                      }),
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
                        TextFormField(
                          controller: _destinationBusStopLatitudeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: "Szerokość geograficzna",
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.paste),
                                onPressed: () async {
                                  String? content =
                                      await pasteCoordinatesFromClipboard();
                                  if (content != null) {
                                    setState(() {
                                      _destinationBusStopLatitudeController
                                          .text = content;
                                    });
                                    if (validateLatitude(content) != null) {
                                      showSnackBar(
                                          "Niepoprawna szerokość geograficzna!");
                                    }
                                  }
                                },
                              )),
                          validator: (value) {
                            return validateLatitude(value);
                          },
                        ),
                        TextFormField(
                            controller: _destinationBusStopLongitudeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: "Długość geograficzna",
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.paste),
                                  onPressed: () async {
                                    String? content =
                                        await pasteCoordinatesFromClipboard();
                                    if (content != null) {
                                      setState(() {
                                        _destinationBusStopLongitudeController
                                            .text = content;
                                      });
                                      if (validateLongitude(content) != null) {
                                        showSnackBar(
                                            "Niepoprawna długość geograficzna!");
                                      }
                                    }
                                  },
                                )),
                            validator: (value) {
                              return validateLongitude(value);
                            }),
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
                        TextFormField(
                          controller: _previousBusStopLatitudeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: "Szerokość geograficzna",
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.paste),
                                onPressed: () async {
                                  String? content =
                                      await pasteCoordinatesFromClipboard();
                                  if (content != null) {
                                    setState(() {
                                      _previousBusStopLatitudeController.text =
                                          content;
                                    });
                                    if (validateLatitude(content) != null) {
                                      showSnackBar(
                                          "Niepoprawna szerokość geograficzna!");
                                    }
                                  }
                                },
                              )),
                          validator: (value) {
                            return validateLatitude(value);
                          },
                        ),
                        TextFormField(
                            controller: _previousBusStopLongitudeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: "Długość geograficzna",
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.paste),
                                  onPressed: () async {
                                    String? content =
                                        await pasteCoordinatesFromClipboard();
                                    if (content != null) {
                                      setState(() {
                                        _previousBusStopLongitudeController
                                            .text = content;
                                      });
                                      if (validateLongitude(content) != null) {
                                        showSnackBar(
                                            "Niepoprawna długość geograficzna!");
                                      }
                                    }
                                  },
                                )),
                            validator: (value) {
                              return validateLongitude(value);
                            }),
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
            )));
  }
}
