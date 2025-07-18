// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 4;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String?,
      description: fields[1] as String,
      counterStreak: fields[2] as int,
      counterLevel: fields[3] as int,
      lastCheckedOffDate: fields[4] as DateTime?,
      isArchived: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.counterStreak)
      ..writeByte(3)
      ..write(obj.counterLevel)
      ..writeByte(4)
      ..write(obj.lastCheckedOffDate)
      ..writeByte(5)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Habit _$HabitFromJson(Map<String, dynamic> json) => Habit(
      id: json['id'] as String?,
      description: json['description'] as String,
      counterStreak: (json['counterStreak'] as num?)?.toInt() ?? 0,
      counterLevel: (json['counterLevel'] as num?)?.toInt() ?? 0,
      lastCheckedOffDate: json['lastCheckedOffDate'] == null
          ? null
          : DateTime.parse(json['lastCheckedOffDate'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
    );

Map<String, dynamic> _$HabitToJson(Habit instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'counterStreak': instance.counterStreak,
      'counterLevel': instance.counterLevel,
      'lastCheckedOffDate': instance.lastCheckedOffDate?.toIso8601String(),
      'isArchived': instance.isArchived,
    };
