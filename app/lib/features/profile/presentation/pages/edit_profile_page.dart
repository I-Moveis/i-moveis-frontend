import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

/// Edit profile — cozy form with rounded inputs.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(opacity: fade.value, child: Column(children: [
          BrutalistAppBar(title: 'Editar perfil', actions: [BrutalistAppBarAction(icon: Icons.check_rounded, onTap: () => Navigator.of(context).pop())]),
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: AppSpacing.xl),
              // Avatar
              Center(child: Stack(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withValues(alpha: 0.1)),
                  child: Icon(Icons.person_rounded, size: 36, color: accentColor.withValues(alpha: 0.5)),
                ),
                Positioned(bottom: 0, right: 0, child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    child: Icon(Icons.camera_alt_rounded, size: 14, color: isDark ? AppColors.black : AppColors.white),
                  ),
                )),
              ])),
              const SizedBox(height: AppSpacing.xxxl),
              _field('Nome completo', 'Seu nome', Icons.person_outline_rounded, isDark, titleColor, mutedColor, accentColor),
              const SizedBox(height: AppSpacing.xl),
              _field('Email', 'usuario@email.com', Icons.alternate_email_rounded, isDark, titleColor, mutedColor, accentColor, enabled: false),
              const SizedBox(height: AppSpacing.xl),
              _field('Telefone', '(11) 99999-0000', Icons.phone_outlined, isDark, titleColor, mutedColor, accentColor),
              const SizedBox(height: AppSpacing.xl),
              _field('CPF', '000.000.000-00', Icons.badge_outlined, isDark, titleColor, mutedColor, accentColor),
              const SizedBox(height: AppSpacing.xxxl),
              BrutalistGradientButton(label: 'SALVAR', icon: Icons.check_rounded, onTap: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.massive),
            ]),
          )),
        ]));
      },
    );
  }

  Widget _field(String label, String hint, IconData icon, bool isDark, Color titleColor, Color mutedColor, Color accentColor, {bool enabled = true}) {
    final bgColor = enabled ? BrutalistPalette.surfaceBg(isDark) : BrutalistPalette.glassBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.titleSmall.copyWith(color: mutedColor)),
      const SizedBox(height: AppSpacing.sm),
      Container(
        decoration: BoxDecoration(color: bgColor, borderRadius: AppRadius.borderLg, border: Border.all(color: borderColor)),
        child: TextField(
          enabled: enabled,
          style: AppTypography.bodyLarge.copyWith(color: enabled ? titleColor : titleColor.withValues(alpha: 0.4)),
          cursorColor: accentColor, cursorWidth: 1.5,
          decoration: InputDecoration(
            hintText: hint, hintStyle: AppTypography.bodyLarge.copyWith(color: BrutalistPalette.faint(isDark)),
            prefixIcon: Icon(icon, size: 18, color: mutedColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdLg),
            filled: false,
          ),
        ),
      ),
    ]);
  }
}
