import '../models/chat_models.dart';

abstract class ChatRemoteDataSource {
  Future<ChatSessionModel> getOrCreateSession(String tenantId);
  Future<List<ChatSessionModel>> listSessions({String? tenantId, String? status, String? landlordId});
  Future<ChatSessionModel> getSession(String sessionId);
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String senderType,
    required String content,
    String? mediaUrl,
  });
  Future<ChatSessionModel> updateSessionStatus(String sessionId, String status);
}
