//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/salary_model.dart';
// import '../../providers/salary_provider.dart';
//
// // ────────────────────────────────────────────────────────────
// //  Design Tokens — Modern Palette
// // ────────────────────────────────────────────────────────────
// const _kPurple = Color(0xFF6C5CE7);
// const _kPurpleDark = Color(0xFF5B4BD6);
// const _kPurpleLight = Color(0xFFF3F1FF);
// const _kPurpleSoft = Color(0xFFEDE9FE);
// const _kGreen = Color(0xFF16A34A);
// const _kGreenBg = Color(0xFFECFDF3);
// const _kGreenBorder = Color(0xFFBBF7D0);
// const _kRed = Color(0xFFDC2626);
// const _kRedBg = Color(0xFFFEF2F2);
// const _kOrange = Color(0xFFD97706);
// const _kOrangeBg = Color(0xFFFFFBEB);
// const _kOrangeBorder = Color(0xFFFDE68A);
// const _kBorder = Color(0xFFE5E7EB);
// const _kSurface = Color(0xFFF7F8FB);
// const _kInk = Color(0xFF111827);
// const _kSlate = Color(0xFF6B7280);
// const _kSlateLight = Color(0xFF9CA3AF);
// const double _kDesktopBreakpoint = 900;
//
// // ────────────────────────────────────────────────────────────
// //  Salary List Screen
// // ────────────────────────────────────────────────────────────
// class SalaryListScreen extends StatefulWidget {
//   const SalaryListScreen({super.key});
//
//   @override
//   State<SalaryListScreen> createState() => _SalaryListScreenState();
// }
//
// class _SalaryListScreenState extends State<SalaryListScreen> {
//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;
//   String _statusFilter = 'All';
//   String _typeFilter = 'All';
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   void _loadData() {
//     context.read<SalaryProvider>().fetchSalaries(_selectedYear, _selectedMonth);
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   List<SalaryRecord> _filteredSalaries(List<SalaryRecord> all) {
//     return all.where((s) {
//       if (_statusFilter != 'All' && s.status != _statusFilter) return false;
//       if (_typeFilter != 'All' && s.employeeType != _typeFilter) return false;
//       final query = _searchController.text.trim().toLowerCase();
//       if (query.isNotEmpty && !s.employeeName.toLowerCase().contains(query)) return false;
//       return true;
//     }).toList();
//   }
//
//   Future<void> _pickYear() async {
//     final currentYear = DateTime.now().year;
//     final result = await showDialog<int>(
//       context: context,
//       builder: (ctx) => _YearPickerDialog(initialYear: _selectedYear, minYear: 2015, maxYear: currentYear),
//     );
//     if (result != null) {
//       setState(() => _selectedYear = result);
//       _loadData();
//     }
//   }
//
//   void _onMonthChanged(int? month) {
//     if (month == null) return;
//     setState(() => _selectedMonth = month);
//     _loadData();
//   }
//
//   Future<void> _changeStatusInline(SalaryRecord record, String newStatus) async {
//     if (record.status == newStatus) return;
//     try {
//       await context.read<SalaryProvider>().updateSalaryStatus(record.id!, newStatus);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${record.employeeName} marked as $newStatus'),
//             backgroundColor: _kGreen,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: _kRed, behavior: SnackBarBehavior.floating),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<SalaryProvider>();
//     final allSalaries = provider.salaries;
//     final filtered = _filteredSalaries(allSalaries);
//     final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: _kInk,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         surfaceTintColor: Colors.transparent,
//         title: const Text('Salary Records', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
//         bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: _kBorder)),
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 16, isDesktop ? 24 : 16, 16),
//             child: isDesktop ? _buildDesktopFilters() : _buildMobileFilters(),
//           ),
//           Container(height: 8, color: _kSurface),
//           Expanded(
//             child: provider.loadingSalaries
//                 ? const Center(child: CircularProgressIndicator(color: _kPurple))
//                 : filtered.isEmpty
//                 ? _buildEmptyState()
//                 : isDesktop
//                 ? _buildDesktopTable(filtered)
//                 : _buildMobileList(filtered),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(color: _kPurpleLight, shape: BoxShape.circle),
//             child: const Icon(Icons.receipt_long_outlined, size: 40, color: _kPurple),
//           ),
//           const SizedBox(height: 16),
//           Text('No salary records found', style: TextStyle(color: _kSlate, fontWeight: FontWeight.w600, fontSize: 15)),
//           const SizedBox(height: 4),
//           Text('Try changing filters or the selected month', style: TextStyle(color: _kSlateLight, fontSize: 13)),
//         ],
//       ),
//     );
//   }
//
//   // ── Modern pill-style dropdown wrapper ──
//   Widget _pillDropdown<T>({required Widget child, double? width}) {
//     return Container(
//       width: width,
//       height: 44,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kBorder),
//       ),
//       child: child,
//     );
//   }
//
//   Widget _buildDesktopFilters() {
//     return Row(
//       children: [
//         InkWell(
//           onTap: _pickYear,
//           borderRadius: BorderRadius.circular(12),
//           child: _pillDropdown(
//             width: 120,
//             child: Row(
//               children: [
//                 const Icon(Icons.calendar_today_outlined, size: 16, color: _kPurple),
//                 const SizedBox(width: 8),
//                 Text('$_selectedYear', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk)),
//                 const Spacer(),
//                 const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         _pillDropdown(
//           width: 130,
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<int>(
//               value: _selectedMonth,
//               isExpanded: true,
//               icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//               items: List.generate(12, (i) => i + 1)
//                   .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(0, m)))))
//                   .toList(),
//               onChanged: _onMonthChanged,
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         _pillDropdown(
//           width: 140,
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: _statusFilter,
//               isExpanded: true,
//               icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//               items: ['All', 'Pending', 'Paid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
//               onChanged: (v) => setState(() => _statusFilter = v!),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         _pillDropdown(
//           width: 140,
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: _typeFilter,
//               isExpanded: true,
//               icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//               items: ['All', 'teacher', 'staff']
//                   .map((t) => DropdownMenuItem(value: t, child: Text(t == 'All' ? 'All Types' : t.capitalize())))
//                   .toList(),
//               onChanged: (v) => setState(() => _typeFilter = v!),
//             ),
//           ),
//         ),
//         const Spacer(),
//         SizedBox(
//           width: 260,
//           height: 44,
//           child: TextField(
//             controller: _searchController,
//             style: const TextStyle(fontSize: 13),
//             decoration: InputDecoration(
//               hintText: 'Search by name…',
//               hintStyle: TextStyle(color: _kSlateLight, fontSize: 13),
//               prefixIcon: const Icon(Icons.search, size: 19, color: _kSlateLight),
//               filled: true,
//               fillColor: _kSurface,
//               contentPadding: const EdgeInsets.symmetric(vertical: 12),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
//               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
//               focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPurple, width: 1.5)),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                 icon: const Icon(Icons.close, size: 16, color: _kSlateLight),
//                 onPressed: () => setState(() => _searchController.clear()),
//               )
//                   : null,
//             ),
//             onChanged: (v) => setState(() {}),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMobileFilters() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: InkWell(
//                 onTap: _pickYear,
//                 borderRadius: BorderRadius.circular(12),
//                 child: _pillDropdown(
//                   child: Row(
//                     children: [
//                       const Icon(Icons.calendar_today_outlined, size: 15, color: _kPurple),
//                       const SizedBox(width: 6),
//                       Text('$_selectedYear', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//                       const Spacer(),
//                       const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: _pillDropdown(
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<int>(
//                     value: _selectedMonth,
//                     isExpanded: true,
//                     icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
//                     style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//                     items: List.generate(12, (i) => i + 1)
//                         .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMM').format(DateTime(0, m)))))
//                         .toList(),
//                     onChanged: _onMonthChanged,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: _pillDropdown(
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _statusFilter,
//                     isExpanded: true,
//                     icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
//                     style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//                     items: ['All', 'Pending', 'Paid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
//                     onChanged: (v) => setState(() => _statusFilter = v!),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: _pillDropdown(
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _typeFilter,
//                     isExpanded: true,
//                     icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
//                     style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//                     items: ['All', 'teacher', 'staff']
//                         .map((t) => DropdownMenuItem(value: t, child: Text(t == 'All' ? 'All Types' : t.capitalize())))
//                         .toList(),
//                     onChanged: (v) => setState(() => _typeFilter = v!),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 44,
//           child: TextField(
//             controller: _searchController,
//             style: const TextStyle(fontSize: 13),
//             decoration: InputDecoration(
//               hintText: 'Search by name…',
//               hintStyle: TextStyle(color: _kSlateLight, fontSize: 13),
//               prefixIcon: const Icon(Icons.search, size: 19, color: _kSlateLight),
//               filled: true,
//               fillColor: _kSurface,
//               contentPadding: const EdgeInsets.symmetric(vertical: 12),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
//               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
//               focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPurple, width: 1.5)),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                 icon: const Icon(Icons.close, size: 16, color: _kSlateLight),
//                 onPressed: () => setState(() => _searchController.clear()),
//               )
//                   : null,
//             ),
//             onChanged: (v) => setState(() {}),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Desktop: modern card-table hybrid instead of raw DataTable ──
//   Widget _buildDesktopTable(List<SalaryRecord> records) {
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: _kBorder),
//           ),
//           child: Column(
//             children: [
//               // Header row
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                 decoration: const BoxDecoration(
//                   color: _kPurpleLight,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                 ),
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 34, child: Text('#', style: _headerStyle)),
//                     const Expanded(flex: 3, child: Text('Employee', style: _headerStyle)),
//                     const Expanded(flex: 2, child: Text('Designation', style: _headerStyle)),
//                     const Expanded(flex: 2, child: Text('Base Salary', style: _headerStyle)),
//                     const Expanded(flex: 2, child: Text('Net Salary', style: _headerStyle)),
//                     const Expanded(flex: 2, child: Text('Status', style: _headerStyle)),
//                   ],
//                 ),
//               ),
//               ...List.generate(records.length, (i) {
//                 final s = records[i];
//                 final isLast = i == records.length - 1;
//                 return InkWell(
//                   onTap: () => _openDetail(s),
//                   borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                     decoration: BoxDecoration(
//                       border: isLast ? null : const Border(bottom: BorderSide(color: _kBorder)),
//                     ),
//                     child: Row(
//                       children: [
//                         SizedBox(width: 34, child: Text('${i + 1}', style: const TextStyle(color: _kSlateLight, fontSize: 13, fontWeight: FontWeight.w600))),
//                         Expanded(
//                           flex: 3,
//                           child: Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 16,
//                                 backgroundColor: _kPurpleSoft,
//                                 child: Text(
//                                   s.employeeName.isNotEmpty ? s.employeeName[0].toUpperCase() : '?',
//                                   style: const TextStyle(color: _kPurple, fontWeight: FontWeight.w700, fontSize: 12),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(s.employeeName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: _kInk)),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(s.designation ?? '—', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: _kSlate)),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text('Rs ${NumberFormat('#,##0').format(s.baseSalary)}', style: const TextStyle(fontSize: 13, color: _kInk)),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text('Rs ${NumberFormat('#,##0').format(s.netSalary)}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: _statusDropdownChip(s, onChanged: (v) => _changeStatusInline(s, v)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMobileList(List<SalaryRecord> records) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(14),
//       itemCount: records.length,
//       itemBuilder: (context, i) {
//         final s = records[i];
//         return InkWell(
//           onTap: () => _openDetail(s),
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: _kBorder),
//               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 22,
//                       height: 22,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(6)),
//                       child: Text('${i + 1}', style: const TextStyle(fontSize: 10.5, color: _kSlateLight, fontWeight: FontWeight.w700)),
//                     ),
//                     const SizedBox(width: 10),
//                     CircleAvatar(
//                       radius: 19,
//                       backgroundColor: _kPurpleSoft,
//                       child: Text(
//                         s.employeeName.isNotEmpty ? s.employeeName[0].toUpperCase() : '?',
//                         style: const TextStyle(color: _kPurple, fontWeight: FontWeight.w700, fontSize: 13),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(s.employeeName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: _kInk)),
//                           if (s.designation != null)
//                             Text(s.designation!, style: TextStyle(color: _kSlate, fontSize: 12.5)),
//                         ],
//                       ),
//                     ),
//                     const Icon(Icons.chevron_right, color: _kSlateLight, size: 20),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Container(height: 1, color: _kBorder),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _mobileStat('Base Salary', 'Rs ${NumberFormat('#,##0').format(s.baseSalary)}'),
//                     ),
//                     Expanded(
//                       child: _mobileStat('Net Salary', 'Rs ${NumberFormat('#,##0').format(s.netSalary)}', emphasize: true),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 _statusDropdownChip(s, onChanged: (v) => _changeStatusInline(s, v), fullWidth: true),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _mobileStat(String label, String value, {bool emphasize = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(fontSize: 11, color: _kSlateLight, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 2),
//         Text(value, style: TextStyle(fontSize: 14, fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600, color: _kInk)),
//       ],
//     );
//   }
//
//   // ── Status chip that is ALSO a dropdown to change status directly from list ──
//   Widget _statusDropdownChip(SalaryRecord record, {required ValueChanged<String> onChanged, bool fullWidth = false}) {
//     final isPaid = record.status == 'Paid';
//     final bg = isPaid ? _kGreenBg : _kOrangeBg;
//     final fg = isPaid ? _kGreen : _kOrange;
//     final border = isPaid ? _kGreenBorder : _kOrangeBorder;
//
//     return Container(
//       width: fullWidth ? double.infinity : null,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: record.status,
//           isDense: true,
//           isExpanded: fullWidth,
//           icon: Icon(Icons.expand_more, size: 16, color: fg),
//           style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700),
//           dropdownColor: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           items: [
//             DropdownMenuItem(
//               value: 'Pending',
//               child: Row(mainAxisSize: MainAxisSize.min, children: const [
//                 Icon(Icons.schedule, size: 14, color: _kOrange),
//                 SizedBox(width: 6),
//                 Text('Pending', style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600)),
//               ]),
//             ),
//             DropdownMenuItem(
//               value: 'Paid',
//               child: Row(mainAxisSize: MainAxisSize.min, children: const [
//                 Icon(Icons.check_circle, size: 14, color: _kGreen),
//                 SizedBox(width: 6),
//                 Text('Paid', style: TextStyle(color: _kGreen, fontWeight: FontWeight.w600)),
//               ]),
//             ),
//           ],
//           onChanged: (v) {
//             if (v != null) onChanged(v);
//           },
//         ),
//       ),
//     );
//   }
//
//   void _openDetail(SalaryRecord record) {
//     Navigator.of(context).push(MaterialPageRoute(builder: (_) => SalaryDetailScreen(record: record))).then((_) => _loadData());
//   }
// }
//
// const TextStyle _headerStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: _kPurpleDark, letterSpacing: 0.2);
//
// // ────────────────────────────────────────────────────────────
// //  Salary Detail / Edit Screen
// // ────────────────────────────────────────────────────────────
// class SalaryDetailScreen extends StatefulWidget {
//   final SalaryRecord record;
//   const SalaryDetailScreen({super.key, required this.record});
//
//   @override
//   State<SalaryDetailScreen> createState() => _SalaryDetailScreenState();
// }
//
// class _SalaryDetailScreenState extends State<SalaryDetailScreen> {
//   late TextEditingController _fineCtrl;
//   late TextEditingController _bonusCtrl;
//   late TextEditingController _noteCtrl;
//   bool _isEditing = false;
//   bool _isSaving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fineCtrl = TextEditingController(text: widget.record.fine.toStringAsFixed(0));
//     _bonusCtrl = TextEditingController(text: widget.record.bonus.toStringAsFixed(0));
//     _noteCtrl = TextEditingController(text: widget.record.note ?? '');
//   }
//
//   @override
//   void dispose() {
//     _fineCtrl.dispose();
//     _bonusCtrl.dispose();
//     _noteCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveEdits() async {
//     final fine = double.tryParse(_fineCtrl.text.trim()) ?? widget.record.fine;
//     final bonus = double.tryParse(_bonusCtrl.text.trim()) ?? widget.record.bonus;
//     final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
//
//     setState(() => _isSaving = true);
//     try {
//       await context.read<SalaryProvider>().updateSalaryFields(widget.record.id!, fine: fine, bonus: bonus, note: note);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Salary updated successfully'),
//             backgroundColor: _kGreen,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: _kRed, behavior: SnackBarBehavior.floating),
//         );
//         setState(() => _isSaving = false);
//       }
//     }
//   }
//
//   Future<void> _changeStatus(String newStatus) async {
//     try {
//       await context.read<SalaryProvider>().updateSalaryStatus(widget.record.id!, newStatus);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Status changed to $newStatus'),
//             backgroundColor: _kGreen,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: _kRed, behavior: SnackBarBehavior.floating),
//         );
//       }
//     }
//   }
//
//   Future<void> _deleteRecord() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: const BoxDecoration(color: _kRedBg, shape: BoxShape.circle),
//                 child: const Icon(Icons.delete_outline, color: _kRed, size: 28),
//               ),
//               const SizedBox(height: 16),
//               const Text('Delete this salary?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kInk)),
//               const SizedBox(height: 8),
//               Text('This action cannot be undone.', style: TextStyle(fontSize: 13, color: _kSlate), textAlign: TextAlign.center),
//               const SizedBox(height: 22),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(ctx, false),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 13),
//                         side: const BorderSide(color: _kBorder),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text('Cancel', style: TextStyle(color: _kInk, fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(ctx, true),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _kRed,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(vertical: 13),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//     if (confirm == true) {
//       try {
//         await context.read<SalaryProvider>().deleteSalary(widget.record.id!);
//         if (mounted) {
//           Navigator.pop(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Record deleted.'), backgroundColor: _kGreen, behavior: SnackBarBehavior.floating),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: $e'), backgroundColor: _kRed, behavior: SnackBarBehavior.floating),
//           );
//         }
//       }
//     }
//   }
//
//   Widget _statusChip(String status) {
//     final isPaid = status == 'Paid';
//     final bg = isPaid ? _kGreenBg : _kOrangeBg;
//     final fg = isPaid ? _kGreen : _kOrange;
//     final border = isPaid ? _kGreenBorder : _kOrangeBorder;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(isPaid ? Icons.check_circle : Icons.schedule, size: 14, color: fg),
//           const SizedBox(width: 6),
//           Text(status, style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700)),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final rec = widget.record;
//     final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: _kInk,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         surfaceTintColor: Colors.transparent,
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: _kPurpleSoft,
//               child: Text(
//                 rec.employeeName.isNotEmpty ? rec.employeeName[0].toUpperCase() : '?',
//                 style: const TextStyle(color: _kPurple, fontWeight: FontWeight.w700, fontSize: 13),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Flexible(
//               child: Text(rec.employeeName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
//             ),
//           ],
//         ),
//         bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: _kBorder)),
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined, color: _isEditing ? _kRed : _kPurple),
//             tooltip: _isEditing ? 'Cancel Edit' : 'Edit',
//             onPressed: () => setState(() => _isEditing = !_isEditing),
//           ),
//           IconButton(icon: const Icon(Icons.delete_outline, color: _kRed), tooltip: 'Delete', onPressed: _deleteRecord),
//           const SizedBox(width: 4),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(isDesktop ? 24 : 16),
//         child: isDesktop
//             ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700), child: _buildDetailContent(rec)))
//             : _buildDetailContent(rec),
//       ),
//     );
//   }
//
//   Widget _buildDetailContent(SalaryRecord rec) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Net salary hero card
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(colors: [_kPurple, _kPurpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [BoxShadow(color: _kPurple.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
//           ),
//           child: Column(
//             children: [
//               const Text('Net Salary', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
//               const SizedBox(height: 8),
//               Text('Rs ${NumberFormat('#,##0').format(rec.netSalary)}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
//               const SizedBox(height: 14),
//               _statusChip(rec.status),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // Status actions
//         _buildCard('Payment Status', icon: Icons.payments_outlined, children: [
//           if (rec.createdAt != null) _detailRow('Generated At', Text(DateFormat('dd MMM yyyy, hh:mm a').format(rec.createdAt!))),
//           if (rec.paidAt != null) _detailRow('Paid At', Text(DateFormat('dd MMM yyyy, hh:mm a').format(rec.paidAt!))),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: rec.status == 'Pending'
//                 ? ElevatedButton.icon(
//               onPressed: () => _changeStatus('Paid'),
//               icon: const Icon(Icons.check_circle, size: 18),
//               label: const Text('Mark as Paid'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _kGreen,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             )
//                 : OutlinedButton.icon(
//               onPressed: () => _changeStatus('Pending'),
//               icon: const Icon(Icons.undo, size: 18),
//               label: const Text('Mark as Pending'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: _kOrange,
//                 side: const BorderSide(color: _kOrangeBorder),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 16),
//
//         // Employee info card — LOCKED (read-only, no edit even in edit mode)
//         _buildCard('Employee Information', icon: Icons.badge_outlined, locked: true, children: [
//           _detailRow('Employee', Text(rec.employeeName)),
//           _detailRow('Type', Text(rec.employeeType == 'teacher' ? 'Teacher' : 'Staff')),
//           if (rec.designation != null) _detailRow('Designation', Text(rec.designation!)),
//           _detailRow('Month', Text(DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month)))),
//         ]),
//         const SizedBox(height: 16),
//
//         // Salary breakdown card
//         _buildCard('Salary Breakdown', icon: Icons.calculate_outlined, children: [
//           _detailRow('Base Salary', Text('Rs ${NumberFormat('#,##0').format(rec.baseSalary)}')),
//           _detailRow('Working Days', Text('${rec.workingDays} of ${rec.totalDaysInMonth}')),
//           _detailRow('Leaves (Absents)', Text('${rec.leaves}')),
//           _detailRow('Per Day Rate', Text('Rs ${NumberFormat('#,##0').format(rec.perDayRate)}')),
//           _detailRow('Absent Deduction', Text('- Rs ${NumberFormat('#,##0').format(rec.absentDeduction)}', style: const TextStyle(color: _kRed, fontWeight: FontWeight.w600))),
//         ]),
//         const SizedBox(height: 16),
//
//         // Adjustments card (editable)
//         _buildCard('Adjustments & Note', icon: Icons.tune, children: [
//           if (!_isEditing) ...[
//             _detailRow('Fine / Deduction', Text('Rs ${NumberFormat('#,##0').format(rec.fine)}', style: const TextStyle(color: _kRed, fontWeight: FontWeight.w600))),
//             _detailRow('Bonus / Addition', Text('Rs ${NumberFormat('#,##0').format(rec.bonus)}', style: const TextStyle(color: _kGreen, fontWeight: FontWeight.w600))),
//             if (rec.note != null && rec.note!.isNotEmpty) _detailRow('Note', Text(rec.note!)),
//           ] else ...[
//             _editField(controller: _fineCtrl, label: 'Fine / Deduction', icon: Icons.remove_circle_outline, color: _kRed),
//             const SizedBox(height: 12),
//             _editField(controller: _bonusCtrl, label: 'Bonus / Addition', icon: Icons.add_circle_outline, color: _kGreen),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _noteCtrl,
//               maxLines: 2,
//               decoration: InputDecoration(
//                 labelText: 'Note (optional)',
//                 filled: true,
//                 fillColor: _kSurface,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
//                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
//                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPurple, width: 1.5)),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _isSaving ? null : _saveEdits,
//                 icon: _isSaving
//                     ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Icon(Icons.save_outlined, size: 18),
//                 label: Text(_isSaving ? 'Saving…' : 'Save Changes'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _kPurple,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ),
//           ],
//         ]),
//         const SizedBox(height: 24),
//       ],
//     );
//   }
//
//   Widget _editField({required TextEditingController controller, required String label, required IconData icon, required Color color}) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, size: 20, color: color),
//         prefixText: 'Rs ',
//         filled: true,
//         fillColor: _kSurface,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
//         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
//         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 1.5)),
//       ),
//     );
//   }
//
//   Widget _buildCard(String title, {required List<Widget> children, IconData? icon, bool locked = false}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _kBorder),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               if (icon != null) ...[
//                 Icon(icon, size: 17, color: _kPurple),
//                 const SizedBox(width: 8),
//               ],
//               Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kInk)),
//               if (locked) ...[
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _kBorder)),
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     Icon(Icons.lock_outline, size: 11, color: _kSlateLight),
//                     const SizedBox(width: 4),
//                     Text('Locked', style: TextStyle(fontSize: 10.5, color: _kSlateLight, fontWeight: FontWeight.w600)),
//                   ]),
//                 ),
//               ],
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget _detailRow(String label, Widget value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 7),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(color: _kSlate, fontSize: 13)),
//           Flexible(
//             child: DefaultTextStyle.merge(
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//               textAlign: TextAlign.right,
//               child: value,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Year picker dialog — modern style ──
// class _YearPickerDialog extends StatelessWidget {
//   final int initialYear, minYear, maxYear;
//   const _YearPickerDialog({required this.initialYear, required this.minYear, required this.maxYear});
//
//   @override
//   Widget build(BuildContext context) {
//     final years = List.generate(maxYear - minYear + 1, (i) => minYear + i).reversed.toList();
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Select Year', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kInk)),
//             const SizedBox(height: 14),
//             SizedBox(
//               height: 240,
//               width: 260,
//               child: ListView.builder(
//                 itemCount: years.length,
//                 itemBuilder: (ctx, i) {
//                   final y = years[i];
//                   final selected = y == initialYear;
//                   return InkWell(
//                     borderRadius: BorderRadius.circular(10),
//                     onTap: () => Navigator.pop(context, y),
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 2),
//                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                       decoration: BoxDecoration(
//                         color: selected ? _kPurpleLight : Colors.transparent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         children: [
//                           Text('$y', style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w400, color: selected ? _kPurple : _kInk)),
//                           const Spacer(),
//                           if (selected) const Icon(Icons.check, color: _kPurple, size: 18),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// extension StringExtension on String {
//   String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/salary_model.dart';
import '../../providers/salary_provider.dart';
import 'generate_salary_screen.dart';

// ────────────────────────────────────────────────────────────
//  Design Tokens — Modern Palette
// ────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6C5CE7);
const _kPurpleDark = Color(0xFF5B4BD6);
const _kPurpleLight = Color(0xFFF3F1FF);
const _kPurpleSoft = Color(0xFFEDE9FE);
const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFECFDF3);
const _kGreenBorder = Color(0xFFBBF7D0);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEF2F2);
const _kOrange = Color(0xFFD97706);
const _kOrangeBg = Color(0xFFFFFBEB);
const _kOrangeBorder = Color(0xFFFDE68A);
const _kBorder = Color(0xFFE5E7EB);
const _kSurface = Color(0xFFF7F8FB);
const _kInk = Color(0xFF111827);
const _kSlate = Color(0xFF6B7280);
const _kSlateLight = Color(0xFF9CA3AF);
const double _kDesktopBreakpoint = 900;

