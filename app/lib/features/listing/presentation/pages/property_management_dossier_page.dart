import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../providers/my_properties_notifier.dart';

class PropertyManagementDossierPage extends ConsumerWidget {
  const PropertyManagementDossierPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(myPropertiesNotifierProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        return Column(
          children: [
            const BrutalistAppBar(
              title: 'Gestão de Aluguéis',
            ),
            Expanded(
              child: propertiesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (e, _) => Center(
                  child: Text(
                    e is Failure ? e.message : 'Erro ao carregar dados.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: BrutalistPalette.title(isDark),
                    ),
                  ),
                ),
                data: (properties) {
                  // Filter only properties that have a "tenant" (simulated for now)
                  // In a real app, this would come from the backend.
                  if (properties.isEmpty) {
                    return _EmptyDossier(isDark: isDark);
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      // Simulating different statuses for variety in the demo
                      final statusIndex = index % 3;
                      final statuses = ['PAID', 'PENDING', 'LATE'];
                      final status = statuses[statusIndex];

                      return _ManagementCard(
                        propertyTitle: property.title,
                        imageUrl: property.imageUrls.isNotEmpty 
                            ? property.imageUrls.first 
                            : 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=400&auto=format&fit=crop',
                        tenantName: 'Inquilino ${index + 1}',
                        rentValue: property.price,
                        paymentStatus: status,
                        isDark: isDark,
                        onChat: () => context.go('/chat'),
                        onDetails: () => context.push('/my-properties/${property.id}/analytics'),
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

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.propertyTitle,
    required this.imageUrl,
    required this.tenantName,
    required this.rentValue,
    required this.paymentStatus,
    required this.isDark,
    required this.onChat,
    required this.onDetails,
  });

  final String propertyTitle;
  final String imageUrl;
  final String tenantName;
  final String rentValue;
  final String paymentStatus;
  final bool isDark;
  final VoidCallback onChat;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (paymentStatus) {
      case 'PAID':
        statusColor = AppColors.success;
        statusLabel = 'PAGO';
        statusIcon = Icons.check_circle_outline_rounded;
      case 'LATE':
        statusColor = AppColors.error;
        statusLabel = 'ATRASADO';
        statusIcon = Icons.error_outline_rounded;
      case 'PENDING':
      default:
        statusColor = BrutalistPalette.accentOrange(isDark);
        statusLabel = 'AGUARDANDO';
        statusIcon = Icons.access_time_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
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
          // Property Header with Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
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
                      propertyTitle,
                      style: AppTypography.titleSmallBold.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Management Details
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: BrutalistPalette.subtleBg(isDark),
                      child: Icon(Icons.person_rounded, color: BrutalistPalette.muted(isDark)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Inquilino', style: AppTypography.bodySmall.copyWith(color: BrutalistPalette.muted(isDark))),
                          Text(tenantName, style: AppTypography.titleMedium.copyWith(color: BrutalistPalette.title(isDark), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Aluguel', style: AppTypography.bodySmall.copyWith(color: BrutalistPalette.muted(isDark))),
                        Text(rentValue, style: AppTypography.titleMediumAccent.copyWith(color: BrutalistPalette.accentPeach(isDark))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'DETALHES',
                        onPressed: onDetails,
                        variant: AppButtonVariant.outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: 'CHAT',
                        onPressed: onChat,
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
          Icon(Icons.assignment_late_outlined, size: 64, color: BrutalistPalette.muted(isDark)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nenhum imóvel em gestão ativa.',
            style: AppTypography.titleMedium.copyWith(color: BrutalistPalette.muted(isDark)),
          ),
        ],
      ),
    );
  }
}
