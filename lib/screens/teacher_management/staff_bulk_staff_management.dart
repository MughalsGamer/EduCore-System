//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../models/teacher.dart';
// import '../../models/class_model.dart';
// import '../../providers/teacher_provider.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/subject_provider.dart';
//
// // ─── Constants ────────────────────────────────────────────────────────────────
// const _kPurple = Color(0xFF534AB7);
// const _kPurpleLight = Color(0xFFF0EFFE);
// const _kPurpleMid = Color(0xFF6C63D4);
// const _kGreen = Color(0xFF15803D);
// const _kGreenBg = Color(0xFFDCFCE7);
// const _kRed = Color(0xFFDC2626);
// const _kRedBg = Color(0xFFFEE2E2);
// const _kOrange = Color(0xFFD97706);
// const _kOrangeBg = Color(0xFFFEF3C7);
// const _kCardBg = Color(0xFFF7F7FA);
// const _kBorderColor = Color(0xFFE7E8F0);
//
// // Row-table sizing (used by both Bulk Add + Bulk Edit compact tables)
// const double _kRowHeight = 64; // a bit taller than the old cramped table for easier tapping
// const double _kColGap = 10;
//
// // ─── CNIC Formatter ──────────────────────────────────────────────────────────
// class _CnicFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
//     final limited = digits.length > 13 ? digits.substring(0, 13) : digits;
//     final buffer = StringBuffer();
//     for (int i = 0; i < limited.length; i++) {
//       if (i == 5 || i == 12) buffer.write('-');
//       buffer.write(limited[i]);
//     }
//     final formatted = buffer.toString();
//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }
//
// // ─── Row data model ──────────────────────────────────────────────────────────
// class _RowData {
//   final String id;
//   String type;
//   String name;
//   String fatherOrHusbandName;
//   String cnic;
//   String dob;
//   String gender;
//   String maritalStatus;
//   String? bloodGroup;
//   String religion;
//   String nationality;
//   String address;
//   String phone;
//   String emergencyPhone;
//   String employmentType;
//   double salary;
//   String? reference;
//   String? note;
//   String? designation;
//   String? joiningDate;
//   String? classId; // single class for quick row
//   String? sectionName; // single section for quick row (belongs to classId)
//   List<String> assignedClasses;
//   List<String> assignedSections;
//   List<String> subjects;
//   bool hasError;
//   String errorMsg;
//   RowStatus status;
//
//   /// If this row was hydrated from an existing StaffMember (bulk edit mode),
//   /// this holds the original id so we know to update instead of add.
//   String? existingStaffId;
//
//   _RowData({
//     required this.id,
//     this.type = 'teacher',
//     this.name = '',
//     this.fatherOrHusbandName = '',
//     this.cnic = '',
//     this.dob = '',
//     this.gender = 'Male',
//     this.maritalStatus = 'Single',
//     this.bloodGroup,
//     this.religion = '',
//     this.nationality = 'Pakistani',
//     this.address = '',
//     this.phone = '',
//     this.emergencyPhone = '',
//     this.employmentType = 'Regular',
//     this.salary = 0,
//     this.reference,
//     this.note,
//     this.designation,
//     this.joiningDate,
//     this.classId,
//     this.sectionName,
//     this.assignedClasses = const [],
//     this.assignedSections = const [],
//     this.subjects = const [],
//     this.hasError = false,
//     this.errorMsg = '',
//     this.status = RowStatus.idle,
//     this.existingStaffId,
//   });
//
//   /// Build a row from an existing StaffMember, so bulk-edit table shows
//   /// already-available data pre-filled, just like bulk-add's row shape.
//   factory _RowData.fromStaffMember(StaffMember s) {
//     return _RowData(
//       id: s.id ?? UniqueKey().toString(),
//       existingStaffId: s.id,
//       type: s.type,
//       name: s.name,
//       fatherOrHusbandName: s.fatherOrHusbandName,
//       cnic: s.cnic,
//       dob: s.dob,
//       gender: s.gender,
//       maritalStatus: s.maritalStatus,
//       bloodGroup: s.bloodGroup,
//       religion: s.religion,
//       nationality: s.nationality,
//       address: s.address,
//       phone: s.phone,
//       emergencyPhone: s.emergencyPhone,
//       employmentType: s.employmentType,
//       salary: s.salary,
//       reference: s.reference,
//       note: s.note,
//       designation: s.designation,
//       joiningDate: s.joiningDate,
//       classId: s.assignedClasses.isNotEmpty ? s.assignedClasses.first : null,
//       sectionName:
//       s.assignedSections.isNotEmpty ? s.assignedSections.first : null,
//       assignedClasses: List<String>.from(s.assignedClasses),
//       assignedSections: List<String>.from(s.assignedSections ?? []),
//       subjects: List<String>.from(s.subjects),
//       status: RowStatus.idle,
//     );
//   }
//
//   _RowData copyWith({
//     String? type,
//     String? name,
//     String? fatherOrHusbandName,
//     String? cnic,
//     String? dob,
//     String? gender,
//     String? maritalStatus,
//     Object? bloodGroup = _sentinel,
//     String? religion,
//     String? nationality,
//     String? address,
//     String? phone,
//     String? emergencyPhone,
//     String? employmentType,
//     double? salary,
//     Object? reference = _sentinel,
//     Object? note = _sentinel,
//     Object? designation = _sentinel,
//     Object? joiningDate = _sentinel,
//     Object? classId = _sentinel,
//     Object? sectionName = _sentinel,
//     List<String>? assignedClasses,
//     List<String>? assignedSections,
//     List<String>? subjects,
//     bool? hasError,
//     String? errorMsg,
//     RowStatus? status,
//   }) =>
//       _RowData(
//         id: id,
//         existingStaffId: existingStaffId,
//         type: type ?? this.type,
//         name: name ?? this.name,
//         fatherOrHusbandName: fatherOrHusbandName ?? this.fatherOrHusbandName,
//         cnic: cnic ?? this.cnic,
//         dob: dob ?? this.dob,
//         gender: gender ?? this.gender,
//         maritalStatus: maritalStatus ?? this.maritalStatus,
//         bloodGroup:
//         bloodGroup == _sentinel ? this.bloodGroup : bloodGroup as String?,
//         religion: religion ?? this.religion,
//         nationality: nationality ?? this.nationality,
//         address: address ?? this.address,
//         phone: phone ?? this.phone,
//         emergencyPhone: emergencyPhone ?? this.emergencyPhone,
//         employmentType: employmentType ?? this.employmentType,
//         salary: salary ?? this.salary,
//         reference: reference == _sentinel ? this.reference : reference as String?,
//         note: note == _sentinel ? this.note : note as String?,
//         designation:
//         designation == _sentinel ? this.designation : designation as String?,
//         joiningDate:
//         joiningDate == _sentinel ? this.joiningDate : joiningDate as String?,
//         classId: classId == _sentinel ? this.classId : classId as String?,
//         sectionName:
//         sectionName == _sentinel ? this.sectionName : sectionName as String?,
//         assignedClasses: assignedClasses ?? this.assignedClasses,
//         assignedSections: assignedSections ?? this.assignedSections,
//         subjects: subjects ?? this.subjects,
//         hasError: hasError ?? this.hasError,
//         errorMsg: errorMsg ?? this.errorMsg,
//         status: status ?? this.status,
//       );
//
//   bool get isEmpty => name.trim().isEmpty && phone.trim().isEmpty;
//
//   String? validate() {
//     if (name.trim().isEmpty) return 'Name required';
//     if (phone.trim().isEmpty) return 'Phone required';
//     if (classId != null && (sectionName == null || sectionName!.isEmpty)) {
//       return 'Section required for selected class';
//     }
//     return null;
//   }
//
//   StaffMember toStaffMember() {
//     final effectiveClasses = classId != null ? [classId!] : assignedClasses;
//     final effectiveSections = sectionName != null
//         ? [sectionName!]
//         : assignedSections;
//     return StaffMember(
//       id: existingStaffId,
//       type: type,
//       name: name.trim(),
//       fatherOrHusbandName: fatherOrHusbandName.trim(),
//       cnic: cnic.trim(),
//       dob: dob,
//       gender: gender,
//       maritalStatus: maritalStatus,
//       bloodGroup: bloodGroup,
//       religion: religion.trim(),
//       nationality: nationality.trim(),
//       address: address.trim(),
//       phone: phone.trim(),
//       emergencyPhone: emergencyPhone.trim(),
//       employmentType: employmentType,
//       salary: salary,
//       reference: reference?.trim().isEmpty == true ? null : reference?.trim(),
//       note: note?.trim().isEmpty == true ? null : note?.trim(),
//       designation:
//       designation?.trim().isEmpty == true ? null : designation?.trim(),
//       joiningDate: joiningDate?.isEmpty == true ? null : joiningDate,
//       assignedClasses: effectiveClasses,
//       assignedSections: effectiveSections,
//       subjects: subjects,
//       imageBase64: null,
//     );
//   }
// }
//
// // sentinel for nullable copyWith
// const _sentinel = Object();
//
// enum RowStatus { idle, saving, saved, failed }
//
// // ─── Bulk Add Screen ──────────────────────────────────────────────────────────
// class BulkAddStaffScreen extends StatefulWidget {
//   const BulkAddStaffScreen({super.key});
//
//   @override
//   State<BulkAddStaffScreen> createState() => _BulkAddStaffScreenState();
// }
//
// class _BulkAddStaffScreenState extends State<BulkAddStaffScreen> {
//   final List<_RowData> _rows = [];
//   bool _isSavingAll = false;
//   int _savedCount = 0;
//   int _failedCount = 0;
//   int _nextId = 1;
//
//   @override
//   void initState() {
//     super.initState();
//     for (int i = 0; i < 3; i++) _addRow();
//   }
//
//   void _addRow({int count = 1}) {
//     setState(() {
//       for (int i = 0; i < count; i++) {
//         final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//         _rows.add(_RowData(id: '${_nextId++}', joiningDate: today));
//       }
//     });
//   }
//
//   void _removeRow(int index) {
//     if (_rows.length <= 1) return;
//     setState(() => _rows.removeAt(index));
//   }
//
//   void _clearAll() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape:
//         RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         title: const Text('Clear All Rows?',
//             style: TextStyle(fontWeight: FontWeight.w600)),
//         content: const Text('All unsaved data will be lost.'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text('Cancel')),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: _kRed, foregroundColor: Colors.white),
//             onPressed: () {
//               Navigator.pop(ctx);
//               setState(() {
//                 _rows.clear();
//                 _savedCount = 0;
//                 _failedCount = 0;
//                 _addRow(count: 3);
//               });
//             },
//             child: const Text('Clear'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _updateRow(int index, _RowData updated) {
//     setState(() => _rows[index] = updated);
//   }
//
//   List<_RowData> get _filledRows =>
//       _rows.where((r) => !r.isEmpty).toList();
//
//   Future<void> _saveAll() async {
//     bool anyError = false;
//     setState(() {
//       for (int i = 0; i < _rows.length; i++) {
//         if (_rows[i].isEmpty) continue;
//         final err = _rows[i].validate();
//         if (err != null) {
//           _rows[i] = _rows[i].copyWith(hasError: true, errorMsg: err);
//           anyError = true;
//         } else {
//           _rows[i] = _rows[i].copyWith(hasError: false, errorMsg: '');
//         }
//       }
//     });
//
//     if (anyError) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please fix errors before saving.'),
//             backgroundColor: _kRed),
//       );
//       return;
//     }
//
//     final toSave = _filledRows;
//     if (toSave.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('No data to save. Fill at least one row.'),
//             backgroundColor: _kOrange),
//       );
//       return;
//     }
//
//     setState(() {
//       _isSavingAll = true;
//       _savedCount = 0;
//       _failedCount = 0;
//       for (int i = 0; i < _rows.length; i++) {
//         if (!_rows[i].isEmpty) {
//           _rows[i] = _rows[i].copyWith(status: RowStatus.saving);
//         }
//       }
//     });
//
//     final provider = context.read<StaffProvider>();
//
//     for (int i = 0; i < _rows.length; i++) {
//       if (_rows[i].isEmpty || _rows[i].status == RowStatus.saved) continue;
//       try {
//         await provider.addStaff(_rows[i].toStaffMember());
//         if (mounted) {
//           setState(() {
//             _rows[i] =
//                 _rows[i].copyWith(status: RowStatus.saved, hasError: false);
//             _savedCount++;
//           });
//         }
//       } catch (e) {
//         if (mounted) {
//           setState(() {
//             _rows[i] = _rows[i].copyWith(
//               status: RowStatus.failed,
//               hasError: true,
//               errorMsg: 'Save failed: $e',
//             );
//             _failedCount++;
//           });
//         }
//       }
//     }
//
//     if (mounted) {
//       setState(() => _isSavingAll = false);
//
//       if (_failedCount == 0 && _savedCount > 0) {
//         provider.fetchTeachers();
//         provider.fetchStaffOnly();
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('$_savedCount record(s) saved successfully!'),
//             backgroundColor: _kGreen,
//           ),
//         );
//
//         await Future.delayed(const Duration(milliseconds: 600));
//         if (mounted) Navigator.pop(context, true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 '$_savedCount saved${_failedCount > 0 ? ', $_failedCount failed' : ''}'),
//             backgroundColor: _failedCount > 0 ? _kOrange : _kGreen,
//           ),
//         );
//         if (_failedCount == 0) {
//           provider.fetchTeachers();
//           provider.fetchStaffOnly();
//         }
//       }
//     }
//   }
//
//   void _openFullEdit(int index) {
//     final data = _rows[index];
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => _FullEditDialog(
//         data: data,
//         onSave: (updated) {
//           _updateRow(index, updated);
//           Navigator.pop(ctx);
//         },
//         onCancel: () => Navigator.pop(ctx),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F8),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         scrolledUnderElevation: 1,
//         title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text('Bulk Add Staff / Teachers',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//           Text(
//               '${_filledRows.length} filled · ${_filledRows.where((r) => r.validate() == null).length} ready',
//               style: const TextStyle(fontSize: 11, color: Colors.grey)),
//         ]),
//         actions: [
//           TextButton.icon(
//             onPressed: _clearAll,
//             icon: const Icon(Icons.clear_all, size: 16, color: _kRed),
//             label: const Text('Clear',
//                 style: TextStyle(color: _kRed, fontSize: 13)),
//           ),
//           const SizedBox(width: 4),
//         ],
//       ),
//       body: Column(children: [
//         Container(
//           color: _kPurpleLight,
//           padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Row(children: [
//             const Icon(Icons.info_outline, size: 15, color: _kPurple),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Quick info yahan fill karein. Class select karne par uski Section bhi select karein. Full details k liye ✏️ edit icon click karein.',
//                 style:
//                 TextStyle(fontSize: 12, color: Colors.grey.shade700),
//               ),
//             ),
//           ]),
//         ),
//         if (_savedCount > 0 || _failedCount > 0)
//           Container(
//             width: double.infinity,
//             color: Colors.white,
//             padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Wrap(spacing: 8, children: [
//               if (_savedCount > 0)
//                 _pill('$_savedCount saved', _kGreen, _kGreenBg),
//               if (_failedCount > 0)
//                 _pill('$_failedCount failed', _kRed, _kRedBg),
//             ]),
//           ),
//         // ── Table header (compact horizontal layout) ──
//         _TableHeader(showCheckbox: false),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.fromLTRB(10, 6, 10, 100),
//             itemCount: _rows.length,
//             itemBuilder: (ctx, i) => Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: _StaffTableRow(
//                 key: ValueKey(_rows[i].id),
//                 data: _rows[i],
//                 index: i,
//                 total: _rows.length,
//                 onChanged: (updated) => _updateRow(i, updated),
//                 onRemove: () => _removeRow(i),
//                 onFullEdit: () => _openFullEdit(i),
//               ),
//             ),
//           ),
//         ),
//       ]),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border(top: BorderSide(color: Colors.grey.shade200)),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, -3)),
//           ],
//         ),
//         child: SafeArea(
//           top: false,
//           child: Row(children: [
//             Expanded(
//               child: Wrap(spacing: 8, runSpacing: 8, children: [
//                 _addBtn('+1', () => _addRow()),
//                 _addBtn('+3', () => _addRow(count: 3)),
//                 _addBtn('+5', () => _addRow(count: 5)),
//               ]),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: _isSavingAll ? null : _saveAll,
//                 icon: _isSavingAll
//                     ? const SizedBox(
//                     width: 14,
//                     height: 14,
//                     child: CircularProgressIndicator(
//                         strokeWidth: 2, color: Colors.white))
//                     : const Icon(Icons.cloud_upload_outlined, size: 17),
//                 label: Text(_isSavingAll ? 'Saving...' : 'Save All'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _kPurple,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   padding:
//                   const EdgeInsets.symmetric(vertical: 13),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   textStyle: const TextStyle(
//                       fontSize: 13, fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
//
//   Widget _addBtn(String label, VoidCallback onTap) => InkWell(
//     onTap: onTap,
//     borderRadius: BorderRadius.circular(8),
//     child: Container(
//       padding:
//       const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
//       decoration: BoxDecoration(
//         border: Border.all(color: _kPurple.withOpacity(0.3)),
//         borderRadius: BorderRadius.circular(10),
//         color: _kPurpleLight,
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         const Icon(Icons.add, size: 14, color: _kPurple),
//         const SizedBox(width: 4),
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 12,
//                 color: _kPurple,
//                 fontWeight: FontWeight.w700)),
//       ]),
//     ),
//   );
//
//   Widget _pill(String label, Color text, Color bg) => Container(
//     padding:
//     const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//     decoration:
//     BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
//     child: Text(label,
//         style: TextStyle(
//             fontSize: 11, color: text, fontWeight: FontWeight.w600)),
//   );
// }
//
// // ─── Column layout definition ─────────────────────────────────────────────────
// // Shared by header + rows so widths always line up. On wide screens these
// // flex-fit the available width; on narrow screens the whole row becomes
// // horizontally scrollable (see _RowScaffold), so we give each column a
// // sensible minimum width to scroll against.
// class _Col {
//   final String label;
//   final double minWidth; // width used inside the horizontal-scroll (mobile) mode
//   final int flex; // flex used in fit mode (desktop/tablet)
//   const _Col(this.label, this.minWidth, this.flex);
// }
//
// const _kColumns = [
//   _Col('#', 30, 0),
//   _Col('Name *', 150, 3),
//   _Col('Type', 100, 2),
//   _Col('Contact *', 130, 2),
//   _Col('CNIC', 150, 2),
//   _Col('Designation', 140, 2),
//   _Col('Class', 130, 2),
//   _Col('Section', 110, 2),
//   _Col('Joining', 130, 2),
//   _Col('Salary', 110, 2),
//   _Col('', 76, 0), // actions
// ];
//
// double get _kTableMinWidth =>
//     _kColumns.fold<double>(0, (sum, c) => sum + c.minWidth) +
//         _kColGap * (_kColumns.length - 1) +
//         20;
//
// // ─── Table header row ─────────────────────────────────────────────────────────
// class _TableHeader extends StatelessWidget {
//   final bool showCheckbox;
//   const _TableHeader({required this.showCheckbox});
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (ctx, constraints) {
//       final isNarrow = constraints.maxWidth < _kTableMinWidth;
//       final content = Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
//         ),
//         child: Row(children: [
//           if (showCheckbox) const SizedBox(width: 40),
//           for (int i = 0; i < _kColumns.length; i++) ...[
//             if (i > 0) const SizedBox(width: _kColGap),
//             isNarrow
//                 ? SizedBox(
//               width: _kColumns[i].minWidth,
//               child: _headerText(_kColumns[i].label),
//             )
//                 : Expanded(
//               flex: _kColumns[i].flex == 0 ? 1 : _kColumns[i].flex,
//               child: _headerText(_kColumns[i].label),
//             ),
//           ],
//         ]),
//       );
//       if (isNarrow) {
//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           physics: const NeverScrollableScrollPhysics(),
//           child: SizedBox(width: _kTableMinWidth, child: content),
//         );
//       }
//       return content;
//     });
//   }
//
//   Widget _headerText(String label) => Text(
//     label,
//     style: TextStyle(
//         fontSize: 11.5,
//         fontWeight: FontWeight.w700,
//         color: Colors.grey.shade600),
//   );
// }
//
// // ─── Row scaffold: handles narrow-screen horizontal scroll vs wide-screen fit ─
// // On mobile (narrow width), the row scrolls horizontally in sync conceptually
// // with the header above it (both use the same _kTableMinWidth). On wider
// // screens (tablet/desktop) columns flex-fit the available width instead.
// class _RowScaffold extends StatelessWidget {
//   final Widget Function(bool isNarrow) builder;
//   const _RowScaffold({required this.builder});
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (ctx, constraints) {
//       final isNarrow = constraints.maxWidth < _kTableMinWidth;
//       final content = builder(isNarrow);
//       if (isNarrow) {
//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: SizedBox(width: _kTableMinWidth, child: content),
//         );
//       }
//       return content;
//     });
//   }
// }
//
// // ─── Shared: class/section selector (compact dropdowns for table cells) ──────
// // Used by both the Bulk Add and Bulk Edit table rows. Selecting a class
// // resets the section; if the chosen class has no sections configured, an
// // inline warning icon/tooltip is shown (every class is expected to have
// // >= 1 section).
// class _CompactClassField extends StatelessWidget {
//   final String? classId;
//   final bool enabled;
//   final ValueChanged<String?> onChanged;
//
//   const _CompactClassField({
//     required this.classId,
//     required this.enabled,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ClassProvider>(
//       builder: (_, classProv, __) {
//         final classes = classProv.classes;
//         final validClassId =
//         classes.any((c) => c.id == classId) ? classId : null;
//         return _compactDropdown<String>(
//           value: validClassId,
//           enabled: enabled && classes.isNotEmpty,
//           hint: classes.isEmpty ? 'No classes' : 'Class',
//           items: classes
//               .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
//               .toList(),
//           onChanged: onChanged,
//         );
//       },
//     );
//   }
// }
//
// class _CompactSectionField extends StatelessWidget {
//   final String? classId;
//   final String? sectionName;
//   final bool enabled;
//   final ValueChanged<String?> onChanged;
//
//   const _CompactSectionField({
//     required this.classId,
//     required this.sectionName,
//     required this.enabled,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ClassProvider>(
//       builder: (_, classProv, __) {
//         final classes = classProv.classes;
//         final validClassId =
//         classes.any((c) => c.id == classId) ? classId : null;
//         final selectedClass = validClassId != null
//             ? classes.firstWhere((c) => c.id == validClassId)
//             : null;
//         final sections = selectedClass?.sections ?? [];
//         final validSection = sections.any((s) => s.sectionName == sectionName)
//             ? sectionName
//             : null;
//
//         final dropdown = _compactDropdown<String>(
//           value: validSection,
//           enabled: enabled && validClassId != null && sections.isNotEmpty,
//           hint: validClassId == null
//               ? '—'
//               : (sections.isEmpty ? 'None' : 'Section'),
//           items: sections
//               .map((s) => DropdownMenuItem(
//               value: s.sectionName, child: Text(s.sectionName)))
//               .toList(),
//           onChanged: onChanged,
//         );
//
//         if (validClassId != null && sections.isEmpty) {
//           return Row(mainAxisSize: MainAxisSize.min, children: [
//             Expanded(child: dropdown),
//             const SizedBox(width: 2),
//             Tooltip(
//               message:
//               '${selectedClass?.name ?? 'Is class'} mein koi section nahi hai.',
//               child: Icon(Icons.warning_amber_rounded,
//                   size: 15, color: Colors.orange.shade600),
//             ),
//           ]);
//         }
//         if (validClassId != null && validSection == null) {
//           return Row(mainAxisSize: MainAxisSize.min, children: [
//             Expanded(child: dropdown),
//             const SizedBox(width: 2),
//             Tooltip(
//               message: 'Section select karna zaroori hai',
//               child: Icon(Icons.error_outline,
//                   size: 15, color: _kRed.withOpacity(0.8)),
//             ),
//           ]);
//         }
//         return dropdown;
//       },
//     );
//   }
// }
//
// Widget _compactDropdown<T>({
//   required T? value,
//   required bool enabled,
//   required String hint,
//   required List<DropdownMenuItem<T>> items,
//   required ValueChanged<T?> onChanged,
// }) {
//   return DropdownButtonFormField<T>(
//     value: value,
//     isExpanded: true,
//     isDense: true,
//     decoration: InputDecoration(
//       hintText: hint,
//       hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300)),
//       enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300)),
//       disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade200)),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: _kPurple, width: 1.5)),
//       filled: true,
//       fillColor: enabled ? Colors.white : Colors.grey.shade100,
//     ),
//     style: const TextStyle(fontSize: 12.5, color: Colors.black87),
//     items: items,
//     onChanged: enabled ? onChanged : null,
//   );
// }
//
// Widget _compactTextField({
//   required TextEditingController controller,
//   String? hint,
//   String? prefixText,
//   TextInputType? keyboard,
//   List<TextInputFormatter>? inputFormatters,
//   bool enabled = true,
//   ValueChanged<String>? onChanged,
// }) {
//   return TextField(
//     controller: controller,
//     enabled: enabled,
//     keyboardType: keyboard,
//     inputFormatters: inputFormatters,
//     onChanged: onChanged,
//     style: const TextStyle(fontSize: 12.5),
//     decoration: InputDecoration(
//       hintText: hint,
//       prefixText: prefixText,
//       isDense: true,
//       hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: _kPurple, width: 1.5),
//       ),
//       disabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       filled: true,
//       fillColor: enabled ? Colors.white : Colors.grey.shade100,
//     ),
//   );
// }
//
// Widget _compactDateField({
//   required TextEditingController controller,
//   required bool enabled,
//   required VoidCallback onTap,
// }) {
//   return TextField(
//     controller: controller,
//     readOnly: true,
//     enabled: enabled,
//     style: const TextStyle(fontSize: 12.5),
//     decoration: InputDecoration(
//       hintText: 'YYYY-MM-DD',
//       isDense: true,
//       suffixIcon: Icon(Icons.calendar_today,
//           size: 14, color: enabled ? _kPurple : Colors.grey.shade400),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: _kPurple, width: 1.5),
//       ),
//       disabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       filled: true,
//       fillColor: enabled ? Colors.white : Colors.grey.shade100,
//     ),
//     onTap: enabled ? onTap : null,
//   );
// }
//
// // ─── Compact table row widget (Bulk Add) ──────────────────────────────────────
// // Single-line-per-record layout: all core fields sit in one horizontal row
// // (Name | Type | Contact | CNIC | Designation | Class | Section | Joining |
// // Salary | actions). On desktop/tablet columns flex-fit the width; on
// // narrow/mobile screens the row becomes horizontally scrollable while
// // wrapping to fit as much as possible first via smaller compact fields.
// class _StaffTableRow extends StatefulWidget {
//   final _RowData data;
//   final int index;
//   final int total;
//   final ValueChanged<_RowData> onChanged;
//   final VoidCallback onRemove;
//   final VoidCallback onFullEdit;
//
//   const _StaffTableRow({
//     super.key,
//     required this.data,
//     required this.index,
//     required this.total,
//     required this.onChanged,
//     required this.onRemove,
//     required this.onFullEdit,
//   });
//
//   @override
//   State<_StaffTableRow> createState() => _StaffTableRowState();
// }
//
// class _StaffTableRowState extends State<_StaffTableRow> {
//   late TextEditingController _nameCtrl;
//   late TextEditingController _phoneCtrl;
//   late TextEditingController _cnicCtrl;
//   late TextEditingController _desigCtrl;
//   late TextEditingController _joiningDateCtrl;
//   late TextEditingController _salaryCtrl;
//   String? _classId;
//   String? _sectionName;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.data.name);
//     _phoneCtrl = TextEditingController(text: widget.data.phone);
//     _cnicCtrl = TextEditingController(text: widget.data.cnic);
//     _desigCtrl = TextEditingController(text: widget.data.designation ?? '');
//     _joiningDateCtrl =
//         TextEditingController(text: widget.data.joiningDate ?? '');
//     _salaryCtrl = TextEditingController(
//         text: widget.data.salary > 0 ? widget.data.salary.toString() : '');
//     _classId = widget.data.classId ??
//         (widget.data.assignedClasses.isNotEmpty
//             ? widget.data.assignedClasses.first
//             : null);
//     _sectionName = widget.data.sectionName ??
//         (widget.data.assignedSections.isNotEmpty
//             ? widget.data.assignedSections.first
//             : null);
//   }
//
//   @override
//   void didUpdateWidget(covariant _StaffTableRow oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.data != widget.data) {
//       if (_nameCtrl.text != widget.data.name) _nameCtrl.text = widget.data.name;
//       if (_phoneCtrl.text != widget.data.phone) {
//         _phoneCtrl.text = widget.data.phone;
//       }
//       if (_cnicCtrl.text != widget.data.cnic) _cnicCtrl.text = widget.data.cnic;
//       final desig = widget.data.designation ?? '';
//       if (_desigCtrl.text != desig) _desigCtrl.text = desig;
//       final jd = widget.data.joiningDate ?? '';
//       if (_joiningDateCtrl.text != jd) _joiningDateCtrl.text = jd;
//       final sal = widget.data.salary > 0 ? widget.data.salary.toString() : '';
//       if (_salaryCtrl.text != sal) _salaryCtrl.text = sal;
//       final newClassId = widget.data.classId ??
//           (widget.data.assignedClasses.isNotEmpty
//               ? widget.data.assignedClasses.first
//               : null);
//       if (newClassId != _classId) _classId = newClassId;
//       final newSection = widget.data.sectionName ??
//           (widget.data.assignedSections.isNotEmpty
//               ? widget.data.assignedSections.first
//               : null);
//       if (newSection != _sectionName) _sectionName = newSection;
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _phoneCtrl.dispose();
//     _cnicCtrl.dispose();
//     _desigCtrl.dispose();
//     _joiningDateCtrl.dispose();
//     _salaryCtrl.dispose();
//     super.dispose();
//   }
//
//   void _emit() {
//     widget.onChanged(widget.data.copyWith(
//       name: _nameCtrl.text,
//       phone: _phoneCtrl.text,
//       cnic: _cnicCtrl.text,
//       designation:
//       _desigCtrl.text.trim().isEmpty ? null : _desigCtrl.text.trim(),
//       classId: _classId,
//       sectionName: _sectionName,
//       joiningDate:
//       _joiningDateCtrl.text.isEmpty ? null : _joiningDateCtrl.text,
//       salary: double.tryParse(_salaryCtrl.text) ?? 0,
//     ));
//   }
//
//   Color get _borderColor {
//     switch (widget.data.status) {
//       case RowStatus.saved:
//         return _kGreen.withOpacity(0.5);
//       case RowStatus.failed:
//         return _kRed.withOpacity(0.5);
//       case RowStatus.saving:
//         return _kPurple.withOpacity(0.4);
//       default:
//         return widget.data.hasError
//             ? _kRed.withOpacity(0.4)
//             : _kBorderColor;
//     }
//   }
//
//   Color get _bg {
//     switch (widget.data.status) {
//       case RowStatus.saved:
//         return _kGreenBg.withOpacity(0.4);
//       case RowStatus.failed:
//         return _kRedBg.withOpacity(0.4);
//       case RowStatus.saving:
//         return _kPurpleLight.withOpacity(0.5);
//       default:
//         return widget.data.hasError ? _kRedBg.withOpacity(0.3) : Colors.white;
//     }
//   }
//
//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final initial = _joiningDateCtrl.text.isNotEmpty
//         ? DateFormat('yyyy-MM-dd').parse(_joiningDateCtrl.text)
//         : now;
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2000),
//       lastDate: now,
//     );
//     if (picked != null) {
//       final formatted = DateFormat('yyyy-MM-dd').format(picked);
//       _joiningDateCtrl.text = formatted;
//       _emit();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isSaved = widget.data.status == RowStatus.saved;
//     final isSaving = widget.data.status == RowStatus.saving;
//     final enabled = !isSaved;
//
//     Widget statusIcon() {
//       if (isSaving) {
//         return const SizedBox(
//             width: 14,
//             height: 14,
//             child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple));
//       }
//       if (isSaved) return const Icon(Icons.check_circle, size: 18, color: _kGreen);
//       if (widget.data.hasError) {
//         return Tooltip(
//           message: widget.data.errorMsg,
//           child: const Icon(Icons.error_outline, size: 18, color: _kRed),
//         );
//       }
//       return Text('${widget.index + 1}',
//           style: const TextStyle(
//               fontSize: 12, fontWeight: FontWeight.w700, color: _kPurple));
//     }
//
//     return Container(
//       constraints: const BoxConstraints(minHeight: _kRowHeight),
//       decoration: BoxDecoration(
//         color: _bg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _borderColor, width: 1.2),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       child: _RowScaffold(builder: (isNarrow) {
//         final cells = <Widget>[
//           _cell(isNarrow, 0, Center(child: statusIcon())),
//           _cell(
//               isNarrow,
//               1,
//               _compactTextField(
//                 controller: _nameCtrl,
//                 hint: 'Ahmed Khan',
//                 enabled: enabled,
//                 onChanged: (_) {
//                   setState(() {});
//                   _emit();
//                 },
//               )),
//           _cell(
//               isNarrow,
//               2,
//               _compactDropdown<String>(
//                 value: widget.data.type,
//                 enabled: enabled,
//                 hint: 'Type',
//                 items: const [
//                   DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
//                   DropdownMenuItem(value: 'staff', child: Text('Staff')),
//                 ],
//                 onChanged: (v) =>
//                     widget.onChanged(widget.data.copyWith(type: v!)),
//               )),
//           _cell(
//               isNarrow,
//               3,
//               _compactTextField(
//                 controller: _phoneCtrl,
//                 hint: '03XX-XXXXXXX',
//                 keyboard: TextInputType.phone,
//                 enabled: enabled,
//                 onChanged: (_) => _emit(),
//               )),
//           _cell(
//               isNarrow,
//               4,
//               _compactTextField(
//                 controller: _cnicCtrl,
//                 hint: '34101-1234567-8',
//                 keyboard: TextInputType.number,
//                 inputFormatters: [_CnicFormatter()],
//                 enabled: enabled,
//                 onChanged: (_) => _emit(),
//               )),
//           _cell(
//               isNarrow,
//               5,
//               _compactTextField(
//                 controller: _desigCtrl,
//                 hint: 'Principal...',
//                 enabled: enabled,
//                 onChanged: (_) => _emit(),
//               )),
//           _cell(
//               isNarrow,
//               6,
//               _CompactClassField(
//                 classId: _classId,
//                 enabled: enabled,
//                 onChanged: (v) {
//                   setState(() {
//                     _classId = v;
//                     _sectionName = null;
//                   });
//                   _emit();
//                 },
//               )),
//           _cell(
//               isNarrow,
//               7,
//               _CompactSectionField(
//                 classId: _classId,
//                 sectionName: _sectionName,
//                 enabled: enabled,
//                 onChanged: (v) {
//                   setState(() => _sectionName = v);
//                   _emit();
//                 },
//               )),
//           _cell(
//               isNarrow,
//               8,
//               _compactDateField(
//                 controller: _joiningDateCtrl,
//                 enabled: enabled,
//                 onTap: _pickDate,
//               )),
//           _cell(
//               isNarrow,
//               9,
//               _compactTextField(
//                 controller: _salaryCtrl,
//                 hint: '0',
//                 keyboard: TextInputType.number,
//                 enabled: enabled,
//                 prefixText: 'Rs ',
//                 onChanged: (_) => _emit(),
//               )),
//           _cell(
//               isNarrow,
//               10,
//               Row(mainAxisSize: MainAxisSize.min, children: [
//                 if (enabled) ...[
//                   IconButton(
//                     icon: const Icon(Icons.edit_note, size: 19, color: _kPurple),
//                     onPressed: widget.onFullEdit,
//                     tooltip: 'Full details edit karein',
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                     visualDensity: VisualDensity.compact,
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     icon: Icon(Icons.delete_outline,
//                         size: 19,
//                         color: widget.total <= 1
//                             ? Colors.grey.shade300
//                             : Colors.red.shade300),
//                     onPressed: widget.total <= 1 ? null : widget.onRemove,
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                     visualDensity: VisualDensity.compact,
//                   ),
//                 ],
//               ])),
//         ];
//
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             for (int i = 0; i < cells.length; i++) ...[
//               if (i > 0) const SizedBox(width: _kColGap),
//               cells[i],
//             ],
//           ],
//         );
//       }),
//     );
//   }
//
//   Widget _cell(bool isNarrow, int colIndex, Widget child) {
//     final col = _kColumns[colIndex];
//     if (isNarrow) {
//       return SizedBox(width: col.minWidth, child: child);
//     }
//     return Expanded(flex: col.flex == 0 ? 1 : col.flex, child: child);
//   }
// }
//
// // ─── Full Edit Dialog (shared by Bulk Add + Bulk Edit) ────────────────────────
// class _FullEditDialog extends StatefulWidget {
//   final _RowData data;
//   final void Function(_RowData) onSave;
//   final VoidCallback onCancel;
//
//   const _FullEditDialog({
//     required this.data,
//     required this.onSave,
//     required this.onCancel,
//   });
//
//   @override
//   State<_FullEditDialog> createState() => _FullEditDialogState();
// }
//
// class _FullEditDialogState extends State<_FullEditDialog> {
//   late _RowData _editedData;
//   final _formKey = GlobalKey<FormState>();
//
//   late TextEditingController _nameCtrl;
//   late TextEditingController _fatherCtrl;
//   late TextEditingController _cnicCtrl;
//   late TextEditingController _religionCtrl;
//   late TextEditingController _nationalityCtrl;
//   late TextEditingController _addressCtrl;
//   late TextEditingController _phoneCtrl;
//   late TextEditingController _emergencyCtrl;
//   late TextEditingController _salaryCtrl;
//   late TextEditingController _referenceCtrl;
//   late TextEditingController _noteCtrl;
//   late TextEditingController _designationCtrl;
//
//   String _dob = '';
//   String _joiningDate = '';
//   List<String> _assignedClasses = [];
//   List<String> _assignedSections = [];
//   List<String> _subjects = [];
//   String _type = 'teacher';
//   String _gender = 'Male';
//   String _maritalStatus = 'Single';
//   String? _bloodGroup;
//   String _employmentType = 'Regular';
//
//   final _typeOptions = ['teacher', 'staff'];
//   final _genderOptions = ['Male', 'Female', 'Other'];
//   final _maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
//   final _bloodOptions = [
//     'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
//   ];
//   final _employmentOptions = ['Contract', 'Regular', 'Daily'];
//
//   @override
//   void initState() {
//     super.initState();
//     final d = widget.data;
//     _editedData = d;
//     _nameCtrl = TextEditingController(text: d.name);
//     _fatherCtrl = TextEditingController(text: d.fatherOrHusbandName);
//     _cnicCtrl = TextEditingController(text: d.cnic);
//     _religionCtrl = TextEditingController(text: d.religion);
//     _nationalityCtrl = TextEditingController(text: d.nationality);
//     _addressCtrl = TextEditingController(text: d.address);
//     _phoneCtrl = TextEditingController(text: d.phone);
//     _emergencyCtrl = TextEditingController(text: d.emergencyPhone);
//     _salaryCtrl = TextEditingController(
//         text: d.salary > 0 ? d.salary.toString() : '');
//     _referenceCtrl = TextEditingController(text: d.reference ?? '');
//     _noteCtrl = TextEditingController(text: d.note ?? '');
//     _designationCtrl =
//         TextEditingController(text: d.designation ?? '');
//
//     _type = d.type;
//     _gender = d.gender;
//     _maritalStatus = d.maritalStatus;
//     _bloodGroup = d.bloodGroup;
//     _employmentType = d.employmentType;
//     _dob = d.dob;
//     _joiningDate =
//         d.joiningDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
//     _assignedClasses = List.from(d.assignedClasses);
//     _assignedSections = List.from(d.assignedSections);
//     _subjects = List.from(d.subjects);
//
//     // Seed from the quick row's class/section too, in case the row was
//     // filled in table view and this dialog is opened afterwards.
//     if (_assignedClasses.isEmpty && d.classId != null) {
//       _assignedClasses = [d.classId!];
//     }
//     if (_assignedSections.isEmpty && d.sectionName != null) {
//       _assignedSections = [d.sectionName!];
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _fatherCtrl.dispose();
//     _cnicCtrl.dispose();
//     _religionCtrl.dispose();
//     _nationalityCtrl.dispose();
//     _addressCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emergencyCtrl.dispose();
//     _salaryCtrl.dispose();
//     _referenceCtrl.dispose();
//     _noteCtrl.dispose();
//     _designationCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickDob() async {
//     final now = DateTime.now();
//     final initialDate = _dob.isNotEmpty
//         ? DateFormat('yyyy-MM-dd').parse(_dob)
//         : DateTime(now.year - 25, 1, 1);
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(1940),
//       lastDate: now,
//     );
//     if (picked != null) {
//       setState(() => _dob = DateFormat('yyyy-MM-dd').format(picked));
//     }
//   }
//
//   Future<void> _pickJoiningDate() async {
//     final now = DateTime.now();
//     final initialDate = _joiningDate.isNotEmpty
//         ? DateFormat('yyyy-MM-dd').parse(_joiningDate)
//         : now;
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(2000),
//       lastDate: now,
//     );
//     if (picked != null) {
//       setState(
//               () => _joiningDate = DateFormat('yyyy-MM-dd').format(picked));
//     }
//   }
//
//   void _save() {
//     if (!_formKey.currentState!.validate()) return;
//
//     if (_assignedClasses.isNotEmpty) {
//       // Every class in this school has at least one section, so requiring
//       // a section whenever a class is picked keeps data consistent.
//       final classProvider = context.read<ClassProvider>();
//       for (final classId in _assignedClasses) {
//         final cls = classProvider.classes
//             .where((c) => c.id == classId)
//             .cast<SchoolClass?>()
//             .firstWhere((c) => c != null, orElse: () => null);
//         final sectionNames =
//         (cls?.sections ?? []).map((s) => s.sectionName).toSet();
//         final hasMatchingSection =
//         _assignedSections.any((s) => sectionNames.contains(s));
//         if (sectionNames.isNotEmpty && !hasMatchingSection) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(
//                 '${cls?.name ?? 'Selected class'} ke liye ek section select karein.'),
//             backgroundColor: _kRed,
//           ));
//           return;
//         }
//       }
//     }
//
//     final String? effectiveClassId =
//     _assignedClasses.isEmpty ? null : _assignedClasses.first;
//     final String? effectiveSectionName =
//     _assignedSections.isEmpty ? null : _assignedSections.first;
//
//     final updated = _editedData.copyWith(
//       type: _type,
//       name: _nameCtrl.text.trim(),
//       fatherOrHusbandName: _fatherCtrl.text.trim(),
//       cnic: _cnicCtrl.text.trim(),
//       dob: _dob,
//       gender: _gender,
//       maritalStatus: _maritalStatus,
//       bloodGroup: _bloodGroup,
//       religion: _religionCtrl.text.trim(),
//       nationality: _nationalityCtrl.text.trim(),
//       address: _addressCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       emergencyPhone: _emergencyCtrl.text.trim(),
//       employmentType: _employmentType,
//       salary: double.tryParse(_salaryCtrl.text) ?? 0,
//       reference: _referenceCtrl.text.trim().isEmpty
//           ? null
//           : _referenceCtrl.text.trim(),
//       note: _noteCtrl.text.trim().isEmpty
//           ? null
//           : _noteCtrl.text.trim(),
//       designation: _designationCtrl.text.trim().isEmpty
//           ? null
//           : _designationCtrl.text.trim(),
//       joiningDate: _joiningDate.isEmpty ? null : _joiningDate,
//       classId: effectiveClassId,
//       sectionName: effectiveSectionName,
//       assignedClasses: _assignedClasses,
//       assignedSections: _assignedSections,
//       subjects: _subjects,
//       hasError: false,
//       errorMsg: '',
//     );
//     widget.onSave(updated);
//   }
//
//   Widget _buildClassSectionSelector() {
//     return Consumer<ClassProvider>(
//       builder: (context, classProvider, _) {
//         final classes = classProvider.classes;
//         if (classes.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.amber.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.amber.shade200),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.info_outline,
//                     size: 15, color: Colors.amber.shade700),
//                 const SizedBox(width: 8),
//                 const Expanded(
//                   child: Text(
//                     'Pehle classes add karein.',
//                     style:
//                     TextStyle(fontSize: 12, color: Colors.amber),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Wrap(
//               spacing: 8,
//               runSpacing: 6,
//               children: classes.map((cls) {
//                 final isSelected = _assignedClasses.contains(cls.id);
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       if (isSelected) {
//                         _assignedClasses.remove(cls.id);
//                         final sectionNames = (cls.sections)
//                             .map((s) => s.sectionName)
//                             .toSet();
//                         _assignedSections.removeWhere(
//                                 (sec) => sectionNames.contains(sec));
//                       } else {
//                         _assignedClasses.add(cls.id!);
//                       }
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 150),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 7),
//                     decoration: BoxDecoration(
//                       color: isSelected ? _kPurple : Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected
//                             ? _kPurple
//                             : Colors.grey.shade300,
//                         width: isSelected ? 1.5 : 0.8,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         if (isSelected) ...[
//                           const Icon(Icons.check,
//                               size: 14, color: Colors.white),
//                           const SizedBox(width: 4),
//                         ],
//                         Text(
//                           cls.name,
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             color: isSelected
//                                 ? Colors.white
//                                 : Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//             if (_assignedClasses.isNotEmpty) ...[
//               const SizedBox(height: 14),
//               Text(
//                 'Sections select karein: *',
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: _kPurple),
//               ),
//               const SizedBox(height: 8),
//               ..._assignedClasses.map((classId) {
//                 final cls =
//                 classes.firstWhere((c) => c.id == classId);
//                 final sections = cls.sections;
//                 if (sections.isEmpty) {
//                   return Padding(
//                     padding: const EdgeInsets.only(left: 4, bottom: 8),
//                     child: Row(children: [
//                       Icon(Icons.info_outline,
//                           size: 14,
//                           color: Colors.orange.shade400),
//                       const SizedBox(width: 6),
//                       Text(
//                         '${cls.name} mein koi section nahi hai',
//                         style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.orange.shade700),
//                       ),
//                     ]),
//                   );
//                 }
//                 return Padding(
//                   padding: const EdgeInsets.only(left: 4, bottom: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(cls.name,
//                           style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey.shade700)),
//                       const SizedBox(height: 6),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 6,
//                         children: sections.map((section) {
//                           final sectionName = section.sectionName;
//                           final isSelected =
//                           _assignedSections.contains(sectionName);
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 if (isSelected) {
//                                   _assignedSections.remove(sectionName);
//                                 } else {
//                                   _assignedSections.add(sectionName);
//                                 }
//                               });
//                             },
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 150),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 7),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? _kPurple
//                                     : Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? _kPurple
//                                       : Colors.grey.shade300,
//                                   width: isSelected ? 1.5 : 0.8,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   if (isSelected) ...[
//                                     const Icon(Icons.check,
//                                         size: 14, color: Colors.white),
//                                     const SizedBox(width: 4),
//                                   ],
//                                   Text(
//                                     sectionName,
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w500,
//                                       color: isSelected
//                                           ? Colors.white
//                                           : Colors.black87,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ],
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildSubjectSelector() {
//     return Consumer<MuddulProvider>(
//       builder: (context, provider, _) {
//         if (provider.loading) {
//           return const Center(
//               child: CircularProgressIndicator(strokeWidth: 2));
//         }
//         final allSubjects =
//         provider.mudduls.map((m) => m.subjectName).toSet().toList()
//           ..sort();
//         if (allSubjects.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.amber.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.amber.shade200),
//             ),
//             child: Row(children: [
//               Icon(Icons.info_outline,
//                   size: 16, color: Colors.amber.shade700),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text(
//                   'Koi subject nahi mila. Pehle subjects add karein.',
//                   style: TextStyle(fontSize: 12, color: Colors.amber),
//                 ),
//               ),
//             ]),
//           );
//         }
//         return Wrap(
//           spacing: 8,
//           runSpacing: 6,
//           children: allSubjects.map((subject) {
//             final isSelected = _subjects.contains(subject);
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (isSelected) {
//                     _subjects.remove(subject);
//                   } else {
//                     _subjects.add(subject);
//                   }
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 150),
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 7),
//                 decoration: BoxDecoration(
//                   color: isSelected ? _kPurple : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: isSelected ? _kPurple : Colors.grey.shade300,
//                     width: isSelected ? 1.5 : 0.8,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (isSelected) ...[
//                       const Icon(Icons.check,
//                           size: 14, color: Colors.white),
//                       const SizedBox(width: 4),
//                     ],
//                     Text(
//                       subject,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color:
//                         isSelected ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width >= 700;
//
//     return Dialog(
//       shape:
//       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding: EdgeInsets.symmetric(
//         horizontal: isWide ? 40 : 12,
//         vertical: 24,
//       ),
//       child: Container(
//         width: isWide ? 700 : double.infinity,
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.92,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [_kPurple, _kPurpleMid],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius:
//                 BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: Row(children: [
//                 const Icon(Icons.person_add_alt_1_outlined,
//                     color: Colors.white70, size: 20),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _nameCtrl.text.trim().isEmpty
//                             ? 'Full Details'
//                             : _nameCtrl.text.trim(),
//                         style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white),
//                       ),
//                       Text(
//                         _type == 'teacher' ? 'Teacher' : 'Staff Member',
//                         style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.white.withOpacity(0.7)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white70),
//                   onPressed: widget.onCancel,
//                 ),
//               ]),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Form(
//                   key: _formKey,
//                   child: isWide
//                       ? _buildDesktopForm()
//                       : _buildMobileForm(),
//                 ),
//               ),
//             ),
//             const Divider(height: 1),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   OutlinedButton(
//                     onPressed: widget.onCancel,
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: _kPurple),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(color: _kPurple)),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton.icon(
//                     onPressed: _save,
//                     icon: const Icon(Icons.check, size: 16),
//                     label: const Text('Save Row'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _kPurple,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDesktopForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _dialogSection('Role', Icons.manage_accounts_outlined, [
//           Row(
//             children: _typeOptions.map((t) {
//               final sel = _type == t;
//               return GestureDetector(
//                 onTap: () => setState(() => _type = t),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 150),
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 20, vertical: 8),
//                   margin: const EdgeInsets.only(right: 10),
//                   decoration: BoxDecoration(
//                     color: sel ? _kPurple : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: sel ? _kPurple : Colors.grey.shade300),
//                   ),
//                   child: Text(
//                     t == 'teacher' ? 'Teacher' : 'Staff',
//                     style: TextStyle(
//                       color: sel ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ]),
//         _dialogSection(
//             'Personal Information', Icons.person_outline, [
//           _row2([
//             _df('Full Name *', _nameCtrl,
//                 validator: (v) =>
//                 v!.trim().isEmpty ? 'Required' : null,
//                 onChanged: (_) => setState(() {})),
//             _df('Designation', _designationCtrl,
//                 hint: 'e.g. Principal, Head Teacher...',
//                 onChanged: (_) => setState(() {})),
//           ]),
//           _row2([
//             _df(
//               _maritalStatus == 'Married'
//                   ? 'Husband Name *'
//                   : 'Father Name *',
//               _fatherCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null,
//             ),
//             _cnicField(),
//           ]),
//           _row2([
//             _dateField('Date of Birth', _dob, _pickDob,
//                 validator: (_) =>
//                 _dob.isEmpty ? 'Required' : null),
//             _dateField('Joining Date', _joiningDate,
//                 _pickJoiningDate),
//           ]),
//           _row2([
//             _dropdownField('Gender', _gender, _genderOptions,
//                     (v) => setState(() => _gender = v!)),
//             _dropdownField('Marital Status', _maritalStatus,
//                 _maritalOptions,
//                     (v) => setState(() => _maritalStatus = v!)),
//           ]),
//           _row2([
//             _dropdownField('Blood Group (Optional)', _bloodGroup,
//                 _bloodOptions,
//                     (v) => setState(() => _bloodGroup = v),
//                 nullable: true),
//             _df('Religion *', _religionCtrl,
//                 validator: (v) =>
//                 v!.trim().isEmpty ? 'Required' : null),
//           ]),
//           _df('Nationality *', _nationalityCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//         ]),
//         _dialogSection(
//             'Contact Information', Icons.contact_phone_outlined, [
//           _df('Address *', _addressCtrl,
//               maxLines: 2,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//           _row2([
//             _df('Phone No *', _phoneCtrl,
//                 keyboard: TextInputType.phone,
//                 validator: (v) =>
//                 v!.trim().isEmpty ? 'Required' : null),
//             _df('Emergency No *', _emergencyCtrl,
//                 keyboard: TextInputType.phone,
//                 validator: (v) =>
//                 v!.trim().isEmpty ? 'Required' : null),
//           ]),
//         ]),
//         _dialogSection('Job Details', Icons.work_outline, [
//           _row2([
//             _dropdownField('Employment Type', _employmentType,
//                 _employmentOptions,
//                     (v) => setState(() => _employmentType = v!)),
//             _salaryField(),
//           ]),
//         ]),
//         _dialogSection(
//             'Assigned Class & Section', Icons.class_outlined, [
//           _buildClassSectionSelector(),
//         ]),
//         _dialogSection(
//             'Assigned Subjects', Icons.menu_book_outlined, [
//           _buildSubjectSelector(),
//         ]),
//         _dialogSection(
//             'Additional Info (Optional)', Icons.info_outline, [
//           _row2([
//             _df('Reference', _referenceCtrl),
//             _df('Note', _noteCtrl, maxLines: 3),
//           ]),
//         ]),
//       ],
//     );
//   }
//
//   Widget _buildMobileForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _dialogSection('Role', Icons.manage_accounts_outlined, [
//           Wrap(
//             spacing: 8,
//             children: _typeOptions.map((t) {
//               final sel = _type == t;
//               return GestureDetector(
//                 onTap: () => setState(() => _type = t),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 150),
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 20, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: sel ? _kPurple : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: sel ? _kPurple : Colors.grey.shade300),
//                   ),
//                   child: Text(
//                     t == 'teacher' ? 'Teacher' : 'Staff',
//                     style: TextStyle(
//                       color: sel ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ]),
//         _dialogSection(
//             'Personal Information', Icons.person_outline, [
//           _df('Full Name *', _nameCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null,
//               onChanged: (_) => setState(() {})),
//           _df('Designation', _designationCtrl,
//               hint: 'e.g. Principal, Head Teacher...',
//               onChanged: (_) => setState(() {})),
//           _df(
//             _maritalStatus == 'Married' ? 'Husband Name *' : 'Father Name *',
//             _fatherCtrl,
//             validator: (v) => v!.trim().isEmpty ? 'Required' : null,
//           ),
//           _cnicField(),
//           _dateField('Date of Birth', _dob, _pickDob,
//               validator: (_) =>
//               _dob.isEmpty ? 'Required' : null),
//           _dateField(
//               'Joining Date', _joiningDate, _pickJoiningDate),
//           _dropdownField('Gender', _gender, _genderOptions,
//                   (v) => setState(() => _gender = v!)),
//           _dropdownField('Marital Status', _maritalStatus,
//               _maritalOptions,
//                   (v) => setState(() => _maritalStatus = v!)),
//           _dropdownField('Blood Group (Optional)', _bloodGroup,
//               _bloodOptions,
//                   (v) => setState(() => _bloodGroup = v),
//               nullable: true),
//           _df('Religion *', _religionCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//           _df('Nationality *', _nationalityCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//         ]),
//         _dialogSection(
//             'Contact Information', Icons.contact_phone_outlined, [
//           _df('Address *', _addressCtrl,
//               maxLines: 2,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//           _df('Phone No *', _phoneCtrl,
//               keyboard: TextInputType.phone,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//           _df('Emergency No *', _emergencyCtrl,
//               keyboard: TextInputType.phone,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//         ]),
//         _dialogSection('Job Details', Icons.work_outline, [
//           _dropdownField('Employment Type', _employmentType,
//               _employmentOptions,
//                   (v) => setState(() => _employmentType = v!)),
//           _salaryField(),
//         ]),
//         _dialogSection(
//             'Assigned Class & Section', Icons.class_outlined, [
//           _buildClassSectionSelector(),
//         ]),
//         _dialogSection(
//             'Assigned Subjects', Icons.menu_book_outlined, [
//           _buildSubjectSelector(),
//         ]),
//         _dialogSection(
//             'Additional Info (Optional)', Icons.info_outline, [
//           _df('Reference', _referenceCtrl),
//           _df('Note', _noteCtrl, maxLines: 3),
//         ]),
//       ],
//     );
//   }
//
//   Widget _dialogSection(
//       String title, IconData icon, List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFEEEFF3)),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: const BoxDecoration(
//             color: _kPurpleLight,
//             borderRadius:
//             BorderRadius.vertical(top: Radius.circular(12)),
//           ),
//           child: Row(children: [
//             Icon(icon, size: 16, color: _kPurple),
//             const SizedBox(width: 8),
//             Text(title,
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: _kPurple)),
//           ]),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: _spaced(children, 10),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   Widget _row2(List<Widget> children) {
//     return Row(
//       children: children
//           .map((w) => Expanded(child: w))
//           .expand((w) => [w, const SizedBox(width: 10)])
//           .toList()
//         ..removeLast(),
//     );
//   }
//
//   Widget _df(
//       String label,
//       TextEditingController ctrl, {
//         String? hint,
//         int maxLines = 1,
//         TextInputType? keyboard,
//         String? Function(String?)? validator,
//         ValueChanged<String>? onChanged,
//       }) {
//     return TextFormField(
//       controller: ctrl,
//       maxLines: maxLines,
//       keyboardType: keyboard,
//       onChanged: onChanged,
//       decoration: _deco(label, hint: hint),
//       validator: validator,
//       style: const TextStyle(fontSize: 13),
//     );
//   }
//
//   Widget _cnicField() {
//     return TextFormField(
//       controller: _cnicCtrl,
//       keyboardType: TextInputType.number,
//       maxLength: 15,
//       inputFormatters: [_CnicFormatter()],
//       decoration:
//       _deco('CNIC (34101-1234567-8)').copyWith(counterText: ''),
//       style: const TextStyle(fontSize: 13),
//       validator: (v) {
//         if (v == null || v.trim().isEmpty) return null;
//         final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
//         if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
//         return null;
//       },
//     );
//   }
//
//   Widget _salaryField() {
//     return TextFormField(
//       controller: _salaryCtrl,
//       decoration: _deco('Salary *').copyWith(prefixText: 'Rs  '),
//       keyboardType: TextInputType.number,
//       style: const TextStyle(fontSize: 13),
//       validator: (v) =>
//       v == null || v.trim().isEmpty ? 'Required' : null,
//     );
//   }
//
//   Widget _dateField(
//       String label,
//       String value,
//       VoidCallback onTap, {
//         String? Function(String?)? validator,
//       }) {
//     return TextFormField(
//       readOnly: true,
//       controller: TextEditingController(text: value),
//       decoration: _deco(label).copyWith(
//         suffixIcon: const Icon(Icons.calendar_today,
//             size: 16, color: _kPurple),
//       ),
//       style: const TextStyle(fontSize: 13),
//       onTap: onTap,
//       validator: validator,
//     );
//   }
//
//   Widget _dropdownField<T>(
//       String label,
//       T value,
//       List<String> items,
//       ValueChanged<T?> onChanged, {
//         bool nullable = false,
//       }) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       decoration: _deco(label),
//       style: const TextStyle(fontSize: 13, color: Colors.black87),
//       items: [
//         if (nullable)
//           const DropdownMenuItem(
//               value: null,
//               child: Text('Select (Optional)')) as DropdownMenuItem<T>,
//         ...items.map(
//                 (i) => DropdownMenuItem<T>(value: i as T, child: Text(i))),
//       ],
//       onChanged: onChanged,
//     );
//   }
//
//   InputDecoration _deco(String label, {String? hint}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: const TextStyle(fontSize: 12),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: _kPurple, width: 1.5),
//       ),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     );
//   }
//
//   List<Widget> _spaced(List<Widget> children, double gap) {
//     final result = <Widget>[];
//     for (int i = 0; i < children.length; i++) {
//       result.add(children[i]);
//       if (i < children.length - 1) result.add(SizedBox(height: gap));
//     }
//     return result;
//   }
// }
//
// // ─── Bulk Edit Screen ──────────────────────────────────────────────────────────
// // Card-based selection replaced with compact table rows matching Bulk Add.
// // The core rule of this screen: NOTHING is editable until a row is selected.
// // Selection can happen two ways — tapping the checkbox, or tapping anywhere
// // on the row itself. Once selected, the row's fields light up and behave
// // exactly like Bulk Add's row. Unselected rows are visually dimmed and fully
// // inert — no field, dropdown, or date-picker responds to touch until selected.
// class BulkEditStaffScreen extends StatefulWidget {
//   final String? initialTypeFilter;
//
//   const BulkEditStaffScreen({super.key, this.initialTypeFilter});
//
//   @override
//   State<BulkEditStaffScreen> createState() => _BulkEditStaffScreenState();
// }
//
// class _BulkEditStaffScreenState extends State<BulkEditStaffScreen> {
//   // rowId -> _RowData (rowId == existingStaffId for hydrated rows)
//   final Map<String, _RowData> _rows = {};
//   final Set<String> _selectedIds = {};
//
//   String _typeFilter = 'all'; // all | teacher | staff
//   String? _classFilter; // classId, null = all classes
//   String? _sectionFilter; // sectionName, null = all sections (within class)
//   String _searchQuery = '';
//   final _searchCtrl = TextEditingController();
//
//   bool _isSavingAll = false;
//   bool _hydrated = false;
//   int _savedCount = 0;
//   int _failedCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _typeFilter = widget.initialTypeFilter ?? 'all';
//     _searchCtrl.addListener(
//             () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
//     Future.microtask(() async {
//       final provider = context.read<StaffProvider>();
//       await Future.wait([
//         provider.fetchTeachers(),
//         provider.fetchStaffOnly(),
//       ]);
//       _hydrateRows();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   void _hydrateRows() {
//     final provider = context.read<StaffProvider>();
//     final all = [...provider.teachers, ...provider.staffOnly];
//     setState(() {
//       _rows.clear();
//       for (final s in all) {
//         if (s.id == null) continue;
//         _rows[s.id!] = _RowData.fromStaffMember(s);
//       }
//       _hydrated = true;
//     });
//   }
//
//   List<_RowData> get _visibleRows {
//     var list = _rows.values.toList();
//
//     if (_typeFilter != 'all') {
//       list = list.where((r) => r.type == _typeFilter).toList();
//     }
//     if (_classFilter != null) {
//       list = list.where((r) {
//         final classes =
//         r.classId != null ? [r.classId!] : r.assignedClasses;
//         return classes.contains(_classFilter);
//       }).toList();
//     }
//     if (_sectionFilter != null) {
//       list = list
//           .where((r) => r.assignedSections.contains(_sectionFilter))
//           .toList();
//     }
//     if (_searchQuery.isNotEmpty) {
//       list = list.where((r) {
//         return r.name.toLowerCase().contains(_searchQuery) ||
//             r.phone.toLowerCase().contains(_searchQuery) ||
//             (r.designation ?? '').toLowerCase().contains(_searchQuery);
//       }).toList();
//     }
//     return list;
//   }
//
//   void _updateRow(String rowId, _RowData updated) {
//     setState(() => _rows[rowId] = updated);
//   }
//
//   void _selectRow(String rowId) {
//     if (_selectedIds.contains(rowId)) return;
//     setState(() => _selectedIds.add(rowId));
//   }
//
//   void _toggleSelect(String rowId) {
//     setState(() {
//       if (_selectedIds.contains(rowId)) {
//         _selectedIds.remove(rowId);
//       } else {
//         _selectedIds.add(rowId);
//       }
//     });
//   }
//
//   void _selectAllVisible() {
//     final visible = _visibleRows.map((r) => r.id).toList();
//     setState(() {
//       final allSelected =
//           visible.isNotEmpty && visible.every(_selectedIds.contains);
//       if (allSelected) {
//         _selectedIds.removeAll(visible);
//       } else {
//         _selectedIds.addAll(visible);
//       }
//     });
//   }
//
//   void _openFullEdit(_RowData data) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => _FullEditDialog(
//         data: data,
//         onSave: (updated) {
//           _updateRow(data.id, updated);
//           Navigator.pop(ctx);
//         },
//         onCancel: () => Navigator.pop(ctx),
//       ),
//     );
//   }
//
//   Future<void> _saveSelected() async {
//     if (_selectedIds.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//                 'Pehle kam az kam ek row select karein (checkbox ya row par tap karein).'),
//             backgroundColor: _kOrange),
//       );
//       return;
//     }
//
//     // Validate selected rows first.
//     bool anyError = false;
//     setState(() {
//       for (final id in _selectedIds) {
//         final row = _rows[id]!;
//         final err = row.validate();
//         if (err != null) {
//           _rows[id] = row.copyWith(hasError: true, errorMsg: err);
//           anyError = true;
//         } else {
//           _rows[id] = row.copyWith(hasError: false, errorMsg: '');
//         }
//       }
//     });
//
//     if (anyError) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please fix errors before saving.'),
//             backgroundColor: _kRed),
//       );
//       return;
//     }
//
//     setState(() {
//       _isSavingAll = true;
//       _savedCount = 0;
//       _failedCount = 0;
//       for (final id in _selectedIds) {
//         _rows[id] = _rows[id]!.copyWith(status: RowStatus.saving);
//       }
//     });
//
//     final provider = context.read<StaffProvider>();
//
//     for (final id in _selectedIds.toList()) {
//       final row = _rows[id]!;
//       try {
//         await provider.updateStaff(row.existingStaffId ?? id, row.toStaffMember());
//         if (mounted) {
//           setState(() {
//             _rows[id] =
//                 row.copyWith(status: RowStatus.saved, hasError: false);
//             _savedCount++;
//           });
//         }
//       } catch (e) {
//         if (mounted) {
//           setState(() {
//             _rows[id] = row.copyWith(
//               status: RowStatus.failed,
//               hasError: true,
//               errorMsg: 'Update failed: $e',
//             );
//             _failedCount++;
//           });
//         }
//       }
//     }
//
//     if (mounted) {
//       setState(() => _isSavingAll = false);
//       provider.fetchTeachers();
//       provider.fetchStaffOnly();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               '$_savedCount updated${_failedCount > 0 ? ', $_failedCount failed' : ''}'),
//           backgroundColor: _failedCount > 0 ? _kOrange : _kGreen,
//         ),
//       );
//
//       if (_failedCount == 0) {
//         setState(() => _selectedIds.clear());
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final classProvider = context.watch<ClassProvider>();
//     final staffProviderLoading = context.watch<StaffProvider>().loading;
//     final visible = _visibleRows;
//     final allVisibleSelected =
//         visible.isNotEmpty && visible.every((r) => _selectedIds.contains(r.id));
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F8),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         scrolledUnderElevation: 1,
//         title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text('Bulk Edit Staff / Teachers',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//           Text(
//               '${_selectedIds.length} selected · ${visible.length} visible',
//               style: const TextStyle(fontSize: 11, color: Colors.grey)),
//         ]),
//       ),
//       body: Column(children: [
//         // ── Instruction banner (mirrors Bulk Add's info bar) ───────────
//         Container(
//           color: _kPurpleLight,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Row(children: [
//             const Icon(Icons.info_outline, size: 15, color: _kPurple),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Row select karein (☑️ checkbox ya row par tap) — sirf selected rows hi editable hongi.',
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//               ),
//             ),
//           ]),
//         ),
//         // ── Filters bar ──────────────────────────────────────────────
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(children: [
//                 Checkbox(
//                   value: allVisibleSelected,
//                   onChanged: (_) => _selectAllVisible(),
//                   activeColor: _kPurple,
//                 ),
//                 Text('Select all visible',
//                     style: TextStyle(
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade700)),
//               ]),
//               Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 crossAxisAlignment: WrapCrossAlignment.center,
//                 children: [
//                   _filterChip('All', 'all'),
//                   _filterChip('Teachers', 'teacher'),
//                   _filterChip('Staff', 'staff'),
//                   Container(
//                       width: 1,
//                       height: 22,
//                       color: Colors.grey.shade300,
//                       margin: const EdgeInsets.symmetric(horizontal: 4)),
//                   _classFilterDropdown(classProvider),
//                   _sectionFilterDropdown(classProvider),
//                   if (_classFilter != null || _sectionFilter != null)
//                     TextButton.icon(
//                       onPressed: () => setState(() {
//                         _classFilter = null;
//                         _sectionFilter = null;
//                       }),
//                       icon: const Icon(Icons.filter_alt_off_outlined,
//                           size: 15, color: _kRed),
//                       label: const Text('Clear filters',
//                           style: TextStyle(fontSize: 12, color: _kRed)),
//                       style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 8)),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 40,
//                 child: TextField(
//                   controller: _searchCtrl,
//                   decoration: InputDecoration(
//                     hintText: 'Search by name, phone, designation…',
//                     hintStyle: TextStyle(
//                         fontSize: 12, color: Colors.grey.shade400),
//                     prefixIcon: const Icon(Icons.search,
//                         size: 17, color: Colors.grey),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 0),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide:
//                         BorderSide(color: Colors.grey.shade300)),
//                     enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide:
//                         BorderSide(color: Colors.grey.shade300)),
//                     focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide:
//                         const BorderSide(color: _kPurple)),
//                     filled: true,
//                     fillColor: const Color(0xFFF8F9FC),
//                   ),
//                   style: const TextStyle(fontSize: 13),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const Divider(height: 1),
//         if (_selectedIds.isNotEmpty)
//           Container(
//             color: _kPurpleLight,
//             padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(children: [
//               const Icon(Icons.lock_open_rounded, size: 16, color: _kPurple),
//               const SizedBox(width: 8),
//               Text('${_selectedIds.length} selected · editable now',
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: _kPurple)),
//               const Spacer(),
//               TextButton(
//                 onPressed: () => setState(() => _selectedIds.clear()),
//                 child: const Text('Deselect all',
//                     style: TextStyle(fontSize: 12, color: _kPurple)),
//               ),
//             ]),
//           ),
//         // ── Table header ─────────────────────────────────────────────
//         _TableHeader(showCheckbox: true),
//         // ── Rows ─────────────────────────────────────────────────────
//         Expanded(
//           child: (staffProviderLoading && !_hydrated)
//               ? const Center(
//               child: CircularProgressIndicator(color: _kPurple))
//               : visible.isEmpty
//               ? _buildEmpty()
//               : ListView.builder(
//             padding: const EdgeInsets.fromLTRB(10, 6, 10, 90),
//             itemCount: visible.length,
//             itemBuilder: (ctx, i) {
//               final row = visible[i];
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: _EditableStaffTableRow(
//                   key: ValueKey(row.id),
//                   data: row,
//                   selected: _selectedIds.contains(row.id),
//                   onSelectToggle: () => _toggleSelect(row.id),
//                   onSelectOnly: () => _selectRow(row.id),
//                   onChanged: (updated) => _updateRow(row.id, updated),
//                   onFullEdit: () => _openFullEdit(row),
//                 ),
//               );
//             },
//           ),
//         ),
//       ]),
//       bottomNavigationBar: _selectedIds.isEmpty
//           ? null
//           : Container(
//         padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border(top: BorderSide(color: Colors.grey.shade200)),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, -3)),
//           ],
//         ),
//         child: SafeArea(
//           top: false,
//           child: Row(children: [
//             if (_savedCount > 0) ...[
//               _pill('$_savedCount saved', _kGreen, _kGreenBg),
//               const SizedBox(width: 8),
//             ],
//             if (_failedCount > 0) ...[
//               _pill('$_failedCount failed', _kRed, _kRedBg),
//               const SizedBox(width: 8),
//             ],
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: _isSavingAll ? null : _saveSelected,
//                 icon: _isSavingAll
//                     ? const SizedBox(
//                     width: 14,
//                     height: 14,
//                     child: CircularProgressIndicator(
//                         strokeWidth: 2, color: Colors.white))
//                     : const Icon(Icons.cloud_upload_outlined, size: 17),
//                 label: Text(_isSavingAll
//                     ? 'Saving...'
//                     : 'Save Selected (${_selectedIds.length})'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _kPurple,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(vertical: 13),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   textStyle: const TextStyle(
//                       fontSize: 13, fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
//
//   Widget _classFilterDropdown(ClassProvider classProvider) {
//     final classes = classProvider.classes;
//     return SizedBox(
//       width: 170,
//       height: 34,
//       child: DropdownButtonFormField<String>(
//         value: _classFilter,
//         isDense: true,
//         isExpanded: true,
//         decoration: _filterDropDecoration('All Classes'),
//         items: [
//           const DropdownMenuItem(value: null, child: Text('All Classes')),
//           ...classes.map((c) =>
//               DropdownMenuItem(value: c.id, child: Text(c.name))),
//         ],
//         onChanged: (v) => setState(() {
//           _classFilter = v;
//           _sectionFilter = null; // reset section when class changes
//         }),
//       ),
//     );
//   }
//
//   Widget _sectionFilterDropdown(ClassProvider classProvider) {
//     if (_classFilter == null) {
//       return SizedBox(
//         width: 170,
//         height: 34,
//         child: DropdownButtonFormField<String>(
//           value: null,
//           isDense: true,
//           isExpanded: true,
//           decoration: _filterDropDecoration('All Sections'),
//           items: const [
//             DropdownMenuItem(value: null, child: Text('All Sections')),
//           ],
//           onChanged: null,
//         ),
//       );
//     }
//     final cls = classProvider.classes
//         .where((c) => c.id == _classFilter)
//         .cast<SchoolClass?>()
//         .firstWhere((c) => c != null, orElse: () => null);
//     final sections = cls?.sections ?? [];
//     return SizedBox(
//       width: 170,
//       height: 34,
//       child: DropdownButtonFormField<String>(
//         value: _sectionFilter,
//         isDense: true,
//         isExpanded: true,
//         decoration: _filterDropDecoration('All Sections'),
//         style: const TextStyle(fontSize: 12, color: Colors.black87),
//         items: [
//           const DropdownMenuItem(value: null, child: Text('All Sections')),
//           ...sections.map((s) => DropdownMenuItem(
//               value: s.sectionName, child: Text(s.sectionName))),
//         ],
//         onChanged: sections.isEmpty
//             ? null
//             : (v) => setState(() => _sectionFilter = v),
//       ),
//     );
//   }
//
//   InputDecoration _filterDropDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300)),
//       enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300)),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: _kPurple, width: 1.5)),
//       filled: true,
//       fillColor: const Color(0xFFF8F9FC),
//     );
//   }
//
//   Widget _pill(String label, Color text, Color bg) => Container(
//     padding:
//     const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//     decoration:
//     BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
//     child: Text(label,
//         style: TextStyle(
//             fontSize: 12, color: text, fontWeight: FontWeight.w700)),
//   );
//
//   Widget _filterChip(String label, String value) {
//     final isActive = _typeFilter == value;
//     return GestureDetector(
//       onTap: () => setState(() => _typeFilter = value),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding:
//         const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//         decoration: BoxDecoration(
//           color: isActive ? _kPurple : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//               color: isActive ? _kPurple : Colors.grey.shade300),
//         ),
//         child: Text(label,
//             style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: isActive
//                     ? Colors.white
//                     : Colors.grey.shade700)),
//       ),
//     );
//   }
//
//   Widget _buildEmpty() => Center(
//     child: Column(mainAxisSize: MainAxisSize.min, children: [
//       Icon(Icons.people_outline,
//           size: 48, color: Colors.grey.shade300),
//       const SizedBox(height: 12),
//       Text(
//         _searchQuery.isEmpty
//             ? 'No records match the current filters.'
//             : 'No results for "$_searchQuery"',
//         style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//       ),
//     ]),
//   );
// }
//
// // ─── Editable Staff Table Row (Bulk Edit) ─────────────────────────────────────
// // Same compact table visual language as _StaffTableRow (Bulk Add), plus a
// // selection checkbox at the start of the row and a gating layer
// // (IgnorePointer + Opacity) so nothing is editable until the row is selected.
// // Tapping anywhere on the dimmed row selects it (never deselects on tap, so
// // editing never gets interrupted mid-flow); the checkbox is the only way to
// // deselect.
// class _EditableStaffTableRow extends StatefulWidget {
//   final _RowData data;
//   final bool selected;
//   final VoidCallback onSelectToggle; // checkbox: toggles both ways
//   final VoidCallback onSelectOnly;   // row tap: selects only, never deselects
//   final ValueChanged<_RowData> onChanged;
//   final VoidCallback onFullEdit;
//
//   const _EditableStaffTableRow({
//     super.key,
//     required this.data,
//     required this.selected,
//     required this.onSelectToggle,
//     required this.onSelectOnly,
//     required this.onChanged,
//     required this.onFullEdit,
//   });
//
//   @override
//   State<_EditableStaffTableRow> createState() =>
//       _EditableStaffTableRowState();
// }
//
// class _EditableStaffTableRowState extends State<_EditableStaffTableRow> {
//   late TextEditingController _nameCtrl;
//   late TextEditingController _phoneCtrl;
//   late TextEditingController _cnicCtrl;
//   late TextEditingController _desigCtrl;
//   late TextEditingController _joiningDateCtrl;
//   late TextEditingController _salaryCtrl;
//   String? _classId;
//   String? _sectionName;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.data.name);
//     _phoneCtrl = TextEditingController(text: widget.data.phone);
//     _cnicCtrl = TextEditingController(text: widget.data.cnic);
//     _desigCtrl =
//         TextEditingController(text: widget.data.designation ?? '');
//     _joiningDateCtrl =
//         TextEditingController(text: widget.data.joiningDate ?? '');
//     _salaryCtrl = TextEditingController(
//         text: widget.data.salary > 0 ? widget.data.salary.toString() : '');
//     _classId = widget.data.classId ??
//         (widget.data.assignedClasses.isNotEmpty
//             ? widget.data.assignedClasses.first
//             : null);
//     _sectionName = widget.data.sectionName ??
//         (widget.data.assignedSections.isNotEmpty
//             ? widget.data.assignedSections.first
//             : null);
//   }
//
//   @override
//   void didUpdateWidget(covariant _EditableStaffTableRow oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.data != widget.data) {
//       if (_nameCtrl.text != widget.data.name) _nameCtrl.text = widget.data.name;
//       if (_phoneCtrl.text != widget.data.phone) {
//         _phoneCtrl.text = widget.data.phone;
//       }
//       if (_cnicCtrl.text != widget.data.cnic) _cnicCtrl.text = widget.data.cnic;
//       final desig = widget.data.designation ?? '';
//       if (_desigCtrl.text != desig) _desigCtrl.text = desig;
//       final jd = widget.data.joiningDate ?? '';
//       if (_joiningDateCtrl.text != jd) _joiningDateCtrl.text = jd;
//       final sal = widget.data.salary > 0 ? widget.data.salary.toString() : '';
//       if (_salaryCtrl.text != sal) _salaryCtrl.text = sal;
//       final newClassId = widget.data.classId ??
//           (widget.data.assignedClasses.isNotEmpty
//               ? widget.data.assignedClasses.first
//               : null);
//       if (newClassId != _classId) {
//         setState(() => _classId = newClassId);
//       }
//       final newSection = widget.data.sectionName ??
//           (widget.data.assignedSections.isNotEmpty
//               ? widget.data.assignedSections.first
//               : null);
//       if (newSection != _sectionName) {
//         setState(() => _sectionName = newSection);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _phoneCtrl.dispose();
//     _cnicCtrl.dispose();
//     _desigCtrl.dispose();
//     _joiningDateCtrl.dispose();
//     _salaryCtrl.dispose();
//     super.dispose();
//   }
//
//   void _emit() {
//     widget.onChanged(widget.data.copyWith(
//       name: _nameCtrl.text,
//       phone: _phoneCtrl.text,
//       cnic: _cnicCtrl.text,
//       designation:
//       _desigCtrl.text.trim().isEmpty ? null : _desigCtrl.text.trim(),
//       classId: _classId,
//       sectionName: _sectionName,
//       joiningDate:
//       _joiningDateCtrl.text.isEmpty ? null : _joiningDateCtrl.text,
//       salary: double.tryParse(_salaryCtrl.text) ?? 0,
//     ));
//   }
//
//   Color get _borderColor {
//     switch (widget.data.status) {
//       case RowStatus.saved:
//         return _kGreen.withOpacity(0.5);
//       case RowStatus.failed:
//         return _kRed.withOpacity(0.5);
//       case RowStatus.saving:
//         return _kPurple.withOpacity(0.4);
//       default:
//         if (widget.data.hasError) return _kRed.withOpacity(0.4);
//         if (widget.selected) return _kPurple.withOpacity(0.5);
//         return _kBorderColor;
//     }
//   }
//
//   Color get _bg {
//     switch (widget.data.status) {
//       case RowStatus.saved:
//         return _kGreenBg.withOpacity(0.4);
//       case RowStatus.failed:
//         return _kRedBg.withOpacity(0.4);
//       case RowStatus.saving:
//         return _kPurpleLight.withOpacity(0.5);
//       default:
//         if (widget.data.hasError) return _kRedBg.withOpacity(0.3);
//         return widget.selected ? _kPurpleLight.withOpacity(0.35) : Colors.white;
//     }
//   }
//
//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final initial = _joiningDateCtrl.text.isNotEmpty
//         ? DateFormat('yyyy-MM-dd').parse(_joiningDateCtrl.text)
//         : now;
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2000),
//       lastDate: now,
//     );
//     if (picked != null) {
//       final formatted = DateFormat('yyyy-MM-dd').format(picked);
//       _joiningDateCtrl.text = formatted;
//       _emit();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isSaving = widget.data.status == RowStatus.saving;
//     final isSaved = widget.data.status == RowStatus.saved;
//     final bool fieldsEnabled = widget.selected && !isSaving && !isSaved;
//
//     Widget statusOrCheckbox() {
//       if (isSaving) {
//         return const SizedBox(
//             width: 16,
//             height: 16,
//             child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple));
//       }
//       return Checkbox(
//         value: widget.selected,
//         onChanged: (_) => widget.onSelectToggle(),
//         activeColor: _kPurple,
//         visualDensity: VisualDensity.compact,
//       );
//     }
//
//     final rowContent = Container(
//       constraints: const BoxConstraints(minHeight: _kRowHeight),
//       decoration: BoxDecoration(
//         color: _bg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _borderColor, width: 1.2),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: _RowScaffold(builder: (isNarrow) {
//         Widget wrapCell(int colIndex, Widget child) {
//           final col = _kColumns[colIndex];
//           if (isNarrow) return SizedBox(width: col.minWidth, child: child);
//           return Expanded(flex: col.flex == 0 ? 1 : col.flex, child: child);
//         }
//
//         final cells = <Widget>[
//           wrapCell(1,
//               _compactTextField(
//                 controller: _nameCtrl,
//                 hint: 'Ahmed Khan',
//                 enabled: fieldsEnabled,
//                 onChanged: (_) {
//                   setState(() {});
//                   _emit();
//                 },
//               )),
//           wrapCell(
//               2,
//               _compactDropdown<String>(
//                 value: widget.data.type,
//                 enabled: fieldsEnabled,
//                 hint: 'Type',
//                 items: const [
//                   DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
//                   DropdownMenuItem(value: 'staff', child: Text('Staff')),
//                 ],
//                 onChanged: (v) =>
//                     widget.onChanged(widget.data.copyWith(type: v!)),
//               )),
//           wrapCell(
//               3,
//               _compactTextField(
//                 controller: _phoneCtrl,
//                 hint: '03XX-XXXXXXX',
//                 keyboard: TextInputType.phone,
//                 enabled: fieldsEnabled,
//                 onChanged: (_) => _emit(),
//               )),
//           wrapCell(
//               4,
//               _compactTextField(
//                 controller: _cnicCtrl,
//                 hint: '34101-1234567-8',
//                 keyboard: TextInputType.number,
//                 inputFormatters: [_CnicFormatter()],
//                 enabled: fieldsEnabled,
//                 onChanged: (_) => _emit(),
//               )),
//           wrapCell(
//               5,
//               _compactTextField(
//                 controller: _desigCtrl,
//                 hint: 'Principal...',
//                 enabled: fieldsEnabled,
//                 onChanged: (_) => _emit(),
//               )),
//           wrapCell(
//               6,
//               _CompactClassField(
//                 classId: _classId,
//                 enabled: fieldsEnabled,
//                 onChanged: (v) {
//                   setState(() {
//                     _classId = v;
//                     _sectionName = null;
//                   });
//                   _emit();
//                 },
//               )),
//           wrapCell(
//               7,
//               _CompactSectionField(
//                 classId: _classId,
//                 sectionName: _sectionName,
//                 enabled: fieldsEnabled,
//                 onChanged: (v) {
//                   setState(() => _sectionName = v);
//                   _emit();
//                 },
//               )),
//           wrapCell(
//               8,
//               _compactDateField(
//                 controller: _joiningDateCtrl,
//                 enabled: fieldsEnabled,
//                 onTap: _pickDate,
//               )),
//           wrapCell(
//               9,
//               _compactTextField(
//                 controller: _salaryCtrl,
//                 hint: '0',
//                 keyboard: TextInputType.number,
//                 enabled: fieldsEnabled,
//                 prefixText: 'Rs ',
//                 onChanged: (_) => _emit(),
//               )),
//           wrapCell(
//               10,
//               Row(mainAxisSize: MainAxisSize.min, children: [
//                 if (isSaved)
//                   const Icon(Icons.check_circle, size: 18, color: _kGreen)
//                 else if (widget.data.hasError)
//                   Tooltip(
//                     message: widget.data.errorMsg,
//                     child: const Icon(Icons.error_outline,
//                         size: 18, color: _kRed),
//                   )
//                 else
//                   IconButton(
//                     icon: Icon(Icons.edit_note,
//                         size: 19,
//                         color: fieldsEnabled
//                             ? _kPurple
//                             : Colors.grey.shade400),
//                     onPressed: fieldsEnabled ? widget.onFullEdit : null,
//                     tooltip: fieldsEnabled
//                         ? 'Full details edit karein'
//                         : 'Pehle is row ko select karein',
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                     visualDensity: VisualDensity.compact,
//                   ),
//               ])),
//         ];
//
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: isNarrow ? _kColumns[0].minWidth : null,
//               child: Center(child: statusOrCheckbox()),
//             ),
//             const SizedBox(width: _kColGap),
//             for (int i = 0; i < cells.length; i++) ...[
//               if (i > 0) const SizedBox(width: _kColGap),
//               cells[i],
//             ],
//           ],
//         );
//       }),
//     );
//
//     // The name/type/contact/etc fields are gated behind IgnorePointer so
//     // taps don't reach them until selected; a tap anywhere else on the row
//     // selects it. The checkbox itself sits outside the IgnorePointer so it
//     // always works (toggles both ways).
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () {
//         if (!widget.selected) widget.onSelectOnly();
//       },
//       child: IgnorePointer(
//         ignoring: !fieldsEnabled && !isSaving,
//         child: Opacity(
//           opacity: widget.selected ? 1.0 : 0.55,
//           child: _CheckboxPassthrough(
//             selected: widget.selected,
//             onSelectToggle: widget.onSelectToggle,
//             child: rowContent,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Ensures the checkbox stays tappable even while the rest of the row body is
// // wrapped in an IgnorePointer (checkbox toggles selection both ways).
// class _CheckboxPassthrough extends StatelessWidget {
//   final bool selected;
//   final VoidCallback onSelectToggle;
//   final Widget child;
//
//   const _CheckboxPassthrough({
//     required this.selected,
//     required this.onSelectToggle,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // The checkbox inside `child` is already outside the ignoring scope
//     // logically since IgnorePointer only disables pointer events for
//     // descendants when `ignoring` is true — but Flutter's IgnorePointer
//     // ignores ALL descendants regardless of position. To keep the checkbox
//     // interactive at all times, we overlay a real (always-hit-testable)
//     // checkbox in a Stack when the row isn't selected.
//     if (selected) return child;
//     return Stack(
//       children: [
//         child,
//         Positioned(
//           left: 4,
//           top: 0,
//           bottom: 0,
//           child: Center(
//             child: Checkbox(
//               value: selected,
//               onChanged: (_) => onSelectToggle(),
//               activeColor: _kPurple,
//               visualDensity: VisualDensity.compact,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/class_model.dart';
import '../../models/teacher.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../services/firestore_service.dart';

// ─── CNIC Formatter ───────────────────────────────────────────────────────────
class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 13 ? digits.substring(0, 13) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 5 || i == 12) buffer.write('-');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ─── Constants ────────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleMid = Color(0xFF6C63D4);
const _kGreen = Color(0xFF15803D);
const _kGreenBg = Color(0xFFDCFCE7);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEE2E2);
const _kOrange = Color(0xFFD97706);
const _kOrangeBg = Color(0xFFFEF3C7);
const _kCardBg = Color(0xFFF7F7FA);
const _kBorderColor = Color(0xFFE7E8F0);

