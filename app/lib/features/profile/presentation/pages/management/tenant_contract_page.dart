import 'package:flutter/material.dart';
import 'package:app/design_system/design_system.dart';

class TenantContractPage extends StatelessWidget {
  final String tenantName;

  const TenantContractPage({
    super.key,
    required this.tenantName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    // ignore: unused_local_variable
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Contrato Digital', style: AppTypography.titleLarge.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: BrutalistPalette.surfaceBg(isDark),
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
                boxShadow: [
                  BoxShadow(
                    color: titleColor.withValues(alpha: 0.05),
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.verified_user_rounded, color: AppColors.success, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text('CONTRATO DE LOCAÇÃO', style: AppTypography.titleLarge.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
                  Text('REGISTRO #IM-99281-2024', style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                  const Divider(height: AppSpacing.xl),
                  _buildContractSection('Locador', 'Helen Proprietária', titleColor, mutedColor),
                  _buildContractSection('Locatário', tenantName, titleColor, mutedColor),
                  _buildContractSection('Vigência', '12 meses (Abr/2024 - Abr/2025)', titleColor, mutedColor),
                  _buildContractSection('Valor Mensal', 'R\$ 2.500,00', titleColor, mutedColor),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 14),
                        const SizedBox(width: AppSpacing.xs),
                        Text('ASSINADO DIGITALMENTE', style: AppTypography.monoSmallWide.copyWith(color: AppColors.success, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'BAIXAR PDF DO CONTRATO',
              onPressed: () {},
              icon: Icons.download_rounded,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractSection(String label, String value, Color titleColor, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
          Text(value, style: AppTypography.titleSmall.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
