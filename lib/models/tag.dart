import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'tag.g.dart';

@HiveType(typeId: 1)
class Tag extends HiveObject {
  @HiveField(0)
  late HiveList? assignedTo;

  @HiveField(1)
  late String label;

  @HiveField(2)
  //Color.value
  late int color;

  @HiveField(3)
  late Icon? icon;
}
