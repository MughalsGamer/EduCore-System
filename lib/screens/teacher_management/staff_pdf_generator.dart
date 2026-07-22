//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/foundation.dart';
// import 'package:open_file/open_file.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:path_provider/path_provider.dart';
// import '../../models/teacher.dart';
// import '../../models/school_setting_model.dart';
//
// // ============================================================================
// // Design tokens — navy / gold theme matching the reference layout.
// // ============================================================================
// class _Palette {
//   static const navy = PdfColor.fromInt(0xFF152A54);
//   static const navyDark = PdfColor.fromInt(0xFF0E1E3D);
//
//   static const gold = PdfColor.fromInt(0xFFE8A93B);
//   static const goldLight = PdfColor.fromInt(0xFFF6DFAF);
//
//   static const textPrimary = PdfColor.fromInt(0xFF1A1A2E);
//   static const textSecondary = PdfColor.fromInt(0xFF64748B);
//   static const textMuted = PdfColor.fromInt(0xFF94A3B8);
//
//   static const border = PdfColor.fromInt(0xFFE7EAF0);
//   static const surface = PdfColor.fromInt(0xFFF7F8FB);
//
//   static const green = PdfColor.fromInt(0xFF15803D);
//   static const greenBg = PdfColor.fromInt(0xFFE8F5EC);
//   static const greenBorder = PdfColor.fromInt(0xFFB9E3C3);
//
//   static const red = PdfColor.fromInt(0xFFB91C1C);
//   static const redBg = PdfColor.fromInt(0xFFFDECEC);
//
//   static const white = PdfColors.white;
// }
//
// const _radiusSm = pw.BorderRadius.all(pw.Radius.circular(6));
// const _radiusMd = pw.BorderRadius.all(pw.Radius.circular(10));
// const _radiusPill = pw.BorderRadius.all(pw.Radius.circular(999));
//
// const double _sidebarWidth = 170;
//
// // ----------------------------------------------------------------------
// // 1) PDF content generator
// // ----------------------------------------------------------------------
// //
// // IMPORTANT FIXES vs previous version:
// //  1. Layout was a single fixed-size `pw.Page` with a Row([sidebar, content]).
// //     Because the content column can be taller than one A4 page, the pdf
// //     package could not lay it out and produced the broken/overlapping
// //     "zig-zag" render seen in testing. Fixed by switching to `pw.MultiPage`
// //     with the sidebar rendered as its own bordered container that appears
// //     once, and the main content in the page body so it can paginate
// //     naturally across multiple pages if it's long.
// //  2. Font loading used `PdfGoogleFonts`, which downloads fonts over the
// //     network on every single PDF generation — this is the main reason
// //     generation (and therefore the "Save & open" flow) felt slow. Switched
// //     to the standard built-in Helvetica fonts (`pw.Font.helvetica()` etc.)
// //     which ship with the package and require no network call, making
// //     generation near-instant.
// // ----------------------------------------------------------------------
// Future<Uint8List> generateStaffProfilePdf(
//     StaffMember staff,
//     Map<String, String> classIdToName, {
//       SchoolSettings? school,
//     }) async {
//   final pdf = pw.Document();
//
//   final regularFont = pw.Font.helvetica();
//   final boldFont = pw.Font.helveticaBold();
//
//   final theme = pw.ThemeData.withFont(base: regularFont, bold: boldFont);
//
//   final schoolName = (school?.schoolName.isNotEmpty ?? false)
//       ? school!.schoolName
//       : 'EduCore System';
//
//   pw.MemoryImage? schoolLogo;
//   if (school?.logoBase64 != null && school!.logoBase64!.isNotEmpty) {
//     try {
//       schoolLogo = pw.MemoryImage(base64Decode(school.logoBase64!));
//     } catch (_) {}
//   }
//
//   String fmtDate(String? iso) {
//     if (iso == null || iso.isEmpty) return '-';
//     try {
//       final d = DateTime.parse(iso);
//       const m = [
//         'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//       ];
//       return '${d.day} ${m[d.month - 1]} ${d.year}';
//     } catch (_) {
//       return iso;
//     }
//   }
//
//   pw.MemoryImage? avatarImage;
//   if (staff.imageBase64 != null && staff.imageBase64!.isNotEmpty) {
//     try {
//       avatarImage = pw.MemoryImage(base64Decode(staff.imageBase64!));
//     } catch (_) {}
//   }
//
//   // ---- reusable pieces ----------------------------------------------------
//
//   pw.Widget sectionBanner(String title) {
//     return pw.Container(
//       margin: const pw.EdgeInsets.only(bottom: 10),
//       padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: const pw.BoxDecoration(
//         color: _Palette.navy,
//         borderRadius: pw.BorderRadius.all(pw.Radius.circular(18)),
//       ),
//       child: pw.Text(
//         title.toUpperCase(),
//         style: pw.TextStyle(
//           font: boldFont,
//           fontSize: 11.5,
//           color: _Palette.white,
//           letterSpacing: 0.6,
//         ),
//       ),
//     );
//   }
//
//   pw.Widget infoRow(String label, String value, {bool isLast = false}) {
//     return pw.Column(
//       children: [
//         pw.Padding(
//           padding: const pw.EdgeInsets.symmetric(vertical: 8),
//           child: pw.Row(
//             crossAxisAlignment: pw.CrossAxisAlignment.center,
//             children: [
//               pw.Container(
//                 width: 5,
//                 height: 5,
//                 margin: const pw.EdgeInsets.only(right: 10),
//                 decoration: const pw.BoxDecoration(color: _Palette.gold, shape: pw.BoxShape.circle),
//               ),
//               pw.Expanded(
//                 child: pw.Text(label,
//                     style: pw.TextStyle(fontSize: 10.5, color: _Palette.textSecondary)),
//               ),
//               pw.Text(
//                 value.isEmpty ? '-' : value,
//                 style: pw.TextStyle(font: boldFont, fontSize: 10.5, color: _Palette.textPrimary),
//               ),
//             ],
//           ),
//         ),
//         if (!isLast) pw.Container(height: 0.7, color: _Palette.border),
//       ],
//     );
//   }
//
//   pw.Widget card({required pw.Widget child}) {
//     return pw.Container(
//       width: double.infinity,
//       padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       margin: const pw.EdgeInsets.only(bottom: 16),
//       decoration: pw.BoxDecoration(
//         color: _Palette.white,
//         borderRadius: _radiusMd,
//         border: pw.Border.all(color: _Palette.border, width: 0.8),
//       ),
//       child: child,
//     );
//   }
//
//   pw.Widget chipItem(String label, {required PdfColor fg, required PdfColor bg, required PdfColor border}) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: pw.BoxDecoration(
//         color: bg,
//         borderRadius: _radiusPill,
//         border: pw.Border.all(color: border, width: 0.7),
//       ),
//       child: pw.Row(
//         mainAxisSize: pw.MainAxisSize.min,
//         children: [
//           pw.Container(width: 5, height: 5, decoration: pw.BoxDecoration(color: fg, shape: pw.BoxShape.circle)),
//           pw.SizedBox(width: 5),
//           pw.Text(label, style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: fg)),
//         ],
//       ),
//     );
//   }
//
//   // ---- employment history --------------------------------------------------
//
//   List<StatusEvent> historyEvents() {
//     final events = List<StatusEvent>.from(staff.statusHistory);
//     if (!events.any((e) => e.type == 'joined') &&
//         staff.joiningDate != null &&
//         staff.joiningDate!.isNotEmpty) {
//       events.add(StatusEvent(type: 'joined', date: staff.joiningDate!));
//     }
//     if (!events.any((e) => e.type == 'terminated') && staff.isTerminated) {
//       events.add(StatusEvent(
//         type: 'terminated',
//         date: staff.terminationDate ?? DateTime.now().toIso8601String().split('T').first,
//         note: staff.terminationNote,
//       ));
//     }
//     events.sort((a, b) => a.date.compareTo(b.date));
//     return events;
//   }
//
//   (String, PdfColor) historyStyle(String type) {
//     switch (type) {
//       case 'joined':
//         return ('Joined', _Palette.gold);
//       case 'terminated':
//         return ('Terminated', _Palette.red);
//       case 'rejoined':
//         return ('Rejoined', _Palette.green);
//       default:
//         return (type, _Palette.textMuted);
//     }
//   }
//
//   pw.Widget sidebarHistory() {
//     final events = historyEvents();
//     if (events.isEmpty) return pw.SizedBox();
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: List.generate(events.length, (i) {
//         final e = events[i];
//         final (label, color) = historyStyle(e.type);
//         final isLast = i == events.length - 1;
//         return pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Column(
//               children: [
//                 pw.Container(
//                   width: 7,
//                   height: 7,
//                   decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
//                 ),
//                 if (!isLast) pw.Container(width: 1, height: 24, color: PdfColors.white.shade(0.3)),
//               ],
//             ),
//             pw.SizedBox(width: 7),
//             pw.Expanded(
//               child: pw.Padding(
//                 padding: const pw.EdgeInsets.only(bottom: 10),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(label,
//                         style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: _Palette.white)),
//                     pw.SizedBox(height: 1),
//                     pw.Text(fmtDate(e.date),
//                         style: pw.TextStyle(fontSize: 8, color: PdfColors.white.shade(0.25))),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
//
//   // ---- sidebar (left navy column) ------------------------------------------
//
//   pw.Widget sidebarRow(String label, String value) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 10),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             width: 4,
//             height: 4,
//             margin: const pw.EdgeInsets.only(top: 5, right: 7),
//             decoration: const pw.BoxDecoration(color: _Palette.gold, shape: pw.BoxShape.circle),
//           ),
//           pw.Expanded(
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(label,
//                     style: pw.TextStyle(font: boldFont, fontSize: 9, color: _Palette.white)),
//                 pw.Text(value.isEmpty ? '-' : value,
//                     style: pw.TextStyle(fontSize: 8.5, color: PdfColors.white.shade(0.3))),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   pw.Widget sidebar() {
//     return pw.Container(
//       width: _sidebarWidth,
//       padding: const pw.EdgeInsets.fromLTRB(14, 22, 14, 20),
//       decoration: const pw.BoxDecoration(color: _Palette.navy),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.center,
//         mainAxisSize: pw.MainAxisSize.min,
//         children: [
//           pw.Container(
//             width: 92,
//             height: 92,
//             decoration: pw.BoxDecoration(
//               shape: pw.BoxShape.circle,
//               border: pw.Border.all(color: _Palette.gold, width: 3),
//             ),
//             child: pw.ClipOval(
//               child: avatarImage != null
//                   ? pw.Image(avatarImage, fit: pw.BoxFit.cover, width: 92, height: 92)
//                   : pw.Container(
//                 color: PdfColors.white.shade(0.15),
//                 alignment: pw.Alignment.center,
//                 child: pw.Text(
//                   _initials(staff.name),
//                   style: pw.TextStyle(font: boldFont, fontSize: 26, color: _Palette.white),
//                 ),
//               ),
//             ),
//           ),
//           pw.SizedBox(height: 12),
//           pw.Text(
//             staff.name.toUpperCase(),
//             textAlign: pw.TextAlign.center,
//             style: pw.TextStyle(font: boldFont, fontSize: 13, color: _Palette.white),
//           ),
//           pw.SizedBox(height: 8),
//           pw.Container(width: 36, height: 2, color: _Palette.gold),
//           pw.SizedBox(height: 10),
//           pw.Wrap(
//             alignment: pw.WrapAlignment.center,
//             spacing: 6,
//             runSpacing: 6,
//             children: [
//               pw.Container(
//                 padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.white.shade(0.12),
//                   borderRadius: _radiusPill,
//                   border: pw.Border.all(color: PdfColors.white.shade(0.3), width: 0.6),
//                 ),
//                 child: pw.Text(
//                   staff.type == 'teacher' ? 'Teacher' : 'Staff',
//                   style: pw.TextStyle(font: boldFont, fontSize: 8, color: _Palette.white),
//                 ),
//               ),
//               pw.Container(
//                 padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: pw.BoxDecoration(
//                   color: staff.isTerminated ? _Palette.redBg : _Palette.greenBg,
//                   borderRadius: _radiusPill,
//                 ),
//                 child: pw.Text(
//                   staff.isTerminated ? 'Terminated' : 'Active',
//                   style: pw.TextStyle(
//                     font: boldFont,
//                     fontSize: 8,
//                     color: staff.isTerminated ? _Palette.red : _Palette.green,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 16),
//           pw.Container(height: 1, width: double.infinity, color: PdfColors.white.shade(0.2)),
//           pw.SizedBox(height: 14),
//           sidebarRow('CNIC', staff.cnic),
//           sidebarRow('Phone', staff.phone),
//           sidebarRow('Joined', fmtDate(staff.joiningDate)),
//           sidebarRow('Employment Type', staff.employmentType),
//           if (historyEvents().length > 1) ...[
//             pw.SizedBox(height: 4),
//             pw.Container(height: 1, width: double.infinity, color: PdfColors.white.shade(0.2)),
//             pw.SizedBox(height: 12),
//             pw.Align(
//               alignment: pw.Alignment.centerLeft,
//               child: pw.Text('EMPLOYMENT HISTORY',
//                   style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: _Palette.gold, letterSpacing: 0.5)),
//             ),
//             pw.SizedBox(height: 10),
//             sidebarHistory(),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ---- top header -----------------------------------------------------------
//
//   pw.Widget topHeader() {
//     return pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.center,
//       children: [
//         if (schoolLogo != null)
//           pw.Container(
//             width: 42,
//             height: 42,
//             margin: const pw.EdgeInsets.only(right: 10),
//             child: pw.Image(schoolLogo, fit: pw.BoxFit.contain),
//           ),
//         pw.Expanded(
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Row(
//                 crossAxisAlignment: pw.CrossAxisAlignment.end,
//                 children: [
//                   pw.Text('STAFF ', style: pw.TextStyle(font: boldFont, fontSize: 20, color: _Palette.navy)),
//                   pw.Text('PROFILE', style: pw.TextStyle(font: boldFont, fontSize: 20, color: _Palette.gold)),
//                 ],
//               ),
//               pw.SizedBox(height: 2),
//               pw.Text(
//                 schoolName.toUpperCase(),
//                 style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: _Palette.textSecondary, letterSpacing: 1),
//               ),
//             ],
//           ),
//         ),
//         pw.Container(
//           padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//           decoration: const pw.BoxDecoration(
//             color: _Palette.navy,
//             borderRadius: _radiusPill,
//           ),
//           child: pw.Text(
//             fmtDate(DateTime.now().toIso8601String()),
//             style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: _Palette.white),
//           ),
//         ),
//       ],
//     );
//   }
//
//   pw.Widget footer() {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Container(height: 1.2, color: _Palette.gold, margin: const pw.EdgeInsets.only(bottom: 12)),
//         pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.center,
//           children: [
//             pw.BarcodeWidget(
//               barcode: pw.Barcode.qrCode(),
//               data: 'Staff: ${staff.name} | CNIC: ${staff.cnic} | $schoolName',
//               width: 40,
//               height: 40,
//               color: _Palette.navy,
//             ),
//             pw.SizedBox(width: 10),
//             pw.Expanded(
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text('Developed by Ali Haider',
//                       style: pw.TextStyle(font: boldFont, fontSize: 10, color: _Palette.navy)),
//                   pw.SizedBox(height: 2),
//                   pw.Text('0300-7465064',
//                       style: pw.TextStyle(fontSize: 9, color: _Palette.textSecondary)),
//                 ],
//               ),
//             ),
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.end,
//               children: [
//                 pw.Container(
//                   width: 110,
//                   height: 0.8,
//                   color: _Palette.textMuted,
//                   margin: const pw.EdgeInsets.only(bottom: 4),
//                 ),
//                 pw.Text('Authorized Signature',
//                     style: pw.TextStyle(fontSize: 8.5, color: _Palette.textSecondary)),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // ---- main content sections (right column) ---------------------------------
//
//   final mainContent = <pw.Widget>[
//     topHeader(),
//     pw.SizedBox(height: 16),
//     sectionBanner('Personal Information'),
//     card(
//       child: pw.Column(
//         children: [
//           infoRow('Father / Husband', staff.fatherOrHusbandName),
//           infoRow('CNIC', staff.cnic),
//           infoRow('Date of Birth', fmtDate(staff.dob)),
//           infoRow('Gender', staff.gender),
//           infoRow('Marital Status', staff.maritalStatus),
//           infoRow('Blood Group', staff.bloodGroup ?? '-'),
//           infoRow('Religion', staff.religion),
//           infoRow('Nationality', staff.nationality, isLast: true),
//         ],
//       ),
//     ),
//     sectionBanner('Contact Information'),
//     card(
//       child: pw.Column(
//         children: [
//           infoRow('Address', staff.address),
//           infoRow('Phone', staff.phone),
//           infoRow('Emergency', staff.emergencyPhone, isLast: true),
//         ],
//       ),
//     ),
//     sectionBanner('Job Details'),
//     card(
//       child: pw.Column(
//         children: [
//           infoRow('Employment Type', staff.employmentType),
//           infoRow(
//             'Salary',
//             '${school?.currency.isNotEmpty ?? false ? school!.currency : "PKR"} ${_formatMoney(staff.salary)}',
//             isLast: staff.reference == null || staff.reference!.isEmpty,
//           ),
//           if (staff.reference != null && staff.reference!.isNotEmpty)
//             infoRow('Reference', staff.reference!, isLast: true),
//         ],
//       ),
//     ),
//     if (staff.subjects.isNotEmpty) ...[
//       sectionBanner('Assigned Subjects'),
//       card(
//         child: pw.Padding(
//           padding: const pw.EdgeInsets.symmetric(vertical: 12),
//           child: pw.Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: staff.subjects
//                 .map((s) => chipItem(s, fg: _Palette.navy, bg: _Palette.surface, border: _Palette.navy))
//                 .toList(),
//           ),
//         ),
//       ),
//     ],
//     if (staff.assignedClasses.isNotEmpty) ...[
//       sectionBanner('Assigned Classes'),
//       card(
//         child: pw.Padding(
//           padding: const pw.EdgeInsets.symmetric(vertical: 12),
//           child: pw.Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: staff.assignedClasses
//                 .map((id) => chipItem(classIdToName[id] ?? id,
//                 fg: _Palette.green, bg: _Palette.greenBg, border: _Palette.greenBg))
//                 .toList(),
//           ),
//         ),
//       ),
//     ],
//     if (staff.note != null && staff.note!.isNotEmpty) ...[
//       sectionBanner('Notes'),
//       pw.Container(
//         width: double.infinity,
//         padding: const pw.EdgeInsets.all(14),
//         margin: const pw.EdgeInsets.only(bottom: 16),
//         decoration: pw.BoxDecoration(
//           color: _Palette.goldLight,
//           borderRadius: _radiusMd,
//           border: pw.Border.all(color: _Palette.gold, width: 0.8),
//         ),
//         child: pw.Text(
//           staff.note!,
//           style: pw.TextStyle(fontSize: 10.5, color: _Palette.navyDark, lineSpacing: 2),
//         ),
//       ),
//     ],
//     footer(),
//   ];
//
//   // ---- page: MultiPage lets this paginate correctly instead of overflowing
//   // and corrupting the layout the way a single fixed `pw.Page` did.
//   pdf.addPage(
//     pw.MultiPage(
//       theme: theme,
//       pageFormat: PdfPageFormat.a4,
//       margin: pw.EdgeInsets.zero,
//       header: (context) => pw.SizedBox(),
//       build: (context) => [
//         pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             sidebar(),
//             pw.SizedBox(width: 16),
//             pw.Expanded(
//               child: pw.Padding(
//                 padding: const pw.EdgeInsets.fromLTRB(0, 20, 20, 20),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: mainContent,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
//
//   return pdf.save();
// }
//
// // ----------------------------------------------------------------------
// // small internal helpers
// // ----------------------------------------------------------------------
// String _initials(String name) {
//   final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
//   if (parts.isEmpty) return '?';
//   if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//   return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
// }
//
// String _formatMoney(num value) {
//   final s = value.toStringAsFixed(0);
//   final buffer = StringBuffer();
//   final reversed = s.split('').reversed.toList();
//   for (var i = 0; i < reversed.length; i++) {
//     buffer.write(reversed[i]);
//     final posFromEnd = i + 1;
//     if (posFromEnd == 3 || (posFromEnd > 3 && (posFromEnd - 3) % 2 == 0)) {
//       if (i != reversed.length - 1) buffer.write(',');
//     }
//   }
//   return buffer.toString().split('').reversed.join();
// }
//
// // ----------------------------------------------------------------------
// // 2) Cross-platform save + auto-open helper
// // ----------------------------------------------------------------------
// class PdfUtils {
//   static Future<void> saveAndOpenPdf(Uint8List bytes, String fileName) async {
//     if (kIsWeb) {
//       await Printing.sharePdf(bytes: bytes, filename: fileName);
//       return;
//     }
//
//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final path = '${dir.path}/$fileName';
//       final file = File(path);
//       await file.writeAsBytes(bytes, flush: true);
//
//       final result = await OpenFile.open(path);
//
//       if (result.type != ResultType.done) {
//         await Printing.sharePdf(bytes: bytes, filename: fileName);
//       }
//     } catch (e) {
//       debugPrint('PdfUtils.saveAndOpenPdf failed, falling back to share: $e');
//       await Printing.sharePdf(bytes: bytes, filename: fileName);
//     }
//   }
// }


import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/school_setting_model.dart';
import '../../models/teacher.dart';

Future<Uint8List> generateStaffProfilePdf(
    StaffMember staff,
    Map<String, String> classIdToName, {
      required SchoolSettings school,
    }) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          // Header
          pw.Row(
            children: [
              pw.Container(
                width: 100,
                height: 100,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColors.grey300,
                  image: school.logoBase64 != null
                      ? pw.DecorationImage(
                      image: pw.MemoryImage(base64Decode(school.logoBase64!)))
                      : null,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('STAFF PROFILE',
                      style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange)),
                  pw.Text('STAFF DETAILS SUMMARY',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Sidebar and Main Content
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Sidebar (Left)
              pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 120,
                      width: 120,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.white,
                        image: staff.imageBase64 != null
                            ? pw.DecorationImage(
                            image: pw.MemoryImage(base64Decode(staff.imageBase64!)))
                            : null,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(staff.name,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: pw.BoxDecoration(
                          color: PdfColors.green, borderRadius: pw.BorderRadius.circular(20)),
                      child: pw.Text('Active',
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('📞 ${staff.phone}',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                    pw.Text('📅 Joined: ${staff.joiningDate ?? '--'}',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),

              // Main Content (Right)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Row(
                              children: [
                                pw.Icon(pw.IconData(0xe853), color: PdfColors.blue, size: 20),
                                pw.SizedBox(width: 8),
                                pw.Text('PERSONAL INFORMATION',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                          pw.Divider(color: PdfColors.grey300),

                          // ✅ درست Table (Error کے بغیر)
                          pw.Table.fromTextArray(
                            border: pw.TableBorder.all(color: PdfColors.grey100, width: 0.5),
                            headerStyle: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black),
                            headers: ['Label', 'Value'],
                            data: [
                              ['Father / Husband', staff.fatherOrHusbandName],
                              ['CNIC', staff.cnic],
                              ['Date of Birth', staff.dob],
                              ['Gender', staff.gender],
                              ['Marital Status', staff.maritalStatus],
                              ['Blood Group', staff.bloodGroup ?? '-'],
                              ['Religion', staff.religion],
                              ['Nationality', staff.nationality],
                            ],
                            // ✅ columns: اور TableColumn کی بجائے columnWidths استعمال کریں
                            columnWidths: {
                              0: const pw.FixedColumnWidth(120),
                              1: const pw.FixedColumnWidth(200),
                            },
                          ),
                        ],
                      ),
                    ),
                    // ... اسی طرح Contact اور Job Details بھی لکھیں
                  ],
                ),
              ),
            ],
          ),
        ];
      },
    ),
  );

  return pdf.save(); // ✅ اب یہ صحیح طور پر Future<Uint8List> ریٹرن کرے گا
}