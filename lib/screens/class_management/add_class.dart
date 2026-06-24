//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/class_model.dart';
// import '../../providers/class_provider.dart';
//
// // ─────────────────────────────────────────────
// //  Subject-wise schedule entry
// // ─────────────────────────────────────────────
// class _SubjectScheduleEntry {
//   String subject;
//   List<String> days;
//   String startTime;
//   String endTime;
//
//   _SubjectScheduleEntry({
//     this.subject = '',
//     List<String>? days,
//     this.startTime = '08:00',
//     this.endTime = '08:45',
//   }) : days = days ?? [];
// }
//
// // ─────────────────────────────────────────────
// //  Per-section timetable state
// // ─────────────────────────────────────────────
// class _SectionTimetableData {
//   // Days currently selected (pending generate)
//   List<String> pendingDays = [];
//   // Days already generated into timetable
//   Set<String> generatedDays = {};
//
//   final TextEditingController startController =
//   TextEditingController(text: '08:00');
//   final TextEditingController endController =
//   TextEditingController(text: '14:00');
//   final TextEditingController lunchStartController =
//   TextEditingController(text: '11:30');
//   final TextEditingController lunchEndController =
//   TextEditingController(text: '12:30');
//   bool hasLunchBreak = true;
//
//   List<_SubjectScheduleEntry> subjectEntries = [];
//   bool isSubjectWiseMode = false;
//   bool showAdvanced = false;
//
//   void dispose() {
//     startController.dispose();
//     endController.dispose();
//     lunchStartController.dispose();
//     lunchEndController.dispose();
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Screen
// // ─────────────────────────────────────────────
// class AddEditClassScreen extends StatefulWidget {
//   final SchoolClass? existingClass;
//   const AddEditClassScreen({super.key, this.existingClass});
//
//   @override
//   State<AddEditClassScreen> createState() => _AddEditClassScreenState();
// }
//
// class _AddEditClassScreenState extends State<AddEditClassScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _classNameController;
//   late TextEditingController _headOfClassTeacherController;
//   late TextEditingController _monthlyFeeController;
//
//   final List<String> _weekdays = [
//     'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
//   ];
//
//   // ── Class subjects ──
//   final TextEditingController _classSubjectInputController =
//   TextEditingController();
//   List<String> _classSubjects = [];
//
//   // ── Class timetable: simple mode ──
//   // pendingDays = selected but not yet generated
//   List<String> _classPendingDays = [];
//   // generatedDays = already in _classTimetable (cannot re-select)
//   Set<String> _classGeneratedDays = {};
//   final TextEditingController _classStartTimeController =
//   TextEditingController(text: '08:00');
//   final TextEditingController _classEndTimeController =
//   TextEditingController(text: '14:00');
//   final TextEditingController _lunchStartTimeController =
//   TextEditingController(text: '11:30');
//   final TextEditingController _lunchEndTimeController =
//   TextEditingController(text: '12:30');
//   bool _hasLunchBreak = true;
//   List<TimetableDay> _classTimetable = [];
//   bool _showAdvancedClassTimetable = false;
//
//   // ── Class timetable: subject-wise mode ──
//   bool _isSubjectWiseMode = false;
//   List<_SubjectScheduleEntry> _classSubjectEntries = [];
//
//   // ── Sections ──
//   List<Section> _sections = [];
//   List<TextEditingController> _sectionSubjectControllers = [];
//   final List<_SectionTimetableData> _sectionTimetables = [];
//   bool _hasSections = false;
//   bool _isSaving = false;
//
//   // ─────────────────────────────────────────────
//   //  initState
//   // ─────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     final existing = widget.existingClass;
//
//     _classNameController =
//         TextEditingController(text: existing?.name ?? '');
//     _headOfClassTeacherController =
//         TextEditingController(text: existing?.headOfClassTeacher ?? '');
//     _monthlyFeeController =
//         TextEditingController(text: existing?.monthlyFee?.toString() ?? '');
//
//     _classSubjects = existing?.subjects ?? [];
//
//     if (existing?.timetable != null && existing!.timetable!.isNotEmpty) {
//       _classTimetable = existing.timetable!
//           .map((t) => TimetableDay(
//         day: t.day,
//         periods: t.periods
//             .map((p) => TimetablePeriod(
//           subject: p.subject,
//           startTime: p.startTime,
//           endTime: p.endTime,
//           isLunchBreak: p.isLunchBreak,
//         ))
//             .toList(),
//       ))
//           .toList();
//
//       _classGeneratedDays = _classTimetable.map((d) => d.day).toSet();
//
//       if (_classTimetable.isNotEmpty) {
//         final firstDay = _classTimetable.first;
//         if (firstDay.periods.isNotEmpty) {
//           _classStartTimeController.text = firstDay.periods.first.startTime;
//           _classEndTimeController.text = firstDay.periods.last.endTime;
//         }
//         for (var period in firstDay.periods) {
//           if (period.isLunchBreak) {
//             _lunchStartTimeController.text = period.startTime;
//             _lunchEndTimeController.text = period.endTime;
//             _hasLunchBreak = true;
//             break;
//           }
//         }
//       }
//     }
//
//     _sections = existing?.sections ?? [];
//     _sectionSubjectControllers =
//         List.generate(_sections.length, (_) => TextEditingController());
//
//     for (int i = 0; i < _sections.length; i++) {
//       final sec = _sections[i];
//       final data = _SectionTimetableData();
//       if (sec.timetable != null && sec.timetable!.isNotEmpty) {
//         data.generatedDays = sec.timetable!.map((d) => d.day).toSet();
//         final firstDay = sec.timetable!.first;
//         if (firstDay.periods.isNotEmpty) {
//           data.startController.text = firstDay.periods.first.startTime;
//           data.endController.text = firstDay.periods.last.endTime;
//         }
//         for (var p in firstDay.periods) {
//           if (p.isLunchBreak) {
//             data.lunchStartController.text = p.startTime;
//             data.lunchEndController.text = p.endTime;
//             data.hasLunchBreak = true;
//             break;
//           }
//         }
//       }
//       _sectionTimetables.add(data);
//     }
//   }
//
//   @override
//   void dispose() {
//     _classNameController.dispose();
//     _headOfClassTeacherController.dispose();
//     _monthlyFeeController.dispose();
//     _classSubjectInputController.dispose();
//     _classStartTimeController.dispose();
//     _classEndTimeController.dispose();
//     _lunchStartTimeController.dispose();
//     _lunchEndTimeController.dispose();
//     for (var c in _sectionSubjectControllers) c.dispose();
//     for (var d in _sectionTimetables) d.dispose();
//     super.dispose();
//   }
//
//   // ─────────────────────────────────────────────
//   //  Time Picker helper
//   // ─────────────────────────────────────────────
//   Future<void> _pickTime(
//       BuildContext context, TextEditingController controller) async {
//     // Parse existing text to pre-select in picker
//     TimeOfDay initial = const TimeOfDay(hour: 8, minute: 0);
//     final parts = controller.text.split(':');
//     if (parts.length == 2) {
//       final h = int.tryParse(parts[0]);
//       final m = int.tryParse(parts[1]);
//       if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
//     }
//
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: initial,
//       builder: (context, child) => MediaQuery(
//         data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
//         child: child!,
//       ),
//     );
//
//     if (picked != null) {
//       final formatted =
//           '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
//       setState(() => controller.text = formatted);
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   //  Time Field widget (text + clock icon)
//   // ─────────────────────────────────────────────
//   Widget _buildTimeField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         hintText: hint,
//         isDense: true,
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.access_time, size: 18),
//           tooltip: 'Pick time',
//           onPressed: () => _pickTime(context, controller),
//         ),
//       ),
//       keyboardType: TextInputType.datetime,
//     );
//   }
//
//   // ─────────────────────────────────────────────
//   //  Timetable generators
//   // ─────────────────────────────────────────────
//
//   /// Simple mode — build periods for given days, MERGE into existing timetable
//   void _mergeSimpleTimetable({
//     required List<TimetableDay> existing,
//     required List<String> newDays,
//     required String start,
//     required String end,
//     required bool hasLunch,
//     required String lunchStart,
//     required String lunchEnd,
//   }) {
//     for (final day in newDays) {
//       final List<TimetablePeriod> periods = [];
//       if (hasLunch && lunchStart.isNotEmpty && lunchEnd.isNotEmpty) {
//         if (lunchStart != start) {
//           periods.add(TimetablePeriod(
//               startTime: start, endTime: lunchStart, subject: ''));
//         }
//         periods.add(TimetablePeriod(
//             startTime: lunchStart,
//             endTime: lunchEnd,
//             isLunchBreak: true,
//             subject: 'Lunch'));
//         if (lunchEnd != end) {
//           periods.add(
//               TimetablePeriod(startTime: lunchEnd, endTime: end, subject: ''));
//         }
//       } else {
//         periods
//             .add(TimetablePeriod(startTime: start, endTime: end, subject: ''));
//       }
//
//       // Replace if day already exists, else add
//       final idx = existing.indexWhere((d) => d.day == day);
//       final newDay = TimetableDay(day: day, periods: periods);
//       if (idx >= 0) {
//         existing[idx] = newDay;
//       } else {
//         existing.add(newDay);
//       }
//     }
//
//     // Sort by weekday order
//     existing.sort(
//             (a, b) => _weekdays.indexOf(a.day) - _weekdays.indexOf(b.day));
//   }
//
//   /// Subject-wise mode — MERGE new entries into existing timetable
//   void _mergeSubjectWiseTimetable({
//     required List<TimetableDay> existing,
//     required List<_SubjectScheduleEntry> entries,
//   }) {
//     // Build new periods grouped by day from the entries
//     final Map<String, List<TimetablePeriod>> byDay = {};
//     for (final entry in entries) {
//       for (final day in entry.days) {
//         byDay.putIfAbsent(day, () => []);
//         byDay[day]!.add(TimetablePeriod(
//           subject: entry.subject,
//           startTime: entry.startTime,
//           endTime: entry.endTime,
//         ));
//       }
//     }
//
//     for (final day in byDay.keys) {
//       final newPeriods = byDay[day]!;
//       final idx = existing.indexWhere((d) => d.day == day);
//       if (idx >= 0) {
//         // Merge: add only periods not already present (by startTime+subject)
//         for (final np in newPeriods) {
//           final alreadyThere = existing[idx].periods.any(
//                   (p) => p.startTime == np.startTime && p.subject == np.subject);
//           if (!alreadyThere) existing[idx].periods.add(np);
//         }
//         // Re-sort by start time
//         existing[idx]
//             .periods
//             .sort((a, b) => a.startTime.compareTo(b.startTime));
//       } else {
//         newPeriods.sort((a, b) => a.startTime.compareTo(b.startTime));
//         existing.add(TimetableDay(day: day, periods: newPeriods));
//       }
//     }
//
//     existing
//         .sort((a, b) => _weekdays.indexOf(a.day) - _weekdays.indexOf(b.day));
//   }
//
//   void _generateClassTimetable() {
//     if (_isSubjectWiseMode) {
//       if (_classSubjectEntries.isEmpty ||
//           _classSubjectEntries.any((e) => e.subject.isEmpty)) {
//         _snack('Please fill all subject names');
//         return;
//       }
//       if (_classSubjectEntries.any((e) => e.days.isEmpty)) {
//         _snack('Please select at least one day for each subject');
//         return;
//       }
//       setState(() {
//         _mergeSubjectWiseTimetable(
//           existing: _classTimetable,
//           entries: _classSubjectEntries,
//         );
//         // Update generatedDays
//         for (final e in _classSubjectEntries) {
//           _classGeneratedDays.addAll(e.days);
//         }
//       });
//     } else {
//       if (_classPendingDays.isEmpty ||
//           _classStartTimeController.text.isEmpty ||
//           _classEndTimeController.text.isEmpty) {
//         _snack('Please select days and enter start/end times');
//         return;
//       }
//       setState(() {
//         _mergeSimpleTimetable(
//           existing: _classTimetable,
//           newDays: _classPendingDays,
//           start: _classStartTimeController.text,
//           end: _classEndTimeController.text,
//           hasLunch: _hasLunchBreak,
//           lunchStart: _lunchStartTimeController.text,
//           lunchEnd: _lunchEndTimeController.text,
//         );
//         // Mark these days as generated & clear pending selection
//         _classGeneratedDays.addAll(_classPendingDays);
//         _classPendingDays.clear();
//       });
//     }
//   }
//
//   void _generateSectionTimetable(int idx) {
//     final data = _sectionTimetables[idx];
//     _sections[idx].timetable ??= [];
//
//     if (data.isSubjectWiseMode) {
//       if (data.subjectEntries.isEmpty ||
//           data.subjectEntries.any((e) => e.subject.isEmpty)) {
//         _snack('Please fill all subject names');
//         return;
//       }
//       if (data.subjectEntries.any((e) => e.days.isEmpty)) {
//         _snack('Please select at least one day for each subject');
//         return;
//       }
//       setState(() {
//         _mergeSubjectWiseTimetable(
//           existing: _sections[idx].timetable!,
//           entries: data.subjectEntries,
//         );
//         for (final e in data.subjectEntries) {
//           data.generatedDays.addAll(e.days);
//         }
//       });
//     } else {
//       if (data.pendingDays.isEmpty ||
//           data.startController.text.isEmpty ||
//           data.endController.text.isEmpty) {
//         _snack('Please select days and enter start/end times');
//         return;
//       }
//       setState(() {
//         _mergeSimpleTimetable(
//           existing: _sections[idx].timetable!,
//           newDays: data.pendingDays,
//           start: data.startController.text,
//           end: data.endController.text,
//           hasLunch: data.hasLunchBreak,
//           lunchStart: data.lunchStartController.text,
//           lunchEnd: data.lunchEndController.text,
//         );
//         data.generatedDays.addAll(data.pendingDays);
//         data.pendingDays.clear();
//       });
//     }
//   }
//
//   void _snack(String msg) =>
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(msg)));
//
//   // ─────────────────────────────────────────────
//   //  Subject helpers
//   // ─────────────────────────────────────────────
//   void _addClassSubject() {
//     final subject = _classSubjectInputController.text.trim();
//     if (subject.isNotEmpty) {
//       setState(() {
//         _classSubjects.add(subject);
//         _classSubjectInputController.clear();
//       });
//     }
//   }
//
//   void _removeClassSubject(int index) =>
//       setState(() => _classSubjects.removeAt(index));
//
//   void _addSectionSubject(int sectionIndex) {
//     final controller = _sectionSubjectControllers[sectionIndex];
//     final subject = controller.text.trim();
//     if (subject.isNotEmpty) {
//       setState(() {
//         _sections[sectionIndex].subjects ??= [];
//         _sections[sectionIndex].subjects!.add(subject);
//         controller.clear();
//       });
//     }
//   }
//
//   void _removeSectionSubject(int sectionIndex, int subjectIndex) =>
//       setState(
//               () => _sections[sectionIndex].subjects!.removeAt(subjectIndex));
//
//   // ─────────────────────────────────────────────
//   //  Save
//   // ─────────────────────────────────────────────
//   Future<void> _saveClass() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSaving = true);
//
//     final schoolClass = SchoolClass(
//       id: widget.existingClass?.id,
//       name: _classNameController.text.trim(),
//       headOfClassTeacher: _headOfClassTeacherController.text.trim(),
//       monthlyFee: double.tryParse(_monthlyFeeController.text),
//       subjects: _classSubjects,
//       timetable: _classTimetable,
//       sections: _sections,
//     );
//
//     try {
//       final provider = context.read<ClassProvider>();
//       if (widget.existingClass == null) {
//         await provider.addClass(schoolClass);
//       } else {
//         await provider.updateClass(schoolClass);
//       }
//       if (mounted) Navigator.pop(context, true);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   //  Advanced timetable helpers
//   // ─────────────────────────────────────────────
//   void _addClassTimetableDay() => setState(
//           () => _classTimetable.add(TimetableDay(day: 'Monday', periods: [])));
//   void _removeClassTimetableDay(int i) =>
//       setState(() => _classTimetable.removeAt(i));
//   void _addClassPeriod(int di) => setState(() {
//     _classTimetable[di]
//         .periods
//         .add(TimetablePeriod(startTime: '09:00', endTime: '09:45'));
//   });
//   void _removeClassPeriod(int di, int pi) =>
//       setState(() => _classTimetable[di].periods.removeAt(pi));
//
//   void _addSection() => setState(() {
//     _sections.add(Section(sectionName: ''));
//     _sectionSubjectControllers.add(TextEditingController());
//     _sectionTimetables.add(_SectionTimetableData());
//   });
//
//   void _removeSection(int i) => setState(() {
//     _sections.removeAt(i);
//     _sectionSubjectControllers[i].dispose();
//     _sectionSubjectControllers.removeAt(i);
//     _sectionTimetables[i].dispose();
//     _sectionTimetables.removeAt(i);
//   });
//
//   void _addSectionTimetableDay(int si) => setState(() {
//     _sections[si].timetable ??= [];
//     _sections[si]
//         .timetable!
//         .add(TimetableDay(day: 'Monday', periods: []));
//   });
//   void _removeSectionTimetableDay(int si, int di) =>
//       setState(() => _sections[si].timetable!.removeAt(di));
//   void _addSectionPeriod(int si, int di) => setState(() {
//     _sections[si]
//         .timetable![di]
//         .periods
//         .add(TimetablePeriod(startTime: '09:00', endTime: '09:45'));
//   });
//   void _removeSectionPeriod(int si, int di, int pi) =>
//       setState(() => _sections[si].timetable![di].periods.removeAt(pi));
//
//   // ─────────────────────────────────────────────
//   //  UI Helpers
//   // ─────────────────────────────────────────────
//   Widget _buildSubjectsChips(List<String> subjects, Function(int) onDelete) {
//     if (subjects.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.only(top: 6),
//       child: Wrap(
//         spacing: 6,
//         runSpacing: 4,
//         children: subjects.asMap().entries.map((e) {
//           return Chip(
//             label: Text(e.value),
//             deleteIcon: const Icon(Icons.close, size: 18),
//             onDeleted: () => onDelete(e.key),
//             backgroundColor: Colors.blue.shade50,
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildTimetablePreview(List<TimetableDay> timetable) {
//     if (timetable.isEmpty) return const SizedBox.shrink();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 12),
//         Text('Generated Timetable',
//             style: Theme.of(context).textTheme.titleSmall),
//         const SizedBox(height: 4),
//         ...timetable.map((day) => Card(
//           margin: const EdgeInsets.symmetric(vertical: 3),
//           color: Colors.blue.shade50,
//           child: Padding(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(day.day,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 13)),
//                 const SizedBox(height: 4),
//                 ...day.periods.map((p) => Padding(
//                   padding: const EdgeInsets.only(bottom: 2),
//                   child: Row(
//                     children: [
//                       Text(p.isLunchBreak ? '🍽️' : '📚',
//                           style: const TextStyle(fontSize: 14)),
//                       const SizedBox(width: 6),
//                       Text(
//                         '${p.startTime} – ${p.endTime}',
//                         style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w500),
//                       ),
//                       if (p.subject.isNotEmpty &&
//                           !p.isLunchBreak) ...[
//                         const SizedBox(width: 6),
//                         Flexible(
//                           child: Text(
//                             p.subject,
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.blue.shade700),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 )),
//               ],
//             ),
//           ),
//         )),
//       ],
//     );
//   }
//
//   Widget _buildTimetableCard(
//       List<TimetableDay> timetable,
//       Function(int) onRemoveDay,
//       Function(int) onAddPeriod,
//       Function(int, int) onRemovePeriod,
//       ) {
//     return Column(
//       children: timetable.asMap().entries.map((dayEntry) {
//         final dayIndex = dayEntry.key;
//         final day = dayEntry.value;
//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 4),
//           elevation: 1,
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: day.day,
//                         decoration: const InputDecoration(
//                             labelText: 'Day',
//                             border: OutlineInputBorder(),
//                             isDense: true),
//                         items: _weekdays
//                             .map((d) =>
//                             DropdownMenuItem(value: d, child: Text(d)))
//                             .toList(),
//                         onChanged: (val) =>
//                             setState(() => day.day = val!),
//                       ),
//                     ),
//                     IconButton(
//                       icon:
//                       const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: () => onRemoveDay(dayIndex),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 ...day.periods.asMap().entries.map((pe) {
//                   final pIndex = pe.key;
//                   final period = pe.value;
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 2,
//                           child: TextFormField(
//                             initialValue: period.subject,
//                             decoration: const InputDecoration(
//                                 labelText: 'Subject',
//                                 border: OutlineInputBorder(),
//                                 isDense: true),
//                             onChanged: (v) => period.subject = v,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: TextFormField(
//                             initialValue: period.startTime,
//                             decoration: InputDecoration(
//                               labelText: 'Start',
//                               border: const OutlineInputBorder(),
//                               isDense: true,
//                               suffixIcon: IconButton(
//                                 icon: const Icon(Icons.access_time, size: 16),
//                                 onPressed: () async {
//                                   final ctrl = TextEditingController(
//                                       text: period.startTime);
//                                   await _pickTime(context, ctrl);
//                                   setState(
//                                           () => period.startTime = ctrl.text);
//                                 },
//                               ),
//                             ),
//                             onChanged: (v) => period.startTime = v,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: TextFormField(
//                             initialValue: period.endTime,
//                             decoration: InputDecoration(
//                               labelText: 'End',
//                               border: const OutlineInputBorder(),
//                               isDense: true,
//                               suffixIcon: IconButton(
//                                 icon: const Icon(Icons.access_time, size: 16),
//                                 onPressed: () async {
//                                   final ctrl = TextEditingController(
//                                       text: period.endTime);
//                                   await _pickTime(context, ctrl);
//                                   setState(() => period.endTime = ctrl.text);
//                                 },
//                               ),
//                             ),
//                             onChanged: (v) => period.endTime = v,
//                           ),
//                         ),
//                         Column(
//                           children: [
//                             Checkbox(
//                               value: period.isLunchBreak,
//                               onChanged: (val) => setState(
//                                       () => period.isLunchBreak = val ?? false),
//                             ),
//                             const Text('Lunch',
//                                 style: TextStyle(fontSize: 10)),
//                           ],
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.remove_circle,
//                               color: Colors.red, size: 20),
//                           onPressed: () => onRemovePeriod(dayIndex, pIndex),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//                 TextButton.icon(
//                   onPressed: () => onAddPeriod(dayIndex),
//                   icon: const Icon(Icons.add, size: 18),
//                   label: const Text('Add Period'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   // ─────────────────────────────────────────────
//   //  Subject-wise entries UI
//   // ─────────────────────────────────────────────
//   Widget _buildSubjectWiseEntries(
//       List<_SubjectScheduleEntry> entries,
//       VoidCallback onAddEntry,
//       Function(int) onRemoveEntry,
//       ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ...entries.asMap().entries.map((mapEntry) {
//           final i = mapEntry.key;
//           final entry = mapEntry.value;
//           return Card(
//             margin: const EdgeInsets.only(bottom: 10),
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10)),
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Subject name + delete
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           initialValue: entry.subject,
//                           decoration: const InputDecoration(
//                             labelText: 'Subject Name',
//                             border: OutlineInputBorder(),
//                             isDense: true,
//                             prefixIcon:
//                             Icon(Icons.book_outlined, size: 18),
//                           ),
//                           onChanged: (v) =>
//                               setState(() => entry.subject = v),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete_outline,
//                             color: Colors.red, size: 20),
//                         onPressed: () => onRemoveEntry(i),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Start & End time with clock picker
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Builder(builder: (ctx) {
//                           final ctrl =
//                           TextEditingController(text: entry.startTime);
//                           return TextFormField(
//                             controller: ctrl,
//                             decoration: InputDecoration(
//                               labelText: 'Start Time',
//                               border: const OutlineInputBorder(),
//                               isDense: true,
//                               hintText: '08:00',
//                               suffixIcon: IconButton(
//                                 icon: const Icon(Icons.access_time,
//                                     size: 18),
//                                 onPressed: () async {
//                                   await _pickTime(context, ctrl);
//                                   setState(
//                                           () => entry.startTime = ctrl.text);
//                                 },
//                               ),
//                             ),
//                             onChanged: (v) =>
//                                 setState(() => entry.startTime = v),
//                           );
//                         }),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Builder(builder: (ctx) {
//                           final ctrl =
//                           TextEditingController(text: entry.endTime);
//                           return TextFormField(
//                             controller: ctrl,
//                             decoration: InputDecoration(
//                               labelText: 'End Time',
//                               border: const OutlineInputBorder(),
//                               isDense: true,
//                               hintText: '08:45',
//                               suffixIcon: IconButton(
//                                 icon: const Icon(Icons.access_time,
//                                     size: 18),
//                                 onPressed: () async {
//                                   await _pickTime(context, ctrl);
//                                   setState(
//                                           () => entry.endTime = ctrl.text);
//                                 },
//                               ),
//                             ),
//                             onChanged: (v) =>
//                                 setState(() => entry.endTime = v),
//                           );
//                         }),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Day chips
//                   Text('Select Days:',
//                       style: Theme.of(context).textTheme.labelMedium),
//                   const SizedBox(height: 6),
//                   Wrap(
//                     spacing: 6,
//                     runSpacing: 4,
//                     children: _weekdays.map((day) {
//                       final selected = entry.days.contains(day);
//                       return FilterChip(
//                         label: Text(day.substring(0, 3),
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 color: selected
//                                     ? Colors.white
//                                     : Colors.black87)),
//                         selected: selected,
//                         selectedColor: Theme.of(context).primaryColor,
//                         backgroundColor: Colors.grey.shade100,
//                         checkmarkColor: Colors.white,
//                         onSelected: (val) => setState(() {
//                           if (val) {
//                             entry.days.add(day);
//                           } else {
//                             entry.days.remove(day);
//                           }
//                         }),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//         const SizedBox(height: 4),
//         OutlinedButton.icon(
//           onPressed: onAddEntry,
//           icon: const Icon(Icons.add, size: 18),
//           label: const Text('Add Subject'),
//           style: OutlinedButton.styleFrom(
//             minimumSize: const Size(double.infinity, 40),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─────────────────────────────────────────────
//   //  Main schedule card (UNIFIED)
//   // ─────────────────────────────────────────────
//   Widget _buildScheduleCard({
//     required bool isSubjectWiseMode,
//     required VoidCallback onToggleMode,
//     // Simple mode
//     required List<String> pendingDays,
//     required Set<String> generatedDays,
//     required TextEditingController startController,
//     required TextEditingController endController,
//     required TextEditingController lunchStartController,
//     required TextEditingController lunchEndController,
//     required bool hasLunchBreak,
//     required ValueChanged<bool> onLunchToggle,
//     required bool showAdvanced,
//     required VoidCallback onToggleAdvanced,
//     required VoidCallback? onAddDay,
//     required Function(int) onRemoveDay,
//     required Function(int) onAddPeriod,
//     required Function(int, int) onRemovePeriod,
//     // Subject-wise
//     required List<_SubjectScheduleEntry> subjectEntries,
//     required VoidCallback onAddSubjectEntry,
//     required Function(int) onRemoveSubjectEntry,
//     // Common
//     required VoidCallback onGenerate,
//     required List<TimetableDay> timetable,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Mode Toggle ──
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           padding: const EdgeInsets.all(4),
//           child: Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     if (isSubjectWiseMode) onToggleMode();
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     decoration: BoxDecoration(
//                       color: !isSubjectWiseMode
//                           ? Theme.of(context).primaryColor
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Center(
//                       child: Text('Simple Schedule',
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: !isSubjectWiseMode
//                                   ? Colors.white
//                                   : Colors.black54)),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     if (!isSubjectWiseMode) onToggleMode();
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     decoration: BoxDecoration(
//                       color: isSubjectWiseMode
//                           ? Theme.of(context).primaryColor
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Center(
//                       child: Text('Subject-wise',
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: isSubjectWiseMode
//                                   ? Colors.white
//                                   : Colors.black54)),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         if (!isSubjectWiseMode) ...[
//           // ══ SIMPLE MODE ══
//
//           // Day chips: generated=disabled+green, pending=selected+blue, available=normal
//           Text('Select Days:', style: Theme.of(context).textTheme.labelLarge),
//           const SizedBox(height: 4),
//           Text(
//             'Already generated days are locked (green). Select remaining days and generate.',
//             style: Theme.of(context)
//                 .textTheme
//                 .bodySmall
//                 ?.copyWith(color: Colors.black45),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 6,
//             children: _weekdays.map((day) {
//               final isGenerated = generatedDays.contains(day);
//               final isPending = pendingDays.contains(day);
//
//               return FilterChip(
//                 label: Text(
//                   day,
//                   style: TextStyle(
//                     color: isGenerated
//                         ? Colors.green.shade800
//                         : isPending
//                         ? Colors.white
//                         : Colors.black87,
//                     fontSize: 13,
//                   ),
//                 ),
//                 selected: isPending,
//                 // Disable if already generated
//                 onSelected: isGenerated
//                     ? null
//                     : (val) => setState(() {
//                   if (val) {
//                     pendingDays.add(day);
//                   } else {
//                     pendingDays.remove(day);
//                   }
//                 }),
//                 selectedColor: Theme.of(context).primaryColor,
//                 backgroundColor: isGenerated
//                     ? Colors.green.shade50
//                     : Colors.grey.shade100,
//                 checkmarkColor: Colors.white,
//                 avatar: isGenerated
//                     ? Icon(Icons.check_circle,
//                     size: 16, color: Colors.green.shade700)
//                     : null,
//                 disabledColor: Colors.green.shade50,
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 16),
//
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTimeField(
//                   controller: startController,
//                   label: 'Class Start',
//                   hint: '08:00',
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildTimeField(
//                   controller: endController,
//                   label: 'Class End',
//                   hint: '14:00',
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//
//           Row(
//             children: [
//               Text('Lunch Break',
//                   style: Theme.of(context).textTheme.bodyMedium),
//               const Spacer(),
//               Switch(
//                 value: hasLunchBreak,
//                 onChanged: (val) => setState(() => onLunchToggle(val)),
//               ),
//             ],
//           ),
//           if (hasLunchBreak) ...[
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildTimeField(
//                     controller: lunchStartController,
//                     label: 'Lunch Start',
//                     hint: '11:30',
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildTimeField(
//                     controller: lunchEndController,
//                     label: 'Lunch End',
//                     hint: '12:30',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           const SizedBox(height: 16),
//
//           ElevatedButton.icon(
//             onPressed: pendingDays.isEmpty ? null : onGenerate,
//             icon: const Icon(Icons.refresh),
//             label: Text(pendingDays.isEmpty
//                 ? 'Select days to generate'
//                 : 'Generate for ${pendingDays.length} day(s)'),
//             style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 42)),
//           ),
//
//           _buildTimetablePreview(timetable),
//           const SizedBox(height: 12),
//
//           // Advanced toggle
//           InkWell(
//             onTap: onToggleAdvanced,
//             borderRadius: BorderRadius.circular(6),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 children: [
//                   Icon(
//                       showAdvanced
//                           ? Icons.expand_less
//                           : Icons.expand_more,
//                       size: 20),
//                   const SizedBox(width: 4),
//                   Text('Advanced: Customize Periods',
//                       style: Theme.of(context).textTheme.labelMedium),
//                 ],
//               ),
//             ),
//           ),
//           if (showAdvanced) ...[
//             const SizedBox(height: 8),
//             if (onAddDay != null)
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton.icon(
//                   onPressed: onAddDay,
//                   icon: const Icon(Icons.add, size: 18),
//                   label: const Text('Add Day'),
//                 ),
//               ),
//             _buildTimetableCard(
//                 timetable, onRemoveDay, onAddPeriod, onRemovePeriod),
//           ],
//         ] else ...[
//           // ══ SUBJECT-WISE MODE ══
//           Text(
//             'Add subjects, assign days & time. Generate merges with existing.',
//             style: Theme.of(context)
//                 .textTheme
//                 .bodySmall
//                 ?.copyWith(color: Colors.black45),
//           ),
//           const SizedBox(height: 12),
//           _buildSubjectWiseEntries(
//             subjectEntries,
//             onAddSubjectEntry,
//             onRemoveSubjectEntry,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: subjectEntries.isEmpty ? null : onGenerate,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Generate & Merge Timetable'),
//             style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 42)),
//           ),
//           _buildTimetablePreview(timetable),
//         ],
//       ],
//     );
//   }
//
//   // ─────────────────────────────────────────────
//   //  build
//   // ─────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//         Text(widget.existingClass == null ? 'Add Class' : 'Edit Class'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             TextFormField(
//               controller: _classNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Class Name',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.class_),
//               ),
//               validator: (v) =>
//               v == null || v.trim().isEmpty ? 'Enter class name' : null,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _headOfClassTeacherController,
//               decoration: const InputDecoration(
//                 labelText: 'Head of Class Teacher',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.person),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _monthlyFeeController,
//               decoration: const InputDecoration(
//                 labelText: 'Monthly Fee (Optional)',
//                 border: OutlineInputBorder(),
//                 prefixText: '\$ ',
//                 prefixIcon: Icon(Icons.money),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16),
//
//             // ── Class Subjects ──
//             Text('Class Subjects',
//                 style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _classSubjectInputController,
//                     decoration: const InputDecoration(
//                       hintText: 'Add subject',
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: _addClassSubject,
//                   icon: const Icon(Icons.save, color: Colors.blue),
//                   tooltip: 'Add Subject',
//                 ),
//               ],
//             ),
//             _buildSubjectsChips(_classSubjects, _removeClassSubject),
//             const SizedBox(height: 24),
//
//             // ════════════════════════════════════
//             //  CLASS SCHEDULE
//             // ════════════════════════════════════
//             Card(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Class Schedule',
//                         style: Theme.of(context).textTheme.titleMedium),
//                     const SizedBox(height: 12),
//                     _buildScheduleCard(
//                       isSubjectWiseMode: _isSubjectWiseMode,
//                       onToggleMode: () => setState(
//                               () => _isSubjectWiseMode = !_isSubjectWiseMode),
//                       pendingDays: _classPendingDays,
//                       generatedDays: _classGeneratedDays,
//                       startController: _classStartTimeController,
//                       endController: _classEndTimeController,
//                       lunchStartController: _lunchStartTimeController,
//                       lunchEndController: _lunchEndTimeController,
//                       hasLunchBreak: _hasLunchBreak,
//                       onLunchToggle: (val) => _hasLunchBreak = val,
//                       showAdvanced: _showAdvancedClassTimetable,
//                       onToggleAdvanced: () => setState(() =>
//                       _showAdvancedClassTimetable =
//                       !_showAdvancedClassTimetable),
//                       onAddDay: _addClassTimetableDay,
//                       onRemoveDay: _removeClassTimetableDay,
//                       onAddPeriod: _addClassPeriod,
//                       onRemovePeriod: _removeClassPeriod,
//                       subjectEntries: _classSubjectEntries,
//                       onAddSubjectEntry: () => setState(
//                               () => _classSubjectEntries
//                               .add(_SubjectScheduleEntry())),
//                       onRemoveSubjectEntry: (i) => setState(
//                               () => _classSubjectEntries.removeAt(i)),
//                       onGenerate: _generateClassTimetable,
//                       timetable: _classTimetable,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // ════════════════════════════════════
//             //  SECTIONS TOGGLE
//             // ════════════════════════════════════
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Has Sections?',
//                     style: Theme.of(context).textTheme.titleMedium),
//                 Switch(
//                   value: _hasSections,
//                   onChanged: (val) {
//                     setState(() {
//                       _hasSections = val;
//                       if (!val) {
//                         for (var c in _sectionSubjectControllers) {
//                           c.dispose();
//                         }
//                         _sectionSubjectControllers.clear();
//                         for (var d in _sectionTimetables) {
//                           d.dispose();
//                         }
//                         _sectionTimetables.clear();
//                         _sections.clear();
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),
//
//             // ════════════════════════════════════
//             //  SECTIONS
//             // ════════════════════════════════════
//             if (_hasSections) ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Sections',
//                       style: Theme.of(context).textTheme.titleMedium),
//                   ElevatedButton.icon(
//                     onPressed: _addSection,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add Section'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               ...List.generate(_sections.length, (si) {
//                 final section = _sections[si];
//                 final td = _sectionTimetables[si];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 initialValue: section.sectionName,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Section Name',
//                                   border: OutlineInputBorder(),
//                                   prefixIcon: Icon(Icons.group),
//                                 ),
//                                 onChanged: (val) =>
//                                 section.sectionName = val,
//                                 validator: (v) =>
//                                 v == null || v.trim().isEmpty
//                                     ? 'Enter section name'
//                                     : null,
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete,
//                                   color: Colors.red),
//                               onPressed: () => _removeSection(si),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           initialValue: section.headOfTeacher,
//                           decoration: const InputDecoration(
//                             labelText: 'Head of Teacher',
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.person_outline),
//                           ),
//                           onChanged: (val) => section.headOfTeacher = val,
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           initialValue: section.monthlyFee?.toString(),
//                           decoration: const InputDecoration(
//                             labelText: 'Monthly Fee (Optional)',
//                             border: OutlineInputBorder(),
//                             prefixText: '\$ ',
//                           ),
//                           keyboardType: TextInputType.number,
//                           onChanged: (val) =>
//                           section.monthlyFee = double.tryParse(val),
//                         ),
//                         const SizedBox(height: 12),
//                         Text('Subjects',
//                             style:
//                             Theme.of(context).textTheme.labelLarge),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller:
//                                 _sectionSubjectControllers[si],
//                                 decoration: const InputDecoration(
//                                   hintText: 'Add subject',
//                                   border: OutlineInputBorder(),
//                                   isDense: true,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             IconButton(
//                               onPressed: () => _addSectionSubject(si),
//                               icon: const Icon(Icons.save,
//                                   color: Colors.blue),
//                               tooltip: 'Add Subject',
//                             ),
//                           ],
//                         ),
//                         _buildSubjectsChips(
//                           section.subjects ?? [],
//                               (idx) => _removeSectionSubject(si, idx),
//                         ),
//                         const SizedBox(height: 12),
//                         Text('Section Timetable',
//                             style:
//                             Theme.of(context).textTheme.labelLarge),
//                         const SizedBox(height: 8),
//                         _buildScheduleCard(
//                           isSubjectWiseMode: td.isSubjectWiseMode,
//                           onToggleMode: () => setState(() =>
//                           td.isSubjectWiseMode = !td.isSubjectWiseMode),
//                           pendingDays: td.pendingDays,
//                           generatedDays: td.generatedDays,
//                           startController: td.startController,
//                           endController: td.endController,
//                           lunchStartController: td.lunchStartController,
//                           lunchEndController: td.lunchEndController,
//                           hasLunchBreak: td.hasLunchBreak,
//                           onLunchToggle: (val) => td.hasLunchBreak = val,
//                           showAdvanced: td.showAdvanced,
//                           onToggleAdvanced: () => setState(
//                                   () => td.showAdvanced = !td.showAdvanced),
//                           onAddDay: () => _addSectionTimetableDay(si),
//                           onRemoveDay: (di) =>
//                               _removeSectionTimetableDay(si, di),
//                           onAddPeriod: (di) =>
//                               _addSectionPeriod(si, di),
//                           onRemovePeriod: (di, pi) =>
//                               _removeSectionPeriod(si, di, pi),
//                           subjectEntries: td.subjectEntries,
//                           onAddSubjectEntry: () => setState(() =>
//                               td.subjectEntries
//                                   .add(_SubjectScheduleEntry())),
//                           onRemoveSubjectEntry: (i) => setState(
//                                   () => td.subjectEntries.removeAt(i)),
//                           onGenerate: () => _generateSectionTimetable(si),
//                           timetable: section.timetable ?? [],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ],
//
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: _isSaving ? null : _saveClass,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 backgroundColor: Theme.of(context).primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: _isSaving
//                   ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                     strokeWidth: 2, color: Colors.white),
//               )
//                   : Text(
//                 widget.existingClass == null
//                     ? 'Save Class'
//                     : 'Update Class',
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';

// ─────────────────────────────────────────────
//  Subject-wise schedule entry (unchanged)
// ─────────────────────────────────────────────
class _SubjectScheduleEntry {
  String subject;
  List<String> days;
  String startTime;
  String endTime;

  _SubjectScheduleEntry({
    this.subject = '',
    List<String>? days,
    this.startTime = '08:00',
    this.endTime = '08:45',
  }) : days = days ?? [];
}

// ─────────────────────────────────────────────
//  Per-section timetable state (unchanged)
// ─────────────────────────────────────────────
class _SectionTimetableData {
  List<String> pendingDays = [];
  Set<String> generatedDays = {};

  final TextEditingController startController =
  TextEditingController(text: '08:00');
  final TextEditingController endController =
  TextEditingController(text: '14:00');
  final TextEditingController lunchStartController =
  TextEditingController(text: '11:30');
  final TextEditingController lunchEndController =
  TextEditingController(text: '12:30');
  bool hasLunchBreak = true;

  List<_SubjectScheduleEntry> subjectEntries = [];
  bool isSubjectWiseMode = false;
  bool showAdvanced = false;

  void dispose() {
    startController.dispose();
    endController.dispose();
    lunchStartController.dispose();
    lunchEndController.dispose();
  }
}

// ─────────────────────────────────────────────
//  Custom section name field with class prefix
// ─────────────────────────────────────────────
class _SectionNameField extends StatefulWidget {
  final String className;
  final String initialFullName;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const _SectionNameField({
    required this.className,
    required this.initialFullName,
    required this.onChanged,
    this.validator,
  });

  @override
  State<_SectionNameField> createState() => _SectionNameFieldState();
}

class _SectionNameFieldState extends State<_SectionNameField> {
  late TextEditingController _controller;
  String _prefix = '';

  @override
  void initState() {
    super.initState();
    _updatePrefixAndController();
  }

  @override
  void didUpdateWidget(covariant _SectionNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.className != widget.className ||
        oldWidget.initialFullName != widget.initialFullName) {
      _updatePrefixAndController();
    }
  }

  void _updatePrefixAndController() {
    final className = widget.className.trim().isEmpty
        ? 'Class'
        : widget.className.trim();
    _prefix = '$className section ';

    // Extract the suffix from the initial full name
    String suffix = '';
    if (widget.initialFullName.isNotEmpty &&
        widget.initialFullName.startsWith(_prefix)) {
      suffix = widget.initialFullName.substring(_prefix.length);
    }
    _controller = TextEditingController(text: suffix);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Section Name',
        border: const OutlineInputBorder(),
        prefixText: _prefix,
        prefixIcon: const Icon(Icons.group),
      ),
      onChanged: (suffix) {
        final fullName = '$_prefix$suffix';
        widget.onChanged(fullName);
      },
      validator: widget.validator,
    );
  }
}

// ─────────────────────────────────────────────
//  Main Screen
// ─────────────────────────────────────────────
class AddEditClassScreen extends StatefulWidget {
  final SchoolClass? existingClass;
  const AddEditClassScreen({super.key, this.existingClass});

  @override
  State<AddEditClassScreen> createState() => _AddEditClassScreenState();
}

class _AddEditClassScreenState extends State<AddEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _classNameController;
  late TextEditingController _headOfClassTeacherController;
  late TextEditingController _monthlyFeeController;

  final List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  // ── Class subjects ──
  final TextEditingController _classSubjectInputController =
  TextEditingController();
  List<String> _classSubjects = [];

  // ── Class timetable: simple mode ──
  List<String> _classPendingDays = [];
  Set<String> _classGeneratedDays = {};
  final TextEditingController _classStartTimeController =
  TextEditingController(text: '08:00');
  final TextEditingController _classEndTimeController =
  TextEditingController(text: '14:00');
  final TextEditingController _lunchStartTimeController =
  TextEditingController(text: '11:30');
  final TextEditingController _lunchEndTimeController =
  TextEditingController(text: '12:30');
  bool _hasLunchBreak = true;
  List<TimetableDay> _classTimetable = [];
  bool _showAdvancedClassTimetable = false;

  // ── Class timetable: subject-wise mode ──
  bool _isSubjectWiseMode = false;
  List<_SubjectScheduleEntry> _classSubjectEntries = [];

  // ── Sections ──
  List<Section> _sections = [];
  List<TextEditingController> _sectionSubjectControllers = [];
  final List<_SectionTimetableData> _sectionTimetables = [];
  bool _hasSections = false;
  bool _isSaving = false;

  // Class name for section prefix
  String _classDisplayName = '';

  @override
  void initState() {
    super.initState();
    final existing = widget.existingClass;

    _classNameController =
        TextEditingController(text: existing?.name ?? '');
    _headOfClassTeacherController =
        TextEditingController(text: existing?.headOfClassTeacher ?? '');
    _monthlyFeeController =
        TextEditingController(text: existing?.monthlyFee?.toString() ?? '');

    _classDisplayName = _classNameController.text.trim();
    _classNameController.addListener(() {
      setState(() {
        _classDisplayName = _classNameController.text.trim();
      });
    });

    _classSubjects = existing?.subjects ?? [];

    if (existing?.timetable != null && existing!.timetable!.isNotEmpty) {
      _classTimetable = existing.timetable!
          .map((t) => TimetableDay(
        day: t.day,
        periods: t.periods
            .map((p) => TimetablePeriod(
          subject: p.subject,
          startTime: p.startTime,
          endTime: p.endTime,
          isLunchBreak: p.isLunchBreak,
        ))
            .toList(),
      ))
          .toList();

      _classGeneratedDays = _classTimetable.map((d) => d.day).toSet();

      if (_classTimetable.isNotEmpty) {
        final firstDay = _classTimetable.first;
        if (firstDay.periods.isNotEmpty) {
          _classStartTimeController.text = firstDay.periods.first.startTime;
          _classEndTimeController.text = firstDay.periods.last.endTime;
        }
        for (var period in firstDay.periods) {
          if (period.isLunchBreak) {
            _lunchStartTimeController.text = period.startTime;
            _lunchEndTimeController.text = period.endTime;
            _hasLunchBreak = true;
            break;
          }
        }
      }
    }

    _sections = existing?.sections ?? [];
    _sectionSubjectControllers =
        List.generate(_sections.length, (_) => TextEditingController());

    for (int i = 0; i < _sections.length; i++) {
      final sec = _sections[i];
      final data = _SectionTimetableData();
      if (sec.timetable != null && sec.timetable!.isNotEmpty) {
        data.generatedDays = sec.timetable!.map((d) => d.day).toSet();
        final firstDay = sec.timetable!.first;
        if (firstDay.periods.isNotEmpty) {
          data.startController.text = firstDay.periods.first.startTime;
          data.endController.text = firstDay.periods.last.endTime;
        }
        for (var p in firstDay.periods) {
          if (p.isLunchBreak) {
            data.lunchStartController.text = p.startTime;
            data.lunchEndController.text = p.endTime;
            data.hasLunchBreak = true;
            break;
          }
        }
      }
      _sectionTimetables.add(data);
    }
  }

  @override
  void dispose() {
    _classNameController.removeListener(() {});
    _classNameController.dispose();
    _headOfClassTeacherController.dispose();
    _monthlyFeeController.dispose();
    _classSubjectInputController.dispose();
    _classStartTimeController.dispose();
    _classEndTimeController.dispose();
    _lunchStartTimeController.dispose();
    _lunchEndTimeController.dispose();
    for (var c in _sectionSubjectControllers) c.dispose();
    for (var d in _sectionTimetables) d.dispose();
    super.dispose();
  }

  // ---------- Duplicate class name check ----------
  bool _isClassNameDuplicate(String name) {
    final normalizedInput = name.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final classes = context.read<ClassProvider>().classes;
    final currentId = widget.existingClass?.id;

    for (final cls in classes) {
      if (currentId != null && cls.id == currentId) continue;
      final normalizedExisting =
      cls.name.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      if (normalizedExisting == normalizedInput) return true;
    }
    return false;
  }

  // ---------- Time picker helper ----------
  Future<void> _pickTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay initial = const TimeOfDay(hour: 8, minute: 0);
    final parts = controller.text.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() => controller.text = formatted);
    }
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        hintText: hint,
        isDense: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time, size: 18),
          onPressed: () => _pickTime(context, controller),
        ),
      ),
      keyboardType: TextInputType.datetime,
    );
  }

  // ---------- Timetable generators (unchanged) ----------
  void _mergeSimpleTimetable({
    required List<TimetableDay> existing,
    required List<String> newDays,
    required String start,
    required String end,
    required bool hasLunch,
    required String lunchStart,
    required String lunchEnd,
  }) {
    for (final day in newDays) {
      final List<TimetablePeriod> periods = [];
      if (hasLunch && lunchStart.isNotEmpty && lunchEnd.isNotEmpty) {
        if (lunchStart != start) {
          periods.add(
              TimetablePeriod(startTime: start, endTime: lunchStart, subject: ''));
        }
        periods.add(TimetablePeriod(
            startTime: lunchStart,
            endTime: lunchEnd,
            isLunchBreak: true,
            subject: 'Lunch'));
        if (lunchEnd != end) {
          periods.add(
              TimetablePeriod(startTime: lunchEnd, endTime: end, subject: ''));
        }
      } else {
        periods
            .add(TimetablePeriod(startTime: start, endTime: end, subject: ''));
      }

      final idx = existing.indexWhere((d) => d.day == day);
      final newDay = TimetableDay(day: day, periods: periods);
      if (idx >= 0) {
        existing[idx] = newDay;
      } else {
        existing.add(newDay);
      }
    }
    existing.sort(
            (a, b) => _weekdays.indexOf(a.day) - _weekdays.indexOf(b.day));
  }

  void _mergeSubjectWiseTimetable({
    required List<TimetableDay> existing,
    required List<_SubjectScheduleEntry> entries,
  }) {
    final Map<String, List<TimetablePeriod>> byDay = {};
    for (final entry in entries) {
      for (final day in entry.days) {
        byDay.putIfAbsent(day, () => []);
        byDay[day]!.add(TimetablePeriod(
          subject: entry.subject,
          startTime: entry.startTime,
          endTime: entry.endTime,
        ));
      }
    }
    for (final day in byDay.keys) {
      final newPeriods = byDay[day]!;
      final idx = existing.indexWhere((d) => d.day == day);
      if (idx >= 0) {
        for (final np in newPeriods) {
          final alreadyThere = existing[idx].periods.any(
                  (p) => p.startTime == np.startTime && p.subject == np.subject);
          if (!alreadyThere) existing[idx].periods.add(np);
        }
        existing[idx]
            .periods
            .sort((a, b) => a.startTime.compareTo(b.startTime));
      } else {
        newPeriods.sort((a, b) => a.startTime.compareTo(b.startTime));
        existing.add(TimetableDay(day: day, periods: newPeriods));
      }
    }
    existing.sort(
            (a, b) => _weekdays.indexOf(a.day) - _weekdays.indexOf(b.day));
  }

  void _generateClassTimetable() {
    if (_isSubjectWiseMode) {
      if (_classSubjectEntries.isEmpty ||
          _classSubjectEntries.any((e) => e.subject.isEmpty)) {
        _snack('Please fill all subject names');
        return;
      }
      if (_classSubjectEntries.any((e) => e.days.isEmpty)) {
        _snack('Please select at least one day for each subject');
        return;
      }
      setState(() {
        _mergeSubjectWiseTimetable(
          existing: _classTimetable,
          entries: _classSubjectEntries,
        );
        for (final e in _classSubjectEntries) {
          _classGeneratedDays.addAll(e.days);
        }
      });
    } else {
      if (_classPendingDays.isEmpty ||
          _classStartTimeController.text.isEmpty ||
          _classEndTimeController.text.isEmpty) {
        _snack('Please select days and enter start/end times');
        return;
      }
      setState(() {
        _mergeSimpleTimetable(
          existing: _classTimetable,
          newDays: _classPendingDays,
          start: _classStartTimeController.text,
          end: _classEndTimeController.text,
          hasLunch: _hasLunchBreak,
          lunchStart: _lunchStartTimeController.text,
          lunchEnd: _lunchEndTimeController.text,
        );
        _classGeneratedDays.addAll(_classPendingDays);
        _classPendingDays.clear();
      });
    }
  }

  void _generateSectionTimetable(int idx) {
    final data = _sectionTimetables[idx];
    _sections[idx].timetable ??= [];

    if (data.isSubjectWiseMode) {
      if (data.subjectEntries.isEmpty ||
          data.subjectEntries.any((e) => e.subject.isEmpty)) {
        _snack('Please fill all subject names');
        return;
      }
      if (data.subjectEntries.any((e) => e.days.isEmpty)) {
        _snack('Please select at least one day for each subject');
        return;
      }
      setState(() {
        _mergeSubjectWiseTimetable(
          existing: _sections[idx].timetable!,
          entries: data.subjectEntries,
        );
        for (final e in data.subjectEntries) {
          data.generatedDays.addAll(e.days);
        }
      });
    } else {
      if (data.pendingDays.isEmpty ||
          data.startController.text.isEmpty ||
          data.endController.text.isEmpty) {
        _snack('Please select days and enter start/end times');
        return;
      }
      setState(() {
        _mergeSimpleTimetable(
          existing: _sections[idx].timetable!,
          newDays: data.pendingDays,
          start: data.startController.text,
          end: data.endController.text,
          hasLunch: data.hasLunchBreak,
          lunchStart: data.lunchStartController.text,
          lunchEnd: data.lunchEndController.text,
        );
        data.generatedDays.addAll(data.pendingDays);
        data.pendingDays.clear();
      });
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ---------- Subject helpers (unchanged) ----------
  void _addClassSubject() {
    final subject = _classSubjectInputController.text.trim();
    if (subject.isNotEmpty) {
      setState(() {
        _classSubjects.add(subject);
        _classSubjectInputController.clear();
      });
    }
  }

  void _removeClassSubject(int index) =>
      setState(() => _classSubjects.removeAt(index));

  void _addSectionSubject(int sectionIndex) {
    final controller = _sectionSubjectControllers[sectionIndex];
    final subject = controller.text.trim();
    if (subject.isNotEmpty) {
      setState(() {
        _sections[sectionIndex].subjects ??= [];
        _sections[sectionIndex].subjects!.add(subject);
        controller.clear();
      });
    }
  }

  void _removeSectionSubject(int sectionIndex, int subjectIndex) =>
      setState(() => _sections[sectionIndex].subjects!.removeAt(subjectIndex));

  // ---------- Save ----------
  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final schoolClass = SchoolClass(
      id: widget.existingClass?.id,
      name: _classNameController.text.trim(),
      headOfClassTeacher: _headOfClassTeacherController.text.trim(),
      monthlyFee: double.tryParse(_monthlyFeeController.text),
      subjects: _classSubjects,
      timetable: _classTimetable,
      sections: _sections,
    );

    try {
      final provider = context.read<ClassProvider>();
      if (widget.existingClass == null) {
        await provider.addClass(schoolClass);
      } else {
        await provider.updateClass(schoolClass);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------- Advanced timetable helpers (unchanged) ----------
  void _addClassTimetableDay() => setState(
          () => _classTimetable.add(TimetableDay(day: 'Monday', periods: [])));
  void _removeClassTimetableDay(int i) =>
      setState(() => _classTimetable.removeAt(i));
  void _addClassPeriod(int di) => setState(() {
    _classTimetable[di]
        .periods
        .add(TimetablePeriod(startTime: '09:00', endTime: '09:45'));
  });
  void _removeClassPeriod(int di, int pi) =>
      setState(() => _classTimetable[di].periods.removeAt(pi));

  void _addSection() => setState(() {
    _sections.add(Section(sectionName: ''));
    _sectionSubjectControllers.add(TextEditingController());
    _sectionTimetables.add(_SectionTimetableData());
  });
  void _removeSection(int i) => setState(() {
    _sections.removeAt(i);
    _sectionSubjectControllers[i].dispose();
    _sectionSubjectControllers.removeAt(i);
    _sectionTimetables[i].dispose();
    _sectionTimetables.removeAt(i);
  });
  void _addSectionTimetableDay(int si) => setState(() {
    _sections[si].timetable ??= [];
    _sections[si].timetable!.add(TimetableDay(day: 'Monday', periods: []));
  });
  void _removeSectionTimetableDay(int si, int di) =>
      setState(() => _sections[si].timetable!.removeAt(di));
  void _addSectionPeriod(int si, int di) => setState(() {
    _sections[si]
        .timetable![di]
        .periods
        .add(TimetablePeriod(startTime: '09:00', endTime: '09:45'));
  });
  void _removeSectionPeriod(int si, int di, int pi) =>
      setState(() => _sections[si].timetable![di].periods.removeAt(pi));

  // ---------- UI Builders (mostly unchanged, schedule card adapted) ----------
  Widget _buildSubjectsChips(List<String> subjects, Function(int) onDelete) {
    if (subjects.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: subjects.asMap().entries.map((e) {
          return Chip(
            label: Text(e.value),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => onDelete(e.key),
            backgroundColor: Colors.blue.shade50,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimetablePreview(List<TimetableDay> timetable) {
    if (timetable.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Generated Timetable',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        ...timetable.map((day) => Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.day,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                ...day.periods.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Text(p.isLunchBreak ? '🍽️' : '📚',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '${p.startTime} – ${p.endTime}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),
                      if (p.subject.isNotEmpty && !p.isLunchBreak) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            p.subject,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTimetableCard(
      List<TimetableDay> timetable,
      Function(int) onRemoveDay,
      Function(int) onAddPeriod,
      Function(int, int) onRemovePeriod,
      ) {
    return Column(
      children: timetable.asMap().entries.map((dayEntry) {
        final dayIndex = dayEntry.key;
        final day = dayEntry.value;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: day.day,
                        decoration: const InputDecoration(
                            labelText: 'Day',
                            border: OutlineInputBorder(),
                            isDense: true),
                        items: _weekdays
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) => setState(() => day.day = val!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => onRemoveDay(dayIndex),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...day.periods.asMap().entries.map((pe) {
                  final pIndex = pe.key;
                  final period = pe.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: period.subject,
                            decoration: const InputDecoration(
                                labelText: 'Subject',
                                border: OutlineInputBorder(),
                                isDense: true),
                            onChanged: (v) => period.subject = v,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextFormField(
                            initialValue: period.startTime,
                            decoration: InputDecoration(
                              labelText: 'Start',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.access_time, size: 16),
                                onPressed: () async {
                                  final ctrl =
                                  TextEditingController(text: period.startTime);
                                  await _pickTime(context, ctrl);
                                  setState(() => period.startTime = ctrl.text);
                                },
                              ),
                            ),
                            onChanged: (v) => period.startTime = v,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextFormField(
                            initialValue: period.endTime,
                            decoration: InputDecoration(
                              labelText: 'End',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.access_time, size: 16),
                                onPressed: () async {
                                  final ctrl =
                                  TextEditingController(text: period.endTime);
                                  await _pickTime(context, ctrl);
                                  setState(() => period.endTime = ctrl.text);
                                },
                              ),
                            ),
                            onChanged: (v) => period.endTime = v,
                          ),
                        ),
                        Column(
                          children: [
                            Checkbox(
                              value: period.isLunchBreak,
                              onChanged: (val) => setState(
                                      () => period.isLunchBreak = val ?? false),
                            ),
                            const Text('Lunch', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red, size: 20),
                          onPressed: () => onRemovePeriod(dayIndex, pIndex),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => onAddPeriod(dayIndex),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Period'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectWiseEntries(
      List<_SubjectScheduleEntry> entries,
      VoidCallback onAddEntry,
      Function(int) onRemoveEntry,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...entries.asMap().entries.map((mapEntry) {
          final i = mapEntry.key;
          final entry = mapEntry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.subject,
                          decoration: const InputDecoration(
                            labelText: 'Subject Name',
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: Icon(Icons.book_outlined, size: 18),
                          ),
                          onChanged: (v) => setState(() => entry.subject = v),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        onPressed: () => onRemoveEntry(i),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Builder(builder: (ctx) {
                          final ctrl =
                          TextEditingController(text: entry.startTime);
                          return TextFormField(
                            controller: ctrl,
                            decoration: InputDecoration(
                              labelText: 'Start Time',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              hintText: '08:00',
                              suffixIcon: IconButton(
                                icon:
                                const Icon(Icons.access_time, size: 18),
                                onPressed: () async {
                                  await _pickTime(context, ctrl);
                                  setState(() => entry.startTime = ctrl.text);
                                },
                              ),
                            ),
                            onChanged: (v) => setState(() => entry.startTime = v),
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Builder(builder: (ctx) {
                          final ctrl =
                          TextEditingController(text: entry.endTime);
                          return TextFormField(
                            controller: ctrl,
                            decoration: InputDecoration(
                              labelText: 'End Time',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              hintText: '08:45',
                              suffixIcon: IconButton(
                                icon:
                                const Icon(Icons.access_time, size: 18),
                                onPressed: () async {
                                  await _pickTime(context, ctrl);
                                  setState(() => entry.endTime = ctrl.text);
                                },
                              ),
                            ),
                            onChanged: (v) => setState(() => entry.endTime = v),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Select Days:',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _weekdays.map((day) {
                      final selected = entry.days.contains(day);
                      return FilterChip(
                        label: Text(day.substring(0, 3),
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                selected ? Colors.white : Colors.black87)),
                        selected: selected,
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey.shade100,
                        checkmarkColor: Colors.white,
                        onSelected: (val) => setState(() {
                          if (val) {
                            entry.days.add(day);
                          } else {
                            entry.days.remove(day);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: onAddEntry,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Subject'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }

  // Unified schedule card (unchanged logic)
  Widget _buildScheduleCard({
    required bool isSubjectWiseMode,
    required VoidCallback onToggleMode,
    required List<String> pendingDays,
    required Set<String> generatedDays,
    required TextEditingController startController,
    required TextEditingController endController,
    required TextEditingController lunchStartController,
    required TextEditingController lunchEndController,
    required bool hasLunchBreak,
    required ValueChanged<bool> onLunchToggle,
    required bool showAdvanced,
    required VoidCallback onToggleAdvanced,
    required VoidCallback? onAddDay,
    required Function(int) onRemoveDay,
    required Function(int) onAddPeriod,
    required Function(int, int) onRemovePeriod,
    required List<_SubjectScheduleEntry> subjectEntries,
    required VoidCallback onAddSubjectEntry,
    required Function(int) onRemoveSubjectEntry,
    required VoidCallback onGenerate,
    required List<TimetableDay> timetable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isSubjectWiseMode) onToggleMode();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !isSubjectWiseMode
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('Simple Schedule',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: !isSubjectWiseMode
                                  ? Colors.white
                                  : Colors.black54)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isSubjectWiseMode) onToggleMode();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSubjectWiseMode
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('Subject-wise',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSubjectWiseMode
                                  ? Colors.white
                                  : Colors.black54)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!isSubjectWiseMode) ...[
          Text('Select Days:',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            'Already generated days are locked (green). Select remaining days and generate.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black45),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _weekdays.map((day) {
              final isGenerated = generatedDays.contains(day);
              final isPending = pendingDays.contains(day);
              return FilterChip(
                label: Text(
                  day,
                  style: TextStyle(
                    color: isGenerated
                        ? Colors.green.shade800
                        : isPending
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 13,
                  ),
                ),
                selected: isPending,
                onSelected: isGenerated
                    ? null
                    : (val) => setState(() {
                  if (val) {
                    pendingDays.add(day);
                  } else {
                    pendingDays.remove(day);
                  }
                }),
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: isGenerated
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                checkmarkColor: Colors.white,
                avatar: isGenerated
                    ? Icon(Icons.check_circle,
                    size: 16, color: Colors.green.shade700)
                    : null,
                disabledColor: Colors.green.shade50,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  controller: startController,
                  label: 'Class Start',
                  hint: '08:00',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  controller: endController,
                  label: 'Class End',
                  hint: '14:00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Lunch Break',
                  style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Switch(
                value: hasLunchBreak,
                onChanged: (val) => setState(() => onLunchToggle(val)),
              ),
            ],
          ),
          if (hasLunchBreak) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    controller: lunchStartController,
                    label: 'Lunch Start',
                    hint: '11:30',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeField(
                    controller: lunchEndController,
                    label: 'Lunch End',
                    hint: '12:30',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: pendingDays.isEmpty ? null : onGenerate,
            icon: const Icon(Icons.refresh),
            label: Text(pendingDays.isEmpty
                ? 'Select days to generate'
                : 'Generate for ${pendingDays.length} day(s)'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 42)),
          ),
          _buildTimetablePreview(timetable),
          const SizedBox(height: 12),
          InkWell(
            onTap: onToggleAdvanced,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(showAdvanced ? Icons.expand_less : Icons.expand_more,
                      size: 20),
                  const SizedBox(width: 4),
                  Text('Advanced: Customize Periods',
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ),
          if (showAdvanced) ...[
            const SizedBox(height: 8),
            if (onAddDay != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onAddDay,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Day'),
                ),
              ),
            _buildTimetableCard(
                timetable, onRemoveDay, onAddPeriod, onRemovePeriod),
          ],
        ] else ...[
          Text(
            'Add subjects, assign days & time. Generate merges with existing.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black45),
          ),
          const SizedBox(height: 12),
          _buildSubjectWiseEntries(
            subjectEntries,
            onAddSubjectEntry,
            onRemoveSubjectEntry,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: subjectEntries.isEmpty ? null : onGenerate,
            icon: const Icon(Icons.refresh),
            label: const Text('Generate & Merge Timetable'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 42)),
          ),
          _buildTimetablePreview(timetable),
        ],
      ],
    );
  }

  // ───── Build sections UI (used in both mobile and desktop) ─────
  Widget _buildSectionsList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sections', style: Theme.of(context).textTheme.titleMedium),
            ElevatedButton.icon(
              onPressed: _addSection,
              icon: const Icon(Icons.add),
              label: const Text('Add Section'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_sections.length, (si) {
          final section = _sections[si];
          final td = _sectionTimetables[si];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SectionNameField(
                          className: _classDisplayName,
                          initialFullName: section.sectionName,
                          onChanged: (fullName) => section.sectionName = fullName,
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Enter section name'
                              : null,
                        ),
                      ),
                      IconButton(
                        icon:
                        const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeSection(si),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: section.headOfTeacher,
                    decoration: const InputDecoration(
                      labelText: 'Head of Teacher',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    onChanged: (val) => section.headOfTeacher = val,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: section.monthlyFee?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Fee (Optional)',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                    section.monthlyFee = double.tryParse(val),
                  ),
                  const SizedBox(height: 12),
                  Text('Subjects',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _sectionSubjectControllers[si],
                          decoration: const InputDecoration(
                            hintText: 'Add subject',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addSectionSubject(si),
                        icon: const Icon(Icons.save, color: Colors.blue),
                        tooltip: 'Add Subject',
                      ),
                    ],
                  ),
                  _buildSubjectsChips(
                    section.subjects ?? [],
                        (idx) => _removeSectionSubject(si, idx),
                  ),
                  const SizedBox(height: 12),
                  Text('Section Timetable',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _buildScheduleCard(
                    isSubjectWiseMode: td.isSubjectWiseMode,
                    onToggleMode: () => setState(
                            () => td.isSubjectWiseMode = !td.isSubjectWiseMode),
                    pendingDays: td.pendingDays,
                    generatedDays: td.generatedDays,
                    startController: td.startController,
                    endController: td.endController,
                    lunchStartController: td.lunchStartController,
                    lunchEndController: td.lunchEndController,
                    hasLunchBreak: td.hasLunchBreak,
                    onLunchToggle: (val) => td.hasLunchBreak = val,
                    showAdvanced: td.showAdvanced,
                    onToggleAdvanced: () =>
                        setState(() => td.showAdvanced = !td.showAdvanced),
                    onAddDay: () => _addSectionTimetableDay(si),
                    onRemoveDay: (di) => _removeSectionTimetableDay(si, di),
                    onAddPeriod: (di) => _addSectionPeriod(si, di),
                    onRemovePeriod: (di, pi) =>
                        _removeSectionPeriod(si, di, pi),
                    subjectEntries: td.subjectEntries,
                    onAddSubjectEntry: () => setState(
                            () => td.subjectEntries.add(_SubjectScheduleEntry())),
                    onRemoveSubjectEntry: (i) =>
                        setState(() => td.subjectEntries.removeAt(i)),
                    onGenerate: () => _generateSectionTimetable(si),
                    timetable: section.timetable ?? [],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive breakpoint
    const double desktopBreakpoint = 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.existingClass == null ? 'Add Class' : 'Edit Class'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= desktopBreakpoint;

            // Common content widgets
            final classInfoSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _classNameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.class_),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter class name';
                    if (_isClassNameDuplicate(v.trim())) {
                      return 'A class with this name already exists';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _headOfClassTeacherController,
                  decoration: const InputDecoration(
                    labelText: 'Head of Class Teacher',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _monthlyFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Fee (Optional)',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                    prefixIcon: Icon(Icons.money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text('Class Subjects',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _classSubjectInputController,
                        decoration: const InputDecoration(
                          hintText: 'Add subject',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addClassSubject,
                      icon: const Icon(Icons.save, color: Colors.blue),
                      tooltip: 'Add Subject',
                    ),
                  ],
                ),
                _buildSubjectsChips(_classSubjects, _removeClassSubject),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class Schedule',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _buildScheduleCard(
                          isSubjectWiseMode: _isSubjectWiseMode,
                          onToggleMode: () => setState(() =>
                          _isSubjectWiseMode = !_isSubjectWiseMode),
                          pendingDays: _classPendingDays,
                          generatedDays: _classGeneratedDays,
                          startController: _classStartTimeController,
                          endController: _classEndTimeController,
                          lunchStartController: _lunchStartTimeController,
                          lunchEndController: _lunchEndTimeController,
                          hasLunchBreak: _hasLunchBreak,
                          onLunchToggle: (val) => _hasLunchBreak = val,
                          showAdvanced: _showAdvancedClassTimetable,
                          onToggleAdvanced: () => setState(() =>
                          _showAdvancedClassTimetable =
                          !_showAdvancedClassTimetable),
                          onAddDay: _addClassTimetableDay,
                          onRemoveDay: _removeClassTimetableDay,
                          onAddPeriod: _addClassPeriod,
                          onRemovePeriod: _removeClassPeriod,
                          subjectEntries: _classSubjectEntries,
                          onAddSubjectEntry: () => setState(() =>
                              _classSubjectEntries
                                  .add(_SubjectScheduleEntry())),
                          onRemoveSubjectEntry: (i) => setState(
                                  () => _classSubjectEntries.removeAt(i)),
                          onGenerate: _generateClassTimetable,
                          timetable: _classTimetable,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sections toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Has Sections?',
                        style: Theme.of(context).textTheme.titleMedium),
                    Switch(
                      value: _hasSections,
                      onChanged: (val) {
                        setState(() {
                          _hasSections = val;
                          if (!val) {
                            for (var c in _sectionSubjectControllers) {
                              c.dispose();
                            }
                            _sectionSubjectControllers.clear();
                            for (var d in _sectionTimetables) {
                              d.dispose();
                            }
                            _sectionTimetables.clear();
                            _sections.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            );

            final sectionsSection = _hasSections
                ? _buildSectionsList()
                : const SizedBox.shrink();

            final saveButton = Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveClass,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : Text(
                  widget.existingClass == null
                      ? 'Save Class'
                      : 'Update Class',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );

            if (isDesktop) {
              // Desktop layout: two columns, scrollable independently
              return Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: classInfoSection,
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: sectionsSection,
                          ),
                        ),
                      ],
                    ),
                  ),
                  saveButton,
                ],
              );
            } else {
              // Mobile layout: single scrollable column
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    classInfoSection,
                    sectionsSection,
                    const SizedBox(height: 16),
                    saveButton,
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}