
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart'; // for the loading dialog
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/teacher.dart'; // adjust path
import '../../models/attendance_model.dart'; // adjust path

// ──────────────────────────────────────────────────
//  COLOR PALETTE — matches app's status colors
// ──────────────────────────────────────────────────
const PdfColor _kNavy = PdfColor.fromInt(0xFF1E1B4B);
const PdfColor _kNavyLight = PdfColor.fromInt(0xFF312E7D);
const PdfColor _kPurple = PdfColor.fromInt(0xFF534AB7);
const PdfColor _kPurpleDark = PdfColor.fromInt(0xFF433CA0);
const PdfColor _kInk = PdfColor.fromInt(0xFF1F2937);
const PdfColor _kSlate = PdfColor.fromInt(0xFF64748B);
const PdfColor _kBorder = PdfColor.fromInt(0xFFE2E8F0);
const PdfColor _kSurface = PdfColor.fromInt(0xFFF8FAFC);
const PdfColor _kWhite = PdfColor.fromInt(0xFFFFFFFF);
const PdfColor _kGold = PdfColor.fromInt(0xFFFBBF24);

const PdfColor _kGreen = PdfColor.fromInt(0xFF166534);
const PdfColor _kGreenBg = PdfColor.fromInt(0xFFEFFCF3);
const PdfColor _kRed = PdfColor.fromInt(0xFFB91C1C);
const PdfColor _kRedBg = PdfColor.fromInt(0xFFFEF2F2);
const PdfColor _kOrange = PdfColor.fromInt(0xFFB45309);
const PdfColor _kOrangeBg = PdfColor.fromInt(0xFFFFFBEB);
const PdfColor _kBlue = PdfColor.fromInt(0xFF1D4ED8);
const PdfColor _kBlueBg = PdfColor.fromInt(0xFFEFF6FF);
const PdfColor _kPurpleAccent = PdfColor.fromInt(0xFF6D28D9);
const PdfColor _kPurpleBg = PdfColor.fromInt(0xFFF5F3FF);
const PdfColor _kGrey = PdfColor.fromInt(0xFF475569);
const PdfColor _kGreyBg = PdfColor.fromInt(0xFFF1F5F9);

Map<String, dynamic> _statusMeta(String key) {
  const list = <Map<String, dynamic>>[
    {'key': 'present', 'label': 'Present', 'color': _kGreen, 'bg': _kGreenBg, 'badge': '1'},
    {'key': 'absent', 'label': 'Absent', 'color': _kRed, 'bg': _kRedBg, 'badge': '2'},
    {'key': 'late', 'label': 'Late', 'color': _kOrange, 'bg': _kOrangeBg, 'badge': '3'},
    {'key': 'leave', 'label': 'Leave', 'color': _kBlue, 'bg': _kBlueBg, 'badge': '4'},
    {'key': 'half_day', 'label': 'Half Day', 'color': _kPurpleAccent, 'bg': _kPurpleBg, 'badge': '5'},
    {'key': 'holiday', 'label': 'Holiday', 'color': _kGrey, 'bg': _kGreyBg, 'badge': '6'},
  ];
  return list.firstWhere((s) => s['key'] == key, orElse: () => list[0]);
}

