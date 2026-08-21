//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../lib/utils/exam_result_card_temp_storage.dart';
// import '../../models/class_model.dart';
// import '../../models/exam_result_card_model.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/exam_result_card_provider.dart';
// import '../../providers/student_provider.dart';
//
// class ExamResultCardFormScreen extends StatefulWidget {
//   final ExamResultCard? card;
//   const ExamResultCardFormScreen({super.key, this.card});
//
//   @override
//   State<ExamResultCardFormScreen> createState() => _ExamResultCardFormScreenState();
// }
//
// class _ExamResultCardFormScreenState extends State<ExamResultCardFormScreen>
//     with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   String _examName = '';
//   DateTime _examDate = DateTime.now();
//   String? _selectedClassId;
//   String? _selectedSectionId;
//
//   List<ExamSubject> _availableSubjects = [];
//   Set<String> _selectedSubjectNames = {};
//   Map<String, int> _totalMarksMap = {};
//
//   Set<String> _selectedStudentIds = {};
//   Map<String, Map<String, double>> _marks = {};
//   String _studentSearch = '';
//
//   int _currentStep = 0;
//   late final PageController _pageController;
//   late final AnimationController _fadeController;
//   bool _isLoading = false;
//   bool _isEditing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _isEditing = widget.card != null;
//     if (_isEditing) {
//       _loadFromCard(widget.card!);
//     } else {
//       _loadDraft();
//     }
//   }
//
//   Future<void> _loadFromCard(ExamResultCard card) async {
//     setState(() {
//       _examName = card.examName;
//       _examDate = card.date;
//       _selectedClassId = card.classId;
//       _selectedSectionId = card.sectionId;
//       _availableSubjects = List.from(card.subjects);
//       _selectedSubjectNames = card.subjects.map((s) => s.name).toSet();
//       _totalMarksMap = {for (var s in card.subjects) s.name: s.totalMarks};
//       for (final sm in card.studentMarks) {
//         _selectedStudentIds.add(sm.studentId);
//         _marks[sm.studentId] = Map.from(sm.obtainedMarks);
//       }
//     });
//     await _loadStudents();
//   }
//
//   Future<void> _loadDraft() async {
//     final draft = await ExamResultCardTempStorage.loadSettings();
//     if (draft != null && mounted) {
//       setState(() {
//         _examName = draft['examName'] as String;
//         _examDate = draft['date'] as DateTime;
//         _selectedClassId = draft['classId'] as String?;
//         _selectedSectionId = draft['sectionId'] as String?;
//         final subjects = (draft['subjects'] as List)
//             .map((e) => ExamSubject.fromMap(e as Map<String, dynamic>))
//             .toList();
//         _availableSubjects = subjects;
//         _selectedSubjectNames = subjects.map((s) => s.name).toSet();
//         _totalMarksMap = {for (var s in subjects) s.name: s.totalMarks};
//       });
//       if (_selectedClassId != null && _selectedSectionId != null) {
//         await _loadStudents();
//       }
//     }
//     _fadeController.forward();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _fadeController.dispose();
//     if (!_isEditing) {
//       ExamResultCardTempStorage.clearSettings();
//     }
//     super.dispose();
//   }
//
//   // ─── Data loading ──────────────────────────────────────────────
//
//   Future<void> _loadSubjectsForSelection() async {
//     if (_selectedClassId == null || _selectedSectionId == null) return;
//     setState(() => _isLoading = true);
//     try {
//       final classProvider = context.read<ClassProvider>();
//       final classModel = classProvider.classes.firstWhere((c) => c.id == _selectedClassId);
//       final section = classModel.sections.firstWhere((s) => s.sectionName == _selectedSectionId);
//       List<SubjectMark> subjects = [];
//       if (section.subjectMarks != null && section.subjectMarks!.isNotEmpty) {
//         subjects = section.subjectMarks!;
//       } else if (classModel.subjects != null && classModel.subjects!.isNotEmpty) {
//         subjects = classModel.subjects!;
//       }
//       setState(() {
//         _availableSubjects = subjects.map((s) => ExamSubject(name: s.name, totalMarks: s.totalMarks)).toList();
//         _selectedSubjectNames = subjects.map((s) => s.name).toSet();
//         _totalMarksMap = {for (var s in subjects) s.name: s.totalMarks};
//       });
//       await _loadStudents();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading subjects: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   bool _isLoadingStudents = false;
//
//   Future<void> _loadStudents() async {
//     if (_selectedClassId == null || _selectedSectionId == null) return;
//
//     setState(() => _isLoadingStudents = true);
//
//     // Wait a bit for StudentProvider to load if it's still loading
//     int retries = 0;
//     while (context.read<StudentProvider>().isLoading && retries < 5) {
//       await Future.delayed(const Duration(milliseconds: 300));
//       retries++;
//     }
//
//     try {
//       final classProvider = context.read<ClassProvider>();
//       final selectedClass = classProvider.classes.firstWhere((c) => c.id == _selectedClassId);
//       final className = selectedClass.name;
//
//       final allActive = context.read<StudentProvider>().allActiveStudents;
//       final filtered = allActive.where((s) =>
//       s.student.className == className &&
//           s.student.sectionName == _selectedSectionId).toList();
//
//       setState(() {
//         _selectedStudentIds = filtered.map((s) => s.student.studentId).toSet();
//         _marks = {};
//         for (final s in filtered) {
//           final sid = s.student.studentId;
//           _marks[sid] = {};
//           for (final subj in _selectedSubjects) {
//             _marks[sid]![subj.name] = 0.0;
//           }
//         }
//       });
//     } catch (e) {
//       // If no class found, just clear
//       setState(() {
//         _selectedStudentIds.clear();
//         _marks.clear();
//       });
//     } finally {
//       setState(() => _isLoadingStudents = false);
//     }
//   }
//   Future<void> _saveDraft() async {
//     if (_selectedClassId == null || _selectedSectionId == null) return;
//     final classProvider = context.read<ClassProvider>();
//     final className = classProvider.classes.firstWhere((c) => c.id == _selectedClassId).name;
//     await ExamResultCardTempStorage.saveSettings(
//       examName: _examName,
//       date: _examDate,
//       classId: _selectedClassId!,
//       className: className,
//       sectionId: _selectedSectionId!,
//       sectionName: _selectedSectionId!,
//       subjects: _selectedSubjects.map((s) => s.toMap()).toList(),
//     );
//   }
//
//   // ─── Step navigation ──────────────────────────────────────────
//
//   void _nextStep() {
//     if (_currentStep < 2) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOutCubic,
//       );
//       setState(() => _currentStep++);
//     }
//   }
//
//   void _prevStep() {
//     if (_currentStep > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOutCubic,
//       );
//       setState(() => _currentStep--);
//     }
//   }
//
//   // ─── Generate / Update ──────────────────────────────────────
//
//   Future<void> _generateCard() async {
//     if (_examName.isEmpty ||
//         _selectedClassId == null ||
//         _selectedSectionId == null ||
//         _selectedSubjects.isEmpty ||
//         _selectedStudentIds.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please complete all fields.')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       final studentProvider = context.read<StudentProvider>();
//       final studentMarks = <StudentExamMarks>[];
//       for (final sid in _selectedStudentIds) {
//         final student = studentProvider.students.firstWhere((s) => s.student.studentId == sid);
//         final obtained = Map<String, double>.from(_marks[sid] ?? {});
//         studentMarks.add(StudentExamMarks(
//           studentId: sid,
//           studentName: student.student.name,
//           obtainedMarks: obtained,
//         ));
//       }
//
//       final classProvider = context.read<ClassProvider>();
//       final className = classProvider.classes.firstWhere((c) => c.id == _selectedClassId).name;
//
//       final newCard = ExamResultCard(
//         examName: _examName,
//         date: _examDate,
//         classId: _selectedClassId!,
//         className: className,
//         sectionId: _selectedSectionId!,
//         sectionName: _selectedSectionId!,
//         subjects: _selectedSubjects,
//         studentMarks: studentMarks,
//       );
//
//       if (_isEditing) {
//         await context.read<ExamResultCardProvider>().updateCard(widget.card!.id!, newCard);
//       } else {
//         await context.read<ExamResultCardProvider>().addCard(newCard);
//       }
//
//       await _saveDraft();
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(_isEditing ? 'Card updated!' : 'Card generated!')),
//         );
//         setState(() {
//           _selectedStudentIds.clear();
//           _marks.clear();
//           _studentSearch = '';
//           _currentStep = 0;
//           _pageController.jumpToPage(0);
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ─── Build ──────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     final isWeb = MediaQuery.of(context).size.width > 800;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: Text(_isEditing ? 'Edit Result Card' : 'New Result Card'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         centerTitle: false,
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final maxWidth = isWeb ? 800.0 : constraints.maxWidth;
//           return Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: maxWidth),
//               child: Column(
//                 children: [
//                   _buildStepIndicator(),
//                   Expanded(
//                     child: PageView(
//                       controller: _pageController,
//                       physics: const NeverScrollableScrollPhysics(),
//                       children: [
//                         _buildStep1(),
//                         _buildStep2(),
//                         _buildStep3(),
//                       ],
//                     ),
//                   ),
//                   _buildNavigationButtons(),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ─── Step Indicator ─────────────────────────────────────────
//
//   Widget _buildStepIndicator() {
//     final labels = ['Details & Subjects', 'Select Students', 'Enter Marks'];
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: List.generate(3, (i) {
//           final isActive = i == _currentStep;
//           final isDone = i < _currentStep;
//           return Expanded(
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         height: 4,
//                         decoration: BoxDecoration(
//                           color: isActive || isDone
//                               ? const Color(0xFF534AB7)
//                               : Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                     ),
//                     if (i == 2) const SizedBox(width: 0),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   labels[i],
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                     color: isActive ? const Color(0xFF534AB7) : Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
//
//   // ─── Step 1 ─────────────────────────────────────────────────
//
//   Widget _buildStep1() {
//     final classProvider = context.watch<ClassProvider>();
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: FadeTransition(
//         opacity: _fadeController,
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Exam Details', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 16),
//               TextFormField(
//                 initialValue: _examName,
//                 decoration: const InputDecoration(
//                   labelText: 'Test / Exam Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 onChanged: (v) {
//                   _examName = v;
//                   _saveDraft();
//                 },
//               ),
//               const SizedBox(height: 16),
//               InkWell(
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: _examDate,
//                     firstDate: DateTime(2020),
//                     lastDate: DateTime(2100),
//                   );
//                   if (picked != null) {
//                     setState(() => _examDate = picked);
//                     _saveDraft();
//                   }
//                 },
//                 child: InputDecorator(
//                   decoration: const InputDecoration(
//                     labelText: 'Date',
//                     border: OutlineInputBorder(),
//                   ),
//                   child: Text(DateFormat('dd MMMM yyyy').format(_examDate)),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text('Class & Section', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 8),
//
//               // ── Class Dropdown ──
//               if (classProvider.isLoading)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   child: Center(child: CircularProgressIndicator()),
//                 )
//               else if (classProvider.error != null)
//                 Column(
//                   children: [
//                     Text(
//                       'Error loading classes: ${classProvider.error}',
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => classProvider.loadClasses(),
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 )
//               else if (classProvider.classes.isEmpty)
//                   const Padding(
//                     padding: EdgeInsets.symmetric(vertical: 12),
//                     child: Text('No classes found. Please add a class first.'),
//                   )
//                 else
//                   DropdownButtonFormField<String>(
//                     value: _selectedClassId,
//                     decoration: const InputDecoration(
//                       labelText: 'Class',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: classProvider.classes.map((c) {
//                       return DropdownMenuItem(value: c.id, child: Text(c.name));
//                     }).toList(),
//                     onChanged: (v) {
//                       setState(() {
//                         _selectedClassId = v;
//                         _selectedSectionId = null;
//                         _availableSubjects.clear();
//                         _selectedSubjectNames.clear();
//                       });
//                       _saveDraft();
//                     },
//                   ),
//
//               const SizedBox(height: 12),
//
//               // ── Section Dropdown ──
//               if (_selectedClassId != null)
//                 Builder(
//                   builder: (context) {
//                     final selectedClass = classProvider.classes
//                         .firstWhere((c) => c.id == _selectedClassId);
//                     final sections = selectedClass.sections;
//                     if (sections.isEmpty) {
//                       return const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8),
//                         child: Text('No sections in this class.'),
//                       );
//                     }
//                     return DropdownButtonFormField<String>(
//                       value: _selectedSectionId,
//                       decoration: const InputDecoration(
//                         labelText: 'Section',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: sections.map((s) {
//                         return DropdownMenuItem(
//                           value: s.sectionName,
//                           child: Text(s.sectionName),
//                         );
//                       }).toList(),
//                       onChanged: (v) {
//                         setState(() => _selectedSectionId = v);
//                         _loadSubjectsForSelection();
//                         _saveDraft();
//                       },
//                     );
//                   },
//                 ),
//
//               const SizedBox(height: 24),
//
//               // ── Subjects ──
//               if (_isLoading)
//                 const Center(child: CircularProgressIndicator())
//               else if (_availableSubjects.isNotEmpty) ...[
//                 Text('Subjects', style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 ..._availableSubjects.map((subject) {
//                   final isSelected = _selectedSubjectNames.contains(subject.name);
//                   return Card(
//                     elevation: 0,
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       side: BorderSide(
//                         color: isSelected ? const Color(0xFF534AB7) : Colors.grey.shade300,
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Row(
//                         children: [
//                           Checkbox(
//                             value: isSelected,
//                             onChanged: (v) {
//                               setState(() {
//                                 if (v == true) {
//                                   _selectedSubjectNames.add(subject.name);
//                                   if (!_totalMarksMap.containsKey(subject.name)) {
//                                     _totalMarksMap[subject.name] = subject.totalMarks;
//                                   }
//                                 } else {
//                                   _selectedSubjectNames.remove(subject.name);
//                                 }
//                               });
//                               _saveDraft();
//                             },
//                           ),
//                           Expanded(
//                             child: Text(subject.name,
//                                 style: const TextStyle(fontSize: 16)),
//                           ),
//                           if (isSelected)
//                             SizedBox(
//                               width: 100,
//                               child: TextFormField(
//                                 initialValue: _totalMarksMap[subject.name]
//                                     ?.toString() ?? subject.totalMarks.toString(),
//                                 keyboardType: TextInputType.number,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Total',
//                                   border: OutlineInputBorder(),
//                                   isDense: true,
//                                 ),
//                                 onChanged: (v) {
//                                   final val = int.tryParse(v) ?? subject.totalMarks;
//                                   setState(() {
//                                     _totalMarksMap[subject.name] = val;
//                                   });
//                                   _saveDraft();
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Step 2 ─────────────────────────────────────────────────
//
//   Widget _buildStep2() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text('Select Students',
//               style: Theme.of(context).textTheme.titleLarge),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: TextField(
//             onChanged: (v) => setState(() => _studentSearch = v),
//             decoration: InputDecoration(
//               hintText: 'Search by name, ID, father...',
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none),
//               filled: true,
//               fillColor: Colors.white,
//               isDense: true,
//             ),
//           ),
//         ),
//         Expanded(
//           child: _isLoadingStudents
//               ? const Center(child: CircularProgressIndicator())
//               : _selectedStudentIds.isEmpty
//               ? Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.person_off, size: 48, color: Colors.grey),
//                 const SizedBox(height: 8),
//                 const Text('No students found for this class/section.'),
//                 const SizedBox(height: 8),
//                 ElevatedButton(
//                   onPressed: _loadStudents,
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           )
//               : ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: _selectedStudentIds.length,
//             itemBuilder: (ctx, i) {
//               final sid = _selectedStudentIds.elementAt(i);
//               final student = context
//                   .read<StudentProvider>()
//                   .students
//                   .firstWhere((s) => s.student.studentId == sid);
//               final matchesSearch = _studentSearch.isEmpty ||
//                   student.student.name
//                       .toLowerCase()
//                       .contains(_studentSearch.toLowerCase()) ||
//                   student.fatherName
//                       .toLowerCase()
//                       .contains(_studentSearch.toLowerCase()) ||
//                   student.student.studentId
//                       .toLowerCase()
//                       .contains(_studentSearch.toLowerCase());
//               if (!matchesSearch) return const SizedBox.shrink();
//               return Card(
//                 elevation: 0,
//                 margin: const EdgeInsets.symmetric(vertical: 4),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//                 child: CheckboxListTile(
//                   title: Text(student.student.name,
//                       style: const TextStyle(fontWeight: FontWeight.w500)),
//                   subtitle: Text(
//                       '${student.student.className} - ${student.student.sectionName}'),
//                   value: true,
//                   onChanged: (v) {
//                     setState(() {
//                       if (v == false) {
//                         _selectedStudentIds.remove(sid);
//                         _marks.remove(sid);
//                       } else {
//                         _selectedStudentIds.add(sid);
//                         _marks[sid] = {};
//                         for (final subj in _selectedSubjects) {
//                           _marks[sid]![subj.name] = 0.0;
//                         }
//                       }
//                     });
//                   },
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//   // ─── Step 3 ─────────────────────────────────────────────────
//
//   Widget _buildStep3() {
//     final students = _selectedStudentIds
//         .map((sid) => context.read<StudentProvider>().students
//         .firstWhere((s) => s.student.studentId == sid))
//         .toList();
//
//     if (students.isEmpty) {
//       return const Center(child: Text('No students selected.'));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: DataTable(
//             columnSpacing: 12,
//             headingRowColor: MaterialStateColor.resolveWith(
//                     (states) => Colors.grey.shade100),
//             columns: [
//               const DataColumn(
//                   label: Text('Student',
//                       style: TextStyle(fontWeight: FontWeight.bold))),
//               ..._selectedSubjects.map((s) => DataColumn(
//                   label: Text('${s.name}\n(${s.totalMarks})',
//                       style: const TextStyle(fontWeight: FontWeight.bold)))),
//             ],
//             rows: students.map((student) {
//               final sid = student.student.studentId;
//               return DataRow(cells: [
//                 DataCell(Text(student.student.name,
//                     style: const TextStyle(fontWeight: FontWeight.w500))),
//                 ..._selectedSubjects.map((subj) {
//                   return DataCell(
//                     SizedBox(
//                       width: 80,
//                       child: TextFormField(
//                         initialValue: _marks[sid]?[subj.name]?.toString() ?? '0',
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           isDense: true,
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (v) {
//                           setState(() {
//                             _marks[sid]![subj.name] = double.tryParse(v) ?? 0;
//                           });
//                         },
//                       ),
//                     ),
//                   );
//                 }),
//               ]);
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Navigation Buttons ────────────────────────────────────
//
//   Widget _buildNavigationButtons() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           if (_currentStep > 0)
//             TextButton.icon(
//               onPressed: _prevStep,
//               icon: const Icon(Icons.arrow_back_ios, size: 16),
//               label: const Text('Back'),
//             )
//           else
//             const SizedBox(width: 80),
//           if (_currentStep < 2)
//             ElevatedButton.icon(
//               onPressed: _nextStep,
//               icon: const Icon(Icons.arrow_forward_ios, size: 16),
//               label: const Text('Next'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF534AB7),
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//             )
//           else
//             ElevatedButton.icon(
//               onPressed: _isLoading ? null : _generateCard,
//               icon: _isLoading
//                   ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//                   : const Icon(Icons.save),
//               label: Text(_isEditing ? 'Update Card' : 'Generate Card'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green.shade600,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Helpers ──────────────────────────────────────────────
//
//   List<ExamSubject> get _selectedSubjects {
//     return _availableSubjects
//         .where((s) => _selectedSubjectNames.contains(s.name))
//         .map((s) => ExamSubject(
//       name: s.name,
//       totalMarks: _totalMarksMap[s.name] ?? s.totalMarks,
//     ))
//         .toList();
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/utils/exam_result_card_temp_storage.dart';
import '../../models/class_model.dart';
import '../../models/exam_result_card_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/exam_result_card_provider.dart';
import '../../providers/student_provider.dart';

class ExamResultCardFormScreen extends StatefulWidget {
  final ExamResultCard? card;
  final StudentWithContext? studentContext; // For student‑specific edit

  const ExamResultCardFormScreen({
    super.key,
    this.card,
    this.studentContext,
  });

  @override
  State<ExamResultCardFormScreen> createState() =>
      _ExamResultCardFormScreenState();
}

class _ExamResultCardFormScreenState extends State<ExamResultCardFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _examName = '';
  DateTime _examDate = DateTime.now();
  String? _selectedClassId;
  String? _selectedSectionId;

  List<ExamSubject> _availableSubjects = [];
  Set<String> _selectedSubjectNames = {};
  Map<String, int> _totalMarksMap = {};

  Set<String> _selectedStudentIds = {};
  Map<String, Map<String, double>> _marks = {};
  String _studentSearch = '';

  int _currentStep = 0;
  late final PageController _pageController;
  late final AnimationController _fadeController;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isStudentEdit = false; // true when editing a single student's marks

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _isEditing = widget.card != null;
    _isStudentEdit = widget.studentContext != null;

    if (_isStudentEdit) {
      // Student‑specific edit: load card and restrict to that student
      _loadFromCard(widget.card!, onlyStudent: widget.studentContext!);
    } else if (_isEditing) {
      _loadFromCard(widget.card!);
    } else {
      _loadDraft();
    }
  }

  Future<void> _loadFromCard(ExamResultCard card,
      {StudentWithContext? onlyStudent}) async {
    setState(() {
      _examName = card.examName;
      _examDate = card.date;
      _selectedClassId = card.classId;
      _selectedSectionId = card.sectionId;
      _availableSubjects = List.from(card.subjects);
      _selectedSubjectNames = card.subjects.map((s) => s.name).toSet();
      _totalMarksMap = {for (var s in card.subjects) s.name: s.totalMarks};

      // Load student marks
      if (onlyStudent != null) {
        // Only this student
        final sid = onlyStudent.student.studentId;
        _selectedStudentIds = {sid};
        _marks[sid] = {};
        final sm = card.studentMarks.firstWhere(
                (m) => m.studentId == sid,
            orElse: () => StudentExamMarks(studentId: sid, studentName: ''));
        if (sm.studentId.isNotEmpty) {
          _marks[sid] = Map.from(sm.obtainedMarks);
        } else {
          // If marks missing, init with zeros
          for (final subj in card.subjects) {
            _marks[sid]![subj.name] = 0.0;
          }
        }
      } else {
        // Full card edit
        for (final sm in card.studentMarks) {
          _selectedStudentIds.add(sm.studentId);
          _marks[sm.studentId] = Map.from(sm.obtainedMarks);
        }
      }
    });
    if (onlyStudent == null) {
      await _loadStudents();
    }
    _fadeController.forward();
  }

  Future<void> _loadDraft() async {
    final draft = await ExamResultCardTempStorage.loadSettings();
    if (draft != null && mounted) {
      setState(() {
        _examName = draft['examName'] as String;
        _examDate = draft['date'] as DateTime;
        _selectedClassId = draft['classId'] as String?;
        _selectedSectionId = draft['sectionId'] as String?;
        final subjects = (draft['subjects'] as List)
            .map((e) => ExamSubject.fromMap(e as Map<String, dynamic>))
            .toList();
        _availableSubjects = subjects;
        _selectedSubjectNames = subjects.map((s) => s.name).toSet();
        _totalMarksMap = {for (var s in subjects) s.name: s.totalMarks};
      });
      if (_selectedClassId != null && _selectedSectionId != null) {
        await _loadStudents();
      }
    }
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    if (!_isEditing && !_isStudentEdit) {
      ExamResultCardTempStorage.clearSettings();
    }
    super.dispose();
  }

  // ─── Data loading ──────────────────────────────────────────────

  Future<void> _loadSubjectsForSelection() async {
    if (_selectedClassId == null || _selectedSectionId == null) return;
    setState(() => _isLoading = true);
    try {
      final classProvider = context.read<ClassProvider>();
      final classModel = classProvider.classes
          .firstWhere((c) => c.id == _selectedClassId);
      final section = classModel.sections
          .firstWhere((s) => s.sectionName == _selectedSectionId);
      List<SubjectMark> subjects = [];
      if (section.subjectMarks != null && section.subjectMarks!.isNotEmpty) {
        subjects = section.subjectMarks!;
      } else if (classModel.subjects != null &&
          classModel.subjects!.isNotEmpty) {
        subjects = classModel.subjects!;
      }
      setState(() {
        _availableSubjects = subjects
            .map((s) => ExamSubject(name: s.name, totalMarks: s.totalMarks))
            .toList();
        _selectedSubjectNames = subjects.map((s) => s.name).toSet();
        _totalMarksMap = {for (var s in subjects) s.name: s.totalMarks};
      });
      await _loadStudents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading subjects: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isLoadingStudents = false;

  Future<void> _loadStudents() async {
    if (_selectedClassId == null || _selectedSectionId == null) return;

    setState(() => _isLoadingStudents = true);

    int retries = 0;
    while (context.read<StudentProvider>().isLoading && retries < 5) {
      await Future.delayed(const Duration(milliseconds: 300));
      retries++;
    }

    try {
      final classProvider = context.read<ClassProvider>();
      final selectedClass = classProvider.classes
          .firstWhere((c) => c.id == _selectedClassId);
      final className = selectedClass.name;

      final allActive = context.read<StudentProvider>().allActiveStudents;
      final filtered = allActive
          .where((s) =>
      s.student.className == className &&
          s.student.sectionName == _selectedSectionId)
          .toList();

      setState(() {
        _selectedStudentIds = filtered.map((s) => s.student.studentId).toSet();
        _marks = {};
        for (final s in filtered) {
          final sid = s.student.studentId;
          _marks[sid] = {};
          for (final subj in _selectedSubjects) {
            _marks[sid]![subj.name] = 0.0;
          }
        }
      });
    } catch (e) {
      setState(() {
        _selectedStudentIds.clear();
        _marks.clear();
      });
    } finally {
      setState(() => _isLoadingStudents = false);
    }
  }

  Future<void> _saveDraft() async {
    if (_selectedClassId == null || _selectedSectionId == null) return;
    final classProvider = context.read<ClassProvider>();
    final className = classProvider.classes
        .firstWhere((c) => c.id == _selectedClassId)
        .name;
    await ExamResultCardTempStorage.saveSettings(
      examName: _examName,
      date: _examDate,
      classId: _selectedClassId!,
      className: className,
      sectionId: _selectedSectionId!,
      sectionName: _selectedSectionId!,
      subjects: _selectedSubjects.map((s) => s.toMap()).toList(),
    );
  }

  // ─── Step navigation ──────────────────────────────────────────

  void _nextStep() {
    if (_currentStep < (_isStudentEdit ? 2 : 2)) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep--);
    }
  }

  // ─── Generate / Update ──────────────────────────────────────

  Future<void> _generateCard() async {
    if (_examName.isEmpty ||
        _selectedClassId == null ||
        _selectedSectionId == null ||
        _selectedSubjects.isEmpty ||
        _selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final studentProvider = context.read<StudentProvider>();
      final studentMarks = <StudentExamMarks>[];
      for (final sid in _selectedStudentIds) {
        final student = studentProvider.students
            .firstWhere((s) => s.student.studentId == sid);
        final obtained = Map<String, double>.from(_marks[sid] ?? {});
        studentMarks.add(StudentExamMarks(
          studentId: sid,
          studentName: student.student.name,
          obtainedMarks: obtained,
        ));
      }

      final classProvider = context.read<ClassProvider>();
      final className = classProvider.classes
          .firstWhere((c) => c.id == _selectedClassId)
          .name;

      final newCard = ExamResultCard(
        examName: _examName,
        date: _examDate,
        classId: _selectedClassId!,
        className: className,
        sectionId: _selectedSectionId!,
        sectionName: _selectedSectionId!,
        subjects: _selectedSubjects,
        studentMarks: studentMarks,
      );

      if (_isStudentEdit) {
        // Update only this student's marks
        final studentId = widget.studentContext!.student.studentId;
        final marksMap = _marks[studentId] ?? {};
        await context
            .read<ExamResultCardProvider>()
            .updateStudentMarks(widget.card!.id!, studentId, marksMap);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student marks updated!')),
        );
      } else if (_isEditing) {
        await context
            .read<ExamResultCardProvider>()
            .updateCard(widget.card!.id!, newCard);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card updated!')),
        );
      } else {
        await context.read<ExamResultCardProvider>().addCard(newCard);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card generated!')),
        );
      }

      await _saveDraft();

      if (mounted) {
        setState(() {
          _selectedStudentIds.clear();
          _marks.clear();
          _studentSearch = '';
          _currentStep = 0;
          _pageController.jumpToPage(0);
        });
        Navigator.pop(context); // go back after successful save
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_isStudentEdit
            ? 'Edit Marks for ${widget.studentContext!.student.name}'
            : _isEditing
            ? 'Edit Exam Card'
            : 'New Result Card'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF534AB7)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = isWeb ? 800.0 : constraints.maxWidth;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  if (!_isStudentEdit) _buildStepIndicator(),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _isStudentEdit
                          ? [_buildStep3()] // only marks entry
                          : [
                        _buildStep1(),
                        _buildStep2(),
                        _buildStep3(),
                      ],
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Step Indicator ─────────────────────────────────────────

  Widget _buildStepIndicator() {
    final labels = ['Details & Subjects', 'Select Students', 'Enter Marks'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive || isDone
                              ? const Color(0xFF534AB7)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (i == 2) const SizedBox(width: 0),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color:
                    isActive ? const Color(0xFF534AB7) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Step 1 ─────────────────────────────────────────────────

  Widget _buildStep1() {
    final classProvider = context.watch<ClassProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeController,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Exam Details',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _examName,
                decoration: const InputDecoration(
                  labelText: 'Test / Exam Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  _examName = v;
                  _saveDraft();
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _examDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _examDate = picked);
                    _saveDraft();
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('dd MMMM yyyy').format(_examDate)),
                ),
              ),
              const SizedBox(height: 24),
              Text('Class & Section',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              // ── Class Dropdown ──
              if (classProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (classProvider.error != null)
                Column(
                  children: [
                    Text(
                      'Error loading classes: ${classProvider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () => classProvider.loadClasses(),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else if (classProvider.classes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No classes found. Please add a class first.'),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedClassId,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(),
                    ),
                    items: classProvider.classes.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedClassId = v;
                        _selectedSectionId = null;
                        _availableSubjects.clear();
                        _selectedSubjectNames.clear();
                      });
                      _saveDraft();
                    },
                  ),
              const SizedBox(height: 12),

              // ── Section Dropdown ──
              if (_selectedClassId != null)
                Builder(
                  builder: (context) {
                    final selectedClass = classProvider.classes
                        .firstWhere((c) => c.id == _selectedClassId);
                    final sections = selectedClass.sections;
                    if (sections.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No sections in this class.'),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedSectionId,
                      decoration: const InputDecoration(
                        labelText: 'Section',
                        border: OutlineInputBorder(),
                      ),
                      items: sections.map((s) {
                        return DropdownMenuItem(
                          value: s.sectionName,
                          child: Text(s.sectionName),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => _selectedSectionId = v);
                        _loadSubjectsForSelection();
                        _saveDraft();
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),

              // ── Subjects ──
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_availableSubjects.isNotEmpty) ...[
                Text('Subjects', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._availableSubjects.map((subject) {
                  final isSelected = _selectedSubjectNames.contains(subject.name);
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF534AB7)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedSubjectNames.add(subject.name);
                                  if (!_totalMarksMap.containsKey(
                                      subject.name)) {
                                    _totalMarksMap[subject.name] =
                                        subject.totalMarks;
                                  }
                                } else {
                                  _selectedSubjectNames.remove(subject.name);
                                }
                              });
                              _saveDraft();
                            },
                          ),
                          Expanded(
                            child: Text(subject.name,
                                style: const TextStyle(fontSize: 16)),
                          ),
                          if (isSelected)
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: _totalMarksMap[subject.name]
                                    ?.toString() ??
                                    subject.totalMarks.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Total',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (v) {
                                  final val = int.tryParse(v) ??
                                      subject.totalMarks;
                                  setState(() {
                                    _totalMarksMap[subject.name] = val;
                                  });
                                  _saveDraft();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Step 2 ─────────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Select Students',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (v) => setState(() => _studentSearch = v),
            decoration: InputDecoration(
              hintText: 'Search by name, ID, father...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: _isLoadingStudents
              ? const Center(child: CircularProgressIndicator())
              : _selectedStudentIds.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_off,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('No students found for this class/section.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadStudents,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _selectedStudentIds.length,
            itemBuilder: (ctx, i) {
              final sid = _selectedStudentIds.elementAt(i);
              final student = context
                  .read<StudentProvider>()
                  .students
                  .firstWhere((s) => s.student.studentId == sid);
              final matchesSearch = _studentSearch.isEmpty ||
                  student.student.name
                      .toLowerCase()
                      .contains(_studentSearch.toLowerCase()) ||
                  student.fatherName
                      .toLowerCase()
                      .contains(_studentSearch.toLowerCase()) ||
                  student.student.studentId
                      .toLowerCase()
                      .contains(_studentSearch.toLowerCase());
              if (!matchesSearch) return const SizedBox.shrink();
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: CheckboxListTile(
                  title: Text(student.student.name,
                      style:
                      const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                      '${student.student.className} - ${student.student.sectionName}'),
                  value: true,
                  onChanged: (v) {
                    setState(() {
                      if (v == false) {
                        _selectedStudentIds.remove(sid);
                        _marks.remove(sid);
                      } else {
                        _selectedStudentIds.add(sid);
                        _marks[sid] = {};
                        for (final subj in _selectedSubjects) {
                          _marks[sid]![subj.name] = 0.0;
                        }
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Step 3 (Marks Entry) ─────────────────────────────────

  Widget _buildStep3() {
    final students = _selectedStudentIds
        .map((sid) => context.read<StudentProvider>().students
        .firstWhere((s) => s.student.studentId == sid))
        .toList();

    if (students.isEmpty) {
      return const Center(child: Text('No students selected.'));
    }

    final isWeb = MediaQuery.of(context).size.width > 800;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: isWeb ? 20 : 12,
            headingRowColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0xFFF0EFFE)),
            columns: [
              const DataColumn(
                  label: Text('Student',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14))),
              ..._selectedSubjects.map((s) => DataColumn(
                  label: Text('${s.name}\n(${s.totalMarks})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)))),
            ],
            rows: students.map((student) {
              final sid = student.student.studentId;
              final isEditable = !_isStudentEdit ||
                  sid == widget.studentContext!.student.studentId;
              return DataRow(cells: [
                DataCell(Text(student.student.name,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
                ..._selectedSubjects.map((subj) {
                  return DataCell(
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue:
                        _marks[sid]?[subj.name]?.toString() ?? '0',
                        keyboardType: TextInputType.number,
                        enabled: isEditable,
                        decoration: InputDecoration(
                          isDense: true,
                          border: const OutlineInputBorder(),
                          filled: !isEditable,
                          fillColor: Colors.grey.shade100,
                        ),
                        onChanged: (v) {
                          setState(() {
                            _marks[sid]![subj.name] = double.tryParse(v) ?? 0;
                          });
                        },
                      ),
                    ),
                  );
                }),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── Navigation Buttons ────────────────────────────────────

  Widget _buildNavigationButtons() {
    final showBack = _currentStep > 0 && !_isStudentEdit;
    final showNext = _currentStep < 2 && !_isStudentEdit;
    final showGenerate = _isStudentEdit || _currentStep == 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            TextButton.icon(
              onPressed: _prevStep,
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              label: const Text('Back'),
            )
          else
            const SizedBox(width: 80),
          if (showNext)
            ElevatedButton.icon(
              onPressed: _nextStep,
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF534AB7),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          else if (showGenerate)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateCard,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.save),
              label: Text(_isEditing ? 'Update' : 'Generate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  List<ExamSubject> get _selectedSubjects {
    return _availableSubjects
        .where((s) => _selectedSubjectNames.contains(s.name))
        .map((s) => ExamSubject(
      name: s.name,
      totalMarks: _totalMarksMap[s.name] ?? s.totalMarks,
    ))
        .toList();
  }
}