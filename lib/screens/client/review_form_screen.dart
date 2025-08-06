import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_services.dart';
import 'package:flutter/foundation.dart';

class ReviewFormScreen extends StatefulWidget {
  final String restaurantUid;
  const ReviewFormScreen({required this.restaurantUid, Key? key}) : super(key: key);

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  File? _selectedImage;
  bool _loading = false;

  XFile? _webPickedFile;
  Uint8List? _webImageBytes;

  String? _contactError;


  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    return phoneRegex.hasMatch(phone);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Selectează sursa',
          style: TextStyle(color: Colors.white),
        ),
        contentTextStyle: const TextStyle(color: Colors.white),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.photo, color: Colors.white),
            label: const Text('Galerie', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text('Cameră', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webPickedFile = picked;
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    String? contactError;

    if (email.isEmpty && phone.isEmpty) {
      contactError = 'Completează cel puțin email sau telefon';
    } else {
      if (email.isNotEmpty && !_isValidEmail(email)) {
        contactError = 'Emailul introdus nu este valid';
      }
      if (phone.isNotEmpty && !_isValidPhone(phone)) {
        contactError = 'Numărul de telefon nu este valid';
      }
    }

    setState(() => _contactError = contactError);

    if (!isValid || contactError != null) return;

    setState(() => _loading = true);

    try {
      await ApiService.submitPublicReview(
        restaurantUid: widget.restaurantUid,
        email: email,
        phone: phone,
        message: _messageController.text.trim(),
        imageFile: kIsWeb ? null : _selectedImage,
        webImageBytes: kIsWeb ? _webImageBytes : null,
        webImageName: kIsWeb ? _webPickedFile?.name : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Review trimis cu succes'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Eroare la trimiterea review-ului: $e'),
        ),
      );
    }

    setState(() => _loading = false);
  }


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Trimite Review'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
            TextFormField(
            controller: _emailController,
            onChanged: (_) => _validateContact(),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Email'),

              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Telefon'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                ],
              ),
              const SizedBox(height: 10),
              if (_contactError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _contactError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              TextFormField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Descriere'),
                maxLines: 4,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Introdu un mesaj' : null,
              ),
              const SizedBox(height: 10),
              if (!kIsWeb && _selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.file(_selectedImage!, height: 150),
                ),

              if (kIsWeb && _webImageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.memory(_webImageBytes!, height: 150),
                ),
              TextButton.icon(
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text('Alege imagine', style: TextStyle(color: Colors.white)),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // poți pune 0 pentru complet pătrat
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Trimite Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateContact() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    String? error;

    if (email.isEmpty && phone.isEmpty) {
      error = 'Completează cel puțin email sau telefon';
    } else {
      if (email.isNotEmpty && !_isValidEmail(email)) {
        error = 'Emailul introdus nu este valid';
      }
      if (phone.isNotEmpty && !_isValidPhone(phone)) {
        error = 'Numărul de telefon nu este valid';
      }
    }

    setState(() => _contactError = error);
  }
}
