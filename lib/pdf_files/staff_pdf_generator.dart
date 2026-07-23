//
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart' as pw_fonts;
//
// import '../../models/teacher.dart';
// import '../../models/employee_trasaction_model.dart';   // ← new import for transactions
//
// // ─────────────────────────────────────────────────────────────────────────
// // Color palette (unchanged)
// // ─────────────────────────────────────────────────────────────────────────
// const _navy = PdfColor.fromInt(0xFF0F1E3D);
// const _navyDark = PdfColor.fromInt(0xFF0A1530);
// const _blue = PdfColor.fromInt(0xFF2563EB);
// const _blueLight = PdfColor.fromInt(0xFFEFF4FF);
// const _green = PdfColor.fromInt(0xFF16A34A);
// const _greenLight = PdfColor.fromInt(0xFFE8F5E9);
// const _red = PdfColor.fromInt(0xFFDC2626);
// const _redLight = PdfColor.fromInt(0xFFFEF2F2);
// const _grey900 = PdfColor.fromInt(0xFF1A1A2E);
// const _grey500 = PdfColor.fromInt(0xFF888899);
// const _grey200 = PdfColor.fromInt(0xFFEEEEF5);
// const _grey100 = PdfColor.fromInt(0xFFF5F5FA);
// const _white = PdfColors.white;
//
// // Category colours & icons
// const _kCategoryIcons = <String, int>{
//   'Advance': 0xe3a3,           // payments_outlined
//   'Loan': 0xe3a0,              // account_balance_outlined
//   'Expense': 0xe8b6,           // receipt_long_outlined
//   'Fine': 0xe8e6,              // gavel_outlined
//   'Reimbursement': 0xe95c,     // assignment_return_outlined
//   'Others': 0xe5d4,            // more_horiz_rounded
// };
//
// const _kCategoryColors = <String, PdfColor>{
//   'Advance': PdfColor.fromInt(0xFF185FA5),
//   'Loan': PdfColor.fromInt(0xFF854F0B),
//   'Expense': PdfColor.fromInt(0xFF993C1D),
//   'Fine': PdfColor.fromInt(0xFF993556),
//   'Reimbursement': PdfColor.fromInt(0xFF0F6E56),
//   'Others': PdfColor.fromInt(0xFF5F5E5A),
// };
//
// String _fmtDate(String? iso) {
//   if (iso == null || iso.isEmpty) return '--';
//   try {
//     final d = DateTime.parse(iso);
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return '${d.day} ${months[d.month - 1]} ${d.year}';
//   } catch (_) {
//     return iso;
//   }
// }
//
// String _initials(String name) {
//   final parts = name.trim().split(' ');
//   if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
//     return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//   }
//   if (parts.isNotEmpty && parts[0].isNotEmpty) {
//     return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
//   }
//   return '?';
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
// String _formatTransactionDate(DateTime date) {
//   const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//   return '${date.day} ${months[date.month - 1]} ${date.year}';
// }
//
// List<StatusEvent> _buildHistoryEvents(StaffMember staff) {
//   final events = List<StatusEvent>.from(staff.statusHistory);
//   final hasJoined = events.any((e) => e.type == 'joined');
//   if (!hasJoined && staff.joiningDate != null && staff.joiningDate!.isNotEmpty) {
//     events.add(StatusEvent(type: 'joined', date: staff.joiningDate!));
//   }
//   if (staff.terminationDate != null && staff.terminationDate!.isNotEmpty) {
//     final hasTerminatedEvent = events.any((e) => e.type == 'terminated' && e.date == staff.terminationDate);
//     if (!hasTerminatedEvent && staff.isTerminated) {
//       events.add(StatusEvent(type: 'terminated', date: staff.terminationDate!, note: staff.terminationNote));
//     }
//   }
//   if (!staff.isTerminated && staff.isActive) {
//     final terminatedEvents = events.where((e) => e.type == 'terminated').toList();
//     final rejoinedEvents = events.where((e) => e.type == 'rejoined').toList();
//     if (terminatedEvents.isNotEmpty && rejoinedEvents.isEmpty) {
//       terminatedEvents.sort((a, b) => b.date.compareTo(a.date));
//       final lastTerminationDate = terminatedEvents.first.date;
//       final rejoiningDate = DateTime.now().toIso8601String().split('T').first;
//       if (rejoiningDate.compareTo(lastTerminationDate) >= 0) {
//         events.add(StatusEvent(type: 'rejoined', date: rejoiningDate, note: 'Rejoined (auto-detected)'));
//       }
//     }
//   }
//   events.sort((a, b) => a.date.compareTo(b.date));
//   return events;
// }
//
// class _FontCache {
//   static pw.Font? _iconFont;
//   static Future<pw.Font> get iconFont async {
//     if (_iconFont != null) return _iconFont!;
//     _iconFont = await pw_fonts.PdfGoogleFonts.materialIconsRegular();
//     return _iconFont!;
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────
// // ★ UPDATED: now accepts optional transactions list
// // ─────────────────────────────────────────────────────────────────────────
// Future<Uint8List> generateStaffProfilePdf(
//     StaffMember staff,
//     Map<String, String> classIdToName, {
//       List<StaffTransaction>? transactions,   // ← new parameter
//     }) async
// {
//   final pdf = pw.Document();
//   final historyEvents = _buildHistoryEvents(staff);
//   final isTeacher = staff.type == 'teacher';
//
//   final regularFont = pw.Font.helvetica();
//   final boldFont = pw.Font.helveticaBold();
//   final decorativeFont = pw.Font.timesBold();
//   final iconFont = await _FontCache.iconFont;
//
//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       margin: const pw.EdgeInsets.all(0),
//       build: (pw.Context context) {
//         return pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//           children: [
//             // ── Sidebar ────────────────────────────────────────────────
//             pw.Container(
//               width: 155,
//               padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 20),
//               decoration: const pw.BoxDecoration(color: _navy),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.center,
//                 children: [
//                   // Avatar
//                   pw.Container(
//                     width: 80,
//                     height: 80,
//                     decoration: pw.BoxDecoration(
//                       shape: pw.BoxShape.circle,
//                       color: PdfColors.blueGrey800,
//                       border: pw.Border.all(color: _white, width: 2.5),
//                       image: staff.imageBase64 != null
//                           ? pw.DecorationImage(
//                         image: pw.MemoryImage(base64Decode(staff.imageBase64!)),
//                         fit: pw.BoxFit.cover,
//                       )
//                           : null,
//                     ),
//                     child: staff.imageBase64 == null
//                         ? pw.Center(
//                       child: pw.Text(
//                         _initials(staff.name),
//                         style: pw.TextStyle(fontSize: 26, font: boldFont, color: _white),
//                       ),
//                     )
//                         : null,
//                   ),
//                   pw.SizedBox(height: 10),
//
//                   // Name
//                   pw.Text(
//                     staff.name,
//                     textAlign: pw.TextAlign.center,
//                     maxLines: 2,
//                     style: pw.TextStyle(
//                       fontSize: 13,
//                       font: boldFont,
//                       color: _white,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//
//                   if (staff.designation != null && staff.designation!.trim().isNotEmpty)
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.only(top: 4),
//                       child: pw.Text(
//                         staff.designation!,
//                         textAlign: pw.TextAlign.center,
//                         maxLines: 1,
//                         style: pw.TextStyle(
//                           fontSize: 9,
//                           font: regularFont,
//                           color: PdfColors.grey400,
//                         ),
//                       ),
//                     ),
//
//                   pw.SizedBox(height: 10),
//
//                   // Status pills
//                   pw.Wrap(
//                     alignment: pw.WrapAlignment.center,
//                     spacing: 6,
//                     runSpacing: 6,
//                     children: [
//                       _pill(text: staff.isTerminated ? 'Terminated' : 'Active',
//                           bg: staff.isTerminated ? _red : _green,
//                           fg: _white, font: boldFont),
//                       _pill(text: isTeacher ? 'Teacher' : 'Staff',
//                           bg: PdfColors.blueGrey700, fg: _white, font: boldFont),
//                     ],
//                   ),
//                   pw.SizedBox(height: 14),
//                   pw.Divider(color: PdfColors.blueGrey700, thickness: 0.7),
//                   pw.SizedBox(height: 10),
//
//                   // ── Sidebar: CNIC only (Registered removed) ──
//                   _sidebarInfoBlock(const pw.IconData(0xe853), 'CNIC', staff.cnic,
//                       iconFont: iconFont, regularFont: regularFont, boldFont: boldFont),
//                   pw.SizedBox(height: 14),
//
//                   // ── Employment history ──
//                   pw.Container(
//                     width: double.infinity,
//                     padding: const pw.EdgeInsets.all(8),
//                     decoration: pw.BoxDecoration(
//                       color: _navyDark,
//                       borderRadius: pw.BorderRadius.circular(8),
//                       border: pw.Border.all(color: PdfColors.blueGrey700, width: 0.6),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text('EMPLOYMENT HISTORY',
//                             style: pw.TextStyle(fontSize: 8, font: boldFont,
//                                 color: PdfColors.grey400, letterSpacing: 0.4)),
//                         pw.SizedBox(height: 6),
//                         ...historyEvents.asMap().entries.map((entry) {
//                           return _historyTile(
//                             entry.value,
//                             entry.key == historyEvents.length - 1,
//                             boldFont: boldFont,
//                             regularFont: regularFont,
//                           );
//                         }),
//                       ],
//                     ),
//                   ),
//                   pw.SizedBox(height: 12),
//
//                   // ── NEW: Transaction History (if available) ──
//                   if (transactions != null && transactions.isNotEmpty)
//                     _transactionHistoryBlock(
//                       transactions: transactions,
//                       iconFont: iconFont,
//                       boldFont: boldFont,
//                       regularFont: regularFont,
//                     ),
//                 ],
//               ),
//             ),
//
//             // ── Main content ─────────────────────────────────────────
//             pw.Expanded(
//               child: pw.Padding(
//                 padding: const pw.EdgeInsets.fromLTRB(18, 20, 18, 20),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     pw.Row(
//                       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text('STAFF PROFILE',
//                                 style: pw.TextStyle(fontSize: 20,
//                                     font: decorativeFont, color: _navy)),
//                             pw.SizedBox(height: 3),
//                             pw.Container(width: 50, height: 1.5, color: _blue),
//                           ],
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 4),
//
//                     if (staff.isTerminated) ...[
//                       _terminatedBanner(staff, font: regularFont, boldFont: boldFont),
//                       pw.SizedBox(height: 4),
//                     ],
//
//                     // Personal Information (without CNIC)
//                     _sectionCard(
//                       icon: const pw.IconData(0xe853), iconFont: iconFont,
//                       iconColor: _blue, iconBg: _blueLight,
//                       title: 'PERSONAL INFORMATION',
//                       font: regularFont, boldFont: boldFont,
//                       rows: [
//                         _row('Father / Husband', staff.fatherOrHusbandName),
//                         _row('Date of Birth', _fmtDate(staff.dob)),
//                         _row('Gender', staff.gender),
//                         _row('Marital Status', staff.maritalStatus),
//                         _row('Blood Group', staff.bloodGroup ?? '–'),
//                         _row('Religion', staff.religion),
//                         _row('Nationality', staff.nationality),
//                       ],
//                     ),
//                     pw.SizedBox(height: 4),
//
//                     _sectionCard(
//                       icon: const pw.IconData(0xe0b0), iconFont: iconFont,
//                       iconColor: _blue, iconBg: _blueLight,
//                       title: 'CONTACT INFORMATION',
//                       font: regularFont, boldFont: boldFont,
//                       rows: [
//                         _row('Address', staff.address),
//                         _row('Phone', staff.phone),
//                         _row('Emergency', staff.emergencyPhone),
//                       ],
//                     ),
//                     pw.SizedBox(height: 4),
//
//                     _sectionCard(
//                       icon: const pw.IconData(0xe8f9), iconFont: iconFont,
//                       iconColor: _blue, iconBg: _blueLight,
//                       title: 'JOB DETAILS',
//                       font: regularFont, boldFont: boldFont,
//                       rows: [
//                         _row('Employment Type', staff.employmentType),
//                         _row('Salary', 'PKR ${_formatMoney(staff.salary)}',
//                             highlight: true),
//                         if (staff.reference != null && staff.reference!.isNotEmpty)
//                           _row('Reference', staff.reference!),
//                       ],
//                     ),
//
//                     if (staff.subjects.isNotEmpty) ...[
//                       pw.SizedBox(height: 4),
//                       _chipCard(
//                         icon: const pw.IconData(0xe80c), iconFont: iconFont,
//                         iconColor: const PdfColor.fromInt(0xFF534AB7),
//                         iconBg: const PdfColor.fromInt(0xFFF0EFFE),
//                         title: 'ASSIGNED SUBJECTS',
//                         count: staff.subjects.length,
//                         chipColor: const PdfColor.fromInt(0xFF534AB7),
//                         chipBg: const PdfColor.fromInt(0xFFF0EFFE),
//                         labels: staff.subjects,
//                         font: regularFont, boldFont: boldFont,
//                       ),
//                     ],
//
//                     if (staff.assignedClasses.isNotEmpty) ...[
//                       pw.SizedBox(height: 4),
//                       _chipCard(
//                         icon: const pw.IconData(0xe86f), iconFont: iconFont,
//                         iconColor: _green, iconBg: _greenLight,
//                         title: 'ASSIGNED CLASSES',
//                         count: staff.assignedClasses.length,
//                         chipColor: _green, chipBg: _greenLight,
//                         labels: staff.assignedClasses
//                             .map((id) => classIdToName[id] ?? id)
//                             .toList(),
//                         font: regularFont, boldFont: boldFont,
//                       ),
//                     ],
//
//                     if (staff.note != null && staff.note!.isNotEmpty) ...[
//                       pw.SizedBox(height: 4),
//                       _noteCard(staff.note!, font: regularFont, boldFont: boldFont),
//                     ],
//
//                     pw.Spacer(),
//
//                     // Centred footer
//                     pw.Center(
//                       child: pw.Text(
//                         'Developed by Ali Haider | 0300-7465064',
//                         style: pw.TextStyle(
//                           fontSize: 8.5,
//                           font: regularFont,
//                           color: PdfColors.grey600,
//                         ),
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     ),
//   );
//
//   return pdf.save();
// }
//
// // ─────────────────────────────────────────────────────────────────────────
// // NEW: Transaction history block in sidebar
// // ─────────────────────────────────────────────────────────────────────────
// pw.Widget _transactionHistoryBlock({
//   required List<StaffTransaction> transactions,
//   required pw.Font iconFont,
//   required pw.Font boldFont,
//   required pw.Font regularFont,
// })
// {
//   // Sort by date descending (most recent first)
//   final sorted = List<StaffTransaction>.from(transactions)
//     ..sort((a, b) => b.date.compareTo(a.date));
//   // Limit to last 10 to avoid overflow
//   final display = sorted.take(10).toList();
//
//   return pw.Container(
//     width: double.infinity,
//     padding: const pw.EdgeInsets.all(8),
//     decoration: pw.BoxDecoration(
//       color: _navyDark,
//       borderRadius: pw.BorderRadius.circular(8),
//       border: pw.Border.all(color: PdfColors.blueGrey700, width: 0.6),
//     ),
//     child: pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text('TRANSACTION HISTORY',
//             style: pw.TextStyle(fontSize: 8, font: boldFont,
//                 color: PdfColors.grey400, letterSpacing: 0.4)),
//         pw.SizedBox(height: 6),
//         ...display.map((txn) => _transactionTile(txn, iconFont: iconFont, regularFont: regularFont, boldFont: boldFont)),
//       ],
//     ),
//   );
// }
//
// pw.Widget _transactionTile(
//     StaffTransaction txn, {
//       required pw.Font iconFont,
//       required pw.Font regularFont,
//       required pw.Font boldFont,
//     })
// {
//   final catIconCode = _kCategoryIcons[txn.category] ?? 0xe5d4; // more_horiz as fallback
//   final catColor = _kCategoryColors[txn.category] ?? PdfColors.grey400;
//   final dateStr = _formatTransactionDate(txn.date);
//   final amountStr = 'Rs ${_formatMoney(txn.amount)}';
//
//   return pw.Padding(
//     padding: const pw.EdgeInsets.only(bottom: 6),
//     child: pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         // Left icon column
//         pw.Column(
//           children: [
//             pw.Container(
//               width: 14, height: 14,
//               decoration: pw.BoxDecoration(
//                 color: catColor.withAlpha(80),
//                 shape: pw.BoxShape.circle,
//               ),
//               child: pw.Center(
//                 child: pw.Icon(
//                   pw.IconData(catIconCode),
//                   font: iconFont,
//                   size: 8,
//                   color: catColor,
//                 ),
//               ),
//             ),
//             // Small line separator between items (not between last)
//             if (false) pw.Container(width: 1, height: 10, color: PdfColors.grey500), // not needed with padding separation
//           ],
//         ),
//         pw.SizedBox(width: 6),
//         pw.Expanded(
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Expanded(
//                     child: pw.Text(
//                       txn.displayCategory,
//                       style: pw.TextStyle(fontSize: 8, font: boldFont, color: _white),
//                       maxLines: 1,
//                       overflow: pw.TextOverflow.clip,   // ← FIXED
//                     ),
//                   ),
//                   pw.Text(
//                     amountStr,
//                     style: pw.TextStyle(fontSize: 8, font: boldFont, color: _white),
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 2),
//               pw.Text(
//                 dateStr,
//                 style: pw.TextStyle(fontSize: 7, font: regularFont, color: PdfColors.grey500),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────
// // Existing helpers (unchanged except minor adjustments)
// // ─────────────────────────────────────────────────────────────────────────
// pw.Widget _pill({required String text, required PdfColor bg, required PdfColor fg, required pw.Font font}) {
//   return pw.Container(
//     padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//     decoration: pw.BoxDecoration(color: bg, borderRadius: pw.BorderRadius.circular(20)),
//     child: pw.Text(text, style: pw.TextStyle(fontSize: 7.5, font: font, color: fg)),
//   );
// }
//
// pw.Widget _sidebarInfoBlock(pw.IconData icon, String label, String value,
//     {required pw.Font iconFont, required pw.Font regularFont, required pw.Font boldFont}) {
//   return pw.Row(
//     crossAxisAlignment: pw.CrossAxisAlignment.start,
//     children: [
//       pw.Container(
//         width: 18, height: 18,
//         decoration: pw.BoxDecoration(color: PdfColors.blueGrey700, borderRadius: pw.BorderRadius.circular(4)),
//         child: pw.Center(child: pw.Icon(icon, font: iconFont, size: 9, color: _white)),
//       ),
//       pw.SizedBox(width: 6),
//       pw.Expanded(
//         child: pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(label, style: pw.TextStyle(fontSize: 7, font: regularFont, color: PdfColors.grey500)),
//             pw.SizedBox(height: 1),
//             pw.Text(value, style: pw.TextStyle(fontSize: 8, font: boldFont, color: _white)),
//           ],
//         ),
//       ),
//     ],
//   );
// }
//
// pw.Widget _historyTile(StatusEvent e, bool isLast, {required pw.Font boldFont, required pw.Font regularFont}) {
//   late final String label;
//   late final PdfColor color;
//   switch (e.type) {
//     case 'joined': label = 'Joined'; color = _blue; break;
//     case 'terminated': label = 'Terminated'; color = _red; break;
//     case 'rejoined': label = 'Rejoined'; color = _green; break;
//     default: label = e.type; color = PdfColors.grey400;
//   }
//   return pw.Padding(
//     padding: const pw.EdgeInsets.only(bottom: 6),
//     child: pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Column(children: [
//           pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)),
//           if (!isLast) pw.Container(width: 1, height: 18, color: PdfColors.grey500),
//         ]),
//         pw.SizedBox(width: 6),
//         pw.Expanded(
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(label, style: pw.TextStyle(fontSize: 8, font: boldFont, color: _white)),
//               pw.Text(_fmtDate(e.date), style: pw.TextStyle(fontSize: 7, font: regularFont, color: PdfColors.grey500)),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// pw.Widget _terminatedBanner(StaffMember staff, {required pw.Font font, required pw.Font boldFont}) {
//   return pw.Container(
//     width: double.infinity,
//     padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     decoration: pw.BoxDecoration(
//       color: _redLight,
//       borderRadius: pw.BorderRadius.circular(6),
//       border: pw.Border.all(color: _red, width: 0.6),
//     ),
//     child: pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text('Deactivated / Terminated',
//             style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _red)),
//         if (staff.terminationDate != null && staff.terminationDate!.isNotEmpty)
//           pw.Text('Terminated on: ${_fmtDate(staff.terminationDate)}',
//               style: pw.TextStyle(fontSize: 8.5, font: font, color: PdfColors.grey700)),
//         if (staff.terminationNote != null && staff.terminationNote!.isNotEmpty)
//           pw.Text('Note: ${staff.terminationNote}',
//               style: pw.TextStyle(fontSize: 8, font: font, color: PdfColors.grey600)),
//       ],
//     ),
//   );
// }
//
// class _KV { final String label; final String value; final bool highlight; _KV(this.label, this.value, {this.highlight = false}); }
// _KV _row(String label, String value, {bool highlight = false}) => _KV(label, value, highlight: highlight);
//
// pw.Widget _sectionCard({
//   required pw.IconData icon, required pw.Font iconFont,
//   required PdfColor iconColor, required PdfColor iconBg,
//   required String title, required List<_KV> rows,
//   required pw.Font font, required pw.Font boldFont,
// }) {
//   return pw.Container(
//     width: double.infinity,
//     decoration: pw.BoxDecoration(
//       color: _white,
//       borderRadius: pw.BorderRadius.circular(8),
//       border: pw.Border.all(color: _grey200, width: 0.7),
//     ),
//     child: pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Padding(
//           padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 6),
//           child: pw.Row(
//             children: [
//               pw.Container(
//                 width: 18, height: 18,
//                 decoration: pw.BoxDecoration(color: iconColor, shape: pw.BoxShape.circle),
//                 child: pw.Center(child: pw.Icon(icon, font: iconFont, size: 9, color: _white)),
//               ),
//               pw.SizedBox(width: 6),
//               pw.Text(title,
//                   style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _grey900)),
//             ],
//           ),
//         ),
//         pw.Divider(height: 1, color: _grey100, thickness: 0.8),
//         ...rows.asMap().entries.map((entry) {
//           final i = entry.key; final r = entry.value; final isLast = i == rows.length - 1;
//           return pw.Column(
//             children: [
//               pw.Padding(
//                 padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text(r.label,
//                         style: pw.TextStyle(fontSize: 8.5, font: font, color: _grey500)),
//                     pw.Text(r.value,
//                         style: pw.TextStyle(
//                           fontSize: 9,
//                           font: r.highlight ? boldFont : font,
//                           color: r.highlight ? _blue : _grey900,
//                         )),
//                   ],
//                 ),
//               ),
//               if (!isLast) pw.Divider(height: 1, indent: 12, endIndent: 12, color: _grey100),
//             ],
//           );
//         }),
//       ],
//     ),
//   );
// }
//
// pw.Widget _chipCard({
//   required pw.IconData icon, required pw.Font iconFont,
//   required PdfColor iconColor, required PdfColor iconBg,
//   required String title, required int count,
//   required PdfColor chipColor, required PdfColor chipBg,
//   required List<String> labels, required pw.Font font, required pw.Font boldFont,
// }) {
//   return pw.Container(
//     width: double.infinity,
//     padding: const pw.EdgeInsets.all(12),
//     decoration: pw.BoxDecoration(
//       color: _white,
//       borderRadius: pw.BorderRadius.circular(8),
//       border: pw.Border.all(color: _grey200, width: 0.7),
//     ),
//     child: pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Row(
//           children: [
//             pw.Container(
//               width: 18, height: 18,
//               decoration: pw.BoxDecoration(color: iconColor, shape: pw.BoxShape.circle),
//               child: pw.Center(child: pw.Icon(icon, font: iconFont, size: 9, color: _white)),
//             ),
//             pw.SizedBox(width: 6),
//             pw.Text(title,
//                 style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _grey900)),
//             pw.Spacer(),
//             pw.Container(
//               padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: pw.BoxDecoration(
//                 color: chipBg, borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.Text('$count',
//                   style: pw.TextStyle(fontSize: 8, font: boldFont, color: chipColor)),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 8),
//         pw.Wrap(
//           spacing: 5, runSpacing: 5,
//           children: labels.map((label) => pw.Container(
//             padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: pw.BoxDecoration(
//               color: chipBg,
//               borderRadius: pw.BorderRadius.circular(16),
//               border: pw.Border.all(color: chipColor, width: 0.6),
//             ),
//             child: pw.Text(label,
//                 style: pw.TextStyle(fontSize: 8, font: boldFont, color: chipColor)),
//           )).toList(),
//         ),
//       ],
//     ),
//   );
// }
//
// pw.Widget _noteCard(String note, {required pw.Font font, required pw.Font boldFont}) {
//   return pw.Container(
//     width: double.infinity,
//     padding: const pw.EdgeInsets.all(12),
//     decoration: pw.BoxDecoration(
//       color: PdfColor.fromInt(0xFFFFFBEB),
//       borderRadius: pw.BorderRadius.circular(8),
//       border: pw.Border.all(color: PdfColor.fromInt(0xFFFDE68A), width: 0.7),
//     ),
//     child: pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text('NOTES',
//             style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: PdfColor.fromInt(0xFF92400E))),
//         pw.SizedBox(height: 5),
//         pw.Text(note,
//             style: pw.TextStyle(fontSize: 8.5, font: font, color: PdfColor.fromInt(0xFF78350F))),
//       ],
//     ),
//   );
// }
//
//


