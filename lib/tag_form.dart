import 'package:flutter/material.dart';

import 'models/tag.dart';

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
  //TODO: Change the type to something primitive - Hive doesn't support Icons
  Icon? icon;

  @override
  void initState() {
    if (widget.baseTag != null) {
      setState(() {
        isEditing = widget.baseTag != null;
        _labelController.text = widget.baseTag?.label ?? "";
        color =
            Color(widget.baseTag?.color ?? Colors.blue.value).withOpacity(1);
        icon = widget.baseTag?.icon;
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
        ..icon = icon
        ..assignedTo = null;

      Navigator.pop(context, tag);
    }
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
            child: Column(
              children: [
                TextFormField(
                  controller: _labelController,
                  validator: validateLabel,
                  decoration: const InputDecoration(hintText: "Nazwa"),
                )
              ],
            )));
  }
}
