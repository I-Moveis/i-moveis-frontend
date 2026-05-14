import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aba ativa na tela de moderação de anúncios.
// ignore_for_file: avoid_classes_with_only_static_members
/// Provider compartilhado para que o dashboard possa pré-selecionar
/// a aba "Fila de Aprovação" ao navegar via alerta.
enum AdminModerationTab { all, pending }

extension AdminModerationTabLabel on AdminModerationTab {
  String get label {
    switch (this) {
      case AdminModerationTab.all:
        return 'Todos';
      case AdminModerationTab.pending:
        return 'Fila de Aprovação';
    }
  }
}

class AdminModerationTabNotifier extends Notifier<AdminModerationTab> {
  @override
  AdminModerationTab build() => AdminModerationTab.all;

  void selectAll() => state = AdminModerationTab.all;
  void selectPending() => state = AdminModerationTab.pending;
}

final adminModerationTabProvider =
    NotifierProvider<AdminModerationTabNotifier, AdminModerationTab>(
  AdminModerationTabNotifier.new,
);
