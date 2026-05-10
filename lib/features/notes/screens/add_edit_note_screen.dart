import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/note.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/network_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/error_presenter.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  void _saveNote() async {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final notesProvider = context.read<NotesProvider>();
      AsyncResult<void> result;

      if (widget.note != null) {
        // Edit existing
        final updatedNote = Note(
          id: widget.note!.id,
          title: title,
          content: content,
          createdAt: widget.note!.createdAt,
          updatedAt: DateTime.now(),
          userId: widget.note!.userId,
        );
        result = await notesProvider.updateNote(updatedNote);
      } else {
        // Add new
        final newNote = Note(
          id: '',
          title: title,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: '', // Service overrides this
        );
        result = await notesProvider.addNote(newNote);
      }

      if (mounted) {
        if (result is Success) {
          Navigator.pop(context); // Go back after saving
        } else if (result is FailureResult) {
          ErrorPresenter.showError(context, (result).failure);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<NetworkProvider>().isOffline;
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: isOffline
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Note'),
                          content: const Text(
                            'Are you sure you want to delete this note?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        if (context.mounted) {
                          final result = await context
                              .read<NotesProvider>()
                              .deleteNote(widget.note!.id);
                          if (context.mounted) {
                            if (result is Success) {
                              Navigator.pop(context);
                            } else if (result is FailureResult) {
                              ErrorPresenter.showError(
                                context,
                                (result).failure,
                              );
                            }
                          }
                        }
                      }
                    },
              tooltip: 'Delete Note',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Title',
                  hint: 'Enter note title',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Content',
                    hint: 'Type your note here...',
                    controller: _contentController,
                    maxLines: 4, // Makes it expand
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter note content';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<NotesProvider>(
                  builder: (context, notesProvider, child) {
                    return CustomButton(
                      text: 'Save Note',
                      onPressed: isOffline ? null : _saveNote,
                      isLoading: notesProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