import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as pw_fonts;

import '../../../models/teacher.dart';
import '../../../models/salary_adjustment_history.dart'; // SalaryHistory model

// ─────────────────────────────────────────────────────────────────────────
// Color palette
// ─────────────────────────────────────────────────────────────────────────
const _navy = PdfColor.fromInt(0xFF0F1E3D);
const _navyDark = PdfColor.fromInt(0xFF0A1530);
const _blue = PdfColor.fromInt(0xFF2563EB);
const _blueLight = PdfColor.fromInt(0xFFEFF4FF);
const _green = PdfColor.fromInt(0xFF16A34A);
const _greenLight = PdfColor.fromInt(0xFFE8F5E9);
const _red = PdfColor.fromInt(0xFFDC2626);
const _redLight = PdfColor.fromInt(0xFFFEF2F2);
const _grey900 = PdfColor.fromInt(0xFF1A1A2E);
const _grey500 = PdfColor.fromInt(0xFF888899);
const _grey200 = PdfColor.fromInt(0xFFEEEEF5);
const _grey100 = PdfColor.fromInt(0xFFF5F5FA);
const _white = PdfColors.white;

String _fmtDate(String? iso) {
  if (iso == null || iso.isEmpty) return '--';
  try {
    final d = DateTime.parse(iso);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  } catch (_) {
    return iso;
  }
}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  if (parts.isNotEmpty && parts[0].isNotEmpty) {
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
  return '?';
}

