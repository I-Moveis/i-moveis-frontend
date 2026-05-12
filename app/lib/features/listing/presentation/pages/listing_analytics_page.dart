import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../rentals/data/current_payment_repository.dart';
import '../../../rentals/domain/entities/rent_payment.dart';
import '../../../search/domain/entities/property_input.dart';
import '../../data/property_analytics_repository.dart';
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

  static _AnalyticsPaymentStatus fromRentStatus(RentPaymentStatus s) {
    switch (s) {
      case RentPaymentStatus.paid:
        return _AnalyticsPaymentStatus.paid;
      case RentPaymentStatus.late:
        return _AnalyticsPaymentStatus.late;
      case RentPaymentStatus.awaiting:
        return _AnalyticsPaymentStatus.awaiting;
    }
  }

  RentPaymentStatus toRentStatus() {
    switch (this) {
      case _AnalyticsPaymentStatus.paid:
        return RentPaymentStatus.paid;
      case _AnalyticsPaymentStatus.late:
        return RentPaymentStatus.late;
      case _AnalyticsPaymentStatus.awaiting:
        return RentPaymentStatus.awaiting;
    }
  }
}

class _ListingAnalyticsPageState extends ConsumerState<ListingAnalyticsPage> {
  String _selectedFilter = '30 dias';

  /// Status local otimista do imóvel. Inicializa do `property.status` na
  /// primeira render com dado e passa a ser a fonte de verdade visual.
  /// Quando o landlord troca a pill, o PUT é disparado; se falhar, o
  /// state reverte pro valor anterior e mostra snackbar.
  String? _propertyStatus;

  /// Flag pra evitar toggle duplo enquanto o PUT estiver em voo.
  bool _savingStatus = false;

  /// Valor otimista do pagamento enquanto o PUT está em voo. Após
  /// completar, o provider é invalidado e volta a ditar o valor.
  _AnalyticsPaymentStatus? _paymentInflight;
  bool _savingPayment = false;

  /// Analytics por imóvel + janela de tempo (7d / 30d / Total) vem de
  /// `GET /properties/:id/analytics?window=`. Quando o endpoint falha
  /// (rede, 500), o provider devolve null e os cards caem em `—`.
  Map<String, int?> _getMetrics(PropertyAnalytics? analytics) {
    if (analytics == null) {
      return const {'views': null, 'favs': null, 'props': null, 'visits': null};
    }
    return {
      'views': analytics.views,
      'favs': analytics.favorites,
      'props': analytics.proposalsTotal,
      'visits': analytics.visitsScheduled,
    };
  }

