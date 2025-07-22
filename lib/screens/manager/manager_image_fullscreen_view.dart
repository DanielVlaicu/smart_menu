import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageFullscreenView extends StatelessWidget {
  final String imageUrl;

  const ImageFullscreenView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final bool isLocalFile = imageUrl.startsWith('/');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: isLocalFile
                ? FileImage(File(imageUrl)) as ImageProvider
                : NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}