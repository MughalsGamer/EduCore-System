import 'dart:typed_data';

import 'web_pdf_opener_stub.dart'
if (dart.library.html) 'web_pdf_opener_web.dart' as impl;

void openPdfBytesInBrowser(Uint8List pdfBytes) {
  impl.openPdfBytesInBrowser(pdfBytes);
}

void downloadAndOpenPdfWeb(Uint8List pdfBytes, String fileName) {
  impl.downloadAndOpenPdfWeb(pdfBytes, fileName);
}