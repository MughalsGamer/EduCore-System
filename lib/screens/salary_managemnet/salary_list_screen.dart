// // screens/salary_managemnet/salary_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/salary_model.dart';
// import '../../providers/salary_provider.dart';
// import 'generate_salary_screen.dart';
//
// const double _kDesktopBreakpoint = 900;
//
// class SalaryListScreen extends StatefulWidget {
//   const SalaryListScreen({super.key});
//
//   @override
//   State<SalaryListScreen> createState() => _SalaryListScreenState();
// }
//
// class _SalaryListScreenState extends State<SalaryListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<SalaryProvider>().fetchAllSalaries();
//     });
//   }
//
//   // ─── Delete confirmation ───
//   Future<void> _deleteSalary(SalaryRecord record) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Delete Salary'),
//         content: Text(
//           'Are you sure you want to delete the salary record of\n${record.employeeName} for ${DateFormat('MMMM yyyy').format(DateTime(record.year, record.month))}?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       await context.read<SalaryProvider>().deleteSalary(record.id!);
//       context.read<SalaryProvider>().fetchAllSalaries();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Salary deleted'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   // ─── Edit navigation ───
//   void _editSalary(SalaryRecord record) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => GenerateSalaryScreen.edit(record: record),
//       ),
//     ).then((_) {
//       context.read<SalaryProvider>().fetchAllSalaries();
//     });
//   }
//
//   // ─── View details dialog ───
//   void _viewDetails(SalaryRecord record) {
//     final monthName = DateFormat('MMMM yyyy').format(DateTime(record.year, record.month));
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         title: Text('${record.employeeName} – $monthName'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _detailRow('Base Salary', 'Rs ${NumberFormat('#,##0').format(record.baseSalary)}'),
//               _detailRow('Mode', record.mode == 'attendance' ? 'Attendance' : 'Manual'),
//               if (record.mode == 'manual') _detailRow('Working Days', '${record.workingDays}'),
//               _detailRow('Leaves (Absents)', '${record.leaves}'),
//               _detailRow('Per Day Rate', 'Rs ${NumberFormat('#,##0').format(record.perDayRate)}'),
//               _detailRow('Absent Deduction', 'Rs ${NumberFormat('#,##0').format(record.absentDeduction)}'),
//               _detailRow('Fine', 'Rs ${NumberFormat('#,##0').format(record.fine)}'),
//               _detailRow('Bonus', 'Rs ${NumberFormat('#,##0').format(record.bonus)}'),
//               if (record.note != null) _detailRow('Note', record.note!),
//               const SizedBox(height: 8),
//               _detailRow('Net Salary', 'Rs ${NumberFormat('#,##0').format(record.netSalary)}', bold: true),
//               _detailRow('Status', record.status),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
//         ],
//       ),
//     );
//   }
//
//   Widget _detailRow(String label, String value, {bool bold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
//           Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//     final provider = context.watch<SalaryProvider>();
//     final salaries = provider.salaryList;
//     final loading = provider.loadingSalaries;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF534AB7),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: const Text('Salary List', style: TextStyle(fontWeight: FontWeight.w600)),
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : salaries.isEmpty
//           ? const Center(child: Text('No salary records found.'))
//           : isDesktop
//           ? _buildDesktopTable(salaries)
//           : _buildMobileList(salaries),
//     );
//   }
//
//   // ─── Desktop Table ───
//   Widget _buildDesktopTable(List<SalaryRecord> salaries) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         elevation: 2,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: DataTable(
//             columnSpacing: 20,
//             headingRowColor: WidgetStateProperty.all(const Color(0xFFF0EFFE)),
//             columns: const [
//               DataColumn(label: Text('Employee', style: TextStyle(fontWeight: FontWeight.w600))),
//               DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.w600))),
//               DataColumn(label: Text('Net Salary', style: TextStyle(fontWeight: FontWeight.w600))),
//               DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
//               DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
//             ],
//             rows: salaries.map((rec) {
//               return DataRow(cells: [
//                 DataCell(Text(rec.employeeName)),
//                 DataCell(Text(DateFormat('MMM yyyy').format(DateTime(rec.year, rec.month)))),
//                 DataCell(Text('Rs ${NumberFormat('#,##0').format(rec.netSalary)}')),
//                 DataCell(
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: rec.status == 'Paid' ? Colors.green.shade50 : Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(rec.status, style: TextStyle(
//                       color: rec.status == 'Paid' ? Colors.green : Colors.orange,
//                       fontWeight: FontWeight.w600,
//                     )),
//                   ),
//                 ),
//                 DataCell(
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.visibility_outlined, color: Color(0xFF534AB7)),
//                         tooltip: 'View Details',
//                         onPressed: () => _viewDetails(rec),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.edit_outlined, color: Color(0xFF534AB7)),
//                         tooltip: 'Edit',
//                         onPressed: () => _editSalary(rec),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete_outlined, color: Colors.red),
//                         tooltip: 'Delete',
//                         onPressed: () => _deleteSalary(rec),
//                       ),
//                     ],
//                   ),
//                 ),
//               ]);
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Mobile Card List ───
//   Widget _buildMobileList(List<SalaryRecord> salaries) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: salaries.length,
//       itemBuilder: (context, index) {
//         final rec = salaries[index];
//         final monthName = DateFormat('MMMM yyyy').format(DateTime(rec.year, rec.month));
//         return Card(
//           margin: const EdgeInsets.only(bottom: 8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(rec.employeeName,
//                           style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
//                     ),
//                     Text(monthName, style: TextStyle(color: Colors.grey.shade600)),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Text('Net: Rs ${NumberFormat('#,##0').format(rec.netSalary)}',
//                         style: const TextStyle(fontWeight: FontWeight.w600)),
//                     const Spacer(),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: rec.status == 'Paid' ? Colors.green.shade50 : Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(rec.status, style: TextStyle(
//                         color: rec.status == 'Paid' ? Colors.green : Colors.orange,
//                         fontSize: 12,
//                       )),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.visibility, size: 20),
//                       onPressed: () => _viewDetails(rec),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.edit, size: 20),
//                       onPressed: () => _editSalary(rec),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, size: 20, color: Colors.red),
//                       onPressed: () => _deleteSalary(rec),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }