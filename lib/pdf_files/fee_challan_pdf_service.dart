//
//
// import 'package:pdf/pdf.dart';
// import 'dart:typed_data';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// import '../models/fee_challan_model.dart';
// import '../models/school_setting_model.dart';
//
// class FeeChallanPdfService {
//   // ─── UPDATED COLORS TO MATCH IMAGE ──────────────────────────────────────────
//   static const PdfColor _purple = PdfColor.fromInt(0xFF534AB7);    // Main primary
//   static const PdfColor _darkPurple = PdfColor.fromInt(0xFF3B3586); // Header & Table
//   static const PdfColor _lightPurple = PdfColor.fromInt(0xFFEEECFA); // Background boxes
//   static const PdfColor _grey = PdfColor.fromInt(0xFF6B7280);
//   static const PdfColor _borderGrey = PdfColor.fromInt(0xFFE5E7EB);
//   static const PdfColor _lightRedBg = PdfColor.fromInt(0xFFFEF2F2);
//   static const PdfColor _red = PdfColor.fromInt(0xFFDC2626);
//   static const PdfColor _green = PdfColor.fromInt(0xFF16A34A);
//
//   // ─── STATIC SCHOOL DATA ──────────────────────────────────────────────────────
//   static const String schoolName = 'Your School Name';
//   static const String schoolPhone = '123-4567890';
//   static const String schoolAddress = '123 Main Street, City, State';
//   static const String schoolCity = 'City';
//
//   // ── Public API ──
//
//   static Future<Uint8List> buildSinglePdf(
//       FeeChallanModel challan,
//       SchoolSettings settings,
//       ) async {
//     final doc = pw.Document();
//     doc.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(24),
//         build: (context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             _challanBlock(challan, settings, compact: false),
//           ],
//         ),
//       ),
//     );
//     return doc.save();
//   }
//
//   static Future<Uint8List> buildMergedPdf(
//       List<FeeChallanModel> challans,
//       SchoolSettings settings,
//       ) async {
//     final doc = pw.Document();
//
//     for (var i = 0; i < challans.length; i += 2) {
//       final first = challans[i];
//       final second = (i + 1 < challans.length) ? challans[i + 1] : null;
//
//       doc.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//           build: (context) => pw.Column(
//             children: [
//               _challanBlock(first, settings, compact: true),
//               pw.SizedBox(height: 10),
//               pw.Container(
//                 height: 0,
//                 decoration: const pw.BoxDecoration(
//                   border: pw.Border(
//                     top: pw.BorderSide(
//                         color: _borderGrey, width: 1, style: pw.BorderStyle.dashed),
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 10),
//               if (second != null)
//                 _challanBlock(second, settings, compact: true)
//               else
//                 pw.Expanded(child: pw.Container()),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return doc.save();
//   }
//
//   static Future<void> downloadAndOpen(
//       FeeChallanModel challan,
//       SchoolSettings settings,
//       ) async {
//     final bytes = await buildSinglePdf(challan, settings);
//     await Printing.sharePdf(
//       bytes: bytes,
//       filename: 'Challan_${challan.challanNumber}.pdf',
//     );
//   }
//
//   static Future<void> printChallan(
//       FeeChallanModel challan,
//       SchoolSettings settings,
//       ) async {
//     final bytes = await buildSinglePdf(challan, settings);
//     await Printing.layoutPdf(
//       onLayout: (format) async => bytes,
//       name: 'Challan_${challan.challanNumber}.pdf',
//     );
//   }
//
//   static Future<void> bulkDownload(
//       List<FeeChallanModel> challans,
//       SchoolSettings settings,
//       ) async {
//     final bytes = await buildMergedPdf(challans, settings);
//     await Printing.sharePdf(
//       bytes: bytes,
//       filename: 'Fee_Challans_Bulk.pdf',
//     );
//   }
//
//   static Future<void> bulkPrint(
//       List<FeeChallanModel> challans,
//       SchoolSettings settings,
//       ) async {
//     final bytes = await buildMergedPdf(challans, settings);
//     await Printing.layoutPdf(
//       onLayout: (format) async => bytes,
//       name: 'Fee_Challans_Bulk.pdf',
//     );
//   }
//
//   // ── Layout Builders ──
//
//   static pw.Widget _challanBlock(
//       FeeChallanModel c,
//       SchoolSettings settings, {
//         required bool compact,
//       }) {
//     return pw.Container(
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: _borderGrey, width: 1),
//         borderRadius: pw.BorderRadius.circular(6),
//       ),
//       padding: const pw.EdgeInsets.all(12),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           _schoolHeader(),
//           pw.SizedBox(height: 8),
//           pw.Container(height: 1, color: _borderGrey),
//           pw.SizedBox(height: 8),
//           _challanMetaRow(c),
//           pw.SizedBox(height: 12),
//           _studentTable(c),
//           pw.SizedBox(height: 12),
//           _bottomBlocks(c),
//           if (!compact) ...[
//             pw.SizedBox(height: 12),
//             pw.Container(
//               width: double.infinity,
//               decoration: const pw.BoxDecoration(
//                 border: pw.Border(
//                   top: pw.BorderSide(
//                       color: _borderGrey, width: 1, style: pw.BorderStyle.dotted),
//                 ),
//               ),
//               padding: const pw.EdgeInsets.only(top: 8),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.center,
//                 children: [
//                   pw.Text('♥', style: pw.TextStyle(fontSize: 12, color: _purple)),
//                   pw.SizedBox(width: 6),
//                   pw.Text(
//                     'Thank you for your timely payment!',
//                     style: pw.TextStyle(fontSize: 8, color: _grey),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ─── HEADER (Logo + School Name + Right Purple Block) ──────────────────────
//   static pw.Widget _schoolHeader() {
//     return pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.center,
//       children: [
//         pw.Expanded(
//           flex: 2,
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Row(
//                 children: [
//                   // Logo
//                   pw.Container(
//                     width: 34,
//                     height: 34,
//                     alignment: pw.Alignment.center,
//                     decoration: pw.BoxDecoration(
//                       color: _lightPurple,
//                       shape: pw.BoxShape.circle,
//                     ),
//                     child: pw.Text('S', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _darkPurple)),
//                   ),
//                   pw.SizedBox(width: 10),
//                   pw.Text(
//                     schoolName,
//                     style: pw.TextStyle(
//                         fontSize: 16,
//                         fontWeight: pw.FontWeight.bold,
//                         color: _darkPurple),
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 4),
//               pw.Text('📍 $schoolAddress',
//                   style: pw.TextStyle(fontSize: 8, color: _grey)),
//               pw.Text('📞 Ph: $schoolPhone  |  $schoolCity',
//                   style: pw.TextStyle(fontSize: 8, color: _grey)),
//             ],
//           ),
//         ),
//         pw.Container(
//           width: 140,
//           height: 60,
//           padding: const pw.EdgeInsets.symmetric(horizontal: 10),
//           decoration: const pw.BoxDecoration(
//             color: _darkPurple,
//             borderRadius: pw.BorderRadius.only(
//               bottomLeft: pw.Radius.circular(15),
//               topLeft: pw.Radius.circular(15),
//             ),
//           ),
//           alignment: pw.Alignment.center,
//           child: pw.Text(
//             'FEE CHALLAN',
//             style: pw.TextStyle(
//                 fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── META INFO ROW (Light Purple box, with Foolproof Shapes) ──────────────
//   static pw.Widget _challanMetaRow(FeeChallanModel c) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(12),
//       decoration: pw.BoxDecoration(
//         color: _lightPurple,
//         borderRadius: pw.BorderRadius.circular(8),
//         border: pw.Border.all(color: _borderGrey, width: 0.5),
//       ),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           // Column 1: Family, Father, Phone
//           pw.Expanded(
//             flex: 3,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // ⭐ CHANGED HERE: Family ID show kiya Family Name ke aaghy
//                 _metaRowCircleIcon('F', 'Family ID', c.familyName.isNotEmpty ? ' (${c.familyId})' : ''),
//                 _metaRowCircleIcon('P', 'Father', c.fatherName),
//                 if (c.fatherPhone.isNotEmpty)
//                   _metaRowCircleIcon('T', 'Phone', c.fatherPhone),
//               ],
//             ),
//           ),
//           // Column 2: Challan #, Month, Family ID (Agar chahein toh Family ID yahan se hata bhi sakte hain)
//           pw.Expanded(
//             flex: 2,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 _metaRowCircleIcon('D', 'Challan #', c.challanNumber),
//                 _metaRowCircleIcon('C', 'Month', '${c.monthLabel} ${c.year}'),
//                 // Aap chahein toh yahan wali Family ID ko hata kar " " (empty) kar sakte hain, abhi filhal rakha hai
//                 // _metaRowCircleIcon('I', 'Family ID', c.familyId),
//               ],
//             ),
//           ),
//           // Column 3: Generated, Due (with red background)
//           pw.Expanded(
//             flex: 2,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 _metaRowCircleIcon('G', 'Generated', _fmt(c.generatedDate)),
//                 pw.SizedBox(height: 4),
//                 pw.Container(
//                   padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//                   decoration: pw.BoxDecoration(
//                     color: _lightRedBg,
//                     borderRadius: pw.BorderRadius.circular(4),
//                   ),
//                   child: pw.Row(
//                     children: [
//                       pw.Container(
//                           width: 14, height: 14,
//                           decoration: const pw.BoxDecoration(color: _red, shape: pw.BoxShape.circle),
//                           alignment: pw.Alignment.center,
//                           child: pw.Text('!', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))
//                       ),
//                       pw.SizedBox(width: 4),
//                       pw.Text('Due: ${_fmt(c.dueDate)}',
//                           style: pw.TextStyle(
//                               fontSize: 8, color: _red, fontWeight: pw.FontWeight.bold)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Foolproof Icon System (Replaces emojis and PdfIcons)
//   static pw.Widget _metaRowCircleIcon(String iconLetter, String label, String value) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 4),
//       child: pw.Row(
//         children: [
//           pw.Container(
//             width: 14,
//             height: 14,
//             decoration: const pw.BoxDecoration(
//                 color: _purple,
//                 shape: pw.BoxShape.circle
//             ),
//             alignment: pw.Alignment.center,
//             child: pw.Text(
//               iconLetter,
//               style: pw.TextStyle(
//                   color: PdfColors.white,
//                   fontSize: 7,
//                   fontWeight: pw.FontWeight.bold
//               ),
//             ),
//           ),
//           pw.SizedBox(width: 6),
//           pw.Text('$label: ', style: pw.TextStyle(fontSize: 8, color: _grey)),
//           pw.Text(value.isNotEmpty ? value : '—',
//               style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   // ─── DYNAMIC STUDENT TABLE ───────────────────────────────────────────────────
//   static pw.Widget _studentTable(FeeChallanModel c) {
//     bool showAdmission = c.students.any((s) => s.registrationFee > 0);
//     bool showAnnual = c.students.any((s) => s.annualFee > 0);
//
//     List<double> flexValues = [];
//     flexValues.add(0.5); // #
//     flexValues.add(2.0); // Student
//     flexValues.add(1.5); // Class
//     if (showAdmission) flexValues.add(1.2);
//     if (showAnnual) flexValues.add(1.2);
//     flexValues.add(1.2); // Monthly
//     flexValues.add(1.2); // Total
//
//     List<pw.Widget> headerChildren = [
//       _tableHeaderCell('#', flex: 0.5, align: pw.TextAlign.center),
//       _tableHeaderCell('Student', flex: 2.0),
//       _tableHeaderCell('Class', flex: 1.5),
//       if (showAdmission) _tableHeaderCell('Admission', flex: 1.2, align: pw.TextAlign.right),
//       if (showAnnual) _tableHeaderCell('Annual', flex: 1.2, align: pw.TextAlign.right),
//       _tableHeaderCell('Monthly Fee', flex: 1.2, align: pw.TextAlign.right),
//       _tableHeaderCell('Total', flex: 1.2, align: pw.TextAlign.right),
//     ];
//
//     List<pw.TableRow> rows = [];
//     for (int i = 0; i < c.students.length; i++) {
//       final student = c.students[i];
//       List<pw.Widget> cells = [];
//
//       // # Column with light purple box
//       cells.add(pw.Container(
//         padding: const pw.EdgeInsets.symmetric(vertical: 5),
//         alignment: pw.Alignment.center,
//         child: pw.Container(
//           padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: pw.BoxDecoration(
//             color: _lightPurple,
//             borderRadius: pw.BorderRadius.circular(4),
//           ),
//           child: pw.Text('${i + 1}',
//               style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
//         ),
//       ));
//
//       cells.add(_tableCell(student.name, bold: true));
//       cells.add(_tableCell([student.className, student.sectionName]
//           .whereType<String>()
//           .join(' - ')));
//
//       if (showAdmission) {
//         cells.add(_tableCell(
//             student.registrationFee > 0
//                 ? student.registrationFee.toStringAsFixed(0)
//                 : '—',
//             align: pw.TextAlign.right));
//       }
//       if (showAnnual) {
//         cells.add(_tableCell(
//             student.annualFee > 0 ? student.annualFee.toStringAsFixed(0) : '—',
//             align: pw.TextAlign.right));
//       }
//       cells.add(_tableCell(student.monthlyFee.toStringAsFixed(0), align: pw.TextAlign.right));
//       cells.add(_tableCell(student.lineTotal.toStringAsFixed(0), align: pw.TextAlign.right, bold: true));
//
//       rows.add(pw.TableRow(children: cells));
//     }
//
//     Map<int, pw.FlexColumnWidth> columnWidths = {};
//     for (int i = 0; i < flexValues.length; i++) {
//       columnWidths[i] = pw.FlexColumnWidth(flexValues[i]);
//     }
//
//     return pw.Table(
//       border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
//       columnWidths: columnWidths,
//       children: [
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: _darkPurple),
//           children: headerChildren,
//         ),
//         ...rows,
//       ],
//     );
//   }
//
//   static pw.Widget _tableHeaderCell(String text,
//       {double flex = 1.0, pw.TextAlign align = pw.TextAlign.left}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
//       child: pw.Text(
//         text,
//         textAlign: align,
//         style: pw.TextStyle(
//             fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
//       ),
//     );
//   }
//
//   static pw.Widget _tableCell(String text,
//       {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
//       child: pw.Text(
//         text,
//         textAlign: align,
//         style: pw.TextStyle(
//             fontSize: 8,
//             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
//       ),
//     );
//   }
//
//   // ─── BOTTOM BLOCKS (Left: NOTE | Right: This Challan Total) ───────────────
//   // NOTE: FeeChallanModel is now a PURE DEBIT entry — it no longer carries
//   // previousBalance / grandTotal / amountPaid / remainingBalance. Those
//   // fields were removed from the model, so this block only shows
//   // currentMonthTotal (what this specific challan charges). Family-wide
//   // running balance (debits - credits) is a ledger concern, computed live
//   // elsewhere (FeeCollectionProvider), not baked into the challan PDF.
//
//   static pw.Widget _bottomBlocks(FeeChallanModel c) {
//     final hasPreviousBalance = c.previousBalance != 0;
//
//     return pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Expanded(
//           flex: 1,
//           child: pw.Container(
//             padding: const pw.EdgeInsets.all(10),
//             decoration: pw.BoxDecoration(
//               color: _lightPurple,
//               borderRadius: pw.BorderRadius.circular(6),
//             ),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Row(
//                   children: [
//                     pw.Container(
//                       width: 18,
//                       height: 18,
//                       decoration: const pw.BoxDecoration(
//                           color: _purple, shape: pw.BoxShape.circle),
//                       alignment: pw.Alignment.center,
//                       child: pw.Text('i',
//                           style: pw.TextStyle(
//                               color: PdfColors.white,
//                               fontSize: 10,
//                               fontWeight: pw.FontWeight.bold)),
//                     ),
//                     pw.SizedBox(width: 6),
//                     pw.Text('NOTE',
//                         style: pw.TextStyle(
//                             fontSize: 8, fontWeight: pw.FontWeight.bold)),
//                   ],
//                 ),
//                 pw.SizedBox(height: 4),
//                 pw.Text(
//                   'Please pay before the due date to avoid late fee.\nThis is a system-generated challan.',
//                   style: pw.TextStyle(fontSize: 7, color: _grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         pw.SizedBox(width: 12),
//         pw.Expanded(
//           flex: 1,
//           child: pw.Container(
//             padding: const pw.EdgeInsets.all(10),
//             decoration: pw.BoxDecoration(
//               color: _lightPurple,
//               borderRadius: pw.BorderRadius.circular(6),
//             ),
//             child: pw.Column(
//               children: [
//                 if (hasPreviousBalance) ...[
//                   _totalRow(
//                     c.previousBalance < 0
//                         ? 'Previous Balance (Advance)'
//                         : 'Previous Balance',
//                     c.previousBalance,
//                     color: c.previousBalance < 0 ? _green : _red,
//                   ),
//                   pw.SizedBox(height: 3),
//                   _totalRow('This Month Charges', c.currentMonthTotal),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.symmetric(vertical: 4),
//                     child: pw.Container(height: 0.75, color: _borderGrey),
//                   ),
//                 ],
//                 _totalRow(
//                   'Net Payable',
//                   c.netPayableSnapshot,
//                   bold: true,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // static pw.Widget _bottomBlocks(FeeChallanModel c) {
//   //   return pw.Row(
//   //     crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //     children: [
//   //       pw.Expanded(
//   //         flex: 1,
//   //         child: pw.Container(
//   //           padding: const pw.EdgeInsets.all(10),
//   //           decoration: pw.BoxDecoration(
//   //             color: _lightPurple,
//   //             borderRadius: pw.BorderRadius.circular(6),
//   //           ),
//   //           child: pw.Column(
//   //             crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //             children: [
//   //               pw.Row(
//   //                 children: [
//   //                   pw.Container(
//   //                     width: 18,
//   //                     height: 18,
//   //                     decoration: const pw.BoxDecoration(
//   //                         color: _purple, shape: pw.BoxShape.circle),
//   //                     alignment: pw.Alignment.center,
//   //                     child: pw.Text('i',
//   //                         style: pw.TextStyle(
//   //                             color: PdfColors.white,
//   //                             fontSize: 10,
//   //                             fontWeight: pw.FontWeight.bold)),
//   //                   ),
//   //                   pw.SizedBox(width: 6),
//   //                   pw.Text('NOTE',
//   //                       style: pw.TextStyle(
//   //                           fontSize: 8, fontWeight: pw.FontWeight.bold)),
//   //                 ],
//   //               ),
//   //               pw.SizedBox(height: 4),
//   //               pw.Text(
//   //                 'Please pay before the due date to avoid late fee.\nThis is a system-generated challan.',
//   //                 style: pw.TextStyle(fontSize: 7, color: _grey),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //       pw.SizedBox(width: 12),
//   //       pw.Expanded(
//   //         flex: 1,
//   //         child: pw.Container(
//   //           padding: const pw.EdgeInsets.all(10),
//   //           decoration: pw.BoxDecoration(
//   //             color: _lightPurple,
//   //             borderRadius: pw.BorderRadius.circular(6),
//   //           ),
//   //           child: pw.Column(
//   //             children: [
//   //               _totalRow('Total Payable', c.currentMonthTotal, bold: true),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   static pw.Widget _totalRow(String label, double value,
//       {bool bold = false, PdfColor? color}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label,
//               style: pw.TextStyle(
//                   fontSize: 8,
//                   fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//                   color: color ?? (bold ? PdfColors.black : _grey))),
//           pw.Text('Rs ${value.toStringAsFixed(0)}',
//               style: pw.TextStyle(
//                   fontSize: bold ? 10 : 8.5,
//                   fontWeight: pw.FontWeight.bold,
//                   color: color ?? (bold ? _purple : PdfColors.black))),
//         ],
//       ),
//     );
//   }
//
//   static String _fmt(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
// }


