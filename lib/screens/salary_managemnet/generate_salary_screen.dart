// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/teacher.dart';
// import '../../models/salary_model.dart';
// import '../../providers/teacher_provider.dart';
// import '../../providers/salary_provider.dart';
//
// // ─────────────────────────────────────────────
// //  Design tokens (matches EduCore brand)
// // ─────────────────────────────────────────────
// const _kPurple = Color(0xFF534AB7);
// const _kPurpleLight = Color(0xFFF0EFFE);
// const _kPurpleMid = Color(0xFF6C63D4);
// const _kPurpleDark = Color(0xFF433CA0);
//
// const _kGreen = Color(0xFF166534);
// const _kGreenBg = Color(0xFFEFFCF3);
// const _kRed = Color(0xFFB91C1C);
// const _kRedBg = Color(0xFFFEF2F2);
// const _kOrange = Color(0xFFB45309);
// const _kOrangeBg = Color(0xFFFFFBEB);
//
// const _kBorder = Color(0xFFE2E8F0);
// const _kSurface = Color(0xFFF8FAFC);
// const _kInk = Color(0xFF1F2937);
// const _kSlate = Color(0xFF64748B);
//
// const double _kDesktopBreakpoint = 900;
//
// // ─────────────────────────────────────────────
// //  Screen
// // ─────────────────────────────────────────────
// class GenerateSalaryScreen extends StatefulWidget {
//   final bool showAppBar;
//   const GenerateSalaryScreen({super.key, this.showAppBar = true});
//
//   @override
//   State<GenerateSalaryScreen> createState() => _GenerateSalaryScreenState();
// }
//
// class _GenerateSalaryScreenState extends State<GenerateSalaryScreen> {
//   String _employeeType = 'teacher'; // 'teacher' or 'staff'
//   StaffMember? _selectedEmployee;
//
//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;
//
//   String _mode = 'attendance'; // 'attendance' (Option A) or 'manual' (Option B)
//
//   final _fineCtrl = TextEditingController();
//   final _bonusCtrl = TextEditingController();
//   final _noteCtrl = TextEditingController();
//
//   // Manual mode inputs
//   final _manualWorkingDaysCtrl = TextEditingController(text: '30');
//   final _manualLeavesCtrl = TextEditingController(text: '0');
//
//   final _searchCtrl = TextEditingController();
//   bool _showSuggestions = false;
//   final _searchFocus = FocusNode();
//
//   Map<String, dynamic>? _calcResult;
//   bool _isSaving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final staffProvider = context.read<StaffProvider>();
//       if (staffProvider.teachers.isEmpty) staffProvider.fetchTeachers();
//       if (staffProvider.staffOnly.isEmpty) staffProvider.fetchStaffOnly();
//     });
//
//     _fineCtrl.addListener(_recalculateIfManual);
//     _bonusCtrl.addListener(_recalculateIfManual);
//     _manualWorkingDaysCtrl.addListener(_recalculateIfManual);
//     _manualLeavesCtrl.addListener(_recalculateIfManual);
//   }
//
//   @override
//   void dispose() {
//     _fineCtrl.dispose();
//     _bonusCtrl.dispose();
//     _noteCtrl.dispose();
//     _manualWorkingDaysCtrl.dispose();
//     _manualLeavesCtrl.dispose();
//     _searchCtrl.dispose();
//     _searchFocus.dispose();
//     super.dispose();
//   }
//
//   // ───────────────────────────────────────────
//   //  Data helpers
//   // ───────────────────────────────────────────
//   List<StaffMember> get _sourceList {
//     final staffProvider = context.watch<StaffProvider>();
//     return _employeeType == 'teacher'
//         ? staffProvider.teachers
//         : staffProvider.staffOnly;
//   }
//
//   List<StaffMember> get _filteredEmployees {
//     final query = _searchCtrl.text.trim().toLowerCase();
//     final list = _sourceList;
//     if (query.isEmpty) return list;
//     return list.where((e) => e.name.toLowerCase().contains(query)).toList();
//   }
//
//   double get _fine => double.tryParse(_fineCtrl.text.trim()) ?? 0;
//   double get _bonus => double.tryParse(_bonusCtrl.text.trim()) ?? 0;
//
//   void _switchType(String type) {
//     setState(() {
//       _employeeType = type;
//       _selectedEmployee = null;
//       _searchCtrl.clear();
//       _calcResult = null;
//     });
//   }
//
//   void _pickEmployee(StaffMember member) {
//     setState(() {
//       _selectedEmployee = member;
//       _searchCtrl.text = member.name;
//       _showSuggestions = false;
//       _calcResult = null;
//     });
//     _searchFocus.unfocus();
//     if (_mode == 'attendance') _runAttendanceCalculation();
//   }
//
//   void _switchMode(String mode) {
//     setState(() {
//       _mode = mode;
//       _calcResult = null;
//     });
//     if (mode == 'attendance' && _selectedEmployee != null) {
//       _runAttendanceCalculation();
//     } else if (mode == 'manual' && _selectedEmployee != null) {
//       _recalculateManual();
//     }
//   }
//
//   Future<void> _openMonthYearPicker() async {
//     final result = await _showMonthYearPicker(
//       context: context,
//       initialYear: _selectedYear,
//       initialMonth: _selectedMonth,
//     );
//     if (result == null) return;
//     setState(() {
//       _selectedYear = result.year;
//       _selectedMonth = result.month;
//       _calcResult = null;
//     });
//     if (_mode == 'attendance' && _selectedEmployee != null) {
//       _runAttendanceCalculation();
//     }
//   }
//
//   Future<void> _runAttendanceCalculation() async {
//     if (_selectedEmployee == null) return;
//     final provider = context.read<SalaryProvider>();
//     try {
//       final result = await provider.calculateAttendanceBased(
//         employeeId: _selectedEmployee!.id!,
//         baseSalary: _selectedEmployee!.salary,
//         year: _selectedYear,
//         month: _selectedMonth,
//         fine: _fine,
//         bonus: _bonus,
//       );
//       if (mounted) setState(() => _calcResult = result);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _recalculateManual() {
//     if (_selectedEmployee == null) return;
//     final provider = context.read<SalaryProvider>();
//     final workingDays = int.tryParse(_manualWorkingDaysCtrl.text.trim()) ?? 30;
//     final leaves = int.tryParse(_manualLeavesCtrl.text.trim()) ?? 0;
//     final result = provider.calculateManual(
//       baseSalary: _selectedEmployee!.salary,
//       workingDays: workingDays,
//       leaves: leaves,
//       fine: _fine,
//       bonus: _bonus,
//     );
//     setState(() => _calcResult = result);
//   }
//
//   void _recalculateIfManual() {
//     if (_mode == 'manual') {
//       _recalculateManual();
//     } else if (_mode == 'attendance' && _calcResult != null) {
//       // Fine/bonus changed — re-derive net without re-hitting Firestore.
//       final base = _calcResult!['baseSalary'] as double;
//       final absentDeduction = _calcResult!['absentDeduction'] as double;
//       setState(() {
//         _calcResult = {
//           ..._calcResult!,
//           'fine': _fine,
//           'bonus': _bonus,
//           'netSalary': base - absentDeduction - _fine + _bonus,
//         };
//       });
//     }
//   }
//
//   Future<void> _save() async {
//     if (_selectedEmployee == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select an employee first.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     if (_calcResult == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please wait for the salary calculation to complete.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isSaving = true);
//
//     final provider = context.read<SalaryProvider>();
//
//     try {
//       // ── Duplicate check: block + warn if already generated ──
//       final existing = await provider.checkAlreadyGenerated(
//         _selectedEmployee!.id!,
//         _selectedYear,
//         _selectedMonth,
//       );
//
//       if (existing != null) {
//         if (mounted) {
//           setState(() => _isSaving = false);
//           _showAlreadyGeneratedDialog(existing);
//         }
//         return;
//       }
//
//       final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, _selectedMonth));
//       final totalDaysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
//
//       final record = SalaryRecord(
//         employeeId: _selectedEmployee!.id!,
//         employeeName: _selectedEmployee!.name,
//         employeeType: _employeeType,
//         designation: _selectedEmployee!.designation,
//         year: _selectedYear,
//         month: _selectedMonth,
//         mode: _mode,
//         baseSalary: _calcResult!['baseSalary'] as double,
//         totalDaysInMonth: totalDaysInMonth,
//         workingDays: _calcResult!['workingDays'] as int,
//         leaves: _calcResult!['leaves'] as int,
//         perDayRate: _calcResult!['perDayRate'] as double,
//         absentDeduction: _calcResult!['absentDeduction'] as double,
//         fine: _fine,
//         bonus: _bonus,
//         note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
//         netSalary: _calcResult!['netSalary'] as double,
//         status: 'Pending',
//       );
//
//       await provider.saveSalary(record);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Salary of Rs ${NumberFormat('#,##0').format(record.netSalary)} generated for ${record.employeeName} — $monthName $_selectedYear.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         _resetForm();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//
//   void _showAlreadyGeneratedDialog(SalaryRecord existing) {
//     final monthName =
//     DateFormat('MMMM').format(DateTime(existing.year, existing.month));
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         title: Row(
//           children: const [
//             Icon(Icons.warning_amber_rounded, color: _kOrange),
//             SizedBox(width: 10),
//             Text('Already Generated',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//           ],
//         ),
//         content: Text(
//           'A salary record for ${existing.employeeName} — $monthName ${existing.year} '
//               'already exists (Rs ${NumberFormat('#,##0').format(existing.netSalary)}, '
//               'status: ${existing.status}).\n\n'
//               'Generating salary again for the same month is not allowed.',
//           style: const TextStyle(fontSize: 13, height: 1.4),
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _kPurple,
//               foregroundColor: Colors.white,
//               elevation: 0,
//             ),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _resetForm() {
//     setState(() {
//       _selectedEmployee = null;
//       _searchCtrl.clear();
//       _fineCtrl.clear();
//       _bonusCtrl.clear();
//       _noteCtrl.clear();
//       _manualWorkingDaysCtrl.text = '30';
//       _manualLeavesCtrl.text = '0';
//       _calcResult = null;
//     });
//   }
//
//   String get _initials {
//     final name = _selectedEmployee?.name.trim() ?? '';
//     if (name.isEmpty) return '?';
//     final parts = name.split(' ');
//     if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     return name[0].toUpperCase();
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Type toggle
//   // ───────────────────────────────────────────
//   Widget _typeToggle() {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: ['teacher', 'staff'].map((t) {
//           final selected = _employeeType == t;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => _switchType(t),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 padding: const EdgeInsets.symmetric(vertical: 11),
//                 decoration: BoxDecoration(
//                   color: selected ? _kPurple : Colors.transparent,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 alignment: Alignment.center,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       t == 'teacher' ? Icons.school_rounded : Icons.badge_rounded,
//                       size: 16,
//                       color: selected ? Colors.white : Colors.grey.shade600,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       t == 'teacher' ? 'Teacher' : 'Staff',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: selected ? Colors.white : Colors.grey.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Employee search
//   // ───────────────────────────────────────────
//   Widget _employeeSearchField() {
//     final staffProvider = context.watch<StaffProvider>();
//     final isLoading = staffProvider.loading && _sourceList.isEmpty;
//
//     return TapRegion(
//       onTapOutside: (_) {
//         if (_showSuggestions) setState(() => _showSuggestions = false);
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextFormField(
//             controller: _searchCtrl,
//             focusNode: _searchFocus,
//             onTap: () => setState(() => _showSuggestions = true),
//             onChanged: (v) {
//               setState(() {
//                 _showSuggestions = true;
//                 if (_selectedEmployee != null && v != _selectedEmployee!.name) {
//                   _selectedEmployee = null;
//                   _calcResult = null;
//                 }
//               });
//             },
//             decoration: InputDecoration(
//               labelText:
//               'Search ${_employeeType == 'teacher' ? 'Teacher' : 'Staff'} Name *',
//               hintText: 'Start typing a name…',
//               prefixIcon: const Icon(Icons.search, size: 20),
//               suffixIcon: _selectedEmployee != null
//                   ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
//                   : null,
//               labelStyle: const TextStyle(fontSize: 13),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: _kPurple, width: 1.5),
//               ),
//               contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             ),
//           ),
//           if (_showSuggestions) ...[
//             const SizedBox(height: 6),
//             Container(
//               constraints: const BoxConstraints(maxHeight: 220),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey.shade200),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 10,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: isLoading
//                   ? const Padding(
//                 padding: EdgeInsets.all(16),
//                 child:
//                 Center(child: CircularProgressIndicator(strokeWidth: 2)),
//               )
//                   : _filteredEmployees.isEmpty
//                   ? Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Text(
//                   'No ${_employeeType == 'teacher' ? 'teacher' : 'staff'} found.',
//                   style:
//                   TextStyle(fontSize: 13, color: Colors.grey.shade500),
//                 ),
//               )
//                   : ListView.separated(
//                 shrinkWrap: true,
//                 padding: EdgeInsets.zero,
//                 itemCount: _filteredEmployees.length,
//                 separatorBuilder: (_, __) =>
//                     Divider(height: 1, color: Colors.grey.shade100),
//                 itemBuilder: (context, i) {
//                   final e = _filteredEmployees[i];
//                   return ListTile(
//                     dense: true,
//                     leading: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: _kPurpleLight,
//                       child: Text(
//                         e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
//                         style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: _kPurple),
//                       ),
//                     ),
//                     title: Text(e.name, style: const TextStyle(fontSize: 13)),
//                     subtitle: Text(
//                       'Rs ${NumberFormat('#,##0').format(e.salary)}'
//                           '${(e.designation ?? '').isNotEmpty ? ' · ${e.designation}' : ''}',
//                       style:
//                       TextStyle(fontSize: 11, color: Colors.grey.shade500),
//                     ),
//                     onTap: () => _pickEmployee(e),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _selectedEmployeeCard() {
//     if (_selectedEmployee == null) return const SizedBox.shrink();
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: _kPurpleLight,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 18,
//             backgroundColor: _kPurple,
//             child: Text(_initials,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13)),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(_selectedEmployee!.name,
//                     style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87)),
//                 Text(
//                   'Base Salary: Rs ${NumberFormat('#,##0').format(_selectedEmployee!.salary)}'
//                       '${(_selectedEmployee!.designation ?? '').isNotEmpty ? ' · ${_selectedEmployee!.designation}' : ''}',
//                   style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Month/Year chip
//   // ───────────────────────────────────────────
//   Widget _monthYearChip() {
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: _openMonthYearPicker,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: _kSurface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.calendar_month_outlined, size: 16, color: _kSlate),
//             const SizedBox(width: 10),
//             Text(
//               DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
//               style: const TextStyle(
//                   fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk),
//             ),
//             const SizedBox(width: 6),
//             const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Mode toggle (Option A / Option B)
//   // ───────────────────────────────────────────
//   Widget _modeToggle() {
//     return Row(
//       children: [
//         Expanded(
//           child: _modeCard(
//             mode: 'attendance',
//             title: 'Attendance-Based',
//             subtitle: 'Auto-calculated from attendance records',
//             icon: Icons.fact_check_outlined,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: _modeCard(
//             mode: 'manual',
//             title: 'Manual Entry',
//             subtitle: 'You enter working days & leaves yourself',
//             icon: Icons.edit_note_rounded,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _modeCard({
//     required String mode,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//   }) {
//     final selected = _mode == mode;
//     return GestureDetector(
//       onTap: () => _switchMode(mode),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: selected ? _kPurpleLight : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: selected ? _kPurple : Colors.grey.shade300,
//             width: selected ? 1.5 : 0.8,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 18, color: selected ? _kPurple : Colors.grey.shade600),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: selected ? _kPurple : Colors.black87,
//                     ),
//                   ),
//                 ),
//                 if (selected)
//                   const Icon(Icons.check_circle, size: 16, color: _kPurple),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               subtitle,
//               style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Manual mode inputs
//   // ───────────────────────────────────────────
//   Widget _manualInputs() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             controller: _manualWorkingDaysCtrl,
//             keyboardType: TextInputType.number,
//             decoration: _fieldDeco('Working Days *'),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: TextFormField(
//             controller: _manualLeavesCtrl,
//             keyboardType: TextInputType.number,
//             decoration: _fieldDeco('Leaves (Absents) *'),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Attendance mode summary (read-only, informational)
//   // ───────────────────────────────────────────
//   Widget _attendanceSummary() {
//     final provider = context.watch<SalaryProvider>();
//
//     if (provider.calculating) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         alignment: Alignment.center,
//         child: const CircularProgressIndicator(strokeWidth: 2, color: _kPurple),
//       );
//     }
//
//     if (_calcResult == null) {
//       return Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.amber.shade50,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.amber.shade200),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
//             const SizedBox(width: 8),
//             const Expanded(
//               child: Text(
//                 'Select an employee to auto-calculate attendance-based salary.',
//                 style: TextStyle(fontSize: 12, color: Colors.amber),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               _miniStat('Working Days', '30', _kPurple),
//               _miniStat('Absents', '${_calcResult!['leaves']}', _kRed),
//               _miniStat('Present', '${provider.lastPresentDays}', _kGreen),
//               _miniStat('Holidays', '${provider.lastHolidaysExcluded}', _kOrange),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Rule: month treated as 30 days · Sundays/holidays excluded · '
//                 'unmarked or "absent" days deducted at Rs ${NumberFormat('#,##0').format(_calcResult!['perDayRate'])}/day.',
//             style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _miniStat(String label, String value, Color color) {
//     return Expanded(
//       child: Column(
//         children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.w800, color: color)),
//           const SizedBox(height: 2),
//           Text(label,
//               style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
//         ],
//       ),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Fine / Bonus / Note
//   // ───────────────────────────────────────────
//   Widget _fineAndBonusFields() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             controller: _fineCtrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: _fieldDeco('Fine / Deduction (Optional)').copyWith(
//               prefixText: 'Rs  ',
//               prefixIcon: const Icon(Icons.remove_circle_outline,
//                   size: 18, color: _kRed),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: TextFormField(
//             controller: _bonusCtrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: _fieldDeco('Bonus / Addition (Optional)').copyWith(
//               prefixText: 'Rs  ',
//               prefixIcon:
//               const Icon(Icons.add_circle_outline, size: 18, color: _kGreen),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _noteField() {
//     return TextFormField(
//       controller: _noteCtrl,
//       maxLines: 2,
//       decoration: _fieldDeco('Note (Optional)').copyWith(
//         hintText: 'Any remarks about this salary…',
//         alignLabelWithHint: true,
//       ),
//     );
//   }
//
//   InputDecoration _fieldDeco(String label, {String? hint}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: const TextStyle(fontSize: 13),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: _kPurple, width: 1.5),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Net salary preview card
//   // ───────────────────────────────────────────
//   Widget _netSalaryPreview() {
//     if (_calcResult == null) return const SizedBox.shrink();
//
//     final base = _calcResult!['baseSalary'] as double;
//     final deduction = _calcResult!['absentDeduction'] as double;
//     final fine = _calcResult!['fine'] as double;
//     final bonus = _calcResult!['bonus'] as double;
//     final net = _calcResult!['netSalary'] as double;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [_kPurple, _kPurpleMid],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Net Salary',
//               style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600)),
//           const SizedBox(height: 4),
//           Text(
//             'Rs ${NumberFormat('#,##0').format(net)}',
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
//           ),
//           const SizedBox(height: 12),
//           Container(height: 1, color: Colors.white24),
//           const SizedBox(height: 10),
//           _breakdownRow('Base Salary', base, positive: true),
//           _breakdownRow('Absent Deduction', -deduction),
//           if (fine > 0) _breakdownRow('Fine', -fine),
//           if (bonus > 0) _breakdownRow('Bonus', bonus, positive: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _breakdownRow(String label, double value, {bool positive = false}) {
//     final sign = value < 0 ? '- ' : (positive ? '' : '');
//     final displayVal = value.abs();
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
//           Text(
//             '$sign Rs ${NumberFormat('#,##0').format(displayVal)}',
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _saveButton({double? width, double height = 50}) {
//     return SizedBox(
//       width: width,
//       height: height,
//       child: ElevatedButton.icon(
//         onPressed: _isSaving ? null : _save,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _kPurple,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         icon: _isSaving
//             ? const SizedBox(
//           height: 18,
//           width: 18,
//           child:
//           CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//         )
//             : const Icon(Icons.save_rounded, size: 18),
//         label: Text(
//           _isSaving ? 'Generating…' : 'Generate Salary',
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         ),
//       ),
//     );
//   }
//
//   Widget _sectionCard(String title, IconData icon, List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
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
//               Icon(icon, size: 16, color: _kPurple),
//               const SizedBox(width: 8),
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 13, fontWeight: FontWeight.w700, color: _kPurple)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  BUILD
//   // ───────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//
//     final formColumn = SingleChildScrollView(
//       padding: EdgeInsets.all(isDesktop ? 28 : 16),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: isDesktop ? 720 : double.infinity),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [_kPurple, _kPurpleMid],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(Icons.payments_rounded,
//                         color: Colors.white, size: 22),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Generate Salary',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             _sectionCard('Select Employee', Icons.person_search_outlined, [
//               _typeToggle(),
//               const SizedBox(height: 12),
//               _employeeSearchField(),
//               _selectedEmployeeCard(),
//             ]),
//
//             _sectionCard('Salary Month', Icons.calendar_month_outlined, [
//               _monthYearChip(),
//             ]),
//
//             _sectionCard('Calculation Method', Icons.calculate_outlined, [
//               _modeToggle(),
//               const SizedBox(height: 14),
//               if (_mode == 'manual') _manualInputs(),
//               if (_mode == 'attendance') _attendanceSummary(),
//             ]),
//
//             _sectionCard('Adjustments', Icons.tune_rounded, [
//               _fineAndBonusFields(),
//               const SizedBox(height: 14),
//               _noteField(),
//             ]),
//
//             if (_calcResult != null) ...[
//               _netSalaryPreview(),
//               const SizedBox(height: 20),
//             ],
//
//             _saveButton(width: double.infinity),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//
//     if (!widget.showAppBar) {
//       return Container(color: _kSurface, child: formColumn);
//     }
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         backgroundColor: _kPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: const Text('Generate Salary',
//             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
//       ),
//       body: formColumn,
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════
// //  Month/Year picker (same Windows-style dialog used in Attendance History)
// // ═══════════════════════════════════════════════════════════════════════
// class _MonthYearPickerResult {
//   final int year;
//   final int month;
//   _MonthYearPickerResult(this.year, this.month);
// }
//
// Future<_MonthYearPickerResult?> _showMonthYearPicker({
//   required BuildContext context,
//   required int initialYear,
//   required int initialMonth,
// }) {
//   final currentYear = DateTime.now().year;
//   return showDialog<_MonthYearPickerResult>(
//     context: context,
//     barrierColor: Colors.black.withOpacity(0.35),
//     builder: (context) {
//       return _MonthYearPickerDialog(
//         initialYear: initialYear,
//         initialMonth: initialMonth,
//         maxYear: currentYear,
//       );
//     },
//   );
// }
//
// class _MonthYearPickerDialog extends StatefulWidget {
//   final int initialYear;
//   final int initialMonth;
//   final int maxYear;
//   const _MonthYearPickerDialog({
//     required this.initialYear,
//     required this.initialMonth,
//     required this.maxYear,
//   });
//
//   @override
//   State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
// }
//
// class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
//   late int _year;
//   late int _month;
//   bool _showYearGrid = false;
//   late final ScrollController _yearScrollController;
//
//   static const int _minYear = 2015;
//
//   @override
//   void initState() {
//     super.initState();
//     _year = widget.initialYear;
//     _month = widget.initialMonth;
//     final index = _year - _minYear;
//     final estimatedOffset = (index ~/ 3) * 64.0;
//     _yearScrollController = ScrollController(
//       initialScrollOffset: estimatedOffset > 0 ? estimatedOffset : 0,
//     );
//   }
//
//   @override
//   void dispose() {
//     _yearScrollController.dispose();
//     super.dispose();
//   }
//
//   void _goToPreviousYear() {
//     if (_year - 1 < _minYear) return;
//     setState(() => _year -= 1);
//   }
//
//   void _goToNextYear() {
//     if (_year + 1 > widget.maxYear) return;
//     setState(() => _year += 1);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 320),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(),
//               const SizedBox(height: 14),
//               SizedBox(
//                 height: 260,
//                 child: _showYearGrid ? _buildYearGrid() : _buildMonthGrid(),
//               ),
//               const SizedBox(height: 8),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('CANCEL',
//                       style:
//                       TextStyle(fontWeight: FontWeight.w600, color: _kSlate)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.chevron_left, color: _kSlate),
//           onPressed: _showYearGrid ? null : _goToPreviousYear,
//         ),
//         Expanded(
//           child: Center(
//             child: InkWell(
//               borderRadius: BorderRadius.circular(8),
//               onTap: () => setState(() => _showYearGrid = !_showYearGrid),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '$_year',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w800, color: _kInk),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(
//                       _showYearGrid ? Icons.arrow_drop_up : Icons.arrow_drop_down,
//                       color: _kSlate,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.chevron_right, color: _kSlate),
//           onPressed:
//           (_showYearGrid || _year + 1 > widget.maxYear) ? null : _goToNextYear,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMonthGrid() {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 8,
//         childAspectRatio: 1.6,
//       ),
//       itemCount: 12,
//       itemBuilder: (context, index) {
//         final month = index + 1;
//         final isFuture = _year == widget.maxYear && month > DateTime.now().month;
//         final isSelected = month == _month && _year == widget.initialYear;
//         final label = DateFormat('MMM').format(DateTime(0, month));
//
//         return _PickerCell(
//           label: label,
//           isSelected: isSelected,
//           isDisabled: isFuture,
//           onTap: isFuture
//               ? null
//               : () {
//             Navigator.of(context).pop(_MonthYearPickerResult(_year, month));
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildYearGrid() {
//     final years = List.generate(
//       widget.maxYear - _minYear + 1,
//           (i) => _minYear + i,
//     );
//
//     return GridView.builder(
//       controller: _yearScrollController,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 8,
//         childAspectRatio: 1.6,
//       ),
//       itemCount: years.length,
//       itemBuilder: (context, index) {
//         final year = years[index];
//         final isSelected = year == _year;
//
//         return _PickerCell(
//           label: '$year',
//           isSelected: isSelected,
//           isDisabled: false,
//           onTap: () {
//             setState(() {
//               _year = year;
//               _showYearGrid = false;
//             });
//           },
//         );
//       },
//     );
//   }
// }
//
// class _PickerCell extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final bool isDisabled;
//   final VoidCallback? onTap;
//
//   const _PickerCell({
//     required this.label,
//     required this.isSelected,
//     required this.isDisabled,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: isSelected ? _kPurple : Colors.transparent,
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onTap,
//         child: Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: isSelected ? _kPurple : _kBorder,
//             ),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: isDisabled
//                   ? Colors.grey.shade300
//                   : (isSelected ? Colors.white : _kInk),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


//2nd code
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/teacher.dart';
// import '../../models/salary_model.dart';
// import '../../providers/teacher_provider.dart';
// import '../../providers/salary_provider.dart';
//
// // ─────────────────────────────────────────────
// //  Design tokens (matches EduCore brand)
// // ─────────────────────────────────────────────
// const _kPurple = Color(0xFF534AB7);
// const _kPurpleLight = Color(0xFFF0EFFE);
// const _kPurpleMid = Color(0xFF6C63D4);
// const _kPurpleDark = Color(0xFF433CA0);
//
// const _kGreen = Color(0xFF166534);
// const _kGreenBg = Color(0xFFEFFCF3);
// const _kRed = Color(0xFFB91C1C);
// const _kRedBg = Color(0xFFFEF2F2);
// const _kOrange = Color(0xFFB45309);
// const _kOrangeBg = Color(0xFFFFFBEB);
//
// const _kBorder = Color(0xFFE2E8F0);
// const _kSurface = Color(0xFFF8FAFC);
// const _kInk = Color(0xFF1F2937);
// const _kSlate = Color(0xFF64748B);
//
// const double _kDesktopBreakpoint = 900;
//
// // ─────────────────────────────────────────────
// //  Screen
// // ─────────────────────────────────────────────
// class GenerateSalaryScreen extends StatefulWidget {
//   final bool showAppBar;
//   const GenerateSalaryScreen({super.key, this.showAppBar = true});
//
//   @override
//   State<GenerateSalaryScreen> createState() => _GenerateSalaryScreenState();
// }
//
// class _GenerateSalaryScreenState extends State<GenerateSalaryScreen> {
//   String _employeeType = 'teacher'; // 'teacher' or 'staff'
//   StaffMember? _selectedEmployee;
//
//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;
//
//   String _mode = 'attendance'; // 'attendance' (Option A) or 'manual' (Option B)
//
//   final _fineCtrl = TextEditingController();
//   final _bonusCtrl = TextEditingController();
//   final _noteCtrl = TextEditingController();
//
//   // Manual mode inputs
//   final _manualWorkingDaysCtrl = TextEditingController(text: '30');
//   final _manualLeavesCtrl = TextEditingController(text: '0');
//
//   final _searchCtrl = TextEditingController();
//   bool _showSuggestions = false;
//   final _searchFocus = FocusNode();
//
//   Map<String, dynamic>? _calcResult;
//   bool _isSaving = false;
//
//   // ───── Duplicate check state ─────
//   bool _alreadyGenerated = false;
//   SalaryRecord? _existingRecord;
//   bool _isCheckingDuplicate = false; // optional: show small loader while checking
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final staffProvider = context.read<StaffProvider>();
//       if (staffProvider.teachers.isEmpty) staffProvider.fetchTeachers();
//       if (staffProvider.staffOnly.isEmpty) staffProvider.fetchStaffOnly();
//     });
//
//     _fineCtrl.addListener(_recalculateIfManual);
//     _bonusCtrl.addListener(_recalculateIfManual);
//     _manualWorkingDaysCtrl.addListener(_recalculateIfManual);
//     _manualLeavesCtrl.addListener(_recalculateIfManual);
//   }
//
//   @override
//   void dispose() {
//     _fineCtrl.dispose();
//     _bonusCtrl.dispose();
//     _noteCtrl.dispose();
//     _manualWorkingDaysCtrl.dispose();
//     _manualLeavesCtrl.dispose();
//     _searchCtrl.dispose();
//     _searchFocus.dispose();
//     super.dispose();
//   }
//
//   // ───────────────────────────────────────────
//   //  Data helpers
//   // ───────────────────────────────────────────
//   List<StaffMember> get _sourceList {
//     final staffProvider = context.watch<StaffProvider>();
//     return _employeeType == 'teacher'
//         ? staffProvider.teachers
//         : staffProvider.staffOnly;
//   }
//
//   List<StaffMember> get _filteredEmployees {
//     final query = _searchCtrl.text.trim().toLowerCase();
//     final list = _sourceList;
//     if (query.isEmpty) return list;
//     return list.where((e) => e.name.toLowerCase().contains(query)).toList();
//   }
//
//   double get _fine => double.tryParse(_fineCtrl.text.trim()) ?? 0;
//   double get _bonus => double.tryParse(_bonusCtrl.text.trim()) ?? 0;
//
//   void _switchType(String type) {
//     setState(() {
//       _employeeType = type;
//       _selectedEmployee = null;
//       _searchCtrl.clear();
//       _calcResult = null;
//       _resetDuplicateState();
//     });
//   }
//
//   void _pickEmployee(StaffMember member) {
//     setState(() {
//       _selectedEmployee = member;
//       _searchCtrl.text = member.name;
//       _showSuggestions = false;
//     });
//     _searchFocus.unfocus();
//     _checkDuplicate(); // checks after employee & month are both set
//   }
//
//   void _switchMode(String mode) {
//     setState(() {
//       _mode = mode;
//       _calcResult = null;
//     });
//     if (!_alreadyGenerated && _selectedEmployee != null) {
//       if (mode == 'attendance') {
//         _runAttendanceCalculation();
//       } else {
//         _recalculateManual();
//       }
//     }
//   }
//
//   Future<void> _openMonthYearPicker() async {
//     final result = await _showMonthYearPicker(
//       context: context,
//       initialYear: _selectedYear,
//       initialMonth: _selectedMonth,
//     );
//     if (result == null) return;
//     setState(() {
//       _selectedYear = result.year;
//       _selectedMonth = result.month;
//       _calcResult = null;
//     });
//     _checkDuplicate(); // re-check duplicate after month change
//   }
//
//   // ───────────────────────────────────────────
//   //  Duplicate check
//   // ───────────────────────────────────────────
//   Future<void> _checkDuplicate() async {
//     if (_selectedEmployee == null) return;
//
//     setState(() => _isCheckingDuplicate = true);
//
//     try {
//       final provider = context.read<SalaryProvider>();
//       final existing = await provider.checkAlreadyGenerated(
//         _selectedEmployee!.id!,
//         _selectedYear,
//         _selectedMonth,
//       );
//       if (!mounted) return;
//       setState(() {
//         _existingRecord = existing;
//         _alreadyGenerated = existing != null;
//         _isCheckingDuplicate = false;
//         if (existing != null) {
//           // clear any previous calculation
//           _calcResult = null;
//         }
//       });
//
//       // If not generated, recalculate based on current mode
//       if (!_alreadyGenerated && _mode == 'attendance') {
//         _runAttendanceCalculation();
//       } else if (!_alreadyGenerated && _mode == 'manual') {
//         _recalculateManual();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isCheckingDuplicate = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error checking duplicate: $e'),
//               backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _resetDuplicateState() {
//     _alreadyGenerated = false;
//     _existingRecord = null;
//     _isCheckingDuplicate = false;
//   }
//
//   // ───────────────────────────────────────────
//   //  Calculation methods (unchanged)
//   // ───────────────────────────────────────────
//   Future<void> _runAttendanceCalculation() async {
//     if (_selectedEmployee == null) return;
//     final provider = context.read<SalaryProvider>();
//     try {
//       final result = await provider.calculateAttendanceBased(
//         employeeId: _selectedEmployee!.id!,
//         baseSalary: _selectedEmployee!.salary,
//         year: _selectedYear,
//         month: _selectedMonth,
//         fine: _fine,
//         bonus: _bonus,
//       );
//       if (mounted) setState(() => _calcResult = result);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   void _recalculateManual() {
//     if (_selectedEmployee == null) return;
//     final provider = context.read<SalaryProvider>();
//     final workingDays = int.tryParse(_manualWorkingDaysCtrl.text.trim()) ?? 30;
//     final leaves = int.tryParse(_manualLeavesCtrl.text.trim()) ?? 0;
//     final result = provider.calculateManual(
//       baseSalary: _selectedEmployee!.salary,
//       workingDays: workingDays,
//       leaves: leaves,
//       fine: _fine,
//       bonus: _bonus,
//     );
//     setState(() => _calcResult = result);
//   }
//
//   void _recalculateIfManual() {
//     if (_alreadyGenerated) return;
//     if (_mode == 'manual') {
//       _recalculateManual();
//     } else if (_mode == 'attendance' && _calcResult != null) {
//       // Fine/bonus changed — re-derive net without re-hitting Firestore.
//       final base = _calcResult!['baseSalary'] as double;
//       final absentDeduction = _calcResult!['absentDeduction'] as double;
//       setState(() {
//         _calcResult = {
//           ..._calcResult!,
//           'fine': _fine,
//           'bonus': _bonus,
//           'netSalary': base - absentDeduction - _fine + _bonus,
//         };
//       });
//     }
//   }
//
//   Future<void> _save() async {
//     if (_selectedEmployee == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select an employee first.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     if (_calcResult == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please wait for the salary calculation to complete.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     if (_alreadyGenerated) {
//       // Extra safety, though button is already disabled
//       return;
//     }
//
//     setState(() => _isSaving = true);
//
//     final provider = context.read<SalaryProvider>();
//
//     try {
//       // ── Duplicate check one last time before saving ──
//       final existing = await provider.checkAlreadyGenerated(
//         _selectedEmployee!.id!,
//         _selectedYear,
//         _selectedMonth,
//       );
//
//       if (existing != null) {
//         if (mounted) {
//           setState(() {
//             _isSaving = false;
//             _alreadyGenerated = true;
//             _existingRecord = existing;
//           });
//           _showAlreadyGeneratedDialog(existing);
//         }
//         return;
//       }
//
//       final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, _selectedMonth));
//       final totalDaysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
//
//       final record = SalaryRecord(
//         employeeId: _selectedEmployee!.id!,
//         employeeName: _selectedEmployee!.name,
//         employeeType: _employeeType,
//         designation: _selectedEmployee!.designation,
//         year: _selectedYear,
//         month: _selectedMonth,
//         mode: _mode,
//         baseSalary: _calcResult!['baseSalary'] as double,
//         totalDaysInMonth: totalDaysInMonth,
//         workingDays: _calcResult!['workingDays'] as int,
//         leaves: _calcResult!['leaves'] as int,
//         perDayRate: _calcResult!['perDayRate'] as double,
//         absentDeduction: _calcResult!['absentDeduction'] as double,
//         fine: _fine,
//         bonus: _bonus,
//         note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
//         netSalary: _calcResult!['netSalary'] as double,
//         status: 'Pending',
//       );
//
//       await provider.saveSalary(record);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Salary of Rs ${NumberFormat('#,##0').format(record.netSalary)} generated for ${record.employeeName} — $monthName $_selectedYear.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         _resetForm();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//
//   void _showAlreadyGeneratedDialog(SalaryRecord existing) {
//     final monthName =
//     DateFormat('MMMM').format(DateTime(existing.year, existing.month));
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         title: Row(
//           children: const [
//             Icon(Icons.warning_amber_rounded, color: _kOrange),
//             SizedBox(width: 10),
//             Text('Already Generated',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//           ],
//         ),
//         content: Text(
//           'A salary record for ${existing.employeeName} — $monthName ${existing.year} '
//               'already exists (Rs ${NumberFormat('#,##0').format(existing.netSalary)}, '
//               'status: ${existing.status}).\n\n'
//               'Generating salary again for the same month is not allowed.',
//           style: const TextStyle(fontSize: 13, height: 1.4),
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _kPurple,
//               foregroundColor: Colors.white,
//               elevation: 0,
//             ),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _resetForm() {
//     setState(() {
//       _selectedEmployee = null;
//       _searchCtrl.clear();
//       _fineCtrl.clear();
//       _bonusCtrl.clear();
//       _noteCtrl.clear();
//       _manualWorkingDaysCtrl.text = '30';
//       _manualLeavesCtrl.text = '0';
//       _calcResult = null;
//       _resetDuplicateState();
//     });
//   }
//
//   String get _initials {
//     final name = _selectedEmployee?.name.trim() ?? '';
//     if (name.isEmpty) return '?';
//     final parts = name.split(' ');
//     if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     return name[0].toUpperCase();
//   }
//
//   // ───────────────────────────────────────────
//   //  UI: Warning card when already generated
//   // ───────────────────────────────────────────
//   Widget _buildAlreadyGeneratedWarning() {
//     if (_existingRecord == null) return const SizedBox.shrink();
//     final record = _existingRecord!;
//     final monthName = DateFormat('MMMM').format(DateTime(record.year, record.month));
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _kOrangeBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kOrange.withOpacity(0.4)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.warning_amber_rounded, color: _kOrange, size: 20),
//               const SizedBox(width: 10),
//               const Text('Already Generated',
//                   style: TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 14,
//                       color: _kOrange)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'A salary record already exists for ${record.employeeName} — $monthName ${record.year}.',
//             style: const TextStyle(fontSize: 13, color: _kOrange),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Net Salary: Rs ${NumberFormat('#,##0').format(record.netSalary)}',
//             style: const TextStyle(
//                 fontWeight: FontWeight.w600, color: _kOrange, fontSize: 13),
//           ),
//           Text(
//             'Status: ${record.status}',
//             style: const TextStyle(fontSize: 12, color: _kOrange),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'To generate salary for a different month, change the month above.',
//             style: TextStyle(
//                 fontSize: 12,
//                 fontStyle: FontStyle.italic,
//                 color: Colors.grey.shade700),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  UI components (most unchanged, added disabled states)
//   // ───────────────────────────────────────────
//   Widget _typeToggle() {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: ['teacher', 'staff'].map((t) {
//           final selected = _employeeType == t;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => _switchType(t),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 padding: const EdgeInsets.symmetric(vertical: 11),
//                 decoration: BoxDecoration(
//                   color: selected ? _kPurple : Colors.transparent,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 alignment: Alignment.center,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       t == 'teacher' ? Icons.school_rounded : Icons.badge_rounded,
//                       size: 16,
//                       color: selected ? Colors.white : Colors.grey.shade600,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       t == 'teacher' ? 'Teacher' : 'Staff',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: selected ? Colors.white : Colors.grey.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _employeeSearchField() {
//     final staffProvider = context.watch<StaffProvider>();
//     final isLoading = staffProvider.loading && _sourceList.isEmpty;
//
//     return TapRegion(
//       onTapOutside: (_) {
//         if (_showSuggestions) setState(() => _showSuggestions = false);
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextFormField(
//             controller: _searchCtrl,
//             focusNode: _searchFocus,
//             onTap: () => setState(() => _showSuggestions = true),
//             onChanged: (v) {
//               setState(() {
//                 _showSuggestions = true;
//                 if (_selectedEmployee != null && v != _selectedEmployee!.name) {
//                   _selectedEmployee = null;
//                   _calcResult = null;
//                   _resetDuplicateState();
//                 }
//               });
//             },
//             decoration: InputDecoration(
//               labelText:
//               'Search ${_employeeType == 'teacher' ? 'Teacher' : 'Staff'} Name *',
//               hintText: 'Start typing a name…',
//               prefixIcon: const Icon(Icons.search, size: 20),
//               suffixIcon: _selectedEmployee != null
//                   ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
//                   : null,
//               labelStyle: const TextStyle(fontSize: 13),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: _kPurple, width: 1.5),
//               ),
//               contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             ),
//           ),
//           if (_showSuggestions) ...[
//             const SizedBox(height: 6),
//             Container(
//               constraints: const BoxConstraints(maxHeight: 220),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey.shade200),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 10,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: isLoading
//                   ? const Padding(
//                 padding: EdgeInsets.all(16),
//                 child:
//                 Center(child: CircularProgressIndicator(strokeWidth: 2)),
//               )
//                   : _filteredEmployees.isEmpty
//                   ? Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Text(
//                   'No ${_employeeType == 'teacher' ? 'teacher' : 'staff'} found.',
//                   style:
//                   TextStyle(fontSize: 13, color: Colors.grey.shade500),
//                 ),
//               )
//                   : ListView.separated(
//                 shrinkWrap: true,
//                 padding: EdgeInsets.zero,
//                 itemCount: _filteredEmployees.length,
//                 separatorBuilder: (_, __) =>
//                     Divider(height: 1, color: Colors.grey.shade100),
//                 itemBuilder: (context, i) {
//                   final e = _filteredEmployees[i];
//                   return ListTile(
//                     dense: true,
//                     leading: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: _kPurpleLight,
//                       child: Text(
//                         e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
//                         style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: _kPurple),
//                       ),
//                     ),
//                     title: Text(e.name, style: const TextStyle(fontSize: 13)),
//                     subtitle: Text(
//                       'Rs ${NumberFormat('#,##0').format(e.salary)}'
//                           '${(e.designation ?? '').isNotEmpty ? ' · ${e.designation}' : ''}',
//                       style:
//                       TextStyle(fontSize: 11, color: Colors.grey.shade500),
//                     ),
//                     onTap: () => _pickEmployee(e),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _selectedEmployeeCard() {
//     if (_selectedEmployee == null) return const SizedBox.shrink();
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: _kPurpleLight,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 18,
//             backgroundColor: _kPurple,
//             child: Text(_initials,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13)),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(_selectedEmployee!.name,
//                     style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87)),
//                 Text(
//                   'Base Salary: Rs ${NumberFormat('#,##0').format(_selectedEmployee!.salary)}'
//                       '${(_selectedEmployee!.designation ?? '').isNotEmpty ? ' · ${_selectedEmployee!.designation}' : ''}',
//                   style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _monthYearChip() {
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: _openMonthYearPicker,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: _kSurface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.calendar_month_outlined, size: 16, color: _kSlate),
//             const SizedBox(width: 10),
//             Text(
//               DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
//               style: const TextStyle(
//                   fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk),
//             ),
//             const SizedBox(width: 6),
//             const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _modeToggle() {
//     final disabled = _alreadyGenerated;
//     return Opacity(
//       opacity: disabled ? 0.6 : 1.0,
//       child: IgnorePointer(
//         ignoring: disabled,
//         child: Row(
//           children: [
//             Expanded(
//               child: _modeCard(
//                 mode: 'attendance',
//                 title: 'Attendance-Based',
//                 subtitle: 'Auto-calculated from attendance records',
//                 icon: Icons.fact_check_outlined,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: _modeCard(
//                 mode: 'manual',
//                 title: 'Manual Entry',
//                 subtitle: 'You enter working days & leaves yourself',
//                 icon: Icons.edit_note_rounded,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _modeCard({
//     required String mode,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//   }) {
//     final selected = _mode == mode;
//     return GestureDetector(
//       onTap: () => _switchMode(mode),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: selected ? _kPurpleLight : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: selected ? _kPurple : Colors.grey.shade300,
//             width: selected ? 1.5 : 0.8,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 18, color: selected ? _kPurple : Colors.grey.shade600),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: selected ? _kPurple : Colors.black87,
//                     ),
//                   ),
//                 ),
//                 if (selected)
//                   const Icon(Icons.check_circle, size: 16, color: _kPurple),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               subtitle,
//               style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _manualInputs() {
//     final disabled = _alreadyGenerated;
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             controller: _manualWorkingDaysCtrl,
//             keyboardType: TextInputType.number,
//             enabled: !disabled,
//             decoration: _fieldDeco('Working Days *'),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: TextFormField(
//             controller: _manualLeavesCtrl,
//             keyboardType: TextInputType.number,
//             enabled: !disabled,
//             decoration: _fieldDeco('Leaves (Absents) *'),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _attendanceSummary() {
//     final provider = context.watch<SalaryProvider>();
//     if (_alreadyGenerated) return const SizedBox.shrink(); // hide when already generated
//
//     if (provider.calculating) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         alignment: Alignment.center,
//         child: const CircularProgressIndicator(strokeWidth: 2, color: _kPurple),
//       );
//     }
//
//     if (_calcResult == null) {
//       return Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.amber.shade50,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.amber.shade200),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
//             const SizedBox(width: 8),
//             const Expanded(
//               child: Text(
//                 'Select an employee to auto-calculate attendance-based salary.',
//                 style: TextStyle(fontSize: 12, color: Colors.amber),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               _miniStat('Working Days', '30', _kPurple),
//               _miniStat('Absents', '${_calcResult!['leaves']}', _kRed),
//               _miniStat('Present', '${provider.lastPresentDays}', _kGreen),
//               _miniStat('Holidays', '${provider.lastHolidaysExcluded}', _kOrange),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Rule: month treated as 30 days · Sundays/holidays excluded · '
//                 'unmarked or "absent" days deducted at Rs ${NumberFormat('#,##0').format(_calcResult!['perDayRate'])}/day.',
//             style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _miniStat(String label, String value, Color color) {
//     return Expanded(
//       child: Column(
//         children: [
//           Text(value,
//               style: TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.w800, color: color)),
//           const SizedBox(height: 2),
//           Text(label,
//               style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
//         ],
//       ),
//     );
//   }
//
//   Widget _fineAndBonusFields() {
//     final disabled = _alreadyGenerated;
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             controller: _fineCtrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             enabled: !disabled,
//             decoration: _fieldDeco('Fine / Deduction (Optional)').copyWith(
//               prefixText: 'Rs  ',
//               prefixIcon: const Icon(Icons.remove_circle_outline,
//                   size: 18, color: _kRed),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: TextFormField(
//             controller: _bonusCtrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             enabled: !disabled,
//             decoration: _fieldDeco('Bonus / Addition (Optional)').copyWith(
//               prefixText: 'Rs  ',
//               prefixIcon:
//               const Icon(Icons.add_circle_outline, size: 18, color: _kGreen),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _noteField() {
//     return TextFormField(
//       controller: _noteCtrl,
//       maxLines: 2,
//       enabled: !_alreadyGenerated,
//       decoration: _fieldDeco('Note (Optional)').copyWith(
//         hintText: 'Any remarks about this salary…',
//         alignLabelWithHint: true,
//       ),
//     );
//   }
//
//   InputDecoration _fieldDeco(String label, {String? hint}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: const TextStyle(fontSize: 13),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: _kPurple, width: 1.5),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//     );
//   }
//
//   Widget _netSalaryPreview() {
//     if (_alreadyGenerated || _calcResult == null) return const SizedBox.shrink();
//
//     final base = _calcResult!['baseSalary'] as double;
//     final deduction = _calcResult!['absentDeduction'] as double;
//     final fine = _calcResult!['fine'] as double;
//     final bonus = _calcResult!['bonus'] as double;
//     final net = _calcResult!['netSalary'] as double;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [_kPurple, _kPurpleMid],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Net Salary',
//               style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600)),
//           const SizedBox(height: 4),
//           Text(
//             'Rs ${NumberFormat('#,##0').format(net)}',
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
//           ),
//           const SizedBox(height: 12),
//           Container(height: 1, color: Colors.white24),
//           const SizedBox(height: 10),
//           _breakdownRow('Base Salary', base, positive: true),
//           _breakdownRow('Absent Deduction', -deduction),
//           if (fine > 0) _breakdownRow('Fine', -fine),
//           if (bonus > 0) _breakdownRow('Bonus', bonus, positive: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _breakdownRow(String label, double value, {bool positive = false}) {
//     final sign = value < 0 ? '- ' : (positive ? '' : '');
//     final displayVal = value.abs();
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
//           Text(
//             '$sign Rs ${NumberFormat('#,##0').format(displayVal)}',
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _saveButton({double? width, double height = 50}) {
//     if (_alreadyGenerated) {
//       return SizedBox(
//         width: width,
//         height: height,
//         child: ElevatedButton.icon(
//           onPressed: null, // disabled
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.grey.shade300,
//             foregroundColor: Colors.grey.shade600,
//             elevation: 0,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//           icon: const Icon(Icons.lock_outline, size: 18),
//           label: const Text('Already Generated',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//         ),
//       );
//     }
//
//     return SizedBox(
//       width: width,
//       height: height,
//       child: ElevatedButton.icon(
//         onPressed: _isSaving || _alreadyGenerated ? null : _save,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _kPurple,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         icon: _isSaving
//             ? const SizedBox(
//           height: 18,
//           width: 18,
//           child:
//           CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//         )
//             : const Icon(Icons.save_rounded, size: 18),
//         label: Text(
//           _isSaving ? 'Generating…' : 'Generate Salary',
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         ),
//       ),
//     );
//   }
//
//   Widget _sectionCard(String title, IconData icon, List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
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
//               Icon(icon, size: 16, color: _kPurple),
//               const SizedBox(width: 8),
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 13, fontWeight: FontWeight.w700, color: _kPurple)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   // ───────────────────────────────────────────
//   //  Build – responsive scaffold
//   // ───────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;
//
//     // Form content (without scaffold wrapping)
//     final formContent = SingleChildScrollView(
//       padding: EdgeInsets.all(isDesktop ? 28 : 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header card
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [_kPurple, _kPurpleMid],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.payments_rounded,
//                       color: Colors.white, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 const Expanded(
//                   child: Text(
//                     'Generate Salary',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           _sectionCard('Select Employee', Icons.person_search_outlined, [
//             _typeToggle(),
//             const SizedBox(height: 12),
//             _employeeSearchField(),
//             _selectedEmployeeCard(),
//           ]),
//
//           _sectionCard('Salary Month', Icons.calendar_month_outlined, [
//             _monthYearChip(),
//           ]),
//
//           // Duplicate warning (inserted before the method section)
//           if (_alreadyGenerated) _buildAlreadyGeneratedWarning(),
//
//           _sectionCard('Calculation Method', Icons.calculate_outlined, [
//             _modeToggle(),
//             const SizedBox(height: 14),
//             if (_mode == 'manual') _manualInputs(),
//             if (_mode == 'attendance') _attendanceSummary(),
//           ]),
//
//           // If not already generated, show adjustments and preview
//           if (!_alreadyGenerated) ...[
//             _sectionCard('Adjustments', Icons.tune_rounded, [
//               _fineAndBonusFields(),
//               const SizedBox(height: 14),
//               _noteField(),
//             ]),
//
//             if (_calcResult != null) ...[
//               _netSalaryPreview(),
//               const SizedBox(height: 20),
//             ],
//           ],
//
//           _saveButton(width: double.infinity),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//
//     if (!widget.showAppBar) {
//       // When embedded without scaffold, just return the content
//       return Container(color: _kSurface, child: formContent);
//     }
//
//     // Full-screen with app bar
//     final bodyWidget = isDesktop
//         ? Center(
//       child: Card(
//         margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20)),
//         elevation: 2,
//         shadowColor: Colors.black26,
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 800),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: formContent,
//           ),
//         ),
//       ),
//     )
//         : formContent;
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         backgroundColor: _kPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: const Text('Generate Salary',
//             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
//       ),
//       body: bodyWidget,
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════
// //  Month/Year picker (unchanged)
// // ═══════════════════════════════════════════════════════════════════════
// class _MonthYearPickerResult {
//   final int year;
//   final int month;
//   _MonthYearPickerResult(this.year, this.month);
// }
//
// Future<_MonthYearPickerResult?> _showMonthYearPicker({
//   required BuildContext context,
//   required int initialYear,
//   required int initialMonth,
// }) {
//   final currentYear = DateTime.now().year;
//   return showDialog<_MonthYearPickerResult>(
//     context: context,
//     barrierColor: Colors.black.withOpacity(0.35),
//     builder: (context) {
//       return _MonthYearPickerDialog(
//         initialYear: initialYear,
//         initialMonth: initialMonth,
//         maxYear: currentYear,
//       );
//     },
//   );
// }
//
// class _MonthYearPickerDialog extends StatefulWidget {
//   final int initialYear;
//   final int initialMonth;
//   final int maxYear;
//   const _MonthYearPickerDialog({
//     required this.initialYear,
//     required this.initialMonth,
//     required this.maxYear,
//   });
//
//   @override
//   State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
// }
//
// class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
//   late int _year;
//   late int _month;
//   bool _showYearGrid = false;
//   late final ScrollController _yearScrollController;
//
//   static const int _minYear = 2015;
//
//   @override
//   void initState() {
//     super.initState();
//     _year = widget.initialYear;
//     _month = widget.initialMonth;
//     final index = _year - _minYear;
//     final estimatedOffset = (index ~/ 3) * 64.0;
//     _yearScrollController = ScrollController(
//       initialScrollOffset: estimatedOffset > 0 ? estimatedOffset : 0,
//     );
//   }
//
//   @override
//   void dispose() {
//     _yearScrollController.dispose();
//     super.dispose();
//   }
//
//   void _goToPreviousYear() {
//     if (_year - 1 < _minYear) return;
//     setState(() => _year -= 1);
//   }
//
//   void _goToNextYear() {
//     if (_year + 1 > widget.maxYear) return;
//     setState(() => _year += 1);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 320),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(),
//               const SizedBox(height: 14),
//               SizedBox(
//                 height: 260,
//                 child: _showYearGrid ? _buildYearGrid() : _buildMonthGrid(),
//               ),
//               const SizedBox(height: 8),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('CANCEL',
//                       style:
//                       TextStyle(fontWeight: FontWeight.w600, color: _kSlate)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.chevron_left, color: _kSlate),
//           onPressed: _showYearGrid ? null : _goToPreviousYear,
//         ),
//         Expanded(
//           child: Center(
//             child: InkWell(
//               borderRadius: BorderRadius.circular(8),
//               onTap: () => setState(() => _showYearGrid = !_showYearGrid),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '$_year',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w800, color: _kInk),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(
//                       _showYearGrid ? Icons.arrow_drop_up : Icons.arrow_drop_down,
//                       color: _kSlate,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.chevron_right, color: _kSlate),
//           onPressed:
//           (_showYearGrid || _year + 1 > widget.maxYear) ? null : _goToNextYear,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMonthGrid() {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 8,
//         childAspectRatio: 1.6,
//       ),
//       itemCount: 12,
//       itemBuilder: (context, index) {
//         final month = index + 1;
//         final isFuture = _year == widget.maxYear && month > DateTime.now().month;
//         final isSelected = month == _month && _year == widget.initialYear;
//         final label = DateFormat('MMM').format(DateTime(0, month));
//
//         return _PickerCell(
//           label: label,
//           isSelected: isSelected,
//           isDisabled: isFuture,
//           onTap: isFuture
//               ? null
//               : () {
//             Navigator.of(context).pop(_MonthYearPickerResult(_year, month));
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildYearGrid() {
//     final years = List.generate(
//       widget.maxYear - _minYear + 1,
//           (i) => _minYear + i,
//     );
//
//     return GridView.builder(
//       controller: _yearScrollController,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 8,
//         crossAxisSpacing: 8,
//         childAspectRatio: 1.6,
//       ),
//       itemCount: years.length,
//       itemBuilder: (context, index) {
//         final year = years[index];
//         final isSelected = year == _year;
//
//         return _PickerCell(
//           label: '$year',
//           isSelected: isSelected,
//           isDisabled: false,
//           onTap: () {
//             setState(() {
//               _year = year;
//               _showYearGrid = false;
//             });
//           },
//         );
//       },
//     );
//   }
// }
//
// class _PickerCell extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final bool isDisabled;
//   final VoidCallback? onTap;
//
//   const _PickerCell({
//     required this.label,
//     required this.isSelected,
//     required this.isDisabled,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: isSelected ? _kPurple : Colors.transparent,
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onTap,
//         child: Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: isSelected ? _kPurple : _kBorder,
//             ),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: isDisabled
//                   ? Colors.grey.shade300
//                   : (isSelected ? Colors.white : _kInk),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/teacher.dart';
import '../../models/salary_model.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/salary_provider.dart';

// ─────────────────────────────────────────────
//  Design tokens (matches EduCore brand)
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleMid = Color(0xFF6C63D4);
const _kPurpleDark = Color(0xFF433CA0);

const _kGreen = Color(0xFF15803D);
const _kGreenBg = Color(0xFFEFFCF3);
const _kGreenBorder = Color(0xFFBBF7D0);

const _kRed = Color(0xFFB91C1C);
const _kRedBg = Color(0xFFFEF2F2);
const _kRedBorder = Color(0xFFFECACA);

const _kOrange = Color(0xFFB45309);
const _kOrangeBg = Color(0xFFFFFBEB);
const _kOrangeBorder = Color(0xFFFDE68A);

const _kBorder = Color(0xFFE2E8F0);
const _kSurface = Color(0xFFF8FAFC);
const _kCard = Color(0xFFFFFFFF);
const _kInk = Color(0xFF1E293B);
const _kSlate = Color(0xFF64748B);
const _kSlateLight = Color(0xFF94A3B8);

const double _kTabletBreakpoint = 640;
const double _kDesktopBreakpoint = 1000;

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class GenerateSalaryScreen extends StatefulWidget {
  final bool showAppBar;
  final SalaryRecord? existingRecord; // null = create new, non-null = edit mode

  const GenerateSalaryScreen({super.key, this.showAppBar = true, this.existingRecord});

  // Convenience constructor for editing
  GenerateSalaryScreen.edit({required SalaryRecord record, super.key, this.showAppBar = true})
      : existingRecord = record;

  @override
  State<GenerateSalaryScreen> createState() => _GenerateSalaryScreenState();
}

class _GenerateSalaryScreenState extends State<GenerateSalaryScreen> {
  String _employeeType = 'teacher';
  StaffMember? _selectedEmployee;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  String _mode = 'attendance';

  final _fineCtrl = TextEditingController();
  final _bonusCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _manualWorkingDaysCtrl = TextEditingController(text: '30');
  final _manualLeavesCtrl = TextEditingController(text: '0');

  final _searchCtrl = TextEditingController();
  bool _showSuggestions = false;
  final _searchFocus = FocusNode();

  Map<String, dynamic>? _calcResult;
  bool _isSaving = false;

  // Duplicate-check state (only used in create mode)
  bool _isCheckingDuplicate = false;
  SalaryRecord? _existingRecord;
  int _checkToken = 0;

  bool get _isEditMode => widget.existingRecord != null;

  // In edit mode, the form is locked except for adjustments.
  bool get _isLocked => _isEditMode ? false : _existingRecord != null; // for create mode duplicate lock

  @override
  void initState() {
    super.initState();
    _initializeFromExisting();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditMode) {
        final staffProvider = context.read<StaffProvider>();
        if (staffProvider.teachers.isEmpty) staffProvider.fetchTeachers();
        if (staffProvider.staffOnly.isEmpty) staffProvider.fetchStaffOnly();
      }
    });

    _fineCtrl.addListener(_recalculateIfManual);
    _bonusCtrl.addListener(_recalculateIfManual);
    _manualWorkingDaysCtrl.addListener(_recalculateIfManual);
    _manualLeavesCtrl.addListener(_recalculateIfManual);
  }

  void _initializeFromExisting() {
    if (!_isEditMode) return;
    final rec = widget.existingRecord!;
    _selectedYear = rec.year;
    _selectedMonth = rec.month;
    _employeeType = rec.employeeType;
    _mode = rec.mode;

    // Create a minimal StaffMember with all required fields filled with dummy data.
    _selectedEmployee = StaffMember(
      id: rec.employeeId,
      name: rec.employeeName,
      designation: rec.designation ?? '',
      salary: rec.baseSalary,
      type: rec.employeeType,               // ← required field
      cnic: '',
      phone: '',
      address: '',
      dob: '2000-01-01',
      gender: 'Male',
      religion: '',
      nationality: '',
      maritalStatus: '',
      fatherOrHusbandName: '',
      emergencyPhone: '',
      employmentType: rec.employeeType == 'teacher' ? 'Teacher' : 'Staff',
    );

    _searchCtrl.text = rec.employeeName;

    _fineCtrl.text = rec.fine.toStringAsFixed(0);
    _bonusCtrl.text = rec.bonus.toStringAsFixed(0);
    _noteCtrl.text = rec.note ?? '';
    _manualWorkingDaysCtrl.text = rec.workingDays.toString();
    _manualLeavesCtrl.text = rec.leaves.toString();

    // Run initial calculation after the frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mode == 'attendance') {
        _runAttendanceCalculation();
      } else {
        _recalculateManual();
      }
    });
  }

  @override
  void dispose() {
    _fineCtrl.dispose();
    _bonusCtrl.dispose();
    _noteCtrl.dispose();
    _manualWorkingDaysCtrl.dispose();
    _manualLeavesCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Data helpers ──
  List<StaffMember> get _sourceList {
    final staffProvider = context.watch<StaffProvider>();
    return _employeeType == 'teacher' ? staffProvider.teachers : staffProvider.staffOnly;
  }

  List<StaffMember> get _filteredEmployees {
    final query = _searchCtrl.text.trim().toLowerCase();
    final list = _sourceList;
    if (query.isEmpty) return list;
    return list.where((e) => e.name.toLowerCase().contains(query)).toList();
  }

  double get _fine => double.tryParse(_fineCtrl.text.trim()) ?? 0;
  double get _bonus => double.tryParse(_bonusCtrl.text.trim()) ?? 0;

  void _switchType(String type) {
    if (_isEditMode || _employeeType == type) return;
    setState(() {
      _employeeType = type;
      _selectedEmployee = null;
      _searchCtrl.clear();
      _calcResult = null;
      _existingRecord = null;
    });
  }

  Future<void> _pickEmployee(StaffMember member) async {
    if (_isEditMode) return;
    setState(() {
      _selectedEmployee = member;
      _searchCtrl.text = member.name;
      _showSuggestions = false;
      _calcResult = null;
      _existingRecord = null;
    });
    _searchFocus.unfocus();
    await _checkDuplicateForCurrentSelection();
    if (!_isLocked && _mode == 'attendance') {
      _runAttendanceCalculation();
    } else if (!_isLocked && _mode == 'manual') {
      _recalculateManual();
    }
  }

  void _switchMode(String mode) {
    if (_isEditMode || _isLocked) return;
    setState(() {
      _mode = mode;
      _calcResult = null;
    });
    if (mode == 'attendance' && _selectedEmployee != null) {
      _runAttendanceCalculation();
    } else if (mode == 'manual' && _selectedEmployee != null) {
      _recalculateManual();
    }
  }

  Future<void> _openMonthYearPicker() async {
    if (_isEditMode) return;
    final result = await _showMonthYearPicker(
      context: context,
      initialYear: _selectedYear,
      initialMonth: _selectedMonth,
    );
    if (result == null) return;
    setState(() {
      _selectedYear = result.year;
      _selectedMonth = result.month;
      _calcResult = null;
      _existingRecord = null;
    });
    if (_selectedEmployee != null) {
      await _checkDuplicateForCurrentSelection();
      if (!_isLocked && _mode == 'attendance') {
        _runAttendanceCalculation();
      } else if (!_isLocked && _mode == 'manual') {
        _recalculateManual();
      }
    }
  }

  Future<void> _checkDuplicateForCurrentSelection() async {
    if (_selectedEmployee == null || _isEditMode) return;
    final myToken = ++_checkToken;
    setState(() => _isCheckingDuplicate = true);
    try {
      final provider = context.read<SalaryProvider>();
      final existing = await provider.checkAlreadyGenerated(
        _selectedEmployee!.id!,
        _selectedYear,
        _selectedMonth,
      );
      if (!mounted || myToken != _checkToken) return;
      setState(() {
        _existingRecord = existing;
        _isCheckingDuplicate = false;
      });
    } catch (e) {
      if (!mounted || myToken != _checkToken) return;
      setState(() => _isCheckingDuplicate = false);
    }
  }

  Future<void> _runAttendanceCalculation() async {
    if (_selectedEmployee == null || (_isLocked && !_isEditMode)) return;
    final provider = context.read<SalaryProvider>();
    try {
      final result = await provider.calculateAttendanceBased(
        employeeId: _selectedEmployee!.id!,
        baseSalary: _selectedEmployee!.salary,
        year: _selectedYear,
        month: _selectedMonth,
        fine: _fine,
        bonus: _bonus,
      );
      if (mounted) setState(() => _calcResult = result);
    } catch (e) {
      if (mounted) _showSnack('Error: $e', isError: true);
    }
  }

  void _recalculateManual() {
    if (_selectedEmployee == null || (_isLocked && !_isEditMode)) return;
    final provider = context.read<SalaryProvider>();
    final workingDays = int.tryParse(_manualWorkingDaysCtrl.text.trim()) ?? 30;
    final leaves = int.tryParse(_manualLeavesCtrl.text.trim()) ?? 0;
    final result = provider.calculateManual(
      baseSalary: _selectedEmployee!.salary,
      workingDays: workingDays,
      leaves: leaves,
      fine: _fine,
      bonus: _bonus,
    );
    setState(() => _calcResult = result);
  }

  void _recalculateIfManual() {
    if (_isLocked && !_isEditMode) return;
    if (_mode == 'manual') {
      _recalculateManual();
    } else if (_mode == 'attendance' && _calcResult != null) {
      final base = _calcResult!['baseSalary'] as double;
      final absentDeduction = _calcResult!['absentDeduction'] as double;
      setState(() {
        _calcResult = {
          ..._calcResult!,
          'fine': _fine,
          'bonus': _bonus,
          'netSalary': base - absentDeduction - _fine + _bonus,
        };
      });
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _kRed : _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── SAVE (handles both create and update) ──
  Future<void> _save() async {
    if (_selectedEmployee == null) {
      _showSnack('Please select an employee first.', isError: true);
      return;
    }
    if (_calcResult == null) {
      _showSnack('Please wait for the salary calculation to complete.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<SalaryProvider>();

    try {
      if (_isEditMode) {
        // ── Update existing record ──
        final updateData = {
          'fine': _fine,
          'bonus': _bonus,
          'note': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          'leaves': _mode == 'manual'
              ? int.tryParse(_manualLeavesCtrl.text) ?? 0
              : _calcResult!['leaves'],
          'workingDays': _mode == 'manual'
              ? int.tryParse(_manualWorkingDaysCtrl.text) ?? 30
              : _calcResult!['workingDays'],
          'absentDeduction': _calcResult!['absentDeduction'],
          'netSalary': _calcResult!['netSalary'],
        };
        await provider.updateExistingSalary(widget.existingRecord!.id!, updateData);
        if (mounted) {
          _showSnack('Salary updated successfully!');
          Navigator.pop(context); // return to list
        }
      } else {
        // ── Create new record (original logic) ──
        final existing = await provider.checkAlreadyGenerated(
          _selectedEmployee!.id!,
          _selectedYear,
          _selectedMonth,
        );
        if (existing != null) {
          if (mounted) {
            setState(() {
              _isSaving = false;
              _existingRecord = existing;
            });
          }
          return;
        }
        final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, _selectedMonth));
        final totalDaysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
        final record = SalaryRecord(
          employeeId: _selectedEmployee!.id!,
          employeeName: _selectedEmployee!.name,
          employeeType: _employeeType,
          designation: _selectedEmployee!.designation,
          year: _selectedYear,
          month: _selectedMonth,
          mode: _mode,
          baseSalary: _calcResult!['baseSalary'] as double,
          totalDaysInMonth: totalDaysInMonth,
          workingDays: _calcResult!['workingDays'] as int,
          leaves: _calcResult!['leaves'] as int,
          perDayRate: _calcResult!['perDayRate'] as double,
          absentDeduction: _calcResult!['absentDeduction'] as double,
          fine: _fine,
          bonus: _bonus,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          netSalary: _calcResult!['netSalary'] as double,
          status: 'Pending',
        );
        await provider.saveSalary(record);
        if (mounted) {
          _showSnack('Salary of Rs ${NumberFormat('#,##0').format(record.netSalary)} generated for ${record.employeeName} — $monthName $_selectedYear.');
          _resetForm();
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedEmployee = null;
      _searchCtrl.clear();
      _fineCtrl.clear();
      _bonusCtrl.clear();
      _noteCtrl.clear();
      _manualWorkingDaysCtrl.text = '30';
      _manualLeavesCtrl.text = '0';
      _calcResult = null;
      _existingRecord = null;
    });
  }

  String get _initials {
    final name = _selectedEmployee?.name.trim() ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  // ═══════════════════════════════════════════
  //  UI Components
  // ═══════════════════════════════════════════

  Widget _header(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 22 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPurple, _kPurpleMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 48 : 42,
            height: isDesktop ? 48 : 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.payments_rounded,
                color: Colors.white, size: isDesktop ? 24 : 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Salary' : 'Generate Salary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 17 : 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditMode
                      ? 'Adjust fine, bonus, or other details'
                      : 'Calculate and generate monthly salary',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: isDesktop ? 12.5 : 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBadge(int number, {required bool done}) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? _kGreenBg : _kPurpleLight,
        shape: BoxShape.circle,
        border: Border.all(color: done ? _kGreenBorder : _kPurple.withOpacity(0.25)),
      ),
      child: done
          ? const Icon(Icons.check, size: 13, color: _kGreen)
          : Text('$number',
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: _kPurple)),
    );
  }

  Widget _typeToggle() {
    return IgnorePointer(
      ignoring: _isEditMode,
      child: Opacity(
        opacity: _isEditMode ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: ['teacher', 'staff'].map((t) {
              final selected = _employeeType == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _switchType(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: selected ? _kPurple : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          t == 'teacher' ? Icons.school_rounded : Icons.badge_rounded,
                          size: 16,
                          color: selected ? Colors.white : _kSlate,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t == 'teacher' ? 'Teacher' : 'Staff',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : _kSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _employeeSearchField() {
    final staffProvider = context.watch<StaffProvider>();
    final isLoading = staffProvider.loading && _sourceList.isEmpty;

    return IgnorePointer(
      ignoring: _isEditMode,
      child: Opacity(
        opacity: _isEditMode ? 0.6 : 1,
        child: TapRegion(
          onTapOutside: (_) {
            if (_showSuggestions) setState(() => _showSuggestions = false);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onTap: () => setState(() => _showSuggestions = true),
                onChanged: (v) {
                  setState(() {
                    _showSuggestions = true;
                    if (_selectedEmployee != null && v != _selectedEmployee!.name) {
                      _selectedEmployee = null;
                      _calcResult = null;
                      _existingRecord = null;
                    }
                  });
                },
                style: const TextStyle(fontSize: 13.5, color: _kInk),
                decoration: InputDecoration(
                  labelText: 'Search ${_employeeType == 'teacher' ? 'Teacher' : 'Staff'} Name',
                  hintText: 'Start typing a name…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _kSlate),
                  suffixIcon: _isCheckingDuplicate
                      ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple),
                    ),
                  )
                      : (_selectedEmployee != null
                      ? Icon(Icons.check_circle_rounded,
                      color: _isLocked ? _kRed : _kGreen, size: 20)
                      : null),
                  labelStyle: const TextStyle(fontSize: 13, color: _kSlate),
                  filled: true,
                  fillColor: _kSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kPurple, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              if (_showSuggestions) ...[
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple)),
                  )
                      : _filteredEmployees.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.search_off_rounded, size: 16, color: _kSlateLight),
                        const SizedBox(width: 8),
                        Text('No ${_employeeType == 'teacher' ? 'teacher' : 'staff'} found.',
                            style: const TextStyle(fontSize: 12.5, color: _kSlate)),
                      ],
                    ),
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _filteredEmployees.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: _kBorder.withOpacity(0.6)),
                    itemBuilder: (context, i) {
                      final e = _filteredEmployees[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: _kPurpleLight,
                          child: Text(
                            e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPurple),
                          ),
                        ),
                        title: Text(e.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          'Rs ${NumberFormat('#,##0').format(e.salary)}'
                              '${(e.designation ?? '').isNotEmpty ? ' · ${e.designation}' : ''}',
                          style: const TextStyle(fontSize: 11, color: _kSlate),
                        ),
                        onTap: () => _pickEmployee(e),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectedEmployeeCard() {
    if (_selectedEmployee == null) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _isLocked && !_isEditMode ? _kRedBg : _kPurpleLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _isLocked && !_isEditMode ? _kRedBorder : _kPurple.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _isLocked && !_isEditMode ? _kRed : _kPurple,
            child: Text(_initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedEmployee!.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
                Text(
                  'Base Salary: Rs ${NumberFormat('#,##0').format(_selectedEmployee!.salary)}'
                      '${(_selectedEmployee!.designation ?? '').isNotEmpty ? ' · ${_selectedEmployee!.designation}' : ''}',
                  style: const TextStyle(fontSize: 11, color: _kSlate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _duplicateWarningBanner() {
    if (!_isLocked || _isEditMode) return const SizedBox.shrink();
    final existing = _existingRecord!;
    final monthName = DateFormat('MMMM').format(DateTime(existing.year, existing.month));
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kRedBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kRedBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_rounded, color: _kRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salary for $monthName ${existing.year} has already been generated for this employee.',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kRed),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: Rs ${NumberFormat('#,##0').format(existing.netSalary)}  ·  Status: ${existing.status}',
                  style: TextStyle(fontSize: 11.5, color: _kRed.withOpacity(0.85)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a different month to generate a new salary for this employee.',
                  style: TextStyle(fontSize: 11.5, color: _kRed.withOpacity(0.75)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthYearChip() {
    return IgnorePointer(
      ignoring: _isEditMode,
      child: Opacity(
        opacity: _isEditMode ? 0.6 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _openMonthYearPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: _kPurpleLight, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.calendar_month_rounded, size: 16, color: _kPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kInk),
                  ),
                ),
                if (!_isEditMode) const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _kSlate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeToggle(bool isDesktop) {
    return IgnorePointer(
      ignoring: _isEditMode || _isLocked,
      child: Opacity(
        opacity: (_isEditMode || _isLocked) ? 0.6 : 1,
        child: Row(
          children: [
            Expanded(child: _modeCard(mode: 'attendance', title: 'Attendance-Based', subtitle: 'Auto-calculated from records', icon: Icons.fact_check_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _modeCard(mode: 'manual', title: 'Manual Entry', subtitle: 'Enter working days & leaves', icon: Icons.edit_note_rounded)),
          ],
        ),
      ),
    );
  }

  Widget _modeCard({
    required String mode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _mode == mode;
    final disabled = _isEditMode || _isLocked;
    return GestureDetector(
      onTap: disabled ? null : () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: disabled ? _kSurface : (selected ? _kPurpleLight : _kCard),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled ? _kBorder : (selected ? _kPurple : _kBorder),
            width: selected && !disabled ? 1.5 : 1,
          ),
        ),
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 18, color: selected ? _kPurple : _kSlate),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? _kPurple : _kInk))),
                if (selected && !disabled) const Icon(Icons.check_circle_rounded, size: 16, color: _kPurple),
              ]),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: _kSlate)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _manualInputs() {
    return Row(
      children: [
        Expanded(child: TextFormField(controller: _manualWorkingDaysCtrl, enabled: !_isLocked, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13.5), decoration: _fieldDeco('Working Days'))),
        const SizedBox(width: 12),
        Expanded(child: TextFormField(controller: _manualLeavesCtrl, enabled: !_isLocked, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13.5), decoration: _fieldDeco('Leaves (Absents)'))),
      ],
    );
  }

  Widget _attendanceSummary() {
    final provider = context.watch<SalaryProvider>();
    if (_isLocked && !_isEditMode) return const SizedBox.shrink();
    if (provider.calculating) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple));
    }
    if (_calcResult == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _kOrangeBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kOrangeBorder)),
        child: Row(children: [
          const Icon(Icons.info_rounded, size: 16, color: _kOrange),
          const SizedBox(width: 8),
          Expanded(child: Text(_selectedEmployee == null ? 'Select an employee to auto-calculate attendance-based salary.' : 'Calculating attendance for the selected month…', style: const TextStyle(fontSize: 12, color: _kOrange))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _miniStat('Working Days', '30', _kPurple),
            _miniStat('Absents', '${_calcResult!['leaves']}', _kRed),
            _miniStat('Present', '${provider.lastPresentDays}', _kGreen),
            _miniStat('Holidays', '${provider.lastHolidaysExcluded}', _kOrange),
          ]),
          const SizedBox(height: 10),
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 10),
          Text('Month treated as 30 days · Sundays/holidays excluded · unmarked or "absent" days deducted at Rs ${NumberFormat('#,##0').format(_calcResult!['perDayRate'])}/day.', style: const TextStyle(fontSize: 11, color: _kSlate)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, color: _kSlate)),
      ]),
    );
  }

  Widget _fineAndBonusFields(bool stacked) {
    final fineField = TextFormField(controller: _fineCtrl, enabled: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(fontSize: 13.5), decoration: _fieldDeco('Fine / Deduction').copyWith(prefixText: 'Rs  ', prefixIcon: const Icon(Icons.remove_circle_outline, size: 18, color: _kRed)));
    final bonusField = TextFormField(controller: _bonusCtrl, enabled: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(fontSize: 13.5), decoration: _fieldDeco('Bonus / Addition').copyWith(prefixText: 'Rs  ', prefixIcon: const Icon(Icons.add_circle_outline, size: 18, color: _kGreen)));
    if (stacked) return Column(children: [fineField, const SizedBox(height: 12), bonusField]);
    return Row(children: [Expanded(child: fineField), const SizedBox(width: 12), Expanded(child: bonusField)]);
  }

  Widget _noteField() {
    return TextFormField(controller: _noteCtrl, maxLines: 2, style: const TextStyle(fontSize: 13.5), decoration: _fieldDeco('Note (Optional)').copyWith(hintText: 'Any remarks about this salary…', alignLabelWithHint: true));
  }

  InputDecoration _fieldDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: _kSlate),
      filled: true,
      fillColor: _kSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPurple, width: 1.5)),
    );
  }

  Widget _netSalaryPreview() {
    if (_calcResult == null || (_isLocked && !_isEditMode)) return const SizedBox.shrink();
    final base = _calcResult!['baseSalary'] as double;
    final deduction = _calcResult!['absentDeduction'] as double;
    final fine = _calcResult!['fine'] as double;
    final bonus = _calcResult!['bonus'] as double;
    final net = _calcResult!['netSalary'] as double;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [_kPurple, _kPurpleMid], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withOpacity(0.8), size: 16), const SizedBox(width: 6), const Text('Net Salary', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 6),
          Text('Rs ${NumberFormat('#,##0').format(net)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withOpacity(0.18)),
          const SizedBox(height: 10),
          _breakdownRow('Base Salary', base, positive: true),
          _breakdownRow('Absent Deduction', -deduction),
          if (fine > 0) _breakdownRow('Fine', -fine),
          if (bonus > 0) _breakdownRow('Bonus', bonus, positive: true),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, double value, {bool positive = false}) {
    final sign = value < 0 ? '- ' : '';
    final displayVal = value.abs();
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3.5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12.5)), Text('$sign Rs ${NumberFormat('#,##0').format(displayVal)}', style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600))]));
  }

  Widget _saveButton({double? width, double height = 52}) {
    final disabled = _isSaving || (!_isEditMode && (_isLocked || _selectedEmployee == null));
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLocked && !_isEditMode ? _kSlateLight : _kPurple,
          disabledBackgroundColor: _kSlateLight.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: _isSaving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(_isEditMode ? Icons.save_rounded : (_isLocked ? Icons.lock_rounded : Icons.save_rounded), size: 18),
        label: Text(_isSaving ? 'Saving…' : (_isEditMode ? 'Update Salary' : (_isLocked ? 'Already Generated' : 'Generate Salary')), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required int step, required bool stepDone, required List<Widget> children, bool dimmed = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kBorder.withOpacity(0.7))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [_stepBadge(step, done: stepDone), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk))]),
        const SizedBox(height: 14),
        Opacity(opacity: dimmed ? 0.55 : 1, child: IgnorePointer(ignoring: dimmed, child: Column(children: children))),
      ]),
    );
  }

  // ── BUILD ──
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= _kDesktopBreakpoint;
    final isTablet = width >= _kTabletBreakpoint && width < _kDesktopBreakpoint;

    final employeeSection = _sectionCard(
      title: 'Select Employee', icon: Icons.person_search_rounded, step: 1,
      stepDone: _selectedEmployee != null,
      children: [_typeToggle(), const SizedBox(height: 12), _employeeSearchField(), _selectedEmployeeCard()],
    );
    final monthSection = _sectionCard(
      title: 'Salary Month', icon: Icons.calendar_month_rounded, step: 2,
      stepDone: _selectedEmployee != null && !_isCheckingDuplicate,
      children: [_monthYearChip(), _duplicateWarningBanner()],
    );
    final methodSection = _sectionCard(
      title: 'Calculation Method', icon: Icons.calculate_rounded, step: 3,
      stepDone: _calcResult != null, dimmed: _isLocked && !_isEditMode,
      children: [_modeToggle(isDesktop), const SizedBox(height: 14), if (_mode == 'manual') _manualInputs(), if (_mode == 'attendance') _attendanceSummary()],
    );
    final adjustmentsSection = _sectionCard(
      title: 'Adjustments', icon: Icons.tune_rounded, step: 4, stepDone: false,
      dimmed: _isLocked && !_isEditMode,
      children: [_fineAndBonusFields(!isDesktop && !isTablet && width < 420), const SizedBox(height: 14), _noteField()],
    );

    Widget body;
    if (isDesktop) {
      body = SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _header(true),
            const SizedBox(height: 22),
            IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: Column(children: [employeeSection, monthSection, methodSection, adjustmentsSection])),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kSlate)),
                const SizedBox(height: 10),
                if (_calcResult != null && !_isLocked) _netSalaryPreview() else Container(
                  padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kBorder)),
                  child: Column(children: [
                    Icon(Icons.calculate_outlined, size: 32, color: _kSlateLight),
                    const SizedBox(height: 10),
                    Text(_isLocked && !_isEditMode ? 'This month is already generated.' : 'Fill in the details to see salary breakdown.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: _kSlateLight)),
                  ]),
                ),
                const SizedBox(height: 20),
                _saveButton(width: double.infinity),
              ])),
            ])),
            const SizedBox(height: 20),
          ]),
        ),
      );
    } else {
      body = SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 22 : 14),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 640 : double.infinity),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _header(false),
            const SizedBox(height: 16),
            employeeSection,
            monthSection,
            methodSection,
            adjustmentsSection,
            if (_calcResult != null && !_isLocked) ...[_netSalaryPreview(), const SizedBox(height: 18)],
            _saveButton(width: double.infinity),
            const SizedBox(height: 20),
          ]),
        ),
      );
    }

    if (!widget.showAppBar) return Container(color: _kSurface, child: body);
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEditMode ? 'Edit Salary' : 'Generate Salary', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      body: body,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Month/Year picker (unchanged)
// ═══════════════════════════════════════════════════════════════════════
// (Keep your existing _showMonthYearPicker dialog code here)
// ═══════════════════════════════════════════════════════════════════════
class _MonthYearPickerResult {
  final int year;
  final int month;
  _MonthYearPickerResult(this.year, this.month);
}

