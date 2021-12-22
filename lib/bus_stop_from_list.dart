import 'package:bustra/manage_tags.dart';
import 'package:bustra/map_picker.dart';
import 'package:bustra/models/bus_stop.dart';
import 'package:bustra/transactions.dart';
import 'package:bustra/utils/bus_stop_types.dart';
import 'package:bustra/utils/get_bus_stop_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'models/tag.dart';
import "package:bustra/utils/show_snackbar.dart";

class BusStopFromList extends StatefulWidget {
  @override
  State<BusStopFromList> createState() => _BusStopFromListState();

  final BusStop? baseBusStop;

  const BusStopFromList({Key? key, this.baseBusStop}) : super(key: key);
}

class _BusStopFromListState extends State<BusStopFromList> {
  bool isEditing = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _fieldKeys = {
    'route': GlobalKey<FormFieldState>(),
    'destinationBusStop': GlobalKey<FormFieldState>(),
    'previousBusStop': GlobalKey<FormFieldState>(),
    'name': GlobalKey<FormFieldState>(),
  };

  final TextEditingController _nameController = TextEditingController();

  String? selectedRoute;
  BusStopListEntry? destinationBusStop;
  BusStopListEntry? previousBusStop;
  List<Tag> _tags = [];

  //DEV
  //TODO: Get it from the backend
  List<String> routes = [];
  List<BusStopListEntry> listBusStops = [];

  int _stepperStep = 0;
  List<String> _steps = [
    "route",
    "destinationBusStop",
    'previousBusStop',
    'name',
    'tags'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.baseBusStop != null) {
      isEditing = true;
      //DEV
      //TODO: Set the values to fit the base busStop

      _nameController.text = widget.baseBusStop!.name!;

      _tags = getBusStopTags(widget.baseBusStop!);
    } else {
      isEditing = false;
    }
  }

  void _showSnackBar(String message) {
    showSnackBar(context, message);
  }

  void handleSave(BuildContext context) {
    if (validateWholeForm()) {
      //DEV
      //TODO: Save
      print("SAVE");
      Navigator.pop(context, null);
      /*
      final busStopObj = BusStop()..name = _nameController.text;

      final BusStopUnsaved returnBusStopVal = BusStopUnsaved(busStopObj, _tags);
      Navigator.pop(context, returnBusStopVal);
      */
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
      ),
      body: Form(
          key: _formKey,
          child: Stepper(
              type: StepperType.vertical,
              currentStep: _stepperStep,
              controlsBuilder: (BuildContext context,
                  {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: onStepCancel,
                      child: const Text('Cofnij'),
                    ),
                    ElevatedButton(
                      onPressed: onStepContinue,
                      child: Text(_stepperStep == _steps.length - 1
                          ? "Zapisz"
                          : 'Dalej'),
                    ),
                  ],
                );
              },
              onStepCancel: () {
                if (_stepperStep > 0) {
                  setState(() {
                    _stepperStep -= 1;
                  });
                }
              },
              onStepContinue: () {
                if (_stepperStep < _steps.length - 1) {
                  if (_fieldKeys[_steps[_stepperStep]]
                          ?.currentState
                          ?.validate() ??
                      true) {
                    setState(() {
                      _stepperStep += 1;
                    });
                  }
                } else {
                  handleSave(context);
                }
              },
              steps: [
                Step(
                  title: const Text('Linia'),
                  content: DropdownButtonFormField(
                      key: _fieldKeys['route'],
                      value: selectedRoute,
                      validator: (val) {
                        return val == null ? "Wybierz linię" : null;
                      },
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRoute = newValue;
                        });
                      },
                      items: routes
                          .map((String routeName) => DropdownMenuItem<String>(
                              value: routeName, child: Text(routeName)))
                          .toList()),
                ),
                Step(
                  title: const Text('Przystanek docelowy'),
                  content: DropdownButtonFormField(
                      key: _fieldKeys['destinationBusStop'],
                      value: destinationBusStop?.id.toString(),
                      validator: (val) {
                        return val == null
                            ? "Wybierz przystanek docelowy"
                            : null;
                      },
                      onChanged: (String? newId) {
                        setState(() {
                          destinationBusStop = listBusStops.firstWhere(
                              (element) =>
                                  element.id == int.tryParse(newId ?? ""));
                          //The previous bus stop will be probaby the one before the destination bus stop, so let's show user a hint (assuming the element isn't the first one in the array and user hasn't selected previous bus stop)
                          int destinationBusStopIndex =
                              listBusStops.indexOf(destinationBusStop!);
                          if (destinationBusStopIndex > 0 &&
                              previousBusStop == null) {
                            previousBusStop =
                                listBusStops[destinationBusStopIndex - 1];
                          }
                        });
                      },
                      items: listBusStops
                          .map((BusStopListEntry entry) =>
                              DropdownMenuItem<String>(
                                  value: entry.id.toString(),
                                  child: Text(entry.name)))
                          .toList()),
                ),
                Step(
                  title: Text('Przystanek poprzedzający'),
                  content: DropdownButtonFormField(
                      key: _fieldKeys['previousBusStop'],
                      value: previousBusStop?.id.toString(),
                      validator: (val) {
                        if (val == null)
                          return "Wybierz przystanek poprzedzający";
                        if (previousBusStop == destinationBusStop)
                          return "Przystanek poprzedzający nie może być docelowym";
                        return null;
                      },
                      onChanged: (String? newId) {
                        setState(() {
                          previousBusStop = listBusStops.firstWhere((element) =>
                              element.id == int.tryParse(newId ?? ""));
                        });
                      },
                      items: listBusStops
                          .map((BusStopListEntry entry) =>
                              DropdownMenuItem<String>(
                                  value: entry.id.toString(),
                                  child: Text(entry.name)))
                          .toList()),
                ),
                Step(
                  title: Text('Nazwa'),
                  content: TextFormField(
                      controller: _nameController,
                      key: _fieldKeys['name'],
                      decoration: const InputDecoration(
                        labelText: "Nazwa",
                      ),
                      maxLength: 255,
                      validator: (val) {
                        return val == null || val.isEmpty
                            ? "Nazwa nie może być pusta"
                            : null;
                      }),
                ),
                Step(
                    title: Text('Tagi'),
                    content: Column(
                      children: [
                        Wrap(
                            direction: Axis.vertical,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: List<Widget>.generate(
                              _tags.length,
                              (int id) {
                                Tag tag = _tags[id];
                                return Chip(
                                  label: Text(tag.label,
                                      style: TextStyle(
                                          color: Color(tag.color)
                                                      .computeLuminance() >
                                                  0.5
                                              ? Colors.black
                                              : Colors.white)),
                                  deleteIcon: Icon(Icons.close,
                                      color:
                                          Color(tag.color).computeLuminance() >
                                                  0.5
                                              ? Colors.black
                                              : Colors.white),
                                  onDeleted: () => setState(() {
                                    _tags.remove(tag);
                                  }),
                                  backgroundColor:
                                      Color(tag.color).withOpacity(1),
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
                    )),
              ])),
    );
  }
}
