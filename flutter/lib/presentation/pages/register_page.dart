import 'package:flutter/material.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
                  TextField(controller: emailController, decoration: InputDecoration(labelText: l10n.email)),
                  TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: l10n.password)),
                  const SizedBox(height: 24),
                  auth.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          final success = await auth.register(
                            emailController.text,
                            passwordController.text,
                            nameController.text
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.registrationSuccessful)));
                            Navigator.pop(context);
                          }
                        },
                        child: Text(l10n.register)
                      ),


                  if (auth.errorMessage != null) Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
              ),
            );
          },
        ),
      );

  }
}