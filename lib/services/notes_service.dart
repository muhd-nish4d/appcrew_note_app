import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';
import 'auth_service.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Helper to get user's notes collection reference
  CollectionReference? get _notesCollection {
    final user = _authService.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('notes');
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    final collection = _notesCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.add(note.toMap());
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    final collection = _notesCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(note.id).update(note.toMap());
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    final collection = _notesCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(noteId).delete();
  }

  // Stream of notes for current user
  Stream<List<Note>> getNotesStream() {
    final collection = _notesCollection;
    if (collection == null) return const Stream.empty();

    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
