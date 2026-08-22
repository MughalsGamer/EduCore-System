

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../lib/utils/exam_result_card_temp_storage.dart';
import '../../models/class_model.dart';
import '../../models/exam_result_card_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/exam_result_card_provider.dart';
import '../../providers/student_provider.dart';

// ─── Design Tokens (kept consistent with list screen) ─────────
class _T {
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF4338CA);
  static const primaryLight = Color(0xFFEEF2FF);
  static const bg = Color(0xFFF8F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFEDEFF5);
  static const success = Color(0xFF059669);
  static const successBg = Color(0xFFECFDF5);
  static const danger = Color(0xFFDC2626);
  static const dangerBg = Color(0xFFFEF2F2);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const cardRadius = 20.0;

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primary.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
  );
}

class ExamResultCardFormScreen extends StatefulWidget {
  final ExamResultCard? card;
  final StudentWithContext? studentContext;

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

  // Full list of students in the selected class/section (does NOT shrink
  // when a student is unticked — only _selectedStudentIds tracks selection).
  List<StudentWithContext> _classStudents = [];
  Set<String> _selectedStudentIds = {};
  Map<String, Map<String, double>> _marks = {};
  String _studentSearch = '';

  int _currentStep = 0;
  late final PageController _pageController;
  late final AnimationController _fadeController;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isStudentEdit = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _isEditing = widget.card != null;
    _isStudentEdit = widget.studentContext != null;

