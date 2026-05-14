import 'package:app/design_system/design_system.dart';
import 'package:app/features/rentals/data/rent_payment_repository.dart';
import 'package:app/features/rentals/domain/entities/rent_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Histórico financeiro de um inquilino num imóvel específico. Abre
/// pelo sheet "Ações de Gestão" da tela "Meus Inquilinos".
///
/// Consome `GET /api/properties/:id/payments?tenantId=` (histórico
/// multi-mês). Quando o array vem vazio (raro — sem nenhuma cobrança
/// gerada ainda), mostra estado vazio direto.
class TenantRentHistoryPage extends ConsumerWidget {
  const TenantRentHistoryPage({
    required this.tenantName,
    this.tenantId,
    this.propertyId,
    super.key,
  });

  final String tenantName;
  final String? tenantId;
  final String? propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

    final hasIds = tenantId != null &&
        tenantId!.isNotEmpty &&
        propertyId != null &&
        propertyId!.isNotEmpty;

    final payments = hasIds
        ? ref
                .watch(rentPaymentHistoryProvider(
                  RentPaymentQuery(
                      propertyId: propertyId!, tenantId: tenantId!),
                ))
                .asData
                ?.value ??
            const <RentPayment>[]
        : const <RentPayment>[];

    final openBalance = payments
        .where((p) => p.status != RentPaymentStatus.paid)
        .fold<double>(0, (sum, p) => sum + p.amount);

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Histórico Financeiro',
          style: AppTypography.titleLarge
              .copyWith(color: titleColor, fontWeight: FontWeight.bold),
        ),
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
            _BalanceCard(
              openBalance: openBalance,
              isDark: isDark,
              titleColor: titleColor,
              mutedColor: mutedColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Pagamentos Recebidos',
              style: AppTypography.titleMedium.copyWith(
                color: titleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (payments.isEmpty)
              _EmptyHistory(isDark: isDark, mutedColor: mutedColor)
            else
              for (final p in payments) ...[
                _HistoryCard(
                  payment: p,
                  isDark: isDark,
                  titleColor: titleColor,
                  mutedColor: mutedColor,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
          ],
        ),
      ),
    );
  }

}

/// Header card com o saldo em aberto — soma dos pagamentos com status
/// diferente de `paid`. Zerado (R$ 0,00) quando não há pendências ou
/// quando a lista está vazia.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.openBalance,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
  });

  final double openBalance;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final formatted = _formatBrl(openBalance);
    return Container(
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
              Text('Saldo em Aberto',
                  style: AppTypography.bodySmall.copyWith(color: mutedColor)),
              Text(
                formatted,
                style: AppTypography.headlineMedium.copyWith(color: titleColor),
              ),
            ],
          ),
          Icon(Icons.account_balance_wallet_outlined,
              color: accentColor, size: 32),
        ],
      ),
    );
  }

  /// `1234.56` → `R$ 1.234,56`. Formatação leve em-loco; se precisar
  /// mais cenário, usar `intl.NumberFormat.currency`.
  String _formatBrl(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '00';
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return 'R\$ $buf,$decPart';
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.payment,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
  });

  final RentPayment payment;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final isPaid = payment.status == RentPaymentStatus.paid;
    final isLate = payment.status == RentPaymentStatus.late;
    final Color statusColor;
    final IconData icon;
    if (isPaid) {
      statusColor = AppColors.success;
      icon = Icons.check_circle_outline;
    } else if (isLate) {
      statusColor = AppColors.error;
      icon = Icons.error_outline;
    } else {
      statusColor = AppColors.warning;
      icon = Icons.access_time_rounded;
    }

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
                Text(payment.monthLabel,
                    style: AppTypography.titleMedium.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                    )),
                Text(payment.status.label,
                    style: AppTypography.bodySmall
                        .copyWith(color: statusColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${payment.amountLabel}',
                  style: AppTypography.titleMedium.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                  )),
              Text(payment.paidDateLabel,
                  style: AppTypography.bodySmall.copyWith(color: mutedColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.isDark, required this.mutedColor});
  final bool isDark;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: BrutalistPalette.surfaceBg(isDark),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 40, color: mutedColor.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Nenhum pagamento registrado ainda.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: mutedColor),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Os pagamentos aparecem aqui conforme forem confirmados.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: mutedColor),
          ),
        ],
      ),
    );
  }
}
