//
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/salary_model.dart';
// import '../../providers/employee_transaction_provider.dart';
// import '../../providers/salary_provider.dart';
// import 'generate_salary_screen.dart';
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
// const _kRedBorder = Color(0xFFFCA5A5);
// const _kOrange = Color(0xFFD97706);
// const _kOrangeBg = Color(0xFFFFFBEB);
// const _kOrangeBorder = Color(0xFFFDE68A);
// const _kBlue = Color(0xFF3B82F6);
// const _kBorder = Color(0xFFE5E7EB);
// const _kSurface = Color(0xFFF7F8FB);
// const _kInk = Color(0xFF111827);
// const _kSlate = Color(0xFF6B7280);
// const _kSlateLight = Color(0xFF9CA3AF);
// const double _kDesktopBreakpoint = 900;
//
// // ────────────────────────────────────────────────────────────
// //  Salary List Screen (Kept as is)
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
//   void _openEdit(SalaryRecord record) {
//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (_) => GenerateSalaryScreen(existingRecord: record)))
//         .then((_) => _loadData());
//   }
//
//   Future<void> _confirmDelete(SalaryRecord record) async {
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
//               Text(
//                 'This will permanently remove the salary record for ${record.employeeName}.',
//                 style: TextStyle(fontSize: 13, color: _kSlate),
//                 textAlign: TextAlign.center,
//               ),
//               if (record.isTerminated) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: _kOrangeBg,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: _kOrangeBorder),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.info_outline, color: _kOrange, size: 16),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           '${record.employeeName} will be reinstated (un-terminated) automatically.',
//                           style: const TextStyle(fontSize: 11.5, color: _kOrange),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
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
//
//     if (confirm == true) {
//       try {
//         final wasTerminated = record.isTerminated;
//         await context.read<SalaryProvider>().deleteSalary(
//           record.id!,
//           transactionProvider: context.read<StaffTransactionProvider>(),
//         );
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(wasTerminated
//                   ? 'Record deleted. ${record.employeeName} has been reinstated.'
//                   : 'Record deleted.'),
//               backgroundColor: _kGreen,
//               behavior: SnackBarBehavior.floating,
//             ),
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
//                     const SizedBox(width: 96, child: Text('Actions', style: _headerStyle)),
//                   ],
//                 ),
//               ),
//               ...List.generate(records.length, (i) {
//                 final s = records[i];
//                 final isLast = i == records.length - 1;
//                 final rowColor = s.isTerminated ? _kRedBg.withOpacity(0.5) : null;
//                 return InkWell(
//                   onTap: () => _openDetail(s),
//                   borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: rowColor,
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
//                                 backgroundColor: s.isTerminated ? _kRedBg : _kPurpleSoft,
//                                 child: Text(
//                                   s.employeeName.isNotEmpty ? s.employeeName[0].toUpperCase() : '?',
//                                   style: TextStyle(color: s.isTerminated ? _kRed : _kPurple, fontWeight: FontWeight.w700, fontSize: 12),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(s.employeeName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: _kInk)),
//                                     if (s.isTerminated) ...[
//                                       const SizedBox(height: 2),
//                                       _terminatedBadge(),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(s.designation ?? '—', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: _kSlate)),
//                         ),
//                         // Base Salary column (use baseSalary)
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             'Rs ${NumberFormat('#,##0').format(s.baseSalary)}',
//                             style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk),
//                           ),
//                         ),
//
// // Net Salary column (use final payable amount = payableNetSalary)
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             '${s.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(s.payableNetSalary.abs())}',
//                             style: TextStyle(
//                               fontSize: 13.5,
//                               fontWeight: FontWeight.w700,
//                               color: s.payableNetSalary < 0 ? _kRed : _kInk,
//                             ),
//                           ),
//                         ),
//                         // Expanded(
//                         //   flex: 2,
//                         //   child: Text(
//                         //     '${s.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(s.payableNetSalary.abs())}',
//                         //     style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: s.payableNetSalary < 0 ? _kRed : _kInk),
//                         //   ),
//                         // ),
//                         // Expanded(
//                         //   flex: 2,
//                         //   child: Text('Rs ${NumberFormat('#,##0').format(s.netSalary)}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
//                         // ),
//                         Expanded(
//                           flex: 2,
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: _statusDropdownChip(s, onChanged: (v) => _changeStatusInline(s, v)),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 96,
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.edit_outlined, size: 18, color: _kPurple),
//                                 tooltip: 'Edit',
//                                 onPressed: () => _openEdit(s),
//                                 visualDensity: VisualDensity.compact,
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete_outline, size: 18, color: _kRed),
//                                 tooltip: 'Delete',
//                                 onPressed: () => _confirmDelete(s),
//                                 visualDensity: VisualDensity.compact,
//                               ),
//                             ],
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
//               color: s.isTerminated ? _kRedBg.withOpacity(0.4) : Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: s.isTerminated ? _kRedBorder : _kBorder),
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
//                       backgroundColor: s.isTerminated ? _kRedBg : _kPurpleSoft,
//                       child: Text(
//                         s.employeeName.isNotEmpty ? s.employeeName[0].toUpperCase() : '?',
//                         style: TextStyle(color: s.isTerminated ? _kRed : _kPurple, fontWeight: FontWeight.w700, fontSize: 13),
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
//                     IconButton(
//                       icon: const Icon(Icons.edit_outlined, size: 18, color: _kPurple),
//                       tooltip: 'Edit',
//                       visualDensity: VisualDensity.compact,
//                       onPressed: () => _openEdit(s),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete_outline, size: 18, color: _kRed),
//                       tooltip: 'Delete',
//                       visualDensity: VisualDensity.compact,
//                       onPressed: () => _confirmDelete(s),
//                     ),
//                   ],
//                 ),
//                 if (s.isTerminated) ...[
//                   const SizedBox(height: 8),
//                   _terminatedBadge(),
//                 ],
//                 const SizedBox(height: 8),
//                 Container(height: 1, color: _kBorder),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _mobileStat('Base Salary', 'Rs ${NumberFormat('#,##0').format(s.baseSalary)}'),
//                     ),
//                     Expanded(
//                       child: _mobileStat(
//                         'Net Salary',
//                         '${s.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(s.payableNetSalary.abs())}',
//                         emphasize: true,
//                       ),
//                     ),
//                   ],
//                 ),
// //                 Row(
// //                   children: [
// //                     // Inside _buildDesktopTable, replace the two middle columns with:
// //
// // // Base Salary (was wrongly showing payableNetSalary)
// //                     Expanded(
// //                       flex: 2,
// //                       child: Text(
// //                         'Rs ${NumberFormat('#,##0').format(s.baseSalary)}',
// //                         style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk),
// //                       ),
// //                     ),
// //
// // // Net Salary (now shows the final payable amount)
// //                     Expanded(
// //                       flex: 2,
// //                       child: Text(
// //                         // Use the same formatting as the mobile list (handles negative sign)
// //                         '${s.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(s.payableNetSalary.abs())}',
// //                         style: TextStyle(
// //                           fontSize: 13.5,
// //                           fontWeight: FontWeight.w700,
// //                           color: s.payableNetSalary < 0 ? _kRed : _kInk,
// //                         ),
// //                       ),
// //                     ),
// //
// //                   ],
// //                 ),
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
//   Widget _terminatedBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: _kRedBg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _kRedBorder),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.person_off_rounded, size: 10, color: _kRed),
//           const SizedBox(width: 4),
//           Text(
//             'Terminated',
//             style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kRed),
//           ),
//         ],
//       ),
//     );
//   }
//
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
//
// // ────────────────────────────────────────────────────────────
// //  ✅ UPDATED Salary Detail Screen
// // ────────────────────────────────────────────────────────────
//
//
// // ────────────────────────────────────────────────────────────
// //  Design Tokens
// // ────────────────────────────────────────────────────────────
//
//
// // ────────────────────────────────────────────────────────────
// //  Salary Detail Screen
// // ────────────────────────────────────────────────────────────
// class SalaryDetailScreen extends StatelessWidget {
//   final SalaryRecord record;
//   const SalaryDetailScreen({super.key, required this.record});
//
//   @override
//   Widget build(BuildContext context) {
//     final rec = record;
//     const int totalDays = 30;
//     final int presentDays = totalDays - rec.leaves;
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: _buildAppBar(context),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//           return SingleChildScrollView(
//             padding: EdgeInsets.all(isDesktop ? 24 : 14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (rec.isTerminated) ...[
//                   _terminatedBanner(rec),
//                   const SizedBox(height: 16),
//                 ],
//                 _buildStatsRow(isDesktop),
//                 SizedBox(height: isDesktop ? 20 : 14),
//                 if (isDesktop)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(flex: 3, child: _buildSalaryBreakdown(rec, presentDays)),
//                       const SizedBox(width: 20),
//                       Expanded(flex: 2, child: _buildEmployeeInfo(rec)),
//                     ],
//                   )
//                 else
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildEmployeeInfo(rec),
//                       const SizedBox(height: 14),
//                       _buildSalaryBreakdown(rec, presentDays),
//                     ],
//                   ),
//                 if (rec.note != null && rec.note!.isNotEmpty) ...[
//                   SizedBox(height: isDesktop ? 20 : 14),
//                   _buildNotes(rec.note!),
//                 ],
//                 const SizedBox(height: 12),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ─── App Bar (responsive: desktop shows text+icon buttons, mobile shows icon-only + menu) ───
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       surfaceTintColor: Colors.transparent,
//       leadingWidth: 44,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_rounded, color: _kInk, size: 22),
//         onPressed: () => Navigator.pop(context),
//       ),
//       titleSpacing: 0,
//       title: LayoutBuilder(
//         builder: (context, c) {
//           final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//           return Text(
//             'Salary Details',
//             style: TextStyle(color: _kInk, fontSize: isDesktop ? 18 : 16, fontWeight: FontWeight.w700),
//           );
//         },
//       ),
//       centerTitle: false,
//       actions: [
//         Builder(builder: (context) {
//           final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//           if (isDesktop) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 20),
//               child: Row(
//                 children: [
//                   _actionButton(
//                     icon: Icons.print_outlined,
//                     label: 'Print Slip',
//                     onTap: () {
//                       // TODO: Implement print functionality
//                     },
//                   ),
//                   const SizedBox(width: 10),
//                   _actionButton(
//                     icon: Icons.download_rounded,
//                     label: 'Download PDF',
//                     filled: true,
//                     onTap: () {
//                       // TODO: Implement PDF download
//                     },
//                   ),
//                 ],
//               ),
//             );
//           }
//           // Mobile: compact icon buttons
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.print_outlined, color: _kSlate, size: 22),
//                   tooltip: 'Print Slip',
//                   onPressed: () {
//                     // TODO: Implement print functionality
//                   },
//                 ),
//                 Container(
//                   margin: const EdgeInsets.only(right: 4),
//                   decoration: BoxDecoration(color: _kPurple, borderRadius: BorderRadius.circular(10)),
//                   child: IconButton(
//                     icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
//                     tooltip: 'Download PDF',
//                     onPressed: () {
//                       // TODO: Implement PDF download
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(height: 1, color: _kBorder),
//       ),
//     );
//   }
//
//   Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap, bool filled = false}) {
//     if (filled) {
//       return ElevatedButton.icon(
//         onPressed: onTap,
//         icon: Icon(icon, size: 16, color: Colors.white),
//         label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _kPurple,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     }
//     return OutlinedButton.icon(
//       onPressed: onTap,
//       icon: const Icon(Icons.print_outlined, size: 16, color: _kSlate),
//       label: Text(label, style: const TextStyle(color: _kSlate, fontSize: 13, fontWeight: FontWeight.w600)),
//       style: OutlinedButton.styleFrom(
//         side: const BorderSide(color: _kBorder),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       ),
//     );
//   }
//
//   Widget _terminatedBanner(SalaryRecord rec) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: _kRedBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kRedBorder),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.person_off_rounded, size: 16, color: _kRed),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               '${rec.employeeName} was terminated. This salary record reflects their final month.',
//               style: const TextStyle(fontSize: 12.5, color: _kRed, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Top Stats Row ───
//   Widget _buildStatsRow(bool isDesktop) {
//     final rec = record;
//     final totalDeductions = rec.absentDeduction + rec.fine;
//     final netPayable = rec.payableNetSalary;
//
//     final cards = [
//       _StatCardData(
//         label: 'Base Salary',
//         value: rec.baseSalary,
//         subLabel: 'Monthly gross salary',
//         icon: Icons.account_balance_wallet_outlined,
//         color: _kPurple,
//         bg: _kPurpleLight,
//       ),
//       _StatCardData(
//         label: 'Total Deductions',
//         value: totalDeductions,
//         subLabel: 'Absences + fines',
//         icon: Icons.trending_down_rounded,
//         color: _kRed,
//         bg: _kRedBg,
//       ),
//       _StatCardData(
//         label: 'Total Bonus',
//         value: rec.bonus,
//         subLabel: 'All bonuses',
//         icon: Icons.card_giftcard_rounded,
//         color: _kGreen,
//         bg: _kGreenBg,
//       ),
//       _StatCardData(
//         label: 'Net Salary',
//         value: netPayable,
//         subLabel: 'Payable amount',
//         icon: Icons.account_balance_rounded,
//         color: _kBlue,
//         bg: _kBlue,
//         emphasize: true,
//       ),
//     ];
//
//     if (isDesktop) {
//       return Row(
//         children: List.generate(cards.length, (i) {
//           return Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 14),
//               child: _statCard(cards[i]),
//             ),
//           );
//         }),
//       );
//     }
//
//     // Mobile: 2x2 grid
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final cardWidth = (constraints.maxWidth - 10) / 2;
//         return Wrap(
//           spacing: 10,
//           runSpacing: 10,
//           children: cards.map((c) => SizedBox(width: cardWidth, child: _statCard(c))).toList(),
//         );
//       },
//     );
//   }
//
//   Widget _statCard(_StatCardData data) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBorder),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(color: data.bg, shape: BoxShape.circle),
//             child: Icon(data.icon, size: 18, color: data.color),
//           ),
//           const SizedBox(height: 10),
//           Text(data.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: _kInk)),
//           const SizedBox(height: 2),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerLeft,
//             child: Text(
//               '${data.value < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(data.value.abs())}',
//               style: TextStyle(
//                 fontSize: data.emphasize ? 20 : 18,
//                 fontWeight: FontWeight.w800,
//                 color: data.color,
//               ),
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(data.subLabel, style: const TextStyle(fontSize: 10.5, color: _kSlateLight)),
//         ],
//       ),
//     );
//   }
//
//   // ─── Employee Info Card ───
//   Widget _buildEmployeeInfo(SalaryRecord rec) {
//     return _buildCard(
//       title: 'Employee Information',
//       icon: Icons.person_outline_rounded,
//       children: [
//         _detailRow('Employee Name', rec.employeeName),
//         _detailRow('Employee ID', rec.employeeId ?? 'N/A'),
//         _detailRow('Designation', rec.designation ?? 'N/A'),
//         _detailRow('Department', 'Computer Science'),
//         _detailRow('Joining Date', '12 Jan 2025'),
//         _detailRow('Salary Month', DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month))),
//         _detailRow('Generated Date', DateFormat('dd MMM yyyy').format(rec.generatedDate)),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Status', style: TextStyle(color: _kSlate, fontSize: 13)),
//               _statusChip(rec.status),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Salary Breakdown Card ───
//   Widget _buildSalaryBreakdown(SalaryRecord rec, int presentDays) {
//     return _buildCard(
//       title: 'Salary Breakdown',
//       icon: Icons.receipt_long_outlined,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//           decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
//           child: Row(
//             children: [
//               Expanded(flex: 3, child: Text('Description', style: _breakdownHeaderStyle())),
//               Expanded(flex: 3, child: Text('Details', style: _breakdownHeaderStyle())),
//               Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: _breakdownHeaderStyle())),
//             ],
//           ),
//         ),
//         const SizedBox(height: 4),
//         _breakdownRow('Base Salary', 'Monthly fixed salary', 'Rs ${NumberFormat('#,##0').format(rec.baseSalary)}', isBold: true),
//         _breakdownRow('Present Days', '$presentDays days', '—'),
//         _breakdownRow('Absent Days', '${rec.leaves} days', '—'),
//         _breakdownRow(
//           'Absent Deduction',
//           '${rec.leaves} days × Rs ${NumberFormat('#,##0').format(rec.perDayRate)}',
//           '-Rs ${NumberFormat('#,##0').format(rec.absentDeduction)}',
//           isRed: true,
//         ),
//         if (rec.fine > 0)
//           _breakdownRow('Fine / Deduction', 'Disciplinary fine', '-Rs ${NumberFormat('#,##0').format(rec.fine)}', isRed: true),
//         if (rec.bonus > 0)
//           _breakdownRow('Bonus / Addition', 'Performance bonus', '+Rs ${NumberFormat('#,##0').format(rec.bonus)}', isGreen: true),
//         // ★ NEW — Balance deduction row, only shown if this salary had a
//         // ledger deduction recorded against the employee's balance.
//         if (rec.recordInLedger && rec.ledgerDeductionAmount != 0)
//           _breakdownRow(
//             'Balance Deduction',
//             'Deducted from employee balance',
//             '-Rs ${NumberFormat('#,##0').format(rec.ledgerDeductionAmount)}',
//             isRed: true,
//           ),
//         const SizedBox(height: 10),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           decoration: BoxDecoration(
//             // ★ NEW — red-tinted box when net payable has gone negative
//             // (deduction exceeded the calculated net salary).
//             color: rec.payableNetSalary < 0 ? _kRedBg : _kPurpleLight,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: rec.payableNetSalary < 0 ? _kRedBorder : _kPurpleSoft),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Net Payable Salary',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                   color: rec.payableNetSalary < 0 ? _kRed : _kPurpleDark,
//                 ),
//               ),
//               Text(
//                 // ★ NEW — leading "- " shown when payable amount is negative,
//                 // instead of formatting it as a positive number.
//                 '${rec.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(rec.payableNetSalary.abs())}',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 17,
//                   color: rec.payableNetSalary < 0 ? _kRed : _kPurpleDark,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//   // Widget _buildSalaryBreakdown(SalaryRecord rec, int presentDays) {
//   //   return _buildCard(
//   //     title: 'Salary Breakdown',
//   //     icon: Icons.receipt_long_outlined,
//   //     children: [
//   //       Container(
//   //         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//   //         decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
//   //         child: Row(
//   //           children: [
//   //             Expanded(flex: 3, child: Text('Description', style: _breakdownHeaderStyle())),
//   //             Expanded(flex: 3, child: Text('Details', style: _breakdownHeaderStyle())),
//   //             Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: _breakdownHeaderStyle())),
//   //           ],
//   //         ),
//   //       ),
//   //       const SizedBox(height: 4),
//   //       _breakdownRow('Base Salary', 'Monthly fixed salary', 'Rs ${NumberFormat('#,##0').format(rec.baseSalary)}', isBold: true),
//   //       _breakdownRow('Present Days', '$presentDays days', '—'),
//   //       _breakdownRow('Absent Days', '${rec.leaves} days', '—'),
//   //       _breakdownRow(
//   //         'Absent Deduction',
//   //         '${rec.leaves} days × Rs ${NumberFormat('#,##0').format(rec.perDayRate)}',
//   //         '-Rs ${NumberFormat('#,##0').format(rec.absentDeduction)}',
//   //         isRed: true,
//   //       ),
//   //       if (rec.fine > 0)
//   //         _breakdownRow('Fine / Deduction', 'Disciplinary fine', '-Rs ${NumberFormat('#,##0').format(rec.fine)}', isRed: true),
//   //       if (rec.bonus > 0)
//   //         _breakdownRow('Bonus / Addition', 'Performance bonus', '+Rs ${NumberFormat('#,##0').format(rec.bonus)}', isGreen: true),
//   //       const SizedBox(height: 10),
//   //       Container(
//   //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//   //         decoration: BoxDecoration(
//   //           color: _kPurpleLight,
//   //           borderRadius: BorderRadius.circular(10),
//   //           border: Border.all(color: _kPurpleSoft),
//   //         ),
//   //         child: Row(
//   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //           children: [
//   //             const Text('Net Payable Salary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _kPurpleDark)),
//   //             Text(
//   //               'Rs ${NumberFormat('#,##0').format(rec.payableNetSalary)}',
//   //               style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: _kPurpleDark),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   // ─── Notes Card ───
//   Widget _buildNotes(String note) {
//     final lines = note.split('\n').where((l) => l.trim().isNotEmpty).toList();
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _kOrangeBg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kOrangeBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.sticky_note_2_outlined, size: 18, color: _kOrange),
//               SizedBox(width: 8),
//               Text('Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF92400E))),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...lines.map((line) => Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('•  ', style: TextStyle(color: Color(0xFF92400E), fontSize: 14, fontWeight: FontWeight.w700)),
//                 Expanded(
//                   child: Text(line, style: const TextStyle(color: Color(0xFF78350F), fontSize: 13, height: 1.5)),
//                 ),
//               ],
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   // ─── Shared Helpers ───
//
//   Widget _statusChip(String status) {
//     final isPaid = status == 'Paid';
//     final bg = isPaid ? _kGreenBg : _kOrangeBg;
//     final fg = isPaid ? _kGreen : _kOrange;
//     final border = isPaid ? _kGreenBorder : _kOrangeBorder;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(isPaid ? Icons.check_circle : Icons.schedule, size: 13, color: fg),
//           const SizedBox(width: 4),
//           Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBorder),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(color: _kPurpleLight, borderRadius: BorderRadius.circular(8)),
//                 child: Icon(icon, size: 16, color: _kPurple),
//               ),
//               const SizedBox(width: 8),
//               Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: _kInk)),
//             ],
//           ),
//           const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: _kBorder)),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(label, style: const TextStyle(color: _kSlate, fontSize: 13)),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _breakdownRow(String label, String details, String amount, {bool isBold = false, bool isRed = false, bool isGreen = false}) {
//     Color textColor = _kInk;
//     if (isRed) textColor = _kRed;
//     if (isGreen) textColor = _kGreen;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.w600 : FontWeight.w400, fontSize: 13, color: textColor)),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(details, style: const TextStyle(fontSize: 12, color: _kSlate)),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               amount,
//               textAlign: TextAlign.right,
//               style: TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, fontSize: 13, color: textColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   TextStyle _breakdownHeaderStyle() {
//     return const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _kSlate, letterSpacing: 0.3);
//   }
// }
//
// class _StatCardData {
//   final String label;
//   final double value;
//   final String subLabel;
//   final IconData icon;
//   final Color color;
//   final Color bg;
//   final bool emphasize;
//
//   _StatCardData({
//     required this.label,
//     required this.value,
//     required this.subLabel,
//     required this.icon,
//     required this.color,
//     required this.bg,
//     this.emphasize = false,
//   });
// }
// // class SalaryDetailScreen extends StatelessWidget {
// //   final SalaryRecord record;
// //   const SalaryDetailScreen({super.key, required this.record});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final rec = record;
// //     final int totalDays = 30; // Assuming standard month
// //     final int presentDays = totalDays - rec.leaves;
// //
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8FAFC),
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         scrolledUnderElevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: const Text(
// //           'Salary Details',
// //           style: TextStyle(
// //             color: Color(0xFF111827),
// //             fontSize: 18,
// //             fontWeight: FontWeight.w700,
// //           ),
// //         ),
// //         centerTitle: true,
// //         actions: [
// //           // Print Slip Button
// //           OutlinedButton.icon(
// //             onPressed: () {
// //               // TODO: Implement print functionality
// //             },
// //             icon: const Icon(Icons.print, size: 14, color: _kSlate),
// //             label: const Text('Print Slip', style: TextStyle(color: _kSlate, fontSize: 13, fontWeight: FontWeight.w600)),
// //             style: OutlinedButton.styleFrom(
// //               side: const BorderSide(color: _kBorder),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           // Download PDF Button
// //           OutlinedButton.icon(
// //             onPressed: () {
// //               // TODO: Implement PDF download
// //             },
// //             icon: const Icon(Icons.download_rounded, size: 14, color: _kSlate),
// //             label: const Text('Download PDF', style: TextStyle(color: _kSlate, fontSize: 13, fontWeight: FontWeight.w600)),
// //             style: OutlinedButton.styleFrom(
// //               side: const BorderSide(color: _kBorder),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //         ],
// //       ),
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final isDesktop = constraints.maxWidth >= 900;
// //           return SingleChildScrollView(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // 1. Top Stats Row (4 Cards)
// //                 _buildStatsRow(rec),
// //                 const SizedBox(height: 24),
// //
// //                 // 2. Middle Section (Desktop: Row, Mobile: Column)
// //                 if (isDesktop)
// //                   Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Expanded(flex: 2, child: _buildSalaryBreakdown(rec, presentDays)),
// //                       const SizedBox(width: 20),
// //                       Expanded(flex: 1, child: _buildEmployeeInfo(rec)),
// //                     ],
// //                   )
// //                 else
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       _buildSalaryBreakdown(rec, presentDays),
// //                       const SizedBox(height: 20),
// //                       _buildEmployeeInfo(rec),
// //                     ],
// //                   ),
// //
// //                 const SizedBox(height: 20),
// //
// //                 // 3. Notes
// //                 if (rec.note != null && rec.note!.isNotEmpty)
// //                   _buildNotes(rec.note!),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   // ─── Top Stats Row ───
// //   Widget _buildStatsRow(SalaryRecord rec) {
// //     final totalDeductions = rec.absentDeduction + rec.fine;
// //     final netPayable = rec.payableNetSalary;
// //
// //     // Use Wrap to handle small screens gracefully (2x2 grid if space gets tight)
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         final isMobile = constraints.maxWidth < 600;
// //         return Wrap(
// //           spacing: 12,
// //           runSpacing: 12,
// //           children: [
// //             _buildStatCard(
// //               label: 'Base Salary',
// //               value: 'Rs ${NumberFormat('#,##0').format(rec.baseSalary)}',
// //               subLabel: 'Monthly Gross Salary',
// //               icon: Icons.account_balance_wallet_outlined,
// //               color: _kPurple,
// //               width: isMobile ? (constraints.maxWidth / 2) - 6 : null,
// //             ),
// //             _buildStatCard(
// //               label: 'Total Deductions',
// //               value: 'Rs ${NumberFormat('#,##0').format(totalDeductions)}',
// //               subLabel: 'All Deductions',
// //               icon: Icons.trending_down_rounded,
// //               color: _kRed,
// //               width: isMobile ? (constraints.maxWidth / 2) - 6 : null,
// //             ),
// //             _buildStatCard(
// //               label: 'Total Bonus',
// //               value: 'Rs ${NumberFormat('#,##0').format(rec.bonus)}',
// //               subLabel: 'All Bonuses',
// //               icon: Icons.card_giftcard,
// //               color: _kGreen,
// //               width: isMobile ? (constraints.maxWidth / 2) - 6 : null,
// //             ),
// //             _buildStatCard(
// //               label: 'Net Salary',
// //               value: 'Rs ${NumberFormat('#,##0').format(netPayable)}',
// //               subLabel: 'Payable Amount',
// //               icon: Icons.account_balance_rounded,
// //               color: _kBlue,
// //               width: isMobile ? (constraints.maxWidth / 2) - 6 : null,
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _buildStatCard({
// //     required String label,
// //     required String value,
// //     required String subLabel,
// //     required IconData icon,
// //     required Color color,
// //     double? width,
// //   }) {
// //     return Container(
// //       width: width,
// //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: _kBorder),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   color: color.withOpacity(0.1),
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: Icon(icon, size: 20, color: color),
// //               ),
// //               const SizedBox(width: 10),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     label,
// //                     style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
// //                   ),
// //                   Text(
// //                     subLabel,
// //                     style: const TextStyle(fontSize: 11, color: _kSlateLight),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 12),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.w800,
// //               color: color,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ─── Employee Info Card ───
// //   Widget _buildEmployeeInfo(SalaryRecord rec) {
// //     return _buildCard(
// //       title: 'Employee Information',
// //       icon: Icons.person_outline,
// //       children: [
// //         _detailRow('Employee Name', Text(rec.employeeName)),
// //         _detailRow('Employee ID', Text(rec.employeeId ?? 'N/A')),
// //         _detailRow('Designation', Text(rec.designation ?? 'N/A')),
// //         _detailRow('Department', Text('Computer Science')), // Hardcoded as per image, or you can use rec.department if available
// //         _detailRow('Joining Date', Text('12 Jan 2025')),    // Placeholder as per image
// //         _detailRow('Salary Month', Text(DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month)))),
// //         _detailRow('Generated Date', Text(DateFormat('dd MMM yyyy').format(rec.generatedDate))),
// //         _detailRow('Status', _statusChip(rec.status)),
// //       ],
// //     );
// //   }
// //
// //   // ─── Salary Breakdown Card ───
// //   Widget _buildSalaryBreakdown(SalaryRecord rec, int presentDays) {
// //     return _buildCard(
// //       title: 'Salary Breakdown',
// //       icon: Icons.receipt_long_outlined,
// //       children: [
// //         // Table Header
// //         Container(
// //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
// //           decoration: BoxDecoration(
// //             color: const Color(0xFFF3F4F6),
// //             borderRadius: BorderRadius.circular(6),
// //           ),
// //           child: Row(
// //             children: [
// //               Expanded(flex: 3, child: Text('Description', style: _breakdownHeaderStyle())),
// //               Expanded(flex: 3, child: Text('Details', style: _breakdownHeaderStyle())),
// //               Expanded(flex: 2, child: Text('Amount', style: _breakdownHeaderStyle(textAlign: TextAlign.right))),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //
// //         // Data Rows
// //         _breakdownRow('Base Salary', 'Monthly Fixed Salary', 'Rs ${NumberFormat('#,##0').format(rec.baseSalary)}', isBold: true),
// //         _breakdownRow('Present Days', '$presentDays Days', '-'),
// //         _breakdownRow('Absent Days', '${rec.leaves} Days', '-'),
// //         _breakdownRow('Absent Deduction', '${rec.leaves} Days × Rs ${NumberFormat('#,##0').format(rec.perDayRate)}', '-Rs ${NumberFormat('#,##0').format(rec.absentDeduction)}', isRed: true),
// //
// //         if (rec.fine > 0)
// //           _breakdownRow('Fine / Deduction', 'Disciplinary Fine', 'Rs ${NumberFormat('#,##0').format(rec.fine)}', isRed: true),
// //
// //         if (rec.bonus > 0)
// //           _breakdownRow('Bonus / Addition', 'Performance Bonus', '+Rs ${NumberFormat('#,##0').format(rec.bonus)}', isGreen: true),
// //
// //         const SizedBox(height: 12),
// //
// //         // Footer Total (Highlighted Background as in Image)
// //         Container(
// //           padding: const EdgeInsets.all(12),
// //           decoration: BoxDecoration(
// //             color: _kPurpleLight,
// //             borderRadius: BorderRadius.circular(8),
// //             border: Border.all(color: _kPurpleSoft),
// //           ),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'Net Payable Salary',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.w700,
// //                   fontSize: 14,
// //                   color: _kBlue,
// //                 ),
// //               ),
// //               Text(
// //                 'Rs ${NumberFormat('#,##0').format(rec.payableNetSalary)}',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.w800,
// //                   fontSize: 15,
// //                   color: _kBlue,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   // ─── Notes Card ───
// //   Widget _buildNotes(String note) {
// //     final lines = note.split('\n').where((l) => l.trim().isNotEmpty).toList();
// //
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: _kOrangeBg,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: _kOrangeBorder),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               const Icon(Icons.note_outlined, size: 18, color: Color(0xFFD97706)),
// //               const SizedBox(width: 8),
// //               const Text(
// //                 'Notes',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.w700,
// //                   fontSize: 14,
// //                   color: Color(0xFF92400E),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 12),
// //           ...lines.map((line) => Padding(
// //             padding: const EdgeInsets.only(bottom: 6),
// //             child: Row(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text('• ', style: TextStyle(color: Color(0xFF92400E), fontSize: 14)),
// //                 Expanded(
// //                   child: Text(
// //                     line,
// //                     style: const TextStyle(color: Color(0xFF78350F), fontSize: 13, height: 1.5),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ─── Helper Widgets ───
// //
// //   Widget _statusChip(String status) {
// //     final isPaid = status == 'Paid';
// //     final bg = isPaid ? const Color(0xFFECFDF3) : const Color(0xFFFFFBEB);
// //     final fg = isPaid ? _kGreen : const Color(0xFFD97706);
// //     final border = isPaid ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A);
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: bg,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: border),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(isPaid ? Icons.check_circle : Icons.schedule, size: 14, color: fg),
// //           const SizedBox(width: 4),
// //           Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: _kBorder),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(icon, size: 18, color: _kPurple),
// //               const SizedBox(width: 8),
// //               Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF111827))),
// //             ],
// //           ),
// //           const Padding(
// //             padding: EdgeInsets.symmetric(vertical: 12),
// //             child: Divider(height: 1, color: _kBorder),
// //           ),
// //           ...children,
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _detailRow(String label, Widget value, {FontWeight fontWeight = FontWeight.w600}) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Expanded(
// //             flex: 2,
// //             child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
// //           ),
// //           Expanded(
// //             flex: 3,
// //             child: DefaultTextStyle.merge(
// //               style: TextStyle(fontWeight: fontWeight, fontSize: 13, color: const Color(0xFF111827)),
// //               textAlign: TextAlign.right,
// //               child: value,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _breakdownRow(String label, String details, String amount, {bool isBold = false, bool isRed = false, bool isGreen = false}) {
// //     Color textColor = const Color(0xFF111827);
// //     if (isRed) textColor = _kRed;
// //     if (isGreen) textColor = _kGreen;
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8),
// //       child: Row(
// //         children: [
// //           Expanded(flex: 3, child: Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.w600 : FontWeight.w400, fontSize: 13, color: textColor))),
// //           Expanded(flex: 3, child: Text(details, style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)))),
// //           Expanded(flex: 2, child: Text(amount, textAlign: TextAlign.right, style: TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, fontSize: 13, color: textColor))),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   TextStyle _breakdownHeaderStyle({TextAlign textAlign = TextAlign.left}) {
// //     return TextStyle(
// //       fontSize: 12,
// //       fontWeight: FontWeight.w700,
// //       color: const Color(0xFF6B7280),
// //       letterSpacing: 0.3,
// //     );
// //   }
// // }
//
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

//final file
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/salary_model.dart';
// import '../../pdf_files/salary_pdf_service.dart';
// import '../../providers/employee_transaction_provider.dart';
// import '../../providers/salary_provider.dart';
// import 'generate_salary_screen.dart';
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
// const _kRedBorder = Color(0xFFFCA5A5);
// const _kOrange = Color(0xFFD97706);
// const _kOrangeBg = Color(0xFFFFFBEB);
// const _kOrangeBorder = Color(0xFFFDE68A);
// const _kBlue = Color(0xFF3B82F6);
// const _kBorder = Color(0xFFE5E7EB);
// const _kSurface = Color(0xFFF7F8FB);
// const _kInk = Color(0xFF111827);
// const _kSlate = Color(0xFF6B7280);
// const _kSlateLight = Color(0xFF9CA3AF);
// const double _kDesktopBreakpoint = 900;
//
// // ────────────────────────────────────────────────────────────
// //  Salary List Screen (Kept as is)
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
//   void _openEdit(SalaryRecord record) {
//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (_) => GenerateSalaryScreen(existingRecord: record)))
//         .then((_) => _loadData());
//   }
//
//   Future<void> _confirmDelete(SalaryRecord record) async {
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
//               Text(
//                 'This will permanently remove the salary record for ${record.employeeName}.',
//                 style: TextStyle(fontSize: 13, color: _kSlate),
//                 textAlign: TextAlign.center,
//               ),
//               if (record.isTerminated) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: _kOrangeBg,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: _kOrangeBorder),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.info_outline, color: _kOrange, size: 16),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           '${record.employeeName} will be reinstated (un-terminated) automatically.',
//                           style: const TextStyle(fontSize: 11.5, color: _kOrange),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
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
//
//     if (confirm == true) {
//       try {
//         final wasTerminated = record.isTerminated;
//         await context.read<SalaryProvider>().deleteSalary(
//           record.id!,
//           transactionProvider: context.read<StaffTransactionProvider>(),
//         );
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(wasTerminated
//                   ? 'Record deleted. ${record.employeeName} has been reinstated.'
//                   : 'Record deleted.'),
//               backgroundColor: _kGreen,
//               behavior: SnackBarBehavior.floating,
//             ),
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
//                     const SizedBox(width: 96, child: Text('Actions', style: _headerStyle)),
//                   ],
//                 ),
//               ),
//               ...List.generate(records.length, (i) {
//                 final s = records[i];
//                 final isLast = i == records.length - 1;
//                 final rowColor = s.isTerminated ? _kRedBg.withOpacity(0.5) : null;
//                 return InkWell(
//                   onTap: () => _openDetail(s),
//                   borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: rowColor,
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
//                                 backgroundColor: s.isTerminated ? _kRedBg : _kPurpleSoft,
//                                 child: Text(
//                                   s.employeeName.isNotEmpty ? s.employeeName[0].toUpperCase() : '?',
//                                   style: TextStyle(color: s.isTerminated ? _kRed : _kPurple, fontWeight: FontWeight.w700, fontSize: 12),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(s.employeeName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: _kInk)),
//                                     if (s.isTerminated) ...[
//                                       const SizedBox(height: 2),
//                                       _terminatedBadge(),
//                                     ],
//                                   ],
//                                 ),
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
//                           child: Text(
//                             'Rs ${NumberFormat('#,##0').format(s.baseSalary)}',
//                             style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             '${s.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(s.payableNetSalary.abs())}',
//                             style: TextStyle(
//                               fontSize: 13.5,
//                               fontWeight: FontWeight.w700,
//                               color: s.payableNetSalary < 0 ? _kRed : _kInk,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: _statusDropdownChip(s, onChanged: (v) => _changeStatusInline(s, v)),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 96,
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.edit_outlined, size: 18, color: _kPurple),
//                                 tooltip: 'Edit',
//                                 onPressed: () => _openEdit(s),
//                                 visualDensity: VisualDensity.compact,
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete_outline, size: 18, color: _kRed),
//                                 tooltip: 'Delete',
//                                 onPressed: () => _confirmDelete(s),
//                                 visualDensity: VisualDensity.compact,
//                               ),
//                             ],
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
//               color: s.isTerminated ? _kRedBg.withOpacity(0.4) : Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: s.isTerminated ? _kRedBorder : _kBorder),
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
//                       backgroundColor: s.isTerminated ? _kRedBg : _kPurpleSoft,
//                       child: Text(
//                         s.employeeName.isNotEmpty ? s.employeeName[0].toUpperCase() : '?',
//                         style: TextStyle(color: s.isTerminated ? _kRed : _kPurple, fontWeight: FontWeight.w700, fontSize: 13),
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
//                     IconButton(
//                       icon: const Icon(Icons.edit_outlined, size: 18, color: _kPurple),
//                       tooltip: 'Edit',
//                       visualDensity: VisualDensity.compact,
//                       onPressed: () => _openEdit(s),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete_outline, size: 18, color: _kRed),
//                       tooltip: 'Delete',
//                       visualDensity: VisualDensity.compact,
//                       onPressed: () => _confirmDelete(s),
//                     ),
//                   ],
//                 ),
//                 if (s.isTerminated) ...[
//                   const SizedBox(height: 8),
//                   _terminatedBadge(),
//                 ],
//                 const SizedBox(height: 8),
//                 Container(height: 1, color: _kBorder),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _mobileStat('Base Salary', 'Rs ${NumberFormat('#,##0').format(s.baseSalary)}'),
//                     ),
//                     Expanded(
//                       child: _mobileStat(
//                         'Net Salary',
//                         '${s.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(s.payableNetSalary.abs())}',
//                         emphasize: true,
//                       ),
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
//   Widget _terminatedBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: _kRedBg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _kRedBorder),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.person_off_rounded, size: 10, color: _kRed),
//           const SizedBox(width: 4),
//           Text(
//             'Terminated',
//             style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kRed),
//           ),
//         ],
//       ),
//     );
//   }
//
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
//
// // ────────────────────────────────────────────────────────────
// //  Salary Detail Screen
// //  ★ NOW STATEFUL — needed to track PDF loading state for the
// //    Print / Download buttons (spinner while generating).
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
//   bool _isDownloading = false;
//   bool _isPrinting = false;
//
//   SalaryRecord get rec => widget.record;
//
//   // ★ NEW — Download PDF: generates the slip and, on web, triggers a
//   // browser download; on mobile/desktop, opens the native share/save
//   // sheet so the user can save it or open it directly in a PDF viewer.
//   Future<void> _handleDownload() async {
//     if (_isDownloading) return;
//     setState(() => _isDownloading = true);
//     try {
//       await SalaryPdfService.downloadAndOpen(rec);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Salary slip downloaded'),
//             backgroundColor: _kGreen,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to download PDF: $e'), backgroundColor: _kRed, behavior: SnackBarBehavior.floating),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isDownloading = false);
//     }
//   }
//
//   // ★ NEW — Print Slip: opens the system print dialog (works via the
//   // browser's print dialog on web, and the native print/share sheet
//   // on mobile/desktop).
//   Future<void> _handlePrint() async {
//     if (_isPrinting) return;
//     setState(() => _isPrinting = true);
//     try {
//       await SalaryPdfService.printSlip(rec);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to print: $e'), backgroundColor: _kRed, behavior: SnackBarBehavior.floating),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isPrinting = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const int totalDays = 30;
//     final int presentDays = totalDays - rec.leaves;
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: _buildAppBar(context),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//           return SingleChildScrollView(
//             padding: EdgeInsets.all(isDesktop ? 24 : 14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (rec.isTerminated) ...[
//                   _terminatedBanner(rec),
//                   const SizedBox(height: 16),
//                 ],
//                 _buildStatsRow(isDesktop),
//                 SizedBox(height: isDesktop ? 20 : 14),
//                 if (isDesktop)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(flex: 3, child: _buildSalaryBreakdown(rec, presentDays)),
//                       const SizedBox(width: 20),
//                       Expanded(flex: 2, child: _buildEmployeeInfo(rec)),
//                     ],
//                   )
//                 else
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildEmployeeInfo(rec),
//                       const SizedBox(height: 14),
//                       _buildSalaryBreakdown(rec, presentDays),
//                     ],
//                   ),
//                 if (rec.note != null && rec.note!.isNotEmpty) ...[
//                   SizedBox(height: isDesktop ? 20 : 14),
//                   _buildNotes(rec.note!),
//                 ],
//                 const SizedBox(height: 12),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ─── App Bar (responsive: desktop shows text+icon buttons, mobile shows icon-only) ───
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       surfaceTintColor: Colors.transparent,
//       leadingWidth: 44,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_rounded, color: _kInk, size: 22),
//         onPressed: () => Navigator.pop(context),
//       ),
//       titleSpacing: 0,
//       title: LayoutBuilder(
//         builder: (context, c) {
//           final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//           return Text(
//             'Salary Details',
//             style: TextStyle(color: _kInk, fontSize: isDesktop ? 18 : 16, fontWeight: FontWeight.w700),
//           );
//         },
//       ),
//       centerTitle: false,
//       actions: [
//         Builder(builder: (context) {
//           final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//           if (isDesktop) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 20),
//               child: Row(
//                 children: [
//                   _actionButton(
//                     icon: Icons.print_outlined,
//                     label: 'Print Slip',
//                     loading: _isPrinting,
//                     onTap: _handlePrint,
//                   ),
//                   const SizedBox(width: 10),
//                   _actionButton(
//                     icon: Icons.download_rounded,
//                     label: 'Download PDF',
//                     filled: true,
//                     loading: _isDownloading,
//                     onTap: _handleDownload,
//                   ),
//                 ],
//               ),
//             );
//           }
//           // Mobile: compact icon buttons
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: _isPrinting
//                       ? const SizedBox(
//                     width: 18,
//                     height: 18,
//                     child: CircularProgressIndicator(strokeWidth: 2, color: _kSlate),
//                   )
//                       : const Icon(Icons.print_outlined, color: _kSlate, size: 22),
//                   tooltip: 'Print Slip',
//                   onPressed: _isPrinting ? null : _handlePrint,
//                 ),
//                 Container(
//                   margin: const EdgeInsets.only(right: 4),
//                   decoration: BoxDecoration(color: _kPurple, borderRadius: BorderRadius.circular(10)),
//                   child: IconButton(
//                     icon: _isDownloading
//                         ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                     )
//                         : const Icon(Icons.download_rounded, color: Colors.white, size: 20),
//                     tooltip: 'Download PDF',
//                     onPressed: _isDownloading ? null : _handleDownload,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(height: 1, color: _kBorder),
//       ),
//     );
//   }
//
//   Widget _actionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     bool filled = false,
//     bool loading = false,
//   }) {
//     final spinner = SizedBox(
//       width: 14,
//       height: 14,
//       child: CircularProgressIndicator(strokeWidth: 2, color: filled ? Colors.white : _kSlate),
//     );
//
//     if (filled) {
//       return ElevatedButton.icon(
//         onPressed: loading ? null : onTap,
//         icon: loading ? spinner : Icon(icon, size: 16, color: Colors.white),
//         label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _kPurple,
//           disabledBackgroundColor: _kPurple.withOpacity(0.7),
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     }
//     return OutlinedButton.icon(
//       onPressed: loading ? null : onTap,
//       icon: loading ? spinner : const Icon(Icons.print_outlined, size: 16, color: _kSlate),
//       label: Text(label, style: const TextStyle(color: _kSlate, fontSize: 13, fontWeight: FontWeight.w600)),
//       style: OutlinedButton.styleFrom(
//         side: const BorderSide(color: _kBorder),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       ),
//     );
//   }
//
//   Widget _terminatedBanner(SalaryRecord rec) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: _kRedBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kRedBorder),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.person_off_rounded, size: 16, color: _kRed),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               '${rec.employeeName} was terminated. This salary record reflects their final month.',
//               style: const TextStyle(fontSize: 12.5, color: _kRed, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Top Stats Row ───
//   Widget _buildStatsRow(bool isDesktop) {
//     final totalDeductions = rec.absentDeduction + rec.fine;
//     final netPayable = rec.payableNetSalary;
//
//     final cards = [
//       _StatCardData(
//         label: 'Base Salary',
//         value: rec.baseSalary,
//         subLabel: 'Monthly gross salary',
//         icon: Icons.account_balance_wallet_outlined,
//         color: _kPurple,
//         bg: _kPurpleLight,
//       ),
//       _StatCardData(
//         label: 'Total Deductions',
//         value: totalDeductions,
//         subLabel: 'Absences + fines',
//         icon: Icons.trending_down_rounded,
//         color: _kRed,
//         bg: _kRedBg,
//       ),
//       _StatCardData(
//         label: 'Total Bonus',
//         value: rec.bonus,
//         subLabel: 'All bonuses',
//         icon: Icons.card_giftcard_rounded,
//         color: _kGreen,
//         bg: _kGreenBg,
//       ),
//       _StatCardData(
//         label: 'Net Salary',
//         value: netPayable,
//         subLabel: 'Payable amount',
//         icon: Icons.account_balance_rounded,
//         color: _kBlue,
//         bg: _kBlue,
//         emphasize: true,
//       ),
//     ];
//
//     if (isDesktop) {
//       return Row(
//         children: List.generate(cards.length, (i) {
//           return Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 14),
//               child: _statCard(cards[i]),
//             ),
//           );
//         }),
//       );
//     }
//
//     // Mobile: 2x2 grid
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final cardWidth = (constraints.maxWidth - 10) / 2;
//         return Wrap(
//           spacing: 10,
//           runSpacing: 10,
//           children: cards.map((c) => SizedBox(width: cardWidth, child: _statCard(c))).toList(),
//         );
//       },
//     );
//   }
//
//   Widget _statCard(_StatCardData data) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBorder),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(color: data.bg, shape: BoxShape.circle),
//             child: Icon(data.icon, size: 18, color: data.color),
//           ),
//           const SizedBox(height: 10),
//           Text(data.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: _kInk)),
//           const SizedBox(height: 2),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerLeft,
//             child: Text(
//               '${data.value < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(data.value.abs())}',
//               style: TextStyle(
//                 fontSize: data.emphasize ? 20 : 18,
//                 fontWeight: FontWeight.w800,
//                 color: data.color,
//               ),
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(data.subLabel, style: const TextStyle(fontSize: 10.5, color: _kSlateLight)),
//         ],
//       ),
//     );
//   }
//
//   // ─── Employee Info Card ───
//   Widget _buildEmployeeInfo(SalaryRecord rec) {
//     return _buildCard(
//       title: 'Employee Information',
//       icon: Icons.person_outline_rounded,
//       children: [
//         _detailRow('Employee Name', rec.employeeName),
//         _detailRow('Employee ID', rec.employeeId ?? 'N/A'),
//         _detailRow('Designation', rec.designation ?? 'N/A'),
//         _detailRow('Department', 'Computer Science'),
//         _detailRow('Joining Date', '12 Jan 2025'),
//         _detailRow('Salary Month', DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month))),
//         _detailRow('Generated Date', DateFormat('dd MMM yyyy').format(rec.generatedDate)),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Status', style: TextStyle(color: _kSlate, fontSize: 13)),
//               _statusChip(rec.status),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Salary Breakdown Card ───
//   Widget _buildSalaryBreakdown(SalaryRecord rec, int presentDays) {
//     return _buildCard(
//       title: 'Salary Breakdown',
//       icon: Icons.receipt_long_outlined,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//           decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
//           child: Row(
//             children: [
//               Expanded(flex: 3, child: Text('Description', style: _breakdownHeaderStyle())),
//               Expanded(flex: 3, child: Text('Details', style: _breakdownHeaderStyle())),
//               Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: _breakdownHeaderStyle())),
//             ],
//           ),
//         ),
//         const SizedBox(height: 4),
//         _breakdownRow('Base Salary', 'Monthly fixed salary', 'Rs ${NumberFormat('#,##0').format(rec.baseSalary)}', isBold: true),
//         _breakdownRow('Present Days', '$presentDays days', '—'),
//         _breakdownRow('Absent Days', '${rec.leaves} days', '—'),
//         _breakdownRow(
//           'Absent Deduction',
//           '${rec.leaves} days × Rs ${NumberFormat('#,##0').format(rec.perDayRate)}',
//           '-Rs ${NumberFormat('#,##0').format(rec.absentDeduction)}',
//           isRed: true,
//         ),
//         if (rec.fine > 0)
//           _breakdownRow('Fine / Deduction', 'Disciplinary fine', '-Rs ${NumberFormat('#,##0').format(rec.fine)}', isRed: true),
//         if (rec.bonus > 0)
//           _breakdownRow('Bonus / Addition', 'Performance bonus', '+Rs ${NumberFormat('#,##0').format(rec.bonus)}', isGreen: true),
//         if (rec.recordInLedger && rec.ledgerDeductionAmount != 0)
//           _breakdownRow(
//             'Balance Deduction',
//             'Deducted from employee balance',
//             '-Rs ${NumberFormat('#,##0').format(rec.ledgerDeductionAmount)}',
//             isRed: true,
//           ),
//         const SizedBox(height: 10),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           decoration: BoxDecoration(
//             color: rec.payableNetSalary < 0 ? _kRedBg : _kPurpleLight,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: rec.payableNetSalary < 0 ? _kRedBorder : _kPurpleSoft),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Net Payable Salary',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                   color: rec.payableNetSalary < 0 ? _kRed : _kPurpleDark,
//                 ),
//               ),
//               Text(
//                 '${rec.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(rec.payableNetSalary.abs())}',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 17,
//                   color: rec.payableNetSalary < 0 ? _kRed : _kPurpleDark,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Notes Card ───
//   Widget _buildNotes(String note) {
//     final lines = note.split('\n').where((l) => l.trim().isNotEmpty).toList();
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _kOrangeBg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kOrangeBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.sticky_note_2_outlined, size: 18, color: _kOrange),
//               SizedBox(width: 8),
//               Text('Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF92400E))),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...lines.map((line) => Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('•  ', style: TextStyle(color: Color(0xFF92400E), fontSize: 14, fontWeight: FontWeight.w700)),
//                 Expanded(
//                   child: Text(line, style: const TextStyle(color: Color(0xFF78350F), fontSize: 13, height: 1.5)),
//                 ),
//               ],
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   // ─── Shared Helpers ───
//
//   Widget _statusChip(String status) {
//     final isPaid = status == 'Paid';
//     final bg = isPaid ? _kGreenBg : _kOrangeBg;
//     final fg = isPaid ? _kGreen : _kOrange;
//     final border = isPaid ? _kGreenBorder : _kOrangeBorder;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(isPaid ? Icons.check_circle : Icons.schedule, size: 13, color: fg),
//           const SizedBox(width: 4),
//           Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBorder),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(color: _kPurpleLight, borderRadius: BorderRadius.circular(8)),
//                 child: Icon(icon, size: 16, color: _kPurple),
//               ),
//               const SizedBox(width: 8),
//               Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: _kInk)),
//             ],
//           ),
//           const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: _kBorder)),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(label, style: const TextStyle(color: _kSlate, fontSize: 13)),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _breakdownRow(String label, String details, String amount, {bool isBold = false, bool isRed = false, bool isGreen = false}) {
//     Color textColor = _kInk;
//     if (isRed) textColor = _kRed;
//     if (isGreen) textColor = _kGreen;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.w600 : FontWeight.w400, fontSize: 13, color: textColor)),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(details, style: const TextStyle(fontSize: 12, color: _kSlate)),
//           ),
//           Expanded(
//             flex: 2,
//             child: Text(
//               amount,
//               textAlign: TextAlign.right,
//               style: TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, fontSize: 13, color: textColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   TextStyle _breakdownHeaderStyle() {
//     return const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _kSlate, letterSpacing: 0.3);
//   }
// }
//
// class _StatCardData {
//   final String label;
//   final double value;
//   final String subLabel;
//   final IconData icon;
//   final Color color;
//   final Color bg;
//   final bool emphasize;
//
//   _StatCardData({
//     required this.label,
//     required this.value,
//     required this.subLabel,
//     required this.icon,
//     required this.color,
//     required this.bg,
//     this.emphasize = false,
//   });
// }
//
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
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../models/salary_model.dart';
import '../../pdf_files/salary_pdf_service.dart';
import '../../providers/employee_transaction_provider.dart';
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
const _kRedBorder = Color(0xFFFCA5A5);
const _kOrange = Color(0xFFD97706);
const _kOrangeBg = Color(0xFFFFFBEB);
const _kOrangeBorder = Color(0xFFFDE68A);
const _kBlue = Color(0xFF3B82F6);
const _kBorder = Color(0xFFE5E7EB);
const _kSurface = Color(0xFFF7F8FB);
const _kInk = Color(0xFF111827);
const _kSlate = Color(0xFF6B7280);
const _kSlateLight = Color(0xFF9CA3AF);
const double _kDesktopBreakpoint = 900;

