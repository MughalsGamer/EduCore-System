//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../../models/teacher.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Screen wrapper (mobile navigation)
// // ─────────────────────────────────────────────────────────────────────────────
// class StaffProfileScreen extends StatelessWidget {
//   final StaffMember staff;
//   final Map<String, String> classIdToName;
//
//   const StaffProfileScreen({
//     super.key,
//     required this.staff,
//     this.classIdToName = const {},
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0EFF8),
//       appBar: AppBar(
//         title: const Text(
//           'Staff Profile',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF534AB7),
//         iconTheme: const IconThemeData(color: Colors.white),
//         elevation: 0,
//       ),
//       // NOTE: no outer SingleChildScrollView anymore — StaffProfileView now
//       // manages its own layout: left sidebar (with internally-scrollable
//       // history) + right content, both height-bounded to the viewport.
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: StaffProfileView(staff: staff, classIdToName: classIdToName),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Core view — usable in mobile screen AND desktop side-panel.
// // Used for BOTH active employees (Teacher/Staff list) AND terminated/
// // deactivated employees (Terminated list) — the Employment History section
// // below shows the full joined → terminated → rejoined ... timeline either way.
// // ─────────────────────────────────────────────────────────────────────────────
// class StaffProfileView extends StatelessWidget {
//   final StaffMember staff;
//   final Map<String, String> classIdToName;
//   final VoidCallback? onClose;
//
//   const StaffProfileView({
//     super.key,
//     required this.staff,
//     this.classIdToName = const {},
//     this.onClose,
//   });
//
//   // ── Theme ──
//   static const _purple       = Color(0xFF534AB7);
//   static const _purpleLight  = Color(0xFFF0EFFE);
//   static const _purpleDark   = Color(0xFF3D3589);
//   static const _purpleAccent = Color(0xFF7B6FD0);
//   static const _red          = Color(0xFFB91C1C);
//   static const _redBg        = Color(0xFFFEF2F2);
//   static const _blue         = Color(0xFF2563EB);
//   static const _green        = Color(0xFF15803D);
//
//   // ── Build ──
//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 720;
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.07),
//             blurRadius: 14,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: isMobile
//           ? _buildMobileLayout(context)
//           : _buildDesktopLayout(context),
//     );
//   }
//
//   // ─────────────────────────────────── Desktop ──────────────────────────────
//   // Left sidebar is now height-bound to the panel (LayoutBuilder/IntrinsicHeight
//   // via Row's default cross-stretch) so its History block can expand and
//   // scroll internally, while the right content column scrolls independently.
//   Widget _buildDesktopLayout(BuildContext context) {
//     return SizedBox(
//       // Fill whatever height the parent gives (Dialog / page body). If the
//       // parent gives unbounded height (e.g. inside a plain Column), fall back
//       // to a sensible viewport-based height so the sidebar can still size.
//       height: MediaQuery.of(context).size.height * 0.82,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Left: gradient sidebar (fixed 260 px wide), fills full height
//           SizedBox(width: 260, child: _buildSidebar()),
//           // Right: scrollable detail panel
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Staff Details',
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       if (onClose != null)
//                         IconButton(
//                           icon: const Icon(Icons.close, color: Colors.grey),
//                           onPressed: onClose,
//                           tooltip: 'Close',
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   ..._contentWidgets(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─────────────────────────────────── Mobile ───────────────────────────────
//   // Mobile: sidebar (with its own internally-scrollable history, capped
//   // height) sits on top, then the rest of the profile content scrolls below
//   // it as before.
//   Widget _buildMobileLayout(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           SizedBox(
//             height: 560, // enough for photo/badges/quick-info + history block
//             child: _buildSidebar(),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: _contentWidgets()),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ────────────────────── Shared scrollable content (right/below panel) ─────
//   // Employment History now lives INSIDE the sidebar (see _buildSidebar), so
//   // it is intentionally no longer built here.
//   List<Widget> _contentWidgets() {
//     return [
//       // ── Employment status banner (only shown when terminated) ──
//       if (staff.isTerminated) ...[
//         _buildTerminatedBanner(),
//         const SizedBox(height: 14),
//       ],
//
//       // ── Personal ──
//       _buildInfoCard(
//         icon: Icons.person_outline,
//         title: 'Personal Information',
//         rows: [
//           _InfoRow('Father / Husband', staff.fatherOrHusbandName),
//           _InfoRow('CNIC',             staff.cnic),
//           _InfoRow('Date of Birth',    staff.dob),
//           _InfoRow('Gender',           staff.gender),
//           _InfoRow('Marital Status',   staff.maritalStatus),
//           _InfoRow('Blood Group',      staff.bloodGroup ?? '-'),
//           _InfoRow('Religion',         staff.religion),
//           _InfoRow('Nationality',      staff.nationality),
//         ],
//       ),
//       const SizedBox(height: 14),
//
//       // ── Contact ──
//       _buildInfoCard(
//         icon: Icons.contact_phone_outlined,
//         title: 'Contact Information',
//         rows: [
//           _InfoRow('Address',   staff.address),
//           _InfoRow('Phone',     staff.phone),
//           _InfoRow('Emergency', staff.emergencyPhone),
//         ],
//       ),
//       const SizedBox(height: 14),
//
//       // ── Job ──
//       _buildInfoCard(
//         icon: Icons.work_outline,
//         title: 'Job Details',
//         rows: [
//           _InfoRow('Employment Type', staff.employmentType),
//           _InfoRow('Salary', 'PKR ${staff.salary.toStringAsFixed(0)}',
//               highlight: true),
//           if (staff.reference != null && staff.reference!.isNotEmpty)
//             _InfoRow('Reference', staff.reference!),
//         ],
//       ),
//
//       // ── Subjects ──
//       if (staff.subjects.isNotEmpty) ...[
//         const SizedBox(height: 14),
//         _buildChipCard(
//           icon: Icons.menu_book_outlined,
//           title: 'Assigned Subjects',
//           count: staff.subjects.length,
//           accentColor: _purple,
//           bgColor: _purpleLight,
//           chips: staff.subjects
//               .map((s) => _chipItem(label: s, bg: _purpleLight, color: _purple))
//               .toList(),
//         ),
//       ],
//
//       // ── Classes — classIdToName se NAME show hoga, ID nahi ──
//       if (staff.assignedClasses.isNotEmpty) ...[
//         const SizedBox(height: 14),
//         _buildChipCard(
//           icon: Icons.class_outlined,
//           title: 'Assigned Classes',
//           count: staff.assignedClasses.length,
//           accentColor: const Color(0xFF2E7D32),
//           bgColor: const Color(0xFFE8F5E9),
//           chips: staff.assignedClasses.map((id) {
//             final name = classIdToName[id] ?? id; // ← NAME, not raw ID
//             return _chipItem(
//               label: name,
//               bg: const Color(0xFFE8F5E9),
//               color: const Color(0xFF2E7D32),
//               icon: Icons.class_,
//             );
//           }).toList(),
//         ),
//       ],
//
//       // ── Note ──
//       if (staff.note != null && staff.note!.isNotEmpty) ...[
//         const SizedBox(height: 14),
//         _buildNoteCard(),
//       ],
//     ];
//   }
//
//   // ── Builds the complete, chronologically-sorted employment history list.
//   // Works identically for active AND terminated/deactivated members — the
//   // ONLY difference is which events exist in the data:
//   //   • Active, never terminated  → just "Joined"
//   //   • Terminated                → "Joined" ... "Terminated" (most recent)
//   //   • Rejoined after terminate  → "Joined" ... "Terminated" ... "Rejoined"
//   //
//   // Fix vs. previous version: earlier this only backfilled from
//   // joiningDate/terminationDate when statusHistory was COMPLETELY empty, so
//   // a record that already had a 'joined' entry (but was missing a
//   // 'terminated' entry, e.g. terminated before this feature existed) would
//   // never show its termination date. Now each event type is backfilled
//   // independently based on what's actually missing from the log.
//   List<StatusEvent> _buildHistoryEvents() {
//     final events = List<StatusEvent>.from(staff.statusHistory);
//
//     final hasJoined = events.any((e) => e.type == 'joined');
//     final hasTerminated = events.any((e) => e.type == 'terminated');
//
//     if (!hasJoined && staff.joiningDate != null && staff.joiningDate!.isNotEmpty) {
//       events.add(StatusEvent(type: 'joined', date: staff.joiningDate!));
//     }
//
//     if (!hasTerminated &&
//         staff.terminationDate != null &&
//         staff.terminationDate!.isNotEmpty) {
//       events.add(StatusEvent(
//         type: 'terminated',
//         date: staff.terminationDate!,
//         note: staff.terminationNote,
//       ));
//     }
//
//     // Chronological order: oldest first. Stable sort keeps same-date events
//     // (rare) in the order they were logged.
//     events.sort((a, b) => a.date.compareTo(b.date));
//     return events;
//   }
//
//   // ─────────────────────────── Terminated status banner ────────────────────
//   Widget _buildTerminatedBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: _redBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _red.withOpacity(0.35)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.person_off_rounded, color: _red, size: 20),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Deactivated / Terminated',
//                     style: TextStyle(
//                         fontSize: 13, fontWeight: FontWeight.w700, color: _red)),
//                 if (staff.terminationDate != null)
//                   Text('Since ${_formatDate(staff.terminationDate)}',
//                       style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
//                 if (staff.terminationNote != null &&
//                     staff.terminationNote!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 2),
//                     child: Text(staff.terminationNote!,
//                         style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─────────────────────────── Employment History block (in-sidebar) ───────
//   // Lives inside the gradient sidebar, below the quick-info rows, filling the
//   // remaining empty space. Only THIS block's list scrolls internally
//   // (Expanded + ListView.builder) — it never causes the whole profile page
//   // to scroll.
//   Widget _buildHistoryBlock() {
//     final events = _buildHistoryEvents();
//
//     return Expanded(
//       child: Container(
//         width: double.infinity,
//         margin: const EdgeInsets.only(top: 20),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.10),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.white24),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.18),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(Icons.history, size: 14, color: Colors.white),
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Employment History',
//                   style: TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: events.isEmpty
//                   ? Text(
//                 'No history recorded yet.',
//                 style: TextStyle(fontSize: 11.5, color: Colors.white70),
//               )
//                   : Scrollbar(
//                 thumbVisibility: events.length > 3,
//                 child: ListView.builder(
//                   padding: EdgeInsets.zero,
//                   itemCount: events.length,
//                   itemBuilder: (ctx, i) => _historyTile(
//                     events[i],
//                     isLast: i == events.length - 1,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _historyTile(StatusEvent e, {required bool isLast}) {
//     late final String label;
//     late final Color color;
//     late final IconData icon;
//     switch (e.type) {
//       case 'joined':
//         label = 'Joined';
//         color = _blue;
//         icon = Icons.login;
//         break;
//       case 'terminated':
//         label = 'Terminated';
//         color = _red;
//         icon = Icons.logout;
//         break;
//       case 'rejoined':
//         label = 'Rejoined';
//         color = _green;
//         icon = Icons.restart_alt;
//         break;
//       default:
//         label = e.type;
//         color = Colors.grey;
//         icon = Icons.circle;
//     }
//
//     // Light variant of the accent color so the tile reads well on the
//     // sidebar's dark gradient background.
//     final lightColor = Color.alphaBlend(Colors.white.withOpacity(0.55), color);
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Column(children: [
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.18),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 12, color: Colors.white),
//             ),
//             if (!isLast)
//               Container(width: 2, height: 26, color: Colors.white24),
//           ]),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(children: [
//                   Text(label,
//                       style: TextStyle(
//                           fontSize: 12, fontWeight: FontWeight.w700, color: lightColor)),
//                 ]),
//                 const SizedBox(height: 1),
//                 Text(_formatDate(e.date),
//                     style: const TextStyle(fontSize: 11, color: Colors.white70)),
//                 if (e.note != null && e.note!.isNotEmpty) ...[
//                   const SizedBox(height: 2),
//                   Text(e.note!,
//                       style: const TextStyle(fontSize: 11, color: Colors.white60)),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatDate(String? iso) {
//     if (iso == null || iso.isEmpty) return '—';
//     try {
//       final d = DateTime.parse(iso);
//       const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
//       return '${d.day} ${months[d.month - 1]} ${d.year}';
//     } catch (_) {
//       return iso;
//     }
//   }
//
//   // ─────────────────────────── Gradient Sidebar ─────────────────────────────
//   // Now a fixed header block (photo, name, badges, quick info) + the
//   // Employment History block filling the rest of the available height and
//   // scrolling internally when needed.
//   Widget _buildSidebar() {
//     final isTeacher = staff.type == 'teacher';
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [_purpleDark, _purple, _purpleAccent],
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // ── Portrait photo (ID-card shape — same as shared frame) ──────
//           Container(
//             width: 110,
//             height: 146,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white, width: 3),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.35),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(17),
//               child: staff.imageBase64 != null
//                   ? Image.memory(
//                 base64Decode(staff.imageBase64!),
//                 fit: BoxFit.cover,
//                 width: 110,
//                 height: 146,
//               )
//                   : Container(
//                 color: Colors.white.withOpacity(0.18),
//                 child: Center(
//                   child: Text(
//                     _initials(staff.name),
//                     style: const TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // ── Name ──
//           Text(
//             staff.name,
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               letterSpacing: 0.3,
//             ),
//           ),
//           const SizedBox(height: 8),
//
//           // ── Role badge + status badge ──
//           Wrap(
//             alignment: WrapAlignment.center,
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.white30),
//                 ),
//                 child: Text(
//                   isTeacher ? '👨‍🏫 Teacher' : '🏢 Staff',
//                   style: const TextStyle(
//                     fontSize: 11.5,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               // ★ Status badge (Active / Terminated) — same widget for both
//               // states; only the color/label flips based on staff.isTerminated.
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: staff.isTerminated
//                       ? Colors.red.withOpacity(0.25)
//                       : Colors.green.withOpacity(0.25),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                       color: staff.isTerminated
//                           ? Colors.red.shade100
//                           : Colors.green.shade100),
//                 ),
//                 child: Text(
//                   staff.isTerminated ? 'Terminated' : 'Active',
//                   style: const TextStyle(
//                     fontSize: 11.5,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 18),
//           Container(height: 1, color: Colors.white24),
//           const SizedBox(height: 16),
//
//           // ── Quick info ──
//           _sidebarRow(Icons.phone_outlined,    staff.phone),
//           const SizedBox(height: 8),
//           _sidebarRow(Icons.badge_outlined,    staff.employmentType),
//           if (staff.bloodGroup != null && staff.bloodGroup!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             _sidebarRow(Icons.water_drop_outlined, staff.bloodGroup!),
//           ],
//           if (staff.joiningDate != null && staff.joiningDate!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             _sidebarRow(Icons.calendar_today_outlined,
//                 'Joined ${_formatDate(staff.joiningDate)}'),
//           ],
//
//           // ★ Employment History — fills all remaining empty space below the
//           // quick-info rows, and is the ONLY part of this sidebar (and, for
//           // desktop, effectively the only scrollable competing element) that
//           // scrolls internally when the timeline is long.
//           _buildHistoryBlock(),
//         ],
//       ),
//     );
//   }
//
//   Widget _sidebarRow(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(icon, size: 14, color: Colors.white70),
//         const SizedBox(width: 6),
//         Flexible(
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(fontSize: 12, color: Colors.white70),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─────────────────────────── Info section card ────────────────────────────
//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required List<_InfoRow> rows,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFEEEEF5)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: _purpleLight,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, size: 16, color: _purple),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1, color: Color(0xFFF0F0F5)),
//           // Rows
//           ...rows.asMap().entries.map((e) {
//             final isLast = e.key == rows.length - 1;
//             final row   = e.value;
//             return Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 11),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         width: 130,
//                         child: Text(
//                           row.label,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Color(0xFF888899),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           row.value,
//                           textAlign: TextAlign.end,
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: row.highlight
//                                 ? FontWeight.bold
//                                 : FontWeight.w500,
//                             color: row.highlight
//                                 ? _purple
//                                 : const Color(0xFF1A1A2E),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!isLast)
//                   const Divider(
//                     height: 1,
//                     indent: 16,
//                     endIndent: 16,
//                     color: Color(0xFFF0F0F5),
//                   ),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   // ─────────────────────────── Chip card (subjects / classes) ──────────────
//   Widget _buildChipCard({
//     required IconData icon,
//     required String title,
//     required int count,
//     required Color accentColor,
//     required Color bgColor,
//     required List<Widget> chips,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFEEEEF5)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, size: 16, color: accentColor),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1A1A2E),
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   '$count',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: accentColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Wrap(spacing: 8, runSpacing: 6, children: chips),
//         ],
//       ),
//     );
//   }
//
//   Widget _chipItem({
//     required String label,
//     required Color bg,
//     required Color color,
//     IconData? icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (icon != null) ...[
//             Icon(icon, size: 12, color: color),
//             const SizedBox(width: 4),
//           ],
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─────────────────────────────── Note card ────────────────────────────────
//   Widget _buildNoteCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFBEB),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFFDE68A)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFEF3C7),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.sticky_note_2_outlined,
//                     size: 16, color: Color(0xFFD97706)),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Notes',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF92400E),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             staff.note!,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF78350F),
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Helpers ──
//   String _initials(String name) {
//     final parts = name.trim().split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Helper model
// // ─────────────────────────────────────────────────────────────────────────────
// class _InfoRow {
//   final String label;
//   final String value;
//   final bool highlight;
//   const _InfoRow(this.label, this.value, {this.highlight = false});
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/teacher.dart';
import '../../providers/teacher_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen wrapper (mobile navigation)
// ─────────────────────────────────────────────────────────────────────────────
class StaffProfileScreen extends StatelessWidget {
  final StaffMember staff;
  final Map<String, String> classIdToName;

