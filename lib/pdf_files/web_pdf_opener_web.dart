import 'dart:typed_data';
import 'dart:html' as html;

void openPdfBytesInBrowser(Uint8List pdfBytes) {
  final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
}

void downloadAndOpenPdfWeb(Uint8List pdfBytes, String fileName) {
  final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.window.open(url, '_blank');

  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  Future.delayed(const Duration(seconds: 5), () {
    html.Url.revokeObjectUrl(url);
  });
}