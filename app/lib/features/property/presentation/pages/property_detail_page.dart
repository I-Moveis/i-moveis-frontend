import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';

/// Property detail — cozy with hero image, rounded stat boxes, warm accents.
class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({required this.propertyId, super.key});
  final String propertyId;

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _heroFade;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _heroFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entrance, curve: const Interval(0, 0.4, curve: Curves.easeOut)));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entrance, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));
    Future.delayed(const Duration(milliseconds: 100), () { if (mounted) _entrance.forward(); });
  }

  @override
  void dispose() { _entrance.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(animation: _entrance, builder: (context, _) {
        return Stack(children: [
          CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
            // Hero
            SliverToBoxAdapter(child: Opacity(opacity: _heroFade.value, child: SizedBox(height: 280, child: Stack(fit: StackFit.expand, children: [
              ColoredBox(color: BrutalistPalette.imagePlaceholderBg(isDark), child: Center(child: Icon(Icons.home_rounded, size: 64, color: (isDark ? Colors.white : BrutalistPalette.warmBrown).withValues(alpha: 0.08)))),
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, bg.withValues(alpha: 0.95)], stops: const [0.3, 1.0])))),
              Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.md), child: Row(children: [
                _glassBtn(Icons.arrow_back_rounded, () => Navigator.of(context).pop(), isDark, mutedColor),
                const Spacer(),
                _glassBtn(Icons.favorite_outline_rounded, () {}, isDark, mutedColor),
                const SizedBox(width: AppSpacing.sm),
                _glassBtn(Icons.share_outlined, () {}, isDark, mutedColor),
              ])))),
              Positioned(bottom: AppSpacing.xl, right: AppSpacing.screenHorizontal, child: GestureDetector(
                onTap: () => context.push('/property/${widget.propertyId}/photos'),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs), decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderFull, border: Border.all(color: borderColor)),
                  child: Text('1 / 5', style: AppTypography.bodySmall.copyWith(color: mutedColor))),
              )),
            ])))),

            // Content
            SliverToBoxAdapter(child: Opacity(opacity: _contentFade.value, child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: AppSpacing.xl),
              // Tags
              Row(children: [
                _tag('Exclusivo', accentColor, isDark),
                const SizedBox(width: AppSpacing.sm),
                _tag('Novo', isDark ? BrutalistPalette.warmAmber : BrutalistPalette.deepAmber, isDark),
              ]),
              const SizedBox(height: AppSpacing.lg),
              Text('Apartamento — Vila Madalena', style: AppTypography.headlineLarge.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.xs),
              Row(children: [Icon(Icons.place_outlined, size: 14, color: mutedColor), const SizedBox(width: AppSpacing.xs), Text('São Paulo, SP', style: AppTypography.bodyMedium.copyWith(color: mutedColor))]),

              const SizedBox(height: AppSpacing.xxl),
              // Stats
              Text('Detalhes', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                _stat('51', 'm²', Icons.straighten_rounded, cardBg, borderColor, titleColor, mutedColor, accentColor),
                const SizedBox(width: AppSpacing.sm),
                _stat('2', 'quartos', Icons.bed_rounded, cardBg, borderColor, titleColor, mutedColor, accentColor),
                const SizedBox(width: AppSpacing.sm),
                _stat('1', 'banh.', Icons.bathtub_outlined, cardBg, borderColor, titleColor, mutedColor, accentColor),
                const SizedBox(width: AppSpacing.sm),
                _stat('1', 'vaga', Icons.directions_car_outlined, cardBg, borderColor, titleColor, mutedColor, accentColor),
              ]),

              const SizedBox(height: AppSpacing.xxl),
              // Pricing
              Text('Valores', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.md),
              _priceRow('Aluguel', r'R$ 2.500,00', titleColor, mutedColor),
              _priceRow('Condomínio', r'R$ 450,00', titleColor, mutedColor),
              _priceRow('IPTU', r'R$ 250,00', titleColor, mutedColor),
              Divider(height: AppSpacing.xxl, color: accentColor.withValues(alpha: 0.2)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Total / mês', style: AppTypography.titleLargeBold.copyWith(color: titleColor)),
                Text(r'R$ 3.200,00', style: AppTypography.headlineMediumBold.copyWith(color: accentColor)),
              ]),

              const SizedBox(height: AppSpacing.xxl),
              Text('Sobre', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.md),
              Text('Apartamento amplo e bem iluminado, com vista para o parque. Localização privilegiada, próximo a transporte público e comércio.', style: AppTypography.bodyLarge.copyWith(color: titleColor.withValues(alpha: 0.8), height: 1.8)),

              const SizedBox(height: AppSpacing.xxl),
              Text('Amenidades', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.md),
              Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: ['Piscina', 'Academia', 'Portaria 24h', 'Elevador', 'Varanda'].map((a) => _tag(a, accentColor, isDark)).toList()),

              const SizedBox(height: AppSpacing.xxl),
              Text('Localização', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.md),
              Container(height: 160, decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                child: Center(child: Icon(Icons.map_outlined, size: 32, color: accentColor.withValues(alpha: 0.2)))),

              const SizedBox(height: AppSpacing.xxl),
              Text('Proprietário', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.md),
              Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withValues(alpha: 0.1)),
                    child: Center(child: Text('M', style: AppTypography.titleMediumBold.copyWith(color: accentColor)))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mariana', style: AppTypography.titleLargeBold.copyWith(color: titleColor)),
                    Text('Membro desde 2023', style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                  ])),
                  GestureDetector(onTap: () {}, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(borderRadius: AppRadius.borderFull, border: Border.all(color: borderColor)),
                    child: Text('Mensagem', style: AppTypography.titleSmall.copyWith(color: mutedColor)),
                  )),
                ])),
              const SizedBox(height: 120),
            ])))),
          ]),
          // Bottom bar
          Positioned(left: 0, right: 0, bottom: 0, child: Opacity(opacity: _contentFade.value, child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: (isDark ? AppColors.blackLight : AppColors.white).withValues(alpha: 0.92),
              border: Border(top: BorderSide(color: borderColor, width: 0.5))),
            child: SafeArea(top: false, child: Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => context.push('/property/${widget.propertyId}/schedule'),
                child: Container(height: 48, decoration: BoxDecoration(borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                  child: Center(child: Text('Agendar visita', style: AppTypography.titleSmallBold.copyWith(color: titleColor)))),
              )),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: BrutalistGradientButton(label: 'PROPOSTA', height: 48, icon: Icons.description_outlined,
                onTap: () => context.push('/property/${widget.propertyId}/proposal'))),
            ])),
          ))),
        ]);
      }),
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap, bool isDark, Color color) {
    return GestureDetector(onTap: onTap, child: Container(width: 40, height: 40,
      decoration: BoxDecoration(color: BrutalistPalette.overlayPillBg(isDark), borderRadius: AppRadius.borderMd),
      child: Icon(icon, size: 18, color: color)));
  }

  Widget _tag(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.borderFull),
      child: Text(label, style: AppTypography.bodySmallBold.copyWith(color: color)),
    );
  }

  Widget _stat(String val, String label, IconData icon, Color bg, Color border, Color title, Color muted, Color accent) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.borderLg, border: Border.all(color: border)),
      child: Column(children: [
        Icon(icon, size: 16, color: accent.withValues(alpha: 0.5)),
        const SizedBox(height: AppSpacing.sm),
        Text(val, style: AppTypography.headlineMediumBold.copyWith(color: title)),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: AppTypography.captionTiny.copyWith(color: muted)),
      ])));
  }

  Widget _priceRow(String label, String value, Color title, Color muted) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: AppTypography.bodyMedium.copyWith(color: muted)), Text(value, style: AppTypography.titleSmall.copyWith(color: title))],
    ));
  }
}