const double _kRowHeight = 64;
const double _kColGap = 10;

// ─── Row data model ──────────────────────────────────────────────────────────
class _RowData {
  final String id;
  String type;
  String name;
  String fatherOrHusbandName;
  String cnic;
  String dob;
  String gender;
  String maritalStatus;
  String? bloodGroup;
  String religion;
  String nationality;
  String address;
  String phone;
  String emergencyPhone;
  String employmentType;
  double salary;
  String? reference;
  String? note;
  String? designation;
  String? joiningDate;
  String? classId;
  String? sectionName;
  List<String> assignedClasses;
  List<String> assignedSections;
  List<String> subjects;
  bool hasError;
  String errorMsg;
  RowStatus status;
  String? existingStaffId;

  _RowData({
    required this.id,
    this.type = 'teacher',
    this.name = '',
    this.fatherOrHusbandName = '',
    this.cnic = '',
    this.dob = '',
    this.gender = 'Male',
    this.maritalStatus = 'Single',
    this.bloodGroup,
    this.religion = '',
    this.nationality = 'Pakistani',
    this.address = '',
    this.phone = '',
    this.emergencyPhone = '',
    this.employmentType = 'Regular',
    this.salary = 0,
    this.reference,
    this.note,
    this.designation,
    this.joiningDate,
    this.classId,
    this.sectionName,
    this.assignedClasses = const [],
    this.assignedSections = const [],
    this.subjects = const [],
    this.hasError = false,
    this.errorMsg = '',
    this.status = RowStatus.idle,
    this.existingStaffId,
  });

