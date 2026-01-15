import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/app_constants.dart';
import 'package:flutter_application_1/model/notes_model.dart';
import 'package:flutter_application_1/screens/add_note_screen.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/note_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _viewMode = AppConstants.gridViewMode;
  bool _isSearching = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];

  Stream<List<Note>>? _noteStream;
  @override
  void initState() {
    super.initState();
    _noteStream = _firestoreService.getNotes();
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode =
          _viewMode == AppConstants.gridViewMode
              ? AppConstants.listViewMode
              : AppConstants.gridViewMode;
    });
  }

  void _applySearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredNotes = _notes;
      });
    } else {
      final searchQuery = query.toLowerCase();
      setState(() {
        _filteredNotes =
            _notes.where((note) {
              final titleLower = note.title.toLowerCase();
              final contentLower = note.content.toLowerCase();
              return titleLower.contains(searchQuery) ||
                  contentLower.contains(searchQuery) ||
                  note.tags.any(
                    (tag) => tag.toLowerCase().contains(searchQuery),
                  );
            }).toList();
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredNotes = [];
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isSearching
              ? _buildSearchAppBar()
              : AppBar(
                title: const Text('Notes'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _viewMode == AppConstants.gridViewMode
                          ? Icons.view_list
                          : Icons.grid_view,
                    ),
                    onPressed: _toggleViewMode,
                  ),
                ],
              ),

      body: StreamBuilder<List<Note>>(
        stream: _noteStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notes formed',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the "+" button to create your first note.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          _notes = snapshot.data!;

          final displayNotes = _isSearching ? _filteredNotes : _notes;

          return _viewMode == AppConstants.gridViewMode
              ? _buildGridView(displayNotes)
              : _buildListView(displayNotes);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return NoteCard(
            note: notes[index],
            onDelete: () async {
              await _firestoreService.deleteNote(notes[index].id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Note deleted successfully')),
              );
            },
            onTogglePin: () async {
              await _firestoreService.togglePinStatus(notes[index]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Note Pin Status Updated')),
              );
            },
            isListView: true,
          );
        },
      ),
    );
  }

  Widget _buildListView(List<Note> notes) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: NoteCard(
            note: notes[index],
            onDelete: () async {
              await _firestoreService.deleteNote(notes[index].id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Note deleted Successfully')),
              );
            },
            isListView: true,
            onTogglePin: () {},
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(13),
          hintText: 'Search notes .....',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        onChanged: _applySearch,
        cursorColor: Colors.white,
      ),
      actions: [
        IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
