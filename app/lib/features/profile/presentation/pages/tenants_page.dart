import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../chat/domain/entities/conversation_summary.dart';
import '../../../chat/presentation/providers/conversations_notifier.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../search/domain/entities/property.dart';

/// Tela "Meus Inquilinos" — mostra um card por inquilino que mora em
/// algum imóvel do landlord logado. Derivada de:
/// - `myPropertiesNotifierProvider.where(currentTenant != null)` — um
///   item por property com inquilino vinculado
/// - `conversationsProvider` — preview da última mensagem, quando há
///   conversa linkada àquele tenant
///
/// **Dependências de backend** (ver `BACKEND_HANDOFF.md`):
/// - `property.currentTenant` (§2) — sem isso, lista fica vazia
/// - `conversation.linkedTenantId` (§12) — sem isso, preview fica "—"
/// - `tenant.documentStatus` e `contract.endDate` — ainda não existem;
///   por ora status é derivado de `property.status` e vencimento fica
///   em "—" (ver §13 proposto)
class TenantsPage extends ConsumerWidget {
  const TenantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    final properties = ref
            .watch(myPropertiesNotifierProvider)
            .asData
            ?.value ??
        const <Property>[];
    final conversations =
        ref.watch(conversationsProvider).asData?.value ?? const [];

    // Cruza imóveis (com inquilino) + conversas (linkadas ao tenant) pra
    // montar os dados de cada card num único passe. Ordem: mais recente
    // por property.id (sem `rentalStartedAt` dá pra melhorar depois).
    final entries = <_TenantEntry>[
      for (final p in properties)
        if (p.currentTenant != null)
          _TenantEntry.from(property: p, conversations: conversations),
    ];

    return BrutalistPageScaffold(
      builder: (context, _, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: entrance,
            curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
          ),
        );

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: BrutalistPageHeader(
                  title: 'Meus Inquilinos',
                  subtitle: 'Gerencie quem mora nos seus imóveis',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: entries.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xxxl),
                          child: _EmptyTenants(
                              isDark: isDark,
                              titleColor: titleColor,
                              mutedColor: mutedColor),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              for (var i = 0; i < entries.length; i++) ...[
                                _buildTenantCard(context, entries[i], i,
                                    isDark, titleColor, mutedColor,
                                    accentColor),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              const SizedBox(height: AppSpacing.massive),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTenantCard(
    BuildContext context,
    _TenantEntry entry,
    int index,
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    final data = entry.toLegacyData();
    return _TenantCard(
      tenant: data,
      index: index,
      isDark: isDark,
      titleColor: titleColor,
      mutedColor: mutedColor,
      accentColor: accentColor,
      onTap: () => _showTenantDetails(context, data, index, isDark),
    );
  }

  void _showTenantDetails(BuildContext context, _TenantData tenant, int index, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TenantDetailsSheet(tenant: tenant, index: index, isDark: isDark),
    );
  }
}

