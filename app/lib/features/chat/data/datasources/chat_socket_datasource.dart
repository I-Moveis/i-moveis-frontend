import 'dart:async';
import '../../../../core/services/socket_service.dart';
import '../models/chat_models.dart';

class ChatSocketDataSource {
  ChatSocketDataSource(this._socketService);

  final SocketService _socketService;

  Stream<MessageModel> get onNewMessage =>
      _socketService.onNewMessage.map((data) {
        final msg = data['message'] as Map<String, dynamic>? ?? data;
        return MessageModel.fromJson(msg);
      });

  Stream<Map<String, dynamic>> get onSessionUpdated =>
      _socketService.onSessionUpdated;

  Stream<bool> get onConnectionChanged =>
      _socketService.onConnectionChanged;

  bool get isConnected => _socketService.isConnected;
}
