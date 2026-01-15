import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class AddNoteScreen extends StatefulWidget {
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isLoading = false;
  List<String> _tags = [];
  int _selectedColorIndex = 0;

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestoreService.addNote(
          _titleController.text,
          _contentController.text,
          _selectedColorIndex,
          _tags,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: InputBorder.none,
                          filled: true,
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_tags.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          children:
                              _tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  onDeleted: () => _removeTag(tag),
                                  deleteIcon: Icon(Icons.close, size: 18),
                                );
                              }).toList(),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagsController,
                              decoration: InputDecoration(
                                labelText: 'Tags',
                                border: InputBorder.none,
                                filled: true,
                                prefixIcon: Icon(Icons.tag),
                              ),
                              onFieldSubmitted: (value) => _addTag(),
                            ),
                          ),
                          IconButton(
                            onPressed: _addTag,
                            icon: const Icon(Icons.add),
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          hintText: 'Note Content',
                          border: InputBorder.none,
                          filled: true,
                        ),
                        maxLines: null,
                        minLines: 10,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter content';
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
