//
// import 'dart:typed_data';
//
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// import '../../models/salary_model.dart';
//
// // ────────────────────────────────────────────────────────────
// //  Design Tokens — Matches the exact colors from the image
// // ────────────────────────────────────────────────────────────
// final PdfColor _kNavy = PdfColor.fromInt(0xFF1F3A5F);
// final PdfColor _kRowGrey = PdfColor.fromInt(0xFFF3F4F6);
// final PdfColor _kInk = PdfColor.fromInt(0xFF111827);
// final PdfColor _kSlate = PdfColor.fromInt(0xFF6B7280);
// final PdfColor _kBorder = PdfColor.fromInt(0xFFD1D5DB);
// final PdfColor _kRed = PdfColor.fromInt(0xFFDC2626);
// final PdfColor _kGreen = PdfColor.fromInt(0xFF16A34A);
//
// class SalaryPdfService {
//   SalaryPdfService._();
//
//   /// Builds the salary slip PDF document bytes.
//   static Future<Uint8List> _buildPdf(SalaryRecord rec) async {
//     final doc = pw.Document();
//
//     // Constants for calculation
//     const int totalDays = 30;
//     final int presentDays = totalDays - rec.leaves;
//
//     // Formatter
//     final currency = NumberFormat('#,##0');
//     String Function(num) fmt = (num v) => '${currency.format(v.abs())}';
//
//     // Mapping your existing model fields
//     final String department = rec.employeeType == 'teacher'
//         ? 'Teaching Staff'
//         : (rec.employeeType == 'staff' ? 'Admin Staff' : 'N/A');
//
//     // Date helper
//     final startDate = DateTime(rec.year, rec.month, 1);
//     final endDate = DateTime(rec.year, rec.month + 1, 0);
//
//     // Calculations for table
//     final int absentDays = rec.leaves;
//     final double totalEarnings = rec.baseSalary + rec.bonus;
//     final double totalDeductions = rec.absentDeduction + rec.fine + (rec.recordInLedger ? rec.ledgerDeductionAmount : 0);
//     final double netPayable = rec.payableNetSalary;
//
//     doc.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(25),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // 1. Title
//               pw.Align(
//                 alignment: pw.Alignment.center,
//                 child: pw.Text(
//                   'PAYROLL SLIP',
//                   style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: _kInk, letterSpacing: 1),
//                 ),
//               ),
//               pw.SizedBox(height: 18),
//
//               // 2. Employee Info Block
//               _buildEmployeeInfo(
//                   rec,
//                   department,
//                   startDate,
//                   endDate
//               ),
//               pw.SizedBox(height: 18),
//
//               // 3. Salary Breakdown Title & Table
//               _buildSalaryBreakdownTitle(),
//               pw.SizedBox(height: 8),
//               _buildSalaryBreakdownTable(
//                   rec,
//                   presentDays,
//                   absentDays,
//                   totalEarnings,
//                   totalDeductions,
//                   fmt
//               ),
//               pw.SizedBox(height: 12),
//
//               // 4. Net Payable Box
//               _buildNetPayableBox(netPayable, fmt),
//               pw.SizedBox(height: 20),
//
//               // 5. Received By / Authorized By Boxes
//               _buildSignatureBoxes(),
//               pw.SizedBox(height: 16),
//
//               // 6. Notes
//               if (rec.note != null && rec.note!.trim().isNotEmpty) ...[
//                 _buildNotes(rec.note!),
//                 pw.SizedBox(height: 16),
//               ],
//
//               // 7. Footer
//               pw.Spacer(),
//               _buildFooter(),
//             ],
//           );
//         },
//       ),
//     );
//
//     return doc.save();
//   }
//
//   // ─── Employee Information Block ───
//   static pw.Widget _buildEmployeeInfo(
//       SalaryRecord rec, String department, DateTime start, DateTime end) {
//
//     // Left Column Helper Row
//     pw.Widget infoRow(String label, String value) {
//       return pw.Padding(
//         padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
//         child: pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.SizedBox(
//               width: 95,
//               child: pw.Text(label, style: pw.TextStyle(fontSize: 9.5, color: _kSlate)),
//             ),
//             pw.Text(':', style: pw.TextStyle(fontSize: 9.5, color: _kSlate)),
//             pw.SizedBox(width: 8),
//             pw.Expanded(
//               child: pw.Text(value, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk)),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // Right Column Block – no icon, only title text
//     pw.Widget infoBlock(String title, pw.Widget child) {
//       return pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(title, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk)),
//           pw.SizedBox(height: 4),
//           child,
//         ],
//       );
//     }
//
//     return pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         // LEFT COLUMN
//         pw.Expanded(
//           flex: 6,
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('EMPLOYEE INFORMATION', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _kInk)),
//               pw.SizedBox(height: 6),
//               infoRow('Employee Name', rec.employeeName),
//               infoRow('Employee ID', rec.employeeId ?? 'N/A'),
//               infoRow('Designation', rec.designation ?? 'N/A'),
//               infoRow('Department', department),
//               infoRow('Salary Month', DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month))),
//               infoRow('Generated Date', DateFormat('dd MMM yyyy').format(rec.generatedDate)),
//               pw.Padding(
//                 padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
//                 // child: pw.Row(
//                 //   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 //   children: [
//                 //     pw.SizedBox(width: 95, child: pw.Text('Status', style: pw.TextStyle(fontSize: 9.5, color: _kSlate))),
//                 //     pw.Text(':', style: pw.TextStyle(fontSize: 9.5, color: _kSlate)),
//                 //     pw.SizedBox(width: 8),
//                 //     pw.Text(' ${rec.status}', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kGreen)),
//                 //   ],
//                 // ),
//               ),
//             ],
//           ),
//         ),
//         pw.SizedBox(width: 10),
//
//         // RIGHT COLUMN
//         pw.Expanded(
//           flex: 5,
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               infoBlock('MONTH & YEAR',
//                   pw.Text(DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month)), style: pw.TextStyle(fontSize: 9.5, color: _kInk))
//               ),
//               pw.SizedBox(height: 12),
//               infoBlock('PAYROLL PERIOD',
//                   pw.Text('01 ${DateFormat('MMM yyyy').format(start)} - 31 ${DateFormat('MMM yyyy').format(end)}', style: pw.TextStyle(fontSize: 9.5, color: _kInk))
//               ),
//               pw.SizedBox(height: 12),
//               infoBlock('PAY STATUS',
//                   pw.Text(' ${rec.status}', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kGreen))
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Salary Breakdown Title ───
//   static pw.Widget _buildSalaryBreakdownTitle() {
//     return pw.Row(
//       children: [
//         pw.Expanded(child: pw.Container(height: 1, color: _kBorder)),
//         pw.Padding(
//           padding: const pw.EdgeInsets.symmetric(horizontal: 8),
//           child: pw.Text('SALARY DETAILS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _kInk)),
//         ),
//         pw.Expanded(child: pw.Container(height: 1, color: _kBorder)),
//       ],
//     );
//   }
//
//   // ─── Salary Breakdown Table ───
//   static pw.Widget _buildSalaryBreakdownTable(
//       SalaryRecord rec, int present, int absent, double earnings, double deductions, String Function(num) fmt) {
//
//     pw.Widget row(String desc, String amount, {bool isTotal = false, bool isDeduction = false, bool isAdd = false}) {
//       return pw.Container(
//         padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         decoration: pw.BoxDecoration(
//           color: isTotal ? _kRowGrey : null,
//           border: const pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEDEFF2), width: 0.5)),
//         ),
//         child: pw.Row(
//           children: [
//             pw.Expanded(
//               flex: 3,
//               child: pw.Text(desc, style: pw.TextStyle(fontSize: 9.5, fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal, color: _kInk)),
//             ),
//             pw.Expanded(
//               flex: 1,
//               child: pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Text(amount, style: pw.TextStyle(
//                     fontSize: 9.5,
//                     fontWeight: pw.FontWeight.bold,
//                     color: isDeduction ? _kRed : (isAdd ? _kGreen : (isTotal ? _kInk : _kInk))
//                 )),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return pw.Column(
//       children: [
//         // Header
//         pw.Container(
//           padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           color: _kRowGrey,
//           child: pw.Row(
//             children: [
//               pw.Expanded(flex: 3, child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk))),
//               pw.Expanded(flex: 1, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('AMOUNT (Rs)', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk)))),
//             ],
//           ),
//         ),
//
//         // Rows
//         row('Base Salary', '${fmt(rec.baseSalary)}'),
//         row('Present Days ($present Days)', '-'),
//         row('Absent Days ($absent Days)', '-'),
//         if (absent > 0)
//           row('Absent Deduction ', '-${fmt(rec.absentDeduction)}', isDeduction: true),
//         // row('Absent Deduction ($absent Days × Rs ${fmt(rec.perDayRate)})', '-${fmt(rec.absentDeduction)}', isDeduction: true),
//
//         if (rec.fine > 0)
//           row('Fine / Deduction', '-${fmt(rec.fine)}', isDeduction: true),
//         if (rec.bonus > 0)
//           row('Bonus / Addition (Performance Bonus)', '+${fmt(rec.bonus)}', isAdd: true),
//         if (rec.recordInLedger && rec.ledgerDeductionAmount != 0)
//           row('Balance Deduction', '-${fmt(rec.ledgerDeductionAmount)}', isDeduction: true),
//
//         // Totals
//         row('TOTAL Salary', fmt(earnings), isTotal: true),
//         row('TOTAL DEDUCTIONS', fmt(deductions.abs()), isTotal: true, isDeduction: true),
//       ],
//     );
//   }
//
//   // ─── Net Payable Box ───
//   static pw.Widget _buildNetPayableBox(double netPayable, String Function(num) fmt) {
//     return pw.Container(
//       width: double.infinity,
//       padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: _kNavy, width: 1.5),
//         borderRadius: pw.BorderRadius.circular(4),
//       ),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('NET PAYABLE SALARY', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _kInk)),
//               pw.Text('(Payable Amount)', style: pw.TextStyle(fontSize: 9, color: _kSlate)),
//             ],
//           ),
//           pw.Text(
//             'Rs ${fmt(netPayable)}',
//             style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _kNavy),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   // ─── Notes ───
//   static pw.Widget _buildNotes(String note) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text('NOTES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _kInk)),
//         pw.SizedBox(height: 4),
//         pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('•', style: pw.TextStyle(fontSize: 10, color: _kSlate)),
//             pw.SizedBox(width: 6),
//             pw.Expanded(
//               child: pw.Text(note, style: pw.TextStyle(fontSize: 9.5, color: _kSlate, height: 1.4)),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // ─── Signature Boxes ───
//   static pw.Widget _buildSignatureBoxes() {
//     pw.Widget box(String title) {
//       return pw.Expanded(
//         child: pw.Container(
//           height: 60,
//           padding: const pw.EdgeInsets.only(top: 8),
//           decoration: pw.BoxDecoration(
//             border: pw.Border.all(color: _kBorder, width: 1),
//             borderRadius: pw.BorderRadius.circular(3),
//           ),
//           child: pw.Align(
//             alignment: pw.Alignment.topCenter,
//             child: pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _kInk)),
//           ),
//         ),
//       );
//     }
//
//     return pw.Row(
//       children: [
//         box('RECEIVED BY'),
//         pw.SizedBox(width: 16),
//         box('AUTHORIZED BY'),
//       ],
//     );
//   }
//
//
//
//   // ─── Footer ───
//   static pw.Widget _buildFooter() {
//     return pw.Align(
//       alignment: pw.Alignment.center,
//       child: pw.Text(
//         'Developed by Ali Haider | 0300-7465064',
//         style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF9CA3AF), fontWeight: pw.FontWeight.bold),
//       ),
//     );
//   }
//
//   // ────────────────────────────────────────────────────────────
//   //  Public actions
//   // ────────────────────────────────────────────────────────────
//   static String _fileName(SalaryRecord rec) {
//     final safeName = rec.employeeName.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
//     return 'Salary_${safeName}_${rec.year}_${rec.month.toString().padLeft(2, '0')}.pdf';
//   }
//
//   static Future<void> downloadAndOpen(SalaryRecord rec) async {
//     final bytes = await _buildPdf(rec);
//     final fileName = _fileName(rec);
//     await Printing.sharePdf(bytes: bytes, filename: fileName);
//   }
//
//   static Future<void> printSlip(SalaryRecord rec) async {
//     final bytes = await _buildPdf(rec);
//     await Printing.layoutPdf(
//       onLayout: (format) async => bytes,
//       name: _fileName(rec),
//     );
//   }
// }


import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/salary_model.dart';

final PdfColor _kNavy = PdfColor.fromInt(0xFF1F3A5F);
final PdfColor _kRowGrey = PdfColor.fromInt(0xFFF3F4F6);
final PdfColor _kInk = PdfColor.fromInt(0xFF111827);
final PdfColor _kSlate = PdfColor.fromInt(0xFF6B7280);
final PdfColor _kBorder = PdfColor.fromInt(0xFFD1D5DB);
final PdfColor _kRed = PdfColor.fromInt(0xFFDC2626);
final PdfColor _kGreen = PdfColor.fromInt(0xFF16A34A);

class SalaryPdfService {
  SalaryPdfService._();

  static Future<Uint8List> _buildPdf(SalaryRecord rec) async {
    final doc = pw.Document();

    const int totalDays = 30;
    final int presentDays = totalDays - rec.leaves;

    final currency = NumberFormat('#,##0');
    String Function(num) fmt = (num v) => '${currency.format(v.abs())}';

    final String department = rec.employeeType == 'teacher'
        ? 'Teaching Staff'
        : (rec.employeeType == 'staff' ? 'Admin Staff' : 'N/A');

    final startDate = DateTime(rec.year, rec.month, 1);
    final endDate = DateTime(rec.year, rec.month + 1, 0);

    final int absentDays = rec.leaves;
    final double totalEarnings = rec.baseSalary + rec.bonus;
    final double totalDeductions = rec.absentDeduction + rec.fine + (rec.recordInLedger ? rec.ledgerDeductionAmount : 0);
    final double netPayable = rec.payableNetSalary;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'PAYROLL SLIP',
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: _kInk, letterSpacing: 1),
                ),
              ),
              pw.SizedBox(height: 18),
              _buildEmployeeInfo(rec, department, startDate, endDate),
              pw.SizedBox(height: 18),
              _buildSalaryBreakdownTitle(),
              pw.SizedBox(height: 8),
              _buildSalaryBreakdownTable(rec, presentDays, absentDays, totalEarnings, totalDeductions, fmt),
              pw.SizedBox(height: 12),
              _buildNetPayableBox(netPayable, fmt),
              pw.SizedBox(height: 20),

              // Notes moved ABOVE signatures
              if (rec.note != null && rec.note!.trim().isNotEmpty) ...[
                _buildNotes(rec.note!),
                pw.SizedBox(height: 16),
              ],

              _buildSignatureBoxes(),
              pw.SizedBox(height: 16),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildEmployeeInfo(
      SalaryRecord rec, String department, DateTime start, DateTime end) {

    pw.Widget infoRow(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 95,
              child: pw.Text(label, style: pw.TextStyle(fontSize: 9.5, color: _kSlate)),
            ),
            pw.Text(':', style: pw.TextStyle(fontSize: 9.5, color: _kSlate)),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Text(value, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk)),
            ),
          ],
        ),
      );
    }

    pw.Widget infoBlock(String title, pw.Widget child) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk)),
          pw.SizedBox(height: 4),
          child,
        ],
      );
    }

    // Termination badge – show only if terminated
    pw.Widget? terminationBadge;
    if (rec.isTerminated) {
      terminationBadge = pw.Padding(
        padding: const pw.EdgeInsets.only(top: 6),
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFFEF2F2), // light red background
            border: pw.Border.all(color: _kRed, width: 1),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            'TERMINATED',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _kRed,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    final bool isTerminated = rec.isTerminated;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 6,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('EMPLOYEE INFORMATION',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _kInk)),
              pw.SizedBox(height: 6),
              infoRow('Employee Name', rec.employeeName),
              infoRow('Employee ID', rec.employeeId ?? 'N/A'),
              infoRow('Designation', rec.designation ?? 'N/A'),
              infoRow('Department', department),
              infoRow('Salary Month',
                  DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month))),
              infoRow('Generated Date',
                  DateFormat('dd MMM yyyy').format(rec.generatedDate)),
              // Show termination badge only when applicable
              if (terminationBadge != null) terminationBadge,
            ],
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              infoBlock(
                  'MONTH & YEAR',
                  pw.Text(
                      DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month)),
                      style: pw.TextStyle(fontSize: 9.5, color: _kInk))),
              pw.SizedBox(height: 12),
              infoBlock(
                  'PAYROLL PERIOD',
                  pw.Text(
                      '01 ${DateFormat('MMM yyyy').format(start)} - 31 ${DateFormat('MMM yyyy').format(end)}',
                      style: pw.TextStyle(fontSize: 9.5, color: _kInk))),
              pw.SizedBox(height: 12),
              infoBlock(
                  'PAY STATUS',
                  pw.Text(' ${rec.status}',
                      style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: isTerminated ? _kRed : _kGreen))),
            ],
          ),
        ),
      ],
    );
  }
  //old code
  // static pw.Widget _buildEmployeeInfo(
  //     SalaryRecord rec, String department, DateTime start, DateTime end)
  // {
  //
  //   pw.Widget infoRow(String label, String value) {
  //     return pw.Padding(
  //       padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
  //       child: pw.Row(
  //         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //         children: [
  //           pw.SizedBox(
  //             width: 95,
  //             child: pw.Text(label, style: pw.TextStyle(fontSize: 9.5, color: _kSlate)),
  //           ),
  //           pw.Text(':', style: pw.TextStyle(fontSize: 9.5, color: _kSlate)),
  //           pw.SizedBox(width: 8),
  //           pw.Expanded(
  //             child: pw.Text(value, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk)),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   pw.Widget infoBlock(String title, pw.Widget child) {
  //     return pw.Column(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         pw.Text(title, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk)),
  //         pw.SizedBox(height: 4),
  //         child,
  //       ],
  //     );
  //   }
  //   // Termination badge
  //   pw.Widget? terminationBadge;
  //   if (rec.isTerminated) {
  //     terminationBadge = pw.Padding(
  //       padding: const pw.EdgeInsets.only(top: 6),
  //       child: pw.Container(
  //         padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //         decoration: pw.BoxDecoration(
  //           color: PdfColor.fromInt(0xFFFEF2F2), // light red background
  //           border: pw.Border.all(color: _kRed, width: 1),
  //           borderRadius: pw.BorderRadius.circular(6),
  //         ),
  //         child: pw.Text(
  //           'TERMINATED',
  //           style: pw.TextStyle(
  //             fontSize: 9,
  //             fontWeight: pw.FontWeight.bold,
  //             color: _kRed,
  //             letterSpacing: 0.5,
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //
  //   // Determine if terminated (assuming rec.status is 'terminated' or similar)
  //
  //   // ✅ isTerminated ab boolean se directly le rahe hain
  //   final bool isTerminated = rec.isTerminated;
  //
  //   return pw.Row(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       pw.Expanded(
  //         flex: 6,
  //         child: pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text('EMPLOYEE INFORMATION', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _kInk)),
  //             pw.SizedBox(height: 6),
  //             infoRow('Employee Name', rec.employeeName),
  //             infoRow('Employee ID', rec.employeeId ?? 'N/A'),
  //             infoRow('Designation', rec.designation ?? 'N/A'),
  //             infoRow('Department', department),
  //             infoRow('Salary Month', DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month))),
  //             infoRow('Generated Date', DateFormat('dd MMM yyyy').format(rec.generatedDate)),
  //
  //             // Status row (uncommented & styled based on termination)
  //             // pw.Padding(
  //             //   padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
  //             //   child: pw.Row(
  //             //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             //     children: [
  //             //       pw.SizedBox(width: 95, child: pw.Text('Status', style: pw.TextStyle(fontSize: 9.5, color: _kSlate))),
  //             //       pw.Text(':', style: pw.TextStyle(fontSize: 9.5, color: _kSlate)),
  //             //       pw.SizedBox(width: 8),
  //             //       pw.Text(
  //             //         ' ${rec.status}',
  //             //         style: pw.TextStyle(
  //             //           fontSize: 9.5,
  //             //           fontWeight: pw.FontWeight.bold,
  //             //           color: isTerminated ? _kRed : _kGreen,
  //             //         ),
  //             //       ),
  //             //     ],
  //             //   ),
  //             //
  //             // ),
  //             // infoRow('Terminated', isTerminated ? 'Yes' : 'No'),
  //           ],
  //         ),
  //       ),
  //       pw.SizedBox(width: 10),
  //       pw.Expanded(
  //         flex: 5,
  //         child: pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             infoBlock('MONTH & YEAR',
  //                 pw.Text(DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month)), style: pw.TextStyle(fontSize: 9.5, color: _kInk))),
  //             pw.SizedBox(height: 12),
  //             infoBlock('PAYROLL PERIOD',
  //                 pw.Text('01 ${DateFormat('MMM yyyy').format(start)} - 31 ${DateFormat('MMM yyyy').format(end)}', style: pw.TextStyle(fontSize: 9.5, color: _kInk))),
  //             pw.SizedBox(height: 12),
  //             infoBlock('PAY STATUS',
  //                 pw.Text(' ${rec.status}', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: isTerminated ? _kRed : _kGreen))),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  //
  // }

  static pw.Widget _buildSalaryBreakdownTitle() {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Container(height: 1, color: _kBorder)),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Text('SALARY DETAILS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _kInk)),
        ),
        pw.Expanded(child: pw.Container(height: 1, color: _kBorder)),
      ],
    );
  }

  static pw.Widget _buildSalaryBreakdownTable(
      SalaryRecord rec, int present, int absent, double earnings, double deductions, String Function(num) fmt) {

    pw.Widget row(String desc, String amount, {bool isTotal = false, bool isDeduction = false, bool isAdd = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: pw.BoxDecoration(
          color: isTotal ? _kRowGrey : null,
          border: const pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEDEFF2), width: 0.5)),
        ),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Text(desc, style: pw.TextStyle(fontSize: 9.5, fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal, color: _kInk)),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(amount, style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: isDeduction ? _kRed : (isAdd ? _kGreen : (isTotal ? _kInk : _kInk))
                )),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: _kRowGrey,
          child: pw.Row(
            children: [
              pw.Expanded(flex: 3, child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk))),
              pw.Expanded(flex: 1, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('AMOUNT (Rs)', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _kInk)))),
            ],
          ),
        ),
        row('Base Salary', '${fmt(rec.baseSalary)}'),
        row('Present Days ($present Days)', '-'),
        row('Absent Days ($absent Days)', '-'),
        if (absent > 0)
          row('Absent Deduction ', '-${fmt(rec.absentDeduction)}', isDeduction: true),
        if (rec.fine > 0)
          row('Fine / Deduction', '-${fmt(rec.fine)}', isDeduction: true),
        if (rec.bonus > 0)
          row('Bonus / Addition (Performance Bonus)', '+${fmt(rec.bonus)}', isAdd: true),
        if (rec.recordInLedger && rec.ledgerDeductionAmount != 0)
          row('Balance Deduction', '-${fmt(rec.ledgerDeductionAmount)}', isDeduction: true),
        row('TOTAL Salary', fmt(earnings), isTotal: true),
        row('TOTAL DEDUCTIONS', fmt(deductions.abs()), isTotal: true, isDeduction: true),
      ],
    );
  }

  static pw.Widget _buildNetPayableBox(double netPayable, String Function(num) fmt) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _kNavy, width: 1.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('NET PAYABLE SALARY', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _kInk)),
              pw.Text('(Payable Amount)', style: pw.TextStyle(fontSize: 9, color: _kSlate)),
            ],
          ),
          pw.Text(
            'Rs ${fmt(netPayable)}',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _kNavy),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureBoxes() {
    pw.Widget box(String title) {
      return pw.Expanded(
        child: pw.Container(
          height: 60,
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _kBorder, width: 1),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Align(
            alignment: pw.Alignment.topCenter,
            child: pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _kInk)),
          ),
        ),
      );
    }

    return pw.Row(
      children: [
        box('RECEIVED BY'),
        pw.SizedBox(width: 16),
        box('AUTHORIZED BY'),
      ],
    );
  }

  static pw.Widget _buildNotes(String note) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('NOTES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _kInk)),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('•', style: pw.TextStyle(fontSize: 10, color: _kSlate)),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: pw.Text(note, style: pw.TextStyle(fontSize: 9.5, color: _kSlate, height: 1.4)),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Align(
      alignment: pw.Alignment.center,
      child: pw.Text(
        'Developed by Ali Haider | 0300-7465064',
        style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF9CA3AF), fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static String _fileName(SalaryRecord rec) {
    final safeName = rec.employeeName.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    return 'Salary_${safeName}_${rec.year}_${rec.month.toString().padLeft(2, '0')}.pdf';
  }

  static Future<void> downloadAndOpen(SalaryRecord rec) async {
    final bytes = await _buildPdf(rec);
    final fileName = _fileName(rec);
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  static Future<void> printSlip(SalaryRecord rec) async {
    final bytes = await _buildPdf(rec);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: _fileName(rec),
    );
  }
}