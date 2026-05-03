import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

class TenantsPage extends StatelessWidget {
  const TenantsPage({super.key});

  static const _tenants = [
    _TenantData(
      name: 'João Silva',
      initials: 'JS',
      property: 'Apartamento Jardins',
      status: 'Documentação OK',
      lastMessage: 'Enviado comprovante de PIX.',
      contractEnd: '12/2026',
      isVerified: true,
    ),
    _TenantData(
      name: 'Maria Oliveira',
      initials: 'MO',
      property: 'Studio Pinheiros',
      status: 'Aguardando Assinatura',
      lastMessage: 'Pode conferir o contrato?',
      contractEnd: '08/2025',
      isVerified: true,
    ),
    _TenantData(
      name: 'Pedro Santos',
      initials: 'PS',
      property: 'Loft Vila Madalena',
      status: 'Pendente Documentos',
      lastMessage: 'Vou enviar o RG amanhã.',
      contractEnd: '05/2027',
      isVerified: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return BrutalistPageScaffold(
      builder: (context, _, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      Text('Meus Inquilinos', style: AppTypography.headlineLarge.copyWith(color: titleColor)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text('Gerencie quem mora nos seus imóveis', style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
                      const SizedBox(height: AppSpacing.xxl),
                      for (final tenant in _tenants) ...[
                        _buildTenantCard(context, tenant, isDark, titleColor, mutedColor, accentColor),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      const SizedBox(height: AppSpacing.massive),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTenantCard(BuildContext context, _TenantData tenant, bool isDark, Color titleColor, Color mutedColor, Color accentColor) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final statusColor = tenant.status.contains('OK') ? Colors.green : (tenant.status.contains('Pendente') ? Colors.orange : accentColor);

    return GestureDetector(
      onTap: () => _showTenantDetails(context, tenant, isDark),
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
                  child: Center(child: Text(tenant.initials, style: AppTypography.titleMediumBold.copyWith(color: accentColor))),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(tenant.name, style: AppTypography.titleLargeBold.copyWith(color: titleColor)),
                          if (tenant.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified_rounded, size: 14, color: accentColor),
                          ],
                        ],
                      ),
                      Text(tenant.property, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(tenant.status, style: AppTypography.propertyTag.copyWith(color: statusColor, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 14, color: mutedColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tenant.lastMessage,
                    style: AppTypography.bodySmall.copyWith(color: mutedColor, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('Contrato: ${tenant.contractEnd}', style: AppTypography.bodySmall.copyWith(color: mutedColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTenantDetails(BuildContext context, _TenantData tenant, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TenantDetailsSheet(tenant: tenant, isDark: isDark),
    );
  }
}

class _TenantDetailsSheet extends StatelessWidget {
  final _TenantData tenant;
  final bool isDark;
  const _TenantDetailsSheet({required this.tenant, required this.isDark});

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
                    AppMenuGroupItem(icon: Icons.chat_outlined, label: 'Abrir Chat com Inquilino', onTap: () {}),
                    AppMenuGroupItem(icon: Icons.description_outlined, label: 'Ver Documentos Enviados', onTap: () {}),
                    AppMenuGroupItem(icon: Icons.history_rounded, label: 'Histórico de Aluguéis', onTap: () {}),
                    AppMenuGroupItem(icon: Icons.gavel_rounded, label: 'Visualizar Contrato Digital', onTap: () {}),
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

class _TenantData {
  const _TenantData({
    required this.name,
    required this.initials,
    required this.property,
    required this.status,
    required this.lastMessage,
    required this.contractEnd,
    required this.isVerified,
  });
  final String name;
  final String initials;
  final String property;
  final String status;
  final String lastMessage;
  final String contractEnd;
  final bool isVerified;
}