/// Generates an A4-landscape PDF of a staff member's monthly attendance,
/// styled to match the app's dark navy/purple brand theme, with the
/// staff photo up top and the attendance log split into two columns so
/// everything fits on a single page.
///
/// If [context] is provided, a tiny loading indicator is shown while the
/// PDF is built and saved, and is dismissed as soon as the file is ready.
///
/// On mobile/desktop: saves to temp folder & opens automatically.
/// On web: opens the PDF directly in a new browser tab (print/preview dialog).
Future<void> generateAndOpenAttendancePdf({
  required StaffMember staff,
  required List<AttendanceRecord> records,
  required Map<String, int> summary,
  required int year,
  required int month,
  BuildContext? context,
}) async {
  bool dialogShown = false;
  if (context != null && context.mounted) {
    dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PdfGeneratingDialog(),
    );
    // Let the dialog actually paint before doing any heavy work below.
    await Future.delayed(const Duration(milliseconds: 50));
  }

  try {
    // ── 1. Compute summary values ──────────────────
    final total = summary['total'] ?? 0;
    final present = summary['present'] ?? 0;
    final absent = summary['absent'] ?? 0;
    final leave = summary['leave'] ?? 0;
    final late = summary['late'] ?? 0;
    final halfDay = summary['half_day'] ?? 0;
    final holiday = summary['holiday'] ?? 0;
    final workingDays = total - holiday;
    final attendancePercent =
    workingDays == 0 ? 0.0 : (present / workingDays) * 100;

    // ── 2. Decode staff photo (if any) ─────────────
    pw.MemoryImage? staffImage;
    final picBase64 = staff.imageBase64;
    if (picBase64 != null && picBase64.isNotEmpty) {
      try {
        staffImage = pw.MemoryImage(base64Decode(picBase64));
      } catch (_) {
        staffImage = null;
      }
    }

    // ── 3. Build PDF ───────────────────────────────
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(0),
        build: (pdfContext) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildSidebar(staff, staffImage, year, month),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(
                      present: present,
                      absent: absent,
                      leave: leave,
                      late: late,
                      halfDay: halfDay,
                      holiday: holiday,
                      workingDays: workingDays,
                      percent: attendancePercent,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Expanded(child: _buildTwoColumnTable(records)),
                    pw.SizedBox(height: 8),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // pdf.save() is already asynchronous and yields back to the event
    // loop internally, so the UI thread stays responsive without needing
    // a background isolate (which was the actual source of the freeze —
    // spawning/serializing to a new isolate on some devices can itself
    // stall far longer than just building the PDF directly here).
    final pdfBytes = await pdf.save();

    // ── 4. Save / open based on platform ──────────
    final monthYear = DateFormat('yyyy_MM').format(DateTime(year, month));
    final safeStaffName = staff.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final fileName = 'attendance_${safeStaffName}_$monthYear.pdf';

    if (kIsWeb) {
      // WEB: opens the PDF directly in a new tab via the browser's
      // print/preview dialog. No dart:html needed — works everywhere.
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: fileName,
      );

      if (dialogShown && context != null && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }
    } else {
      // MOBILE / DESKTOP — save then auto-open
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes, flush: true);

      // Dismiss the loader as soon as the file is actually saved — don't
      // make the user wait on the OS's own viewer-launch time.
      if (dialogShown && context != null && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }

      // Fire-and-forget: let the OS open the PDF without blocking us.
      OpenFile.open(file.path).then((result) {
        if (result.type != ResultType.done) {
          // ignore: avoid_print
          print(
            'Could not auto-open attendance PDF: ${result.type} - ${result.message}',
          );
        }
      });
    }
  } catch (e) {
    // ignore: avoid_print
    print('Failed to save/open attendance PDF: $e');
    rethrow;
  } finally {
    if (dialogShown && context != null && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

/// Tiny, instantly-visible loading indicator shown while the PDF is being
/// generated. Kept intentionally minimal so it costs nothing to build and
/// appears the instant the button is tapped.
class _PdfGeneratingDialog extends StatelessWidget {
  const _PdfGeneratingDialog();

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            SizedBox(width: 16),
            Text('Preparing attendance PDF…'),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
//  SIDEBAR — dark navy panel with photo + staff info
// ──────────────────────────────────────────────────
pw.Widget _buildSidebar(
    StaffMember staff, pw.MemoryImage? staffImage, int year, int month) {
  final hasDesignation =
      staff.designation != null && staff.designation!.trim().isNotEmpty;

  return pw.Container(
    width: 165,
    padding: const pw.EdgeInsets.fromLTRB(16, 22, 16, 16),
    decoration: const pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [_kNavy, _kPurpleDark],
        begin: pw.Alignment.topCenter,
        end: pw.Alignment.bottomCenter,
      ),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Photo
        pw.Center(
          child: pw.Container(
            width: 78,
            height: 78,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: _kWhite,
              border: pw.Border.all(color: _kWhite, width: 2.5),
            ),
            child: pw.ClipOval(
              child: staffImage != null
                  ? pw.Image(staffImage, fit: pw.BoxFit.cover)
                  : pw.Center(
                child: pw.Text(
                  staff.name.isNotEmpty
                      ? staff.name[0].toUpperCase()
                      : '?',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: _kPurple,
                  ),
                ),
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 14),

        // Name
        pw.Center(
          child: pw.Text(
            staff.name,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: _kWhite,
            ),
          ),
        ),

        // Designation — plain, clearly legible text directly under the
        // name (gold on dark navy = high contrast, unlike the old
        // low-contrast white-on-white pill).
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            hasDesignation
                ? staff.designation!
                : (staff.type.toLowerCase() == 'teacher'
                ? 'Teacher'
                : 'Staff'),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: _kGold,
              letterSpacing: 0.3,
            ),
          ),
        ),

        pw.SizedBox(height: 20),
        pw.Divider(color: _kWhite.shade(0.2), thickness: 0.7),
        pw.SizedBox(height: 14),

        _sidebarInfoRow(
          'Designation',
          hasDesignation ? staff.designation! : '-',
        ),
        pw.SizedBox(height: 12),
        _sidebarInfoRow(
          'Period',
          DateFormat('MMMM yyyy').format(DateTime(year, month)),
        ),

        pw.Spacer(),
        pw.Divider(color: _kWhite.shade(0.2), thickness: 0.7),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 7.5, color: _kWhite.shade(0.6)),
        ),
      ],
    ),
  );
}

pw.Widget _sidebarInfoRow(String label, String value) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        label.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 7.5,
          color: _kWhite.shade(0.55),
          letterSpacing: 0.5,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 10.5,
          fontWeight: pw.FontWeight.bold,
          color: _kWhite,
        ),
      ),
    ],
  );
}

