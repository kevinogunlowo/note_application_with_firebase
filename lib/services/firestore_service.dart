import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/constants/app_constants.dart';
import 'package:flutter_application_1/model/notes_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notesCollection {
    return _firestore.collection(AppConstants.notesCollection);
  }

  Stream<List<Note>> getNotes() {
    return _notesCollection
        .orderBy('isPinned', descending: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
        });
  }

  Future<Note> getNote(String noteId) async {
    try {
      final docSnapshot = await _notesCollection.doc(noteId).get();
      if (docSnapshot.exists) {
        return Note.fromMap(docSnapshot.data()!);
      } else {
        throw Exception('Note not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Note> addNote(
    String title,
    String content,
    int colorIndex,
    List<String> tags,
  ) async {
    try {
      final noteId = _notesCollection.doc().id;
      final now = DateTime.now();
      final newNote = Note(
        id: noteId,
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
        colorIndex: colorIndex,
        isPinned: false,
        tags: tags,
      );

      await _notesCollection.doc(noteId).set(newNote.toMap());
      return newNote;
    } catch (e) {
      rethrow;
    }
  }

  Future<Note> updateNote(Note note) async {
    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await _notesCollection.doc(note.id).update(updatedNote.toMap());
      return updatedNote;
    } catch (e) {
      rethrow;
    }
  }

  Future<Note> togglePinStatus(Note note) async {
    try {
      final updatedNote = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );
      await _notesCollection.doc(note.id).update(updatedNote.toMap());
      return updatedNote;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Note>> searchNotes(String query) {
    final String searchQuery = query.toLowerCase();
    return _notesCollection
        .where('title', isGreaterThanOrEqualTo: searchQuery)
        .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
        .orderBy('isPinned', descending: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Note.fromMap(doc.data())).where((
            note,
          ) {
            final titleLower = note.title.toLowerCase();
            final contentLower = note.content.toLowerCase();
            return titleLower.contains(searchQuery) ||
                contentLower.contains(searchQuery) ||
                note.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
          }).toList();
        });
  }
}
