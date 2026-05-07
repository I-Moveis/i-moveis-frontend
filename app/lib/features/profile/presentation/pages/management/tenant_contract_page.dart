import 'package:app/design_system/design_system.dart';
import 'package:app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:app/features/auth/presentation/providers/auth_state.dart';
import 'package:app/features/listing/presentation/providers/my_properties_notifier.dart';
import 'package:app/features/search/domain/entities/property.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela de Contrato Digital — mostrada quando o landlord clica em
/// "Visualizar Contrato Digital" na página de inquilinos.
///
/// **Dados hidratados:**
/// - `Locador`: nome do landlord atualmente autenticado (auth notifier).
/// - `Locatário`: nome passado por query param (vem da lista de inquilinos).
/// - `Vigência` / `Valor Mensal`: quando a rota recebe `propertyId`, lê do
///   imóvel correspondente em `myPropertiesNotifierProvider`. Sem isso,
///   fallback para placeholder.
///
/// **Ações de PDF:**
/// - `BAIXAR PDF DO CONTRATO`: abre a URL pública do contrato (quando
///   existe) via `url_launcher`. Quando não há URL (backend ainda não
///   expôs), mostra aviso ao usuário.
/// - `ENVIAR CONTRATO ASSINADO`: o landlord escolhe um PDF local e o
///   arquivo sobe por multipart. Hoje isso precisa de endpoint que o
///   backend ainda não tem — ver `BACKEND_LANDLORD_GAPS.md §5`.
class TenantContractPage extends ConsumerStatefulWidget {
  const TenantContractPage({
    required this.tenantName,
    this.propertyId,
    this.tenantId,
    super.key,
  });

  final String tenantName;
  final String? propertyId;
  final String? tenantId;

  @override
  ConsumerState<TenantContractPage> createState() =>
      _TenantContractPageState();
}

class _TenantContractPageState extends ConsumerState<TenantContractPage> {
  String? _uploadedFileName;
  bool _uploadingSigned = false;

  /// Resolve o imóvel associado ao contrato, quando a rota recebeu
  /// `propertyId`. Usa o cache de "meus imóveis" — é o mesmo dado que
  /// abastece o dossier e a análise.
  Property? _findProperty() {
    if (widget.propertyId == null) return null;
    final list = ref
            .read(myPropertiesNotifierProvider)
            .asData
            ?.value ??
        const [];
    for (final p in list) {
      if (p.id == widget.propertyId) return p;
    }
    return null;
  }

  String _resolveLocadorName() {
    return ref.read(authNotifierProvider).maybeWhen(
          authenticated: (user) => user.name.isEmpty ? 'Proprietário' : user.name,
          orElse: () => 'Proprietário',
        );
  }

  Future<void> _downloadContract() async {
    final messenger = ScaffoldMessenger.of(context);
    // TODO(backend-gap): quando o backend expuser
    // GET /api/contracts/:id/pdf, trocar o 'url' abaixo pelo endpoint
    // real e gerar a URL autenticada. Ver BACKEND_LANDLORD_GAPS.md §5.
    const url = '';
    if (url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Download indisponível: o contrato PDF será habilitado quando o backend expuser /api/contracts.'),
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o PDF.')),
      );
    }
  }

  Future<void> _uploadSignedContract() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _uploadingSigned = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _uploadingSigned = false);
        return;
      }

      final picked = result.files.first;
      // TODO(backend-gap): PUT /api/contracts/:id/signed-document
      // multipart com campo `signedPdf`. Enquanto o endpoint não existir,
      // guardamos só o nome do arquivo pra feedback visual — o bytes
      // ficam em `picked.bytes` quando for hora de subir.
      setState(() {
        _uploadedFileName = picked.name;
        _uploadingSigned = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Arquivo "${picked.name}" selecionado. O envio será ativado quando o backend expuser /api/contracts/:id/signed-document.',
          ),
        ),
      );
    } on Object {
      if (mounted) {
        setState(() => _uploadingSigned = false);
        messenger.showSnackBar(
          const SnackBar(
              content: Text('Não foi possível selecionar o arquivo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);

    final property = _findProperty();
    final locadorName = _resolveLocadorName();

    final monthlyValue =
        property != null && property.priceValue > 0 ? property.price : '—';
    final vigencia = property != null
        ? _formatVigencia(property)
        : 'A definir no contrato';
    final registro = property?.id.isNotEmpty == true
        ? '#${property!.id.substring(0, property.id.length.clamp(0, 12))}'
        : '#—';

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Contrato Digital',
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
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_user_rounded,
                      color: AppColors.success, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text('CONTRATO DE LOCAÇÃO',
                      style: AppTypography.titleLarge.copyWith(
                          color: titleColor, fontWeight: FontWeight.bold)),
                  Text('REGISTRO $registro',
                      style:
                          AppTypography.bodySmall.copyWith(color: mutedColor)),
                  const Divider(height: AppSpacing.xl),
                  _buildContractSection('Locador', locadorName, titleColor, mutedColor),
                  _buildContractSection('Locatário', widget.tenantName, titleColor, mutedColor),
                  if (property != null)
                    _buildContractSection(
                        'Imóvel', property.title, titleColor, mutedColor),
                  _buildContractSection(
                      'Vigência', vigencia, titleColor, mutedColor),
                  _buildContractSection(
                      'Valor Mensal', monthlyValue, titleColor, mutedColor),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 14),
                        const SizedBox(width: AppSpacing.xs),
                        Text('ASSINADO DIGITALMENTE',
                            style: AppTypography.monoSmallWide.copyWith(
                                color: AppColors.success, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'BAIXAR PDF DO CONTRATO',
              onPressed: _downloadContract,
              icon: Icons.download_rounded,
              isExpanded: true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: _uploadingSigned
                  ? 'ABRINDO SELETOR...'
                  : _uploadedFileName == null
                      ? 'ENVIAR CONTRATO ASSINADO'
                      : 'SELECIONADO: ${_uploadedFileName!}',
              onPressed: _uploadingSigned ? null : _uploadSignedContract,
              icon: Icons.upload_file_rounded,
              isExpanded: true,
              variant: AppButtonVariant.outline,
            ),
            if (_uploadedFileName != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'O envio para o servidor será habilitado quando o backend expuser /api/contracts/:id/signed-document.',
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  /// Placeholder de vigência enquanto backend não devolve datas reais.
  /// Usa a data corrente + 12 meses como janela padrão — só pra ter algo
  /// sensato na UI. Trocar quando o backend expuser `rental_process`.
  String _formatVigencia(Property property) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    final now = DateTime.now();
    final end = DateTime(now.year + 1, now.month);
    return '12 meses (${months[now.month - 1]}/${now.year} - '
        '${months[end.month - 1]}/${end.year})';
  }

  Widget _buildContractSection(
      String label, String value, Color titleColor, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: AppTypography.titleSmall
                    .copyWith(color: titleColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
