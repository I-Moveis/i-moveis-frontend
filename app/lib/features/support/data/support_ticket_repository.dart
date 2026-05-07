import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../domain/entities/support_ticket.dart';

/// Armazena e lista chamados de suporte. **Dois modos**:
///
/// 1. **Remoto** (preferido, quando backend expuser
///    `POST /api/support/tickets` e `GET /api/support/tickets`): carrega
///    e salva direto na API.
/// 2. **Local** (fallback): persiste em SharedPreferences com uma chave
///    por usuário. Útil até o backend subir — o usuário vê seus próprios
///    chamados já criados mesmo antes do painel do admin existir.
///
/// Quando um chamado é criado no modo local, ele ganha um id sintético
/// (o próprio code `SUP-...`). Quando o remoto começar a responder, os
/// tickets locais seguem visíveis até o próximo refresh que vem da API
/// — aí o backend passa a ser a fonte de verdade.
class SupportTicketRepository {
  SupportTicketRepository({
    required SharedPreferences prefs,
    required Dio dio,
  })  : _prefs = prefs,
        _dio = dio;

  final SharedPreferences _prefs;
  final Dio _dio;

  static const _localKey = 'support.local_tickets';

  /// Lista todos os chamados do usuário atual. Tenta remoto primeiro.
  /// Se falhar (endpoint ausente, rede caiu), cai no cache local.
  Future<List<SupportTicket>> list() async {
    try {
      final response =
          await _dio.get<dynamic>('/support/tickets');
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<dynamic, dynamic>>()
            .map((m) => SupportTicket.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<dynamic, dynamic>>()
            .map((m) => SupportTicket.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[support] GET /support/tickets falhou '
          '(${e.response?.statusCode ?? '---'}): ${e.message} — '
          'caindo no cache local',
        );
      }
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[support] GET falha inesperada: $e');
    }
    return _readLocal();
  }

  /// Cria um novo chamado. Retorna o ticket com o código final —
  /// preferencialmente o que o backend gerou, ou um local se a API
  /// não respondeu.
  Future<SupportTicket> create({
    required String title,
    required String description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/support/tickets',
        data: {'title': title, 'description': description},
      );
      if (response.data != null) {
        final ticket = SupportTicket.fromJson(response.data!);
        // Boa prática: mesmo quando o POST sobe limpo, guardamos uma
        // cópia local por enquanto — quando o GET também funcionar,
        // o próximo refresh sobrescreve. Assim a lista nunca fica vazia
        // num estado transitório.
        await _appendLocal(ticket);
        return ticket;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[support] POST /support/tickets falhou '
          '(${e.response?.statusCode ?? '---'}): ${e.message}',
        );
      }
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[support] POST falha inesperada: $e');
    }

    // Fallback: gera código local e guarda.
    final ticket = SupportTicket(
      id: _localCode(),
      code: _localCode(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      status: SupportTicketStatus.open,
    );
    // `id` e `code` iguais é intencional no fallback — id único não tem
    // valor enquanto não existe backend pra referenciar.
    await _appendLocal(ticket);
    return ticket;
  }

  Future<SupportTicket?> find(String code) async {
    final all = await list();
    for (final t in all) {
      if (t.code == code) return t;
    }
    return null;
  }

  // ── Local cache ────────────────────────────────────────────────

  List<SupportTicket> _readLocal() {
    final raw = _prefs.getString(_localKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => SupportTicket.fromJson(Map<String, dynamic>.from(m)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on Object {
      return const [];
    }
  }

  Future<void> _appendLocal(SupportTicket ticket) async {
    final current = _readLocal();
    // Evita duplicata se o mesmo código já estiver no cache.
    final deduped = [ticket, ...current.where((t) => t.code != ticket.code)];
    await _prefs.setString(
      _localKey,
      jsonEncode(deduped.map((t) => t.toJson()).toList()),
    );
  }

  String _localCode() {
    final now = DateTime.now();
    final date = '${now.year.toString().substring(2)}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final random = Random().nextInt(46655);
    final suffix = random.toRadixString(36).toUpperCase().padLeft(4, '0');
    return 'SUP-$date-$suffix';
  }
}

final supportTicketRepositoryProvider = Provider<SupportTicketRepository>((ref) {
  return SupportTicketRepository(
    prefs: ref.watch(sharedPreferencesProvider),
    dio: ref.watch(dioProvider),
  );
});
