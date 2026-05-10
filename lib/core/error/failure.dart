// failure.dart

class Failure {
  final String message;
  final String? code;
  final Exception? originalException;

  const Failure({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

sealed class AsyncResult<T> {
  const AsyncResult();
}

class Success<T> extends AsyncResult<T> {
  final T data;
  const Success(this.data);
}

class FailureResult<T> extends AsyncResult<T> {
  final Failure failure;
  const FailureResult(this.failure);
}
