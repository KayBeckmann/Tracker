import 'package:flutter/material.dart';
import 'package:tracker/models/note.dart';
import 'package:tracker/services/note_service.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _textController.text = widget.note!.text;
      _tagsController.text = widget.note!.tags.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Neue Notiz' : 'Notiz bearbeiten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Notiztext (Markdown)'),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie einen Notiztext ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (kommagetrennt)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final tags = _tagsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    final newOrUpdatedNote = Note(
                      id: widget.note?.id,
                      text: _textController.text,
                      tags: tags,
                    );

                    if (widget.note == null) {
                      NoteService().addNote(newOrUpdatedNote);
                    } else {
                      NoteService().updateNote(newOrUpdatedNote);
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}