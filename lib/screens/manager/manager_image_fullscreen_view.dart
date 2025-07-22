import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ManagerImageFullscreenView extends StatelessWidget {
  final String imageUrl;

  const ManagerImageFullscreenView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isLocalFile = imageUrl.startsWith('/') || imageUrl.startsWith('file:');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              imageProvider: isLocalFile
                  ? FileImage(File(imageUrl))
                  : NetworkImage(imageUrl) as ImageProvider,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, progress) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, color: Colors.red, size: 60),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