  factory _RowData.fromStaffMember(StaffMember s) {
    return _RowData(
      id: s.id ?? UniqueKey().toString(),
      existingStaffId: s.id,
      type: s.type,
      name: s.name,
      fatherOrHusbandName: s.fatherOrHusbandName,
      cnic: s.cnic,
      dob: s.dob,
      gender: s.gender,
      maritalStatus: s.maritalStatus,
      bloodGroup: s.bloodGroup,
      religion: s.religion,
      nationality: s.nationality,
      address: s.address,
      phone: s.phone,
      emergencyPhone: s.emergencyPhone,
      employmentType: s.employmentType,
      salary: s.salary,
      reference: s.reference,
      note: s.note,
      designation: s.designation,
      joiningDate: s.joiningDate,
      classId: s.assignedClasses.isNotEmpty ? s.assignedClasses.first : null,
      sectionName: s.assignedSections.isNotEmpty ? s.assignedSections.first : null,
      assignedClasses: List<String>.from(s.assignedClasses),
      assignedSections: List<String>.from(s.assignedSections ?? []),
      subjects: List<String>.from(s.subjects),
      status: RowStatus.idle,
    );
  }

  _RowData copyWith({
    String? type,
    String? name,
    String? fatherOrHusbandName,
    String? cnic,
    String? dob,
    String? gender,
    String? maritalStatus,
    Object? bloodGroup = _sentinel,
    String? religion,
    String? nationality,
    String? address,
    String? phone,
    String? emergencyPhone,
    String? employmentType,
    double? salary,
    Object? reference = _sentinel,
    Object? note = _sentinel,
    Object? designation = _sentinel,
    Object? joiningDate = _sentinel,
    Object? classId = _sentinel,
    Object? sectionName = _sentinel,
    List<String>? assignedClasses,
    List<String>? assignedSections,
    List<String>? subjects,
    bool? hasError,
    String? errorMsg,
    RowStatus? status,
  }) =>
      _RowData(
        id: id,
        existingStaffId: existingStaffId,
        type: type ?? this.type,
        name: name ?? this.name,
        fatherOrHusbandName: fatherOrHusbandName ?? this.fatherOrHusbandName,
        cnic: cnic ?? this.cnic,
        dob: dob ?? this.dob,
        gender: gender ?? this.gender,
        maritalStatus: maritalStatus ?? this.maritalStatus,
        bloodGroup: bloodGroup == _sentinel ? this.bloodGroup : bloodGroup as String?,
        religion: religion ?? this.religion,
        nationality: nationality ?? this.nationality,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        emergencyPhone: emergencyPhone ?? this.emergencyPhone,
        employmentType: employmentType ?? this.employmentType,
        salary: salary ?? this.salary,
        reference: reference == _sentinel ? this.reference : reference as String?,
        note: note == _sentinel ? this.note : note as String?,
        designation: designation == _sentinel ? this.designation : designation as String?,
        joiningDate: joiningDate == _sentinel ? this.joiningDate : joiningDate as String?,
        classId: classId == _sentinel ? this.classId : classId as String?,
        sectionName: sectionName == _sentinel ? this.sectionName : sectionName as String?,
        assignedClasses: assignedClasses ?? this.assignedClasses,
        assignedSections: assignedSections ?? this.assignedSections,
        subjects: subjects ?? this.subjects,
        hasError: hasError ?? this.hasError,
        errorMsg: errorMsg ?? this.errorMsg,
        status: status ?? this.status,
      );