class _TenantDetailsSheet extends StatelessWidget {
  const _TenantDetailsSheet({required this.tenant, required this.index, required this.isDark});
  final _TenantData tenant;
  final int index;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = BrutalistPalette.surfaceBg(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: mutedColor.withValues(alpha: 0.2), borderRadius: AppRadius.borderFull),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withValues(alpha: 0.1)),
                        child: Center(child: Text(tenant.initials, style: AppTypography.headlineSmall.copyWith(color: accentColor))),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tenant.name, style: AppTypography.headlineMedium.copyWith(color: titleColor)),
                            Text(tenant.property, style: AppTypography.bodyLarge.copyWith(color: mutedColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  const AppSectionHeader(title: 'Ações de Gestão'),
                  const SizedBox(height: AppSpacing.md),
                  AppMenuGroup(items: [
                    AppMenuGroupItem(
                      icon: Icons.chat_outlined,
                      label: 'Abrir Chat com Inquilino',
                      onTap: () {
                        Navigator.pop(context); // Close sheet
                        // ID composto (property + tenant) é a convenção
                        // aceita pelo /chat/:conversationId enquanto o
                        // backend não expõe o resolver oficial
                        // (BACKEND_HANDOFF.md §4). Quando existir,
                        // substituir por fetch do ID real da conversa.
                        context.push(
                          '/chat/property-${tenant.propertyId}-tenant-${tenant.tenantId}',
                        );
                      },
                    ),
                    AppMenuGroupItem(
                      icon: Icons.description_outlined,
                      label: 'Ver Documentos Enviados',
                      onTap: () {
                        Navigator.pop(context);
                        context.push(
                          '/search/documents?name=${Uri.encodeComponent(tenant.name)}',
                        );
                      },
                    ),
                    AppMenuGroupItem(
                      icon: Icons.history_rounded,
                      label: 'Histórico de Aluguéis',
                      onTap: () {
                        Navigator.pop(context);
                        context.push(
                          '/search/rent-history'
                          '?name=${Uri.encodeComponent(tenant.name)}'
                          '&tenantId=${Uri.encodeComponent(tenant.tenantId)}'
                          '&propertyId=${Uri.encodeComponent(tenant.propertyId)}',
                        );
                      },
                    ),
                    AppMenuGroupItem(
                      icon: Icons.gavel_rounded,
                      label: 'Visualizar Contrato Digital',
                      onTap: () {
                        Navigator.pop(context);
                        context.push(
                          '/search/contract'
                          '?name=${Uri.encodeComponent(tenant.name)}'
                          '&tenantId=${Uri.encodeComponent(tenant.tenantId)}'
                          '&propertyId=${Uri.encodeComponent(tenant.propertyId)}',
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xxl),
                  const AppSectionHeader(title: 'Informações do Contrato'),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: BrutalistPalette.subtleBg(isDark),
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Vencimento', tenant.contractEnd, isDark),
                        const SizedBox(height: 12),
                        _buildInfoRow('Valor Mensal', r'R$ 2.500,00', isDark),
                        const SizedBox(height: 12),
                        _buildInfoRow('Garantia', 'Seguro Fiança', isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: AppRadius.borderLg,
              ),
              child: Center(child: Text('Fechar', style: AppTypography.titleSmallBold.copyWith(color: isDark ? AppColors.black : AppColors.white))),
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: BrutalistPalette.muted(isDark))),
        Text(value, style: AppTypography.titleSmallBold.copyWith(color: BrutalistPalette.title(isDark))),
      ],
    );
  }
}

/// Dados já enriquecidos pra um card de inquilino — mistura Property,
/// PropertyTenant e ConversationSummary numa estrutura que a UI
/// consome direto. Calculado uma vez no build, passado pro card.
class _TenantEntry {
  const _TenantEntry({
    required this.tenantId,
    required this.propertyId,
    required this.tenantName,
    required this.propertyTitle,
    required this.status,
    required this.lastMessage,
    required this.contractEnd,
  });

  final String tenantId;
  final String propertyId;
  final String tenantName;
  final String propertyTitle;

  /// Status textual preservado ("Documentação OK" / "Aguardando
  /// Assinatura" / "Pendente Documentos"). Derivado de `property.status`
  /// por ora — quando o backend expuser `tenant.documentStatus`, trocar
  /// aqui. Ver BACKEND_HANDOFF.md §13.
  final String status;

  /// Preview da última mensagem trocada com esse inquilino. Vem de uma
  /// `ConversationSummary` com `linkedTenantId` igual ao tenant id.
  /// Fallback quando não há conversa: string vazia (a UI oculta o
  /// preview).
  final String lastMessage;

  /// Mês/ano do fim do contrato (ex: "12/2026"). Backend ainda não
  /// expõe esse campo — por ora fica em "—". Ver BACKEND_HANDOFF.md §13.
  final String contractEnd;

