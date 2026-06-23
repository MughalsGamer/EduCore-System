//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/class_model.dart';
// import '../../providers/class_provider.dart';
//
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
//   // ---------- Class subjects ----------
//   final TextEditingController _classSubjectInputController = TextEditingController();
//   List<String> _classSubjects = [];
//
//   // ---------- Simplified timetable ----------
//   final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
//   List<String> _selectedDays = [];
//   final TextEditingController _classStartTimeController = TextEditingController(text: '08:00');
//   final TextEditingController _classEndTimeController = TextEditingController(text: '14:00');
//   final TextEditingController _lunchStartTimeController = TextEditingController(text: '11:30');
//   final TextEditingController _lunchEndTimeController = TextEditingController(text: '12:30');
//
//   List<TimetableDay> _classTimetable = [];
//   bool _showAdvancedTimetable = false;
//
//   // ---------- Sections ----------
//   List<Section> _sections = [];
//   List<TextEditingController> _sectionSubjectControllers = [];
//   bool _hasSections = false;
//   bool _isSaving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     final existing = widget.existingClass;
//
//     _classNameController = TextEditingController(text: existing?.name ?? '');
//     _headOfClassTeacherController = TextEditingController(
//         text: existing?.headOfClassTeacher ?? '');
//     _monthlyFeeController = TextEditingController(
//         text: existing?.monthlyFee?.toString() ?? '');
//
//     _classSubjects = existing?.subjects ?? [];
//
//     // If existing class has timetable, try to extract simplified times
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
//       // Attempt to pre-fill the simplified form from existing data
//       _selectedDays = _classTimetable.map((d) => d.day).toList();
//       if (_classTimetable.isNotEmpty) {
//         final firstDay = _classTimetable.first;
//         if (firstDay.periods.isNotEmpty) {
//           _classStartTimeController.text = firstDay.periods.first.startTime;
//           _classEndTimeController.text = firstDay.periods.last.endTime;
//         }
//         // Find lunch break
//         for (var period in firstDay.periods) {
//           if (period.isLunchBreak) {
//             _lunchStartTimeController.text = period.startTime;
//             _lunchEndTimeController.text = period.endTime;
//             break;
//           }
//         }
//       }
//     }
//
//     // Sections deep copy
//     _sections = existing?.sections ?? [];
//     _sectionSubjectControllers = List.generate(
//         _sections.length, (_) => TextEditingController());
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
//     for (var c in _sectionSubjectControllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   // ---------- Generate timetable ----------
//   void _generateTimetable() {
//     if (_selectedDays.isEmpty ||
//         _classStartTimeController.text.isEmpty ||
//         _classEndTimeController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select days and enter start/end times')),
//       );
//       return;
//     }
//
//     final start = _classStartTimeController.text;
//     final end = _classEndTimeController.text;
//     final lunchStart = _lunchStartTimeController.text;
//     final lunchEnd = _lunchEndTimeController.text;
//
//     setState(() {
//       _classTimetable = _selectedDays.map((day) {
//         List<TimetablePeriod> periods = [];
//
//         // Morning period (before lunch)
//         if (lunchStart.isNotEmpty && lunchStart != start) {
//           periods.add(TimetablePeriod(
//             startTime: start,
//             endTime: lunchStart,
//             subject: '', // leave empty, user can edit later
//           ));
//         }
//
//         // Lunch break
//         if (lunchStart.isNotEmpty && lunchEnd.isNotEmpty) {
//           periods.add(TimetablePeriod(
//             startTime: lunchStart,
//             endTime: lunchEnd,
//             isLunchBreak: true,
//             subject: 'Lunch',
//           ));
//         }
//
//         // Afternoon period (after lunch)
//         if (lunchEnd.isNotEmpty && lunchEnd != end) {
//           periods.add(TimetablePeriod(
//             startTime: lunchEnd,
//             endTime: end,
//             subject: '',
//           ));
//         }
//
//         // If no lunch break defined, just one full period
//         if (periods.isEmpty) {
//           periods.add(TimetablePeriod(startTime: start, endTime: end, subject: ''));
//         }
//
//         return TimetableDay(day: day, periods: periods);
//       }).toList();
//     });
//   }
//
//   // ---------- Class subjects ----------
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
//   void _removeClassSubject(int index) {
//     setState(() {
//       _classSubjects.removeAt(index);
//     });
//   }
//
//   // ---------- Section subjects ----------
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
//   void _removeSectionSubject(int sectionIndex, int subjectIndex) {
//     setState(() {
//       _sections[sectionIndex].subjects!.removeAt(subjectIndex);
//     });
//   }
//
//   // ---------- Save ----------
//   Future<void> _saveClass() async {
//     if (!_formKey.currentState!.validate()) return;
//
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
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//
//   // ---------- Timetable helpers (for advanced editing) ----------
//   void _addClassTimetableDay() {
//     setState(() {
//       _classTimetable.add(TimetableDay(day: 'Monday', periods: []));
//     });
//   }
//
//   void _removeClassTimetableDay(int index) {
//     setState(() {
//       _classTimetable.removeAt(index);
//     });
//   }
//
//   void _addClassPeriod(int dayIndex) {
//     setState(() {
//       _classTimetable[dayIndex].periods.add(
//         TimetablePeriod(startTime: '09:00', endTime: '09:45'),
//       );
//     });
//   }
//
//   void _removeClassPeriod(int dayIndex, int periodIndex) {
//     setState(() {
//       _classTimetable[dayIndex].periods.removeAt(periodIndex);
//     });
//   }
//
//   // ---------- Section helpers ----------
//   void _addSection() {
//     setState(() {
//       _sections.add(Section(sectionName: ''));
//       _sectionSubjectControllers.add(TextEditingController());
//     });
//   }
//
//   void _removeSection(int index) {
//     setState(() {
//       _sections.removeAt(index);
//       _sectionSubjectControllers[index].dispose();
//       _sectionSubjectControllers.removeAt(index);
//     });
//   }
//
//   void _addSectionTimetableDay(int sectionIndex) {
//     setState(() {
//       _sections[sectionIndex].timetable ??= [];
//       _sections[sectionIndex].timetable!.add(
//         TimetableDay(day: 'Monday', periods: []),
//       );
//     });
//   }
//
//   void _removeSectionTimetableDay(int sectionIndex, int dayIndex) {
//     setState(() {
//       _sections[sectionIndex].timetable!.removeAt(dayIndex);
//     });
//   }
//
//   void _addSectionPeriod(int sectionIndex, int dayIndex) {
//     setState(() {
//       _sections[sectionIndex]
//           .timetable![dayIndex]
//           .periods
//           .add(TimetablePeriod(startTime: '09:00', endTime: '09:45'));
//     });
//   }
//
//   void _removeSectionPeriod(int sectionIndex, int dayIndex, int periodIndex) {
//     setState(() {
//       _sections[sectionIndex]
//           .timetable![dayIndex]
//           .periods
//           .removeAt(periodIndex);
//     });
//   }
//
//   // ---------- Shared timetable card builder (for advanced) ----------
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
//                           labelText: 'Day',
//                           border: OutlineInputBorder(),
//                           isDense: true,
//                         ),
//                         items: _weekdays
//                             .map((d) => DropdownMenuItem(value: d, child: Text(d)))
//                             .toList(),
//                         onChanged: (val) => day.day = val!,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: () => onRemoveDay(dayIndex),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 ...day.periods.asMap().entries.map((periodEntry) {
//                   final pIndex = periodEntry.key;
//                   final period = periodEntry.value;
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 2,
//                           child: TextFormField(
//                             initialValue: period.subject,
//                             decoration: const InputDecoration(
//                               labelText: 'Subject',
//                               border: OutlineInputBorder(),
//                               isDense: true,
//                             ),
//                             onChanged: (v) => period.subject = v,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             initialValue: period.startTime,
//                             decoration: const InputDecoration(
//                               labelText: 'Start',
//                               border: OutlineInputBorder(),
//                               isDense: true,
//                             ),
//                             onChanged: (v) => period.startTime = v,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             initialValue: period.endTime,
//                             decoration: const InputDecoration(
//                               labelText: 'End',
//                               border: OutlineInputBorder(),
//                               isDense: true,
//                             ),
//                             onChanged: (v) => period.endTime = v,
//                           ),
//                         ),
//                         Column(
//                           children: [
//                             Checkbox(
//                               value: period.isLunchBreak,
//                               onChanged: (val) {
//                                 setState(() => period.isLunchBreak = val ?? false);
//                               },
//                             ),
//                             const Text('Lunch', style: TextStyle(fontSize: 10)),
//                           ],
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
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
//   // ---------- Subjects chips widget ----------
//   Widget _buildSubjectsChips(List<String> subjects, Function(int) onDelete) {
//     if (subjects.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.only(top: 6),
//       child: Wrap(
//         spacing: 6,
//         runSpacing: 4,
//         children: subjects.asMap().entries.map((entry) {
//           final idx = entry.key;
//           final subject = entry.value;
//           return Chip(
//             label: Text(subject),
//             deleteIcon: const Icon(Icons.close, size: 18),
//             onDeleted: () => onDelete(idx),
//             backgroundColor: Colors.blue.shade50,
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   // ---------- Preview of generated days ----------
//   Widget _buildGeneratedDaysPreview() {
//     if (_classTimetable.isEmpty) return const SizedBox.shrink();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 12),
//         Text('Timetable Preview', style: Theme.of(context).textTheme.titleSmall),
//         const SizedBox(height: 8),
//         ..._classTimetable.map((day) => ListTile(
//           dense: true,
//           leading: const Icon(Icons.today),
//           title: Text(day.day),
//           subtitle: Text(
//             day.periods.map((p) {
//               if (p.isLunchBreak) return '🍽 ${p.startTime} - ${p.endTime} (Lunch)';
//               return '📚 ${p.startTime} - ${p.endTime}';
//             }).join(' | '),
//             style: const TextStyle(fontSize: 13),
//           ),
//         )),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.existingClass == null ? 'Add Class' : 'Edit Class'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             // Class Name
//             TextFormField(
//               controller: _classNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Class Name',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.class_),
//               ),
//               validator: (v) => v == null || v.trim().isEmpty ? 'Enter class name' : null,
//             ),
//             const SizedBox(height: 16),
//
//             // Head of Class Teacher
//             TextFormField(
//               controller: _headOfClassTeacherController,
//               decoration: const InputDecoration(
//                 labelText: 'Head of Class Teacher',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.person),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Monthly Fee
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
//             // Class Subjects
//             Text('Class Subjects', style: Theme.of(context).textTheme.titleMedium),
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
//             // ========== NEW: SIMPLIFIED CLASS TIMETABLE ==========
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Class Schedule', style: Theme.of(context).textTheme.titleMedium),
//                     const SizedBox(height: 12),
//
//                     // Select days
//                     Text('Select Days:', style: Theme.of(context).textTheme.labelLarge),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       children: _weekdays.map((day) => FilterChip(
//                         label: Text(day),
//                         selected: _selectedDays.contains(day),
//                         onSelected: (selected) {
//                           setState(() {
//                             if (selected) {
//                               _selectedDays.add(day);
//                             } else {
//                               _selectedDays.remove(day);
//                             }
//                           });
//                         },
//                       )).toList(),
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Times
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             controller: _classStartTimeController,
//                             decoration: const InputDecoration(
//                               labelText: 'Class Start',
//                               border: OutlineInputBorder(),
//                               hintText: '08:00',
//                               isDense: true,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextFormField(
//                             controller: _classEndTimeController,
//                             decoration: const InputDecoration(
//                               labelText: 'Class End',
//                               border: OutlineInputBorder(),
//                               hintText: '14:00',
//                               isDense: true,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             controller: _lunchStartTimeController,
//                             decoration: const InputDecoration(
//                               labelText: 'Lunch Start',
//                               border: OutlineInputBorder(),
//                               hintText: '11:30',
//                               isDense: true,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextFormField(
//                             controller: _lunchEndTimeController,
//                             decoration: const InputDecoration(
//                               labelText: 'Lunch End',
//                               border: OutlineInputBorder(),
//                               hintText: '12:30',
//                               isDense: true,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Generate button
//                     ElevatedButton.icon(
//                       onPressed: _generateTimetable,
//                       icon: const Icon(Icons.refresh),
//                       label: const Text('Generate Timetable'),
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size(double.infinity, 40),
//                       ),
//                     ),
//
//                     // Preview of generated days
//                     _buildGeneratedDaysPreview(),
//
//                     // Advanced editing
//                     const SizedBox(height: 12),
//                     InkWell(
//                       onTap: () => setState(() => _showAdvancedTimetable = !_showAdvancedTimetable),
//                       child: Row(
//                         children: [
//                           Icon(
//                             _showAdvancedTimetable ? Icons.expand_less : Icons.expand_more,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Advanced: Customize Periods',
//                             style: Theme.of(context).textTheme.labelMedium,
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (_showAdvancedTimetable) ...[
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton.icon(
//                             onPressed: _addClassTimetableDay,
//                             icon: const Icon(Icons.add, size: 18),
//                             label: const Text('Add Day'),
//                           ),
//                         ],
//                       ),
//                       _buildTimetableCard(
//                         _classTimetable,
//                         _removeClassTimetableDay,
//                         _addClassPeriod,
//                         _removeClassPeriod,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Sections Toggle
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Has Sections?', style: Theme.of(context).textTheme.titleMedium),
//                 Switch(
//                   value: _hasSections,
//                   onChanged: (val) {
//                     setState(() {
//                       _hasSections = val;
//                       if (!val) {
//                         _sections.clear();
//                         for (var c in _sectionSubjectControllers) {
//                           c.dispose();
//                         }
//                         _sectionSubjectControllers.clear();
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),
//
//             // Sections
//             if (_hasSections) ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Sections', style: Theme.of(context).textTheme.titleMedium),
//                   ElevatedButton.icon(
//                     onPressed: _addSection,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add Section'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               ...List.generate(_sections.length, (sectionIndex) {
//                 final section = _sections[sectionIndex];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
//                                 onChanged: (val) => section.sectionName = val,
//                                 validator: (v) =>
//                                 v == null || v.trim().isEmpty ? 'Enter section name' : null,
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () => _removeSection(sectionIndex),
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
//                           onChanged: (val) => section.monthlyFee = double.tryParse(val),
//                         ),
//                         const SizedBox(height: 12),
//                         Text('Subjects', style: Theme.of(context).textTheme.labelLarge),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: _sectionSubjectControllers[sectionIndex],
//                                 decoration: const InputDecoration(
//                                   hintText: 'Add subject',
//                                   border: OutlineInputBorder(),
//                                   isDense: true,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             IconButton(
//                               onPressed: () => _addSectionSubject(sectionIndex),
//                               icon: const Icon(Icons.save, color: Colors.blue),
//                               tooltip: 'Add Subject',
//                             ),
//                           ],
//                         ),
//                         _buildSubjectsChips(
//                           section.subjects ?? [],
//                               (subjectIndex) => _removeSectionSubject(sectionIndex, subjectIndex),
//                         ),
//                         const SizedBox(height: 12),
//                         Text('Section Timetable', style: Theme.of(context).textTheme.labelLarge),
//                         if (section.timetable != null)
//                           _buildTimetableCard(
//                             section.timetable!,
//                                 (dayIndex) => _removeSectionTimetableDay(sectionIndex, dayIndex),
//                                 (dayIndex) => _addSectionPeriod(sectionIndex, dayIndex),
//                                 (dayIndex, periodIndex) =>
//                                 _removeSectionPeriod(sectionIndex, dayIndex, periodIndex),
//                           ),
//                         TextButton.icon(
//                           onPressed: () => _addSectionTimetableDay(sectionIndex),
//                           icon: const Icon(Icons.add_circle_outline),
//                           label: const Text('Add Day to Section Timetable'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ],
//             const SizedBox(height: 32),
//
//             // Save Button
//             ElevatedButton(
//               onPressed: _isSaving ? null : _saveClass,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 backgroundColor: Theme.of(context).primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: _isSaving
//                   ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//               )
//                   : Text(
//                 widget.existingClass == null ? 'Save Class' : 'Update Class',
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  // ---------- Class subjects ----------
  final TextEditingController _classSubjectInputController = TextEditingController();
  List<String> _classSubjects = [];

  // ---------- Simplified class timetable ----------
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  List<String> _selectedDays = [];
  final TextEditingController _classStartTimeController = TextEditingController(text: '08:00');
  final TextEditingController _classEndTimeController = TextEditingController(text: '14:00');
  final TextEditingController _lunchStartTimeController = TextEditingController(text: '11:30');
  final TextEditingController _lunchEndTimeController = TextEditingController(text: '12:30');
  bool _hasLunchBreak = true;   // ← lunch on/off toggle
  List<TimetableDay> _classTimetable = [];
  bool _showAdvancedClassTimetable = false;

  // ---------- Sections ----------
  List<Section> _sections = [];
  List<TextEditingController> _sectionSubjectControllers = [];

  // Section timetable state (one per section)
  final List<_SectionTimetableData> _sectionTimetables = [];

  bool _hasSections = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingClass;

    _classNameController = TextEditingController(text: existing?.name ?? '');
    _headOfClassTeacherController = TextEditingController(
        text: existing?.headOfClassTeacher ?? '');
    _monthlyFeeController = TextEditingController(
        text: existing?.monthlyFee?.toString() ?? '');

    _classSubjects = existing?.subjects ?? [];

    // Pre-fill class timetable if existing
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

      _selectedDays = _classTimetable.map((d) => d.day).toList();
      if (_classTimetable.isNotEmpty) {
        final firstDay = _classTimetable.first;
        if (firstDay.periods.isNotEmpty) {
          _classStartTimeController.text = firstDay.periods.first.startTime;
          _classEndTimeController.text = firstDay.periods.last.endTime;
        }
        // Detect lunch break
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

    // Sections
    _sections = existing?.sections ?? [];
    _sectionSubjectControllers = List.generate(
        _sections.length, (_) => TextEditingController());

    // Build section timetable state objects from existing data
    for (int i = 0; i < _sections.length; i++) {
      final sec = _sections[i];
      final data = _SectionTimetableData();
      if (sec.timetable != null && sec.timetable!.isNotEmpty) {
        data.selectedDays = sec.timetable!.map((d) => d.day).toList();
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
    _classNameController.dispose();
    _headOfClassTeacherController.dispose();
    _monthlyFeeController.dispose();
    _classSubjectInputController.dispose();
    _classStartTimeController.dispose();
    _classEndTimeController.dispose();
    _lunchStartTimeController.dispose();
    _lunchEndTimeController.dispose();
    for (var c in _sectionSubjectControllers) {
      c.dispose();
    }
    for (var d in _sectionTimetables) {
      d.dispose();
    }
    super.dispose();
  }

  // ---------- Generate class timetable ----------
  void _generateClassTimetable() {
    if (_selectedDays.isEmpty ||
        _classStartTimeController.text.isEmpty ||
        _classEndTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select days and enter start/end times')),
      );
      return;
    }

    final start = _classStartTimeController.text;
    final end = _classEndTimeController.text;
    final lunchStart = _lunchStartTimeController.text;
    final lunchEnd = _lunchEndTimeController.text;

    setState(() {
      _classTimetable = _selectedDays.map((day) {
        List<TimetablePeriod> periods = [];

        if (_hasLunchBreak && lunchStart.isNotEmpty && lunchEnd.isNotEmpty) {
          // Morning period (before lunch)
          if (lunchStart != start) {
            periods.add(TimetablePeriod(
              startTime: start,
              endTime: lunchStart,
              subject: '',
            ));
          }
          // Lunch break
          periods.add(TimetablePeriod(
            startTime: lunchStart,
            endTime: lunchEnd,
            isLunchBreak: true,
            subject: 'Lunch',
          ));
          // Afternoon period (after lunch)
          if (lunchEnd != end) {
            periods.add(TimetablePeriod(
              startTime: lunchEnd,
              endTime: end,
              subject: '',
            ));
          }
        } else {
          // No lunch – one full period
          periods.add(TimetablePeriod(startTime: start, endTime: end, subject: ''));
        }

        return TimetableDay(day: day, periods: periods);
      }).toList();
    });
  }

  // ---------- Generate section timetable ----------
  void _generateSectionTimetable(int sectionIndex) {
    final data = _sectionTimetables[sectionIndex];
    if (data.selectedDays.isEmpty ||
        data.startController.text.isEmpty ||
        data.endController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select days and enter start/end times')),
      );
      return;
    }

    final start = data.startController.text;
    final end = data.endController.text;
    final lunchStart = data.lunchStartController.text;
    final lunchEnd = data.lunchEndController.text;

    setState(() {
      final timetable = data.selectedDays.map((day) {
        List<TimetablePeriod> periods = [];

        if (data.hasLunchBreak && lunchStart.isNotEmpty && lunchEnd.isNotEmpty) {
          if (lunchStart != start) {
            periods.add(TimetablePeriod(startTime: start, endTime: lunchStart, subject: ''));
          }
          periods.add(TimetablePeriod(
            startTime: lunchStart,
            endTime: lunchEnd,
            isLunchBreak: true,
            subject: 'Lunch',
          ));
          if (lunchEnd != end) {
            periods.add(TimetablePeriod(startTime: lunchEnd, endTime: end, subject: ''));
          }
        } else {
          periods.add(TimetablePeriod(startTime: start, endTime: end, subject: ''));
        }

        return TimetableDay(day: day, periods: periods);
      }).toList();

      _sections[sectionIndex].timetable = timetable;
    });
  }

  // ---------- Class subjects ----------
  void _addClassSubject() {
    final subject = _classSubjectInputController.text.trim();
    if (subject.isNotEmpty) {
      setState(() {
        _classSubjects.add(subject);
        _classSubjectInputController.clear();
      });
    }
  }

  void _removeClassSubject(int index) {
    setState(() => _classSubjects.removeAt(index));
  }

  // ---------- Section subjects ----------
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

  void _removeSectionSubject(int sectionIndex, int subjectIndex) {
    setState(() => _sections[sectionIndex].subjects!.removeAt(subjectIndex));
  }

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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------- Timetable helpers (advanced) ----------
  void _addClassTimetableDay() {
    setState(() => _classTimetable.add(TimetableDay(day: 'Monday', periods: [])));
  }

  void _removeClassTimetableDay(int index) {
    setState(() => _classTimetable.removeAt(index));
  }

  void _addClassPeriod(int dayIndex) {
    setState(() {
      _classTimetable[dayIndex].periods.add(
        TimetablePeriod(startTime: '09:00', endTime: '09:45'),
      );
    });
  }

  void _removeClassPeriod(int dayIndex, int periodIndex) {
    setState(() => _classTimetable[dayIndex].periods.removeAt(periodIndex));
  }

  // ---------- Section helpers ----------
  void _addSection() {
    setState(() {
      _sections.add(Section(sectionName: ''));
      _sectionSubjectControllers.add(TextEditingController());
      _sectionTimetables.add(_SectionTimetableData());
    });
  }

  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
      _sectionSubjectControllers[index].dispose();
      _sectionSubjectControllers.removeAt(index);
      _sectionTimetables[index].dispose();
      _sectionTimetables.removeAt(index);
    });
  }

  void _addSectionTimetableDay(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].timetable ??= [];
      _sections[sectionIndex].timetable!.add(
        TimetableDay(day: 'Monday', periods: []),
      );
    });
  }

  void _removeSectionTimetableDay(int sectionIndex, int dayIndex) {
    setState(() {
      _sections[sectionIndex].timetable!.removeAt(dayIndex);
    });
  }

  void _addSectionPeriod(int sectionIndex, int dayIndex) {
    setState(() {
      _sections[sectionIndex]
          .timetable![dayIndex]
          .periods
          .add(TimetablePeriod(startTime: '09:00', endTime: '09:45'));
    });
  }

  void _removeSectionPeriod(int sectionIndex, int dayIndex, int periodIndex) {
    setState(() {
      _sections[sectionIndex]
          .timetable![dayIndex]
          .periods
          .removeAt(periodIndex);
    });
  }

  // ---------- Timetable card builder (advanced) ----------
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
                          isDense: true,
                        ),
                        items: _weekdays
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) => day.day = val!,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => onRemoveDay(dayIndex),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...day.periods.asMap().entries.map((periodEntry) {
                  final pIndex = periodEntry.key;
                  final period = periodEntry.value;
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
                              isDense: true,
                            ),
                            onChanged: (v) => period.subject = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: period.startTime,
                            decoration: const InputDecoration(
                              labelText: 'Start',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) => period.startTime = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: period.endTime,
                            decoration: const InputDecoration(
                              labelText: 'End',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) => period.endTime = v,
                          ),
                        ),
                        Column(
                          children: [
                            Checkbox(
                              value: period.isLunchBreak,
                              onChanged: (val) {
                                setState(() => period.isLunchBreak = val ?? false);
                              },
                            ),
                            const Text('Lunch', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
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

  // ---------- Subjects chips ----------
  Widget _buildSubjectsChips(List<String> subjects, Function(int) onDelete) {
    if (subjects.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: subjects.asMap().entries.map((entry) {
          final idx = entry.key;
          final subject = entry.value;
          return Chip(
            label: Text(subject),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => onDelete(idx),
            backgroundColor: Colors.blue.shade50,
          );
        }).toList(),
      ),
    );
  }

  // ---------- Preview widget ----------
  Widget _buildTimetablePreview(List<TimetableDay> timetable) {
    if (timetable.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Timetable Preview', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...timetable.map((day) => ListTile(
          dense: true,
          leading: const Icon(Icons.today),
          title: Text(day.day),
          subtitle: Text(
            day.periods.map((p) {
              if (p.isLunchBreak) return '🍽 ${p.startTime} - ${p.endTime} (Lunch)';
              return '📚 ${p.startTime} - ${p.endTime}';
            }).join(' | '),
            style: const TextStyle(fontSize: 13),
          ),
        )),
      ],
    );
  }

  // ---------- Simplified schedule card (reusable) ----------
  Widget _buildScheduleCard({
    required List<String> selectedDays,
    required TextEditingController startController,
    required TextEditingController endController,
    required TextEditingController lunchStartController,
    required TextEditingController lunchEndController,
    required bool hasLunchBreak,
    required ValueChanged<bool> onLunchToggle,
    required VoidCallback onGenerate,
    required List<TimetableDay> timetable,
    required VoidCallback? onAddDay,
    required Function(int) onRemoveDay,
    required Function(int) onAddPeriod,
    required Function(int, int) onRemovePeriod,
    required bool showAdvanced,
    required VoidCallback onToggleAdvanced,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Days:', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _weekdays.map((day) => FilterChip(
            label: Text(day),
            selected: selectedDays.contains(day),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedDays.add(day);
                } else {
                  selectedDays.remove(day);
                }
              });
            },
          )).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: startController,
                decoration: const InputDecoration(
                  labelText: 'Class Start',
                  border: OutlineInputBorder(),
                  hintText: '08:00',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: endController,
                decoration: const InputDecoration(
                  labelText: 'Class End',
                  border: OutlineInputBorder(),
                  hintText: '14:00',
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('Lunch Break', style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Switch(
              value: hasLunchBreak,
              onChanged: (val) {
                setState(() => onLunchToggle(val));
              },
            ),
          ],
        ),
        if (hasLunchBreak) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: lunchStartController,
                  decoration: const InputDecoration(
                    labelText: 'Lunch Start',
                    border: OutlineInputBorder(),
                    hintText: '11:30',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: lunchEndController,
                  decoration: const InputDecoration(
                    labelText: 'Lunch End',
                    border: OutlineInputBorder(),
                    hintText: '12:30',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onGenerate,
          icon: const Icon(Icons.refresh),
          label: const Text('Generate Timetable'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
        _buildTimetablePreview(timetable),
        const SizedBox(height: 12),
        InkWell(
          onTap: onToggleAdvanced,
          child: Row(
            children: [
              Icon(
                showAdvanced ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text('Advanced: Customize Periods',
                  style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
        if (showAdvanced) ...[
          const SizedBox(height: 8),
          if (onAddDay != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onAddDay,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Day'),
                ),
              ],
            ),
          _buildTimetableCard(timetable, onRemoveDay, onAddPeriod, onRemovePeriod),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingClass == null ? 'Add Class' : 'Edit Class'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Class Name
            TextFormField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.class_),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter class name' : null,
            ),
            const SizedBox(height: 16),
            // Head of Class Teacher
            TextFormField(
              controller: _headOfClassTeacherController,
              decoration: const InputDecoration(
                labelText: 'Head of Class Teacher',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            // Monthly Fee
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
            // Class Subjects
            Text('Class Subjects', style: Theme.of(context).textTheme.titleMedium),
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

            // ========== CLASS SCHEDULE ==========
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Class Schedule', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildScheduleCard(
                      selectedDays: _selectedDays,
                      startController: _classStartTimeController,
                      endController: _classEndTimeController,
                      lunchStartController: _lunchStartTimeController,
                      lunchEndController: _lunchEndTimeController,
                      hasLunchBreak: _hasLunchBreak,
                      onLunchToggle: (val) => _hasLunchBreak = val,
                      onGenerate: _generateClassTimetable,
                      timetable: _classTimetable,
                      onAddDay: _addClassTimetableDay,
                      onRemoveDay: _removeClassTimetableDay,
                      onAddPeriod: _addClassPeriod,
                      onRemovePeriod: _removeClassPeriod,
                      showAdvanced: _showAdvancedClassTimetable,
                      onToggleAdvanced: () => setState(() => _showAdvancedClassTimetable = !_showAdvancedClassTimetable),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sections Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Has Sections?', style: Theme.of(context).textTheme.titleMedium),
                Switch(
                  value: _hasSections,
                  onChanged: (val) {
                    setState(() {
                      _hasSections = val;
                      if (!val) {
                        for (var c in _sectionSubjectControllers) { c.dispose(); }
                        _sectionSubjectControllers.clear();
                        for (var d in _sectionTimetables) { d.dispose(); }
                        _sectionTimetables.clear();
                        _sections.clear();
                      }
                    });
                  },
                ),
              ],
            ),

            // Sections
            if (_hasSections) ...[
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
              ...List.generate(_sections.length, (sectionIndex) {
                final section = _sections[sectionIndex];
                final timetableData = _sectionTimetables[sectionIndex];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: section.sectionName,
                                decoration: const InputDecoration(
                                  labelText: 'Section Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.group),
                                ),
                                onChanged: (val) => section.sectionName = val,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Enter section name' : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeSection(sectionIndex),
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
                          onChanged: (val) => section.monthlyFee = double.tryParse(val),
                        ),
                        const SizedBox(height: 12),
                        Text('Subjects', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _sectionSubjectControllers[sectionIndex],
                                decoration: const InputDecoration(
                                  hintText: 'Add subject',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _addSectionSubject(sectionIndex),
                              icon: const Icon(Icons.save, color: Colors.blue),
                              tooltip: 'Add Subject',
                            ),
                          ],
                        ),
                        _buildSubjectsChips(
                          section.subjects ?? [],
                              (idx) => _removeSectionSubject(sectionIndex, idx),
                        ),
                        const SizedBox(height: 12),

                        // ---------- Section Timetable (simplified) ----------
                        Text('Section Timetable', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        _buildScheduleCard(
                          selectedDays: timetableData.selectedDays,
                          startController: timetableData.startController,
                          endController: timetableData.endController,
                          lunchStartController: timetableData.lunchStartController,
                          lunchEndController: timetableData.lunchEndController,
                          hasLunchBreak: timetableData.hasLunchBreak,
                          onLunchToggle: (val) => timetableData.hasLunchBreak = val,
                          onGenerate: () => _generateSectionTimetable(sectionIndex),
                          timetable: section.timetable ?? [],
                          onAddDay: () => _addSectionTimetableDay(sectionIndex),
                          onRemoveDay: (dayIndex) => _removeSectionTimetableDay(sectionIndex, dayIndex),
                          onAddPeriod: (dayIndex) => _addSectionPeriod(sectionIndex, dayIndex),
                          onRemovePeriod: (dayIndex, periodIndex) => _removeSectionPeriod(sectionIndex, dayIndex, periodIndex),
                          showAdvanced: timetableData.showAdvanced,
                          onToggleAdvanced: () => setState(() => timetableData.showAdvanced = !timetableData.showAdvanced),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveClass,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Text(
                widget.existingClass == null ? 'Save Class' : 'Update Class',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------- Helper class for per-section timetable state ----------
class _SectionTimetableData {
  List<String> selectedDays = [];
  final TextEditingController startController = TextEditingController(text: '08:00');
  final TextEditingController endController = TextEditingController(text: '14:00');
  final TextEditingController lunchStartController = TextEditingController(text: '11:30');
  final TextEditingController lunchEndController = TextEditingController(text: '12:30');
  bool hasLunchBreak = true;
  bool showAdvanced = false;

  void dispose() {
    startController.dispose();
    endController.dispose();
    lunchStartController.dispose();
    lunchEndController.dispose();
  }
}