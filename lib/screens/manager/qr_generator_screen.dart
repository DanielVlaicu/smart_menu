import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';


class QRGeneratorScreen extends StatelessWidget {
  final String qrData = 'https://smartmenu.app/restaurant-id-123';

  const QRGeneratorScreen({super.key});

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final qrImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(300);

    final bytes = qrImage!.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Image(pw.MemoryImage(bytes))),
      ),
    );

    return pdf.save();
  }

  Future<void> _saveAsPdf() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(300, 300);

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

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/qr_code.png');
    await file.writeAsBytes(pngBytes);

    debugPrint('PNG salvat la: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generează Cod QR'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(data: qrData, size: 200),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saveAsPdf, child: const Text('Salvează ca PDF')),
            ElevatedButton(onPressed: () {
              // TODO: PNG export
            }, child: const Text('Salvează ca PNG')),
          ],
        ),
      ),
    );
  }
}