String _formatMoney(num value) {
  final s = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  final reversed = s.split('').reversed.toList();
  for (var i = 0; i < reversed.length; i++) {
    buffer.write(reversed[i]);
    final posFromEnd = i + 1;
    if (posFromEnd == 3 || (posFromEnd > 3 && (posFromEnd - 3) % 2 == 0)) {
      if (i != reversed.length - 1) buffer.write(',');
    }
  }
  return buffer.toString().split('').reversed.join();
}

List<StatusEvent> _buildHistoryEvents(StaffMember staff) {
  final events = List<StatusEvent>.from(staff.statusHistory);
  final hasJoined = events.any((e) => e.type == 'joined');
  if (!hasJoined && staff.joiningDate != null && staff.joiningDate!.isNotEmpty) {
    events.add(StatusEvent(type: 'joined', date: staff.joiningDate!));
  }
  if (staff.terminationDate != null && staff.terminationDate!.isNotEmpty) {
    final hasTerminatedEvent = events.any((e) => e.type == 'terminated' && e.date == staff.terminationDate);
    if (!hasTerminatedEvent && staff.isTerminated) {
      events.add(StatusEvent(type: 'terminated', date: staff.terminationDate!, note: staff.terminationNote));
    }
  }
  if (!staff.isTerminated && staff.isActive) {
    final terminatedEvents = events.where((e) => e.type == 'terminated').toList();
    final rejoinedEvents = events.where((e) => e.type == 'rejoined').toList();
    if (terminatedEvents.isNotEmpty && rejoinedEvents.isEmpty) {
      terminatedEvents.sort((a, b) => b.date.compareTo(a.date));
      final lastTerminationDate = terminatedEvents.first.date;
      final rejoiningDate = DateTime.now().toIso8601String().split('T').first;
      if (rejoiningDate.compareTo(lastTerminationDate) >= 0) {
        events.add(StatusEvent(type: 'rejoined', date: rejoiningDate, note: 'Rejoined (auto-detected)'));
      }
    }
  }
  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
}