Future<_MonthYearPickerResult?> _showMonthYearPicker({
  required BuildContext context,
  required int initialYear,
  required int initialMonth,
}) {
  final currentYear = DateTime.now().year;
  return showDialog<_MonthYearPickerResult>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return _MonthYearPickerDialog(
        initialYear: initialYear,
        initialMonth: initialMonth,
        maxYear: currentYear,
      );
    },
  );
}

class _MonthYearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int maxYear;
  const _MonthYearPickerDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.maxYear,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _year;
  late int _month;
  bool _showYearGrid = false;
  late final ScrollController _yearScrollController;

  static const int _minYear = 2015;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
    final index = _year - _minYear;
    final estimatedOffset = (index ~/ 3) * 64.0;
    _yearScrollController = ScrollController(
      initialScrollOffset: estimatedOffset > 0 ? estimatedOffset : 0,
    );
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  void _goToPreviousYear() {
    if (_year - 1 < _minYear) return;
    setState(() => _year -= 1);
  }

  void _goToNextYear() {
    if (_year + 1 > widget.maxYear) return;
    setState(() => _year += 1);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              SizedBox(
                height: 260,
                child: _showYearGrid ? _buildYearGrid() : _buildMonthGrid(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL',
                      style: TextStyle(fontWeight: FontWeight.w700, color: _kSlate)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: _kSlate),
          onPressed: _showYearGrid ? null : _goToPreviousYear,
        ),
        Expanded(
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _showYearGrid = !_showYearGrid),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_year',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: _kInk),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showYearGrid
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                      color: _kSlate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: _kSlate),
          onPressed:
          (_showYearGrid || _year + 1 > widget.maxYear) ? null : _goToNextYear,
        ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isFuture = _year == widget.maxYear && month > DateTime.now().month;
        final isSelected = month == _month && _year == widget.initialYear;
        final label = DateFormat('MMM').format(DateTime(0, month));

        return _PickerCell(
          label: label,
          isSelected: isSelected,
          isDisabled: isFuture,
          onTap: isFuture
              ? null
              : () {
            Navigator.of(context).pop(_MonthYearPickerResult(_year, month));
          },
        );
      },
    );
  }

  Widget _buildYearGrid() {
    final years = List.generate(
      widget.maxYear - _minYear + 1,
          (i) => _minYear + i,
    );

    return GridView.builder(
      controller: _yearScrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == _year;

        return _PickerCell(
          label: '$year',
          isSelected: isSelected,
          isDisabled: false,
          onTap: () {
            setState(() {
              _year = year;
              _showYearGrid = false;
            });
          },
        );
      },
    );
  }
}

class _PickerCell extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _PickerCell({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _kPurple : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _kPurple : _kBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDisabled
                  ? Colors.grey.shade300
                  : (isSelected ? Colors.white : _kInk),
            ),
          ),
        ),
      ),
    );
  }
}