  /// Dispara PUT /properties/:id/payments/current. Mesmo padrão
  /// otimista do `_changePropertyStatus`.
  Future<void> _changePayment(_AnalyticsPaymentStatus next) async {
    if (_savingPayment) return;
    setState(() {
      _paymentInflight = next;
      _savingPayment = true;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(currentPaymentRepositoryProvider).update(
            propertyId: widget.propertyId,
            status: next.toRentStatus(),
          );
      ref.invalidate(currentPaymentProvider(widget.propertyId));
      if (!mounted) return;
      setState(() {
        _paymentInflight = null;
        _savingPayment = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _paymentInflight = null;
        _savingPayment = false;
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Não foi possível atualizar o pagamento: $e')),
      );
    }
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
    final analyticsAsync = ref.watch(propertyAnalyticsProvider(
      PropertyAnalyticsQuery(
        propertyId: widget.propertyId,
        window: AnalyticsWindow.fromUiLabel(_selectedFilter),
      ),
    ));
    final metrics = _getMetrics(analyticsAsync.asData?.value);
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
                          // Lê snapshot real do backend. Fallback AWAITING
                          // enquanto carrega ou falha.
                          const AppSectionHeader(
                              title: 'Status do aluguel (mês atual)'),
                          const SizedBox(height: AppSpacing.md),
                          Consumer(
                            builder: (context, ref, _) {
                              final remote = ref
                                  .watch(currentPaymentProvider(widget.propertyId))
                                  .asData
                                  ?.value;
                              final backendStatus = remote != null
                                  ? _AnalyticsPaymentStatus.fromRentStatus(
                                      remote.status,
                                    )
                                  : _AnalyticsPaymentStatus.awaiting;
                              final display = _paymentInflight ?? backendStatus;
                              return _AnalyticsPaymentSelector(
                                current: display,
                                onChanged:
                                    _savingPayment ? (_) {} : _changePayment,
                                isDark: isDark,
                              );
                            },
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

  Widget _buildSummaryMetrics(Color accentColor, Map<String, int?> metrics) {
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
            _MetricCardValue(
              icon: Icons.visibility_outlined,
              value: metrics['views'],
              label: 'Visualizações',
            ),
            const SizedBox(width: AppSpacing.md),
            _MetricCardValue(
              icon: Icons.favorite_outline,
              value: metrics['favs'],
              label: 'Favoritos',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _MetricCardValue(
              icon: Icons.description_outlined,
              value: metrics['props'],
              label: 'Propostas',
            ),
            const SizedBox(width: AppSpacing.md),
            _MetricCardValue(
              icon: Icons.calendar_today_outlined,
              value: metrics['visits'],
              label: 'Visitas',
            ),
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

  /// Histórico de inquilinos — aguarda endpoint que devolva contratos
  /// passados pro imóvel (hoje só temos `Contract` ATIVO via US-014).
  /// Layout do card permanece pra quando o endpoint existir, basta
  /// trocar o empty state por `ListView` dos inquilinos retornados.
  Widget _buildTenantHistory(
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    return _EmptySectionCard(
      isDark: isDark,
      mutedColor: mutedColor,
      icon: Icons.people_outline_rounded,
      message:
          'Nenhum inquilino cadastrado ainda. O histórico de inquilinos aparece aqui quando houver contratos fechados.',
    );
  }

  /// Evolução do aluguel — depende de série temporal de
  /// `monthlyRent` por contrato. Sem endpoint entregue ainda.
  Widget _buildRentHistory(
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    return _EmptySectionCard(
      isDark: isDark,
      mutedColor: mutedColor,
      icon: Icons.trending_up_rounded,
      message:
          'Evolução do aluguel indisponível — aparece aqui conforme os contratos forem renovados com reajuste.',
    );
  }

  /// Encargos (IPTU / Condomínio) — depende do modelo `Expense` no
  /// backend, que ainda não expõe endpoint de listagem por imóvel.
  Widget _buildTaxHistory(
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    return _EmptySectionCard(
      isDark: isDark,
      mutedColor: mutedColor,
      icon: Icons.receipt_long_outlined,
      message:
          'Nenhum encargo registrado ainda. IPTU e condomínio aparecem aqui conforme forem lançados.',
    );
  }
}

/// Variante do [AppMetricCard] que aceita valor nulo — renderiza `—`
/// sem count-up e mantém layout/rótulo originais. Usada enquanto o
/// endpoint de analytics por imóvel ainda não foi entregue.
class _MetricCardValue extends ConsumerWidget {
  const _MetricCardValue({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int? value;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (value != null) {
      return AppMetricCard(icon: icon, value: value!, label: label);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = BrutalistPalette.surfaceBg(isDark);
    final border = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = BrutalistPalette.accentOrange(isDark);

    return Expanded(
      child: Tooltip(
        message: 'Métrica ainda não disponível',
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.5)),
              const SizedBox(height: AppSpacing.md),
              Text(
                '—',
                style: AppTypography.headlineLarge
                    .copyWith(color: titleColor.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card vazio genérico — usado para seções cujo endpoint ainda não
/// existe. Mantém a altura sem parecer quebrado e dá contexto do que
/// vai aparecer no lugar.
class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({
    required this.isDark,
    required this.mutedColor,
    required this.icon,
    required this.message,
  });

  final bool isDark;
  final Color mutedColor;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: mutedColor.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: mutedColor),
          ),
        ],
      ),
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

/// Seletor do status do imóvel (AVAILABLE/NEGOTIATING/RENTED). Cada
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
    ('NEGOTIATING', 'EM NEGOCIAÇÃO', Icons.handshake_outlined),
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
      case 'NEGOTIATING':
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
