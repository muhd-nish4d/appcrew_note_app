import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';
import 'auth_service.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Helper getter for current user's notes collection reference
  CollectionReference? get _userNotesCollection {
    final user = _authService.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('notes');
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    final collection = _userNotesCollection;
    if (collection == null) throw Exception('User not authenticated');

    final map = note.toMap();
    map['user_id'] = _authService.currentUser!.uid; 
    map['created_at'] = DateTime.now().millisecondsSinceEpoch;
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    await collection.add(map).timeout(const Duration(seconds: 10));
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    final collection = _userNotesCollection;
    if (collection == null) throw Exception('User not authenticated');

    final map = note.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    // Don't override created_at or user_id during update

    await collection.doc(note.id).update(map).timeout(const Duration(seconds: 10));
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    final collection = _userNotesCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(noteId).delete().timeout(const Duration(seconds: 10));
  }

  // Stream of notes for current user
  Stream<List<Note>> getNotesStream() {
    final collection = _userNotesCollection;
    if (collection == null) return const Stream.empty();

    return collection
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
