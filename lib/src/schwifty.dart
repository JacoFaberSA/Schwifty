import 'dart:async';

class Schwifty<T> {
  static Map<String, Schwifty>? _instance;

  // ignore: unused_field
  final String _key;

  Object? _error;
  Object? get error => _error;
  bool get hasError => _error != null;

  bool _loading = false;
  bool get isLoading => _loading;

  factory Schwifty(String key) {
    _instance ??= {};

    if (_instance![key] == null) {
      _instance![key] = Schwifty<T>._internal(key);
    }

    return _instance![key]! as Schwifty<T>;
  }

  Schwifty._internal(this._key);

  final StreamController<T> _streamController = StreamController<T>.broadcast();

  Stream<T>? _stream;

  /// Access the value stream to rebuild widgets when the value changes
  Stream<T> get stream {
    _stream ??= _streamController.stream.asBroadcastStream(
      onListen: (subscription) {
        if (_currentValue != null) {
          emit(_currentValue as T);
        }
      },
    );
    return _stream!;
  }

  T? _previousValue;
  T? _currentValue;

  /// Get the current value
  T? get value => _currentValue;

  /// Get the previous value
  T? get previousValue => _previousValue;

  void emit(T value) {
    if (_streamController.isClosed) {
      throw Exception('Schwifty instance is disposed');
    }

    _error = null;
    _previousValue = _currentValue;
    _currentValue = value;
    _streamController.add(value);
  }

  void emitError(Object? error) {
    _loading = false;
    _error = error;
    _streamController.addError(Exception(error.toString()));
  }

  void dispose() {
    _error = null;
    _currentValue = null;
    _previousValue = null;
    _streamController.close();
  }

  static String generateNamespace() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void emitFromFuture(Future<T> future) {
    _loading = true;
    future.then((value) {
      _loading = false;
      emit(value);
    }).catchError((error) {
      _loading = false;
      emitError(error);
    });
  }

  void emitFromStream(Stream<T> stream) {
    _loading = true;
    stream.listen((value) {
      _loading = false;
      emit(value);
    }, onError: (error) {
      _loading = false;
      emitError(error);
    });
  }
}
