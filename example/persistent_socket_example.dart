import 'dart:typed_data';

import 'package:persistent_socket/persistent_socket.dart';

Future<void> main() async {
  var socket = PersistentSocket('localhost', 8080);

  socket.stream.listen(
    print,
    onError: print,
    onDone: () => print('d'),
  );
  await socket.send(Uint8List(2), reconnect: true);
}
