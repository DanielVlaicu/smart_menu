import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class QRGeneratorScreen extends StatelessWidget {
  final String uid;
  const QRGeneratorScreen({super.key, required this.uid});

  String get qrData => 'https://smartmenu-d3e47.web.app?client=true&uid=$uid';
  final Color themeBlue = const Color(0xFFB8D8F8);

  Future<File> _generatePngFile() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(300, 300);

    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    );

    qrPainter.paint(canvas, size);
    final picture = recorder.endRecording();
    final img = await picture.toImage(300, 300);
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qr_code.png');
    await file.writeAsBytes(pngBytes);
    return file;
  }

  Future<void> _saveAsPng(BuildContext context) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final file = await _generatePngFile();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PNG salvat la: ${file.path}')),
    );
  }

  Future<void> _saveAsPdf(BuildContext context) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final qrImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(300);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Image(pw.MemoryImage(qrImage!.buffer.asUint8List())),
        ),
      ),
    );

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/qr_code.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF salvat la: ${file.path}')),
    );
  }

  Future<void> _shareQrCode(BuildContext context) async {
    final file = await _generatePngFile();
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Scanează codul QR pentru a accesa meniul!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cod QR Meniu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: qrData,
                size: 220,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 24),
              _buildButton(context, Icons.picture_as_pdf, 'Salvează ca PDF', () => _saveAsPdf(context)),
              const SizedBox(height: 12),
              _buildButton(context, Icons.image_outlined, 'Salvează ca PNG', () => _saveAsPng(context)),
              const SizedBox(height: 12),
              _buildButton(context, Icons.share, 'Partajează Codul', () => _shareQrCode(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String text, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeBlue,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
