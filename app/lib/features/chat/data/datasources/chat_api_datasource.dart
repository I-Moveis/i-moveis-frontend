import 'package:dio/dio.dart';
import '../models/chat_models.dart';
import 'chat_datasource.dart';

class ChatApiDataSource implements ChatRemoteDataSource {
  ChatApiDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ChatSessionModel> getOrCreateSession(String tenantId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/sessions',
      data: {'tenantId': tenantId},
    );
    return ChatSessionModel.fromJson(response.data ?? {});
  }

  @override
  Future<List<ChatSessionModel>> listSessions({
    String? tenantId,
    String? status,
    String? landlordId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tenantId != null) queryParams['tenantId'] = tenantId;
    if (status != null) queryParams['status'] = status;
    if (landlordId != null) queryParams['landlordId'] = landlordId;

    final response = await _dio.get<List<dynamic>>(
      '/chat/sessions',
      queryParameters: queryParams,
    );
    final data = response.data ?? [];
    return data
        .map((s) => ChatSessionModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChatSessionModel> getSession(String sessionId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/chat/sessions/$sessionId',
    );
    return ChatSessionModel.fromJson(response.data ?? {});
  }

  @override
  Future<MessageModel> sendMessage({
    required String sessionId,
    required String senderType,
    required String content,
    String? mediaUrl,
  }) async {
    final body = <String, dynamic>{
      'sessionId': sessionId,
      'senderType': senderType,
      'content': content,
    };
    if (mediaUrl != null) body['mediaUrl'] = mediaUrl;

    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/messages',
      data: body,
    );
    return MessageModel.fromJson(response.data ?? {});
  }

  @override
  Future<ChatSessionModel> updateSessionStatus(
    String sessionId,
    String status,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/chat/sessions/$sessionId/status',
      data: {'status': status},
    );
    return ChatSessionModel.fromJson(response.data ?? {});
  }
}