  bool get isEmpty => name.trim().isEmpty && phone.trim().isEmpty;

  String? validate() {
    if (name.trim().isEmpty) return 'Name required';
    if (phone.trim().isEmpty) return 'Phone required';
    if (classId != null && (sectionName == null || sectionName!.isEmpty)) {
      return 'Section required for selected class';
    }
    return null;
  }

  StaffMember toStaffMember() {
    final effectiveClasses = classId != null ? [classId!] : assignedClasses;
    final effectiveSections = sectionName != null ? [sectionName!] : assignedSections;
    return StaffMember(
      id: existingStaffId,
      type: type,
      name: name.trim(),
      fatherOrHusbandName: fatherOrHusbandName.trim(),
      cnic: cnic.trim(),
      dob: dob,
      gender: gender,
      maritalStatus: maritalStatus,
      bloodGroup: bloodGroup,
      religion: religion.trim(),
      nationality: nationality.trim(),
      address: address.trim(),
      phone: phone.trim(),
      emergencyPhone: emergencyPhone.trim(),
      employmentType: employmentType,
      salary: salary,
      reference: reference?.trim().isEmpty == true ? null : reference?.trim(),
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      designation: designation?.trim().isEmpty == true ? null : designation?.trim(),
      joiningDate: joiningDate?.isEmpty == true ? null : joiningDate,
      assignedClasses: effectiveClasses,
      assignedSections: effectiveSections,
      subjects: subjects,
      imageBase64: null,
    );
  }
}

