import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property_input.dart';
import '../providers/edit_listing_notifier.dart';
import '../providers/my_properties_notifier.dart';
// Property is used via type inference in the data block

class ListingAnalyticsPage extends ConsumerStatefulWidget {
  const ListingAnalyticsPage({required this.propertyId, super.key});
  final String propertyId;

  @override
  ConsumerState<ListingAnalyticsPage> createState() => _ListingAnalyticsPageState();
}

/// Status de pagamento mensal do aluguel — duplicado aqui do dossier
/// porque a dependência inversa (analytics → dossier) não faz sentido.
/// Quando o backend expor `rental_payments`, centralizar num módulo de
/// domínio e as duas telas passam a ler dali.
enum _AnalyticsPaymentStatus {
  awaiting,
  paid,
  late;

  String get label {
    switch (this) {
      case _AnalyticsPaymentStatus.paid:
        return 'PAGO';
      case _AnalyticsPaymentStatus.late:
        return 'ATRASADO';
      case _AnalyticsPaymentStatus.awaiting:
        return 'AGUARDANDO';
    }
  }

  IconData get icon {
    switch (this) {
      case _AnalyticsPaymentStatus.paid:
        return Icons.check_circle_outline_rounded;
      case _AnalyticsPaymentStatus.late:
        return Icons.error_outline_rounded;
      case _AnalyticsPaymentStatus.awaiting:
        return Icons.access_time_rounded;
    }
  }
}

class _ListingAnalyticsPageState extends ConsumerState<ListingAnalyticsPage> {
  String _selectedFilter = '30 dias';
  _AnalyticsPaymentStatus _paymentStatus = _AnalyticsPaymentStatus.awaiting;

  /// Status local otimista do imóvel. Inicializa do `property.status` na
  /// primeira render com dado e passa a ser a fonte de verdade visual.
  /// Quando o landlord troca a pill, o PUT é disparado; se falhar, o
  /// state reverte pro valor anterior e mostra snackbar.
  String? _propertyStatus;

  /// Flag pra evitar toggle duplo enquanto o PUT estiver em voo.
  bool _savingStatus = false;

  // Mock data that changes based on filter
  Map<String, int> _getMetrics() {
    return switch (_selectedFilter) {
      '7 dias' => {'views': 42, 'favs': 5, 'props': 1, 'visits': 2},
      '30 dias' => {'views': 142, 'favs': 23, 'props': 5, 'visits': 8},
      _ => {'views': 890, 'favs': 112, 'props': 28, 'visits': 45},
    };
  }

  Future<void> _changePropertyStatus(String next) async {
    if (_savingStatus) return;
    final previous = _propertyStatus;
    setState(() {
      _propertyStatus = next;
      _savingStatus = true;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(editListingNotifierProvider.notifier).submit(
            widget.propertyId,
            PropertyInput(status: next),
          );
      // Quando o próprio backend, ao mudar para RENTED, começar a gerenciar
      // pagamentos, é aqui que a gente refetcharia o payment status. Hoje
      // não há endpoint — o seletor fica manual.
    } on Failure catch (f) {
      setState(() => _propertyStatus = previous);
      messenger.showSnackBar(SnackBar(
        content: Text('Não foi possível atualizar: ${f.message}'),
      ));
    } finally {
      if (mounted) setState(() => _savingStatus = false);
    }
  }

  void _showImageLightbox(BuildContext context, List<String> images, int initialIndex) {
    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (context) => _Lightbox(images: images, initialIndex: initialIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _getMetrics();
    final propertiesAsync = ref.watch(myPropertiesNotifierProvider);
    
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(
          opacity: fade.value,
          child: propertiesAsync.when(
            data: (properties) {
              final property = properties.firstWhere(
                (p) => p.id == widget.propertyId,
                orElse: () => properties.first,
              );

              // Hidrata o status local na primeira leitura de dado.
              // Mudanças subsequentes (landlord trocou a pill) ficam presas
              // no state; o refetch por invalidate do myProperties vai
              // sincronizar naturalmente no próximo ciclo.
              _propertyStatus ??= property.status ?? 'AVAILABLE';
              final currentStatus = _propertyStatus!;
              final isRented = currentStatus == 'RENTED';

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: BrutalistAppBar(title: 'Análise do Imóvel')),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSummaryMetrics(accentColor, metrics),
                        const SizedBox(height: AppSpacing.xxl),

                        // Seletor do status do imóvel — trocar aqui dispara
                        // PUT /properties/:id. Quando o backend auto-ligar
                        // RentalProcess → Property.status (ver
                        // BACKEND_LANDLORD_GAPS.md), este seletor deixa de
                        // ser a única forma de trocar, mas continua válido.
                        const AppSectionHeader(title: 'Status do imóvel'),
                        const SizedBox(height: AppSpacing.md),
                        _PropertyStatusSelector(
                          current: currentStatus,
                          onChanged: _changePropertyStatus,
                          disabled: _savingStatus,
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Seletor inline do status de pagamento mensal.
                        // Só faz sentido para imóveis alugados — enquanto
                        // não tem contrato ativo, mostra como desabilitado
                        // pra não sugerir que existe cobrança em curso.
                        if (isRented) ...[
                          const AppSectionHeader(
                              title: 'Status do aluguel (mês atual)'),
                          const SizedBox(height: AppSpacing.md),
                          _AnalyticsPaymentSelector(
                            current: _paymentStatus,
                            onChanged: (next) =>
                                setState(() => _paymentStatus = next),
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],

                        Text('Imagens Registradas', style: AppTypography.titleMedium.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.md),
                        _buildImageGallery(context, property.imageUrls),
                        const SizedBox(height: AppSpacing.xxl),

                        const AppSectionHeader(title: 'Histórico de Inquilinos'),
                        const SizedBox(height: AppSpacing.md),
                        _buildTenantHistory(isDark, titleColor, mutedColor, accentColor),
                        const SizedBox(height: AppSpacing.xxl),

                        const AppSectionHeader(title: 'Evolução do Aluguel'),
                        const SizedBox(height: AppSpacing.md),
                        _buildRentHistory(isDark, titleColor, mutedColor, accentColor),
                        const SizedBox(height: AppSpacing.xxl),

                        const AppSectionHeader(title: 'Encargos (IPTU / Condomínio)'),
                        const SizedBox(height: AppSpacing.md),
                        _buildTaxHistory(isDark, titleColor, mutedColor, accentColor),
                        const SizedBox(height: AppSpacing.massive),
                      ]),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
          ),
        );
      },
    );
  }