// ──────────────────────────────────────────────────
//  SUMMARY STAT CARDS
// ──────────────────────────────────────────────────
pw.Widget _buildSummaryRow({
  required int present,
  required int absent,
  required int leave,
  required int late,
  required int halfDay,
  required int holiday,
  required int workingDays,
  required double percent,
}) {
  final items = <Map<String, dynamic>>[
    {'label': 'Working Days', 'value': '$workingDays', 'color': _kPurple, 'bg': PdfColor.fromInt(0xFFF0EFFE)},
    {'label': 'Present', 'value': '$present', 'color': _kGreen, 'bg': _kGreenBg},
    {'label': 'Absent', 'value': '$absent', 'color': _kRed, 'bg': _kRedBg},
    {'label': 'Leave', 'value': '$leave', 'color': _kBlue, 'bg': _kBlueBg},
    {'label': 'Late', 'value': '$late', 'color': _kOrange, 'bg': _kOrangeBg},
    {'label': 'Half Day', 'value': '$halfDay', 'color': _kPurpleAccent, 'bg': _kPurpleBg},
    {'label': 'Holidays', 'value': '$holiday', 'color': _kGrey, 'bg': _kGreyBg},
    {'label': 'Attendance %', 'value': '${percent.toStringAsFixed(1)}%', 'color': _kPurple, 'bg': PdfColor.fromInt(0xFFF0EFFE)},
  ];

  return pw.Row(
    children: items.map((item) {
      final isLast = item == items.last;
      return pw.Expanded(
        child: pw.Container(
          margin: pw.EdgeInsets.only(right: isLast ? 0 : 6),
          padding: const pw.EdgeInsets.symmetric(vertical: 9),
          decoration: pw.BoxDecoration(
            color: item['bg'] as PdfColor,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(
                color: (item['color'] as PdfColor).shade(0.7), width: 0.6),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                item['value'] as String,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: item['color'] as PdfColor,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                item['label'] as String,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 7, color: _kSlate),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

// ──────────────────────────────────────────────────
//  TWO-COLUMN ATTENDANCE TABLE (fits full month on 1 page)
// ──────────────────────────────────────────────────
pw.Widget _buildTwoColumnTable(List<AttendanceRecord> records) {
  final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));

  if (sorted.isEmpty) {
    return pw.Container(
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _kBorder),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        'No attendance records found for this period.',
        style: pw.TextStyle(fontSize: 10, color: _kSlate),
      ),
    );
  }

  final half = (sorted.length / 2).ceil();
  final left = sorted.sublist(0, half);
  final right = sorted.sublist(half);

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _kBorder),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: _buildColumn(left, startIndex: 1)),
        pw.Container(width: 0.8, color: _kBorder),
        pw.Expanded(child: _buildColumn(right, startIndex: half + 1)),
      ],
    ),
  );
}

pw.Widget _buildColumn(List<AttendanceRecord> rows, {required int startIndex}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Header
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: const pw.BoxDecoration(color: _kPurpleDark),
        child: pw.Row(
          children: [
            pw.SizedBox(width: 16, child: pw.Text('#', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _kWhite))),
            pw.Expanded(flex: 3, child: pw.Text('DATE', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _kWhite))),
            pw.Expanded(flex: 3, child: pw.Text('DAY', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _kWhite))),
            pw.Expanded(flex: 3, child: pw.Text('STATUS', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _kWhite))),
            pw.Expanded(flex: 3, child: pw.Text('REMARKS', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _kWhite))),
          ],
        ),
      ),
      // Rows
      ...List.generate(rows.length, (i) {
        final r = rows[i];
        DateTime? dt;
        try {
          dt = DateTime.parse(r.date);
        } catch (_) {
          dt = null;
        }
        final meta = _statusMeta(r.status);

        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: i.isEven ? _kWhite : _kSurface,
            border: const pw.Border(bottom: pw.BorderSide(color: _kBorder, width: 0.4)),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(
                width: 16,
                child: pw.Text('${startIndex + i}', style: pw.TextStyle(fontSize: 7.5, color: _kSlate)),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  dt != null ? DateFormat('dd-MMM').format(dt) : r.date,
                  style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _kInk),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  dt != null ? DateFormat('EEE').format(dt) : '-',
                  style: pw.TextStyle(fontSize: 7.5, color: _kSlate),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: meta['bg'] as PdfColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    meta['label'] as String,
                    style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold, color: meta['color'] as PdfColor),
                  ),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  r.remarks.isEmpty ? '-' : r.remarks,
                  style: pw.TextStyle(fontSize: 7.2, color: _kInk),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
              ),
            ],
          ),
        );
      }),
    ],
  );
}

// ──────────────────────────────────────────────────
//  FOOTER
// ──────────────────────────────────────────────────
pw.Widget _buildFooter() {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        'EduCore School Management System',
        style: pw.TextStyle(fontSize: 7, color: _kSlate),
      ),
      pw.Text(
        'Developed by Ali Haider | 0300-7465064',
        style: pw.TextStyle(fontSize: 7, color: _kSlate),
      ),
    ],
  );
}