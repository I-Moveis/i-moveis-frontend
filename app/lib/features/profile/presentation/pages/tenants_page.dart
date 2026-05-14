import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../chat/domain/entities/conversation_summary.dart';
import '../../../chat/presentation/providers/conversations_notifier.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../rentals/data/contract_repository.dart';
import '../../../rentals/domain/entities/contract.dart';
import '../../../search/domain/entities/property.dart';

/// Tela "Meus Inquilinos" — mostra um card por inquilino que mora em
/// algum imóvel do landlord logado. Cruza:
/// - `myPropertiesNotifierProvider.where(currentTenant != null)` — uma
///   linha por property com inquilino vinculado
/// - `activeContractProvider` — `documentStatus` (chip de status) e
///   `endDate` (vencimento) por par (propertyId, tenantId)
/// - `conversationsProvider` — preview da última mensagem
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

    // Cruza imóveis (com inquilino) + conversas (linkadas ao tenant) +
    // contrato ativo (status documental + vencimento) pra montar cada card.
    // O contrato é buscado lazy via provider; null = usar defaults.
    final entries = <_TenantEntry>[
      for (final p in properties)
        if (p.currentTenant != null)
          _TenantEntry.from(
            property: p,
            conversations: conversations,
            contract: ref
                .watch(activeContractProvider(ContractQuery(
                  propertyId: p.id,
                  tenantId: p.currentTenant!.id,
                )))
                .asData
                ?.value,
          ),
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
      onTap: () => _showTenantDetails(
          context, data, index, isDark, titleColor, mutedColor, accentColor,
        ),
    );
  }

  void _showTenantDetails(
    BuildContext context,
    _TenantData tenant,
    int index,
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TenantDetailsSheet(
        tenant: tenant,
        index: index,
        isDark: isDark,
        titleColor: titleColor,
        mutedColor: mutedColor,
        accentColor: accentColor,
        onTap: () => Navigator.of(context).pop(),
      ),
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
                        _buildInfoRow(
                          'Valor Mensal',
                          tenant.monthlyRent.isEmpty ? '—' : tenant.monthlyRent,
                          isDark,
                        ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: BrutalistPalette.muted(isDark))),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.titleSmallBold.copyWith(color: BrutalistPalette.title(isDark)),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

/// Dados já enriquecidos pra um card de inquilino — mistura Property,
/// PropertyTenant, ConversationSummary e Contract numa estrutura que a
/// UI consome direto. Calculado uma vez no build, passado pro card.
class _TenantEntry {
  const _TenantEntry({
    required this.tenantId,
    required this.propertyId,
    required this.tenantName,
    required this.propertyTitle,
    required this.status,
    required this.lastMessage,
    required this.contractEnd,
    required this.monthlyRent,
    required this.isIdentityVerified,
  });

  final String tenantId;
  final String propertyId;
  final String tenantName;
  final String propertyTitle;

  /// Status textual derivado de `Contract.documentStatus`
  /// (PENDING_DOCUMENTS / AWAITING_SIGNATURE / APPROVED). "Sem
  /// contrato" quando ainda não há contrato ativo.
  final String status;

  /// Preview da última mensagem trocada com esse inquilino. Vem de uma
  /// `ConversationSummary` com `linkedTenantId` igual ao tenant id.
  final String lastMessage;

  /// Mês/ano do fim do contrato (ex: "12/2026"), derivado de
  /// `Contract.endDate`. "—" quando sem contrato ativo.
  final String contractEnd;

  /// Valor mensal do aluguel formatado (ex: "R$ 2.500,00"), de
  /// `Contract.monthlyRent`. Vazio quando sem contrato.
  final String monthlyRent;

  /// Identidade do inquilino verificada — vira o checkmark ao lado do
  /// nome no card. Vem de `PropertyTenant.isIdentityVerified`.
  final bool isIdentityVerified;

  factory _TenantEntry.from({
    required Property property,
    required List<ConversationSummary> conversations,
    required Contract? contract,
  }) {
    final matched = conversations.cast<ConversationSummary?>().firstWhere(
      (c) => c?.linkedTenantId == property.currentTenant!.id,
      orElse: () => null,
    );
    return _TenantEntry(property: property, conversation: matched);
  }

  final Property property;
  final ConversationSummary? conversation;

  _TenantData toLegacyData() {
    final tenant = property.currentTenant!;
    ConversationSummary? match;
    for (final c in conversations) {
      if (c.linkedTenantId == tenant.id) {
        match = c;
        break;
      }
    }

    final String status;
    switch (property.status) {
      case 'RENTED':
        status = 'Documentação OK';
        break;
      case 'NEGOTIATING':
        status = 'Aguardando Assinatura';
        break;
      default:
        status = 'Pendente';
    }

    return _TenantData(
      tenantId: tenant.id,
      propertyId: property.id,
      tenantName: tenant.name,
      propertyTitle: property.title,
      status: _statusFromContract(contract),
      lastMessage: match?.lastMessage ?? '',
      contractEnd: contract == null
          ? '—'
          : '${contract.endDate.month.toString().padLeft(2, '0')}/${contract.endDate.year}',
      monthlyRent: contract == null
          ? ''
          : _formatBrl(contract.monthlyRent),
      isIdentityVerified: tenant.isIdentityVerified,
    );
  }

  /// Mapeia `Contract.documentStatus` nas labels da UI. Sem contrato
  /// ativo significa que o landlord ainda precisa formalizar — tratamos
  /// como "Sem contrato" pra ele notar.
  static String _statusFromContract(Contract? contract) {
    if (contract == null) return 'Sem contrato';
    switch (contract.documentStatus) {
      case ContractDocumentStatus.approved:
        return 'Documentação OK';
      case ContractDocumentStatus.awaitingSignature:
        return 'Aguardando Assinatura';
      case ContractDocumentStatus.pendingDocuments:
        return 'Pendente Documentos';
    }
  }

  /// `1234.56` → `R$ 1.234,56`.
  static String _formatBrl(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '00';
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return 'R\$ $buf,$decPart';
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

  _TenantData toLegacyData() {
    return _TenantData(
      tenantId: tenantId,
      propertyId: propertyId,
      name: tenantName,
      initials: initials,
      property: property.title,
      status: status,
      lastMessage: lastMessage.isEmpty ? 'Sem mensagens ainda.' : lastMessage,
      contractEnd: contractEnd,
      monthlyRent: monthlyRent,
      isVerified: isIdentityVerified,
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
    final surfaceBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final statusColor = _statusColor(tenant.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
          boxShadow: BrutalistPalette.subtleShadow(isDark),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  tenant.initials,
                  style: AppTypography.titleSmallBold
                      .copyWith(color: accentColor),
                ),
              ),
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
                          style: AppTypography.titleMediumBold
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
                  const SizedBox(height: 2),
                  Text(
                    tenant.property,
                    style: AppTypography.bodySmall
                        .copyWith(color: mutedColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    tenant.status,
                    style: AppTypography.propertyTag
                        .copyWith(color: statusColor, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tenant.lastMessage,
                  style: AppTypography.bodySmall.copyWith(
                    color: mutedColor,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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

class _TenantDetailsSheet extends StatelessWidget {
  const _TenantDetailsSheet({
    required this.tenant,
    required this.index,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    this.onTap,
  });
  final _TenantData tenant;
  final int index;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;
  final VoidCallback? onTap;

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
      case 'Sem contrato':
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
    required this.monthlyRent,
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
  final String monthlyRent;
  final bool isVerified;
}
