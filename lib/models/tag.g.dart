// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TagAdapter extends TypeAdapter<Tag> {
  @override
  final int typeId = 1;

  @override
  Tag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tag()
      ..assignedTo = (fields[0] as HiveList?)?.castHiveList()
      ..label = fields[1] as String
      ..color = fields[2] as int
      ..icon = fields[3] as Icon?;
  }

  @override
  void write(BinaryWriter writer, Tag obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.assignedTo)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