  const StaffProfileScreen({
    super.key,
    required this.staff,
    this.classIdToName = const {},
  });

  @override
  Widget build(BuildContext context) {
    // FIX: always resolve the FRESHEST copy of this member from the
    // provider by id, instead of trusting whatever `staff` instance the
    // caller happened to pass in. A stale snapshot (captured before the
    // provider's notifyListeners() rebuild) was the reason Termination
    // events were missing in Employment History even though they existed
    // in Firestore. Watching the provider also keeps the profile live.
    final freshStaff = staff.id == null
        ? staff
        : (context.watch<StaffProvider>().getMemberById(staff.id!) ?? staff);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EFF8),
      appBar: AppBar(
        title: const Text(
          'Staff Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF534AB7),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      // NOTE: no outer SingleChildScrollView anymore — StaffProfileView now
      // manages its own layout: left sidebar (with internally-scrollable
      // history) + right content, both height-bounded to the viewport.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StaffProfileView(staff: freshStaff, classIdToName: classIdToName),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Core view — usable in mobile screen AND desktop side-panel.
// Used for BOTH active employees (Teacher/Staff list) AND terminated/
// deactivated employees (Terminated list) — the Employment History section
// below shows the full joined → terminated → rejoined ... timeline either way.
// ─────────────────────────────────────────────────────────────────────────────
class StaffProfileView extends StatelessWidget {
  final StaffMember staff;
  final Map<String, String> classIdToName;
  final VoidCallback? onClose;

  const StaffProfileView({
    super.key,
    required this.staff,
    this.classIdToName = const {},
    this.onClose,
  });

  // ── Theme ──
  static const _purple       = Color(0xFF534AB7);
  static const _purpleLight  = Color(0xFFF0EFFE);
  static const _purpleDark   = Color(0xFF3D3589);
  static const _purpleAccent = Color(0xFF7B6FD0);
  static const _red          = Color(0xFFB91C1C);
  static const _redBg        = Color(0xFFFEF2F2);
  static const _blue         = Color(0xFF2563EB);
  static const _green        = Color(0xFF15803D);

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  // ─────────────────────────────────── Desktop ──────────────────────────────
  // Left sidebar is now height-bound to the panel (LayoutBuilder/IntrinsicHeight
  // via Row's default cross-stretch) so its History block can expand and
  // scroll internally, while the right content column scrolls independently.
  Widget _buildDesktopLayout(BuildContext context) {
    return SizedBox(
      // Fill whatever height the parent gives (Dialog / page body). If the
      // parent gives unbounded height (e.g. inside a plain Column), fall back
      // to a sensible viewport-based height so the sidebar can still size.
      height: MediaQuery.of(context).size.height * 0.82,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: gradient sidebar (fixed 260 px wide), fills full height
          SizedBox(width: 260, child: _buildSidebar()),
          // Right: scrollable detail panel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Staff Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      if (onClose != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: onClose,
                          tooltip: 'Close',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._contentWidgets(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────── Mobile ───────────────────────────────
  // Mobile: sidebar (with its own internally-scrollable history, capped
  // height) sits on top, then the rest of the profile content scrolls below
  // it as before.
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 560, // enough for photo/badges/quick-info + history block
            child: _buildSidebar(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: _contentWidgets()),
          ),
        ],
      ),
    );
  }

  // ────────────────────── Shared scrollable content (right/below panel) ─────
  // Employment History now lives INSIDE the sidebar (see _buildSidebar), so
  // it is intentionally no longer built here.
  List<Widget> _contentWidgets() {
    return [
      // ── Employment status banner (only shown when terminated) ──
      if (staff.isTerminated) ...[
        _buildTerminatedBanner(),
        const SizedBox(height: 14),
      ],

      // ── Personal ──
      _buildInfoCard(
        icon: Icons.person_outline,
        title: 'Personal Information',
        rows: [
          _InfoRow('Father / Husband', staff.fatherOrHusbandName),
          _InfoRow('CNIC',             staff.cnic),
          _InfoRow('Date of Birth',    staff.dob),
          _InfoRow('Gender',           staff.gender),
          _InfoRow('Marital Status',   staff.maritalStatus),
          _InfoRow('Blood Group',      staff.bloodGroup ?? '-'),
          _InfoRow('Religion',         staff.religion),
          _InfoRow('Nationality',      staff.nationality),
        ],
      ),
      const SizedBox(height: 14),

      // ── Contact ──
      _buildInfoCard(
        icon: Icons.contact_phone_outlined,
        title: 'Contact Information',
        rows: [
          _InfoRow('Address',   staff.address),
          _InfoRow('Phone',     staff.phone),
          _InfoRow('Emergency', staff.emergencyPhone),
        ],
      ),
      const SizedBox(height: 14),

      // ── Job ──
      _buildInfoCard(
        icon: Icons.work_outline,
        title: 'Job Details',
        rows: [
          _InfoRow('Employment Type', staff.employmentType),
          _InfoRow('Salary', 'PKR ${staff.salary.toStringAsFixed(0)}',
              highlight: true),
          if (staff.reference != null && staff.reference!.isNotEmpty)
            _InfoRow('Reference', staff.reference!),
        ],
      ),

      // ── Subjects ──
      if (staff.subjects.isNotEmpty) ...[
        const SizedBox(height: 14),
        _buildChipCard(
          icon: Icons.menu_book_outlined,
          title: 'Assigned Subjects',
          count: staff.subjects.length,
          accentColor: _purple,
          bgColor: _purpleLight,
          chips: staff.subjects
              .map((s) => _chipItem(label: s, bg: _purpleLight, color: _purple))
              .toList(),
        ),
      ],

      // ── Classes — classIdToName se NAME show hoga, ID nahi ──
      if (staff.assignedClasses.isNotEmpty) ...[
        const SizedBox(height: 14),
        _buildChipCard(
          icon: Icons.class_outlined,
          title: 'Assigned Classes',
          count: staff.assignedClasses.length,
          accentColor: const Color(0xFF2E7D32),
          bgColor: const Color(0xFFE8F5E9),
          chips: staff.assignedClasses.map((id) {
            final name = classIdToName[id] ?? id; // ← NAME, not raw ID
            return _chipItem(
              label: name,
              bg: const Color(0xFFE8F5E9),
              color: const Color(0xFF2E7D32),
              icon: Icons.class_,
            );
          }).toList(),
        ),
      ],

      // ── Note ──
      if (staff.note != null && staff.note!.isNotEmpty) ...[
        const SizedBox(height: 14),
        _buildNoteCard(),
      ],
    ];
  }

  // ── Builds the complete, chronologically-sorted employment history list.
  // Works identically for active AND terminated/deactivated members — the
  // ONLY difference is which events exist in the data:
  //   • Active, never terminated  → just "Joined"
  //   • Terminated                → "Joined" ... "Terminated" (most recent)
  //   • Rejoined after terminate  → "Joined" ... "Terminated" ... "Rejoined"
  //
  // Fix vs. previous version: earlier this only backfilled from
  // joiningDate/terminationDate when statusHistory was COMPLETELY empty, so
  // a record that already had a 'joined' entry (but was missing a
  // 'terminated' entry, e.g. terminated before this feature existed) would
  // never show its termination date. Now each event type is backfilled
  // independently based on what's actually missing from the log.
  List<StatusEvent> _buildHistoryEvents() {
    final events = List<StatusEvent>.from(staff.statusHistory);

    final hasJoined = events.any((e) => e.type == 'joined');
    final hasTerminated = events.any((e) => e.type == 'terminated');

    if (!hasJoined && staff.joiningDate != null && staff.joiningDate!.isNotEmpty) {
      events.add(StatusEvent(type: 'joined', date: staff.joiningDate!));
    }


    if (!hasTerminated &&
        staff.terminationDate != null &&
        staff.terminationDate!.isNotEmpty) {
      events.add(StatusEvent(
        type: 'terminated',
        date: staff.terminationDate!,
        note: staff.terminationNote,
      ));
    }

    // Chronological order: oldest first. Stable sort keeps same-date events
    // (rare) in the order they were logged.
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  // ─────────────────────────── Terminated status banner ────────────────────
  Widget _buildTerminatedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _redBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_off_rounded, color: _red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Deactivated / Terminated',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: _red)),
                if (staff.terminationDate != null)
                  Text('Since ${_formatDate(staff.terminationDate)}',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700)),
                if (staff.terminationNote != null &&
                    staff.terminationNote!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(staff.terminationNote!,
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Employment History block (in-sidebar) ───────
  // Lives inside the gradient sidebar, below the quick-info rows, filling the
  // remaining empty space. Only THIS block's list scrolls internally
  // (Expanded + ListView.builder) — it never causes the whole profile page
  // to scroll.
  Widget _buildHistoryBlock() {
    final events = _buildHistoryEvents();

    return Expanded(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Employment History',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: events.isEmpty
                  ? Text(
                'No history recorded yet.',
                style: TextStyle(fontSize: 11.5, color: Colors.white70),
              )
                  : Scrollbar(
                thumbVisibility: events.length > 3,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: events.length,
                  itemBuilder: (ctx, i) => _historyTile(
                    events[i],
                    isLast: i == events.length - 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyTile(StatusEvent e, {required bool isLast}) {
    late final String label;
    late final Color color;
    late final IconData icon;
    switch (e.type) {
      case 'joined':
        label = 'Joined';
        color = _blue;
        icon = Icons.login;
        break;
      case 'terminated':
        label = 'Terminated';
        color = _red;
        icon = Icons.logout;
        break;
      case 'rejoined':
        label = 'Rejoined';
        color = _green;
        icon = Icons.restart_alt;
        break;
      default:
        label = e.type;
        color = Colors.grey;
        icon = Icons.circle;
    }

    // Light variant of the accent color so the tile reads well on the
    // sidebar's dark gradient background.
    final lightColor = Color.alphaBlend(Colors.white.withOpacity(0.55), color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: Colors.white),
            ),
            if (!isLast)
              Container(width: 2, height: 26, color: Colors.white24),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: lightColor)),
                ]),
                const SizedBox(height: 1),
                Text(_formatDate(e.date),
                    style: const TextStyle(fontSize: 11, color: Colors.white70)),
                if (e.note != null && e.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(e.note!,
                      style: const TextStyle(fontSize: 11, color: Colors.white60)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  // ─────────────────────────── Gradient Sidebar ─────────────────────────────
  // Now a fixed header block (photo, name, badges, quick info) + the
  // Employment History block filling the rest of the available height and
  // scrolling internally when needed.
  Widget _buildSidebar() {
    final isTeacher = staff.type == 'teacher';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purpleDark, _purple, _purpleAccent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Portrait photo (ID-card shape — same as shared frame) ──────
          Container(
            width: 110,
            height: 146,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: staff.imageBase64 != null
                  ? Image.memory(
                base64Decode(staff.imageBase64!),
                fit: BoxFit.cover,
                width: 110,
                height: 146,
              )
                  : Container(
                color: Colors.white.withOpacity(0.18),
                child: Center(
                  child: Text(
                    _initials(staff.name),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Name ──
          Text(
            staff.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          // ── Role badge + status badge ──
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  isTeacher ? '👨‍🏫 Teacher' : '🏢 Staff',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // ★ Status badge (Active / Terminated) — same widget for both
              // states; only the color/label flips based on staff.isTerminated.
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: staff.isTerminated
                      ? Colors.red.withOpacity(0.25)
                      : Colors.green.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: staff.isTerminated
                          ? Colors.red.shade100
                          : Colors.green.shade100),
                ),
                child: Text(
                  staff.isTerminated ? 'Terminated' : 'Active',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 16),

          // ── Quick info ──
          _sidebarRow(Icons.phone_outlined,    staff.phone),
          const SizedBox(height: 8),
          _sidebarRow(Icons.badge_outlined,    staff.employmentType),
          if (staff.bloodGroup != null && staff.bloodGroup!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _sidebarRow(Icons.water_drop_outlined, staff.bloodGroup!),
          ],
          if (staff.joiningDate != null && staff.joiningDate!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _sidebarRow(Icons.calendar_today_outlined,
                'Joined ${_formatDate(staff.joiningDate)}'),
          ],
          // ★ NEW – show termination date if terminated
          if (staff.isTerminated &&
              staff.terminationDate != null &&
              staff.terminationDate!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _sidebarRow(
              Icons.calendar_today_outlined,
              'Terminated ${_formatDate(staff.terminationDate)}',
            ),
          ],

          // ★ Employment History — fills all remaining empty space below the
          // quick-info rows, and is the ONLY part of this sidebar (and, for
          // desktop, effectively the only scrollable competing element) that
          // scrolls internally when the timeline is long.
          _buildHistoryBlock(),
        ],
      ),
    );
  }

  Widget _sidebarRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── Info section card ────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: _purple),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          // Rows
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            final row   = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          row.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888899),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: row.highlight
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: row.highlight
                                ? _purple
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFF0F0F5),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────── Chip card (subjects / classes) ──────────────
  Widget _buildChipCard({
    required IconData icon,
    required String title,
    required int count,
    required Color accentColor,
    required Color bgColor,
    required List<Widget> chips,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: chips),
        ],
      ),
    );
  }

  Widget _chipItem({
    required String label,
    required Color bg,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────── Note card ────────────────────────────────
  Widget _buildNoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sticky_note_2_outlined,
                    size: 16, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            staff.note!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF78350F),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper model
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow {
  final String label;
  final String value;
  final bool highlight;
  const _InfoRow(this.label, this.value, {this.highlight = false});
}