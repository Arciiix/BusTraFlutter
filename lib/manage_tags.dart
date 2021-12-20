import 'package:bustra/tag_form.dart';
import 'package:bustra/transactions.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/tag.dart';

class ManageTags extends StatefulWidget {
  final List<Tag>? checkedTags;

  const ManageTags({
    Key? key,
    this.checkedTags,
  }) : super(key: key);

  @override
  _ManageTagsState createState() => _ManageTagsState();
}

class _ManageTagsState extends State<ManageTags> {
  List<Tag> _checkedTags = [];

  void _addNewTag() async {
    Tag? newTag = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => TagForm(),
            fullscreenDialog: true));

    if (newTag != null) {
      final transaction = Transactions.getTag();
      transaction.add(newTag);
    }
  }

  void _editTag(Tag tag) async
  {
          _checkedTags.remove(tag);
      
        Tag? editedTag = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => TagForm(baseTag: tag),
            fullscreenDialog: true));

    if (editedTag != null) {
      final transaction = Transactions.getTag();
      transaction.put(tag.key, editedTag);
    }
  }

  void _deleteTag(Tag tag) async
  {
    AlertDialog removeConfirmation = AlertDialog(
      title: const Text("Usuń tag"),
      content: Text("Czy na pewno chcesz usunąć ${tag.label}?"),
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
      final transaction = Transactions.getTag();
      transaction.delete(tag.key);
      _checkedTags.remove(tag);
    }
  }

  @override
  void initState() {
    if (widget.checkedTags != null) {
      setState(() {
        _checkedTags = widget.checkedTags!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Wybierz tag"),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.pop(context, _checkedTags),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _addNewTag(),
        ),
        body: ValueListenableBuilder<Box<Tag>>(
            valueListenable: Transactions.getTag().listenable(),
            builder: (context, box, _) {
              final tags = box.values.toList().cast<Tag>();
              return buildList(tags);
            }));
  }

  Widget buildList(List<Tag> tags) {
    if (tags.isEmpty) {
      return const Center(
          child:
              Text("Nie masz żadnych tagów!", style: TextStyle(fontSize: 24)));
    } else {
      return Column(children: [
        Expanded(
            child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 60),
          itemCount: tags.length,
          itemBuilder: (BuildContext context, int index) {
            final tag = tags[index];
            return buildTag(context, tag);
          },
        ))
      ]);
    }
  }

  Widget buildTag(BuildContext context, Tag tag) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: InkWell(
            onTap: () => _changeChecked(!_checkedTags.contains(tag), tag),
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Checkbox(
                          value: _checkedTags.contains(tag),
                          onChanged: (checked) {
                            _changeChecked(checked, tag);
                          },
                        )),
                    Expanded(flex: 10, child: Text(tag.label)),
                    Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTag(tag)),
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editTag(tag)),
                          ],
                        ))
                  ],
                ))));
  }

  void _changeChecked(bool? checked, Tag tag) {
    checked ??= false;

    if (checked && !_checkedTags.contains(tag)) {
      setState(() {
        _checkedTags.add(tag);
      });
    }
    if (!checked && _checkedTags.contains(tag)) {
      setState(() {
        _checkedTags.remove(tag);
      });
    }
  }
}