import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/fee_challan_model.dart';
import '../models/school_setting_model.dart';

class FeeChallanPdfService {
  static const PdfColor _purple = PdfColor.fromInt(0xFF534AB7);
  static const PdfColor _darkPurple = PdfColor.fromInt(0xFF3B3586);
  static const PdfColor _lightPurple = PdfColor.fromInt(0xFFEEECFA);
  static const PdfColor _grey = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _borderGrey = PdfColor.fromInt(0xFFE5E7EB);
  static const PdfColor _lightRedBg = PdfColor.fromInt(0xFFFEF2F2);
  static const PdfColor _red = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor _green = PdfColor.fromInt(0xFF16A34A);

  static const String schoolName = 'Your School Name';
  static const String schoolPhone = '123-4567890';
  static const String schoolAddress = '123 Main Street, City, State';
  static const String schoolCity = 'City';

  // ─── Public API ──────────────────────────────────────────────────────────────

  static Future<Uint8List> buildSinglePdf(
      FeeChallanModel challan,
      SchoolSettings settings,
      ) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _challanBlock(challan, settings, compact: false),
          ],
        ),
      ),
    );
    return doc.save();
  }

  static Future<Uint8List> buildMergedPdf(
      List<FeeChallanModel> challans,
      SchoolSettings settings,
      ) async {
    final doc = pw.Document();

    for (var i = 0; i < challans.length; i += 2) {
      final first = challans[i];
      final second = (i + 1 < challans.length) ? challans[i + 1] : null;

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          build: (context) => pw.Column(
            children: [
              _challanBlock(first, settings, compact: true),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 0,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: _borderGrey, width: 1, style: pw.BorderStyle.dashed),
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              if (second != null)
                _challanBlock(second, settings, compact: true)
              else
                pw.Expanded(child: pw.Container()),
            ],
          ),
        ),
      );
    }

    return doc.save();
  }

  static Future<void> downloadAndOpen(
      FeeChallanModel challan,
      SchoolSettings settings,
      ) async {
    final bytes = await buildSinglePdf(challan, settings);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Challan_${challan.challanNumber}.pdf',
    );
  }

  static Future<void> printChallan(
      FeeChallanModel challan,
      SchoolSettings settings,
      ) async {
    final bytes = await buildSinglePdf(challan, settings);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Challan_${challan.challanNumber}.pdf',
    );
  }

  static Future<void> bulkDownload(
      List<FeeChallanModel> challans,
      SchoolSettings settings,
      ) async {
    final bytes = await buildMergedPdf(challans, settings);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Fee_Challans_Bulk.pdf',
    );
  }

  static Future<void> bulkPrint(
      List<FeeChallanModel> challans,
      SchoolSettings settings,
      ) async {
    final bytes = await buildMergedPdf(challans, settings);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Fee_Challans_Bulk.pdf',
    );
  }

  // ─── Layout Builders ──────────────────────────────────────────────────────

  static pw.Widget _challanBlock(
      FeeChallanModel c,
      SchoolSettings settings, {
        required bool compact,
      }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderGrey, width: 1),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _schoolHeader(),
          pw.SizedBox(height: 8),
          pw.Container(height: 1, color: _borderGrey),
          pw.SizedBox(height: 8),
          _challanMetaRow(c),
          pw.SizedBox(height: 12),
          _studentTable(c),
          pw.SizedBox(height: 12),
          _bottomBlocks(c),
          if (!compact) ...[
            pw.SizedBox(height: 12),
            pw.Container(
              width: double.infinity,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: _borderGrey, width: 1, style: pw.BorderStyle.dotted),
                ),
              ),
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('♥', style: pw.TextStyle(fontSize: 12, color: _purple)),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    'Thank you for your timely payment!',
                    style: pw.TextStyle(fontSize: 8, color: _grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────────

  static pw.Widget _schoolHeader() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 34,
                    height: 34,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: _lightPurple,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Text('S', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _darkPurple)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    schoolName,
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: _darkPurple),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('📍 $schoolAddress',
                  style: pw.TextStyle(fontSize: 8, color: _grey)),
              pw.Text('📞 Ph: $schoolPhone  |  $schoolCity',
                  style: pw.TextStyle(fontSize: 8, color: _grey)),
            ],
          ),
        ),
        pw.Container(
          width: 140,
          height: 60,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10),
          decoration: const pw.BoxDecoration(
            color: _darkPurple,
            borderRadius: pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(15),
              topLeft: pw.Radius.circular(15),
            ),
          ),
          alignment: pw.Alignment.center,
          child: pw.Text(
            'FEE CHALLAN',
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          ),
        ),
      ],
    );
  }

  // ─── META INFO ROW ──────────────────────────────────────────────────────────

  static pw.Widget _challanMetaRow(FeeChallanModel c) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _lightPurple,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderGrey, width: 0.5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _metaRowCircleIcon('F', 'Family', c.familyName.isNotEmpty ? '${c.familyName} (${c.familyId})' : ''),
                _metaRowCircleIcon('P', 'Father', c.fatherName),
                if (c.fatherPhone.isNotEmpty)
                  _metaRowCircleIcon('T', 'Phone', c.fatherPhone),
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _metaRowCircleIcon('D', 'Challan #', c.challanNumber),
                _metaRowCircleIcon('C', 'Month', '${c.monthLabel} ${c.year}'),
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _metaRowCircleIcon('G', 'Generated', _fmt(c.generatedDate)),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: _lightRedBg,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                          width: 14, height: 14,
                          decoration: const pw.BoxDecoration(color: _red, shape: pw.BoxShape.circle),
                          alignment: pw.Alignment.center,
                          child: pw.Text('!', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))
                      ),
                      pw.SizedBox(width: 4),
                      pw.Text('Due: ${_fmt(c.dueDate)}',
                          style: pw.TextStyle(
                              fontSize: 8, color: _red, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _metaRowCircleIcon(String iconLetter, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Container(
            width: 14,
            height: 14,
            decoration: const pw.BoxDecoration(
                color: _purple,
                shape: pw.BoxShape.circle
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              iconLetter,
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold
              ),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Text('$label: ', style: pw.TextStyle(fontSize: 8, color: _grey)),
          pw.Text(value.isNotEmpty ? value : '—',
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // ─── STUDENT TABLE ──────────────────────────────────────────────────────────

  static pw.Widget _studentTable(FeeChallanModel c) {
    // Determine which columns to show based on actual data
    final showAdmission = c.students.any((s) => s.registrationFee > 0);
    final showAnnual = c.students.any((s) => s.annualFee > 0);
    final showAcademy = c.students.any((s) => s.academyFee > 0);

    List<double> flexValues = [];
    flexValues.add(0.5); // #
    flexValues.add(2.0); // Student
    flexValues.add(1.5); // Class
    if (showAdmission) flexValues.add(1.2);
    if (showAnnual) flexValues.add(1.2);
    if (showAcademy) flexValues.add(1.2); // Academy Fee
    flexValues.add(1.2); // Monthly Fee
    flexValues.add(1.2); // Total

    List<pw.Widget> headerChildren = [
      _tableHeaderCell('#', flex: 0.5, align: pw.TextAlign.center),
      _tableHeaderCell('Student', flex: 2.0),
      _tableHeaderCell('Class', flex: 1.5),
      if (showAdmission) _tableHeaderCell('Admission Fee', flex: 1.2, align: pw.TextAlign.center),
      if (showAnnual) _tableHeaderCell('Annual Fund', flex: 1.2, align: pw.TextAlign.center),

      _tableHeaderCell('School Monthly Fee', flex: 1.2, align: pw.TextAlign.center),
      if (showAcademy) _tableHeaderCell('Academy Fee', flex: 1.2, align: pw.TextAlign.center),
      _tableHeaderCell('Total', flex: 1.2, align: pw.TextAlign.center),
    ];

    List<pw.TableRow> rows = [];
    for (int i = 0; i < c.students.length; i++) {
      final student = c.students[i];
      List<pw.Widget> cells = [];

      // # Column with light purple box
      cells.add(pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        alignment: pw.Alignment.center,
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: _lightPurple,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text('${i + 1}',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ),
      ));

      cells.add(_tableCell(student.name, bold: true));
      cells.add(_tableCell([student.className, student.sectionName]
          .whereType<String>()
          .join(' - ')));

      if (showAdmission) {
        cells.add(_tableCell(
            student.registrationFee > 0
                ? student.registrationFee.toStringAsFixed(0)
                : '0',
            align: pw.TextAlign.center));
      }
      if (showAnnual) {
        cells.add(_tableCell(
            student.annualFee > 0 ? student.annualFee.toStringAsFixed(0) : '0',
            align: pw.TextAlign.center));
      }
      if (showAcademy) {
        cells.add(_tableCell(
            student.academyFee > 0 ? student.academyFee.toStringAsFixed(0) : '0',
            align: pw.TextAlign.center));
      }
      cells.add(_tableCell(student.monthlyFee.toStringAsFixed(0), align: pw.TextAlign.center));
      cells.add(_tableCell(student.lineTotal.toStringAsFixed(0), align: pw.TextAlign.center, bold: true));

      rows.add(pw.TableRow(children: cells));
    }

    Map<int, pw.FlexColumnWidth> columnWidths = {};
    for (int i = 0; i < flexValues.length; i++) {
      columnWidths[i] = pw.FlexColumnWidth(flexValues[i]);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
      columnWidths: columnWidths,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _darkPurple),
          children: headerChildren,
        ),
        ...rows,
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text,
      {double flex = 1.0, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
            fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _tableCell(String text,
      {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
            fontSize: 8,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  // ─── BOTTOM BLOCKS ─────────────────────────────────────────────────────────

  static pw.Widget _bottomBlocks(FeeChallanModel c) {
    final hasPreviousBalance = c.previousBalance != 0;
    final hasExtraCharges = c.extraCharges.isNotEmpty;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _lightPurple,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 18,
                      height: 18,
                      decoration: const pw.BoxDecoration(
                          color: _purple, shape: pw.BoxShape.circle),
                      alignment: pw.Alignment.center,
                      child: pw.Text('i',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text('NOTE',
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Please pay before the due date to avoid late fee.\nThis is a system-generated challan.',
                  style: pw.TextStyle(fontSize: 7, color: _grey),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _lightPurple,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Show extra charges breakdown if any
                if (hasExtraCharges) ...[
                  ...c.extraCharges.map((ex) => _totalRow(
                    '${ex.label} ${ex.source == 'overall' ? '(All)' : '(Family)'}',
                    ex.amount,
                    color: _grey,
                  )),
                  pw.SizedBox(height: 3),
                  pw.Container(height: 0.75, color: _borderGrey),
                  pw.SizedBox(height: 3),
                ],
                if (hasPreviousBalance) ...[
                  _totalRow(
                    c.previousBalance < 0
                        ? 'Previous Balance (Advance)'
                        : 'Previous Balance',
                    c.previousBalance,
                    color: c.previousBalance < 0 ? _green : _red,
                  ),
                  pw.SizedBox(height: 3),
                  _totalRow('This Month Charges', c.currentMonthTotal),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Container(height: 0.75, color: _borderGrey),
                  ),
                ],
                _totalRow(
                  'Net Payable',
                  c.netPayableSnapshot,
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _totalRow(String label, double value,
      {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: color ?? (bold ? PdfColors.black : _grey))),
          pw.Text('Rs ${value.toStringAsFixed(0)}',
              style: pw.TextStyle(
                  fontSize: bold ? 10 : 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: color ?? (bold ? _purple : PdfColors.black))),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}