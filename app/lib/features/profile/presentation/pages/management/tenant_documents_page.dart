import 'package:app/design_system/design_system.dart';
import 'package:flutter/material.dart';

class TenantDocumentsPage extends StatelessWidget {

  const TenantDocumentsPage({
    required this.tenantName, super.key,
  });
  final String tenantName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    final documents = [
      {'title': 'RG Frente', 'date': '12/03/2024', 'icon': Icons.badge_rounded},
      {'title': 'RG Verso', 'date': '12/03/2024', 'icon': Icons.badge_rounded},
      {'title': 'CPF', 'date': '12/03/2024', 'icon': Icons.badge_rounded},
      {'title': 'Comprovante de Renda', 'date': '14/03/2024', 'icon': Icons.description_rounded},
      {'title': 'Comprovante de Residência', 'date': '14/03/2024', 'icon': Icons.home_work_rounded},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Documentos', style: AppTypography.titleLarge.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: accentColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Inquilino: $tenantName',
                    style: AppTypography.titleSmall.copyWith(color: accentColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final doc in documents) ...[
              _buildDocCard(context, doc, isDark, titleColor, mutedColor, accentColor),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(
    BuildContext context,
    Map<String, dynamic> doc,
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: mutedColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(doc['icon'] as IconData, color: titleColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc['title'] as String, style: AppTypography.titleMedium.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
                Text('Enviado em ${doc['date']}', style: AppTypography.bodySmall.copyWith(color: mutedColor)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.visibility_outlined, color: accentColor),
            onPressed: () {
              // Show document preview
            },
          ),
        ],
      ),
    );
  }
}
