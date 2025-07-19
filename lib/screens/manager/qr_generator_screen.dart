import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';


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

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Image(pw.MemoryImage(qrImage!.buffer.asUint8List())),
        ),
      ),
    );

    return pdf.save();
  }

  void _saveAsPdf() async {
    final pdfData = await _generatePdf();
    await Printing.sharePdf(bytes: pdfData, filename: 'qr_code.pdf');
  }

  void _saveAsPng() async {
    // TODO: implement PNG export (necesită alt pachet)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generează Cod QR'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ QrImageView(data: qrData, size: 200), const SizedBox(height: 16),
            ElevatedButton(onPressed: _saveAsPdf, child: const Text('Salvează ca PDF')),
            ElevatedButton(onPressed: _saveAsPng, child: const Text('Salvează ca PNG')),
            ElevatedButton(
              onPressed: () => Printing.layoutPdf(onLayout: (format) async => await _generatePdf()),
              child: const Text('Printează'),
            ),
          ],
        ),
      ),
    );
  }
}