class _FontCache {
  static pw.Font? _iconFont;
  static Future<pw.Font> get iconFont async {
    if (_iconFont != null) return _iconFont!;
    _iconFont = await pw_fonts.PdfGoogleFonts.materialIconsRegular();
    return _iconFont!;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Main PDF generation – now accepts salary adjustments
// ─────────────────────────────────────────────────────────────────────────
Future<Uint8List> generateStaffProfilePdf(
    StaffMember staff,
    Map<String, String> classIdToName, {
      List<SalaryHistory>? salaryHistory,   // ★ changed parameter
    }) async {
  final pdf = pw.Document();
  final historyEvents = _buildHistoryEvents(staff);
  final isTeacher = staff.type == 'teacher';

  final regularFont = pw.Font.helvetica();
  final boldFont = pw.Font.helveticaBold();
  final decorativeFont = pw.Font.timesBold();
  final iconFont = await _FontCache.iconFont;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (pw.Context context) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Sidebar ────────────────────────────────────────────────
            pw.Container(
              width: 155,
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: const pw.BoxDecoration(color: _navy),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Avatar
                  pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: PdfColors.blueGrey800,
                      border: pw.Border.all(color: _white, width: 2.5),
                      image: staff.imageBase64 != null
                          ? pw.DecorationImage(
                        image: pw.MemoryImage(base64Decode(staff.imageBase64!)),
                        fit: pw.BoxFit.cover,
                      )
                          : null,
                    ),
                    child: staff.imageBase64 == null
                        ? pw.Center(
                      child: pw.Text(
                        _initials(staff.name),
                        style: pw.TextStyle(fontSize: 26, font: boldFont, color: _white),
                      ),
                    )
                        : null,
                  ),
                  pw.SizedBox(height: 10),

                  // Name
                  pw.Text(
                    staff.name,
                    textAlign: pw.TextAlign.center,
                    maxLines: 2,
                    style: pw.TextStyle(
                      fontSize: 13,
                      font: boldFont,
                      color: _white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  if (staff.designation != null && staff.designation!.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        staff.designation!,
                        textAlign: pw.TextAlign.center,
                        maxLines: 1,
                        style: pw.TextStyle(
                          fontSize: 9,
                          font: regularFont,
                          color: PdfColors.grey400,
                        ),
                      ),
                    ),

                  pw.SizedBox(height: 10),

                  // Status pills
                  pw.Wrap(
                    alignment: pw.WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _pill(text: staff.isTerminated ? 'Terminated' : 'Active',
                          bg: staff.isTerminated ? _red : _green,
                          fg: _white, font: boldFont),
                      _pill(text: isTeacher ? 'Teacher' : 'Staff',
                          bg: PdfColors.blueGrey700, fg: _white, font: boldFont),
                    ],
                  ),
                  pw.SizedBox(height: 14),
                  pw.Divider(color: PdfColors.blueGrey700, thickness: 0.7),
                  pw.SizedBox(height: 10),

                  // CNIC only
                  _sidebarInfoBlock(const pw.IconData(0xe853), 'CNIC', staff.cnic,
                      iconFont: iconFont, regularFont: regularFont, boldFont: boldFont),
                  pw.SizedBox(height: 14),

                  // Employment history
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: _navyDark,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.blueGrey700, width: 0.6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EMPLOYMENT HISTORY',
                            style: pw.TextStyle(fontSize: 8, font: boldFont,
                                color: PdfColors.grey400, letterSpacing: 0.4)),
                        pw.SizedBox(height: 6),
                        ...historyEvents.asMap().entries.map((entry) {
                          return _historyTile(
                            entry.value,
                            entry.key == historyEvents.length - 1,
                            boldFont: boldFont,
                            regularFont: regularFont,
                          );
                        }),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 12),

                  // ★ SALARY ADJUSTMENT (if available)
                  if (salaryHistory != null && salaryHistory.isNotEmpty)
                    _salaryAdjustmentBlock(
                      salaryHistory: salaryHistory,
                      iconFont: iconFont,
                      boldFont: boldFont,
                      regularFont: regularFont,
                    ),
                ],
              ),
            ),

            // ── Main content ─────────────────────────────────────────
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('STAFF PROFILE',
                                style: pw.TextStyle(fontSize: 20,
                                    font: decorativeFont, color: _navy)),
                            pw.SizedBox(height: 3),
                            pw.Container(width: 50, height: 1.5, color: _blue),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),

                    if (staff.isTerminated) ...[
                      _terminatedBanner(staff, font: regularFont, boldFont: boldFont),
                      pw.SizedBox(height: 4),
                    ],

                    // Personal Information
                    _sectionCard(
                      icon: const pw.IconData(0xe853), iconFont: iconFont,
                      iconColor: _blue, iconBg: _blueLight,
                      title: 'PERSONAL INFORMATION',
                      font: regularFont, boldFont: boldFont,
                      rows: [
                        _row('Father / Husband', staff.fatherOrHusbandName),
                        _row('Date of Birth', _fmtDate(staff.dob)),
                        _row('Gender', staff.gender),
                        _row('Marital Status', staff.maritalStatus),
                        _row('Blood Group', staff.bloodGroup ?? '–'),
                        _row('Religion', staff.religion),
                        _row('Nationality', staff.nationality),
                      ],
                    ),
                    pw.SizedBox(height: 4),

                    _sectionCard(
                      icon: const pw.IconData(0xe0b0), iconFont: iconFont,
                      iconColor: _blue, iconBg: _blueLight,
                      title: 'CONTACT INFORMATION',
                      font: regularFont, boldFont: boldFont,
                      rows: [
                        _row('Address', staff.address),
                        _row('Phone', staff.phone),
                        _row('Emergency', staff.emergencyPhone),
                      ],
                    ),
                    pw.SizedBox(height: 4),

                    _sectionCard(
                      icon: const pw.IconData(0xe8f9), iconFont: iconFont,
                      iconColor: _blue, iconBg: _blueLight,
                      title: 'JOB DETAILS',
                      font: regularFont, boldFont: boldFont,
                      rows: [
                        _row('Employment Type', staff.employmentType),
                        _row('Salary', 'PKR ${_formatMoney(staff.salary)}',
                            highlight: true),
                        if (staff.reference != null && staff.reference!.isNotEmpty)
                          _row('Reference', staff.reference!),
                      ],
                    ),

                    if (staff.subjects.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      _chipCard(
                        icon: const pw.IconData(0xe80c), iconFont: iconFont,
                        iconColor: const PdfColor.fromInt(0xFF534AB7),
                        iconBg: const PdfColor.fromInt(0xFFF0EFFE),
                        title: 'ASSIGNED SUBJECTS',
                        count: staff.subjects.length,
                        chipColor: const PdfColor.fromInt(0xFF534AB7),
                        chipBg: const PdfColor.fromInt(0xFFF0EFFE),
                        labels: staff.subjects,
                        font: regularFont, boldFont: boldFont,
                      ),
                    ],

                    if (staff.assignedClasses.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      _chipCard(
                        icon: const pw.IconData(0xe86f), iconFont: iconFont,
                        iconColor: _green, iconBg: _greenLight,
                        title: 'ASSIGNED CLASSES',
                        count: staff.assignedClasses.length,
                        chipColor: _green, chipBg: _greenLight,
                        labels: staff.assignedClasses
                            .map((id) => classIdToName[id] ?? id)
                            .toList(),
                        font: regularFont, boldFont: boldFont,
                      ),
                    ],

                    if (staff.note != null && staff.note!.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      _noteCard(staff.note!, font: regularFont, boldFont: boldFont),
                    ],

                    pw.Spacer(),

                    // Centred footer
                    pw.Center(
                      child: pw.Text(
                        'Developed by Ali Haider | 0300-7465064',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          font: regularFont,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

// ─────────────────────────────────────────────────────────────────────────
// SALARY ADJUSTMENT block (Employment-History style timeline)
// ─────────────────────────────────────────────────────────────────────────
pw.Widget _salaryAdjustmentBlock({
  required List<SalaryHistory> salaryHistory,
  required pw.Font iconFont,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  // sort by date descending
  final sorted = List<SalaryHistory>.from(salaryHistory)
    ..sort((a, b) => b.date.compareTo(a.date));
  final display = sorted.take(10).toList(); // limit to 10

  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: _navyDark,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: PdfColors.blueGrey700, width: 0.6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('SALARY ADJUSTMENT',
            style: pw.TextStyle(fontSize: 8, font: boldFont,
                color: PdfColors.grey400, letterSpacing: 0.4)),
        pw.SizedBox(height: 6),
        ...display.asMap().entries.map((entry) {
          return _salaryTile(
            entry.value,
            entry.key == display.length - 1,
            boldFont: boldFont,
            regularFont: regularFont,
          );
        }),
      ],
    ),
  );
}

