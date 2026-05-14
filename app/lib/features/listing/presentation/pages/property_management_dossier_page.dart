import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../chat/data/conversation_repository.dart';
import '../../../rentals/data/current_payment_repository.dart';
import '../../../rentals/domain/entities/rent_payment.dart';
import '../../../search/domain/entities/property.dart';
import '../providers/my_properties_notifier.dart';

/// Status de pagamento mensal do aluguel. Hoje é puramente local — o backend
/// não tem recurso de `rental_payments` ainda (ver BACKEND_LANDLORD_GAPS.md).
/// Quando tiver, cada card deixa de manter estado local e passa a ler do
/// endpoint. A UI já está plumbed pra isso.
enum _PaymentStatus {
  awaiting,
  paid,
  late;

  String get label {
    switch (this) {
      case _PaymentStatus.paid:
        return 'PAGO';
      case _PaymentStatus.late:
        return 'ATRASADO';
      case _PaymentStatus.awaiting:
        return 'AGUARDANDO';
    }
  }

  IconData get icon {
    switch (this) {
      case _PaymentStatus.paid:
        return Icons.check_circle_outline_rounded;
      case _PaymentStatus.late:
        return Icons.error_outline_rounded;
      case _PaymentStatus.awaiting:
        return Icons.access_time_rounded;
    }
  }

  /// Converte do enum do domínio (que é o shape do backend) para o
  /// enum interno do dossier — os dois têm os mesmos 3 valores mas
  /// vivem em arquivos distintos por independência histórica.
  static _PaymentStatus fromRentStatus(RentPaymentStatus s) {
    switch (s) {
      case RentPaymentStatus.paid:
        return _PaymentStatus.paid;
      case RentPaymentStatus.late:
        return _PaymentStatus.late;
      case RentPaymentStatus.awaiting:
        return _PaymentStatus.awaiting;
    }
  }

  RentPaymentStatus toRentStatus() {
    switch (this) {
      case _PaymentStatus.paid:
        return RentPaymentStatus.paid;
      case _PaymentStatus.late:
        return RentPaymentStatus.late;
      case _PaymentStatus.awaiting:
        return RentPaymentStatus.awaiting;
    }
  }
}

