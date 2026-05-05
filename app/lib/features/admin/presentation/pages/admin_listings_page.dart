import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';
import '../providers/admin_shared_providers.dart';
import '../providers/moderation_queue_notifier.dart';

// Alias local para não poluir o escopo público
typedef _ModerationTab = AdminModerationTab;

// ─── Mock pending properties (fila de moderação local/demo) ──────────────────────────────

final _mockPendingProperties = [
  const _PendingProperty(
    id: 'pend-1',
    title: 'Apartamento Vila Madalena',
    address: 'Rua Harmonia, 400 — Vila Madalena, SP',
    price: r'R$ 3.800/mês',
    type: 'Apartamento · 2 quartos',
    imageUrls: [
      'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
    ],
    latitude: -23.5558,
    longitude: -46.6896,
  ),
  const _PendingProperty(
    id: 'pend-2',
    title: 'Studio Consolação',
    address: 'Av. Paulista, 900 — Bela Vista, SP',
    price: r'R$ 2.100/mês',
    type: 'Studio · 1 dormitório',
    imageUrls: [
      'https://images.unsplash.com/photo-1536376074432-bf12177d4f4f?auto=format&fit=crop&w=800&q=80',
    ],
    latitude: -23.5489,
    longitude: -46.6388,
  ),
  const _PendingProperty(
    id: 'pend-3',
    title: 'Casa Butantã',
    address: 'Rua Araguaia, 200 — Butantã, SP',
    price: r'R$ 5.500/mês',
    type: 'Casa · 3 quartos',
    imageUrls: [
      'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1600566753190-17f0bb2a6c3e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
    ],
    latitude: -23.5672,
    longitude: -46.7321,
  ),
  const _PendingProperty(
    id: 'pend-4',
    title: 'Cobertura Moema',
    address: 'Al. dos Nhambiquaras, 50 — Moema, SP',
    price: r'R$ 9.000/mês',
    type: 'Cobertura · 3 suítes',
    imageUrls: [
      'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?auto=format&fit=crop&w=800&q=80',
    ],
    latitude: -23.6013,
    longitude: -46.6661,
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdminListingsPage extends ConsumerWidget {
  const AdminListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final async = ref.watch(moderationQueueNotifierProvider);
        final notifier = ref.read(moderationQueueNotifierProvider.notifier);
        final currentStatus = notifier.status;
        
        // Tab selector local (da versão do usuário) adaptado para o provider da development
        final activeTab = ref.watch(adminModerationTabProvider);

        return Column(children: [
          const BrutalistAppBar(title: 'Moderação'),

          // Tab selector logic from local, but mapped to development's provider status
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.md),
            child: Row(children: _ModerationTab.values.map((tab) {
              final isActive = tab == activeTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (tab == _ModerationTab.all) {
                      ref.read(adminModerationTabProvider.notifier).selectAll();
                      notifier.setStatus('APPROVED'); // Ou alguma lógica de "todos" se existir
                    } else {
                      ref.read(adminModerationTabProvider.notifier).selectPending();
                      notifier.setStatus('PENDING');
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: tab == _ModerationTab.all ? AppSpacing.sm : 0),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isActive
                          ? accentColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: AppRadius.borderFull,
                      border: Border.all(
                        color: isActive
                            ? accentColor.withValues(alpha: 0.5)
                            : borderColor,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tab.label,
                            style: AppTypography.titleSmallBold.copyWith(
                              color: isActive ? accentColor : mutedColor,
                              fontSize: 12,
                            )),
                        if (tab == _ModerationTab.pending) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text('${_mockPendingProperties.length}',
                                style: AppTypography.tagBadge.copyWith(
                                    color: AppColors.warning, fontSize: 8)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList()),
          ),

          // Se estiver na aba "pendente", mostra a fila local/demo por cima ou junto
          // Mas vamos seguir a lógica da development de usar o provider real
          Expanded(
            child: activeTab == AdminModerationTab.pending && _mockPendingProperties.isNotEmpty && false // Desativado para priorizar real data, mas deixado estrutura
                ? _PendingQueueList(isDark: isDark)
                : async.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          e is Failure ? e.message : 'Erro ao carregar.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: titleColor),
                        ),
                      ),
                    ),
                    data: (items) => RefreshIndicator(
                      onRefresh: notifier.refresh,
                      child: ListView(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                          vertical: AppSpacing.lg,
                        ),
                        children: [
                          if (items.isEmpty && activeTab != AdminModerationTab.pending)
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Center(
                                child: Text(
                                  'Nenhum imóvel ${_statusLabel(currentStatus).toLowerCase()}.',
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: BrutalistPalette.muted(isDark)),
                                ),
                              ),
                            )
                          else if (items.isEmpty && activeTab == AdminModerationTab.pending)
                             _PendingQueueList(isDark: isDark) // Se a real estiver vazia, mostra a mock
                          else
                            ...items.map((p) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.sm),
                                  child: _ListingRow(
                                    property: p,
                                    isDark: isDark,
                                    status: currentStatus,
                                    onApprove: () => _approve(context, ref, p.id),
                                    onReject: () => _reject(context, ref, p.id),
                                    onDelete: () =>
                                        _confirmDelete(context, ref, p.id),
                                    onDetail: () =>
                                        _showDetailSheet(context, p, isDark),
                                  ),
                                )),
                          const SizedBox(height: AppSpacing.massive),
                        ],
                      ),
                    ),
                  ),
          ),
        ]);
      },
    );
  }

  Future<void> _approve(
      BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aprovar este anúncio?'),
        content: const Text('O imóvel ficará visível para inquilinos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Aprovar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(moderationQueueNotifierProvider.notifier).approve(id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Anúncio aprovado.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  Future<void> _reject(
      BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await _askReason(context);
    if (reason == null) return;
    try {
      await ref
          .read(moderationQueueNotifierProvider.notifier)
          .reject(id, reason);
      messenger.showSnackBar(
        const SnackBar(content: Text('Anúncio rejeitado.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  Future<String?> _askReason(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeitar anúncio'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo (obrigatório)',
              hintText: 'Explique brevemente para o proprietário.',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe um motivo.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover imóvel?'),
        content: const Text(
            'O imóvel será permanentemente removido do sistema.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Voltar')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Remover')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(moderationQueueNotifierProvider.notifier)
          .deleteProperty(id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Imóvel removido.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  Future<void> _showDetailSheet(
      BuildContext context, Property p, bool isDark) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PropertyDetailSheet(property: p, isDark: isDark),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'APPROVED':
      return 'Aprovado';
    case 'REJECTED':
      return 'Rejeitado';
    case 'PENDING':
    default:
      return 'Pendente';
  }
}

// ─── Existing listing row (usuário) ─────────────────────────────────────────────────────

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.property,
    required this.isDark,
    required this.status,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
    required this.onDetail,
  });

  final Property property;
  final bool isDark;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    final showApprove = status != 'APPROVED';
    final showReject = status != 'REJECTED';

    return GestureDetector(
      onTap: onDetail,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          // Thumbnail
          if (property.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                property.imageUrls.first,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 52,
                  height: 52,
                  color: BrutalistPalette.imagePlaceholderBg(isDark),
                  child: Icon(Icons.home_outlined,
                      size: 20, color: mutedColor),
                ),
              ),
            )
          else
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: BrutalistPalette.imagePlaceholderBg(isDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(Icons.home_outlined, size: 20, color: mutedColor),
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title,
                    style: AppTypography.titleSmallBold
                        .copyWith(color: titleColor)),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${property.type} · ${property.price}',
                  style:
                      AppTypography.bodySmall.copyWith(color: mutedColor),
                ),
                if (property.imageUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${property.imageUrls.length} foto${property.imageUrls.length != 1 ? 's' : ''}  · Toque para revisar',
                      style: AppTypography.bodySmall.copyWith(
                          color: mutedColor, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          // Actions
          if (showApprove)
            Tooltip(
              message: 'Aprovar',
              child: IconButton(
                icon: const Icon(Icons.check_circle_outline,
                    color: AppColors.success),
                onPressed: onApprove,
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (showReject)
            Tooltip(
              message: 'Rejeitar',
              child: IconButton(
                icon: const Icon(Icons.block,
                    color: AppColors.warning),
                onPressed: onReject,
                visualDensity: VisualDensity.compact,
              ),
            ),
          // Delete button
          IconButton(
            tooltip: 'Remover',
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ]),
      ),
    );
  }
}

