import 'package:flutter_test/flutter_test.dart';
import 'package:schwifty/schwifty.dart';

void main() {
  group('Schwifty', () {
    test('should create a Schwifty instance with initial value', () {
      final Schwifty<int> schwifty = Schwifty<int>('counter')..emit(0);
      
      expect(schwifty.value, 0);
    });

    test('should update the state value', () {
      final Schwifty<int> schwifty = Schwifty<int>('counter')..emit(0);
      schwifty.emit(1);
      
      expect(schwifty.value, 1);
      expect(schwifty.previousValue, 0);
    });

    test('should handle loading state', () async {
      final Schwifty<int> schwifty = Schwifty<int>('counter');
      
      schwifty.emitFromFuture(Future.delayed(const Duration(seconds: 1), () => 1));
      
      expect(schwifty.isLoading, true);
      await Future.delayed(const Duration(seconds: 1));
      expect(schwifty.isLoading, false);
      expect(schwifty.value, 1);
    });

    test('should handle error state', () async {
      final Schwifty<int> schwifty = Schwifty<int>('counter');
      
      schwifty.emitFromFuture(Future.delayed(const Duration(milliseconds: 50), () => throw Exception('error')));
      
      expect(schwifty.isLoading, true);
      await Future.delayed(const Duration(seconds: 1));
      expect(schwifty.isLoading, false);
      expect(schwifty.hasError, true);
      expect(schwifty.error.toString(), 'Exception: error');
    });

    test('should dispose the state stream', () {
      final Schwifty<int> schwifty = Schwifty<int>('counter')..emit(0);
      
      schwifty.dispose();
      
      expect(schwifty.value, null);
      expect(() => schwifty.emit(1), throwsA(isA<Exception>()));
    });

    test('should handle emitFromStream', () async {
      final Schwifty<int> schwifty = Schwifty<int>('counter');
      
      schwifty.emitFromStream(Stream.value(1));
      
      expect(schwifty.isLoading, true);
      await Future.delayed(const Duration(seconds: 1));
      expect(schwifty.isLoading, false);
      expect(schwifty.value, 1);
    });
  });
}
