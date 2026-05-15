import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/design_system.dart';
import '../../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../../search/domain/entities/property.dart';

/// "Documentação e IPTU" — landlord centraliza os documentos de cada
/// imóvel (matrícula, IPTU, condomínio). Backend ainda não expõe um
/// endpoint de Documentos por imóvel, então a página lista os imóveis
/// do landlord e marca cada linha como pendente. Quando o endpoint
/// `GET /properties/:id/documents` existir, basta plugar nele.
class DocumentsIptuPage extends ConsumerWidget {
  const DocumentsIptuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propsAsync = ref.watch(myPropertiesNotifierProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: entrance,
          curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
        ));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BrutalistPageHeader(
                  title: 'Documentação e IPTU',
                  subtitle: 'Organize os documentos dos seus imóveis',
                  onBack: () => context.pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: propsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.xxxl),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => _Empty(
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                    data: (properties) => properties.isEmpty
                        ? _Empty(
                            isDark: isDark,
                            titleColor: titleColor,
                            mutedColor: mutedColor,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                for (final p in properties) ...[
                                  _PropertyDocCard(
                                    property: p,
                                    isDark: isDark,
                                    titleColor: titleColor,
                                    mutedColor: mutedColor,
                                    accentColor: accentColor,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                const SizedBox(height: AppSpacing.massive),
                              ],
                            ),
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
}

class _PropertyDocCard extends StatelessWidget {
  const _PropertyDocCard({
    required this.property,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
  });

  final Property property;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
        boxShadow: BrutalistPalette.subtleShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_outlined, color: accentColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title,
                        style: AppTypography.titleLargeBold
                            .copyWith(color: titleColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (property.address.isNotEmpty)
                      Text(property.address,
                          style: AppTypography.bodySmall
                              .copyWith(color: mutedColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          _docRow('Matrícula do imóvel', false, mutedColor),
          _docRow('Boleto de IPTU', false, mutedColor),
          _docRow('Convenção do condomínio', false, mutedColor),
        ],
      ),
    );
  }

  Widget _docRow(String label, bool uploaded, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            uploaded
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: uploaded ? AppColors.success : mutedColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label,
                style: AppTypography.bodyMedium.copyWith(color: titleColor)),
          ),
          Text(
            uploaded ? 'Enviado' : 'Pendente',
            style: AppTypography.bodySmall.copyWith(
              color: uploaded ? AppColors.success : mutedColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
  });
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 48, color: mutedColor.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhum imóvel cadastrado',
                style:
                    AppTypography.headlineSmall.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                'Anuncie um imóvel para começar a organizar a documentação.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: mutedColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