// ─── Property detail sheet (galeria + mapa) ───────────────────────────────────

class _PropertyDetailSheet extends StatefulWidget {
  const _PropertyDetailSheet(
      {required this.property, required this.isDark});
  final Property property;
  final bool isDark;

  @override
  State<_PropertyDetailSheet> createState() => _PropertyDetailSheetState();
}

class _PropertyDetailSheetState extends State<_PropertyDetailSheet> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final isDark = widget.isDark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final bg = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    final hasImages = p.imageUrls.isNotEmpty;
    final hasLocation = p.latitude != 0 && p.longitude != 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.zero,
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title area
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                      style: AppTypography.titleSmallBold
                          .copyWith(color: titleColor)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text('${p.type} · ${p.price}',
                      style: AppTypography.bodySmall
                          .copyWith(color: mutedColor)),
                  if (p.address.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Row(children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: mutedColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(p.address,
                            style: AppTypography.bodySmall
                                .copyWith(color: mutedColor, fontSize: 11)),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Galeria de fotos ──────────────────────────────────
            if (hasImages) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl),
                child: Row(children: [
                  Text('Fotos (${p.imageUrls.length})',
                      style: AppTypography.titleSmallBold
                          .copyWith(color: titleColor, fontSize: 13)),
                  const SizedBox(width: AppSpacing.sm),
                  Tooltip(
                    message:
                        'Exclusão de fotos individuais disponível em breve',
                    child: Icon(Icons.info_outline,
                        size: 14, color: mutedColor),
                  ),
                ]),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Main image
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl),
                child: ClipRRect(
                  borderRadius: AppRadius.borderLg,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      p.imageUrls[_currentImage],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color:
                            BrutalistPalette.imagePlaceholderBg(isDark),
                        child: Icon(Icons.broken_image_outlined,
                            color: mutedColor),
                      ),
                    ),
                  ),
                ),
              ),

              // Thumbnails
              if (p.imageUrls.length > 1) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl),
                    itemCount: p.imageUrls.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final isSelected = i == _currentImage;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _currentImage = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? accentColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              p.imageUrls[i],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: BrutalistPalette
                                    .imagePlaceholderBg(isDark),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Mapa de localização ───────────────────────────────
            if (hasLocation) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl),
                child: Text('Localização',
                    style: AppTypography.titleSmallBold
                        .copyWith(color: titleColor, fontSize: 13)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl),
                child: ClipRRect(
                  borderRadius: AppRadius.borderLg,
                  child: SizedBox(
                    height: 180,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(p.latitude, p.longitude),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(p.id),
                          position: LatLng(p.latitude, p.longitude),
                          infoWindow: InfoWindow(title: p.title),
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Ações ─────────────────────────────────────────────
            // Adaptado para usar as funções da classe principal
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl),
              child: Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      // Nota: Esta sheet não tem acesso direto ao ref do widget pai facilmente sem passar
                      // Mas podemos usar um callback ou apenas fechar e deixar o usuário agir na lista
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderFull,
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text('Fechar',
                          style: AppTypography.titleSmallBold
                              .copyWith(color: AppColors.warning)),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.massive),
          ],
        ),
      ),
    );
  }
}

