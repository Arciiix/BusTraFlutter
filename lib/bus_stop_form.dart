import 'package:bustra/manage_tags.dart';
import 'package:bustra/models/bus_stop.dart';
import 'package:bustra/transactions.dart';
import 'package:bustra/utils/get_bus_stop_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'models/tag.dart';
import "package:bustra/utils/show_snackbar.dart";

class BusStopForm extends StatefulWidget {
  @override
  State<BusStopForm> createState() => _BusStopFormState();

  final BusStop? baseBusStop;

  const BusStopForm({Key? key, this.baseBusStop}) : super(key: key);
}

class _BusStopFormState extends State<BusStopForm> {
  bool isEditing = false;

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
  List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.baseBusStop != null) {
      isEditing = true;
      _nameController.text = widget.baseBusStop!.name!;
      _destinationBusStopLatitudeController.text =
          widget.baseBusStop!.destinationBusStopLatitude.toString();
      _destinationBusStopLongitudeController.text =
          widget.baseBusStop!.destinationBusStopLongitude.toString();
      _previousBusStopLatitudeController.text =
          widget.baseBusStop!.previousBusStopLatitude.toString();
      _previousBusStopLongitudeController.text =
          widget.baseBusStop!.previousBusStopLongitude.toString();

      _tags = getBusStopTags(widget.baseBusStop!);
    } else {
      isEditing = false;
    }
  }

  void _showSnackBar(String message) {
    showSnackBar(context, message);
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

  Future<LatLng?> pasteFullCoordinates() async {
    String? clipboardData = await getClipboardData();
    if (clipboardData == null || clipboardData.isEmpty) {
      _showSnackBar("Pusty schowek");
      return null;
    }

    List<String> clipboardCoordinates = clipboardData.split(", ");
    if (clipboardCoordinates.length != 2) {
      _showSnackBar("Zły format koordynatów");
      return null;
    } else {
      if (isNumeric(clipboardCoordinates[0]) &&
          isNumeric(clipboardCoordinates[1]) &&
          validateLatitude(clipboardCoordinates[0]) == null &&
          validateLatitude(clipboardCoordinates[1]) == null) {
        //When it comes to the validateLatitude function, null means that it is valid - non-null value (string) means an error - the function returns its description
        LatLng parsedCoordinates = LatLng(double.parse(clipboardCoordinates[0]),
            double.parse(clipboardCoordinates[1]));
        return parsedCoordinates;
      } else {
        _showSnackBar("Niepoprawne koordynaty");
        return null;
      }
    }
  }

  bool isNumeric(String? text) {
    if (text == null) {
      return false;
    }
    return double.tryParse(text) != null;
  }

  String? validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return "Wartość nie może być pusta";
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
      return "Wartość nie może być pusta";
    }
    final RegExp longitudeRegExp =
        RegExp(r"^[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$");

    if (longitudeRegExp.hasMatch(value)) {
      return null;
    } else {
      return "Niepoprawna wartość";
    }
  }

  void handleSave(BuildContext context) {
    //TODO: Replace comma (,) with a dot (.) in the coordinates inputs
    if (validateWholeForm()) {
      final busStopObj = BusStop()
        ..name = _nameController.text
        ..destinationBusStopLatitude =
            double.parse(_destinationBusStopLatitudeController.text)
        ..destinationBusStopLongitude =
            double.parse(_destinationBusStopLongitudeController.text)
        ..previousBusStopLatitude =
            double.parse(_previousBusStopLatitudeController.text)
        ..previousBusStopLongitude =
            double.parse(_previousBusStopLongitudeController.text);

      final BusStopUnsaved returnBusStopVal = BusStopUnsaved(busStopObj, _tags);
      Navigator.pop(context, returnBusStopVal);
    }
  }

  bool validateWholeForm() {
    return _formKey.currentState!.validate();
  }

  void _addTag() async {
    List<Tag>? tags = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ManageTags(checkedTags: _tags),
            fullscreenDialog: true));

    if (tags != null) {
      setState(() {
        _tags = tags;
      });
    }
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
              onPressed: () => handleSave(context),
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
                      decoration: const InputDecoration(
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
                                      _showSnackBar(
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
                                        _showSnackBar(
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
                                onPressed: () async {
                                  LatLng? coordinates =
                                      await pasteFullCoordinates();
                                  if (coordinates != null) {
                                    setState(() {
                                      _destinationBusStopLatitudeController
                                              .text =
                                          coordinates.latitude.toString();
                                      _destinationBusStopLongitudeController
                                              .text =
                                          coordinates.longitude.toString();
                                    });
                                  }
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
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
                                      _showSnackBar(
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
                                        _showSnackBar(
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
                                onPressed: () async {
                                  LatLng? coordinates =
                                      await pasteFullCoordinates();
                                  if (coordinates != null) {
                                    setState(() {
                                      _previousBusStopLatitudeController.text =
                                          coordinates.latitude.toString();
                                      _previousBusStopLongitudeController.text =
                                          coordinates.longitude.toString();
                                    });
                                  }
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.paste),
                                      Text("Wklej koordynaty")
                                    ])))
                      ],
                    )),
                Column(
                  children: [
                    const Text(
                      "Tagi",
                      style: TextStyle(fontSize: 32),
                      textAlign: TextAlign.left,
                    ),
                    Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: List<Widget>.generate(
                          _tags.length,
                          (int id) {
                            Tag tag = _tags[id];
                            return Chip(
                              label: Text(tag.label),
                              deleteIcon: Icon(Icons.close),
                              onDeleted: () => setState(() {
                                _tags.remove(tag);
                              }),
                              backgroundColor: Color(tag.color).withOpacity(1),
                            );
                            ;
                          },
                        )),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Dodaj tag"),
                      onPressed: () => _addTag(),
                    )
                  ],
                )
              ])),
            )));
  }
}

class BusStopUnsaved {
  BusStop busStopObj;
  List<Tag> tags;

  BusStopUnsaved(this.busStopObj, this.tags);
}
