// error_mappers.dart
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'failure.dart';

class ErrorMapper {
  static Failure map(dynamic error) {
    if (error is FirebaseAuthException) {
      return _mapAuthException(error);
    } else if (error is FirebaseException) {
      return _mapFirestoreException(error);
    } else if (error is SocketException) {
      return const Failure(
        message: 'You appear to be offline. Check your internet connection.',
        code: 'network-error',
      );
    } else if (error is TimeoutException) {
      return const Failure(
        message:
            'The connection timed out. Please check your internet and try again.',
        code: 'timeout',
      );
    } else {
      return Failure(
        message: 'An unexpected error occurred. Please try again.',
        originalException: error is Exception
            ? error
            : Exception(error.toString()),
      );
    }
  }

  static Failure _mapAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'wrong-password':
        message = 'The password you entered is incorrect.';
        break;
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists for that email.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection and try again.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled.';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials provided.';
        break;
      default:
        message = e.message ?? 'An authentication error occurred.';
    }
    return Failure(message: message, code: e.code, originalException: e);
  }

  static Failure _mapFirestoreException(FirebaseException e) {
    String message;
    switch (e.code) {
      case 'permission-denied':
        message = 'You do not have permission to perform this action.';
        break;
      case 'unavailable':
        message = 'Service is currently unavailable. Please try again later.';
        break;
      case 'not-found':
        message = 'The requested document was not found.';
        break;
      case 'deadline-exceeded':
        message = 'The operation timed out. Please try again.';
        break;
      default:
        message = e.message ?? 'A database error occurred.';
    }
    return Failure(message: message, code: e.code, originalException: e);
  }
}