    if (_isStudentEdit) {
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

      if (onlyStudent != null) {
        final sid = onlyStudent.student.studentId;
        _selectedStudentIds = {sid};
        _marks[sid] = {};
        final sm = card.studentMarks.firstWhere(
                (m) => m.studentId == sid,
            orElse: () => StudentExamMarks(studentId: sid, studentName: ''));
        if (sm.studentId.isNotEmpty) {
          _marks[sid] = Map.from(sm.obtainedMarks);
        } else {
          for (final subj in card.subjects) {
            _marks[sid]![subj.name] = 0.0;
          }
        }
      } else {
        for (final sm in card.studentMarks) {
          _selectedStudentIds.add(sm.studentId);
          _marks[sm.studentId] = Map.from(sm.obtainedMarks);
        }
      }
    });
    if (onlyStudent == null) {
      await _loadStudents(preserveSelection: true);
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
      final classModel =
      classProvider.classes.firstWhere((c) => c.id == _selectedClassId);
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
      await _loadStudents(preserveSelection: _isEditing || _isStudentEdit);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snack('Error loading subjects: $e', isError: true));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isLoadingStudents = false;

  /// Loads the full roster for the selected class/section into
  /// [_classStudents]. The roster always contains every student in that
  /// class/section — ticking/unticking never removes anyone from this list,
  /// it only changes [_selectedStudentIds].
  ///
  /// [preserveSelection]: when true (e.g. editing an existing card), the
  /// current `_selectedStudentIds` / `_marks` are kept as-is and only
  /// missing entries are filled in. When false (fresh class/section pick),
  /// every student in the roster is selected by default with zeroed marks.
  Future<void> _loadStudents({bool preserveSelection = false}) async {
    if (_selectedClassId == null || _selectedSectionId == null) return;

    setState(() => _isLoadingStudents = true);

    int retries = 0;
    while (context.read<StudentProvider>().isLoading && retries < 5) {
      await Future.delayed(const Duration(milliseconds: 300));
      retries++;
    }

    try {
      final classProvider = context.read<ClassProvider>();
      final selectedClass =
      classProvider.classes.firstWhere((c) => c.id == _selectedClassId);
      final className = selectedClass.name;

      final allActive = context.read<StudentProvider>().allActiveStudents;
      final filtered = allActive
          .where((s) =>
      s.student.className == className &&
          s.student.sectionName == _selectedSectionId)
          .toList();

      setState(() {
        _classStudents = filtered;

        if (preserveSelection) {
          // Keep existing selection/marks; just make sure every roster
          // student has a marks entry (new students added to the class
          // after the card was created won't be auto-selected).
          for (final s in filtered) {
            final sid = s.student.studentId;
            _marks.putIfAbsent(sid, () => {
              for (final subj in _selectedSubjects) subj.name: 0.0,
            });
          }
        } else {
          _selectedStudentIds =
              filtered.map((s) => s.student.studentId).toSet();
          _marks = {};
          for (final s in filtered) {
            final sid = s.student.studentId;
            _marks[sid] = {};
            for (final subj in _selectedSubjects) {
              _marks[sid]![subj.name] = 0.0;
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        _classStudents = [];
        _selectedStudentIds.clear();
        _marks.clear();
      });
    } finally {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  Future<void> _saveDraft() async {
    if (_selectedClassId == null || _selectedSectionId == null) return;
    final classProvider = context.read<ClassProvider>();
    final className =
        classProvider.classes.firstWhere((c) => c.id == _selectedClassId).name;
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
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(_snack('Please complete all fields.', isError: true));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final studentProvider = context.read<StudentProvider>();
      final studentMarks = <StudentExamMarks>[];
      for (final sid in _selectedStudentIds) {
        final student =
        studentProvider.students.firstWhere((s) => s.student.studentId == sid);
        final obtained = Map<String, double>.from(_marks[sid] ?? {});
        studentMarks.add(StudentExamMarks(
          studentId: sid,
          studentName: student.student.name,
          obtainedMarks: obtained,
        ));
      }

      final classProvider = context.read<ClassProvider>();
      final className =
          classProvider.classes.firstWhere((c) => c.id == _selectedClassId).name;

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
        final studentId = widget.studentContext!.student.studentId;
        final marksMap = _marks[studentId] ?? {};
        await context
            .read<ExamResultCardProvider>()
            .updateStudentMarks(widget.card!.id!, studentId, marksMap);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(_snack('Student marks updated!'));
        }
      } else if (_isEditing) {
        await context
            .read<ExamResultCardProvider>()
            .updateCard(widget.card!.id!, newCard);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(_snack('Card updated!'));
        }
      } else {
        await context.read<ExamResultCardProvider>().addCard(newCard);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(_snack('Card generated!'));
        }
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
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snack('Error: $e', isError: true));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  SnackBar _snack(String msg, {bool isError = false}) {
    return SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? _T.danger : _T.textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    );
  }

  // ─── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 800;

    return Scaffold(
      backgroundColor: _T.bg,
      body: isWeb ? _buildWebScaffold(context) : _buildMobileScaffold(context),
    );
  }

  // ══════════════════════════════════════════════════════════
  // MOBILE SCAFFOLD
  // ══════════════════════════════════════════════════════════

  Widget _buildMobileScaffold(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildMobileHeader(context),
          if (!_isStudentEdit) _buildStepIndicator(isMobile: true),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _isStudentEdit
                  ? [_buildStep3(isMobile: true)]
                  : [
                _buildStep1(isMobile: true),
                _buildStep2(isMobile: true),
                _buildStep3(isMobile: true),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: _T.surface,
        border: Border(bottom: BorderSide(color: _T.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: _T.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              _isStudentEdit
                  ? 'Edit — ${widget.studentContext!.student.name}'
                  : _isEditing
                  ? 'Edit Exam Card'
                  : 'New Result Card',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: -0.2,
                color: _T.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // WEB SCAFFOLD
  // ══════════════════════════════════════════════════════════

  Widget _buildWebScaffold(BuildContext context) {
    return Column(
      children: [
        _buildWebHeader(context),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: _T.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _T.softShadow,
                ),
                child: Column(
                  children: [
                    if (!_isStudentEdit)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                        child: _buildStepIndicator(isMobile: false),
                      ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _isStudentEdit
                            ? [_buildStep3(isMobile: false)]
                            : [
                          _buildStep1(isMobile: false),
                          _buildStep2(isMobile: false),
                          _buildStep3(isMobile: false),
                        ],
                      ),
                    ),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: BoxDecoration(
        color: _T.surface,
        border: Border(bottom: BorderSide(color: _T.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _T.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: _T.primary, size: 18),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            _isStudentEdit
                ? 'Edit Marks — ${widget.studentContext!.student.name}'
                : _isEditing
                ? 'Edit Exam Card'
                : 'New Result Card',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              letterSpacing: -0.3,
              color: _T.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step Indicator ─────────────────────────────────────────

  Widget _buildStepIndicator({required bool isMobile}) {
    final labels = ['Details & Subjects', 'Select Students', 'Enter Marks'];
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 0, vertical: isMobile ? 12 : 0),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: i < 2 ? 8 : 0, bottom: isMobile ? 0 : 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: isActive || isDone ? _T.gradient : null,
                          color: isActive || isDone ? null : _T.bg,
                          shape: BoxShape.circle,
                          border: isActive || isDone
                              ? null
                              : Border.all(color: _T.border),
                        ),
                        alignment: Alignment.center,
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 15)
                            : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isActive
                                ? Colors.white
                                : _T.textTertiary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isDone ? _T.primary : _T.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        color: isActive ? _T.primary : _T.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Step 1 ─────────────────────────────────────────────────

  Widget _buildStep1({required bool isMobile}) {
    final classProvider = context.watch<ClassProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      physics: const BouncingScrollPhysics(),
      child: FadeTransition(
        opacity: _fadeController,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Exam Details', Icons.event_note_rounded),
              const SizedBox(height: 16),
              _premiumTextField(
                label: 'Test / Exam Name',
                initialValue: _examName,
                onChanged: (v) {
                  _examName = v;
                  _saveDraft();
                },
              ),
              const SizedBox(height: 14),
              _datePickerField(),
              const SizedBox(height: 28),
              _sectionTitle('Class & Section', Icons.class_outlined),
              const SizedBox(height: 14),

              if (classProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                      child: CircularProgressIndicator(color: _T.primary)),
                )
              else if (classProvider.error != null)
                Column(
                  children: [
                    Text(
                      'Error loading classes: ${classProvider.error}',
                      style: const TextStyle(color: _T.danger, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _secondaryButton(
                        'Retry', () => classProvider.loadClasses()),
                  ],
                )
              else if (classProvider.classes.isEmpty)
                  _infoBanner('No classes found. Please add a class first.')
                else
                  _premiumDropdown<String>(
                    label: 'Class',
                    value: _selectedClassId,
                    items: classProvider.classes
                        .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
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
              const SizedBox(height: 14),

              if (_selectedClassId != null)
                Builder(
                  builder: (context) {
                    final selectedClass = classProvider.classes
                        .firstWhere((c) => c.id == _selectedClassId);
                    final sections = selectedClass.sections;
                    if (sections.isEmpty) {
                      return _infoBanner('No sections in this class.');
                    }
                    return _premiumDropdown<String>(
                      label: 'Section',
                      value: _selectedSectionId,
                      items: sections
                          .map((s) => DropdownMenuItem(
                          value: s.sectionName, child: Text(s.sectionName)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedSectionId = v);
                        _loadSubjectsForSelection();
                        _saveDraft();
                      },
                    );
                  },
                ),
              const SizedBox(height: 28),

              if (_isLoading)
                const Center(
                    child: CircularProgressIndicator(color: _T.primary))
              else if (_availableSubjects.isNotEmpty) ...[
                _sectionTitle('Subjects', Icons.menu_book_outlined),
                const SizedBox(height: 12),
                ..._availableSubjects.map((subject) {
                  final isSelected =
                  _selectedSubjectNames.contains(subject.name);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? _T.primaryLight : _T.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? _T.primary : _T.border,
                        width: isSelected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          activeColor: _T.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedSubjectNames.add(subject.name);
                                if (!_totalMarksMap.containsKey(subject.name)) {
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
                          child: Text(
                            subject.name,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: _T.textPrimary),
                          ),
                        ),
                        if (isSelected)
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              initialValue:
                              _totalMarksMap[subject.name]?.toString() ??
                                  subject.totalMarks.toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w700),
                              decoration: InputDecoration(
                                labelText: 'Total',
                                labelStyle: const TextStyle(fontSize: 11),
                                filled: true,
                                fillColor: _T.surface,
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (v) {
                                final val =
                                    int.tryParse(v) ?? subject.totalMarks;
                                setState(() {
                                  _totalMarksMap[subject.name] = val;
                                });
                                _saveDraft();
                              },
                            ),
                          ),
                        const SizedBox(width: 4),
                      ],
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

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _T.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15.5,
            letterSpacing: -0.2,
            color: _T.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _premiumTextField({
    required String label,
    required String initialValue,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: _T.textSecondary, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: _T.bg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _T.primary, width: 1.6),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _datePickerField() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _examDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: _T.primary,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _examDate = picked);
          _saveDraft();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _T.bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: _T.textTertiary),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMMM yyyy').format(_examDate),
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: _T.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _premiumDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: _T.textTertiary),
          style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: _T.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                color: _T.textSecondary, fontWeight: FontWeight.w500),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _infoBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _T.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _T.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: _T.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _secondaryButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _T.primary,
        side: const BorderSide(color: _T.primary),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  // ─── Step 2 ─────────────────────────────────────────────────

  Widget _buildStep2({required bool isMobile}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 28, isMobile ? 16 : 24, isMobile ? 16 : 28, 8),
          child: Row(
            children: [
              Expanded(child: _sectionTitle('Select Students', Icons.groups_outlined)),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _T.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedStudentIds.length} selected',
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _T.primary),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 28, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _studentSearch = v),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Search by name, ID, father...',
                hintStyle: TextStyle(color: _T.textTertiary, fontSize: 13.5),
                prefixIcon:
                Icon(Icons.search_rounded, color: _T.textTertiary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoadingStudents
              ? const Center(
              child: CircularProgressIndicator(color: _T.primary))
              : _classStudents.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _T.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_off_rounded,
                      size: 32, color: _T.primary.withOpacity(0.6)),
                ),
                const SizedBox(height: 14),
                const Text('No students found for this class/section.',
                    style: TextStyle(
                        color: _T.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 12),
                _secondaryButton('Retry', () => _loadStudents()),
              ],
            ),
          )
              : Builder(builder: (context) {
            // Always iterate the FULL roster so unticked students
            // stay visible (and re-searchable) instead of
            // disappearing from the list.
            final q = _studentSearch.toLowerCase();
            final visibleStudents = q.isEmpty
                ? _classStudents
                : _classStudents.where((student) {
              return student.student.name
                  .toLowerCase()
                  .contains(q) ||
                  student.fatherName.toLowerCase().contains(q) ||
                  student.student.studentId
                      .toLowerCase()
                      .contains(q);
            }).toList();

            if (visibleStudents.isEmpty) {
              return Center(
                child: Text(
                  'No students match "$_studentSearch"',
                  style: const TextStyle(
                      color: _T.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 28, vertical: 4),
              physics: const BouncingScrollPhysics(),
              itemCount: visibleStudents.length,
              itemBuilder: (ctx, i) {
                final student = visibleStudents[i];
                final sid = student.student.studentId;
                final isSelected =
                _selectedStudentIds.contains(sid);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _T.bg : _T.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                      isSelected ? Colors.transparent : _T.border,
                    ),
                  ),
                  child: CheckboxListTile(
                    controlAffinity:
                    ListTileControlAffinity.leading,
                    activeColor: _T.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    title: Text(student.student.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isSelected
                                ? _T.textPrimary
                                : _T.textTertiary)),
                    subtitle: Text(
                        '${student.student.className} · ${student.student.sectionName}',
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: _T.textSecondary,
                            fontWeight: FontWeight.w500)),
                    value: isSelected,
                    onChanged: (v) {
                      setState(() {
                        if (v == false) {
                          // Untick: only remove from selection.
                          // Student stays in _classStudents so it
                          // remains visible and searchable, and
                          // re-ticking restores it instantly.
                          _selectedStudentIds.remove(sid);
                        } else {
                          _selectedStudentIds.add(sid);
                          _marks.putIfAbsent(sid, () => {});
                          for (final subj in _selectedSubjects) {
                            _marks[sid]!.putIfAbsent(
                                subj.name, () => 0.0);
                          }
                        }
                      });
                    },
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Step 3 (Marks Entry) ─────────────────────────────────

  Widget _buildStep3({required bool isMobile}) {
    // Resolve from _classStudents (falling back to the provider for the
    // student-edit case where _classStudents may be empty) so marks entry
    // only ever shows students currently ticked in step 2.
    final rosterById = {
      for (final s in _classStudents) s.student.studentId: s,
    };
    final students = _selectedStudentIds.map((sid) {
      return rosterById[sid] ??
          context
              .read<StudentProvider>()
              .students
              .firstWhere((s) => s.student.studentId == sid);
    }).toList();

    if (students.isEmpty) {
      return const Center(
        child: Text('No students selected.',
            style: TextStyle(color: _T.textSecondary, fontWeight: FontWeight.w600)),
      );
    }

    if (isMobile) {
      // Mobile: card-per-student layout — far more usable on small screens
      // than a wide horizontally-scrolling table.
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        physics: const BouncingScrollPhysics(),
        itemCount: students.length,
        itemBuilder: (ctx, i) {
          final student = students[i];
          final sid = student.student.studentId;
          final isEditable = !_isStudentEdit ||
              sid == widget.studentContext!.student.studentId;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _T.primaryLight,
                      child: Text(
                        student.student.name.isNotEmpty
                            ? student.student.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: _T.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        student.student.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._selectedSubjects.map((subj) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${subj.name} (${subj.totalMarks})',
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _T.textSecondary),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue:
                            _marks[sid]?[subj.name]?.toString() ?? '0',
                            keyboardType: TextInputType.number,
                            enabled: isEditable,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w700),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: isEditable ? _T.bg : _T.border,
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (v) {
                              setState(() {
                                _marks[sid]![subj.name] =
                                    double.tryParse(v) ?? 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      );
    }

    // Web: clean data table
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _T.border),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor:
              MaterialStateColor.resolveWith((states) => _T.primaryLight),
              headingRowHeight: 52,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 64,
              columns: [
                const DataColumn(
                    label: Text('Student',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _T.textPrimary))),
                ..._selectedSubjects.map((s) => DataColumn(
                    label: Text('${s.name} (${s.totalMarks})',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: _T.textPrimary)))),
              ],
              rows: students.map((student) {
                final sid = student.student.studentId;
                final isEditable = !_isStudentEdit ||
                    sid == widget.studentContext!.student.studentId;
                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: _T.primaryLight,
                        child: Text(
                          student.student.name.isNotEmpty
                              ? student.student.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: _T.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(student.student.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13.5)),
                    ],
                  )),
                  ..._selectedSubjects.map((subj) {
                    return DataCell(
                      SizedBox(
                        width: 76,
                        child: TextFormField(
                          initialValue:
                          _marks[sid]?[subj.name]?.toString() ?? '0',
                          keyboardType: TextInputType.number,
                          enabled: isEditable,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: isEditable ? _T.bg : _T.border.withOpacity(0.5),
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (v) {
                            setState(() {
                              _marks[sid]![subj.name] =
                                  double.tryParse(v) ?? 0;
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
        color: _T.surface,
        border: Border(top: BorderSide(color: _T.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            TextButton.icon(
              onPressed: _prevStep,
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  size: 14, color: _T.textSecondary),
              label: const Text('Back',
                  style: TextStyle(
                      color: _T.textSecondary, fontWeight: FontWeight.w700)),
            )
          else
            const SizedBox(width: 80),
          if (showNext)
            ElevatedButton.icon(
              onPressed: _nextStep,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          else if (showGenerate)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateCard,
              icon: _isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_isEditing || _isStudentEdit ? 'Update' : 'Generate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.success,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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