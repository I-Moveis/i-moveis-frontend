import 'package:flutter/material.dart';
import 'package:app/design_system/design_system.dart';

class TenantRentHistoryPage extends StatelessWidget {
  final String tenantName;

  const TenantRentHistoryPage({
    super.key,
    required this.tenantName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Histórico Financeiro', style: AppTypography.titleLarge.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
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
                color: BrutalistPalette.surfaceBg(isDark),
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo em Aberto', style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                      Text('R\$ 0,00', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
                    ],
                  ),
                  Icon(Icons.account_balance_wallet_outlined, color: accentColor, size: 32),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Pagamentos Recebidos', style: AppTypography.titleMedium.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            for (var item in [
              {'label': 'Abril', 'price': '2.500', 'isPaid': true, 'date': '05/04'},
              {'label': 'Março', 'price': '2.500', 'isPaid': true, 'date': '04/03'},
              {'label': 'Fevereiro', 'price': '2.500', 'isPaid': true, 'date': '05/02'},
              {'label': 'Janeiro', 'price': '2.500', 'isPaid': false, 'date': '-'},
            ]) ...[
              _buildHistoryCard(context, item, isDark, titleColor, mutedColor, accentColor),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
    Color titleColor,
    Color mutedColor,
    Color accentColor,
  ) {
    final isPaid = item['isPaid'] as bool;
    final statusColor = isPaid ? AppColors.success : AppColors.error;
    final icon = isPaid ? Icons.check_circle_outline : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['label'] as String, style: AppTypography.titleMedium.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
                Text(isPaid ? 'Pago' : 'Atrasado', style: AppTypography.bodySmall.copyWith(color: statusColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${item['price']}', style: AppTypography.titleMedium.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
              Text(item['date'] as String, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
            ],
          ),
        ],
      ),
    );
  }
}
