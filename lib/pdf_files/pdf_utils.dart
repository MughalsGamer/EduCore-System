import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

class PdfUtils {
  static Future<void> saveAndOpenPdf(Uint8List pdfBytes, String fileName) async {
    try {
      if (kIsWeb) {
        // ✅ WEB: PDF naye tab mein seedha khulta hai (print/preview dialog).
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: fileName,
        );
      } else {
        // ✅ MOBILE/DESKTOP: file save + auto-open (jaisa pehle tha).
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          print('Error opening file: ${result.message}');
        }
      }
    } catch (e) {
      throw Exception('PDF save/open failed: $e');
    }
  }
}