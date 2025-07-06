import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tracker/models/note.dart';
import 'package:tracker/services/note_service.dart';
import 'package:tracker/note_edit_page.dart';

class NoteReadPage extends StatefulWidget {
  final Note note;

  const NoteReadPage({super.key, required this.note});

  @override
  State<NoteReadPage> createState() => _NoteReadPageState();
}

class _NoteReadPageState extends State<NoteReadPage> {
  final NoteService _noteService = NoteService();

  void _deleteNote() {
    _noteService.deleteNote(widget.note.id);
    Navigator.of(context).pop(); // Go back to the notes list
  }

  void _navigateToEditPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditPage(note: widget.note),
      ),
    );
    // After editing, refresh the current page or go back to the list
    if (mounted) {
      setState(() {}); // Simple refresh, might need more sophisticated update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.text.split('\n')[0]), // First line as title
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditPage,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownBody(
          data: widget.note.text,
        ),
      ),
    );
  }
}
