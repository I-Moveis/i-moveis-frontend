import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';

/// Edit profile — preenche os campos com os dados do usuário atual e
/// persiste alterações via `PATCH /users/me` (endpoint do self-service
/// que só aceita `phoneNumber` + `role`). Nome e email ficam read-only:
/// nome é mantido pelo Firebase Auth (updateDisplayName) e email é
/// identificador imutável.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _submitting = false;
  String _initialPhone = '';

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    final user = state.maybeWhen(
      authenticated: (u) => u,
      orElse: () => null,
    );

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _initialPhone = user?.phone ?? '';
    _phoneController = TextEditingController(text: _initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Converte input brasileiro (ex: `(11) 99999-9999`) para E.164
  /// (`+5511999999999`). `null` quando não há dígitos suficientes — o
  /// backend valida via regex `^\+\d{1,15}$`.
  String? _normalizeToE164(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (trimmed.startsWith('+')) return '+$digits';
    if (digits.length < 10) return null;
    return '+55$digits';
  }

  Future<void> _handleSave() async {
    if (_submitting) return;

    final rawPhone = _phoneController.text.trim();
    final normalized = _normalizeToE164(rawPhone);

    if (rawPhone.isNotEmpty && normalized == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefone inválido')),
      );
      return;
    }

    // Nenhuma mudança detectada — sai sem bater na API.
    if (normalized == _initialPhone ||
        (rawPhone.isEmpty && _initialPhone.isEmpty)) {
      context.pop();
      return;
    }

    setState(() => _submitting = true);

    try {
      final dio = ref.read(dioProvider);
      await dio.patch<Map<String, dynamic>>(
        '/users/me',
        data: {
          if (normalized != null) 'phoneNumber': normalized,
        },
      );

      // Atualiza o cache do /users/me e propaga pro AuthBloc pra UI refletir.
      final local = ref.read(authLocalDataSourceProvider);
      await local.syncFromBackend(dio);
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthEvent.sessionRefreshRequested());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado')),
      );
      context.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.message ?? 'tente novamente'}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: entrance,
            curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
          ),
        );
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        final avatarUrl = context.select<AuthBloc, String?>(
          (bloc) => bloc.state.maybeWhen(
            authenticated: (u) => u.avatarUrl,
            orElse: () => null,
          ),
        );

        return Opacity(
          opacity: fade.value,
          child: Column(
            children: [
              BrutalistAppBar(
                title: 'Editar perfil',
                actions: [
                  BrutalistAppBarAction(
                    icon: Icons.check_rounded,
                    onTap: () {
                      if (!_submitting) unawaited(_handleSave());
                    },
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      // Avatar
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withValues(alpha: 0.1),
                            image: avatarUrl != null && avatarUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: accentColor.withValues(alpha: 0.5),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      _field(
                        controller: _nameController,
                        label: 'Nome completo',
                        hint: 'Seu nome',
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                        titleColor: titleColor,
                        mutedColor: mutedColor,
                        accentColor: accentColor,
                        enabled: false,
                        helperText: 'Gerenciado pelo seu provedor de login',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _field(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'usuario@email.com',
                        icon: Icons.alternate_email_rounded,
                        isDark: isDark,
                        titleColor: titleColor,
                        mutedColor: mutedColor,
                        accentColor: accentColor,
                        enabled: false,
                        helperText: 'Seu identificador de login',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _field(
                        controller: _phoneController,
                        label: 'Telefone',
                        hint: '(11) 99999-0000',
                        icon: Icons.phone_outlined,
                        isDark: isDark,
                        titleColor: titleColor,
                        mutedColor: mutedColor,
                        accentColor: accentColor,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      BrutalistGradientButton(
                        label: _submitting ? 'SALVANDO…' : 'SALVAR',
                        icon: Icons.check_rounded,
                        onTap: _submitting
                            ? null
                            : () => unawaited(_handleSave()),
                      ),
                      const SizedBox(height: AppSpacing.massive),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color titleColor,
    required Color mutedColor,
    required Color accentColor,
    bool enabled = true,
    String? helperText,
    TextInputType? keyboardType,
  }) {
    final bgColor = enabled
        ? BrutalistPalette.surfaceBg(isDark)
        : BrutalistPalette.glassBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.titleSmall.copyWith(color: mutedColor)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: AppTypography.bodyLarge.copyWith(
              color: enabled ? titleColor : titleColor.withValues(alpha: 0.4),
            ),
            cursorColor: accentColor,
            cursorWidth: 1.5,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: BrutalistPalette.faint(isDark),
              ),
              prefixIcon: Icon(icon, size: 18, color: mutedColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.mdLg,
              ),
              filled: false,
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text(
              helperText,
              style: AppTypography.bodySmall.copyWith(
                color: BrutalistPalette.faint(isDark),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
