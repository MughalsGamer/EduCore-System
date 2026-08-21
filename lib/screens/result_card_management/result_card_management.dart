//
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/class_model.dart';
// import '../../models/exam_result_card_model.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/exam_result_card_provider.dart';
// import '../../providers/student_provider.dart';
// import 'exam_result_card_form_screen.dart';
//
// class StudentWiseResultCardsScreen extends StatefulWidget {
//   const StudentWiseResultCardsScreen({super.key});
//
//   @override
//   State<StudentWiseResultCardsScreen> createState() =>
//       _StudentWiseResultCardsScreenState();
// }
//
// class _StudentWiseResultCardsScreenState
//     extends State<StudentWiseResultCardsScreen>
//     with SingleTickerProviderStateMixin {
//   String? _selectedClassId;
//   String? _selectedSectionName;
//   String _search = '';
//   late AnimationController _animationController;
//
//   // ─── Helpers ──────────────────────────────────────────────
//
//   String _classNameById(String id) {
//     final cls = context.read<ClassProvider>().classes.firstWhere(
//           (c) => c.id == id,
//       orElse: () => SchoolClass(name: 'Unknown'),
//     );
//     return cls.name;
//   }
//
//   List<_StudentExamResult> _buildFlatResults(
//       List<StudentWithContext> allStudents,
//       List<ExamResultCard> allCards,
//       ) {
//     final results = <_StudentExamResult>[];
//     final studentMap = {for (final s in allStudents) s.student.studentId: s};
//
//     for (final card in allCards) {
//       for (final sm in card.studentMarks) {
//         final student = studentMap[sm.studentId];
//         if (student != null) {
//           results.add(_StudentExamResult(
//             student: student,
//             examCard: card,
//             studentMarks: sm,
//           ));
//         }
//       }
//     }
//     return results;
//   }
//
//   // ─── Lifecycle ─────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   // ─── Build ──────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     final classProvider = context.watch<ClassProvider>();
//     final examCardProvider = context.watch<ExamResultCardProvider>();
//     final studentProvider = context.watch<StudentProvider>();
//
//     final allStudents = studentProvider.allActiveStudents;
//     final allCards = examCardProvider.cards;
//
//     // ── Build and filter flat list ──
//     var flatResults = _buildFlatResults(allStudents, allCards);
//
//     // Class filter
//     if (_selectedClassId != null) {
//       final className = _classNameById(_selectedClassId!);
//       flatResults = flatResults
//           .where((r) => r.student.student.className == className)
//           .toList();
//     }
//
//     // Section filter
//     if (_selectedSectionName != null) {
//       flatResults = flatResults
//           .where((r) => r.student.student.sectionName == _selectedSectionName)
//           .toList();
//     }
//
//     // Search filter
//     if (_search.isNotEmpty) {
//       final q = _search.toLowerCase();
//       flatResults = flatResults.where((r) {
//         final s = r.student;
//         return s.student.name.toLowerCase().contains(q) ||
//             s.familyId.toLowerCase().contains(q) ||
//             s.student.studentId.toLowerCase().contains(q) ||
//             r.examCard.examName.toLowerCase().contains(q);
//       }).toList();
//     }
//
//     // Sort by student name, then exam date (newest first)
//     flatResults.sort((a, b) {
//       final nameComp = a.student.student.name.compareTo(b.student.student.name);
//       if (nameComp != 0) return nameComp;
//       return b.examCard.date.compareTo(a.examCard.date);
//     });
//
//     // ── Stats ──
//     final totalResults = flatResults.length;
//     final passCount = flatResults.where((r) => _isExamPass(r)).length;
//     final failCount = totalResults - passCount;
//
//     final isWeb = MediaQuery.of(context).size.width > 800;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: _buildAppBar(context),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return Column(
//             children: [
//               _buildStats(totalResults, passCount, failCount),
//               _buildFilters(classProvider),
//               Expanded(
//                 child: examCardProvider.isLoading || studentProvider.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : flatResults.isEmpty
//                     ? _buildEmptyState()
//                     : isWeb
//                     ? _buildWebGrid(flatResults)
//                     : _buildMobileList(flatResults),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   // ─── AppBar ─────────────────────────────────────────────────
//
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       title: const Text(
//         'Student Results',
//         style: TextStyle(
//           fontWeight: FontWeight.w700,
//           fontSize: 20,
//           color: Color(0xFF1A1A2E),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: false,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF534AB7)),
//           onPressed: () {
//             // TODO: Implement PDF generation
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('PDF generation coming soon!'),
//                 duration: Duration(seconds: 2),
//               ),
//             );
//           },
//         ),
//         IconButton(
//           icon: const Icon(Icons.add, color: Color(0xFF534AB7)),
//           onPressed: () async {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (_) => const ExamResultCardFormScreen()),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   // ─── Stats Row ─────────────────────────────────────────────
//
//   Widget _buildStats(int total, int pass, int fail) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       margin: const EdgeInsets.only(bottom: 8),
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _statItem('Total', total, const Color(0xFF534AB7)),
//           _statItem('Pass', pass, const Color(0xFF2E7D32)),
//           _statItem('Fail', fail, const Color(0xFFC62828)),
//         ],
//       ),
//     );
//   }
//
//   Widget _statItem(String label, int value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value.toString(),
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Color(0xFF6B7280),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Filters ────────────────────────────────────────────────
//
//   Widget _buildFilters(ClassProvider classProvider) {
//     final classes = classProvider.classes;
//     final sections = _selectedClassId == null
//         ? <String>[]
//         : classProvider.classes
//         .firstWhere((c) => c.id == _selectedClassId)
//         .sections
//         .map((s) => s.sectionName)
//         .toList();
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: DropdownButtonFormField<String?>(
//                   value: _selectedClassId,
//                   decoration: const InputDecoration(
//                     labelText: 'Class',
//                     border: InputBorder.none,
//                     isDense: true,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 8),
//                   ),
//                   items: [
//                     const DropdownMenuItem<String?>(value: null, child: Text('All Classes')),
//                     ...classes.map((c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.name))),
//                   ],
//                   onChanged: (v) {
//                     setState(() {
//                       _selectedClassId = v;
//                       _selectedSectionName = null;
//                     });
//                   },
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: DropdownButtonFormField<String?>(
//                   value: _selectedSectionName,
//                   decoration: const InputDecoration(
//                     labelText: 'Section',
//                     border: InputBorder.none,
//                     isDense: true,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 8),
//                   ),
//                   items: [
//                     const DropdownMenuItem<String?>(value: null, child: Text('All Sections')),
//                     ...sections.map((s) => DropdownMenuItem<String?>(value: s, child: Text(s))),
//                   ],
//                   onChanged: (v) {
//                     setState(() => _selectedSectionName = v);
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 1),
//           TextField(
//             onChanged: (v) => setState(() => _search = v),
//             decoration: const InputDecoration(
//               hintText: 'Search by student name, ID, family or exam...',
//               prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
//               border: InputBorder.none,
//               isDense: true,
//               contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Empty State ────────────────────────────────────────────
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.assignment_outlined,
//             size: 80,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No exam results found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Generate a result card first to see results here.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Web: Grid Layout ──────────────────────────────────────
//
//   Widget _buildWebGrid(List<_StudentExamResult> results) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: 480,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 1.2,
//       ),
//       itemCount: results.length,
//       itemBuilder: (ctx, i) {
//         return FadeTransition(
//           opacity: _animationController,
//           child: _buildResultCard(results[i]),
//         );
//       },
//     );
//   }
//
//   // ─── Mobile: List Layout ───────────────────────────────────
//
//   Widget _buildMobileList(List<_StudentExamResult> results) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: results.length,
//       itemBuilder: (ctx, i) {
//         return FadeTransition(
//           opacity: _animationController,
//           child: _buildResultCard(results[i]),
//         );
//       },
//     );
//   }
//
//   // ─── Result Card with Edit/Delete ──────────────────────────
//
//   Widget _buildResultCard(_StudentExamResult result) {
//     final student = result.student;
//     final exam = result.examCard;
//     final sm = result.studentMarks;
//     final isPass = _isExamPass(result);
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header: Avatar + Name + Exam Info + Menu ──
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 22,
//                   backgroundColor: const Color(0xFFF0EFFE),
//                   child: Text(
//                     student.student.name.isNotEmpty
//                         ? student.student.name[0].toUpperCase()
//                         : '?',
//                     style: const TextStyle(
//                       color: Color(0xFF534AB7),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         student.student.name,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                           color: Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       Text(
//                         '${student.student.className} - ${student.student.sectionName}',
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF6B7280),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _buildPassFailChip(isPass),
//                 const SizedBox(width: 8),
//                 // ── PopupMenu (Edit / Delete) ──
//                 PopupMenuButton<String>(
//                   icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
//                   onSelected: (value) async {
//                     if (value == 'edit') {
//                       await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ExamResultCardFormScreen(
//                             card: exam, // pass the full card
//                           ),
//                         ),
//                       );
//                     } else if (value == 'delete') {
//                       final confirmed = await showDialog<bool>(
//                         context: context,
//                         builder: (ctx) => AlertDialog(
//                           title: const Text('Delete Exam Result?'),
//                           content: Text(
//                             'Are you sure you want to delete the exam "${exam.examName}"?\nThis will remove all student results for this exam.',
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(ctx, false),
//                               child: const Text('Cancel'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () => Navigator.pop(ctx, true),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                               ),
//                               child: const Text('Delete'),
//                             ),
//                           ],
//                         ),
//                       );
//                       if (confirmed == true) {
//                         try {
//                           await context
//                               .read<ExamResultCardProvider>()
//                               .deleteCard(exam.id!);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Exam card deleted.'),
//                               duration: Duration(seconds: 2),
//                             ),
//                           );
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Error deleting: $e'),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       }
//                     }
//                   },
//                   itemBuilder: (ctx) => [
//                     const PopupMenuItem<String>(
//                       value: 'edit',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit, color: Color(0xFF534AB7)),
//                           SizedBox(width: 8),
//                           Text('Edit'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem<String>(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete_outline, color: Colors.red),
//                           SizedBox(width: 8),
//                           Text('Delete'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const Divider(height: 20, color: Color(0xFFE5E7EB)),
//
//             // ── Exam Details ──
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   exam.examName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 Text(
//                   DateFormat('dd MMM yyyy').format(exam.date),
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             // ── Subject Marks with Progress Bars ──
//             ...exam.subjects.map((subj) {
//               final obtained = sm.obtainedMarks[subj.name] ?? 0;
//               final total = subj.totalMarks;
//               final percentage = total > 0 ? obtained / total : 0.0;
//               final isFail = obtained < total * 0.25;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 80,
//                       child: Text(
//                         subj.name,
//                         style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
//                       ),
//                     ),
//                     Expanded(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: LinearProgressIndicator(
//                           value: percentage.clamp(0.0, 1.0),
//                           backgroundColor: Colors.grey.shade200,
//                           color: isFail ? Colors.red : Colors.green,
//                           minHeight: 8,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 60,
//                       child: Text(
//                         '$obtained / $total',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: isFail ? Colors.red : Colors.green,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─── Helpers ──────────────────────────────────────────────
//
//   bool _isExamPass(_StudentExamResult result) {
//     final sm = result.studentMarks;
//     for (final subj in result.examCard.subjects) {
//       final obtained = sm.obtainedMarks[subj.name] ?? 0;
//       if (obtained < subj.totalMarks * 0.25) return false;
//     }
//     return true;
//   }
//
//   Widget _buildPassFailChip(bool pass) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: pass ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             pass ? Icons.check_circle : Icons.cancel,
//             color: pass ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
//             size: 16,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             pass ? 'PASS' : 'FAIL',
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 12,
//               color: pass ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Helper class ────────────────────────────────────────────
//
// class _StudentExamResult {
//   final StudentWithContext student;
//   final ExamResultCard examCard;
//   final StudentExamMarks studentMarks;
//
//   _StudentExamResult({
//     required this.student,
//     required this.examCard,
//     required this.studentMarks,
//   });
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/class_model.dart';
import '../../models/exam_result_card_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/exam_result_card_provider.dart';
import '../../providers/student_provider.dart';
import 'exam_result_card_form_screen.dart';

class StudentWiseResultCardsScreen extends StatefulWidget {
  const StudentWiseResultCardsScreen({super.key});

  @override
  State<StudentWiseResultCardsScreen> createState() =>
      _StudentWiseResultCardsScreenState();
}

class _StudentWiseResultCardsScreenState
    extends State<StudentWiseResultCardsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedClassId;
  String? _selectedSectionName;
  String _search = '';
  late AnimationController _animationController;

  // ─── Helpers ──────────────────────────────────────────────

  String _classNameById(String id) {
    final cls = context.read<ClassProvider>().classes.firstWhere(
          (c) => c.id == id,
      orElse: () => SchoolClass(name: 'Unknown'),
    );
    return cls.name;
  }

  List<_StudentExamResult> _buildFlatResults(
      List<StudentWithContext> allStudents,
      List<ExamResultCard> allCards) {
    final results = <_StudentExamResult>[];
    final studentMap = {for (final s in allStudents) s.student.studentId: s};

    for (final card in allCards) {
      for (final sm in card.studentMarks) {
        final student = studentMap[sm.studentId];
        if (student != null) {
          results.add(_StudentExamResult(
            student: student,
            examCard: card,
            studentMarks: sm,
          ));
        }
      }
    }
    return results;
  }

  // ─── Lifecycle ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final examCardProvider = context.watch<ExamResultCardProvider>();
    final studentProvider = context.watch<StudentProvider>();

    final allStudents = studentProvider.allActiveStudents;
    final allCards = examCardProvider.cards;

    // ── Build and filter flat list ──
    var flatResults = _buildFlatResults(allStudents, allCards);

    // Class filter
    if (_selectedClassId != null) {
      final className = _classNameById(_selectedClassId!);
      flatResults = flatResults
          .where((r) => r.student.student.className == className)
          .toList();
    }

    // Section filter
    if (_selectedSectionName != null) {
      flatResults = flatResults
          .where((r) => r.student.student.sectionName == _selectedSectionName)
          .toList();
    }

    // Search filter
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      flatResults = flatResults.where((r) {
        final s = r.student;
        return s.student.name.toLowerCase().contains(q) ||
            s.familyId.toLowerCase().contains(q) ||
            s.student.studentId.toLowerCase().contains(q) ||
            r.examCard.examName.toLowerCase().contains(q);
      }).toList();
    }

    // Sort by student name, then exam date (newest first)
    flatResults.sort((a, b) {
      final nameComp = a.student.student.name.compareTo(b.student.student.name);
      if (nameComp != 0) return nameComp;
      return b.examCard.date.compareTo(a.examCard.date);
    });

    // ── Stats ──
    final totalResults = flatResults.length;
    final passCount = flatResults.where((r) => _isExamPass(r)).length;
    final failCount = totalResults - passCount;

    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              _buildStats(totalResults, passCount, failCount),
              _buildFilters(classProvider),
              Expanded(
                child: examCardProvider.isLoading || studentProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : flatResults.isEmpty
                    ? _buildEmptyState()
                    : isWeb
                    ? _buildWebGrid(flatResults)
                    : _buildMobileList(flatResults),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Student Results',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Color(0xFF1A1A2E),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF534AB7)),
          onPressed: () {
            // TODO: Implement PDF generation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF generation coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Color(0xFF534AB7)),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ExamResultCardFormScreen()),
            );
          },
        ),
      ],
    );
  }

  // ─── Stats Row ─────────────────────────────────────────────

  Widget _buildStats(int total, int pass, int fail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', total, const Color(0xFF534AB7)),
          _statItem('Pass', pass, const Color(0xFF2E7D32)),
          _statItem('Fail', fail, const Color(0xFFC62828)),
        ],
      ),
    );
  }

  Widget _statItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // ─── Filters ────────────────────────────────────────────────

  Widget _buildFilters(ClassProvider classProvider) {
    final classes = classProvider.classes;
    final sections = _selectedClassId == null
        ? <String>[]
        : classProvider.classes
        .firstWhere((c) => c.id == _selectedClassId)
        .sections
        .map((s) => s.sectionName)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedClassId,
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Classes')),
                    ...classes.map((c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _selectedClassId = v;
                      _selectedSectionName = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedSectionName,
                  decoration: const InputDecoration(
                    labelText: 'Section',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Sections')),
                    ...sections.map((s) => DropdownMenuItem<String?>(value: s, child: Text(s))),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedSectionName = v);
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(
              hintText: 'Search by student name, ID, family or exam...',
              prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No exam results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a result card first to see results here.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Web: Grid Layout ──────────────────────────────────────

  Widget _buildWebGrid(List<_StudentExamResult> results) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 480,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        return FadeTransition(
          opacity: _animationController,
          child: _buildResultCard(results[i]),
        );
      },
    );
  }

  // ─── Mobile: List Layout ───────────────────────────────────

  Widget _buildMobileList(List<_StudentExamResult> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        return FadeTransition(
          opacity: _animationController,
          child: _buildResultCard(results[i]),
        );
      },
    );
  }

  // ─── Result Card with Edit/Delete (student‑specific) ──────

  Widget _buildResultCard(_StudentExamResult result) {
    final student = result.student;
    final exam = result.examCard;
    final sm = result.studentMarks;
    final isPass = _isExamPass(result);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFF0EFFE),
                  child: Text(
                    student.student.name.isNotEmpty
                        ? student.student.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFF534AB7),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '${student.student.className} - ${student.student.sectionName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPassFailChip(isPass),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      // Student‑specific edit
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamResultCardFormScreen(
                            card: exam,
                            studentContext: student, // pass only this student
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      // Delete only this student from the card
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove Student Result?'),
                          content: Text(
                            'Are you sure you want to remove ${student.student.name} from this exam?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await context
                              .read<ExamResultCardProvider>()
                              .removeStudentFromCard(
                              exam.id!, student.student.studentId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Student result removed.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF534AB7)),
                          SizedBox(width: 8),
                          Text('Edit Marks'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remove Student'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFE5E7EB)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exam.examName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(exam.date),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...exam.subjects.map((subj) {
              final obtained = sm.obtainedMarks[subj.name] ?? 0;
              final total = subj.totalMarks;
              final percentage = total > 0 ? obtained / total : 0.0;
              final isFail = obtained < total * 0.25;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        subj.name,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade200,
                          color: isFail ? Colors.red : Colors.green,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$obtained / $total',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isFail ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  bool _isExamPass(_StudentExamResult result) {
    final sm = result.studentMarks;
    for (final subj in result.examCard.subjects) {
      final obtained = sm.obtainedMarks[subj.name] ?? 0;
      if (obtained < subj.totalMarks * 0.25) return false;
    }
    return true;
  }

  Widget _buildPassFailChip(bool pass) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pass ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pass ? Icons.check_circle : Icons.cancel,
            color: pass ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            pass ? 'PASS' : 'FAIL',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: pass ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper class ────────────────────────────────────────────

class _StudentExamResult {
  final StudentWithContext student;
  final ExamResultCard examCard;
  final StudentExamMarks studentMarks;

  _StudentExamResult({
    required this.student,
    required this.examCard,
    required this.studentMarks,
  });
}