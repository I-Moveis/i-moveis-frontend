import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

/// Individual chat — cozy message view with warm input bar.
class ChatPage extends ConsumerWidget {
  const ChatPage({required this.conversationId, super.key});
  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(
      authenticated: (user) => user.isOwner,
      orElse: () => false,
    );

        final headerTitle = isOwner ? 'Inquilino / Contato' : 'Proprietário';

        return BrutalistPageScaffold(
          waveAmplitude: 0.3, waveCount: 3, waveSpeed: 0.2,
          resizeToAvoidBottomInset: true,
          builder: (context, isDark, entrance, pulse) {
            final fade = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: entrance, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
            );
            final titleColor = BrutalistPalette.title(isDark);
            final mutedColor = BrutalistPalette.muted(isDark);
            final accentColor = isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

            return Opacity(opacity: fade.value, child: Column(children: [
              BrutalistAppBar(
                title: headerTitle, 
                onBack: () => context.go('/chat'), 
                actions: [BrutalistAppBarAction(icon: Icons.info_outline_rounded, onTap: () {})]
              ),
              Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 40, color: accentColor.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.lg),
                Text('Nenhuma mensagem', style: AppTypography.headlineMedium.copyWith(color: titleColor)),
                const SizedBox(height: AppSpacing.xs),
                Text('Envie a primeira mensagem', style: AppTypography.bodyMedium.copyWith(color: mutedColor)),
              ]))),
              // Input bar
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Row(children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.attach_file_rounded, size: 20, color: mutedColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    Expanded(child: TextField(
                      style: AppTypography.bodyMedium.copyWith(color: titleColor),
                      cursorColor: accentColor, cursorWidth: 1.5,
                      decoration: InputDecoration(
                        hintText: 'Mensagem...',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: BrutalistPalette.faint(isDark)),
                        filled: true,
                        fillColor: BrutalistPalette.surfaceBg(isDark),
                        border: OutlineInputBorder(borderRadius: AppRadius.borderRound, borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                        isDense: true,
                      ),
                    )),
                    const SizedBox(width: AppSpacing.xs),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: isDark ? [BrutalistPalette.warmBrown, BrutalistPalette.warmOrange] : [BrutalistPalette.deepBrown, BrutalistPalette.deepOrange]),
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Icon(Icons.send_rounded, size: 16, color: isDark ? AppColors.black : AppColors.white),
                      ),
                    ),
                  ]),
                ),
              ),
            ]));
          },
        );
  }
}
