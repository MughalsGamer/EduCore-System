import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:html' as html; // صرف ویب کے لیے

class PdfUtils {
  static Future<void> saveAndOpenPdf(Uint8List pdfBytes, String fileName) async {
    try {
      if (kIsWeb) {
        // ✅ ویب: PDF براہ راست نئے ٹیب میں کھلے گی (Auto-Open)
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, '_blank'); // نیا ٹیب کھلے گا
        // صارف براؤزر سے خود بھی ڈاؤن لوڈ کر سکتا ہے۔
      } else {
        // ✅ موبائل: فائل سیو کریں اور خودکار اوپن کریں
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