import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/brutalist_palette.dart';

/// Cabeçalho padrão das telas raiz do bottom nav. Mantém consistência
/// visual entre Dashboard, Inquilinos, Meus Imóveis e Chat: logo do app
/// à esquerda, título grande, subtítulo muted abaixo, e um slot
/// opcional à direita (ex: sino de notificações no dashboard).
///
/// A página do Perfil tem layout próprio (avatar grande + nome como
/// título) — não consome este componente.
///
/// Nota: o arquivo se chama `brutalist_section_header` por razões
/// históricas; o widget é `BrutalistPageHeader` porque já existe um
/// `BrutalistSectionHeader` mais antigo (com `index`/`marker`) usado
/// como divisor dentro de páginas longas.
class BrutalistPageHeader extends StatelessWidget {
  const BrutalistPageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;

  /// Linha de apoio abaixo do título, estilo bodyMedium muted. Null
  /// esconde o espaço — deixa o título compacto.
  final String? subtitle;

  /// Widget livre no canto direito (notification bell, botão de ação,
  /// chip de status...). Respeita a altura do header.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 44,
            height: 44,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineLarge.copyWith(color: titleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMedium.copyWith(color: mutedColor),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}
