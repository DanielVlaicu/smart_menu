import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  String errorMessage = '';
  final Color themeBlue = const Color(0xFFB8D8F8);

  Future<void> handleRegister() async {
    if (passController.text != confirmController.text) {
      setState(() => errorMessage = 'Parolele nu coincid');
      return;
    }

    final user = await AuthService().registerWithEmail(
      emailController.text.trim(),
      passController.text.trim(),
    );

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() => errorMessage = 'Înregistrarea a eșuat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Înregistrare'), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Creează un cont nou',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _buildTextField(controller: emailController, label: 'Email'),
            const SizedBox(height: 16),
            _buildTextField(controller: passController, label: 'Parolă', obscure: true),
            const SizedBox(height: 16),
            _buildTextField(controller: confirmController, label: 'Confirmă parola', obscure: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeBlue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Înregistrează-te'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Ai deja cont? Autentifică-te',
                  style: TextStyle(color: Color(0xFFB8D8F8))),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool obscure = false}) {
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