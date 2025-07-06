import 'package:flutter/material.dart';
import 'package:tracker/models/task.dart';
import 'package:tracker/services/database_service.dart';

class TaskEditPage extends StatefulWidget {
  final Task? task;

  const TaskEditPage({super.key, this.task});

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  Priority _priority = Priority.mittel;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _descriptionController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie eine Beschreibung ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Fälligkeitsdatum:'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _dueDate) {
                        setState(() {
                          _dueDate = pickedDate;
                        });
                      }
                    },
                    child: Text(_dueDate.toLocal().toString().split(' ')[0]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priorität'),
                items: Priority.values.map((Priority priority) {
                  return DropdownMenuItem<Priority>(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (Priority? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newOrUpdatedTask = Task(
                      id: widget.task?.id,
                      description: _descriptionController.text,
                      dueDate: _dueDate,
                      priority: _priority,
                      isCompleted: widget.task?.isCompleted ?? false,
                    );

                    if (widget.task == null) {
                      DatabaseService().addTask(newOrUpdatedTask);
                    } else {
                      DatabaseService().updateTask(newOrUpdatedTask);
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
