import 'package:flutter/material.dart';
import 'package:smart_menu/services/auth_service.dart';

import '../../services/api_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final authService = AuthService();
  String errorMessage = '';
  final Color themeBlue = const Color(0xFFB8D8F8);
  bool isLoading = false;

  Future<void> handleRegister() async {
    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    if (passController.text != confirmController.text) {
      setState(() {
        errorMessage = 'Parolele nu coincid';
        isLoading = false;
      });
      return;
    }

    final result = await authService.registerWithEmail(
      emailController.text.trim(),
      passController.text.trim(),
    );

    if (result == 'success') {
      await ApiService.initializeUser();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Cont creat'),
          content: const Text('Verifică email-ul pentru a activa contul. Apoi te poți autentifica.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    } else {
      setState(() => errorMessage = result ?? 'Eroare necunoscută');
    }

    setState(() => isLoading = false);
  }

  void showLoadingOverlay() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(title: const Text('Înregistrare'), backgroundColor: Colors.black),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Creează un cont nou',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                _buildTextField(controller: emailController, label: 'Email'),
                const SizedBox(height: 16),
                _buildTextField(controller: passController, label: 'Parolă', obscure: true),
                const SizedBox(height: 16),
                _buildTextField(controller: confirmController, label: 'Confirmă parola', obscure: true),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeBlue,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Înregistrează-te'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    'Ai deja cont? Autentifică-te',
                    style: TextStyle(color: Color(0xFFB8D8F8)),
                  ),
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white30)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white)),
      ),
    );
  }
}
