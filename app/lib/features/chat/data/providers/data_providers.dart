import 'package:app/core/providers/dio_provider.dart';
import 'package:app/core/services/socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/chat_api_datasource.dart';
import '../datasources/chat_socket_datasource.dart';

final chatApiDataSourceProvider = Provider<ChatApiDataSource>((ref) {
  return ChatApiDataSource(ref.watch(dioProvider));
});

final chatSocketDataSourceProvider = Provider<ChatSocketDataSource>((ref) {
  return ChatSocketDataSource(ref.watch(socketServiceProvider));
});
