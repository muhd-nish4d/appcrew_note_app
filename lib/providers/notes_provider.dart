import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../services/auth_service.dart';
import '../core/error/failure.dart';
import '../core/error/error_mappers.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Note> _notes = [];
  String _searchQuery = '';
  StreamSubscription<List<Note>>? _notesSubscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<Note> get notes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  NotesProvider() {
    // Listen to authentication state changes to dynamically re-subscribe
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _subscribeToNotes();
      } else {
        _notesSubscription?.cancel();
        _notes = [];
        notifyListeners();
      }
    });

    // Initial subscription if already logged in
    if (_authService.currentUser != null) {
      _subscribeToNotes();
    }
  }

  void _subscribeToNotes() {
    _notesSubscription?.cancel();
    _errorMessage = null;
    notifyListeners();

    _notesSubscription = _notesService.getNotesStream().listen(
      (notes) {
        _notes = notes;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error listening to notes: $error');
        final failure = ErrorMapper.map(error);
        _errorMessage = failure.message;
        notifyListeners();
      },
    );
  }

  void retryFetchNotes() {
    _subscribeToNotes();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<AsyncResult<void>> addNote(Note note) async {
    _setLoading(true);
    try {
      await _notesService.addNote(note);
      return const Success(null);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      return FailureResult(failure);
    } finally {
      _setLoading(false);
    }
  }

  Future<AsyncResult<void>> updateNote(Note note) async {
    _setLoading(true);
    try {
      await _notesService.updateNote(note);
      return const Success(null);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      return FailureResult(failure);
    } finally {
      _setLoading(false);
    }
  }

  Future<AsyncResult<void>> deleteNote(String noteId) async {
    _setLoading(true);
    try {
      await _notesService.deleteNote(noteId);
      return const Success(null);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      return FailureResult(failure);
    } finally {
      _setLoading(false);
    }
  }
}