  /// Constrói a partir de uma [Property] que tem `currentTenant != null`
  /// + a lista global de conversas pra buscar preview linkado.
  factory _TenantEntry.from({
    required Property property,
    required List<ConversationSummary> conversations,
  }) {
    final tenant = property.currentTenant!;
    // Procura a conversa mais recente linkada a esse tenant. A lista já
    // vem ordenada DESC por `lastMessageAt` do provider, então
    // firstWhereOrNull basta.
    ConversationSummary? match;
    for (final c in conversations) {
      if (c.linkedTenantId == tenant.id) {
        match = c;
        break;
      }
    }
    return _TenantEntry(
      tenantId: tenant.id,
      propertyId: property.id,
      tenantName: tenant.name,
      propertyTitle: property.title,
      status: _statusFromProperty(property.status),
      lastMessage: match?.lastMessage ?? '',
      contractEnd: '—',
    );
  }

  /// Mapeia `property.status` nas 3 labels herdadas da UI original.
  /// Heurística provisória — ver BACKEND_HANDOFF.md §13 pra proposta
  /// de `tenant.documentStatus` dedicado.
  static String _statusFromProperty(String? status) {
    switch (status) {
      case 'RENTED':
        return 'Documentação OK';
      case 'NEGOTIATING':
        return 'Aguardando Assinatura';
      case 'AVAILABLE':
      default:
        // Caso borderline: tenant vinculado mas property não-RENTED.
        // Tratamos como inquilino incompleto pra o landlord notar.
        return 'Pendente Documentos';
    }
  }

  /// Geração defensiva das iniciais do avatar (ex: "João Silva" → "JS").
  String get initials {
    final parts = tenantName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      final w = parts.first;
      return w.length == 1 ? w.toUpperCase() : w.substring(0, 2).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Converte pro shape legado [_TenantData] consumido pelo sheet. O
  /// sheet passa o `tenantId` + `propertyId` pras rotas que precisam
  /// identificar tanto o inquilino quanto o imóvel (chat, histórico
  /// financeiro, etc.).
  _TenantData toLegacyData() {
    return _TenantData(
      tenantId: tenantId,
      propertyId: propertyId,
      name: tenantName,
      initials: initials,
      property: propertyTitle,
      status: status,
      lastMessage: lastMessage.isEmpty ? 'Sem mensagens ainda.' : lastMessage,
      contractEnd: contractEnd,
      isVerified: false,
    );
  }
}

class _TenantCard extends StatelessWidget {
  const _TenantCard({
    required this.tenant,
    required this.index,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    required this.onTap,
  });

  final _TenantData tenant;
  final int index;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final statusColor = _statusColor(tenant.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
          boxShadow: BrutalistPalette.subtleShadow(isDark),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.1),
                  ),
                  child: Center(
                      child: Text(tenant.initials,
                          style: AppTypography.titleMediumBold
                              .copyWith(color: accentColor))),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tenant.name,
                              style: AppTypography.titleLargeBold
                                  .copyWith(color: titleColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tenant.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified_rounded,
                                size: 14, color: accentColor),
                          ],
                        ],
                      ),
                      Text(tenant.property,
                          style: AppTypography.bodySmall
                              .copyWith(color: mutedColor)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(tenant.status,
                      style: AppTypography.propertyTag
                          .copyWith(color: statusColor, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 14, color: mutedColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tenant.lastMessage,
                    style: AppTypography.bodySmall.copyWith(
                      color: mutedColor,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('Contrato: ${tenant.contractEnd}',
                    style: AppTypography.bodySmall.copyWith(
                        color: mutedColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String label) {
    switch (label) {
      case 'Documentação OK':
        return AppColors.success;
      case 'Aguardando Assinatura':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }
}

class _EmptyTenants extends StatelessWidget {
  const _EmptyTenants({
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
  });

  final bool isDark;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 48, color: mutedColor.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhum inquilino ativo',
                style:
                    AppTypography.headlineSmall.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Quando um inquilino for vinculado a um dos seus imóveis,\n'
              'ele aparece aqui com o status do contrato e as mensagens.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _TenantData {
  const _TenantData({
    required this.tenantId,
    required this.propertyId,
    required this.name,
    required this.initials,
    required this.property,
    required this.status,
    required this.lastMessage,
    required this.contractEnd,
    required this.isVerified,
  });
  final String tenantId;
  final String propertyId;
  final String name;
  final String initials;
  final String property;
  final String status;
  final String lastMessage;
  final String contractEnd;
  final bool isVerified;
}
