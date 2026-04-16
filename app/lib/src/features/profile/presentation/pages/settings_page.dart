import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/design_system/design_system.dart';
import 'package:app/src/core/theme/theme_provider.dart';

/// Settings — cozy toggles and links with working theme switch.
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

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        return Opacity(opacity: fade.value, child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: BrutalistAppBar(title: 'Configurações')),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Preferences section
                Text('Preferências', style: AppTypography.titleSmallBold.copyWith(color: titleColor.withValues(alpha: 0.5))),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
                  child: Column(children: [
                    _toggleRow(icon: Icons.notifications_outlined, label: 'Notificações', subtitle: 'Alertas sobre seus imóveis', value: _notifications, isDark: isDark, titleColor: titleColor, mutedColor: mutedColor, accentColor: accentColor, onChanged: (v) => setState(() => _notifications = v)),
                    Divider(height: 1, indent: AppSpacing.lg + 20 + AppSpacing.md, color: borderColor),
                    _toggleRow(icon: isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined, label: isDarkMode ? 'Modo escuro' : 'Modo claro', subtitle: 'Alternar tema do app', value: isDarkMode, isDark: isDark, titleColor: titleColor, mutedColor: mutedColor, accentColor: accentColor, onChanged: (_) => ref.read(themeProvider.notifier).toggle()),
                  ]),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Legal section
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
              color: value ? accentColor.withValues(alpha: 0.3) : BrutalistPalette.faint(isDark).withValues(alpha: 0.15),
              border: Border.all(color: value ? accentColor.withValues(alpha: 0.5) : BrutalistPalette.faint(isDark).withValues(alpha: 0.3)),
            ),
            child: AnimatedAlign(
              duration: AppDurations.normal, curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: value ? accentColor : BrutalistPalette.faint(isDark))),
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