// ─── Fila de aprovação (mockada) ──────────────────────────────────────────────

class _PendingQueueList extends StatelessWidget {
  const _PendingQueueList({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.lg),
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderLg,
            border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline,
                size: 14, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Fila mockada para demonstração. O campo moderationStatus no backend destrava a fila real.',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.warning, fontSize: 10),
              ),
            ),
          ]),
        ),

        ..._mockPendingProperties.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PendingPropertyCard(pending: p, isDark: isDark),
            )),
        const SizedBox(height: AppSpacing.massive),
      ],
    );
  }
}

class _PendingPropertyCard extends StatefulWidget {
  const _PendingPropertyCard(
      {required this.pending, required this.isDark});
  final _PendingProperty pending;
  final bool isDark;

  @override
  State<_PendingPropertyCard> createState() =>
      _PendingPropertyCardState();
}

class _PendingPropertyCardState extends State<_PendingPropertyCard> {
  bool _approved = false;
  bool _rejected = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pending;
    final isDark = widget.isDark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: _approved
              ? AppColors.success.withValues(alpha: 0.4)
              : _rejected
                  ? AppColors.error.withValues(alpha: 0.4)
                  : borderColor,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image preview
        if (p.imageUrls.isNotEmpty)
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                p.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: BrutalistPalette.imagePlaceholderBg(isDark),
                  child: Icon(Icons.home_outlined, color: mutedColor),
                ),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status chip
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: _approved
                          ? AppColors.success.withValues(alpha: 0.12)
                          : _rejected
                              ? AppColors.error.withValues(alpha: 0.12)
                              : AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      _approved
                          ? 'Aprovado'
                          : _rejected
                              ? 'Reprovado'
                              : 'Aguardando',
                      style: AppTypography.tagBadge.copyWith(
                        color: _approved
                            ? AppColors.success
                            : _rejected
                                ? AppColors.error
                                : AppColors.warning,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('${p.imageUrls.length} foto(s)',
                      style: AppTypography.bodySmall
                          .copyWith(color: mutedColor, fontSize: 10)),
                ]),
                const SizedBox(height: AppSpacing.sm),

                Text(p.title,
                    style: AppTypography.titleSmallBold
                        .copyWith(color: titleColor)),
                const SizedBox(height: AppSpacing.xxs),
                Text(p.type,
                    style: AppTypography.bodySmall
                        .copyWith(color: mutedColor)),
                const SizedBox(height: AppSpacing.xxs),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 11, color: mutedColor),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(p.address,
                        style: AppTypography.bodySmall
                            .copyWith(color: mutedColor, fontSize: 11)),
                  ),
                ]),
                Text(p.price,
                    style: AppTypography.titleSmallBold.copyWith(
                        color: BrutalistPalette.accentOrange(isDark),
                        fontSize: 13)),

                const SizedBox(height: AppSpacing.md),

                if (!_approved && !_rejected)
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showRejectSheet(context, p.title, isDark);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color:
                                AppColors.error.withValues(alpha: 0.08),
                            borderRadius: AppRadius.borderFull,
                            border: Border.all(
                                color: AppColors.error
                                    .withValues(alpha: 0.2)),
                          ),
                          alignment: Alignment.center,
                          child: Text('Reprovar',
                              style: AppTypography.titleSmallBold
                                  .copyWith(
                                      color: AppColors.error,
                                      fontSize: 12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _approved = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.success
                                .withValues(alpha: 0.1),
                            borderRadius: AppRadius.borderFull,
                            border: Border.all(
                                color: AppColors.success
                                    .withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: Text('Aprovar',
                              style: AppTypography.titleSmallBold
                                  .copyWith(
                                      color: AppColors.success,
                                      fontSize: 12)),
                        ),
                      ),
                    ),
                  ])
                else
                  Text(
                    _approved
                        ? '✓ Anúncio aprovado na fila local'
                        : '✗ Anúncio reprovado na fila local',
                    style: AppTypography.bodySmall.copyWith(
                      color: _approved
                          ? AppColors.success
                          : AppColors.error,
                      fontSize: 11,
                    ),
                  ),
              ]),
        ),
      ]),
    );
  }

  Future<void> _showRejectSheet(
      BuildContext context, String title, bool isDark) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RejectSheet(title: title, isDark: isDark, returnResult: true),
    );
    if ((confirmed ?? false) && mounted) {
      setState(() => _rejected = true);
    }
  }
}

