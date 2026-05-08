import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants.dart';

class SocketService {
  io.Socket? _socket;

  final _newMessageController = StreamController<Map<String, dynamic>>.broadcast();
  final _sessionUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get onNewMessage => _newMessageController.stream;
  Stream<Map<String, dynamic>> get onSessionUpdated => _sessionUpdatedController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    disconnect();

    final uri = kApiBaseUrl.replaceAll('/api', '');

    _socket = io.io(
      uri,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .setAuth({'token': 'Bearer $token'})
          .setReconnectionAttempts(99999)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(15000)
          .setTimeout(10000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] ✅ connected to $uri');
      _connectionController.add(true);
    });

    _socket!.onDisconnect((reason) {
      debugPrint('[Socket] ❌ disconnected: $reason');
      _connectionController.add(false);
    });

    _socket!.onConnectError((err) {
      debugPrint('[Socket] 🔴 connect error: $err');
      _connectionController.add(false);
    });

    _socket!.on('new_message', (data) {
      if (data != null) {
        debugPrint('[Socket] 📩 new_message received');
        _newMessageController.add(data as Map<String, dynamic>);
      }
    });

    _socket!.on('session_updated', (data) {
      if (data != null) {
        debugPrint('[Socket] 🔄 session_updated received');
        _sessionUpdatedController.add(data as Map<String, dynamic>);
      }
    });

    debugPrint('[Socket] connecting to $uri...');
    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _newMessageController.close();
    _sessionUpdatedController.close();
    _connectionController.close();
  }
}