  Widget _buildSummaryMetrics(Color accentColor, Map<String, int> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          children: ['7 dias', '30 dias', 'Total'].map((l) {
            final isSelected = _selectedFilter == l;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = l),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : accentColor.withValues(alpha: 0.05),
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(
                    color: isSelected ? accentColor : accentColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Text(
                  l, 
                  style: AppTypography.titleSmall.copyWith(
                    color: isSelected ? Colors.black : accentColor, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            AppMetricCard(icon: Icons.visibility_outlined, value: metrics['views']!, label: 'Visualizações'),
            const SizedBox(width: AppSpacing.md),
            AppMetricCard(icon: Icons.favorite_outline, value: metrics['favs']!, label: 'Favoritos'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            AppMetricCard(icon: Icons.description_outlined, value: metrics['props']!, label: 'Propostas'),
            const SizedBox(width: AppSpacing.md),
            AppMetricCard(icon: Icons.calendar_today_outlined, value: metrics['visits']!, label: 'Visitas'),
          ],
        ),
      ],
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(child: Text('Nenhuma imagem disponível')),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _showImageLightbox(context, images, index),
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: Colors.white10),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.zoom_in_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTenantHistory(bool isDark, Color titleColor, Color mutedColor, Color accentColor) {
    final tenants = [
      {'name': 'João Silva', 'period': 'Abr 2023 - Mar 2024', 'status': 'Finalizado'},
      {'name': 'Maria Oliveira', 'period': 'Abr 2022 - Mar 2023', 'status': 'Finalizado'},
      {'name': 'Pedro Santos', 'period': 'Abr 2024 - Atual', 'status': 'Ativo'},
    ];

    return Column(
      children: tenants.map((t) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: BrutalistPalette.surfaceBg(isDark),
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accentColor.withValues(alpha: 0.1),
              child: Text(t['name']![0], style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['name']!, style: AppTypography.titleSmall.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
                  Text(t['period']!, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: t['status'] == 'Ativo' ? AppColors.success.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: AppRadius.borderFull,
                border: Border.all(color: t['status'] == 'Ativo' ? AppColors.success : mutedColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                t['status']!,
                style: AppTypography.labelSmall.copyWith(
                  color: t['status'] == 'Ativo' ? AppColors.success : mutedColor,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRentHistory(bool isDark, Color titleColor, Color mutedColor, Color accentColor) {
    final rents = [
      {'year': '2024', 'value': r'R$ 2.500', 'increase': '+8.5% (IGP-M)'},
      {'year': '2023', 'value': r'R$ 2.300', 'increase': '+9.2% (IGP-M)'},
      {'year': '2022', 'value': r'R$ 2.100', 'increase': 'Valor Inicial'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Column(
        children: rents.asMap().entries.map((entry) {
          final r = entry.value;
          final isLast = entry.key == rents.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['year']!, style: AppTypography.titleMedium.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
                        Text(r['increase']!, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                      ],
                    ),
                    Text(r['value']!, style: AppTypography.titleMedium.copyWith(color: accentColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (!isLast) Divider(color: BrutalistPalette.surfaceBorder(isDark), height: AppSpacing.md),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaxHistory(bool isDark, Color titleColor, Color mutedColor, Color accentColor) {
    final taxes = [
      {'type': 'IPTU 2024', 'status': 'Pago', 'info': 'Cota Única - 05/02'},
      {'type': 'Condomínio', 'status': 'Pago', 'info': 'Referente a Abril/2024'},
      {'type': 'Condomínio', 'status': 'Pendente', 'info': 'Vence em 10/05'},
    ];

    return Column(
      children: taxes.map((tax) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: BrutalistPalette.subtleBg(isDark),
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
        ),
        child: Row(
          children: [
            Icon(
              tax['status'] == 'Pago' ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: tax['status'] == 'Pago' ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tax['type']!, style: AppTypography.titleSmall.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
                  Text(tax['info']!, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                ],
              ),
            ),
            Text(
              tax['status']!,
              style: AppTypography.labelMedium.copyWith(
                color: tax['status'] == 'Pago' ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _Lightbox extends StatefulWidget {

  const _Lightbox({required this.images, required this.initialIndex});
  final List<String> images;
  final int initialIndex;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.95),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: AppTypography.titleMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
          if (widget.images.length > 1) ...[
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white54, size: 40),
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 40),
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Seletor do status do imóvel (AVAILABLE/IN_NEGOTIATION/RENTED). Cada
/// clique dispara `onChanged` — o pai cuida de chamar o notifier e
/// reverter o visual se o PUT falhar.
class _PropertyStatusSelector extends StatelessWidget {
  const _PropertyStatusSelector({
    required this.current,
    required this.onChanged,
    required this.disabled,
    required this.isDark,
  });

  final String current;
  final ValueChanged<String> onChanged;
  final bool disabled;
  final bool isDark;

  static const _options = [
    ('AVAILABLE', 'DISPONÍVEL', Icons.event_available_outlined),
    ('IN_NEGOTIATION', 'EM NEGOCIAÇÃO', Icons.handshake_outlined),
    ('RENTED', 'ALUGADO', Icons.home_work_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options
          .map((opt) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _PropertyStatusPill(
                    apiValue: opt.$1,
                    label: opt.$2,
                    icon: opt.$3,
                    selected: opt.$1 == current,
                    onTap: disabled ? null : () => onChanged(opt.$1),
                    isDark: isDark,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _PropertyStatusPill extends StatelessWidget {
  const _PropertyStatusPill({
    required this.apiValue,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final String apiValue;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    switch (apiValue) {
      case 'RENTED':
        bg = AppColors.success;
      case 'IN_NEGOTIATION':
        bg = BrutalistPalette.accentAmber(isDark);
      case 'AVAILABLE':
      default:
        bg = BrutalistPalette.accentOrange(isDark);
    }
    final opacity = onTap == null ? 0.4 : 1.0;
    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? bg : bg.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderSm,
            border: Border.all(
              color: selected ? bg : bg.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.black : bg),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: selected ? Colors.black : bg,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seletor inline do status de pagamento para a análise do imóvel. Copiado
/// do dossier pra manter visual idêntico; unificar num módulo de domínio
/// quando o backend expuser `rental_payments`.
class _AnalyticsPaymentSelector extends StatelessWidget {
  const _AnalyticsPaymentSelector({
    required this.current,
    required this.onChanged,
    required this.isDark,
  });

  final _AnalyticsPaymentStatus current;
  final ValueChanged<_AnalyticsPaymentStatus> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _AnalyticsPaymentStatus.values
          .map((s) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _AnalyticsPaymentPill(
                    status: s,
                    selected: s == current,
                    onTap: () => onChanged(s),
                    isDark: isDark,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _AnalyticsPaymentPill extends StatelessWidget {
  const _AnalyticsPaymentPill({
    required this.status,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final _AnalyticsPaymentStatus status;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    switch (status) {
      case _AnalyticsPaymentStatus.paid:
        bg = AppColors.success;
      case _AnalyticsPaymentStatus.late:
        bg = AppColors.error;
      case _AnalyticsPaymentStatus.awaiting:
        bg = BrutalistPalette.accentOrange(isDark);
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
            Text(
              status.label,
              style: AppTypography.labelSmall.copyWith(
                color: selected ? Colors.black : bg,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
