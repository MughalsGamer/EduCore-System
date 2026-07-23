// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart'; // for kIsWeb
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// // Only import 'dart:html' on web
// import 'dart:html' as html;      // will be ignored on non-web
//
// import '../../models/teacher.dart';          // adjust path
// import '../../models/attendance_model.dart'; // adjust path
//
// /// Generates an A4‑landscape PDF of a staff member’s monthly attendance.
// /// On mobile/desktop: saves to temp folder & opens automatically.
// /// On web: triggers a browser download.
// Future<void> generateAndOpenAttendancePdf({
//   required StaffMember staff,
//   required List<AttendanceRecord> records,
//   required Map<String, int> summary,
//   required int year,
//   required int month,
// }) async {
//   // ── 1. Compute summary values ──────────────────
//   final total = summary['total'] ?? 0;
//   final present = summary['present'] ?? 0;
//   final absent = summary['absent'] ?? 0;
//   final leave = summary['leave'] ?? 0;
//   final late = summary['late'] ?? 0;
//   final halfDay = summary['half_day'] ?? 0;
//   final holiday = summary['holiday'] ?? 0;
//   final workingDays = total - holiday;
//   final attendancePercent =
//   workingDays == 0 ? 0.0 : (present / workingDays) * 100;
//
//   // ── 2. Build PDF ───────────────────────────────
//   final pdf = pw.Document();
//   pdf.addPage(
//     pw.MultiPage(
//       pageFormat: PdfPageFormat.a4.landscape,
//       margin: const pw.EdgeInsets.all(24),
//       build: (context) => [
//         _pdfHeader(staff, year, month),
//         pw.SizedBox(height: 14),
//         _pdfSummaryRow(
//           present: present,
//           absent: absent,
//           leave: leave,
//           late: late,
//           halfDay: halfDay,
//           holiday: holiday,
//           workingDays: workingDays,
//           percent: attendancePercent,
//         ),
//         pw.SizedBox(height: 20),
//         _pdfTable(records),
//       ],
//     ),
//   );
//
//   final pdfBytes = await pdf.save();
//
//   // ── 3. Save / open based on platform ──────────
//   final monthYear = DateFormat('yyyy_MM').format(DateTime(year, month));
//   final fileName = 'attendance_${staff.name}_$monthYear.pdf';
//
//   if (kIsWeb) {
//     // WEB: trigger download using dart:html
//     final blob = html.Blob([pdfBytes], 'application/pdf');
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute('download', fileName)
//       ..click();
//     html.Url.revokeObjectUrl(url);
//   } else {
//     // MOBILE / DESKTOP
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(pdfBytes);
//     await OpenFile.open(file.path);
//   }
// }
//
// // ──────────────────────────────────────────────────
// //  PDF WIDGET HELPERS (unchanged from before)
// // ──────────────────────────────────────────────────
//
// pw.Widget _pdfHeader(StaffMember staff, int year, int month) {
//   return pw.Container(
//     padding: const pw.EdgeInsets.all(14),
//     decoration: pw.BoxDecoration(
//       color: const PdfColor.fromInt(0xFF534AB7),
//       borderRadius: pw.BorderRadius.circular(8),
//     ),
//     child: pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.center,
//       children: [
//         pw.Text(
//           staff.name,
//           style: pw.TextStyle(
//             fontSize: 22,
//             fontWeight: pw.FontWeight.bold,
//             color: const PdfColor.fromInt(0xFFFFFFFF),
//           ),
//         ),
//         pw.Spacer(),
//         pw.Text(
//           DateFormat('MMMM yyyy').format(DateTime(year, month)),
//           style: pw.TextStyle(
//             fontSize: 15,
//             color: const PdfColor.fromInt(0xFFFFFFFF),
//           ),
//         ),
//         pw.SizedBox(width: 16),
//         pw.Text(
//           staff.type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff',
//           style: pw.TextStyle(
//             fontSize: 15,
//             color: const PdfColor.fromInt(0xFFFFFFFF),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// pw.Widget _pdfSummaryRow({
//   required int present,
//   required int absent,
//   required int leave,
//   required int late,
//   required int halfDay,
//   required int holiday,
//   required int workingDays,
//   required double percent,
// }) {
//   final items = [
//     ('Working Days', '$workingDays'),
//     ('Present', '$present'),
//     ('Absent', '$absent'),
//     ('Leave', '$leave'),
//     ('Late', '$late'),
//     ('Half Day', '$halfDay'),
//     ('Holidays', '$holiday'),
//     ('Attendance %', '${percent.toStringAsFixed(1)}%'),
//   ];
//
//   return pw.Wrap(
//     spacing: 8,
//     runSpacing: 8,
//     children: items.map((e) {
//       return pw.Container(
//         padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         decoration: pw.BoxDecoration(
//           border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
//           borderRadius: pw.BorderRadius.circular(6),
//         ),
//         child: pw.Column(
//           mainAxisSize: pw.MainAxisSize.min,
//           children: [
//             pw.Text(
//               e.$2,
//               style: pw.TextStyle(
//                 fontSize: 13,
//                 fontWeight: pw.FontWeight.bold,
//                 color: const PdfColor.fromInt(0xFF1F2937),
//               ),
//             ),
//             pw.SizedBox(height: 4),
//             pw.Text(
//               e.$1,
//               style: pw.TextStyle(
//                 fontSize: 9,
//                 color: const PdfColor.fromInt(0xFF64748B),
//               ),
//             ),
//           ],
//         ),
//       );
//     }).toList(),
//   );
// }
//
// pw.Widget _pdfTable(List<AttendanceRecord> records) {
//   final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
//
//   return pw.TableHelper.fromTextArray(
//     headerStyle: pw.TextStyle(
//       fontWeight: pw.FontWeight.bold,
//       fontSize: 10,
//       color: const PdfColor.fromInt(0xFFFFFFFF),
//     ),
//     headerDecoration: const pw.BoxDecoration(
//       color: PdfColor.fromInt(0xFF534AB7),
//     ),
//     cellStyle: pw.TextStyle(
//       fontSize: 9,
//       color: const PdfColor.fromInt(0xFF1F2937),
//     ),
//     cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//     columnWidths: {
//       0: const pw.FixedColumnWidth(24),
//       1: const pw.FixedColumnWidth(80),
//       2: const pw.FixedColumnWidth(90),
//       3: const pw.FixedColumnWidth(130),
//       4: const pw.FlexColumnWidth(1),
//     },
//     headers: ['#', 'Date', 'Day', 'Status', 'Remarks'],
//     data: List<List<String>>.generate(sorted.length, (i) {
//       final r = sorted[i];
//       DateTime? dt;
//       try {
//         dt = DateTime.parse(r.date);
//       } catch (_) {}
//       // reuse _statusMeta (must be defined in this file)
//       final meta = _statusMeta(r.status);
//       return [
//         '${i + 1}',
//         dt != null ? DateFormat('dd-MMM-yyyy').format(dt) : r.date,
//         dt != null ? DateFormat('EEEE').format(dt) : '-',
//         meta['label'] as String,
//         r.remarks.isEmpty ? '-' : r.remarks,
//       ];
//     }),
//   );
// }
//
// // ── Status meta (copy from your screen to keep service self-contained) ──
// const List<Map<String, Object>> _statusList = [
//   {'key': 'present', 'label': 'Present'},
//   {'key': 'absent', 'label': 'Absent'},
//   {'key': 'late', 'label': 'Late'},
//   {'key': 'leave', 'label': 'Leave'},
//   {'key': 'half_day', 'label': 'Half Day'},
//   {'key': 'holiday', 'label': 'Holiday'},
// ];
//
// Map<String, Object> _statusMeta(String key) {
//   return _statusList.firstWhere(
//         (s) => s['key'] == key,
//     orElse: () => _statusList[0],
//   );
// }


