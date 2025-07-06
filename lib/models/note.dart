import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note.g.dart';

@HiveType(typeId: 3)
class Note {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  DateTime updatedAt;

  @HiveField(3)
  List<String> tags;

  Note({
    String? id,
    required this.text,
    List<String>? tags,
  })  : id = id ?? const Uuid().v4(),
        updatedAt = DateTime.now(),
        tags = tags ?? [];
}