// ────────────────────────────────────────────────────────────
//  Salary List Screen
// ────────────────────────────────────────────────────────────
class SalaryListScreen extends StatefulWidget {
  const SalaryListScreen({super.key});

  @override
  State<SalaryListScreen> createState() => _SalaryListScreenState();
}

class _SalaryListScreenState extends State<SalaryListScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _statusFilter = 'All';
  String _typeFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<SalaryProvider>().fetchSalaries(_selectedYear, _selectedMonth);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SalaryRecord> _filteredSalaries(List<SalaryRecord> all) {
    return all.where((s) {
      if (_statusFilter != 'All' && s.status != _statusFilter) return false;
      if (_typeFilter != 'All' && s.employeeType != _typeFilter) return false;
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty && !s.employeeName.toLowerCase().contains(query)) return false;
      return true;
    }).toList();
  }

  Future<void> _pickYear() async {
    final currentYear = DateTime.now().year;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => _YearPickerDialog(initialYear: _selectedYear, minYear: 2015, maxYear: currentYear),
    );
    if (result != null) {
      setState(() => _selectedYear = result);
      _loadData();
    }
  }

  void _onMonthChanged(int? month) {
    if (month == null) return;
    setState(() => _selectedMonth = month);
    _loadData();
  }

  Future<void> _changeStatusInline(SalaryRecord record, String newStatus) async {
    if (record.status == newStatus) return;
    try {
      await context.read<SalaryProvider>().updateSalaryStatus(record.id!, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${record.employeeName} marked as $newStatus'),
            backgroundColor: _kGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _kRed, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _openEdit(SalaryRecord record) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => GenerateSalaryScreen(existingRecord: record)))
        .then((_) => _loadData());
  }

  Future<void> _confirmDelete(SalaryRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(color: _kRedBg, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: _kRed, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Delete this salary?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kInk)),
              const SizedBox(height: 8),
              Text(
                'This will permanently remove the salary record for ${record.employeeName}.',
                style: TextStyle(fontSize: 13, color: _kSlate),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: _kBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: _kInk, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      try {
        await context.read<SalaryProvider>().deleteSalary(record.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record deleted.'), backgroundColor: _kGreen, behavior: SnackBarBehavior.floating),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: _kRed, behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalaryProvider>();
    final allSalaries = provider.salaries;
    final filtered = _filteredSalaries(allSalaries);
    final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _kInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Salary Records', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: _kBorder)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 16, isDesktop ? 24 : 16, 16),
            child: isDesktop ? _buildDesktopFilters() : _buildMobileFilters(),
          ),
          Container(height: 8, color: _kSurface),
          Expanded(
            child: provider.loadingSalaries
                ? const Center(child: CircularProgressIndicator(color: _kPurple))
                : filtered.isEmpty
                ? _buildEmptyState()
                : isDesktop
                ? _buildDesktopTable(filtered)
                : _buildMobileList(filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _kPurpleLight, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, size: 40, color: _kPurple),
          ),
          const SizedBox(height: 16),
          Text('No salary records found', style: TextStyle(color: _kSlate, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Try changing filters or the selected month', style: TextStyle(color: _kSlateLight, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Modern pill-style dropdown wrapper ──
  Widget _pillDropdown<T>({required Widget child, double? width}) {
    return Container(
      width: width,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        InkWell(
          onTap: _pickYear,
          borderRadius: BorderRadius.circular(12),
          child: _pillDropdown(
            width: 120,
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: _kPurple),
                const SizedBox(width: 8),
                Text('$_selectedYear', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk)),
                const Spacer(),
                const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _pillDropdown(
          width: 130,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedMonth,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
              items: List.generate(12, (i) => i + 1)
                  .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(0, m)))))
                  .toList(),
              onChanged: _onMonthChanged,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _pillDropdown(
          width: 140,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilter,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
              items: ['All', 'Pending', 'Paid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _statusFilter = v!),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _pillDropdown(
          width: 140,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _typeFilter,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
              items: ['All', 'teacher', 'staff']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t == 'All' ? 'All Types' : t.capitalize())))
                  .toList(),
              onChanged: (v) => setState(() => _typeFilter = v!),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 260,
          height: 44,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by name…',
              hintStyle: TextStyle(color: _kSlateLight, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 19, color: _kSlateLight),
              filled: true,
              fillColor: _kSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPurple, width: 1.5)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close, size: 16, color: _kSlateLight),
                onPressed: () => setState(() => _searchController.clear()),
              )
                  : null,
            ),
            onChanged: (v) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickYear,
                borderRadius: BorderRadius.circular(12),
                child: _pillDropdown(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 15, color: _kPurple),
                      const SizedBox(width: 6),
                      Text('$_selectedYear', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const Spacer(),
                      const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _pillDropdown(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedMonth,
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMM').format(DateTime(0, m)))))
                        .toList(),
                    onChanged: _onMonthChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _pillDropdown(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
                    items: ['All', 'Pending', 'Paid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _statusFilter = v!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _pillDropdown(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _typeFilter,
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
                    items: ['All', 'teacher', 'staff']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t == 'All' ? 'All Types' : t.capitalize())))
                        .toList(),
                    onChanged: (v) => setState(() => _typeFilter = v!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by name…',
              hintStyle: TextStyle(color: _kSlateLight, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 19, color: _kSlateLight),
              filled: true,
              fillColor: _kSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPurple, width: 1.5)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close, size: 16, color: _kSlateLight),
                onPressed: () => setState(() => _searchController.clear()),
              )
                  : null,
            ),
            onChanged: (v) => setState(() {}),
          ),
        ),
      ],
    );
  }

  // ── Desktop: modern card-table hybrid instead of raw DataTable ──
  Widget _buildDesktopTable(List<SalaryRecord> records) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: _kPurpleLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 34, child: Text('#', style: _headerStyle)),
                    const Expanded(flex: 3, child: Text('Employee', style: _headerStyle)),
                    const Expanded(flex: 2, child: Text('Designation', style: _headerStyle)),
                    const Expanded(flex: 2, child: Text('Base Salary', style: _headerStyle)),
                    const Expanded(flex: 2, child: Text('Net Salary', style: _headerStyle)),
                    const Expanded(flex: 2, child: Text('Status', style: _headerStyle)),
                    const SizedBox(width: 96, child: Text('Actions', style: _headerStyle)),
                  ],
                ),
              ),
              ...List.generate(records.length, (i) {
                final s = records[i];
                final isLast = i == records.length - 1;
                return InkWell(
                  onTap: () => _openDetail(s),
                  borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      border: isLast ? null : const Border(bottom: BorderSide(color: _kBorder)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 34, child: Text('${i + 1}', style: const TextStyle(color: _kSlateLight, fontSize: 13, fontWeight: FontWeight.w600))),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: _kPurpleSoft,
                                child: Text(
                                  s.employeeName.isNotEmpty ? s.employeeName[0].toUpperCase() : '?',
                                  style: const TextStyle(color: _kPurple, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(s.employeeName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: _kInk)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(s.designation ?? '—', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: _kSlate)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Rs ${NumberFormat('#,##0').format(s.baseSalary)}', style: const TextStyle(fontSize: 13, color: _kInk)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Rs ${NumberFormat('#,##0').format(s.netSalary)}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _statusDropdownChip(s, onChanged: (v) => _changeStatusInline(s, v)),
                          ),
                        ),
                        SizedBox(
                          width: 96,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: _kPurple),
                                tooltip: 'Edit',
                                onPressed: () => _openEdit(s),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: _kRed),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDelete(s),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(List<SalaryRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: records.length,
      itemBuilder: (context, i) {
        final s = records[i];
        return InkWell(
          onTap: () => _openDetail(s),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(6)),
                      child: Text('${i + 1}', style: const TextStyle(fontSize: 10.5, color: _kSlateLight, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: _kPurpleSoft,
                      child: Text(
                        s.employeeName.isNotEmpty ? s.employeeName[0].toUpperCase() : '?',
                        style: const TextStyle(color: _kPurple, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.employeeName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: _kInk)),
                          if (s.designation != null)
                            Text(s.designation!, style: TextStyle(color: _kSlate, fontSize: 12.5)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: _kPurple),
                      tooltip: 'Edit',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _openEdit(s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: _kRed),
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmDelete(s),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: _kBorder),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _mobileStat('Base Salary', 'Rs ${NumberFormat('#,##0').format(s.baseSalary)}'),
                    ),
                    Expanded(
                      child: _mobileStat('Net Salary', 'Rs ${NumberFormat('#,##0').format(s.netSalary)}', emphasize: true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _statusDropdownChip(s, onChanged: (v) => _changeStatusInline(s, v), fullWidth: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mobileStat(String label, String value, {bool emphasize = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: _kSlateLight, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600, color: _kInk)),
      ],
    );
  }

  // ── Status chip that is ALSO a dropdown to change status directly from list ──
  Widget _statusDropdownChip(SalaryRecord record, {required ValueChanged<String> onChanged, bool fullWidth = false}) {
    final isPaid = record.status == 'Paid';
    final bg = isPaid ? _kGreenBg : _kOrangeBg;
    final fg = isPaid ? _kGreen : _kOrange;
    final border = isPaid ? _kGreenBorder : _kOrangeBorder;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: record.status,
          isDense: true,
          isExpanded: fullWidth,
          icon: Icon(Icons.expand_more, size: 16, color: fg),
          style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          items: [
            DropdownMenuItem(
              value: 'Pending',
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.schedule, size: 14, color: _kOrange),
                SizedBox(width: 6),
                Text('Pending', style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600)),
              ]),
            ),
            DropdownMenuItem(
              value: 'Paid',
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.check_circle, size: 14, color: _kGreen),
                SizedBox(width: 6),
                Text('Paid', style: TextStyle(color: _kGreen, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  void _openDetail(SalaryRecord record) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SalaryDetailScreen(record: record))).then((_) => _loadData());
  }
}