import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Only for web download
import 'dart:html' as html;

import '../../models/teacher.dart';
import '../../models/attendance_model.dart';

/// Generates an A4‑landscape PDF with colourful two‑column attendance cards,
/// summary, and employee photo. Saves & opens on mobile/desktop, downloads on web.
Future<void> generateAndOpenAttendancePdf({
  required StaffMember staff,
  required List<AttendanceRecord> records,
  required Map<String, int> summary,
  required int year,
  required int month,
}) async {
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

  // ── 2. Build PDF document ──────────────────────
  final pdf = pw.Document();

  // Decode staff photo once
  pw.MemoryImage? staffPhoto;
  if (staff.imageBase64 != null && staff.imageBase64!.isNotEmpty) {
    try {
      final bytes = base64Decode(staff.imageBase64!);
      staffPhoto = pw.MemoryImage(Uint8List.fromList(bytes));
    } catch (_) {}
  }

  // Sort records by date
  final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (context) {
        // Start with header and summary (these fit on every page)
        final pageWidgets = <pw.Widget>[
          _pdfHeader(context, staff, year, month, staffPhoto),
          pw.SizedBox(height: 14),
          _pdfSummaryRow(
            present: present,
            absent: absent,
            leave: leave,
            late: late,
            halfDay: halfDay,
            holiday: holiday,
            workingDays: workingDays,
            percent: attendancePercent,
          ),
          pw.SizedBox(height: 20),
        ];

        // Build rows of two cards each – MultiPage will split automatically
        for (int i = 0; i < sorted.length; i += 2) {
          final left = _singlePdfCard(sorted[i], staffPhoto);
          final right = (i + 1 < sorted.length)
              ? _singlePdfCard(sorted[i + 1], staffPhoto)
              : pw.SizedBox(width: 1); // empty placeholder

          pageWidgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: left),
                  pw.SizedBox(width: 10),
                  pw.Expanded(child: right),
                ],
              ),
            ),
          );
        }
        return pageWidgets;
      },
    ),
  );

  final pdfBytes = await pdf.save();
  final monthYear = DateFormat('yyyy_MM').format(DateTime(year, month));
  final fileName = 'attendance_${staff.name}_$monthYear.pdf';

  // ── 3. Save & open ─────────────────────────────
  if (kIsWeb) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } else {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    await OpenFile.open(file.path);
  }
}

