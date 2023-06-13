import 'package:persistent_socket/persistent_socket.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final socket = PersistentSocket('localhost', 8080);

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(socket, isA<PersistentSocket>());
    });
  });
}