const _sentinel = Object();

enum RowStatus { idle, saving, saved, failed }

// ─── Column definitions ──────────────────────────────────────────────────────
class _Col {
  final String label;
  final double minWidth;
  final int flex;
  const _Col(this.label, this.minWidth, this.flex);
}

const _kColumns = [
  _Col('#', 30, 0),
  _Col('Name *', 150, 3),
  _Col('Type', 100, 2),
  _Col('Contact *', 130, 2),
  _Col('CNIC', 150, 2),
  _Col('Designation', 140, 2),
  _Col('Class', 130, 2),
  _Col('Section', 110, 2),
  _Col('Joining', 130, 2),
  _Col('Salary', 110, 2),
  _Col('', 76, 0),
];

double get _kTableMinWidth =>
    _kColumns.fold<double>(0, (sum, c) => sum + c.minWidth) +
        _kColGap * (_kColumns.length - 1) +
        20;

// ─── Helper widgets ─────────────────────────────────────────────────────────
Widget _compactTextField({
  required TextEditingController controller,
  String? hint,
  String? prefixText,
  TextInputType? keyboard,
  List<TextInputFormatter>? inputFormatters,
  bool enabled = true,
  ValueChanged<String>? onChanged,
}) {
  return TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboard,
    inputFormatters: inputFormatters,
    onChanged: onChanged,
    style: const TextStyle(fontSize: 12.5),
    decoration: InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      isDense: true,
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kPurple, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade100,
    ),
  );
}