// ──────────────────────────────────────────────────
//  PDF WIDGET HELPERS
// ──────────────────────────────────────────────────

pw.Widget _pdfHeader(pw.Context context, StaffMember staff, int year,
    int month, pw.MemoryImage? photo) {
  final fadedWhite = PdfColor.fromInt(0xFFFFFFFF).withOpacity(0.9);

  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: const PdfColor.fromInt(0xFF534AB7),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.ClipOval(
          child: photo != null
              ? pw.Image(photo, width: 44, height: 44, fit: pw.BoxFit.cover)
              : pw.Container(
            width: 44,
            height: 44,
            alignment: pw.Alignment.center,
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF0EFFE),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Text(
              staff.name.isNotEmpty
                  ? staff.name[0].toUpperCase()
                  : '?',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF534AB7),
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 14),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                staff.name,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFFFFFFFF),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                staff.type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff',
                style: pw.TextStyle(
                  fontSize: 13,
                  color: fadedWhite,
                ),
              ),
            ],
          ),
        ),
        pw.Text(
          DateFormat('MMMM yyyy').format(DateTime(year, month)),
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFFFFFFFF),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _pdfSummaryRow({
  required int present,
  required int absent,
  required int leave,
  required int late,
  required int halfDay,
  required int holiday,
  required int workingDays,
  required double percent,
}) {
  final items = [
    ('Working Days', '$workingDays'),
    ('Present', '$present'),
    ('Absent', '$absent'),
    ('Leave', '$leave'),
    ('Late', '$late'),
    ('Half Day', '$halfDay'),
    ('Holidays', '$holiday'),
    ('Attendance %', '${percent.toStringAsFixed(1)}%'),
  ];

  return pw.Wrap(
    spacing: 8,
    runSpacing: 8,
    children: items.map((e) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              e.$2,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF1F2937),
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              e.$1,
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColor.fromInt(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

// ── Compact card (fits two per row) ──────────────
pw.Widget _singlePdfCard(
    AttendanceRecord record, pw.MemoryImage? staffPhoto) {
  final meta = _statusMeta(record.status);
  final PdfColor statusColor = _colorFromHex(meta['colorHex'] as String);
  final PdfColor statusBg = _colorFromHex(meta['bgHex'] as String);
  final String label = meta['label'] as String;

  DateTime? date;
  try {
    date = DateTime.parse(record.date);
  } catch (_) {}

  final PdfColor borderColor = _applyOpacity(statusColor, 0.4);

  return pw.Container(
    padding: const pw.EdgeInsets.all(8),   // reduced padding
    decoration: pw.BoxDecoration(
      color: statusBg,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: borderColor),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Small avatar (24x24)
        pw.ClipOval(
          child: staffPhoto != null
              ? pw.Image(staffPhoto, width: 24, height: 24,
              fit: pw.BoxFit.cover)
              : pw.Container(
            width: 24,
            height: 24,
            alignment: pw.Alignment.center,
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF0EFFE),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Text(
              record.staffName.isNotEmpty
                  ? record.staffName[0].toUpperCase()
                  : '?',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF534AB7),
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        // Date & day + optional remarks (max 1 line)
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (date != null)
                pw.Text(
                  '${DateFormat('dd MMM yyyy').format(date)}  ${DateFormat('EEEE').format(date)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF1F2937),
                  ),
                ),
              if (record.remarks.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  record.remarks,
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor.fromInt(0xFF374151),
                  ),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(width: 6),
        // Status badge
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: pw.BoxDecoration(
            color: statusColor,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFFFFFFFF),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Colour helpers ───────────────────────────────
PdfColor _colorFromHex(String hex) {
  if (hex.isEmpty) return const PdfColor.fromInt(0xFF534AB7);
  try {
    final intVal = int.parse(hex.replaceFirst('#', ''), radix: 16);
    return PdfColor.fromInt(intVal);
  } catch (_) {
    return const PdfColor.fromInt(0xFF534AB7);
  }
}

PdfColor _applyOpacity(PdfColor color, double opacity) {
  return PdfColor(
    color.red / 255,
    color.green / 255,
    color.blue / 255,
    opacity,
  );
}

extension PdfColorOpacity on PdfColor {
  PdfColor withOpacity(double opacity) => _applyOpacity(this, opacity);
}

// ── Status definitions ──────────────────────────
const List<Map<String, Object>> _statusList = [
  {
    'key': 'present',
    'label': 'Present',
    'colorHex': '#166534',
    'bgHex': '#EFFCF3'
  },
  {
    'key': 'absent',
    'label': 'Absent',
    'colorHex': '#B91C1C',
    'bgHex': '#FEF2F2'
  },
  {
    'key': 'late',
    'label': 'Late',
    'colorHex': '#B45309',
    'bgHex': '#FFFBEB'
  },
  {
    'key': 'leave',
    'label': 'Leave',
    'colorHex': '#1D4ED8',
    'bgHex': '#EFF6FF'
  },
  {
    'key': 'half_day',
    'label': 'Half Day',
    'colorHex': '#6D28D9',
    'bgHex': '#F5F3FF'
  },
  {
    'key': 'holiday',
    'label': 'Holiday',
    'colorHex': '#475569',
    'bgHex': '#F1F5F9'
  },
];

Map<String, Object> _statusMeta(String key) {
  return _statusList.firstWhere(
        (s) => s['key'] == key,
    orElse: () => _statusList[0],
  );
}