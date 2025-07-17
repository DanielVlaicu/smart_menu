import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorScreen extends StatelessWidget {
  final String qrData = 'https://smartmenu.app/restaurant-id-123';

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final qrImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(300);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(qrImage!.buffer.asUint8List())),
          );
        },
      ),
    );

    return pdf.save();
  }

  void _saveOrPrint(BuildContext context) async {
    final pdfData = await _generatePdf();

    await Printing.sharePdf(bytes: pdfData, filename: 'qr_code.pdf');
    // sau pentru printare directă:
    // await Printing.layoutPdf(onLayout: (format) => pdfData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generează Cod QR')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.qr_code),
          label: const Text('Generează și Salvează QR'),
          onPressed: () => _saveOrPrint(context),
        ),
      ),
    );
  }
}