Widget _compactDropdown<T>({
  required T? value,
  required bool enabled,
  required String hint,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    value: value,
    isExpanded: true,
    isDense: true,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kPurple, width: 1.5)),
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade100,
    ),
    style: const TextStyle(fontSize: 12.5, color: Colors.black87),
    items: items,
    onChanged: enabled ? onChanged : null,
  );
}

Widget _compactDateField({
  required TextEditingController controller,
  required bool enabled,
  required VoidCallback onTap,
}) {
  return TextField(
    controller: controller,
    readOnly: true,
    enabled: enabled,
    style: const TextStyle(fontSize: 12.5),
    decoration: InputDecoration(
      hintText: 'YYYY-MM-DD',
      isDense: true,
      suffixIcon: Icon(Icons.calendar_today,
          size: 14, color: enabled ? _kPurple : Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kPurple, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade100,
    ),
    onTap: enabled ? onTap : null,
  );
}

class _CompactClassField extends StatelessWidget {
  final String? classId;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  const _CompactClassField({
    required this.classId,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassProvider>(
      builder: (_, classProv, __) {
        final classes = classProv.classes;
        final validClassId = classes.any((c) => c.id == classId) ? classId : null;
        return _compactDropdown<String>(
          value: validClassId,
          enabled: enabled && classes.isNotEmpty,
          hint: classes.isEmpty ? 'No classes' : 'Class',
          items: classes
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}

class _CompactSectionField extends StatelessWidget {
  final String? classId;
  final String? sectionName;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  const _CompactSectionField({
    required this.classId,
    required this.sectionName,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassProvider>(
      builder: (_, classProv, __) {
        final classes = classProv.classes;
        final validClassId = classes.any((c) => c.id == classId) ? classId : null;
        final selectedClass = validClassId != null
            ? classes.firstWhere((c) => c.id == validClassId)
            : null;
        final sections = selectedClass?.sections ?? [];
        final validSection = sections.any((s) => s.sectionName == sectionName)
            ? sectionName
            : null;

        final dropdown = _compactDropdown<String>(
          value: validSection,
          enabled: enabled && validClassId != null && sections.isNotEmpty,
          hint: validClassId == null
              ? '—'
              : (sections.isEmpty ? 'None' : 'Section'),
          items: sections
              .map((s) => DropdownMenuItem(
              value: s.sectionName, child: Text(s.sectionName)))
              .toList(),
          onChanged: onChanged,
        );

        if (validClassId != null && sections.isEmpty) {
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Expanded(child: dropdown),
            const SizedBox(width: 2),
            Tooltip(
              message: '${selectedClass?.name ?? 'Is class'} mein koi section nahi hai.',
              child: Icon(Icons.warning_amber_rounded,
                  size: 15, color: Colors.orange.shade600),
            ),
          ]);
        }
        if (validClassId != null && validSection == null) {
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Expanded(child: dropdown),
            const SizedBox(width: 2),
            Tooltip(
              message: 'Section select karna zaroori hai',
              child: Icon(Icons.error_outline,
                  size: 15, color: _kRed.withOpacity(0.8)),
            ),
          ]);
        }
        return dropdown;
      },
    );
  }
}

// ─── Table header ──────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final bool showCheckbox;
  const _TableHeader({required this.showCheckbox});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isNarrow = constraints.maxWidth < _kTableMinWidth;
      final content = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(children: [
          if (showCheckbox) const SizedBox(width: 40),
          for (int i = 0; i < _kColumns.length; i++) ...[
            if (i > 0) const SizedBox(width: _kColGap),
            isNarrow
                ? SizedBox(
              width: _kColumns[i].minWidth,
              child: _headerText(_kColumns[i].label),
            )
                : Expanded(
              flex: _kColumns[i].flex == 0 ? 1 : _kColumns[i].flex,
              child: _headerText(_kColumns[i].label),
            ),
          ],
        ]),
      );
      if (isNarrow) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(width: _kTableMinWidth, child: content),
        );
      }
      return content;
    });
  }

  Widget _headerText(String label) => Text(
    label,
    style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600),
  );
}

class _RowScaffold extends StatelessWidget {
  final Widget Function(bool isNarrow) builder;
  const _RowScaffold({required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isNarrow = constraints.maxWidth < _kTableMinWidth;
      final content = builder(isNarrow);
      if (isNarrow) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: _kTableMinWidth, child: content),
        );
      }
      return content;
    });
  }
}

// ─── Bulk Add Screen ─────────────────────────────────────────────────────────
class BulkAddStaffScreen extends StatefulWidget {
  const BulkAddStaffScreen({super.key});

  @override
  State<BulkAddStaffScreen> createState() => _BulkAddStaffScreenState();
}

class _BulkAddStaffScreenState extends State<BulkAddStaffScreen> {
  final List<_RowData> _rows = [];
  bool _isSavingAll = false;
  int _savedCount = 0;
  int _failedCount = 0;
  int _nextId = 1;

  final _typeOptions = ['teacher', 'staff', 'academy_staff'];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) _addRow();
  }

  void _addRow({int count = 1}) {
    setState(() {
      for (int i = 0; i < count; i++) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _rows.add(_RowData(id: '${_nextId++}', joiningDate: today));
      }
    });
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() => _rows.removeAt(index));
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Clear All Rows?',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('All unsaved data will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _kRed, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _rows.clear();
                _savedCount = 0;
                _failedCount = 0;
                _addRow(count: 3);
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _updateRow(int index, _RowData updated) {
    setState(() => _rows[index] = updated);
  }

  List<_RowData> get _filledRows => _rows.where((r) => !r.isEmpty).toList();

  Future<void> _saveAll() async {
    bool anyError = false;
    setState(() {
      for (int i = 0; i < _rows.length; i++) {
        if (_rows[i].isEmpty) continue;
        final err = _rows[i].validate();
        if (err != null) {
          _rows[i] = _rows[i].copyWith(hasError: true, errorMsg: err);
          anyError = true;
        } else {
          _rows[i] = _rows[i].copyWith(hasError: false, errorMsg: '');
        }
      }
    });

    if (anyError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fix errors before saving.'),
            backgroundColor: _kRed),
      );
      return;
    }

    final toSave = _filledRows;
    if (toSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No data to save. Fill at least one row.'),
            backgroundColor: _kOrange),
      );
      return;
    }

    setState(() {
      _isSavingAll = true;
      _savedCount = 0;
      _failedCount = 0;
      for (int i = 0; i < _rows.length; i++) {
        if (!_rows[i].isEmpty) {
          _rows[i] = _rows[i].copyWith(status: RowStatus.saving);
        }
      }
    });

    final provider = context.read<StaffProvider>();

    for (int i = 0; i < _rows.length; i++) {
      if (_rows[i].isEmpty || _rows[i].status == RowStatus.saved) continue;
      try {
        await provider.addStaff(_rows[i].toStaffMember());
        if (mounted) {
          setState(() {
            _rows[i] = _rows[i].copyWith(status: RowStatus.saved, hasError: false);
            _savedCount++;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _rows[i] = _rows[i].copyWith(
              status: RowStatus.failed,
              hasError: true,
              errorMsg: 'Save failed: $e',
            );
            _failedCount++;
          });
        }
      }
    }

    if (mounted) {
      setState(() => _isSavingAll = false);

      if (_failedCount == 0 && _savedCount > 0) {
        provider.fetchTeachers();
        provider.fetchStaffOnly();
        provider.fetchAcademyStaff();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_savedCount record(s) saved successfully!'),
            backgroundColor: _kGreen,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$_savedCount saved${_failedCount > 0 ? ', $_failedCount failed' : ''}'),
            backgroundColor: _failedCount > 0 ? _kOrange : _kGreen,
          ),
        );
        if (_failedCount == 0) {
          provider.fetchTeachers();
          provider.fetchStaffOnly();
          provider.fetchAcademyStaff();
        }
      }
    }
  }

  void _openFullEdit(int index) {
    final data = _rows[index];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _FullEditDialog(
        data: data,
        onSave: (updated) {
          _updateRow(index, updated);
          Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bulk Add Staff / Teachers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(
              '${_filledRows.length} filled · ${_filledRows.where((r) => r.validate() == null).length} ready',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        actions: [
          TextButton.icon(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all, size: 16, color: _kRed),
            label: const Text('Clear',
                style: TextStyle(color: _kRed, fontSize: 13)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(children: [
        Container(
          color: _kPurpleLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 15, color: _kPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Quick info yahan fill karein. Class select karne par uski Section bhi select karein. Full details k liye ✏️ edit icon click karein.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ]),
        ),
        if (_savedCount > 0 || _failedCount > 0)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(spacing: 8, children: [
              if (_savedCount > 0)
                _pill('$_savedCount saved', _kGreen, _kGreenBg),
              if (_failedCount > 0)
                _pill('$_failedCount failed', _kRed, _kRedBg),
            ]),
          ),
        _TableHeader(showCheckbox: false),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 100),
            itemCount: _rows.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StaffTableRow(
                key: ValueKey(_rows[i].id),
                data: _rows[i],
                index: i,
                total: _rows.length,
                typeOptions: _typeOptions,
                onChanged: (updated) => _updateRow(i, updated),
                onRemove: () => _removeRow(i),
                onFullEdit: () => _openFullEdit(i),
              ),
            ),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -3)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            Expanded(
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                _addBtn('+1', () => _addRow()),
                _addBtn('+3', () => _addRow(count: 3)),
                _addBtn('+5', () => _addRow(count: 5)),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSavingAll ? null : _saveAll,
                icon: _isSavingAll
                    ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cloud_upload_outlined, size: 17),
                label: Text(_isSavingAll ? 'Saving...' : 'Save All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _addBtn(String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        border: Border.all(color: _kPurple.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
        color: _kPurpleLight,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.add, size: 14, color: _kPurple),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: _kPurple,
                fontWeight: FontWeight.w700)),
      ]),
    ),
  );

  Widget _pill(String label, Color text, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontSize: 11, color: text, fontWeight: FontWeight.w600)),
  );
}

// ─── Bulk Add Table Row ─────────────────────────────────────────────────────
class _StaffTableRow extends StatefulWidget {
  final _RowData data;
  final int index;
  final int total;
  final List<String> typeOptions;
  final ValueChanged<_RowData> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onFullEdit;

  const _StaffTableRow({
    super.key,
    required this.data,
    required this.index,
    required this.total,
    required this.typeOptions,
    required this.onChanged,
    required this.onRemove,
    required this.onFullEdit,
  });

  @override
  State<_StaffTableRow> createState() => _StaffTableRowState();
}

class _StaffTableRowState extends State<_StaffTableRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _desigCtrl;
  late TextEditingController _joiningDateCtrl;
  late TextEditingController _salaryCtrl;
  String? _classId;
  String? _sectionName;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.name);
    _phoneCtrl = TextEditingController(text: widget.data.phone);
    _cnicCtrl = TextEditingController(text: widget.data.cnic);
    _desigCtrl = TextEditingController(text: widget.data.designation ?? '');
    _joiningDateCtrl = TextEditingController(text: widget.data.joiningDate ?? '');
    _salaryCtrl = TextEditingController(
        text: widget.data.salary > 0 ? widget.data.salary.toString() : '');
    _classId = widget.data.classId ??
        (widget.data.assignedClasses.isNotEmpty
            ? widget.data.assignedClasses.first
            : null);
    _sectionName = widget.data.sectionName ??
        (widget.data.assignedSections.isNotEmpty
            ? widget.data.assignedSections.first
            : null);
  }

  @override
  void didUpdateWidget(covariant _StaffTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      if (_nameCtrl.text != widget.data.name) _nameCtrl.text = widget.data.name;
      if (_phoneCtrl.text != widget.data.phone) _phoneCtrl.text = widget.data.phone;
      if (_cnicCtrl.text != widget.data.cnic) _cnicCtrl.text = widget.data.cnic;
      final desig = widget.data.designation ?? '';
      if (_desigCtrl.text != desig) _desigCtrl.text = desig;
      final jd = widget.data.joiningDate ?? '';
      if (_joiningDateCtrl.text != jd) _joiningDateCtrl.text = jd;
      final sal = widget.data.salary > 0 ? widget.data.salary.toString() : '';
      if (_salaryCtrl.text != sal) _salaryCtrl.text = sal;
      final newClassId = widget.data.classId ??
          (widget.data.assignedClasses.isNotEmpty
              ? widget.data.assignedClasses.first
              : null);
      if (newClassId != _classId) _classId = newClassId;
      final newSection = widget.data.sectionName ??
          (widget.data.assignedSections.isNotEmpty
              ? widget.data.assignedSections.first
              : null);
      if (newSection != _sectionName) _sectionName = newSection;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _desigCtrl.dispose();
    _joiningDateCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      cnic: _cnicCtrl.text,
      designation: _desigCtrl.text.trim().isEmpty ? null : _desigCtrl.text.trim(),
      classId: _classId,
      sectionName: _sectionName,
      joiningDate: _joiningDateCtrl.text.isEmpty ? null : _joiningDateCtrl.text,
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
    ));
  }

  Color get _borderColor {
    switch (widget.data.status) {
      case RowStatus.saved:
        return _kGreen.withOpacity(0.5);
      case RowStatus.failed:
        return _kRed.withOpacity(0.5);
      case RowStatus.saving:
        return _kPurple.withOpacity(0.4);
      default:
        return widget.data.hasError
            ? _kRed.withOpacity(0.4)
            : _kBorderColor;
    }
  }

  Color get _bg {
    switch (widget.data.status) {
      case RowStatus.saved:
        return _kGreenBg.withOpacity(0.4);
      case RowStatus.failed:
        return _kRedBg.withOpacity(0.4);
      case RowStatus.saving:
        return _kPurpleLight.withOpacity(0.5);
      default:
        return widget.data.hasError ? _kRedBg.withOpacity(0.3) : Colors.white;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _joiningDateCtrl.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_joiningDateCtrl.text)
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      _joiningDateCtrl.text = formatted;
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = widget.data.status == RowStatus.saved;
    final isSaving = widget.data.status == RowStatus.saving;
    final enabled = !isSaved;

    Widget statusIcon() {
      if (isSaving) {
        return const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple));
      }
      if (isSaved) return const Icon(Icons.check_circle, size: 18, color: _kGreen);
      if (widget.data.hasError) {
        return Tooltip(
          message: widget.data.errorMsg,
          child: const Icon(Icons.error_outline, size: 18, color: _kRed),
        );
      }
      return Text('${widget.index + 1}',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: _kPurple));
    }

    return Container(
      constraints: const BoxConstraints(minHeight: _kRowHeight),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: _RowScaffold(builder: (isNarrow) {
        final cells = <Widget>[
          _cell(isNarrow, 0, Center(child: statusIcon())),
          _cell(
              isNarrow,
              1,
              _compactTextField(
                controller: _nameCtrl,
                hint: 'Ahmed Khan',
                enabled: enabled,
                onChanged: (_) {
                  setState(() {});
                  _emit();
                },
              )),
          _cell(
              isNarrow,
              2,
              _compactDropdown<String>(
                value: widget.data.type,
                enabled: enabled,
                hint: 'Type',
                items: widget.typeOptions.map((t) {
                  String label;
                  if (t == 'teacher') label = 'Teacher';
                  else if (t == 'academy_staff') label = 'Academy';
                  else label = 'Staff';
                  return DropdownMenuItem(value: t, child: Text(label));
                }).toList(),
                onChanged: (v) => widget.onChanged(widget.data.copyWith(type: v!)),
              )),
          _cell(
              isNarrow,
              3,
              _compactTextField(
                controller: _phoneCtrl,
                hint: '03XX-XXXXXXX',
                keyboard: TextInputType.phone,
                enabled: enabled,
                onChanged: (_) => _emit(),
              )),
          _cell(
              isNarrow,
              4,
              _compactTextField(
                controller: _cnicCtrl,
                hint: '34101-1234567-8',
                keyboard: TextInputType.number,
                inputFormatters: [_CnicFormatter()],
                enabled: enabled,
                onChanged: (_) => _emit(),
              )),
          _cell(
              isNarrow,
              5,
              _compactTextField(
                controller: _desigCtrl,
                hint: 'Principal...',
                enabled: enabled,
                onChanged: (_) => _emit(),
              )),
          _cell(
              isNarrow,
              6,
              _CompactClassField(
                classId: _classId,
                enabled: enabled,
                onChanged: (v) {
                  setState(() {
                    _classId = v;
                    _sectionName = null;
                  });
                  _emit();
                },
              )),
          _cell(
              isNarrow,
              7,
              _CompactSectionField(
                classId: _classId,
                sectionName: _sectionName,
                enabled: enabled,
                onChanged: (v) {
                  setState(() => _sectionName = v);
                  _emit();
                },
              )),
          _cell(
              isNarrow,
              8,
              _compactDateField(
                controller: _joiningDateCtrl,
                enabled: enabled,
                onTap: _pickDate,
              )),
          _cell(
              isNarrow,
              9,
              _compactTextField(
                controller: _salaryCtrl,
                hint: '0',
                keyboard: TextInputType.number,
                enabled: enabled,
                prefixText: 'Rs ',
                onChanged: (_) => _emit(),
              )),
          _cell(
              isNarrow,
              10,
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (enabled) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 19, color: _kPurple),
                    onPressed: widget.onFullEdit,
                    tooltip: 'Full details edit karein',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 19,
                        color: widget.total <= 1
                            ? Colors.grey.shade300
                            : Colors.red.shade300),
                    onPressed: widget.total <= 1 ? null : widget.onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ])),
        ];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < cells.length; i++) ...[
              if (i > 0) const SizedBox(width: _kColGap),
              cells[i],
            ],
          ],
        );
      }),
    );
  }

  Widget _cell(bool isNarrow, int colIndex, Widget child) {
    final col = _kColumns[colIndex];
    if (isNarrow) {
      return SizedBox(width: col.minWidth, child: child);
    }
    return Expanded(flex: col.flex == 0 ? 1 : col.flex, child: child);
  }
}