class PropertyManagementDossierPage extends ConsumerWidget {
  const PropertyManagementDossierPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(myPropertiesNotifierProvider);
    // Não derruba a tela se o fetch falhar — cai em lista vazia com aviso
    // in-line. A página tem conteúdo estático (AppBar, layout) que deve
    // sempre aparecer.
    final properties = propertiesAsync.asData?.value ?? const <Property>[];
    final isLoading = propertiesAsync.isLoading && properties.isEmpty;

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        return Column(
          children: [
            const BrutalistAppBar(title: 'Gestão de Aluguéis'),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (properties.isEmpty) {
                    return _EmptyDossier(isDark: isDark);
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.all(AppSpacing.screenHorizontal),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return _ManagementCard(
                        property: property,
                        isDark: isDark,
                        onDetails: () => context.push(
                          '/my-properties/${property.id}/analytics',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Cartão do dossier. Stateful porque o seletor de status de pagamento
/// precisa lidar com PUT assíncrono e reverter em erro. Estado do
/// servidor vem de `currentPaymentProvider` (US-009/010); mutações vão
/// via `currentPaymentRepository.update` e invalidam o provider.
class _ManagementCard extends ConsumerStatefulWidget {
  const _ManagementCard({
    required this.property,
    required this.isDark,
    required this.onDetails,
  });

  final Property property;
  final bool isDark;
  final VoidCallback onDetails;

  @override
  ConsumerState<_ManagementCard> createState() => _ManagementCardState();
}

class _ManagementCardState extends ConsumerState<_ManagementCard> {
  /// Valor otimista em trânsito — usado enquanto o PUT está voando, ou
  /// como fallback se o GET ainda estiver carregando. Após o PUT
  /// completar, o provider é invalidado e volta a ditar o valor real.
  _PaymentStatus? _inflight;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final property = widget.property;
    final status = property.status ?? 'AVAILABLE';
    final tenant = property.currentTenant;
    final isRented = status == 'RENTED';

    // Lê snapshot do backend apenas quando o imóvel está alugado — não
    // faz sentido buscar pagamento se não há contrato ativo. Enquanto
    // carrega (ou fallback null), usa AWAITING como default.
    final remote = isRented
        ? ref.watch(currentPaymentProvider(property.id)).asData?.value
        : null;
    final paymentFromBackend = remote != null
        ? _PaymentStatus.fromRentStatus(remote.status)
        : _PaymentStatus.awaiting;
    final payment = _inflight ?? paymentFromBackend;

    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _CoverHeader(
            title: property.title,
            coverUrl: property.coverImageUrl,
            fallbackUrl: property.imageUrls.isNotEmpty
                ? property.imageUrls.first
                : null,
            statusBadge: _StatusBadge(
              status: status,
              paymentStatus: isRented ? payment : null,
              isDark: isDark,
            ),
            isDark: isDark,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: BrutalistPalette.subtleBg(isDark),
                      child: Icon(
                        tenant != null
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                        color: mutedColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant != null
                                ? 'Inquilino'
                                : _tenantPlaceholder(status),
                            style: AppTypography.bodySmall
                                .copyWith(color: mutedColor),
                          ),
                          Text(
                            tenant?.name ?? _statusCopy(status),
                            style: AppTypography.titleMedium.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Aluguel',
                            style: AppTypography.bodySmall
                                .copyWith(color: mutedColor)),
                        Text(
                          property.price,
                          style: AppTypography.titleMediumAccent.copyWith(
                            color: BrutalistPalette.accentPeach(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isRented) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _PaymentStatusSelector(
                    current: payment,
                    onChanged: _saving ? (_) {} : _updatePayment,
                    isDark: isDark,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'DETALHES',
                        onPressed: widget.onDetails,
                        variant: AppButtonVariant.outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: tenant != null ? 'CHAT' : 'SEM INQUILINO',
                        // Sem tenant vinculado: desabilita o CTA, evita que
                        // o landlord caia na lista genérica de conversas
                        // achando que vai falar com "o inquilino do imóvel".
                        onPressed: tenant != null
                            ? () => _openChatWithTenant(
                                  context,
                                  tenant,
                                  property,
                                )
                            : null,
                        icon: Icons.chat_bubble_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dispara o PUT do status de pagamento. UI otimista: seta
  /// `_inflight` pra mostrar o valor novo imediatamente; se o PUT
  /// falhar, reverte e mostra snackbar. Em sucesso, invalida o
  /// provider pra o próximo read pegar os novos `updatedAt`/`updatedBy`.
  Future<void> _updatePayment(_PaymentStatus next) async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _inflight = next;
      _saving = true;
    });
    try {
      await ref.read(currentPaymentRepositoryProvider).update(
            propertyId: widget.property.id,
            status: next.toRentStatus(),
          );
      // Força próximo watch do provider a refetchar da API em vez de
      // servir o cache antigo.
      ref.invalidate(currentPaymentProvider(widget.property.id));
      if (!mounted) return;
      setState(() {
        _inflight = null;
        _saving = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _inflight = null;
        _saving = false;
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Não foi possível atualizar o pagamento: $e')),
      );
    }
  }

  /// Abre chat 1:1 com o inquilino ligado ao imóvel. Convenção: o
  /// `/chat/:conversationId` aceita tanto id de conversa quanto composite
  /// `property-<pid>-tenant-<tid>` — quando o backend expor o shape real
  /// de conversation, trocar aqui pela resolução da conversa existente.
  Future<void> _openChatWithTenant(
    BuildContext context,
    PropertyTenant tenant,
    Property property,
  ) async {
    try {
      final conversationId = await ref
          .read(conversationRepositoryProvider)
          .resolve(property.id, tenant.id);
      if (context.mounted) {
        context.push('/conversation/$conversationId');
      }
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir conversa.')),
        );
      }
    }
  }

  /// Rótulo da seção "Inquilino" quando não existe tenant vinculado.
  String _tenantPlaceholder(String status) {
    if (status == 'NEGOTIATING') return 'Em negociação';
    return 'Situação';
  }

  /// Copy principal para imóveis sem inquilino vinculado. `AVAILABLE` e
  /// demais caem em "Aguardando locação" — mesmo que o status venha
  /// desconhecido do backend, não quebra.
  String _statusCopy(String status) {
    switch (status) {
      case 'NEGOTIATING':
        return 'Em negociação com interessado';
      case 'RENTED':
        return 'Alugado (sem inquilino no cadastro)';
      case 'AVAILABLE':
      default:
        return 'Aguardando locação';
    }
  }
}

class _CoverHeader extends StatelessWidget {
  const _CoverHeader({
    required this.title,
    required this.coverUrl,
    required this.fallbackUrl,
    required this.statusBadge,
    required this.isDark,
  });

  final String title;
  final String? coverUrl;
  final String? fallbackUrl;
  final Widget statusBadge;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final resolved = coverUrl ?? fallbackUrl;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (resolved != null && resolved.isNotEmpty)
              Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  if (kDebugMode) {
                    debugPrint('[cover] falha ao carregar: $resolved — $error');
                  }
                  return _CoverPlaceholder(isDark: isDark);
                },
              )
            else
              _CoverPlaceholder(isDark: isDark),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Text(
                title,
                style: AppTypography.titleSmallBold
                    .copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(bottom: 12, right: 12, child: statusBadge),
          ],
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrutalistPalette.subtleBg(isDark),
      child: Center(
        child: Icon(
          Icons.home_outlined,
          size: 48,
          color: BrutalistPalette.muted(isDark).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Badge read-only: mostra situação do aluguel quando o imóvel está
/// RENTED (espelha o `_PaymentStatus`), ou situação do imóvel
/// (disponível/em negociação) caso contrário.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.paymentStatus,
    required this.isDark,
  });

  final String status;
  final _PaymentStatus? paymentStatus;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Color bg;
    IconData icon;
    String label;
    if (paymentStatus != null) {
      switch (paymentStatus!) {
        case _PaymentStatus.paid:
          bg = AppColors.success;
          icon = Icons.check_circle_outline_rounded;
          label = 'PAGO';
        case _PaymentStatus.late:
          bg = AppColors.error;
          icon = Icons.error_outline_rounded;
          label = 'ATRASADO';
        case _PaymentStatus.awaiting:
          bg = BrutalistPalette.accentOrange(isDark);
          icon = Icons.access_time_rounded;
          label = 'AGUARDANDO';
      }
    } else if (status == 'NEGOTIATING') {
      bg = BrutalistPalette.accentAmber(isDark);
      icon = Icons.handshake_outlined;
      label = 'NEGOCIANDO';
    } else {
      bg = BrutalistPalette.muted(isDark);
      icon = Icons.event_available_outlined;
      label = 'DISPONÍVEL';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderSm,
        border: Border.all(width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seletor inline do status de pagamento. Três pílulas tocáveis, visual
/// igual ao badge, sem submenu — 3 opções cabem na largura do card.
class _PaymentStatusSelector extends StatelessWidget {
  const _PaymentStatusSelector({
    required this.current,
    required this.onChanged,
    required this.isDark,
  });

  final _PaymentStatus current;
  final ValueChanged<_PaymentStatus> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = BrutalistPalette.muted(isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status do aluguel (mês atual)',
          style: AppTypography.bodySmall.copyWith(color: mutedColor),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: _PaymentStatus.values
              .map((s) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _PaymentPill(
                        status: s,
                        selected: s == current,
                        onTap: () => onChanged(s),
                        isDark: isDark,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _PaymentPill extends StatelessWidget {
  const _PaymentPill({
    required this.status,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final _PaymentStatus status;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    switch (status) {
      case _PaymentStatus.paid:
        bg = AppColors.success;
      case _PaymentStatus.late:
        bg = AppColors.error;
      case _PaymentStatus.awaiting:
        bg = BrutalistPalette.accentOrange(isDark);
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? bg : bg.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: selected ? bg : bg.withValues(alpha: 0.25),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status.icon,
              size: 14,
              color: selected ? Colors.black : bg,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                status.label,
                style: AppTypography.labelSmall.copyWith(
                  color: selected ? Colors.black : bg,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDossier extends StatelessWidget {
  const _EmptyDossier({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 64,
            color: BrutalistPalette.muted(isDark),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nenhum imóvel em gestão ativa.',
            style: AppTypography.titleMedium
                .copyWith(color: BrutalistPalette.muted(isDark)),
          ),
        ],
      ),
    );
  }
}
