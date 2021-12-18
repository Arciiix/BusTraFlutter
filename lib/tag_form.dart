import 'package:bustra/transactions.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'models/tag.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TagForm extends StatefulWidget {
  @override
  _TagFormState createState() => _TagFormState();

  final Tag? baseTag;

  const TagForm({Key? key, this.baseTag}) : super(key: key);
}

class _TagFormState extends State<TagForm> {
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _labelController = TextEditingController();
  Color color = Colors.blue;
  Color pickerColor = Colors.blue;

  @override
  void initState() {
    if (widget.baseTag != null) {
      setState(() {
        isEditing = widget.baseTag != null;
        _labelController.text = widget.baseTag?.label ?? "";
        color =
            Color(widget.baseTag?.color ?? Colors.blue.value).withOpacity(1);
      });
    }
  }

  String? validateLabel(String? text) {
    if (text == null || text.isEmpty) {
      return "Nazwa nie może być pusta!";
    } else {
      return null;
    }
  }

  void _saveTag() {
    if (_formKey.currentState!.validate()) {
      Tag tag = Tag()
        ..label = _labelController.text
        ..color = color.value
        ..assignedTo = HiveList(Transactions.getBusStop());

      Navigator.pop(context, tag);
    }
  }

  void _changeColor() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Wybierz kolor'),
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: pickerColor,
                onColorChanged: _changePickerColor,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Zatwierdź'),
                onPressed: () {
                  //TODO: If the color is more dark, change the text color to white and vice versa
                  setState(() => color = pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _changePickerColor(Color c) {
    setState(() => pickerColor = c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? "Edycja tagu" : "Nowy tag"),
          actions: [
            IconButton(
                icon: const Icon(Icons.save),
                tooltip: "Zapisz",
                onPressed: _saveTag)
          ],
        ),
        body: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _labelController,
                          validator: validateLabel,
                          decoration: const InputDecoration(hintText: "Nazwa"),
                        )),
                    SizedBox(height: 20),
                    InkWell(
                        onTap: _changeColor,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Kolor", style: TextStyle(fontSize: 24)),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: color,
                                ),
                              )
                            ],
                          ),
                        )),
                    SizedBox(height: 20),
                  ],
                ))));
  }
}
