import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'habit.g.dart';

@JsonSerializable()
@HiveType(typeId: 4) // Use a unique typeId for Habit
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  int counterStreak;

  @HiveField(3)
  int counterLevel;

  @HiveField(4)
  DateTime? lastCheckedOffDate;

  @HiveField(5)
  bool isArchived; // For soft delete

  Habit({
    String? id,
    required this.description,
    this.counterStreak = 0,
    this.counterLevel = 0,
    this.lastCheckedOffDate,
    this.isArchived = false,
  }) : id = id ?? const Uuid().v4();

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
  Map<String, dynamic> toJson() => _$HabitToJson(this);

  bool get isCheckedOffToday {
    if (lastCheckedOffDate == null) return false;
    final now = DateTime.now();
    return lastCheckedOffDate!.year == now.year &&
        lastCheckedOffDate!.month == now.month &&
        lastCheckedOffDate!.day == now.day;
  }
}