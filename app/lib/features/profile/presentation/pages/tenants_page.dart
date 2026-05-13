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

class _TenantEntry {
  _TenantEntry({required this.property, this.conversation});

  factory _TenantEntry.from({
    required Property property,
    required List<ConversationSummary> conversations,
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
    final parts = tenant.name.trim().split(RegExp(r'\s+'));
    final String initials;
    if (parts.isEmpty || parts.first.isEmpty) {
      initials = '?';
    } else if (parts.length == 1) {
      final word = parts.first;
      initials = word.length == 1
          ? word.toUpperCase()
          : word.substring(0, 2).toUpperCase();
    } else {
      initials = (parts.first[0] + parts.last[0]).toUpperCase();
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
      name: tenant.name,
      initials: initials,
      property: property.title,
      status: status,
      lastMessage: conversation?.lastMessage ?? '—',
      contractEnd: '—',
      isVerified: property.status == 'RENTED',
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
