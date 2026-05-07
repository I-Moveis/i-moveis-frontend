import 'package:app/design_system/design_system.dart';
import 'package:app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:app/features/auth/presentation/providers/auth_state.dart';
import 'package:app/features/support/presentation/providers/support_tickets_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela de suporte — abre um ticket descritivo que é despachado para o
/// painel do admin. O landlord/tenant vê só o formulário mínimo (título
/// + descrição) e o código do ticket gerado. Metadados como nome, role
/// e horário são anexados pelo backend a partir do JWT; o admin recebe
/// tudo.
///
/// **Backend pendente**: `POST /api/support/tickets` — ver
/// `BACKEND_HANDOFF.md §10`. Enquanto o endpoint não existir, a submissão
/// cai num fluxo offline: gera código local, salva nada, mostra a
/// confirmação e avisa o usuário que o registro vai "entrar na fila"
/// quando a API subir. Em dev isso é útil pra testar a UI; em produção
/// precisa ser substituído pela chamada real.
class SupportTicketPage extends ConsumerStatefulWidget {
  const SupportTicketPage({super.key});

  @override
  ConsumerState<SupportTicketPage> createState() => _SupportTicketPageState();
}

class _SupportTicketPageState extends ConsumerState<SupportTicketPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();

  bool _submitting = false;

  /// Código do ticket após envio. Enquanto null, mostra o form;
  /// quando setado, mostra a confirmação. O usuário clica em FECHAR
  /// e volta pra lista.
  String? _confirmedCode;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    final description = _description.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o título e a descrição do problema.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // Repo cuida do POST + fallback local. Code vem real do backend
      // quando o endpoint existir, local quando não (ver
      // BACKEND_HANDOFF.md §10).
      final ticket = await ref
          .read(supportTicketsProvider.notifier)
          .create(title: title, description: description);
      if (!mounted) return;
      setState(() {
        _confirmedCode = ticket.code;
        _submitting = false;
      });
    } on Object catch (e) {
      if (kDebugMode) debugPrint('[support] create falhou: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o chamado. Tente novamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, __, _, _) {
        return Column(children: [
          const BrutalistAppBar(title: 'Suporte'),
          Expanded(
            child: _confirmedCode == null
                ? _buildForm(isDark)
                : _ConfirmationView(
                    code: _confirmedCode!,
                    isDark: isDark,
                    onClose: () => context.pop(),
                  ),
          ),
        ]);
      },
    );
  }

  Widget _buildForm(bool isDark) {
    final muted = BrutalistPalette.muted(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final role = _resolveRoleLabel(ref);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Abrir chamado',
            style: AppTypography.headlineSmall.copyWith(color: titleColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Descreva sua dúvida com o máximo de detalhes. Nossa equipe '
            'responde pelo mesmo canal que você usa pra acessar o app.',
            style: AppTypography.bodyMedium.copyWith(color: muted),
          ),
          if (role != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: BrutalistPalette.subtleBg(isDark),
                borderRadius: AppRadius.borderPill,
                border: Border.all(
                    color: BrutalistPalette.surfaceBorder(isDark)),
              ),
              child: Text(
                'Registrando como: $role',
                style: AppTypography.bodySmall.copyWith(color: muted),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),

          _FieldLabel('Título', isDark: isDark),
          _BrutalistTextField(
            controller: _title,
            hint: 'Ex: Não consigo editar as fotos do imóvel',
          ),
          const SizedBox(height: AppSpacing.lg),

          _FieldLabel('Descrição', isDark: isDark),
          _BrutalistTextField(
            controller: _description,
            hint: 'Conte o que aconteceu, o que você já tentou, prints '
                'são bem-vindos por chat depois.',
            maxLines: 8,
            minHeight: 160,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          BrutalistGradientButton(
            label: _submitting ? 'ENVIANDO...' : 'ENVIAR CHAMADO',
            icon: Icons.send_rounded,
            onTap: _submitting ? null : _submit,
          ),
          const SizedBox(height: AppSpacing.massive),
        ],
      ),
    );
  }

  /// Deriva o rótulo PT-BR do papel do usuário autenticado. Null quando
  /// o auth state não está resolvido (logout em curso, cold start, etc.)
  /// — nesse caso escondemos o chip no formulário.
  String? _resolveRoleLabel(WidgetRef ref) {
    return ref.read(authNotifierProvider).maybeWhen(
      authenticated: (user) {
        if (user.isAdmin) return 'Admin';
        if (user.isOwner) return 'Proprietário';
        return 'Inquilino';
      },
      orElse: () => null,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, {required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label,
        style: AppTypography.titleSmallBold.copyWith(
          color: BrutalistPalette.title(isDark).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _BrutalistTextField extends StatelessWidget {
  const _BrutalistTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.minHeight = 56,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final accent =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTypography.bodyLarge.copyWith(color: titleColor),
        cursorColor: accent,
        cursorWidth: 1.5,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyLarge.copyWith(
            color: BrutalistPalette.faint(isDark),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({
    required this.code,
    required this.isDark,
    required this.onClose,
  });

  final String code;
  final bool isDark;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final muted = BrutalistPalette.muted(isDark);

    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          const Center(
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 64,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chamado registrado',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSmall.copyWith(color: titleColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Número do chamado',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: muted),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            code,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: titleColor,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: BrutalistPalette.subtleBg(isDark),
              borderRadius: AppRadius.borderLg,
              border:
                  Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
            ),
            child: Text(
              'Chamado salvo. Você pode acompanhar o atendimento pela tela '
              'de Suporte no seu perfil.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: muted),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          BrutalistGradientButton(
            label: 'FECHAR',
            icon: Icons.close_rounded,
            onTap: onClose,
          ),
          const SizedBox(height: AppSpacing.massive),
        ],
      ),
    );
  }
}
