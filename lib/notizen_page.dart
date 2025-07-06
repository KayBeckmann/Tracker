import 'package:flutter/material.dart';
import 'package:tracker/models/note.dart';
import 'package:tracker/services/note_service.dart';
import 'package:tracker/note_edit_page.dart';
import 'package:tracker/note_read_page.dart';

class NotizenPage extends StatefulWidget {
  final String? selectedTag;
  const NotizenPage({super.key, this.selectedTag});

  @override
  State<NotizenPage> createState() => _NotizenPageState();
}

class _NotizenPageState extends State<NotizenPage> {
  final NoteService _noteService = NoteService();
  List<Note> _notes = [];
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.selectedTag;
    _loadNotes();
  }

  @override
  void didUpdateWidget(covariant NotizenPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTag != oldWidget.selectedTag) {
      _selectedTag = widget.selectedTag;
      _loadNotes();
    }
  }

  void _loadNotes() {
    setState(() {
      _notes = _noteService.getNotes();
      if (_selectedTag != null && _selectedTag!.isNotEmpty) {
        _notes = _notes.where((note) => note.tags.contains(_selectedTag)).toList();
      }
    });
  }

  void _navigateToEditPage([Note? note]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditPage(note: note),
      ),
    );
    _loadNotes();
  }

  void _navigateToReadPage(Note note) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteReadPage(note: note),
      ),
    );
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final allTags = _noteService.getNotes().expand((note) => note.tags).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notizen'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedTag = value == 'Alle' ? null : value;
                _loadNotes();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Alle',
                child: Text('Alle Tags'),
              ),
              const PopupMenuDivider(),
              ...allTags.map((tag) => PopupMenuItem<String>(
                value: tag,
                child: Text(tag),
              )),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          final lines = note.text.split('\n');
          final title = lines.isNotEmpty ? lines[0] : '';
          final preview = lines.length > 1 ? lines.sublist(1).take(2).join('\n') : '';

          return ListTile(
            title: Text(title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preview),
                if (note.tags.isNotEmpty)
                  Text(
                    'Tags: ${note.tags.join(', ')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            onTap: () => _navigateToReadPage(note),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditPage(note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _noteService.deleteNote(note.id);
                    _loadNotes();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditPage(),
        child: const Icon(Icons.add),
      ),
    );
  }
}