// ────────────────────────────────────────────────────────────
//  Salary List Screen (with bulk PDF)
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

  // ─── Bulk selection ───
  bool _selectMode = false;
  late Set<String> _selectedIds = {};

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

  // ─── Selection helpers ───
  void _toggleSelectMode() {
    setState(() {
      if (_selectMode) {
        _selectMode = false;
        _selectedIds.clear();
      } else {
        _selectMode = true;
      }
    });
  }

  void _selectAll(List<SalaryRecord> records) {
    setState(() {
      if (_selectedIds.length == records.length) {
        _selectedIds.clear();
      } else {
        _selectedIds = records.map((r) => r.id!).toSet();
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // ─── Bulk actions ───
  Future<void> _bulkPrint() async {
    if (_selectedIds.isEmpty) return;
    final provider = context.read<SalaryProvider>();
    final selectedRecords =
    provider.salaries.where((s) => _selectedIds.contains(s.id)).toList();
    if (selectedRecords.isEmpty) return;

    try {
      final bytes = await SalaryPdfService.buildMergedPdf(selectedRecords);
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'Bulk_Salary_Slips.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  Future<void> _bulkSave() async {
    if (_selectedIds.isEmpty) return;
    final provider = context.read<SalaryProvider>();
    final selectedRecords =
    provider.salaries.where((s) => _selectedIds.contains(s.id)).toList();
    if (selectedRecords.isEmpty) return;

    try {
      final bytes = await SalaryPdfService.buildMergedPdf(selectedRecords);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Bulk_Salary_Slips.pdf',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bulk salary slips saved'),
            backgroundColor: _kGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  List<SalaryRecord> _filteredSalaries(List<SalaryRecord> all) {
    return all.where((s) {
      if (_statusFilter != 'All' && s.status != _statusFilter) return false;
      if (_typeFilter != 'All' && s.employeeType != _typeFilter) return false;
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty && !s.employeeName.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickYear() async {
    final currentYear = DateTime.now().year;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => _YearPickerDialog(
          initialYear: _selectedYear, minYear: 2015, maxYear: currentYear),
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

  Future<void> _changeStatusInline(
      SalaryRecord record, String newStatus) async {
    if (record.status == newStatus) return;
    try {
      await context
          .read<SalaryProvider>()
          .updateSalaryStatus(record.id!, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${record.employeeName} marked as $newStatus'),
            backgroundColor: _kGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: _kRed,
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _openEdit(SalaryRecord record) {
    Navigator.of(context)
        .push(MaterialPageRoute(
        builder: (_) => GenerateSalaryScreen(existingRecord: record)))
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
                decoration: const BoxDecoration(
                    color: _kRedBg, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline,
                    color: _kRed, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Delete this salary?',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kInk)),
              const SizedBox(height: 8),
              Text(
                'This will permanently remove the salary record for ${record.employeeName}.',
                style: TextStyle(fontSize: 13, color: _kSlate),
                textAlign: TextAlign.center,
              ),
              if (record.isTerminated) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kOrangeBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kOrangeBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: _kOrange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${record.employeeName} will be reinstated (un-terminated) automatically.',
                          style: const TextStyle(
                              fontSize: 11.5, color: _kOrange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: _kBorder),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: _kInk, fontWeight: FontWeight.w600)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete',
                          style: TextStyle(fontWeight: FontWeight.w700)),
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
        final wasTerminated = record.isTerminated;
        await context.read<SalaryProvider>().deleteSalary(
          record.id!,
          transactionProvider: context.read<StaffTransactionProvider>(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(wasTerminated
                  ? 'Record deleted. ${record.employeeName} has been reinstated.'
                  : 'Record deleted.'),
              backgroundColor: _kGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'),
                backgroundColor: _kRed,
                behavior: SnackBarBehavior.floating),
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
        title: _selectMode
            ? Text('${_selectedIds.length} selected',
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18))
            : const Text('Salary Records',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          if (_selectMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all, color: _kSlate),
              tooltip: 'Select All',
              onPressed: () => _selectAll(filtered),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: _kInk),
              tooltip: 'Cancel',
              onPressed: _toggleSelectMode,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist_outlined, color: _kSlate),
              tooltip: 'Select',
              onPressed: _toggleSelectMode,
            ),
          ],
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _kBorder)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                isDesktop ? 24 : 16, 16, isDesktop ? 24 : 16, 16),
            child:
            isDesktop ? _buildDesktopFilters() : _buildMobileFilters(),
          ),
          Container(height: 8, color: _kSurface),
          Expanded(
            child: provider.loadingSalaries
                ? const Center(
                child: CircularProgressIndicator(color: _kPurple))
                : filtered.isEmpty
                ? _buildEmptyState()
                : isDesktop
                ? _buildDesktopTable(filtered)
                : _buildMobileList(filtered),
          ),
          if (_selectedIds.isNotEmpty && _selectMode) _buildBulkActionBar(),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(Icons.checklist, color: _kPurple, size: 20),
            const SizedBox(width: 8),
            Text('${_selectedIds.length} selected',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _kInk)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _bulkPrint,
              icon: const Icon(Icons.print_outlined,
                  size: 16, color: _kSlate),
              label: const Text('Print',
                  style: TextStyle(
                      color: _kSlate,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kBorder),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _bulkSave,
              icon: const Icon(Icons.download_rounded,
                  size: 16, color: Colors.white),
              label: const Text('Save',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
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
            decoration: BoxDecoration(
                color: _kPurpleLight, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined,
                size: 40, color: _kPurple),
          ),
          const SizedBox(height: 16),
          Text('No salary records found',
              style: TextStyle(
                  color: _kSlate,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text('Try changing filters or the selected month',
              style: TextStyle(color: _kSlateLight, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _pillDropdown({required Widget child, double? width}) {
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
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: _kPurple),
                const SizedBox(width: 8),
                Text('$_selectedYear',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _kInk)),
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
              icon:
              const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
              items: List.generate(12, (i) => i + 1)
                  .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                      DateFormat('MMMM').format(DateTime(0, m)))))
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
              icon:
              const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
              items: ['All', 'Pending', 'Paid']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
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
              icon:
              const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13, color: _kInk),
              items: ['All', 'teacher', 'staff']
                  .map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t == 'All'
                      ? 'All Types'
                      : t.capitalize())))
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
              prefixIcon: const Icon(Icons.search,
                  size: 19, color: _kSlateLight),
              filled: true,
              fillColor: _kSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: _kPurple, width: 1.5)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close,
                    size: 16, color: _kSlateLight),
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
                      const Icon(Icons.calendar_today_outlined,
                          size: 15, color: _kPurple),
                      const SizedBox(width: 6),
                      Text('$_selectedYear',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const Spacer(),
                      const Icon(Icons.expand_more,
                          size: 18, color: _kSlateLight),
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
                    icon: const Icon(Icons.expand_more,
                        size: 18, color: _kSlateLight),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _kInk),
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(DateFormat('MMM')
                            .format(DateTime(0, m)))))
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
                    icon: const Icon(Icons.expand_more,
                        size: 18, color: _kSlateLight),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _kInk),
                    items: ['All', 'Pending', 'Paid']
                        .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
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
                    icon: const Icon(Icons.expand_more,
                        size: 18, color: _kSlateLight),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _kInk),
                    items: ['All', 'teacher', 'staff']
                        .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t == 'All'
                            ? 'All Types'
                            : t.capitalize())))
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
              prefixIcon: const Icon(Icons.search,
                  size: 19, color: _kSlateLight),
              filled: true,
              fillColor: _kSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: _kPurple, width: 1.5)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close,
                    size: 16, color: _kSlateLight),
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
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: _kPurpleLight,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    if (_selectMode) const SizedBox(width: 40),
                    const SizedBox(
                        width: 34, child: Text('#', style: _headerStyle)),
                    const Expanded(
                        flex: 3,
                        child: Text('Employee', style: _headerStyle)),
                    const Expanded(
                        flex: 2,
                        child: Text('Designation', style: _headerStyle)),
                    const Expanded(
                        flex: 2,
                        child: Text('Base Salary', style: _headerStyle)),
                    const Expanded(
                        flex: 2,
                        child: Text('Net Salary', style: _headerStyle)),
                    const Expanded(
                        flex: 2,
                        child: Text('Status', style: _headerStyle)),
                    const SizedBox(
                        width: 96,
                        child: Text('Actions', style: _headerStyle)),
                  ],
                ),
              ),
              ...List.generate(records.length, (i) {
                final s = records[i];
                final isLast = i == records.length - 1;
                final rowColor =
                s.isTerminated ? _kRedBg.withOpacity(0.5) : null;
                final isSelected = _selectedIds.contains(s.id);

                return InkWell(
                  onTap: _selectMode
                      ? () => _toggleItem(s.id!)
                      : () => _openDetail(s),
                  borderRadius: isLast
                      ? const BorderRadius.vertical(
                      bottom: Radius.circular(16))
                      : BorderRadius.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: rowColor,
                      border: isLast
                          ? null
                          : const Border(
                          bottom: BorderSide(color: _kBorder)),
                    ),
                    child: Row(
                      children: [
                        if (_selectMode)
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleItem(s.id!),
                              activeColor: _kPurple,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        SizedBox(
                            width: 34,
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: _kSlateLight,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: s.isTerminated
                                    ? _kRedBg
                                    : _kPurpleSoft,
                                child: Text(
                                  s.employeeName.isNotEmpty
                                      ? s.employeeName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                      color: s.isTerminated
                                          ? _kRed
                                          : _kPurple,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(s.employeeName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.5,
                                            color: _kInk)),
                                    if (s.isTerminated) ...[
                                      const SizedBox(height: 2),
                                      _terminatedBadge(),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(s.designation ?? '—',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13, color: _kSlate)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Rs ${NumberFormat('#,##0').format(s.baseSalary)}',
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: _kInk),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${s.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(s.payableNetSalary.abs())}',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: s.payableNetSalary < 0
                                    ? _kRed
                                    : _kInk),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _statusDropdownChip(s,
                                onChanged: (v) =>
                                    _changeStatusInline(s, v)),
                          ),
                        ),
                        SizedBox(
                          width: 96,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18, color: _kPurple),
                                tooltip: 'Edit',
                                onPressed: () => _openEdit(s),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: _kRed),
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
        final isSelected = _selectedIds.contains(s.id);

        return InkWell(
          onTap: _selectMode
              ? () => _toggleItem(s.id!)
              : () => _openDetail(s),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: s.isTerminated
                  ? _kRedBg.withOpacity(0.4)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: s.isTerminated ? _kRedBorder : _kBorder),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleItem(s.id!),
                      activeColor: _kPurple,
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    fontSize: 10.5,
                                    color: _kSlateLight,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 19,
                            backgroundColor: s.isTerminated
                                ? _kRedBg
                                : _kPurpleSoft,
                            child: Text(
                              s.employeeName.isNotEmpty
                                  ? s.employeeName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  color: s.isTerminated
                                      ? _kRed
                                      : _kPurple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(s.employeeName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                        color: _kInk)),
                                if (s.designation != null)
                                  Text(s.designation!,
                                      style: TextStyle(
                                          color: _kSlate,
                                          fontSize: 12.5)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                size: 18, color: _kPurple),
                            tooltip: 'Edit',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _openEdit(s),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: _kRed),
                            tooltip: 'Delete',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _confirmDelete(s),
                          ),
                        ],
                      ),
                      if (s.isTerminated) ...[
                        const SizedBox(height: 8),
                        _terminatedBadge(),
                      ],
                      const SizedBox(height: 8),
                      Container(height: 1, color: _kBorder),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _mobileStat(
                                'Base Salary',
                                'Rs ${NumberFormat('#,##0').format(s.baseSalary)}'),
                          ),
                          Expanded(
                            child: _mobileStat(
                              'Net Salary',
                              '${s.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(s.payableNetSalary.abs())}',
                              emphasize: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _statusDropdownChip(s,
                          onChanged: (v) =>
                              _changeStatusInline(s, v),
                          fullWidth: true),
                    ],
                  ),
                ),
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
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: _kSlateLight,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color: _kInk)),
      ],
    );
  }

  Widget _terminatedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _kRedBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kRedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_off_rounded, size: 10, color: _kRed),
          const SizedBox(width: 4),
          Text(
            'Terminated',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kRed),
          ),
        ],
      ),
    );
  }

  Widget _statusDropdownChip(SalaryRecord record,
      {required ValueChanged<String> onChanged, bool fullWidth = false}) {
    final isPaid = record.status == 'Paid';
    final bg = isPaid ? _kGreenBg : _kOrangeBg;
    final fg = isPaid ? _kGreen : _kOrange;
    final border = isPaid ? _kGreenBorder : _kOrangeBorder;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: record.status,
          isDense: true,
          isExpanded: fullWidth,
          icon: Icon(Icons.expand_more, size: 16, color: fg),
          style: TextStyle(
              color: fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w700),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          items: [
            DropdownMenuItem(
              value: 'Pending',
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.schedule, size: 14, color: _kOrange),
                SizedBox(width: 6),
                Text('Pending',
                    style: TextStyle(
                        color: _kOrange, fontWeight: FontWeight.w600)),
              ]),
            ),
            DropdownMenuItem(
              value: 'Paid',
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.check_circle, size: 14, color: _kGreen),
                SizedBox(width: 6),
                Text('Paid',
                    style: TextStyle(
                        color: _kGreen, fontWeight: FontWeight.w600)),
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
    Navigator.of(context)
        .push(MaterialPageRoute(
        builder: (_) => SalaryDetailScreen(record: record)))
        .then((_) => _loadData());
  }
}

