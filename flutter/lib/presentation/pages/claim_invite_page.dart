import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/main_page.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ClaimInvitePage extends StatefulWidget {
  const ClaimInvitePage({super.key});

  @override
  State<ClaimInvitePage> createState() => _ClaimInvitePageState();
}

class _ClaimInvitePageState extends State<ClaimInvitePage> {
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _codeValidated = false;
  bool _requiresLogin = false;
  String? _tripName;
  String? _participantName;
  String? _validatedToken;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onValidateCode(AuthProvider auth) async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 8) return;
    final result = await auth.validateInviteToken(code);
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _codeValidated = true;
        _validatedToken = code;
        _tripName = result['tripName'] as String;
        _participantName = result['participantName'] as String;
        _emailController.text = result['invitedEmail'] as String;
        _requiresLogin = result['requiresLogin'] as bool;
      });
    }
  }

  Future<void> _onClaimPressed(AuthProvider auth, AppLocalizations l10n) async {
    final password = _passwordController.text.trim();
    if (password.length < 6) {
      setState(() => _passwordError = l10n.passwordTooShort);
      return;
    }

    final success = _requiresLogin
        ? await auth.claimInviteWithLogin(_validatedToken!, password)
        : await auth.register(_emailController.text.trim(), password, _participantName!, inviteToken: _validatedToken);
    if (!mounted) return;
    if (success) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const TripsPage()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.secondary],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.email_outlined, size: 44, color: Colors.white),
                              const SizedBox(height: 12),
                              Text(
                                l10n.inviteCode,
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Шаг 1: ввод кода
                      TextField(
                        controller: _codeController,
                        enabled: !_codeValidated,
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(
                          color: _codeValidated ? AppTheme.textSecondary : AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                        textAlign: TextAlign.center,
                        maxLength: 8,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: l10n.inviteCodeFromLetter,
                          labelStyle: const TextStyle(color: AppTheme.textSecondary, letterSpacing: 0),
                          hintText: 'XXXXXXXX',
                          hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 6, fontSize: 22),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: _codeValidated
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.green, width: 1.5)),
                        ),
                      ),

                      if (auth.errorMessage != null && !_codeValidated) ...[
                        const SizedBox(height: 8),
                        Text(auth.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],

                      if (_codeValidated) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, color: AppTheme.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _requiresLogin
                                      ? l10n.loginToJoinAs(_participantName!)
                                      : l10n.youWillJoinAs(_participantName!, _tripName!),
                                  style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          enabled: false,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _passwordController,
                          label: l10n.password,
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          errorText: _passwordError,
                          onChanged: (_) { if (_passwordError != null) setState(() => _passwordError = null); },
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: (auth.isLoading || auth.isValidatingToken)
                            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                            : FilledButton(
                                onPressed: _codeValidated
                                    ? () => _onClaimPressed(auth, l10n)
                                    : () => _onValidateCode(auth),
                                child: Text(
                                  _codeValidated ? l10n.signInToTrip : l10n.checkCode,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                      ),
                      if (auth.errorMessage != null && _codeValidated) ...[
                        const SizedBox(height: 10),
                        Text(auth.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }
}
