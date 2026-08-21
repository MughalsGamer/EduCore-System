// import 'dart:typed_data';
//
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// import '../../models/class_attendance_model.dart';
// import '../providers/class_attendance_report_provider.dart';
//
// // ============================================================
// // PDF EXPORT — "All Classes, Today" attendance report.
// //
// // One page per class+section (per the reference doc list already
// // loaded on the dashboard, i.e. ClassAttendanceReportProvider.todayDocs).
// // Each page lists only students who actually have an attendance
// // record for today (doc.records), with their status.
// //
// // Works on both mobile and web because `printing` uses
// // Printing.layoutPdf / Printing.sharePdf under the hood, which are
// // implemented for both platforms.
// // ============================================================
// class ClassAttendancePdfService {
//   static const PdfColor _kPrimary = PdfColor.fromInt(0xFF534AB7);
//   static const PdfColor _kPrimaryDark = PdfColor.fromInt(0xFF433CA0);
//   static const PdfColor _kInk = PdfColor.fromInt(0xFF1F2937);
//   static const PdfColor _kSlate = PdfColor.fromInt(0xFF64748B);
//   static const PdfColor _kBorder = PdfColor.fromInt(0xFFE2E8F0);
//   static const PdfColor _kSurface = PdfColor.fromInt(0xFFF8FAFC);
//
//   static const PdfColor _kGreen = PdfColor.fromInt(0xFF166534);
//   static const PdfColor _kGreenBg = PdfColor.fromInt(0xFFEFFCF3);
//   static const PdfColor _kRed = PdfColor.fromInt(0xFFB91C1C);
//   static const PdfColor _kRedBg = PdfColor.fromInt(0xFFFEF2F2);
//   static const PdfColor _kOrange = PdfColor.fromInt(0xFFB45309);
//   static const PdfColor _kOrangeBg = PdfColor.fromInt(0xFFFFFBEB);
//   static const PdfColor _kBlue = PdfColor.fromInt(0xFF1D4ED8);
//   static const PdfColor _kBlueBg = PdfColor.fromInt(0xFFEFF6FF);
//   static const PdfColor _kPurple = PdfColor.fromInt(0xFF6D28D9);
//   static const PdfColor _kPurpleBg = PdfColor.fromInt(0xFFF5F3FF);
//
//   static Map<String, PdfColor> _statusColors(AttendanceStatus s) {
//     switch (s) {
//       case AttendanceStatus.present:
//         return {'fg': _kGreen, 'bg': _kGreenBg};
//       case AttendanceStatus.absent:
//         return {'fg': _kRed, 'bg': _kRedBg};
//       case AttendanceStatus.late:
//         return {'fg': _kOrange, 'bg': _kOrangeBg};
//       case AttendanceStatus.leave:
//         return {'fg': _kBlue, 'bg': _kBlueBg};
//       case AttendanceStatus.halfDay:
//         return {'fg': _kPurple, 'bg': _kPurpleBg};
//     }
//   }
//
//   /// Builds the combined PDF bytes for every class/section doc passed in.
//   /// [docs] should be `ClassAttendanceReportProvider.todayDocs` — already
//   /// filtered to today's date by the provider.
//   static Future<Uint8List> _buildPdfBytes(List<ClassAttendanceModel> docs) async {
//     final doc = pw.Document();
//
//     final regularFont = await PdfGoogleFonts.nunitoSansRegular();
//     final boldFont = await PdfGoogleFonts.nunitoSansBold();
//     final extraBoldFont = await PdfGoogleFonts.nunitoSansExtraBold();
//
//     final today = DateTime.now();
//     final dateLabel = DateFormat('EEEE, dd MMMM yyyy').format(today);
//
//     // Only classes/sections that actually have at least one marked
//     // student today are worth a page.
//     final usableDocs = docs.where((d) => d.records.isNotEmpty).toList()
//       ..sort((a, b) {
//         final c = a.className.compareTo(b.className);
//         if (c != 0) return c;
//         return a.sectionName.compareTo(b.sectionName);
//       });
//
//     if (usableDocs.isEmpty) {
//       doc.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           build: (context) => pw.Center(
//             child: pw.Text(
//               'No attendance marked for any class today.',
//               style: pw.TextStyle(font: regularFont, fontSize: 13, color: _kSlate),
//             ),
//           ),
//         ),
//       );
//       final bytes = await doc.save();
//       return bytes;
//     }
//
//     for (final classDoc in usableDocs) {
//       final records = classDoc.records.values.toList()
//         ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
//
//       final total = records.length;
//       final present = records.where((r) => r.status == AttendanceStatus.present).length;
//       final absent = records.where((r) => r.status == AttendanceStatus.absent).length;
//       final late = records.where((r) => r.status == AttendanceStatus.late).length;
//       final leave = records.where((r) => r.status == AttendanceStatus.leave).length;
//       final halfDay = records.where((r) => r.status == AttendanceStatus.halfDay).length;
//       final pct = total == 0 ? 0.0 : (present / total) * 100;
//
//       doc.addPage(
//         pw.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
//           header: (context) => _buildPageHeader(
//             regularFont: regularFont,
//             boldFont: boldFont,
//             extraBoldFont: extraBoldFont,
//             dateLabel: dateLabel,
//             className: classDoc.className,
//             sectionName: classDoc.sectionName,
//           ),
//           footer: (context) => _buildFooter(regularFont, context),
//           build: (context) => [
//             pw.SizedBox(height: 14),
//             _buildSummaryRow(
//               regularFont: regularFont,
//               boldFont: boldFont,
//               total: total,
//               present: present,
//               absent: absent,
//               late: late,
//               leave: leave,
//               halfDay: halfDay,
//               pct: pct,
//             ),
//             pw.SizedBox(height: 16),
//             _buildStudentTable(
//               regularFont: regularFont,
//               boldFont: boldFont,
//               records: records,
//             ),
//           ],
//         ),
//       );
//     }
//
//     return doc.save();
//   }
//
//   static pw.Widget _buildPageHeader({
//     required pw.Font regularFont,
//     required pw.Font boldFont,
//     required pw.Font extraBoldFont,
//     required String dateLabel,
//     required String className,
//     required String sectionName,
//   }) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   'Class Attendance Report',
//                   style: pw.TextStyle(font: extraBoldFont, fontSize: 16, color: _kInk),
//                 ),
//                 pw.SizedBox(height: 3),
//                 pw.Text(
//                   dateLabel,
//                   style: pw.TextStyle(font: regularFont, fontSize: 10, color: _kSlate),
//                 ),
//               ],
//             ),
//             pw.Container(
//               padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//               decoration: pw.BoxDecoration(
//                 color: _kPrimary,
//                 borderRadius: pw.BorderRadius.circular(6),
//               ),
//               child: pw.Text(
//                 '$className — $sectionName',
//                 style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.white),
//               ),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 10),
//         pw.Divider(color: _kBorder, thickness: 1),
//       ],
//     );
//   }
//
//   static pw.Widget _buildFooter(pw.Font regularFont, pw.Context context) {
//     return pw.Column(
//       children: [
//         pw.Divider(color: _kBorder, thickness: 0.6),
//         pw.SizedBox(height: 4),
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Text(
//               'Generated ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
//               style: pw.TextStyle(font: regularFont, fontSize: 8, color: _kSlate),
//             ),
//             pw.Text(
//               'Page ${context.pageNumber} of ${context.pagesCount}',
//               style: pw.TextStyle(font: regularFont, fontSize: 8, color: _kSlate),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   static pw.Widget _buildSummaryRow({
//     required pw.Font regularFont,
//     required pw.Font boldFont,
//     required int total,
//     required int present,
//     required int absent,
//     required int late,
//     required int leave,
//     required int halfDay,
//     required double pct,
//   }) {
//     final items = <_PdfStatItem>[
//       _PdfStatItem('Total', '$total', _kSlate, _kSurface),
//       _PdfStatItem('Present', '$present', _kGreen, _kGreenBg),
//       _PdfStatItem('Absent', '$absent', _kRed, _kRedBg),
//       _PdfStatItem('Late', '$late', _kOrange, _kOrangeBg),
//       _PdfStatItem('Leave', '$leave', _kBlue, _kBlueBg),
//       _PdfStatItem('Half Day', '$halfDay', _kPurple, _kPurpleBg),
//       _PdfStatItem('Attendance %', '${pct.toStringAsFixed(1)}%', _kPrimary, PdfColor.fromInt(0xFFF0EFFE)),
//     ];
//
//     return pw.Row(
//       children: items
//           .map(
//             (item) => pw.Expanded(
//           child: pw.Container(
//             margin: const pw.EdgeInsets.only(right: 6),
//             padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
//             decoration: pw.BoxDecoration(
//               color: item.bg,
//               borderRadius: pw.BorderRadius.circular(6),
//             ),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(item.value, style: pw.TextStyle(font: boldFont, fontSize: 13, color: item.color)),
//                 pw.SizedBox(height: 2),
//                 pw.Text(item.label, style: pw.TextStyle(font: regularFont, fontSize: 7.5, color: item.color)),
//               ],
//             ),
//           ),
//         ),
//       )
//           .toList(),
//     );
//   }
//
//   static pw.Widget _buildStudentTable({
//     required pw.Font regularFont,
//     required pw.Font boldFont,
//     required List<AttendanceRecord> records,
//   }) {
//     pw.Widget headerCell(String text) => pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
//       child: pw.Text(text, style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: PdfColors.white)),
//     );
//
//     pw.Widget bodyCell(String text, {PdfColor? color}) => pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       child: pw.Text(text, style: pw.TextStyle(font: regularFont, fontSize: 9.5, color: color ?? _kInk)),
//     );
//
//     final rows = <pw.TableRow>[
//       pw.TableRow(
//         decoration: const pw.BoxDecoration(color: _kPrimaryDark),
//         children: [
//           headerCell('#'),
//           headerCell('Student Name'),
//           headerCell('Status'),
//         ],
//       ),
//     ];
//
//     for (var i = 0; i < records.length; i++) {
//       final r = records[i];
//       final colors = _statusColors(r.status);
//       rows.add(
//         pw.TableRow(
//           decoration: pw.BoxDecoration(
//             color: i.isEven ? PdfColors.white : _kSurface,
//             border: const pw.Border(bottom: pw.BorderSide(color: _kBorder, width: 0.6)),
//           ),
//           children: [
//             bodyCell('${i + 1}', color: _kSlate),
//             bodyCell(r.name.isNotEmpty ? r.name : 'Unnamed'),
//             pw.Padding(
//               padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//               child: pw.Container(
//                 padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: pw.BoxDecoration(
//                   color: colors['bg'],
//                   borderRadius: pw.BorderRadius.circular(10),
//                 ),
//                 child: pw.Text(
//                   r.status.label,
//                   style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: colors['fg']),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return pw.Table(
//       columnWidths: const {
//         0: pw.FlexColumnWidth(0.6),
//         1: pw.FlexColumnWidth(3),
//         2: pw.FlexColumnWidth(1.6),
//       },
//       border: const pw.TableBorder(
//         top: pw.BorderSide(color: _kBorder, width: 0.6),
//         bottom: pw.BorderSide(color: _kBorder, width: 0.6),
//       ),
//       children: rows,
//     );
//   }
//
//   /// Generates the PDF and opens the platform print/share sheet.
//   /// Works on Web (browser print/save dialog) and Mobile (native
//   /// share/print sheet) via the `printing` package.
//   static Future<void> generateAndOpen(List<ClassAttendanceModel> todayDocs) async {
//     final bytes = await _buildPdfBytes(todayDocs);
//     final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//     if (kIsWeb) {
//       await Printing.layoutPdf(
//         onLayout: (format) async => bytes,
//         name: 'Class_Attendance_Report_$dateStr.pdf',
//       );
//     } else {
//       await Printing.sharePdf(
//         bytes: bytes,
//         filename: 'Class_Attendance_Report_$dateStr.pdf',
//       );
//     }
//   }
//
//   static pw.Widget _buildMonthlyTrendChart(List<DayAggregate> trend) {
//     return pw.CustomPaint(
//       size: const PdfPoint(500, 180),
//       painter: (PdfGraphics canvas, PdfPoint size) {
//         // Draw background
//         canvas.setColor(PdfColors.white);
//         canvas.drawRect(0, 0, size.x, size.y);
//         canvas.setStrokeColor(_kBorder);
//         canvas.setLineWidth(0.5);
//         // Horizontal grid lines
//         for (double y = 0; y <= size.y; y += size.y / 4) {
//           canvas.moveTo(0, y);
//           canvas.lineTo(size.x, y);
//           canvas.strokePath();
//         }
//         // Draw line
//         if (trend.isEmpty) return;
//         final maxY = 100.0;
//         final stepX = size.x / (trend.length - 1);
//         canvas.setColor(_kPrimary);
//         canvas.setLineWidth(2);
//         canvas.moveTo(0, size.y - (trend[0].presentPct / maxY) * size.y);
//         for (int i = 1; i < trend.length; i++) {
//           final x = i * stepX;
//           final y = size.y - (trend[i].presentPct / maxY) * size.y;
//           canvas.lineTo(x, y);
//         }
//         canvas.strokePath();
//         // Draw dots
//         canvas.setFillColor(_kPrimary);
//         for (int i = 0; i < trend.length; i++) {
//           final x = i * stepX;
//           final y = size.y - (trend[i].presentPct / maxY) * size.y;
//           canvas.drawEllipse(x - 3, y - 3, 6, 6);
//           canvas.fillPath();
//         }
//       },
//     );
//   }
//
// }
//
// class _PdfStatItem {
//   final String label;
//   final String value;
//   final PdfColor color;
//   final PdfColor bg;
//   _PdfStatItem(this.label, this.value, this.color, this.bg);
// }


import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/class_attendance_model.dart';
import '../providers/class_attendance_report_provider.dart';

// ============================================================
// PDF EXPORT — All Classes Today, Daily, and Monthly Reports
// ============================================================
class ClassAttendancePdfService {
  static const PdfColor _kPrimary = PdfColor.fromInt(0xFF534AB7);
  static const PdfColor _kPrimaryDark = PdfColor.fromInt(0xFF433CA0);
  static const PdfColor _kInk = PdfColor.fromInt(0xFF1F2937);
  static const PdfColor _kSlate = PdfColor.fromInt(0xFF64748B);
  static const PdfColor _kBorder = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor _kSurface = PdfColor.fromInt(0xFFF8FAFC);

  static const PdfColor _kGreen = PdfColor.fromInt(0xFF166534);
  static const PdfColor _kGreenBg = PdfColor.fromInt(0xFFEFFCF3);
  static const PdfColor _kRed = PdfColor.fromInt(0xFFB91C1C);
  static const PdfColor _kRedBg = PdfColor.fromInt(0xFFFEF2F2);
  static const PdfColor _kOrange = PdfColor.fromInt(0xFFB45309);
  static const PdfColor _kOrangeBg = PdfColor.fromInt(0xFFFFFBEB);
  static const PdfColor _kBlue = PdfColor.fromInt(0xFF1D4ED8);
  static const PdfColor _kBlueBg = PdfColor.fromInt(0xFFEFF6FF);
  static const PdfColor _kPurple = PdfColor.fromInt(0xFF6D28D9);
  static const PdfColor _kPurpleBg = PdfColor.fromInt(0xFFF5F3FF);

  static Map<String, PdfColor> _statusColors(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return {'fg': _kGreen, 'bg': _kGreenBg};
      case AttendanceStatus.absent:
        return {'fg': _kRed, 'bg': _kRedBg};
      case AttendanceStatus.late:
        return {'fg': _kOrange, 'bg': _kOrangeBg};
      case AttendanceStatus.leave:
        return {'fg': _kBlue, 'bg': _kBlueBg};
      case AttendanceStatus.halfDay:
        return {'fg': _kPurple, 'bg': _kPurpleBg};
    }
  }

  // ============================================================
  // ALL CLASSES TODAY (Dashboard export)
  // ============================================================
  static Future<Uint8List> _buildAllClassesPdfBytes(List<ClassAttendanceModel> docs) async {
    final doc = pw.Document();

    final regularFont = await PdfGoogleFonts.nunitoSansRegular();
    final boldFont = await PdfGoogleFonts.nunitoSansBold();
    final extraBoldFont = await PdfGoogleFonts.nunitoSansExtraBold();

    final today = DateTime.now();
    final dateLabel = DateFormat('EEEE, dd MMMM yyyy').format(today);

    final usableDocs = docs.where((d) => d.records.isNotEmpty).toList()
      ..sort((a, b) {
        final c = a.className.compareTo(b.className);
        if (c != 0) return c;
        return a.sectionName.compareTo(b.sectionName);
      });

    if (usableDocs.isEmpty) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Text(
              'No attendance marked for any class today.',
              style: pw.TextStyle(font: regularFont, fontSize: 13, color: _kSlate),
            ),
          ),
        ),
      );
      return doc.save();
    }

    for (final classDoc in usableDocs) {
      final records = classDoc.records.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final total = records.length;
      final present = records.where((r) => r.status == AttendanceStatus.present).length;
      final absent = records.where((r) => r.status == AttendanceStatus.absent).length;
      final late = records.where((r) => r.status == AttendanceStatus.late).length;
      final leave = records.where((r) => r.status == AttendanceStatus.leave).length;
      final halfDay = records.where((r) => r.status == AttendanceStatus.halfDay).length;
      final pct = total == 0 ? 0.0 : (present / total) * 100;

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
          header: (context) => _buildPageHeader(
            regularFont: regularFont,
            boldFont: boldFont,
            extraBoldFont: extraBoldFont,
            dateLabel: dateLabel,
            className: classDoc.className,
            sectionName: classDoc.sectionName,
          ),
          footer: (context) => _buildFooter(regularFont, context),
          build: (context) => [
            pw.SizedBox(height: 14),
            _buildSummaryRow(
              regularFont: regularFont,
              boldFont: boldFont,
              total: total,
              present: present,
              absent: absent,
              late: late,
              leave: leave,
              halfDay: halfDay,
              pct: pct,
            ),
            pw.SizedBox(height: 16),
            _buildStudentTable(
              regularFont: regularFont,
              boldFont: boldFont,
              records: records,
            ),
          ],
        ),
      );
    }

    return doc.save();
  }

  // ============================================================
  // DAILY REPORT (single class/section, selected date)
  // ============================================================
  static Future<Uint8List> _buildDailyPdfBytes(
      ClassAttendanceModel model,
      String className,
      String sectionName,
      DateTime date,
      ) async {
    final doc = pw.Document();
    final regularFont = await PdfGoogleFonts.nunitoSansRegular();
    final boldFont = await PdfGoogleFonts.nunitoSansBold();
    final extraBoldFont = await PdfGoogleFonts.nunitoSansExtraBold();

    final dateLabel = DateFormat('EEEE, dd MMMM yyyy').format(date);
    final records = model.records.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        header: (context) => _buildPageHeader(
          regularFont: regularFont,
          boldFont: boldFont,
          extraBoldFont: extraBoldFont,
          dateLabel: dateLabel,
          className: className,
          sectionName: sectionName,
        ),
        footer: (context) => _buildFooter(regularFont, context),
        build: (context) => [
          pw.SizedBox(height: 14),
          _buildSummaryRow(
            regularFont: regularFont,
            boldFont: boldFont,
            total: model.totalCount,
            present: model.presentCount,
            absent: model.absentCount,
            late: model.lateCount,
            leave: model.leaveCount,
            halfDay: model.halfDayCount,
            pct: model.totalCount == 0 ? 0 : (model.presentCount / model.totalCount) * 100,
          ),
          pw.SizedBox(height: 16),
          _buildStudentTable(
            regularFont: regularFont,
            boldFont: boldFont,
            records: records,
          ),
        ],
      ),
    );
    return doc.save();
  }

  // ============================================================
  // MONTHLY REPORT (single class/section, selected month)
  // ============================================================
  static Future<Uint8List> _buildMonthlyPdfBytes(
      ClassAttendanceReportProvider provider,
      String className,
      String sectionName,
      int month,
      int year,
      ) async {
    final doc = pw.Document();
    final regularFont = await PdfGoogleFonts.nunitoSansRegular();
    final boldFont = await PdfGoogleFonts.nunitoSansBold();
    final extraBoldFont = await PdfGoogleFonts.nunitoSansExtraBold();

    final monthLabel = DateFormat('MMMM yyyy').format(DateTime(year, month));
    final students = provider.studentStats;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        header: (context) => _buildPageHeader(
          regularFont: regularFont,
          boldFont: boldFont,
          extraBoldFont: extraBoldFont,
          dateLabel: monthLabel,
          className: className,
          sectionName: sectionName,
        ),
        footer: (context) => _buildFooter(regularFont, context),
        build: (context) => [
          pw.SizedBox(height: 14),
          _buildMonthlySummaryCards(provider, regularFont, boldFont),
          pw.SizedBox(height: 16),
          if (provider.monthDailyTrend.isNotEmpty) ...[
            pw.Text(
              'Attendance Trend',
              style: pw.TextStyle(font: boldFont, fontSize: 13, color: _kInk),
            ),
            pw.SizedBox(height: 6),
            _buildMonthlyTrendChart(provider.monthDailyTrend),
            pw.SizedBox(height: 16),
          ],
          _buildMonthlyStudentTable(students, regularFont, boldFont),
        ],
      ),
    );
    return doc.save();
  }

  // ============================================================
  // PUBLIC GENERATION METHODS
  // ============================================================
  static Future<void> generateAndOpen(List<ClassAttendanceModel> todayDocs) async {
    final bytes = await _buildAllClassesPdfBytes(todayDocs);
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Class_Attendance_Report_$dateStr.pdf',
      );
    } else {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Class_Attendance_Report_$dateStr.pdf',
      );
    }
  }

  static Future<void> generateDailyReport({
    required ClassAttendanceModel model,
    required String className,
    required String sectionName,
    required DateTime date,
  }) async {
    final bytes = await _buildDailyPdfBytes(model, className, sectionName, date);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Daily_Report_${className}_${sectionName}_$dateStr.pdf',
      );
    } else {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Daily_Report_${className}_${sectionName}_$dateStr.pdf',
      );
    }
  }

  static Future<void> generateMonthlyReport({
    required ClassAttendanceReportProvider provider,
    required String className,
    required String sectionName,
    required int month,
    required int year,
  }) async {
    final bytes = await _buildMonthlyPdfBytes(provider, className, sectionName, month, year);
    final monthStr = DateFormat('yyyy-MM').format(DateTime(year, month));
    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Monthly_Report_${className}_${sectionName}_$monthStr.pdf',
      );
    } else {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Monthly_Report_${className}_${sectionName}_$monthStr.pdf',
      );
    }
  }

  // ============================================================
  // PDF WIDGET BUILDERS
  // ============================================================
  static pw.Widget _buildPageHeader({
    required pw.Font regularFont,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
    required String dateLabel,
    required String className,
    required String sectionName,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Class Attendance Report',
                  style: pw.TextStyle(font: extraBoldFont, fontSize: 16, color: _kInk),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  dateLabel,
                  style: pw.TextStyle(font: regularFont, fontSize: 10, color: _kSlate),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: pw.BoxDecoration(
                color: _kPrimary,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                '$className — $sectionName',
                style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.white),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: _kBorder, thickness: 1),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Font regularFont, pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(color: _kBorder, thickness: 0.6),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
              style: pw.TextStyle(font: regularFont, fontSize: 8, color: _kSlate),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(font: regularFont, fontSize: 8, color: _kSlate),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow({
    required pw.Font regularFont,
    required pw.Font boldFont,
    required int total,
    required int present,
    required int absent,
    required int late,
    required int leave,
    required int halfDay,
    required double pct,
  }) {
    final items = <_PdfStatItem>[
      _PdfStatItem('Total', '$total', _kSlate, _kSurface),
      _PdfStatItem('Present', '$present', _kGreen, _kGreenBg),
      _PdfStatItem('Absent', '$absent', _kRed, _kRedBg),
      _PdfStatItem('Late', '$late', _kOrange, _kOrangeBg),
      _PdfStatItem('Leave', '$leave', _kBlue, _kBlueBg),
      _PdfStatItem('Half Day', '$halfDay', _kPurple, _kPurpleBg),
      _PdfStatItem('Attendance %', '${pct.toStringAsFixed(1)}%', _kPrimary, PdfColor.fromInt(0xFFF0EFFE)),
    ];

    return pw.Row(
      children: items
          .map(
            (item) => pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.only(right: 6),
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: pw.BoxDecoration(
              color: item.bg,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.value, style: pw.TextStyle(font: boldFont, fontSize: 13, color: item.color)),
                pw.SizedBox(height: 2),
                pw.Text(item.label, style: pw.TextStyle(font: regularFont, fontSize: 7.5, color: item.color)),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  static pw.Widget _buildStudentTable({
    required pw.Font regularFont,
    required pw.Font boldFont,
    required List<AttendanceRecord> records,
  }) {
    pw.Widget headerCell(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(text, style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: PdfColors.white)),
    );

    pw.Widget bodyCell(String text, {PdfColor? color}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(text, style: pw.TextStyle(font: regularFont, fontSize: 9.5, color: color ?? _kInk)),
    );

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _kPrimaryDark),
        children: [
          headerCell('#'),
          headerCell('Student Name'),
          headerCell('Status'),
        ],
      ),
    ];

    for (var i = 0; i < records.length; i++) {
      final r = records[i];
      final colors = _statusColors(r.status);
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i.isEven ? PdfColors.white : _kSurface,
            border: const pw.Border(bottom: pw.BorderSide(color: _kBorder, width: 0.6)),
          ),
          children: [
            bodyCell('${i + 1}', color: _kSlate),
            bodyCell(r.name.isNotEmpty ? r.name : 'Unnamed'),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: colors['bg'],
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  r.status.label,
                  style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: colors['fg']),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(0.6),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(1.6),
      },
      border: const pw.TableBorder(
        top: pw.BorderSide(color: _kBorder, width: 0.6),
        bottom: pw.BorderSide(color: _kBorder, width: 0.6),
      ),
      children: rows,
    );
  }

  static pw.Widget _buildMonthlySummaryCards(
      ClassAttendanceReportProvider provider,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    final students = provider.studentStats;
    final totalStudents = students.length;
    final daysMarked = provider.daysMarkedInMonth;

    final avgPct = students.isEmpty ? 0.0 : students.map((s) => s.percentage).reduce((a, b) => a + b) / students.length;

    int totalPresent = 0, totalAbsent = 0, totalLeave = 0, totalLate = 0, totalHalf = 0;
    for (final s in students) {
      totalPresent += s.present;
      totalAbsent += s.absent;
      totalLeave += s.leave;
      totalLate += s.late;
      totalHalf += s.halfDay;
    }

    final items = <_PdfStatItem>[
      _PdfStatItem('Students', '$totalStudents', _kPrimary, PdfColor.fromInt(0xFFF0EFFE)),
      _PdfStatItem('Days Marked', '$daysMarked', _kSlate, _kSurface),
      _PdfStatItem('Present', '$totalPresent', _kGreen, _kGreenBg),
      _PdfStatItem('Absent', '$totalAbsent', _kRed, _kRedBg),
      _PdfStatItem('Leave', '$totalLeave', _kBlue, _kBlueBg),
      _PdfStatItem('Late', '$totalLate', _kOrange, _kOrangeBg),
      _PdfStatItem('Half Day', '$totalHalf', _kPurple, _kPurpleBg),
      _PdfStatItem('Avg Attendance', '${avgPct.toStringAsFixed(1)}%', _kPrimary, PdfColor.fromInt(0xFFF0EFFE)),
    ];

    return pw.Row(
      children: items.map((item) {
        return pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.only(right: 4),
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: pw.BoxDecoration(
              color: item.bg,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.value, style: pw.TextStyle(font: boldFont, fontSize: 10, color: item.color)),
                pw.SizedBox(height: 2),
                pw.Text(item.label, style: pw.TextStyle(font: regularFont, fontSize: 6.5, color: item.color)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildMonthlyStudentTable(
      List<StudentMonthStat> students,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    pw.Widget headerCell(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(text, style: pw.TextStyle(font: boldFont, fontSize: 7.5, color: PdfColors.white)),
    );

    pw.Widget cell(String text, {PdfColor? color}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(font: regularFont, fontSize: 7.5, color: color ?? _kInk)),
    );

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _kPrimaryDark),
        children: [
          headerCell('#'),
          headerCell('Student'),
          headerCell('P'),
          headerCell('A'),
          headerCell('L'),
          headerCell('Late'),
          headerCell('Half'),
          headerCell('%'),
        ],
      ),
    ];

    for (var i = 0; i < students.length; i++) {
      final s = students[i];
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i.isEven ? PdfColors.white : _kSurface,
            border: const pw.Border(bottom: pw.BorderSide(color: _kBorder, width: 0.4)),
          ),
          children: [
            cell('${i + 1}', color: _kSlate),
            cell(s.name),
            cell('${s.present}', color: _kGreen),
            cell('${s.absent}', color: _kRed),
            cell('${s.leave}', color: _kBlue),
            cell('${s.late}', color: _kOrange),
            cell('${s.halfDay}', color: _kPurple),
            cell('${s.percentage.toStringAsFixed(0)}%', color: _kPrimary),
          ],
        ),
      );
    }

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(0.4),
        1: pw.FlexColumnWidth(2.5),
        2: pw.FlexColumnWidth(0.6),
        3: pw.FlexColumnWidth(0.6),
        4: pw.FlexColumnWidth(0.6),
        5: pw.FlexColumnWidth(0.8),
        6: pw.FlexColumnWidth(0.8),
        7: pw.FlexColumnWidth(0.8),
      },
      border: const pw.TableBorder(
        top: pw.BorderSide(color: _kBorder, width: 0.6),
        bottom: pw.BorderSide(color: _kBorder, width: 0.6),
      ),
      children: rows,
    );
  }

  static pw.Widget _buildMonthlyTrendChart(List<DayAggregate> trend) {
    return pw.CustomPaint(
      size: PdfPoint(500, 180),
      painter: (PdfGraphics canvas, PdfPoint size) {
        // Background
        canvas.setFillColor(PdfColors.white);
        canvas.drawRect(0, 0, size.x, size.y);
        canvas.fillPath();

        // Grid lines
        canvas.setStrokeColor(_kBorder);
        canvas.setLineWidth(0.5);
        for (double y = 0; y <= size.y; y += size.y / 4) {
          canvas.moveTo(0, y);
          canvas.lineTo(size.x, y);
          canvas.strokePath();
        }

        // Data line
        if (trend.isEmpty) return;
        final maxY = 100.0;
        final stepX = size.x / (trend.length - 1);
        canvas.setStrokeColor(_kPrimary);
        canvas.setLineWidth(2);
        canvas.moveTo(0, size.y - (trend[0].presentPct / maxY) * size.y);
        for (int i = 1; i < trend.length; i++) {
          final x = i * stepX;
          final y = size.y - (trend[i].presentPct / maxY) * size.y;
          canvas.lineTo(x, y);
        }
        canvas.strokePath();

        // Dots
        canvas.setFillColor(_kPrimary);
        for (int i = 0; i < trend.length; i++) {
          final x = i * stepX;
          final y = size.y - (trend[i].presentPct / maxY) * size.y;
          canvas.drawEllipse(x - 3, y - 3, 6, 6);
          canvas.fillPath();
        }
      },
    );
  }
}

class _PdfStatItem {
  final String label;
  final String value;
  final PdfColor color;
  final PdfColor bg;
  _PdfStatItem(this.label, this.value, this.color, this.bg);
}