pw.Widget _salaryTile(
    SalaryHistory h,
    bool isLast, {
      required pw.Font boldFont,
      required pw.Font regularFont,
    }) {
  final isIncrement = h.isIncrement;
  final color = isIncrement ? _green : _red;
  final label = isIncrement ? 'Increment' : 'Decrement';
  final sign = isIncrement ? '+' : '-';
  final amountStr = '$sign Rs ${_formatMoney(h.amount)}';

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(children: [
          pw.Container(
              width: 6, height: 6,
              decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)),
          if (!isLast) pw.Container(width: 1, height: 18, color: PdfColors.grey500),
        ]),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(label,
                      style: pw.TextStyle(fontSize: 8, font: boldFont, color: _white)),
                  pw.Text(amountStr,
                      style: pw.TextStyle(fontSize: 8, font: boldFont, color: color)),
                ],
              ),
              pw.Text(_fmtDate(h.date),
                  style: pw.TextStyle(fontSize: 7, font: regularFont, color: PdfColors.grey500)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Helpers (unchanged)
// ─────────────────────────────────────────────────────────────────────────
pw.Widget _pill({required String text, required PdfColor bg, required PdfColor fg, required pw.Font font}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: pw.BoxDecoration(color: bg, borderRadius: pw.BorderRadius.circular(20)),
    child: pw.Text(text, style: pw.TextStyle(fontSize: 7.5, font: font, color: fg)),
  );
}

