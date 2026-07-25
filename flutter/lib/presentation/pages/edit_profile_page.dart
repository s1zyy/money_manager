import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/core/utils/overlay_notification.dart';
import 'package:money_manager/domain/usecases/participant/delete_account.dart';
import 'package:money_manager/domain/usecases/participant/full_delete_account.dart';
import 'package:money_manager/injection_container.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/login_page.dart';
import 'package:money_manager/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _nameError;
  String? _currentPasswordError;
  bool _nameSaving = false;
  bool _passwordSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.currentUserName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (!_nameFormKey.currentState!.validate()) return;
    setState(() { _nameSaving = true; _nameError = null; });
    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final success = await auth.updateProfile(_nameController.text.trim());
    if (!mounted) return;
    if (success) {
      showSuccessOverlay(context, l10n.profileUpdated);
    } else {
      setState(() { _nameError = auth.errorMessage; });
    }
    setState(() { _nameSaving = false; });
  }

  Future<void> _savePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() { _passwordSaving = true; _currentPasswordError = null; });
    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final success = await auth.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );
    if (!mounted) return;
    if (success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      showSuccessOverlay(context, l10n.passwordChanged);
    } else {
      setState(() { _currentPasswordError = auth.errorMessage; });
    }
    setState(() { _passwordSaving = false; });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final initial = (auth.currentUserName?.isNotEmpty == true)
        ? auth.currentUserName![0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.textPrimary),
        title: Text(l10n.editProfile,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                child: Text(initial,
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ),
            ),
            const SizedBox(height: 32),

            // --- Profile section ---
            _sectionCard(
              children: [
                Form(
                  key: _nameFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label(l10n.name),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(l10n.enterName),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? l10n.enterName : null,
                      ),
                      const SizedBox(height: 12),
                      _label('Email'),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: auth.currentUserEmail ?? '',
                        enabled: false,
                        decoration: _inputDecoration('Email').copyWith(
                          fillColor: Colors.grey.shade100,
                          suffixIcon: const Icon(Icons.lock_outline,
                              size: 18, color: AppTheme.textSecondary),
                        ),
                      ),
                      if (_nameError != null) ...[
                        const SizedBox(height: 10),
                        Text(_nameError!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center),
                      ],
                      const SizedBox(height: 16),
                      _actionButton(
                        label: l10n.save,
                        loading: _nameSaving,
                        onTap: _saveName,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Password section ---

            _sectionLabel(l10n.changePassword),
            const SizedBox(height: 10),
            _sectionCard(
              children: [
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label(l10n.currentPassword),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        onChanged: (_) {
                          if (_currentPasswordError != null) {
                            setState(() => _currentPasswordError = null);
                          }
                        },
                        decoration: _inputDecoration(l10n.currentPassword).copyWith(
                          suffixIcon: _eyeIcon(_obscureCurrent,
                              () => setState(() => _obscureCurrent = !_obscureCurrent)),
                          errorText: _currentPasswordError,
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? l10n.enterPassword : null,
                      ),
                      const SizedBox(height: 12),
                      _label(l10n.newPassword),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        decoration: _inputDecoration(l10n.newPassword).copyWith(
                          suffixIcon: _eyeIcon(_obscureNew,
                              () => setState(() => _obscureNew = !_obscureNew)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.enterPassword;
                          if (v.length < 6) return l10n.passwordTooShort;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _label(l10n.confirmPassword),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: _inputDecoration(l10n.confirmPassword).copyWith(
                          suffixIcon: _eyeIcon(_obscureConfirm,
                              () => setState(() => _obscureConfirm = !_obscureConfirm)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.enterPassword;
                          if (v != _newPasswordController.text) return l10n.passwordsDoNotMatch;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _actionButton(
                        label: l10n.changePassword,
                        loading: _passwordSaving,
                        onTap: _savePassword,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Delete account ---
            InkWell(
              onTap: () => _confirmDeleteAccount(context, l10n, auth),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_forever_outlined, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Text(l10n.deleteAccount,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w500, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, AppLocalizations l10n, AuthProvider auth) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => _DeleteAccountSheet(l10n: l10n),
    );

    if (result == null || !context.mounted) return;

    try {
      if (result == 'full') {
        await sl<FullDeleteAccountUseCase>().call();
      } else {
        await sl<DeleteAccountUseCase>().call();
      }
      await auth.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorOverlay(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8)),
      );

  Widget _sectionCard({required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
      );

  Widget _eyeIcon(bool obscure, VoidCallback onTap) => IconButton(
        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20, color: AppTheme.textSecondary),
        onPressed: onTap,
      );

  Widget _actionButton({required String label, required bool loading, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
    );
  }
}

class _DeleteAccountSheet extends StatefulWidget {
  final AppLocalizations l10n;
  const _DeleteAccountSheet({required this.l10n});

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  String? _choice;
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: _choice == null ? _buildChoiceStep(context, l10n) : _buildConfirmStep(context, l10n),
      ),
    );
  }

  Widget _buildChoiceStep(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: const Icon(Icons.delete_forever_outlined, color: Colors.red, size: 32),
        ),
        const SizedBox(height: 16),
        Text(l10n.deleteAccountConfirmTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => setState(() => _choice = 'soft'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.deactivateAccount,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red, fontSize: 15)),
                const SizedBox(height: 2),
                Text(l10n.deleteAccountConfirmBody,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _choice = 'full'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.deleteEverything,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
                const SizedBox(height: 2),
                Text(l10n.deleteEverythingBody,
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _cancelButton(context, l10n, onTap: () => Navigator.pop(context, null)),
      ],
    );
  }

  Widget _buildConfirmStep(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        Text(l10n.areYouSure,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Text(l10n.typeDeleteToConfirm,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'DELETE',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _confirmController.text == 'DELETE'
              ? () => Navigator.pop(context, _choice)
              : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _confirmController.text == 'DELETE'
                  ? Colors.red
                  : Colors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(l10n.confirm,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 10),
        _cancelButton(context, l10n, onTap: () => setState(() { _choice = null; _confirmController.clear(); })),
      ],
    );
  }

  Widget _handle() => Container(
      width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)));

  Widget _cancelButton(BuildContext context, AppLocalizations l10n, {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
          child: Text(l10n.cancel,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ),
      );
}
