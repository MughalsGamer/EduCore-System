import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/class_attendance_model.dart';
import '../providers/class_attendance_report_provider.dart';
import '../screens/student_management/student_attendance_report_screen.dart'; // for StudentMonthStat, DayStatusEntry

class StudentAttendancePdfService {
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

  static Future<void> generatePdf({
    required StudentRecord student,
    required StudentMonthStat? stat,
    required List<DayStatusEntry> entries,
    required int month,
    required int year,
  }) async {
    final bytes = await _buildPdfBytes(student, stat, entries, month, year);
    final monthStr = DateFormat('yyyy-MM').format(DateTime(year, month));

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Student_Attendance_${student.name}_$monthStr.pdf',
      );
    } else {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Student_Attendance_${student.name}_$monthStr.pdf',
      );
    }
  }

  static Future<Uint8List> _buildPdfBytes(
      StudentRecord student,
      StudentMonthStat? stat,
      List<DayStatusEntry> entries,
      int month,
      int year,
      ) async {
    final doc = pw.Document();
    final regularFont = await PdfGoogleFonts.nunitoSansRegular();
    final boldFont = await PdfGoogleFonts.nunitoSansBold();
    final extraBoldFont = await PdfGoogleFonts.nunitoSansExtraBold();

    // Decode image if available
    pw.ImageProvider? studentImage;
    if (student.imageBase64 != null && student.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(student.imageBase64!);
        studentImage = pw.MemoryImage(bytes);
      } catch (_) {
        studentImage = null;
      }
    }

    final monthLabel = DateFormat('MMMM yyyy').format(DateTime(year, month));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        header: (context) => _buildHeader(regularFont, boldFont, extraBoldFont, monthLabel),
        footer: (context) => _buildFooter(regularFont, context),
        build: (context) => [
          // Student details card
          _buildStudentInfoCard(student, studentImage, regularFont, boldFont, extraBoldFont),
          pw.SizedBox(height: 16),
          // Summary cards
          _buildSummaryCards(stat, regularFont, boldFont),
          pw.SizedBox(height: 20),
          pw.Text('Daily Attendance', style: pw.TextStyle(font: boldFont, fontSize: 13, color: _kInk)),
          pw.SizedBox(height: 8),
          _buildDailyTable(entries, regularFont, boldFont),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(
      pw.Font regularFont,
      pw.Font boldFont,
      pw.Font extraBoldFont,
      String monthLabel,
      ) {
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
                pw.Text('Student Attendance Report', style: pw.TextStyle(font: extraBoldFont, fontSize: 16, color: _kInk)),
                pw.SizedBox(height: 3),
                pw.Text(monthLabel, style: pw.TextStyle(font: regularFont, fontSize: 10, color: _kSlate)),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: pw.BoxDecoration(color: _kPrimary, borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Text('Student-wise', style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.white)),
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

  static pw.Widget _buildStudentInfoCard(
      StudentRecord student,
      pw.ImageProvider? image,
      pw.Font regularFont,
      pw.Font boldFont,
      pw.Font extraBoldFont,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0EFFE),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          if (image != null)
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
              ),
            )
          else
            pw.Container(
              width: 60,
              height: 60,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: _kPrimary,
              ),
              child: pw.Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: pw.TextStyle(font: boldFont, fontSize: 20, color: _kPrimary),
              ),
            ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(student.name, style: pw.TextStyle(font: extraBoldFont, fontSize: 14, color: _kInk)),
                pw.SizedBox(height: 4),
                pw.Text('${student.className} — ${student.sectionName}', style: pw.TextStyle(font: regularFont, fontSize: 10, color: _kSlate)),
                if (student.familyId.isNotEmpty)
                  pw.Text('Family ID: ${student.familyId}', style: pw.TextStyle(font: regularFont, fontSize: 9, color: _kSlate)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCards(
      StudentMonthStat? stat,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    final present = stat?.present ?? 0;
    final absent = stat?.absent ?? 0;
    final leave = stat?.leave ?? 0;
    final late = stat?.late ?? 0;
    final halfDay = stat?.halfDay ?? 0;
    final markedDays = stat?.markedDays ?? 0;
    final pct = stat?.percentage ?? 0.0;

    final items = <_PdfStatItem>[
      _PdfStatItem('Marked Days', '$markedDays', _kPrimary, PdfColor.fromInt(0xFFF0EFFE)),
      _PdfStatItem('Present', '$present', _kGreen, _kGreenBg),
      _PdfStatItem('Absent', '$absent', _kRed, _kRedBg),
      _PdfStatItem('Leave', '$leave', _kBlue, _kBlueBg),
      _PdfStatItem('Late', '$late', _kOrange, _kOrangeBg),
      _PdfStatItem('Half Day', '$halfDay', _kPurple, _kPurpleBg),
      _PdfStatItem('Attendance %', '${pct.toStringAsFixed(1)}%', _kPrimary, PdfColor.fromInt(0xFFF0EFFE)),
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

  static pw.Widget _buildDailyTable(
      List<DayStatusEntry> entries,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    pw.Widget headerCell(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text, style: pw.TextStyle(font: boldFont, fontSize: 8, color: PdfColors.white)),
    );

    pw.Widget cell(String text, {PdfColor? color}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(font: regularFont, fontSize: 8, color: color ?? _kInk)),
    );

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _kPrimaryDark),
        children: [
          headerCell('#'),
          headerCell('Date'),
          headerCell('Day'),
          headerCell('Status'),
        ],
      ),
    ];

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final colors = _statusColors(e.status);
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i.isEven ? PdfColors.white : _kSurface,
            border: const pw.Border(bottom: pw.BorderSide(color: _kBorder, width: 0.5)),
          ),
          children: [
            cell('${i + 1}', color: _kSlate),
            cell(DateFormat('dd-MMM-yyyy').format(e.date)),
            cell(DateFormat('EEEE').format(e.date)),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: colors['bg'],
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  e.status.label,
                  style: pw.TextStyle(font: boldFont, fontSize: 7.5, color: colors['fg']),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(0.4),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.2),
      },
      border: const pw.TableBorder(
        top: pw.BorderSide(color: _kBorder, width: 0.6),
        bottom: pw.BorderSide(color: _kBorder, width: 0.6),
      ),
      children: rows,
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