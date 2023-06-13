import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class PersistentSocket {
  PersistentSocket(
    this.host,
    this.port, {
    this.sourceAddress,
    this.sourcePort = 0,
    this.timeout = const Duration(seconds: 5),
    this.maxRetries = 3,
    this.retryDelay = 5,
  }) {
    _outputCtrl = StreamController<Uint8List>(
      onListen: _listen,
      onCancel: _cancel,
    );
  }

  /// The host to connect to.
  final dynamic host;

  /// The port to connect to.
  final int port;

  /// The address to bind to locally.
  final dynamic sourceAddress;

  /// The port to bind to locally.
  final int sourcePort;

  /// The timeout for the connection attempt.
  final Duration? timeout;

  /// The maximum number of retries to attempt.
  ///
  /// If null, the socket will attempt to reconnect indefinitely.
  final int? maxRetries;

  /// The delay between retries.
  final int retryDelay;

  /// The number of times the socket has reconnected.
  int reconnections = 0;

  late StreamController<Uint8List> _outputCtrl;
  Socket? _socket;

  Stream<Uint8List> get stream => _outputCtrl.stream;

  Future<void> _listen() async => _socket ??= await _reconnect(maxRetries);

  void _cancel() {
    _outputCtrl.close();
    _socket?.close();
    _socket = null;
  }

  Future<void> send(
    /// The data to send.
    Uint8List data, {
    /// Whether to reconnect if the socket is not connected.
    ///
    /// If connection fails, send will throw an exception.
    bool reconnect = false,
  }) async {
    if (reconnect) await _listen();
    if (_socket == null) throw Exception('Socket is not connected');
    _socket?.add(data);
  }

  Future<Socket?> _reconnect(int? retries) async {
    while (retries == null || retries >= 0) {
      retries = retries == null ? null : retries - 1;
      _socket?.close();
      try {
        final socket = await Socket.connect(
          host,
          port,
          sourceAddress: sourceAddress,
          sourcePort: sourcePort,
          timeout: timeout,
        );
        reconnections++;
        return socket;
      } catch (error) {
        _outputCtrl.addError(error);
      }
      await Future.delayed(Duration(seconds: retryDelay));
    }
    if (retries == 0) {
      _outputCtrl.addError(
          Exception('Socket could not be connected. Retries exceeded.'));
    }

    return null;
  }
}