const TextStyle _headerStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: _kPurpleDark, letterSpacing: 0.2);

// ────────────────────────────────────────────────────────────
//  Salary Detail Screen (read-only view — editing happens via
//  GenerateSalaryScreen's edit mode, opened from the list)
// ────────────────────────────────────────────────────────────
class SalaryDetailScreen extends StatelessWidget {
  final SalaryRecord record;
  const SalaryDetailScreen({super.key, required this.record});

  Widget _statusChip(String status) {
    final isPaid = status == 'Paid';
    final bg = isPaid ? _kGreenBg : _kOrangeBg;
    final fg = isPaid ? _kGreen : _kOrange;
    final border = isPaid ? _kGreenBorder : _kOrangeBorder;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPaid ? Icons.check_circle : Icons.schedule, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rec = record;
    final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _kInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _kPurpleSoft,
              child: Text(
                rec.employeeName.isNotEmpty ? rec.employeeName[0].toUpperCase() : '?',
                style: const TextStyle(color: _kPurple, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(rec.employeeName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ],
        ),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: _kBorder)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: _kPurple),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => GenerateSalaryScreen(existingRecord: rec)))
                  .then((_) => Navigator.of(context).pop());
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: isDesktop
            ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700), child: _buildDetailContent()))
            : _buildDetailContent(),
      ),
    );
  }

  Widget _buildDetailContent() {
    final rec = record;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Net salary hero card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kPurple, _kPurpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _kPurple.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              const Text('Net Salary', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('Rs ${NumberFormat('#,##0').format(rec.netSalary)}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _statusChip(rec.status),
              if (rec.paidAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Paid on ${DateFormat('dd MMM yyyy').format(rec.paidAt!)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Employee info card
        _buildCard('Employee Information', icon: Icons.badge_outlined, children: [
          _detailRow('Employee', Text(rec.employeeName)),
          _detailRow('Type', Text(rec.employeeType == 'teacher' ? 'Teacher' : 'Staff')),
          if (rec.designation != null) _detailRow('Designation', Text(rec.designation!)),
          _detailRow('Month', Text(DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month)))),
        ]),
        const SizedBox(height: 16),

        // Salary breakdown card
        _buildCard('Salary Breakdown', icon: Icons.calculate_outlined, children: [
          _detailRow('Base Salary', Text('Rs ${NumberFormat('#,##0').format(rec.baseSalary)}')),
          _detailRow('Leaves (Absents)', Text('${rec.leaves}')),
          _detailRow('Absent Deduction', Text('- Rs ${NumberFormat('#,##0').format(rec.absentDeduction)}', style: const TextStyle(color: _kRed, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 16),

        // Adjustments card
        _buildCard('Adjustments & Note', icon: Icons.tune, children: [
          _detailRow('Fine / Deduction', Text('Rs ${NumberFormat('#,##0').format(rec.fine)}', style: const TextStyle(color: _kRed, fontWeight: FontWeight.w600))),
          _detailRow('Bonus / Addition', Text('Rs ${NumberFormat('#,##0').format(rec.bonus)}', style: const TextStyle(color: _kGreen, fontWeight: FontWeight.w600))),
          if (rec.note != null && rec.note!.isNotEmpty) _detailRow('Note', Text(rec.note!)),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCard(String title, {required List<Widget> children, IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: _kPurple),
                const SizedBox(width: 8),
              ],
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kInk)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _kSlate, fontSize: 13)),
          Flexible(
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
              textAlign: TextAlign.right,
              child: value,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Year picker dialog — modern style ──
class _YearPickerDialog extends StatelessWidget {
  final int initialYear, minYear, maxYear;
  const _YearPickerDialog({required this.initialYear, required this.minYear, required this.maxYear});

  @override
  Widget build(BuildContext context) {
    final years = List.generate(maxYear - minYear + 1, (i) => minYear + i).reversed.toList();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Year', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kInk)),
            const SizedBox(height: 14),
            SizedBox(
              height: 240,
              width: 260,
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (ctx, i) {
                  final y = years[i];
                  final selected = y == initialYear;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pop(context, y),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? _kPurpleLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text('$y', style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w400, color: selected ? _kPurple : _kInk)),
                          const Spacer(),
                          if (selected) const Icon(Icons.check, color: _kPurple, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}