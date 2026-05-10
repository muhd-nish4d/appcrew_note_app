import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../core/error/failure.dart';
import '../core/error/error_mappers.dart';

class LogInAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get currentUser => _user;

  LogInAuthProvider() {
    // Listen to authentication state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
    // Set initial user
    _user = _authService.currentUser;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<AsyncResult<void>> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      return const Success(null);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      return FailureResult(failure);
    } finally {
      _setLoading(false);
    }
  }

  Future<AsyncResult<void>> signUp(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      return const Success(null);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      return FailureResult(failure);
    } finally {
      _setLoading(false);
    }
  }

  Future<AsyncResult<void>> signOut() async {
    try {
      await _authService.signOut();
      return const Success(null);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      return FailureResult(failure);
    }
  }
}
