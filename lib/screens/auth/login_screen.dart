import 'package:flutter/material.dart';
import 'package:smart_menu/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  String error = '';
  bool loading = false;
  final Color themeBlue = const Color(0xFFB8D8F8);

  Future<void> handleLogin() async {
    setState(() => loading = true);
    final result = await authService.loginWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    setState(() => loading = false);

    if (result == 'success') {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (result!.contains('verificat')) {
      // Mesaj special dacă emailul nu e confirmat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifică adresa de email. Linkul a fost retrimis.')),
      );
      setState(() => error = result);
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Autentificare', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Bine ai revenit!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _textField(emailController, 'Email'),
              const SizedBox(height: 16),
              _textField(passwordController, 'Parola', obscure: true),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeBlue,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Autentificare'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                child: const Text(
                  'Nu ai cont? Creează unul',
                  style: TextStyle(color: Color(0xFFB8D8F8)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (emailController.text.trim().isNotEmpty) {
                    await authService.sendPasswordReset(emailController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email de resetare trimis')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Introdu un email valid pentru resetare.')),
                    );
                  }
                },
                child: const Text('Am uitat parola', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() => loading = true);
                  final result = await authService.signInWithGoogle();
                  setState(() => loading = false);
                  if (result == 'success') {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  } else {
                    setState(() => error = result ?? 'Eroare Google Login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Autentificare cu Google'),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, {bool obscure = false}) {
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
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }
}