pw.Widget _sidebarInfoBlock(pw.IconData icon, String label, String value,
    {required pw.Font iconFont, required pw.Font regularFont, required pw.Font boldFont}) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        width: 18, height: 18,
        decoration: pw.BoxDecoration(color: PdfColors.blueGrey700, borderRadius: pw.BorderRadius.circular(4)),
        child: pw.Center(child: pw.Icon(icon, font: iconFont, size: 9, color: _white)),
      ),
      pw.SizedBox(width: 6),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 7, font: regularFont, color: PdfColors.grey500)),
            pw.SizedBox(height: 1),
            pw.Text(value, style: pw.TextStyle(fontSize: 8, font: boldFont, color: _white)),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _historyTile(StatusEvent e, bool isLast, {required pw.Font boldFont, required pw.Font regularFont}) {
  late final String label;
  late final PdfColor color;
  switch (e.type) {
    case 'joined': label = 'Joined'; color = _blue; break;
    case 'terminated': label = 'Terminated'; color = _red; break;
    case 'rejoined': label = 'Rejoined'; color = _green; break;
    default: label = e.type; color = PdfColors.grey400;
  }
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(children: [
          pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)),
          if (!isLast) pw.Container(width: 1, height: 18, color: PdfColors.grey500),
        ]),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: pw.TextStyle(fontSize: 8, font: boldFont, color: _white)),
              pw.Text(_fmtDate(e.date), style: pw.TextStyle(fontSize: 7, font: regularFont, color: PdfColors.grey500)),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _terminatedBanner(StaffMember staff, {required pw.Font font, required pw.Font boldFont}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: pw.BoxDecoration(
      color: _redLight,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: _red, width: 0.6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Deactivated / Terminated',
            style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _red)),
        if (staff.terminationDate != null && staff.terminationDate!.isNotEmpty)
          pw.Text('Terminated on: ${_fmtDate(staff.terminationDate)}',
              style: pw.TextStyle(fontSize: 8.5, font: font, color: PdfColors.grey700)),
        if (staff.terminationNote != null && staff.terminationNote!.isNotEmpty)
          pw.Text('Note: ${staff.terminationNote}',
              style: pw.TextStyle(fontSize: 8, font: font, color: PdfColors.grey600)),
      ],
    ),
  );
}

