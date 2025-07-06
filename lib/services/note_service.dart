import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracker/models/note.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();

  late Box<Note> _noteBox;

  Future<void> init() async {
    Hive.registerAdapter(NoteAdapter());
    _noteBox = await Hive.openBox<Note>('notes');
  }

  List<Note> getNotes() {
    return _noteBox.values.toList();
  }

  void addNote(Note note) {
    _noteBox.put(note.id, note);
  }

  void updateNote(Note note) {
    _noteBox.put(note.id, note);
  }

  void deleteNote(String id) {
    _noteBox.delete(id);
  }
}