// ─── Full Edit Dialog ──────────────────────────────────────────────────────
class _FullEditDialog extends StatefulWidget {
  final _RowData data;
  final void Function(_RowData) onSave;
  final VoidCallback onCancel;
  const _FullEditDialog({
    required this.data,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_FullEditDialog> createState() => _FullEditDialogState();
}

class _FullEditDialogState extends State<_FullEditDialog> {
  late _RowData _editedData;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _fatherCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _religionCtrl;
  late TextEditingController _nationalityCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emergencyCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _referenceCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _designationCtrl;

  String _dob = '';
  String _joiningDate = '';
  List<String> _assignedClasses = [];
  List<String> _assignedSections = [];
  List<String> _subjects = [];
  String _type = 'teacher';
  String _gender = 'Male';
  String _maritalStatus = 'Single';
  String? _bloodGroup;
  String _employmentType = 'Regular';

  final _typeOptions = ['teacher', 'staff', 'academy_staff'];
  final _genderOptions = ['Male', 'Female', 'Other'];
  final _maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  final _bloodOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final _employmentOptions = ['Contract', 'Regular', 'Daily'];

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _editedData = d;
    _nameCtrl = TextEditingController(text: d.name);
    _fatherCtrl = TextEditingController(text: d.fatherOrHusbandName);
    _cnicCtrl = TextEditingController(text: d.cnic);
    _religionCtrl = TextEditingController(text: d.religion);
    _nationalityCtrl = TextEditingController(text: d.nationality);
    _addressCtrl = TextEditingController(text: d.address);
    _phoneCtrl = TextEditingController(text: d.phone);
    _emergencyCtrl = TextEditingController(text: d.emergencyPhone);
    _salaryCtrl = TextEditingController(text: d.salary > 0 ? d.salary.toString() : '');
    _referenceCtrl = TextEditingController(text: d.reference ?? '');
    _noteCtrl = TextEditingController(text: d.note ?? '');
    _designationCtrl = TextEditingController(text: d.designation ?? '');

    _type = d.type;
    _gender = d.gender;
    _maritalStatus = d.maritalStatus;
    _bloodGroup = d.bloodGroup;
    _employmentType = d.employmentType;
    _dob = d.dob;
    _joiningDate = d.joiningDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _assignedClasses = List.from(d.assignedClasses);
    _assignedSections = List.from(d.assignedSections);
    _subjects = List.from(d.subjects);

    if (_assignedClasses.isEmpty && d.classId != null) {
      _assignedClasses = [d.classId!];
    }
    if (_assignedSections.isEmpty && d.sectionName != null) {
      _assignedSections = [d.sectionName!];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fatherCtrl.dispose();
    _cnicCtrl.dispose();
    _religionCtrl.dispose();
    _nationalityCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emergencyCtrl.dispose();
    _salaryCtrl.dispose();
    _referenceCtrl.dispose();
    _noteCtrl.dispose();
    _designationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initialDate = _dob.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_dob)
        : DateTime(now.year - 25, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _pickJoiningDate() async {
    final now = DateTime.now();
    final initialDate = _joiningDate.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_joiningDate)
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _joiningDate = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_assignedClasses.isNotEmpty) {
      final classProvider = context.read<ClassProvider>();
      for (final classId in _assignedClasses) {
        final cls = classProvider.classes
            .where((c) => c.id == classId)
            .cast<SchoolClass?>()
            .firstWhere((c) => c != null, orElse: () => null);
        final sectionNames = (cls?.sections ?? []).map((s) => s.sectionName).toSet();
        final hasMatchingSection =
        _assignedSections.any((s) => sectionNames.contains(s));
        if (sectionNames.isNotEmpty && !hasMatchingSection) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${cls?.name ?? 'Selected class'} ke liye ek section select karein.'),
            backgroundColor: _kRed,
          ));
          return;
        }
      }
    }

    final String? effectiveClassId =
    _assignedClasses.isEmpty ? null : _assignedClasses.first;
    final String? effectiveSectionName =
    _assignedSections.isEmpty ? null : _assignedSections.first;

    final updated = _editedData.copyWith(
      type: _type,
      name: _nameCtrl.text.trim(),
      fatherOrHusbandName: _fatherCtrl.text.trim(),
      cnic: _cnicCtrl.text.trim(),
      dob: _dob,
      gender: _gender,
      maritalStatus: _maritalStatus,
      bloodGroup: _bloodGroup,
      religion: _religionCtrl.text.trim(),
      nationality: _nationalityCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      emergencyPhone: _emergencyCtrl.text.trim(),
      employmentType: _employmentType,
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
      reference: _referenceCtrl.text.trim().isEmpty ? null : _referenceCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      designation: _designationCtrl.text.trim().isEmpty ? null : _designationCtrl.text.trim(),
      joiningDate: _joiningDate.isEmpty ? null : _joiningDate,
      classId: effectiveClassId,
      sectionName: effectiveSectionName,
      assignedClasses: _assignedClasses,
      assignedSections: _assignedSections,
      subjects: _subjects,
      hasError: false,
      errorMsg: '',
    );
    widget.onSave(updated);
  }

  Widget _buildClassSectionSelector() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, _) {
        final classes = classProvider.classes;
        if (classes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 15, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pehle classes add karein.',
                    style: TextStyle(fontSize: 12, color: Colors.amber),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: classes.map((cls) {
                final isSelected = _assignedClasses.contains(cls.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _assignedClasses.remove(cls.id);
                        final sectionNames = (cls.sections)
                            .map((s) => s.sectionName)
                            .toSet();
                        _assignedSections.removeWhere(
                                (sec) => sectionNames.contains(sec));
                      } else {
                        _assignedClasses.add(cls.id!);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? _kPurple : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? _kPurple : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          cls.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_assignedClasses.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Sections select karein: *',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kPurple),
              ),
              const SizedBox(height: 8),
              ..._assignedClasses.map((classId) {
                final cls = classes.firstWhere((c) => c.id == classId);
                final sections = cls.sections;
                if (sections.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Row(children: [
                      Icon(Icons.info_outline,
                          size: 14,
                          color: Colors.orange.shade400),
                      const SizedBox(width: 6),
                      Text(
                        '${cls.name} mein koi section nahi hai',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700),
                      ),
                    ]),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cls.name,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: sections.map((section) {
                          final sectionName = section.sectionName;
                          final isSelected =
                          _assignedSections.contains(sectionName);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _assignedSections.remove(sectionName);
                                } else {
                                  _assignedSections.add(sectionName);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kPurple
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? _kPurple
                                      : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(Icons.check,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    sectionName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSubjectSelector() {
    return Consumer<MuddulProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(
              child: CircularProgressIndicator(strokeWidth: 2));
        }
        final allSubjects =
        provider.mudduls.map((m) => m.subjectName).toSet().toList()
          ..sort();
        if (allSubjects.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(children: [
              Icon(Icons.info_outline,
                  size: 16, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Koi subject nahi mila. Pehle subjects add karein.',
                  style: TextStyle(fontSize: 12, color: Colors.amber),
                ),
              ),
            ]),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 6,
          children: allSubjects.map((subject) {
            final isSelected = _subjects.contains(subject);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _subjects.remove(subject);
                  } else {
                    _subjects.add(subject);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? _kPurple : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _kPurple : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 12,
        vertical: 24,
      ),
      child: Container(
        width: isWide ? 700 : double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kPurple, _kPurpleMid],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.person_add_alt_1_outlined,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameCtrl.text.trim().isEmpty
                            ? 'Full Details'
                            : _nameCtrl.text.trim(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        _type == 'teacher'
                            ? 'Teacher'
                            : (_type == 'academy_staff' ? 'Academy Staff' : 'Staff Member'),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: widget.onCancel,
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: isWide ? _buildDesktopForm() : _buildMobileForm(),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _kPurple),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: _kPurple)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Save Row'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dialogSection('Role', Icons.manage_accounts_outlined, [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _typeOptions.map((t) {
              final sel = _type == t;
              String label;
              if (t == 'teacher') label = 'Teacher';
              else if (t == 'academy_staff') label = 'Academy Staff';
              else label = 'School Staff';
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: sel ? _kPurple : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? _kPurple : Colors.grey.shade300),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ]),
        _dialogSection(
            'Personal Information', Icons.person_outline, [
          _row2([
            _df('Full Name *', _nameCtrl,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                onChanged: (_) => setState(() {})),
            _df('Designation', _designationCtrl,
                hint: 'e.g. Principal, Head Teacher...',
                onChanged: (_) => setState(() {})),
          ]),
          _row2([
            _df(
              _maritalStatus == 'Married' ? 'Husband Name *' : 'Father Name *',
              _fatherCtrl,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            _cnicField(),
          ]),
          _row2([
            _dateField('Date of Birth', _dob, _pickDob,
                validator: (_) => _dob.isEmpty ? 'Required' : null),
            _dateField('Joining Date', _joiningDate, _pickJoiningDate),
          ]),
          _row2([
            _dropdownField('Gender', _gender, _genderOptions,
                    (v) => setState(() => _gender = v!)),
            _dropdownField('Marital Status', _maritalStatus,
                _maritalOptions,
                    (v) => setState(() => _maritalStatus = v!)),
          ]),
          _row2([
            _dropdownField('Blood Group (Optional)', _bloodGroup,
                _bloodOptions,
                    (v) => setState(() => _bloodGroup = v),
                nullable: true),
            _df('Religion *', _religionCtrl,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
          ]),
          _df('Nationality *', _nationalityCtrl,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null),
        ]),
        _dialogSection(
            'Contact Information', Icons.contact_phone_outlined, [
          _df('Address *', _addressCtrl,
              maxLines: 2,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null),
          _row2([
            _df('Phone No *', _phoneCtrl,
                keyboard: TextInputType.phone,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
            _df('Emergency No *', _emergencyCtrl,
                keyboard: TextInputType.phone,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
          ]),
        ]),
        _dialogSection('Job Details', Icons.work_outline, [
          _row2([
            _dropdownField('Employment Type', _employmentType,
                _employmentOptions,
                    (v) => setState(() => _employmentType = v!)),
            _salaryField(),
          ]),
        ]),
        _dialogSection(
            'Assigned Class & Section', Icons.class_outlined, [
          _buildClassSectionSelector(),
        ]),
        _dialogSection(
            'Assigned Subjects', Icons.menu_book_outlined, [
          _buildSubjectSelector(),
        ]),
        _dialogSection(
            'Additional Info (Optional)', Icons.info_outline, [
          _row2([
            _df('Reference', _referenceCtrl),
            _df('Note', _noteCtrl, maxLines: 3),
          ]),
        ]),
      ],
    );
  }

  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dialogSection('Role', Icons.manage_accounts_outlined, [
          Wrap(
            spacing: 8,
            children: _typeOptions.map((t) {
              final sel = _type == t;
              String label;
              if (t == 'teacher') label = 'Teacher';
              else if (t == 'academy_staff') label = 'Academy Staff';
              else label = 'School Staff';
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _kPurple : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? _kPurple : Colors.grey.shade300),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ]),
        _dialogSection(
            'Personal Information', Icons.person_outline, [
          _df('Full Name *', _nameCtrl,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              onChanged: (_) => setState(() {})),
          _df('Designation', _designationCtrl,
              hint: 'e.g. Principal, Head Teacher...',
              onChanged: (_) => setState(() {})),
          _df(
            _maritalStatus == 'Married' ? 'Husband Name *' : 'Father Name *',
            _fatherCtrl,
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
          ),
          _cnicField(),
          _dateField('Date of Birth', _dob, _pickDob,
              validator: (_) => _dob.isEmpty ? 'Required' : null),
          _dateField('Joining Date', _joiningDate, _pickJoiningDate),
          _dropdownField('Gender', _gender, _genderOptions,
                  (v) => setState(() => _gender = v!)),
          _dropdownField('Marital Status', _maritalStatus,
              _maritalOptions,
                  (v) => setState(() => _maritalStatus = v!)),
          _dropdownField('Blood Group (Optional)', _bloodGroup,
              _bloodOptions,
                  (v) => setState(() => _bloodGroup = v),
              nullable: true),
          _df('Religion *', _religionCtrl,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null),
          _df('Nationality *', _nationalityCtrl,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null),
        ]),
        _dialogSection(
            'Contact Information', Icons.contact_phone_outlined, [
          _df('Address *', _addressCtrl,
              maxLines: 2,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null),
          _df('Phone No *', _phoneCtrl,
              keyboard: TextInputType.phone,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null),
          _df('Emergency No *', _emergencyCtrl,
              keyboard: TextInputType.phone,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null),
        ]),
        _dialogSection('Job Details', Icons.work_outline, [
          _dropdownField('Employment Type', _employmentType,
              _employmentOptions,
                  (v) => setState(() => _employmentType = v!)),
          _salaryField(),
        ]),
        _dialogSection(
            'Assigned Class & Section', Icons.class_outlined, [
          _buildClassSectionSelector(),
        ]),
        _dialogSection(
            'Assigned Subjects', Icons.menu_book_outlined, [
          _buildSubjectSelector(),
        ]),
        _dialogSection(
            'Additional Info (Optional)', Icons.info_outline, [
          _df('Reference', _referenceCtrl),
          _df('Note', _noteCtrl, maxLines: 3),
        ]),
      ],
    );
  }

  Widget _dialogSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEFF3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: _kPurpleLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: _kPurple),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kPurple)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _spaced(children, 10),
          ),
        ),
      ]),
    );
  }

  Widget _row2(List<Widget> children) {
    return Row(
      children: children
          .map((w) => Expanded(child: w))
          .expand((w) => [w, const SizedBox(width: 10)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _df(
      String label,
      TextEditingController ctrl, {
        String? hint,
        int maxLines = 1,
        TextInputType? keyboard,
        String? Function(String?)? validator,
        ValueChanged<String>? onChanged,
      }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: _deco(label, hint: hint),
      validator: validator,
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _cnicField() {
    return TextFormField(
      controller: _cnicCtrl,
      keyboardType: TextInputType.number,
      maxLength: 15,
      inputFormatters: [_CnicFormatter()],
      decoration: _deco('CNIC (34101-1234567-8)').copyWith(counterText: ''),
      style: const TextStyle(fontSize: 13),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
        if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
        return null;
      },
    );
  }

  Widget _salaryField() {
    return TextFormField(
      controller: _salaryCtrl,
      decoration: _deco('Salary *').copyWith(prefixText: 'Rs  '),
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 13),
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _dateField(
      String label,
      String value,
      VoidCallback onTap, {
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: _deco(label).copyWith(
        suffixIcon: const Icon(Icons.calendar_today,
            size: 16, color: _kPurple),
      ),
      style: const TextStyle(fontSize: 13),
      onTap: onTap,
      validator: validator,
    );
  }

  Widget _dropdownField<T>(
      String label,
      T value,
      List<String> items,
      ValueChanged<T?> onChanged, {
        bool nullable = false,
      }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _deco(label),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      items: [
        if (nullable)
          const DropdownMenuItem(
              value: null,
              child: Text('Select (Optional)')) as DropdownMenuItem<T>,
        ...items.map(
                (i) => DropdownMenuItem<T>(value: i as T, child: Text(i))),
      ],
      onChanged: onChanged,
    );
  }

  InputDecoration _deco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kPurple, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  List<Widget> _spaced(List<Widget> children, double gap) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) result.add(SizedBox(height: gap));
    }
    return result;
  }
}

// ─── Bulk Edit Screen ────────────────────────────────────────────────────────
class BulkEditStaffScreen extends StatefulWidget {
  final String? initialTypeFilter;
  const BulkEditStaffScreen({super.key, this.initialTypeFilter});

  @override
  State<BulkEditStaffScreen> createState() => _BulkEditStaffScreenState();
}

class _BulkEditStaffScreenState extends State<BulkEditStaffScreen> {
  final Map<String, _RowData> _rows = {};
  final Set<String> _selectedIds = {};

  String _typeFilter = 'all';
  String? _classFilter;
  String? _sectionFilter;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  bool _isSavingAll = false;
  bool _hydrated = false;
  int _savedCount = 0;
  int _failedCount = 0;