class _KV { final String label; final String value; final bool highlight; _KV(this.label, this.value, {this.highlight = false}); }
_KV _row(String label, String value, {bool highlight = false}) => _KV(label, value, highlight: highlight);

pw.Widget _sectionCard({
  required pw.IconData icon, required pw.Font iconFont,
  required PdfColor iconColor, required PdfColor iconBg,
  required String title, required List<_KV> rows,
  required pw.Font font, required pw.Font boldFont,
}) {
  return pw.Container(
    width: double.infinity,
    decoration: pw.BoxDecoration(
      color: _white,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: _grey200, width: 0.7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: pw.Row(
            children: [
              pw.Container(
                width: 18, height: 18,
                decoration: pw.BoxDecoration(color: iconColor, shape: pw.BoxShape.circle),
                child: pw.Center(child: pw.Icon(icon, font: iconFont, size: 9, color: _white)),
              ),
              pw.SizedBox(width: 6),
              pw.Text(title,
                  style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _grey900)),
            ],
          ),
        ),
        pw.Divider(height: 1, color: _grey100, thickness: 0.8),
        ...rows.asMap().entries.map((entry) {
          final i = entry.key; final r = entry.value; final isLast = i == rows.length - 1;
          return pw.Column(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(r.label,
                        style: pw.TextStyle(fontSize: 8.5, font: font, color: _grey500)),
                    pw.Text(r.value,
                        style: pw.TextStyle(
                          fontSize: 9,
                          font: r.highlight ? boldFont : font,
                          color: r.highlight ? _blue : _grey900,
                        )),
                  ],
                ),
              ),
              if (!isLast) pw.Divider(height: 1, indent: 12, endIndent: 12, color: _grey100),
            ],
          );
        }),
      ],
    ),
  );
}