// ─── Reject modal sheet ───────────────────────────────────────────────────────

class _RejectSheet extends StatefulWidget {
  const _RejectSheet({
    required this.title,
    required this.isDark,
    this.returnResult = false,
  });
  final String title;
  final bool isDark;
  final bool returnResult;

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final bg = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Reprovar anúncio',
                style: AppTypography.titleSmallBold
                    .copyWith(color: AppColors.error)),
            const SizedBox(height: AppSpacing.xxs),
            Text(widget.title,
                style: AppTypography.bodySmall.copyWith(color: mutedColor)),
            const SizedBox(height: AppSpacing.lg),

            Text('Motivo da reprovação',
                style: AppTypography.bodySmall.copyWith(
                    color: titleColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),

            Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                style:
                    AppTypography.bodyMedium.copyWith(color: titleColor),
                decoration: InputDecoration(
                  hintText:
                      'Ex: Fotos de baixa qualidade, endereço incorreto, descrição enganosa...',
                  hintStyle:
                      AppTypography.bodySmall.copyWith(color: mutedColor),
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              Icon(Icons.info_outline, size: 12, color: AppColors.warning),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'O motivo será enviado ao proprietário quando o backend suportar moderação.',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning, fontSize: 10),
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (widget.returnResult) {
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Reprovação registrada (demo). Conecte ao backend para persistir.')),
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: AppRadius.borderFull,
                  ),
                  alignment: Alignment.center,
                  child: Text('Confirmar reprovação',
                      style: AppTypography.titleSmallBold
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ─── Data models for pending queue ───────────────────────────────────────────

class _PendingProperty {
  const _PendingProperty({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.type,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String title;
  final String address;
  final String price;
  final String type;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
}
