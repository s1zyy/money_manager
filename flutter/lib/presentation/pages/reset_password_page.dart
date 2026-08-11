import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/core/utils/overlay_notification.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/login_page.dart';
import 'package:money_manager/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? initialToken;

  const ResetPasswordPage({super.key, this.initialToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null) {
      _tokenController.text = widget.initialToken!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(AuthProvider auth, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await auth.resetPassword(
      _tokenController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      showSuccessOverlay(context, l10n.passwordChangedSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.key_outlined, size: 48, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      l10n.resetPasswordTitle,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.resetPasswordSubtitle,
                      style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _tokenController,
                      style: const TextStyle(color: AppTheme.textPrimary, letterSpacing: 4, fontWeight: FontWeight.w600),
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDecoration(l10n.resetCode, Icons.confirmation_number_outlined),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.enterResetCode;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: _inputDecoration(l10n.newPassword, Icons.lock_outline, suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      )),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.enterPassword;
                        if (v.length < 8) return l10n.passwordMin8;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: _inputDecoration(l10n.confirmPassword, Icons.lock_outline, suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      )),
                      validator: (v) {
                        if (v != _passwordController.text) return l10n.passwordsDoNotMatch;
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: auth.isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                          : FilledButton(
                              onPressed: () => _onSubmit(auth, l10n),
                              child: Text(l10n.changePassword, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(auth.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade400)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
    );
  }
}