pw.Widget _chipCard({
  required pw.IconData icon, required pw.Font iconFont,
  required PdfColor iconColor, required PdfColor iconBg,
  required String title, required int count,
  required PdfColor chipColor, required PdfColor chipBg,
  required List<String> labels, required pw.Font font, required pw.Font boldFont,
}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _white,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: _grey200, width: 0.7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 18, height: 18,
              decoration: pw.BoxDecoration(color: iconColor, shape: pw.BoxShape.circle),
              child: pw.Center(child: pw.Icon(icon, font: iconFont, size: 9, color: _white)),
            ),
            pw.SizedBox(width: 6),
            pw.Text(title,
                style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _grey900)),
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(
                color: chipBg, borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text('$count',
                  style: pw.TextStyle(fontSize: 8, font: boldFont, color: chipColor)),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 5, runSpacing: 5,
          children: labels.map((label) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: chipBg,
              borderRadius: pw.BorderRadius.circular(16),
              border: pw.Border.all(color: chipColor, width: 0.6),
            ),
            child: pw.Text(label,
                style: pw.TextStyle(fontSize: 8, font: boldFont, color: chipColor)),
          )).toList(),
        ),
      ],
    ),
  );
}

pw.Widget _noteCard(String note, {required pw.Font font, required pw.Font boldFont}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFFFFBEB),
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: PdfColor.fromInt(0xFFFDE68A), width: 0.7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('NOTES',
            style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: PdfColor.fromInt(0xFF92400E))),
        pw.SizedBox(height: 5),
        pw.Text(note,
            style: pw.TextStyle(fontSize: 8.5, font: font, color: PdfColor.fromInt(0xFF78350F))),
      ],
    ),
  );
}