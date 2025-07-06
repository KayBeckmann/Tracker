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
  final _newTagController = TextEditingController();
  final NoteService _noteService = NoteService();

  Set<String> _selectedTags = {};
  List<String> _allAvailableTags = [];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _textController.text = widget.note!.text;
      _selectedTags = widget.note!.tags.toSet();
    }
    _loadAllTags();
  }

  void _loadAllTags() {
    setState(() {
      _allAvailableTags = _noteService.getNotes().expand((note) => note.tags).toSet().toList();
    });
  }

  void _addNewTag() {
    final newTag = _newTagController.text.trim();
    if (newTag.isNotEmpty && !_allAvailableTags.contains(newTag)) {
      setState(() {
        _allAvailableTags.add(newTag);
        _selectedTags.add(newTag);
        _newTagController.clear();
      });
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
              const Text('Vorhandene Tags:'),
              Wrap(
                spacing: 8.0,
                children: _allAvailableTags.map((tag) {
                  return ChoiceChip(
                    label: Text(tag),
                    selected: _selectedTags.contains(tag),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newTagController,
                      decoration: const InputDecoration(labelText: 'Neuen Tag hinzufügen'),
                      onFieldSubmitted: (value) => _addNewTag(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewTag,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newOrUpdatedNote = Note(
                      id: widget.note?.id,
                      text: _textController.text,
                      tags: _selectedTags.toList(),
                    );

                    if (widget.note == null) {
                      _noteService.addNote(newOrUpdatedNote);
                    } else {
                      _noteService.updateNote(newOrUpdatedNote);
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
