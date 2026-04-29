import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../listing/presentation/widgets/listing_form_fields.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_input.dart';
import '../providers/admin_users_notifier.dart';

/// Shared form for POST /users and PUT /users/:id. When [userId] is null
/// the page is in create mode; otherwise it hydrates from
/// `adminUserDetailProvider(userId)` and dispatches PUT on save.
class AdminUserFormPage extends ConsumerStatefulWidget {
  const AdminUserFormPage({this.userId, super.key});
  final String? userId;

  @override
  ConsumerState<AdminUserFormPage> createState() =>
      _AdminUserFormPageState();
}

class _AdminUserFormPageState extends ConsumerState<AdminUserFormPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'TENANT';

  bool _hydrated = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.userId != null;

  void _hydrate(AdminUser user) {
    if (_hydrated) return;
    _hydrated = true;
    _name.text = user.name;
    _phone.text = user.phoneNumber;
    _role = user.role;
  }

  Future<void> _onSave() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final name = _name.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Preencha nome e telefone.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final input = AdminUserInput(
        name: name,
        phoneNumber: phone,
        role: _role,
      );
      final notifier = ref.read(adminUsersNotifierProvider.notifier);
      if (_isEdit) {
        await notifier.edit(widget.userId!, input);
      } else {
        await notifier.create(input);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Usuário atualizado.' : 'Usuário criado.')),
      );
      router.pop();
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        final appBar = BrutalistAppBar(
          title: _isEdit ? 'Editar usuário' : 'Novo usuário',
        );

        if (_isEdit) {
          final async = ref.watch(adminUserDetailProvider(widget.userId!));
          return async.when(
            loading: () => Column(children: [
              appBar,
              const Expanded(
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ]),
            error: (e, _) => Column(children: [
              appBar,
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      e is Failure ? e.message : 'Erro ao carregar.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: BrutalistPalette.title(isDark)),
                    ),
                  ),
                ),
              ),
            ]),
            data: (user) {
              _hydrate(user);
              return _buildForm(context, appBar, isDark);
            },
          );
        }

        return _buildForm(context, appBar, isDark);
      },
    );
  }

  Widget _buildForm(BuildContext context, BrutalistAppBar appBar, bool isDark) {
    return Column(children: [
      appBar,
      Expanded(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const ListingSectionLabel('Nome'),
              ListingTextInput(
                controller: _name,
                hint: 'Nome completo',
              ),
              const SizedBox(height: AppSpacing.md),
              const ListingSectionLabel('Telefone (E.164)'),
              ListingTextInput(
                controller: _phone,
                hint: '+5511999999999',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              const ListingSectionLabel('Papel'),
              ListingChoiceRow<String>(
                options: const ['TENANT', 'LANDLORD', 'ADMIN'],
                selected: _role,
                onSelect: (v) => setState(() => _role = v),
                labelOf: _roleLabel,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              BrutalistGradientButton(
                label: _submitting ? 'SALVANDO...' : 'SALVAR',
                icon: Icons.check_rounded,
                onTap: _submitting ? null : _onSave,
              ),
              const SizedBox(height: AppSpacing.massive),
            ],
          ),
        ),
      ),
    ]);
  }

  static String _roleLabel(String r) {
    switch (r) {
      case 'LANDLORD':
        return 'Proprietário';
      case 'ADMIN':
        return 'Administrador';
      case 'TENANT':
      default:
        return 'Inquilino';
    }
  }
}
