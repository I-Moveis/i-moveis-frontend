import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/conversation_repository.dart';
import '../../domain/entities/conversation_summary.dart';

class ConversationsNotifier
    extends AsyncNotifier<List<ConversationSummary>> {
  @override
  Future<List<ConversationSummary>> build() async {
    final repo = ref.read(conversationRepositoryProvider);
    return repo.list();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(conversationRepositoryProvider).list(),
    );
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationSummary>>(
  ConversationsNotifier.new,
);
