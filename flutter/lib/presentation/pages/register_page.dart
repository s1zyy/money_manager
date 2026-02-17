import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
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
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration successful!")));
                            Navigator.pop(context); // Return to the login screen
                          }
                        }, 
                        child: const Text("Register")
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