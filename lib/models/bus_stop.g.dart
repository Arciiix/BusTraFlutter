// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_stop.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusStopAdapter extends TypeAdapter<BusStop> {
  @override
  final int typeId = 0;

  @override
  BusStop read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusStop()
      ..name = fields[0] as String?
      ..destinationBusStopLatitude = fields[1] as double
      ..destinationBusStopLongitude = fields[2] as double
      ..previousBusStopLatitude = fields[3] as double
      ..previousBusStopLongitude = fields[4] as double;
  }

  @override
  void write(BinaryWriter writer, BusStop obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.destinationBusStopLatitude)
      ..writeByte(2)
      ..write(obj.destinationBusStopLongitude)
      ..writeByte(3)
      ..write(obj.previousBusStopLatitude)
      ..writeByte(4)
      ..write(obj.previousBusStopLongitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusStopAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
