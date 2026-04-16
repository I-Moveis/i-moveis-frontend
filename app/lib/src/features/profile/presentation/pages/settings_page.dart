import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:app/src/design_system/design_system.dart';
import 'package:app/src/core/theme/theme_provider.dart';
import 'package:app/src/core/theme/seed_color_provider.dart';

/// Settings — cozy toggles and links with working theme switch and color picker.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final palette = ref.watch(brutalistPaletteProvider);
    final seedColor = ref.watch(seedColorProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );
        final titleColor = palette.title(isDark);
        final mutedColor = palette.muted(isDark);
        final accentColor = isDark ? palette.warmOrange : palette.deepOrange;
        final cardBg = palette.surfaceBg(isDark);
        final borderColor = palette.surfaceBorder(isDark);

        return Opacity(opacity: fade.value, child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: BrutalistAppBar(title: 'Configurações')),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ─── Theme Section ──────────────────────────────────────────
                Text('Aparência', style: AppTypography.titleSmallBold.copyWith(color: titleColor.withValues(alpha: 0.5))),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                  child: Column(children: [
                    _toggleRow(icon: isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined, label: isDarkMode ? 'Modo escuro' : 'Modo claro', subtitle: 'Alternar tema do app', value: isDarkMode, isDark: isDark, titleColor: titleColor, mutedColor: mutedColor, accentColor: accentColor, onChanged: (_) => ref.read(themeProvider.notifier).toggle()),
                    Divider(height: 1, indent: AppSpacing.lg + 20 + AppSpacing.md, color: borderColor),
                    
                    // Color Picker Trigger
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.palette_outlined, size: 20, color: accentColor.withValues(alpha: 0.6)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Cor principal', style: AppTypography.titleSmall.copyWith(color: titleColor)),
                              Text('Personalize a cor de destaque', style: AppTypography.bodySmall.copyWith(color: mutedColor)),
                            ])),
                            const SizedBox(width: AppSpacing.md),
                            GestureDetector(
                              onTap: () => _openColorPicker(context, seedColor),
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: seedColor,
                                  borderRadius: AppRadius.borderSm,
                                  border: Border.all(color: titleColor.withValues(alpha: 0.2)),
                                  boxShadow: [
                                    BoxShadow(color: seedColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ─── Preferences section ─────────────────────────────────────
                Text('Preferências', style: AppTypography.titleSmallBold.copyWith(color: titleColor.withValues(alpha: 0.5))),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                  child: Column(children: [
                    _toggleRow(icon: Icons.notifications_outlined, label: 'Notificações', subtitle: 'Alertas sobre seus imóveis', value: _notifications, isDark: isDark, titleColor: titleColor, mutedColor: mutedColor, accentColor: accentColor, onChanged: (v) => setState(() => _notifications = v)),
                  ]),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ─── Legal section ───────────────────────────────────────────
                Text('Legal', style: AppTypography.titleSmallBold.copyWith(color: titleColor.withValues(alpha: 0.5))),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                  child: Column(children: [
                    _linkRow(icon: Icons.article_outlined, label: 'Termos de uso', titleColor: titleColor, mutedColor: mutedColor, accentColor: accentColor, onTap: () {}),
                    Divider(height: 1, indent: AppSpacing.lg + 20 + AppSpacing.md, color: borderColor),
                    _linkRow(icon: Icons.privacy_tip_outlined, label: 'Privacidade', titleColor: titleColor, mutedColor: mutedColor, accentColor: accentColor, onTap: () {}),
                    Divider(height: 1, indent: AppSpacing.lg + 20 + AppSpacing.md, color: borderColor),
                    _linkRow(icon: Icons.info_outline_rounded, label: 'Sobre o app', titleColor: titleColor, mutedColor: mutedColor, accentColor: accentColor, onTap: () {}),
                  ]),
                ),

                const SizedBox(height: AppSpacing.xxxl),
                Center(child: Text('v1.0.0', style: AppTypography.bodySmall.copyWith(color: mutedColor.withValues(alpha: 0.5)))),
                const SizedBox(height: AppSpacing.massive),
              ]),
            )),
          ],
        ));
      },
    );
  }

  void _openColorPicker(BuildContext context, Color currentColor) async {
    final Color newColor = await showColorPickerDialog(
      context,
      currentColor,
      title: Text('Escolha uma cor', style: AppTypography.titleLarge),
      width: 40,
      height: 40,
      spacing: 12,
      runSpacing: 12,
      borderRadius: 12,
      wheelDiameter: 165,
      enableShadesSelection: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
      actionButtons: const ColorPickerActionButtons(
        okButton: true,
        closeButton: true,
        dialogActionButtons: true,
      ),
      constraints: const BoxConstraints(minHeight: 480, minWidth: 320, maxWidth: 400),
    );

    if (newColor != currentColor) {
      ref.read(seedColorProvider.notifier).setColor(newColor);
    }
  }

  Widget _toggleRow({required IconData icon, required String label, required String subtitle, required bool value, required bool isDark, required Color titleColor, required Color mutedColor, required Color accentColor, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg),
      child: Row(children: [
        Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.6)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTypography.titleSmall.copyWith(color: titleColor)),
          Text(subtitle, style: AppTypography.bodySmall.copyWith(color: mutedColor)),
        ])),
        const SizedBox(width: AppSpacing.md),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: AppDurations.normal, width: 44, height: 24, padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderFull,
              color: value ? accentColor.withValues(alpha: 0.3) : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
              border: Border.all(color: value ? accentColor.withValues(alpha: 0.5) : isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2)),
            ),
            child: AnimatedAlign(
              duration: AppDurations.normal, curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: value ? accentColor : isDark ? Colors.white54 : Colors.black26)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _linkRow({required IconData icon, required String label, required Color titleColor, required Color mutedColor, required Color accentColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg),
        child: Row(children: [
          Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.6)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTypography.titleSmall.copyWith(color: titleColor))),
          Icon(Icons.chevron_right_rounded, size: 18, color: mutedColor.withValues(alpha: 0.4)),
        ]),
      ),
    );
  }
}
