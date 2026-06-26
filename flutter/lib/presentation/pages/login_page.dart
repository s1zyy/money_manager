import 'package:flutter/material.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/register_page.dart';
import 'package:money_manager/presentation/pages/main_page.dart';
import 'package:money_manager/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  void _onLoginPressed(AuthProvider provider) async {
    final success = await provider.login(
      emailController.text.trim(), 
      passwordController.text.trim());
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TripsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body:Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.appTitle, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: l10n.email, border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.password, border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  if(auth.errorMessage != null)
                    Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  auth.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _onLoginPressed(auth),
                        child: Text(l10n.login),
                      ),
                    ),
                    const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: Text(
                          l10n.noAccountRegister,
                          style: TextStyle(color: Colors.blue),
                      ),
                      ),
                    
                ]

                
              )
            );

          }
        )

      );
      
  }
}