const TextStyle _headerStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    color: _kPurpleDark,
    letterSpacing: 0.2);

// ────────────────────────────────────────────────────────────
//  Salary Detail Screen (unchanged, kept as before)
// ────────────────────────────────────────────────────────────
class SalaryDetailScreen extends StatefulWidget {
  final SalaryRecord record;
  const SalaryDetailScreen({super.key, required this.record});

  @override
  State<SalaryDetailScreen> createState() => _SalaryDetailScreenState();
}

class _SalaryDetailScreenState extends State<SalaryDetailScreen> {
  bool _isDownloading = false;
  bool _isPrinting = false;

  SalaryRecord get rec => widget.record;

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      await SalaryPdfService.downloadAndOpen(rec);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salary slip downloaded'),
            backgroundColor: _kGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to download PDF: $e'),
              backgroundColor: _kRed,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _handlePrint() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);
    try {
      await SalaryPdfService.printSlip(rec);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to print: $e'),
              backgroundColor: _kRed,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const int totalDays = 30;
    final int presentDays = totalDays - rec.leaves;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop =
              constraints.maxWidth >= _kDesktopBreakpoint;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rec.isTerminated) ...[
                  _terminatedBanner(rec),
                  const SizedBox(height: 16),
                ],
                _buildStatsRow(isDesktop),
                SizedBox(height: isDesktop ? 20 : 14),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: _buildSalaryBreakdown(
                              rec, presentDays)),
                      const SizedBox(width: 20),
                      Expanded(
                          flex: 2,
                          child: _buildEmployeeInfo(rec)),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEmployeeInfo(rec),
                      const SizedBox(height: 14),
                      _buildSalaryBreakdown(rec, presentDays),
                    ],
                  ),
                if (rec.note != null && rec.note!.isNotEmpty) ...[
                  SizedBox(height: isDesktop ? 20 : 14),
                  _buildNotes(rec.note!),
                ],
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 44,
      leading: IconButton(
        icon:
        const Icon(Icons.arrow_back_rounded, color: _kInk, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: LayoutBuilder(
        builder: (context, c) {
          final isDesktop = MediaQuery.of(context).size.width >=
              _kDesktopBreakpoint;
          return Text(
            'Salary Details',
            style: TextStyle(
                color: _kInk,
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w700),
          );
        },
      ),
      centerTitle: false,
      actions: [
        Builder(builder: (context) {
          final isDesktop = MediaQuery.of(context).size.width >=
              _kDesktopBreakpoint;
          if (isDesktop) {
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  _actionButton(
                    icon: Icons.print_outlined,
                    label: 'Print Slip',
                    loading: _isPrinting,
                    onTap: _handlePrint,
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    icon: Icons.download_rounded,
                    label: 'Download PDF',
                    filled: true,
                    loading: _isDownloading,
                    onTap: _handleDownload,
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: _isPrinting
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kSlate))
                      : const Icon(Icons.print_outlined,
                      color: _kSlate, size: 22),
                  tooltip: 'Print Slip',
                  onPressed: _isPrinting ? null : _handlePrint,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                      color: _kPurple,
                      borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                    icon: _isDownloading
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white))
                        : const Icon(Icons.download_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Download PDF',
                    onPressed:
                    _isDownloading ? null : _handleDownload,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _kBorder),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
    bool loading = false,
  }) {
    final spinner = SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
          strokeWidth: 2, color: filled ? Colors.white : _kSlate),
    );

    if (filled) {
      return ElevatedButton.icon(
        onPressed: loading ? null : onTap,
        icon: loading
            ? spinner
            : Icon(icon, size: 16, color: Colors.white),
        label: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPurple,
          disabledBackgroundColor: _kPurple.withOpacity(0.7),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: loading ? null : onTap,
      icon: loading
          ? spinner
          : const Icon(Icons.print_outlined,
          size: 16, color: _kSlate),
      label: Text(label,
          style: const TextStyle(
              color: _kSlate,
              fontSize: 13,
              fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _kBorder),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _terminatedBanner(SalaryRecord rec) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kRedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kRedBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_off_rounded,
              size: 16, color: _kRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${rec.employeeName} was terminated. This salary record reflects their final month.',
              style: const TextStyle(
                  fontSize: 12.5,
                  color: _kRed,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDesktop) {
    final totalDeductions = rec.absentDeduction + rec.fine;
    final netPayable = rec.payableNetSalary;

    final cards = [
      _StatCardData(
        label: 'Base Salary',
        value: rec.baseSalary,
        subLabel: 'Monthly gross salary',
        icon: Icons.account_balance_wallet_outlined,
        color: _kPurple,
        bg: _kPurpleLight,
      ),
      _StatCardData(
        label: 'Total Deductions',
        value: totalDeductions,
        subLabel: 'Absences + fines',
        icon: Icons.trending_down_rounded,
        color: _kRed,
        bg: _kRedBg,
      ),
      _StatCardData(
        label: 'Total Bonus',
        value: rec.bonus,
        subLabel: 'All bonuses',
        icon: Icons.card_giftcard_rounded,
        color: _kGreen,
        bg: _kGreenBg,
      ),
      _StatCardData(
        label: 'Net Salary',
        value: netPayable,
        subLabel: 'Payable amount',
        icon: Icons.account_balance_rounded,
        color: _kBlue,
        bg: _kBlue,
        emphasize: true,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: List.generate(cards.length, (i) {
          return Expanded(
            child: Padding(
              padding:
              EdgeInsets.only(right: i == cards.length - 1 ? 0 : 14),
              child: _statCard(cards[i]),
            ),
          );
        }),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cards
              .map((c) => SizedBox(width: cardWidth, child: _statCard(c)))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(_StatCardData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
            BoxDecoration(color: data.bg, shape: BoxShape.circle),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(height: 10),
          Text(data.label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: _kInk)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${data.value < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(data.value.abs())}',
              style: TextStyle(
                fontSize: data.emphasize ? 20 : 18,
                fontWeight: FontWeight.w800,
                color: data.color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(data.subLabel,
              style:
              const TextStyle(fontSize: 10.5, color: _kSlateLight)),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfo(SalaryRecord rec) {
    return _buildCard(
      title: 'Employee Information',
      icon: Icons.person_outline_rounded,
      children: [
        _detailRow('Employee Name', rec.employeeName),
        _detailRow('Employee ID', rec.employeeId ?? 'N/A'),
        _detailRow('Designation', rec.designation ?? 'N/A'),
        _detailRow('Department', 'Computer Science'),
        _detailRow('Joining Date', '12 Jan 2025'),
        _detailRow('Salary Month',
            DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month))),
        _detailRow('Generated Date',
            DateFormat('dd MMM yyyy').format(rec.generatedDate)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status',
                  style: TextStyle(color: _kSlate, fontSize: 13)),
              _statusChip(rec.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryBreakdown(SalaryRecord rec, int presentDays) {
    return _buildCard(
      title: 'Salary Breakdown',
      icon: Icons.receipt_long_outlined,
      children: [
        Container(
          padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('Description',
                      style: _breakdownHeaderStyle())),
              Expanded(
                  flex: 3,
                  child:
                  Text('Details', style: _breakdownHeaderStyle())),
              Expanded(
                  flex: 2,
                  child: Text('Amount',
                      textAlign: TextAlign.right,
                      style: _breakdownHeaderStyle())),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _breakdownRow('Base Salary', 'Monthly fixed salary',
            'Rs ${NumberFormat('#,##0').format(rec.baseSalary)}',
            isBold: true),
        _breakdownRow('Present Days', '$presentDays days', '—'),
        _breakdownRow('Absent Days', '${rec.leaves} days', '—'),
        _breakdownRow(
          'Absent Deduction',
          '${rec.leaves} days × Rs ${NumberFormat('#,##0').format(rec.perDayRate)}',
          '-Rs ${NumberFormat('#,##0').format(rec.absentDeduction)}',
          isRed: true,
        ),
        if (rec.fine > 0)
          _breakdownRow('Fine / Deduction', 'Disciplinary fine',
              '-Rs ${NumberFormat('#,##0').format(rec.fine)}',
              isRed: true),
        if (rec.bonus > 0)
          _breakdownRow('Bonus / Addition', 'Performance bonus',
              '+Rs ${NumberFormat('#,##0').format(rec.bonus)}',
              isGreen: true),
        if (rec.recordInLedger && rec.ledgerDeductionAmount != 0)
          _breakdownRow(
            'Balance Deduction',
            'Deducted from employee balance',
            '-Rs ${NumberFormat('#,##0').format(rec.ledgerDeductionAmount)}',
            isRed: true,
          ),
        const SizedBox(height: 10),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: rec.payableNetSalary < 0
                ? _kRedBg
                : _kPurpleLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: rec.payableNetSalary < 0
                    ? _kRedBorder
                    : _kPurpleSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Payable Salary',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: rec.payableNetSalary < 0
                      ? _kRed
                      : _kPurpleDark,
                ),
              ),
              Text(
                '${rec.payableNetSalary < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(rec.payableNetSalary.abs())}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: rec.payableNetSalary < 0
                      ? _kRed
                      : _kPurpleDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotes(String note) {
    final lines =
    note.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kOrangeBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kOrangeBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.sticky_note_2_outlined,
                  size: 18, color: _kOrange),
              SizedBox(width: 8),
              Text('Notes',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF92400E))),
            ],
          ),
          const SizedBox(height: 12),
          ...lines.map((line) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ',
                    style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Expanded(
                  child: Text(line,
                      style: const TextStyle(
                          color: Color(0xFF78350F),
                          fontSize: 13,
                          height: 1.5)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final isPaid = status == 'Paid';
    final bg = isPaid ? _kGreenBg : _kOrangeBg;
    final fg = isPaid ? _kGreen : _kOrange;
    final border = isPaid ? _kGreenBorder : _kOrangeBorder;
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              isPaid ? Icons.check_circle : Icons.schedule,
              size: 13,
              color: fg),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildCard(
      {required String title,
        required IconData icon,
        required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
                    color: _kPurpleLight,
                    borderRadius: BorderRadius.circular(8)),
                child:
                Icon(icon, size: 16, color: _kPurple),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: _kInk)),
            ],
          ),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: _kBorder)),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style:
                const TextStyle(color: _kSlate, fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _kInk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String details, String amount,
      {bool isBold = false,
        bool isRed = false,
        bool isGreen = false}) {
    Color textColor = _kInk;
    if (isRed) textColor = _kRed;
    if (isGreen) textColor = _kGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: TextStyle(
                    fontWeight:
                    isBold ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                    color: textColor)),
          ),
          Expanded(
            flex: 3,
            child: Text(details,
                style:
                const TextStyle(fontSize: 12, color: _kSlate)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                  color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _breakdownHeaderStyle() {
    return const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: _kSlate,
        letterSpacing: 0.3);
  }
}

class _StatCardData {
  final String label;
  final double value;
  final String subLabel;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool emphasize;

  _StatCardData({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.icon,
    required this.color,
    required this.bg,
    this.emphasize = false,
  });
}

class _YearPickerDialog extends StatelessWidget {
  final int initialYear, minYear, maxYear;
  const _YearPickerDialog(
      {required this.initialYear,
        required this.minYear,
        required this.maxYear});

  @override
  Widget build(BuildContext context) {
    final years = List.generate(maxYear - minYear + 1, (i) => minYear + i)
        .reversed
        .toList();
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Year',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kInk)),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? _kPurpleLight
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text('$y',
                              style: TextStyle(
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: selected
                                      ? _kPurple
                                      : _kInk)),
                          const Spacer(),
                          if (selected)
                            const Icon(Icons.check,
                                color: _kPurple, size: 18),
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
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}