  @override
  void initState() {
    super.initState();
    _typeFilter = widget.initialTypeFilter ?? 'all';
    _searchCtrl.addListener(
            () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
    Future.microtask(() async {
      final provider = context.read<StaffProvider>();
      await Future.wait([
        provider.fetchTeachers(),
        provider.fetchStaffOnly(),
        provider.fetchAcademyStaff(),
      ]);
      _hydrateRows();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _hydrateRows() {
    final provider = context.read<StaffProvider>();
    final all = [...provider.teachers, ...provider.staffOnly, ...provider.academyStaff];
    setState(() {
      _rows.clear();
      for (final s in all) {
        if (s.id == null) continue;
        _rows[s.id!] = _RowData.fromStaffMember(s);
      }
      _hydrated = true;
    });
  }

  List<_RowData> get _visibleRows {
    var list = _rows.values.toList();

    if (_typeFilter != 'all') {
      list = list.where((r) => r.type == _typeFilter).toList();
    }
    if (_classFilter != null) {
      list = list.where((r) {
        final classes = r.classId != null ? [r.classId!] : r.assignedClasses;
        return classes.contains(_classFilter);
      }).toList();
    }
    if (_sectionFilter != null) {
      list = list
          .where((r) => r.assignedSections.contains(_sectionFilter))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) {
        return r.name.toLowerCase().contains(_searchQuery) ||
            r.phone.toLowerCase().contains(_searchQuery) ||
            (r.designation ?? '').toLowerCase().contains(_searchQuery);
      }).toList();
    }
    return list;
  }

  void _updateRow(String rowId, _RowData updated) {
    setState(() => _rows[rowId] = updated);
  }

  void _toggleSelect(String rowId) {
    setState(() {
      if (_selectedIds.contains(rowId)) {
        _selectedIds.remove(rowId);
      } else {
        _selectedIds.add(rowId);
      }
    });
  }

  void _selectRow(String rowId) {
    if (_selectedIds.contains(rowId)) return;
    setState(() => _selectedIds.add(rowId));
  }

  void _selectAllVisible() {
    final visible = _visibleRows.map((r) => r.id).toList();
    setState(() {
      final allSelected = visible.isNotEmpty && visible.every(_selectedIds.contains);
      if (allSelected) {
        _selectedIds.removeAll(visible);
      } else {
        _selectedIds.addAll(visible);
      }
    });
  }

  void _openFullEdit(_RowData data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _FullEditDialog(
        data: data,
        onSave: (updated) {
          _updateRow(data.id, updated);
          Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<void> _saveSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Pehle kam az kam ek row select karein (checkbox ya row par tap karein).'),
            backgroundColor: _kOrange),
      );
      return;
    }

    bool anyError = false;
    setState(() {
      for (final id in _selectedIds) {
        final row = _rows[id]!;
        final err = row.validate();
        if (err != null) {
          _rows[id] = row.copyWith(hasError: true, errorMsg: err);
          anyError = true;
        } else {
          _rows[id] = row.copyWith(hasError: false, errorMsg: '');
        }
      }
    });

    if (anyError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fix errors before saving.'),
            backgroundColor: _kRed),
      );
      return;
    }

    setState(() {
      _isSavingAll = true;
      _savedCount = 0;
      _failedCount = 0;
      for (final id in _selectedIds) {
        _rows[id] = _rows[id]!.copyWith(status: RowStatus.saving);
      }
    });

    final provider = context.read<StaffProvider>();

    for (final id in _selectedIds.toList()) {
      final row = _rows[id]!;
      try {
        await provider.updateStaff(row.existingStaffId ?? id, row.toStaffMember());
        if (mounted) {
          setState(() {
            _rows[id] = row.copyWith(status: RowStatus.saved, hasError: false);
            _savedCount++;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _rows[id] = row.copyWith(
              status: RowStatus.failed,
              hasError: true,
              errorMsg: 'Update failed: $e',
            );
            _failedCount++;
          });
        }
      }
    }

    if (mounted) {
      setState(() => _isSavingAll = false);
      provider.fetchTeachers();
      provider.fetchStaffOnly();
      provider.fetchAcademyStaff();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '$_savedCount updated${_failedCount > 0 ? ', $_failedCount failed' : ''}'),
          backgroundColor: _failedCount > 0 ? _kOrange : _kGreen,
        ),
      );

      if (_failedCount == 0) {
        setState(() => _selectedIds.clear());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final staffProviderLoading = context.watch<StaffProvider>().loading;
    final visible = _visibleRows;
    final allVisibleSelected =
        visible.isNotEmpty && visible.every((r) => _selectedIds.contains(r.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bulk Edit Staff / Teachers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(
              '${_selectedIds.length} selected · ${visible.length} visible',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      ),
      body: Column(children: [
        Container(
          color: _kPurpleLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 15, color: _kPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Row select karein (☑️ checkbox ya row par tap) — sirf selected rows hi editable hongi.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ]),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Checkbox(
                  value: allVisibleSelected,
                  onChanged: (_) => _selectAllVisible(),
                  activeColor: _kPurple,
                ),
                Text('Select all visible',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
              ]),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _filterChip('All', 'all'),
                  _filterChip('Teachers', 'teacher'),
                  _filterChip('Staff', 'staff'),
                  _filterChip('Academy', 'academy_staff'),
                  Container(
                      width: 1,
                      height: 22,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 4)),
                  _classFilterDropdown(classProvider),
                  _sectionFilterDropdown(classProvider),
                  if (_classFilter != null || _sectionFilter != null)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _classFilter = null;
                        _sectionFilter = null;
                      }),
                      icon: const Icon(Icons.filter_alt_off_outlined,
                          size: 15, color: _kRed),
                      label: const Text('Clear filters',
                          style: TextStyle(fontSize: 12, color: _kRed)),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, designation…',
                    hintStyle: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search,
                        size: 17, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kPurple)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FC),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (_selectedIds.isNotEmpty)
          Container(
            color: _kPurpleLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Icon(Icons.lock_open_rounded, size: 16, color: _kPurple),
              const SizedBox(width: 8),
              Text('${_selectedIds.length} selected · editable now',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kPurple)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedIds.clear()),
                child: const Text('Deselect all',
                    style: TextStyle(fontSize: 12, color: _kPurple)),
              ),
            ]),
          ),
        _TableHeader(showCheckbox: true),
        Expanded(
          child: (staffProviderLoading && !_hydrated)
              ? const Center(
              child: CircularProgressIndicator(color: _kPurple))
              : visible.isEmpty
              ? _buildEmpty()
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 90),
            itemCount: visible.length,
            itemBuilder: (ctx, i) {
              final row = visible[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _EditableStaffTableRow(
                  key: ValueKey(row.id),
                  data: row,
                  selected: _selectedIds.contains(row.id),
                  onSelectToggle: () => _toggleSelect(row.id),
                  onSelectOnly: () => _selectRow(row.id),
                  onChanged: (updated) => _updateRow(row.id, updated),
                  onFullEdit: () => _openFullEdit(row),
                ),
              );
            },
          ),
        ),
      ]),
      bottomNavigationBar: _selectedIds.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -3)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            if (_savedCount > 0) ...[
              _pill('$_savedCount saved', _kGreen, _kGreenBg),
              const SizedBox(width: 8),
            ],
            if (_failedCount > 0) ...[
              _pill('$_failedCount failed', _kRed, _kRedBg),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSavingAll ? null : _saveSelected,
                icon: _isSavingAll
                    ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cloud_upload_outlined, size: 17),
                label: Text(_isSavingAll
                    ? 'Saving...'
                    : 'Save Selected (${_selectedIds.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _classFilterDropdown(ClassProvider classProvider) {
    final classes = classProvider.classes;
    return SizedBox(
      width: 170,
      height: 34,
      child: DropdownButtonFormField<String>(
        value: _classFilter,
        isDense: true,
        isExpanded: true,
        decoration: _filterDropDecoration('All Classes'),
        items: [
          const DropdownMenuItem(value: null, child: Text('All Classes')),
          ...classes.map((c) =>
              DropdownMenuItem(value: c.id, child: Text(c.name))),
        ],
        onChanged: (v) => setState(() {
          _classFilter = v;
          _sectionFilter = null;
        }),
      ),
    );
  }

  Widget _sectionFilterDropdown(ClassProvider classProvider) {
    if (_classFilter == null) {
      return SizedBox(
        width: 170,
        height: 34,
        child: DropdownButtonFormField<String>(
          value: null,
          isDense: true,
          isExpanded: true,
          decoration: _filterDropDecoration('All Sections'),
          items: const [
            DropdownMenuItem(value: null, child: Text('All Sections')),
          ],
          onChanged: null,
        ),
      );
    }
    final cls = classProvider.classes
        .where((c) => c.id == _classFilter)
        .cast<SchoolClass?>()
        .firstWhere((c) => c != null, orElse: () => null);
    final sections = cls?.sections ?? [];
    return SizedBox(
      width: 170,
      height: 34,
      child: DropdownButtonFormField<String>(
        value: _sectionFilter,
        isDense: true,
        isExpanded: true,
        decoration: _filterDropDecoration('All Sections'),
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        items: [
          const DropdownMenuItem(value: null, child: Text('All Sections')),
          ...sections.map((s) => DropdownMenuItem(
              value: s.sectionName, child: Text(s.sectionName))),
        ],
        onChanged: sections.isEmpty
            ? null
            : (v) => setState(() => _sectionFilter = v),
      ),
    );
  }

  InputDecoration _filterDropDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kPurple, width: 1.5)),
      filled: true,
      fillColor: const Color(0xFFF8F9FC),
    );
  }

  Widget _pill(String label, Color text, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Text(label,
        style: TextStyle(
            fontSize: 12, color: text, fontWeight: FontWeight.w700)),
  );

  Widget _filterChip(String label, String value) {
    final isActive = _typeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _kPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? _kPurple : Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey.shade700)),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.people_outline,
          size: 48, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text(
        _searchQuery.isEmpty
            ? 'No records match the current filters.'
            : 'No results for "$_searchQuery"',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      ),
    ]),
  );
}

// ─── Editable Staff Table Row (Bulk Edit) ────────────────────────────────
class _EditableStaffTableRow extends StatefulWidget {
  final _RowData data;
  final bool selected;
  final VoidCallback onSelectToggle;
  final VoidCallback onSelectOnly;
  final ValueChanged<_RowData> onChanged;
  final VoidCallback onFullEdit;

  const _EditableStaffTableRow({
    super.key,
    required this.data,
    required this.selected,
    required this.onSelectToggle,
    required this.onSelectOnly,
    required this.onChanged,
    required this.onFullEdit,
  });

  @override
  State<_EditableStaffTableRow> createState() => _EditableStaffTableRowState();
}

class _EditableStaffTableRowState extends State<_EditableStaffTableRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _desigCtrl;
  late TextEditingController _joiningDateCtrl;
  late TextEditingController _salaryCtrl;
  String? _classId;
  String? _sectionName;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.name);
    _phoneCtrl = TextEditingController(text: widget.data.phone);
    _cnicCtrl = TextEditingController(text: widget.data.cnic);
    _desigCtrl = TextEditingController(text: widget.data.designation ?? '');
    _joiningDateCtrl = TextEditingController(text: widget.data.joiningDate ?? '');
    _salaryCtrl = TextEditingController(
        text: widget.data.salary > 0 ? widget.data.salary.toString() : '');
    _classId = widget.data.classId ??
        (widget.data.assignedClasses.isNotEmpty
            ? widget.data.assignedClasses.first
            : null);
    _sectionName = widget.data.sectionName ??
        (widget.data.assignedSections.isNotEmpty
            ? widget.data.assignedSections.first
            : null);
  }

  @override
  void didUpdateWidget(covariant _EditableStaffTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      if (_nameCtrl.text != widget.data.name) _nameCtrl.text = widget.data.name;
      if (_phoneCtrl.text != widget.data.phone) _phoneCtrl.text = widget.data.phone;
      if (_cnicCtrl.text != widget.data.cnic) _cnicCtrl.text = widget.data.cnic;
      final desig = widget.data.designation ?? '';
      if (_desigCtrl.text != desig) _desigCtrl.text = desig;
      final jd = widget.data.joiningDate ?? '';
      if (_joiningDateCtrl.text != jd) _joiningDateCtrl.text = jd;
      final sal = widget.data.salary > 0 ? widget.data.salary.toString() : '';
      if (_salaryCtrl.text != sal) _salaryCtrl.text = sal;
      final newClassId = widget.data.classId ??
          (widget.data.assignedClasses.isNotEmpty
              ? widget.data.assignedClasses.first
              : null);
      if (newClassId != _classId) setState(() => _classId = newClassId);
      final newSection = widget.data.sectionName ??
          (widget.data.assignedSections.isNotEmpty
              ? widget.data.assignedSections.first
              : null);
      if (newSection != _sectionName) setState(() => _sectionName = newSection);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _desigCtrl.dispose();
    _joiningDateCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      cnic: _cnicCtrl.text,
      designation: _desigCtrl.text.trim().isEmpty ? null : _desigCtrl.text.trim(),
      classId: _classId,
      sectionName: _sectionName,
      joiningDate: _joiningDateCtrl.text.isEmpty ? null : _joiningDateCtrl.text,
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
    ));
  }

  Color get _borderColor {
    switch (widget.data.status) {
      case RowStatus.saved:
        return _kGreen.withOpacity(0.5);
      case RowStatus.failed:
        return _kRed.withOpacity(0.5);
      case RowStatus.saving:
        return _kPurple.withOpacity(0.4);
      default:
        if (widget.data.hasError) return _kRed.withOpacity(0.4);
        if (widget.selected) return _kPurple.withOpacity(0.5);
        return _kBorderColor;
    }
  }

  Color get _bg {
    switch (widget.data.status) {
      case RowStatus.saved:
        return _kGreenBg.withOpacity(0.4);
      case RowStatus.failed:
        return _kRedBg.withOpacity(0.4);
      case RowStatus.saving:
        return _kPurpleLight.withOpacity(0.5);
      default:
        if (widget.data.hasError) return _kRedBg.withOpacity(0.3);
        return widget.selected ? _kPurpleLight.withOpacity(0.35) : Colors.white;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _joiningDateCtrl.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_joiningDateCtrl.text)
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      _joiningDateCtrl.text = formatted;
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.data.status == RowStatus.saving;
    final isSaved = widget.data.status == RowStatus.saved;
    final bool fieldsEnabled = widget.selected && !isSaving && !isSaved;

    Widget statusOrCheckbox() {
      if (isSaving) {
        return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple));
      }
      return Checkbox(
        value: widget.selected,
        onChanged: (_) => widget.onSelectToggle(),
        activeColor: _kPurple,
        visualDensity: VisualDensity.compact,
      );
    }

    final rowContent = Container(
      constraints: const BoxConstraints(minHeight: _kRowHeight),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: _RowScaffold(builder: (isNarrow) {
        Widget wrapCell(int colIndex, Widget child) {
          final col = _kColumns[colIndex];
          if (isNarrow) return SizedBox(width: col.minWidth, child: child);
          return Expanded(flex: col.flex == 0 ? 1 : col.flex, child: child);
        }

        final cells = <Widget>[
          wrapCell(1,
              _compactTextField(
                controller: _nameCtrl,
                hint: 'Ahmed Khan',
                enabled: fieldsEnabled,
                onChanged: (_) {
                  setState(() {});
                  _emit();
                },
              )),
          wrapCell(
              2,
              _compactDropdown<String>(
                value: widget.data.type,
                enabled: fieldsEnabled,
                hint: 'Type',
                items: const [
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'academy_staff', child: Text('Academy')),
                ],
                onChanged: (v) => widget.onChanged(widget.data.copyWith(type: v!)),
              )),
          wrapCell(
              3,
              _compactTextField(
                controller: _phoneCtrl,
                hint: '03XX-XXXXXXX',
                keyboard: TextInputType.phone,
                enabled: fieldsEnabled,
                onChanged: (_) => _emit(),
              )),
          wrapCell(
              4,
              _compactTextField(
                controller: _cnicCtrl,
                hint: '34101-1234567-8',
                keyboard: TextInputType.number,
                inputFormatters: [_CnicFormatter()],
                enabled: fieldsEnabled,
                onChanged: (_) => _emit(),
              )),
          wrapCell(
              5,
              _compactTextField(
                controller: _desigCtrl,
                hint: 'Principal...',
                enabled: fieldsEnabled,
                onChanged: (_) => _emit(),
              )),
          wrapCell(
              6,
              _CompactClassField(
                classId: _classId,
                enabled: fieldsEnabled,
                onChanged: (v) {
                  setState(() {
                    _classId = v;
                    _sectionName = null;
                  });
                  _emit();
                },
              )),
          wrapCell(
              7,
              _CompactSectionField(
                classId: _classId,
                sectionName: _sectionName,
                enabled: fieldsEnabled,
                onChanged: (v) {
                  setState(() => _sectionName = v);
                  _emit();
                },
              )),
          wrapCell(
              8,
              _compactDateField(
                controller: _joiningDateCtrl,
                enabled: fieldsEnabled,
                onTap: _pickDate,
              )),
          wrapCell(
              9,
              _compactTextField(
                controller: _salaryCtrl,
                hint: '0',
                keyboard: TextInputType.number,
                enabled: fieldsEnabled,
                prefixText: 'Rs ',
                onChanged: (_) => _emit(),
              )),
          wrapCell(
              10,
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (isSaved)
                  const Icon(Icons.check_circle, size: 18, color: _kGreen)
                else if (widget.data.hasError)
                  Tooltip(
                    message: widget.data.errorMsg,
                    child: const Icon(Icons.error_outline,
                        size: 18, color: _kRed),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.edit_note,
                        size: 19,
                        color: fieldsEnabled ? _kPurple : Colors.grey.shade400),
                    onPressed: fieldsEnabled ? widget.onFullEdit : null,
                    tooltip: fieldsEnabled
                        ? 'Full details edit karein'
                        : 'Pehle is row ko select karein',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
              ])),
        ];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: isNarrow ? _kColumns[0].minWidth : null,
              child: Center(child: statusOrCheckbox()),
            ),
            const SizedBox(width: _kColGap),
            for (int i = 0; i < cells.length; i++) ...[
              if (i > 0) const SizedBox(width: _kColGap),
              cells[i],
            ],
          ],
        );
      }),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!widget.selected) widget.onSelectOnly();
      },
      child: IgnorePointer(
        ignoring: !fieldsEnabled && !isSaving,
        child: Opacity(
          opacity: widget.selected ? 1.0 : 0.55,
          child: _CheckboxPassthrough(
            selected: widget.selected,
            onSelectToggle: widget.onSelectToggle,
            child: rowContent,
          ),
        ),
      ),
    );
  }
}

class _CheckboxPassthrough extends StatelessWidget {
  final bool selected;
  final VoidCallback onSelectToggle;
  final Widget child;
  const _CheckboxPassthrough({
    required this.selected,
    required this.onSelectToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) return child;
    return Stack(
      children: [
        child,
        Positioned(
          left: 4,
          top: 0,
          bottom: 0,
          child: Center(
            child: Checkbox(
              value: selected,
              onChanged: (_) => onSelectToggle(),
              activeColor: _kPurple,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}