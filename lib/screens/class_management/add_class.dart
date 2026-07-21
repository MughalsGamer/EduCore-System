
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/teacher_provider.dart';

// ─────────────────────────────────────────────
//  Constants
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFEEEDFE);
const _kPurpleMid = Color(0xFFAFA9EC);
const _kDesktopBreak = 720.0;

final _weekdays = [
  'Monday', 'Tuesday', 'Wednesday',
  'Thursday', 'Friday', 'Saturday',
];

// ─────────────────────────────────────────────
//  Models (local)
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
  bool timetableExpanded = false;
  bool subjectsExpanded = true;

  void dispose() {
    startController.dispose();
    endController.dispose();
    lunchStartController.dispose();
    lunchEndController.dispose();
  }
}

// ─────────────────────────────────────────────
//  Reusable design components
// ─────────────────────────────────────────────

/// Modern section card header
Widget _sectionHeader(BuildContext context, String title, {
  IconData? icon,
  Color? iconColor,
  Widget? trailing,
}) {
  return Row(
    children: [
      if (icon != null) ...[
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: (iconColor ?? _kPurple).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: iconColor ?? _kPurple),
        ),
        const SizedBox(width: 10),
      ],
      Expanded(
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
      if (trailing != null) trailing,
    ],
  );
}

/// Styled card container
Widget _styledCard({required Widget child, EdgeInsets? padding, Color? color}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.zero,
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ],
    ),
    padding: padding ?? const EdgeInsets.all(16),
    child: child,
  );
}

/// Divider with label
Widget _labelDivider(String label, BuildContext context) {
  return Row(children: [
    const Expanded(child: Divider()),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Colors.grey.shade500, letterSpacing: 0.5)),
    ),
    const Expanded(child: Divider()),
  ]);
}

// ─────────────────────────────────────────────
//  Subject + Marks selector (table style)
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
//  Subject + Marks selector (compact, clean)
// ─────────────────────────────────────────────
class _SubjectMarkSelector extends StatefulWidget {
  final List<SubjectMark> selectedSubjectMarks;
  final ValueChanged<List<SubjectMark>> onChanged;

  const _SubjectMarkSelector({
    required this.selectedSubjectMarks,
    required this.onChanged,
  });

  @override
  State<_SubjectMarkSelector> createState() => _SubjectMarkSelectorState();
}

class _SubjectMarkSelectorState extends State<_SubjectMarkSelector> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  TextEditingController _getController(String subject, int currentMarks) {
    if (!_controllers.containsKey(subject)) {
      _controllers[subject] = TextEditingController(
        text: currentMarks == 0 ? '' : currentMarks.toString(),
      );
    }
    return _controllers[subject]!;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MuddulProvider>();
    final allSubjects = provider.mudduls
        .map((m) => m.subjectName)
        .toSet()
        .toList()
      ..sort();

    if (provider.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (allSubjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(children: [
          Icon(Icons.info_outline, size: 15, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No subjects found. Add subjects first.',
              style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
            ),
          ),
        ]),
      );
    }

    final selectedCount = widget.selectedSubjectMarks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _kPurple.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: _kPurple.withOpacity(0.15)),
          ),
          child: Row(children: [
            Expanded(
              flex: 5,
              child: Text(
                'Subject',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            SizedBox(
              width: 88,
              child: Text(
                'Total Marks',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ]),
        ),

        // ── Subject rows ──
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.grey.shade200),
              right: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Column(
            children: allSubjects.asMap().entries.map((entry) {
              final idx = entry.key;
              final subject = entry.value;
              final existingIndex = widget.selectedSubjectMarks
                  .indexWhere((s) => s.name == subject);
              final isSelected = existingIndex >= 0;
              final currentMarks = isSelected
                  ? widget.selectedSubjectMarks[existingIndex].totalMarks
                  : 0;
              final ctrl =
              isSelected ? _getController(subject, currentMarks) : null;
              final isLast = idx == allSubjects.length - 1;

              return InkWell(
                onTap: () {
                  final updated =
                  List<SubjectMark>.from(widget.selectedSubjectMarks);
                  if (isSelected) {
                    _controllers.remove(subject)?.dispose();
                    updated.removeAt(existingIndex);
                  } else {
                    updated.add(SubjectMark(name: subject, totalMarks: 0));
                  }
                  widget.onChanged(updated);
                },
                child: Column(
                  children: [
                    Container(
                      color: isSelected
                          ? _kPurple.withOpacity(0.04)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      child: Row(
                        children: [
                          // ── Checkbox ──
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isSelected ? _kPurple : Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isSelected
                                    ? _kPurple
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),

                          // ── Subject name ──
                          Expanded(
                            flex: 5,
                            child: Text(
                              subject,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color:
                                isSelected ? _kPurple : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // ── Marks field (always visible) ──
                          SizedBox(
                            width: 88,
                            child: isSelected
                                ? GestureDetector(
                              onTap: () {}, // prevent row tap
                              behavior: HitTestBehavior.opaque,
                              child: TextFormField(
                                controller: ctrl,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: '100',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(7),
                                    borderSide: const BorderSide(
                                        color: _kPurple, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: _kPurple
                                            .withOpacity(0.3)),
                                  ),
                                  isDense: true,
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 7),
                                  filled: true,
                                  fillColor:
                                  _kPurple.withOpacity(0.04),
                                ),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly,
                                ],
                                onChanged: (val) {
                                  final parsed =
                                      int.tryParse(val) ?? 0;
                                  final updated =
                                  List<SubjectMark>.from(
                                      widget.selectedSubjectMarks);
                                  updated[existingIndex] = SubjectMark(
                                      name: subject,
                                      totalMarks: parsed);
                                  widget.onChanged(updated);
                                },
                              ),
                            )
                                : Center(
                              child: Text(
                                '—',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider after every row except last
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade100,
                        indent: 12,
                        endIndent: 12,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // ── Footer: selected count ──
        if (selectedCount > 0) ...[
          const SizedBox(height: 8),
          Row(children: [
            const SizedBox(width: 2),
            Icon(Icons.check_circle_outline,
                size: 13, color: Colors.green.shade600),
            const SizedBox(width: 5),
            Text(
              '$selectedCount subject${selectedCount == 1 ? '' : 's'} selected',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ]),
        ],
      ],
    );
  }
}
// class _SubjectMarkSelector extends StatefulWidget {
//   final List<SubjectMark> selectedSubjectMarks;
//   final ValueChanged<List<SubjectMark>> onChanged;
//
//   const _SubjectMarkSelector({
//     required this.selectedSubjectMarks,
//     required this.onChanged,
//   });
//
//   @override
//   State<_SubjectMarkSelector> createState() => _SubjectMarkSelectorState();
// }
//
// class _SubjectMarkSelectorState extends State<_SubjectMarkSelector> {
//   final Map<String, TextEditingController> _controllers = {};
//
//   @override
//   void dispose() {
//     for (final c in _controllers.values) c.dispose();
//     super.dispose();
//   }
//
//   TextEditingController _getController(String subject, int currentMarks) {
//     if (!_controllers.containsKey(subject)) {
//       _controllers[subject] = TextEditingController(
//         text: currentMarks == 0 ? '' : currentMarks.toString(),
//       );
//     }
//     return _controllers[subject]!;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<MuddulProvider>();
//     final allSubjects = provider.mudduls
//         .map((m) => m.subjectName)
//         .toSet()
//         .toList()
//       ..sort();
//
//     if (provider.loading) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 12),
//         child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//       );
//     }
//
//     if (allSubjects.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.amber.shade50,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.amber.shade200),
//         ),
//         child: Row(children: [
//           Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text('No subjects found. Add subjects first.',
//                 style:
//                 TextStyle(fontSize: 12, color: Colors.amber.shade800)),
//           ),
//         ]),
//       );
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header row
//         Container(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             borderRadius:
//             const BorderRadius.vertical(top: Radius.circular(10)),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Row(children: [
//             Expanded(
//               flex: 3,
//               child: Text('Subject',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade600)),
//             ),
//             Text('Total Marks',
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade600)),
//           ]),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             border: Border(
//               left: BorderSide(color: Colors.grey.shade200),
//               right: BorderSide(color: Colors.grey.shade200),
//               bottom: BorderSide(color: Colors.grey.shade200),
//             ),
//             borderRadius:
//             const BorderRadius.vertical(bottom: Radius.circular(10)),
//           ),
//           child: Column(
//             children: allSubjects.asMap().entries.map((entry) {
//               final idx = entry.key;
//               final subject = entry.value;
//               final existingIndex = widget.selectedSubjectMarks
//                   .indexWhere((s) => s.name == subject);
//               final isSelected = existingIndex >= 0;
//               final currentMarks = isSelected
//                   ? widget.selectedSubjectMarks[existingIndex].totalMarks
//                   : 0;
//
//               final ctrl = isSelected
//                   ? _getController(subject, currentMarks)
//                   : null;
//
//               return Container(
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? _kPurpleLight.withOpacity(0.5)
//                       : Colors.transparent,
//                   border: idx < allSubjects.length - 1
//                       ? Border(
//                       bottom:
//                       BorderSide(color: Colors.grey.shade100))
//                       : null,
//                 ),
//                 child: InkWell(
//                   onTap: () {
//                     final updated = List<SubjectMark>.from(
//                         widget.selectedSubjectMarks);
//                     if (isSelected) {
//                       _controllers.remove(subject)?.dispose();
//                       updated.removeAt(existingIndex);
//                     } else {
//                       updated.add(SubjectMark(
//                           name: subject, totalMarks: 0));
//                     }
//                     widget.onChanged(updated);
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 10),
//                     child: Row(children: [
//                       // Checkbox
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 150),
//                         width: 20,
//                         height: 20,
//                         decoration: BoxDecoration(
//                           color: isSelected ? _kPurple : Colors.white,
//                           borderRadius: BorderRadius.circular(5),
//                           border: Border.all(
//                             color: isSelected
//                                 ? _kPurple
//                                 : Colors.grey.shade300,
//                             width: 1.5,
//                           ),
//                         ),
//                         child: isSelected
//                             ? const Icon(Icons.check,
//                             size: 13, color: Colors.white)
//                             : null,
//                       ),
//                       const SizedBox(width: 10),
//                       // Subject name
//                       Expanded(
//                         flex: 3,
//                         child: Text(
//                           subject,
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: isSelected
//                                 ? FontWeight.w600
//                                 : FontWeight.w400,
//                             color: isSelected
//                                 ? _kPurple
//                                 : Colors.black87,
//                           ),
//                         ),
//                       ),
//                       // Marks field
//                       if (isSelected)
//                         SizedBox(
//                           width: 90,
//                           child: TextFormField(
//                             controller: ctrl,
//                             decoration: InputDecoration(
//                               hintText: 'e.g. 100',
//                               hintStyle: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade400),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(
//                                     color: Colors.grey.shade300),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: const BorderSide(
//                                     color: _kPurple, width: 1.5),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(
//                                     color: Colors.grey.shade300),
//                               ),
//                               isDense: true,
//                               contentPadding:
//                               const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 8),
//                             ),
//                             style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500),
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                             onTap: () {},
//                             onChanged: (val) {
//                               final parsed = int.tryParse(val) ?? 0;
//                               final updated = List<SubjectMark>.from(
//                                   widget.selectedSubjectMarks);
//                               updated[existingIndex] = SubjectMark(
//                                   name: subject,
//                                   totalMarks: parsed);
//                               widget.onChanged(updated);
//                             },
//                           ),
//                         )
//                       else
//                         SizedBox(
//                           width: 90,
//                           child: Center(
//                             child: Text('—',
//                                 style: TextStyle(
//                                     color: Colors.grey.shade400,
//                                     fontSize: 13)),
//                           ),
//                         ),
//                     ]),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }

// ─────────────────────────────────────────────
//  Timetable generator widget (extracted)
// ─────────────────────────────────────────────
class _TimetableBuilder extends StatefulWidget {
  final _SectionTimetableData data;
  final List<TimetableDay> timetable;
  final VoidCallback onChanged;
  final void Function(List<TimetableDay>) onTimetableChanged;

  const _TimetableBuilder({
    required this.data,
    required this.timetable,
    required this.onChanged,
    required this.onTimetableChanged,
  });

  @override
  State<_TimetableBuilder> createState() => _TimetableBuilderState();
}

class _TimetableBuilderState extends State<_TimetableBuilder> {
  void _mergeSimple() {
    final d = widget.data;
    if (d.pendingDays.isEmpty) return;
    final start = d.startController.text;
    final end = d.endController.text;

    final updated = List<TimetableDay>.from(widget.timetable);
    for (final day in d.pendingDays) {
      final List<TimetablePeriod> periods = [];
      if (d.hasLunchBreak &&
          d.lunchStartController.text.isNotEmpty &&
          d.lunchEndController.text.isNotEmpty) {
        final ls = d.lunchStartController.text;
        final le = d.lunchEndController.text;
        if (ls != start)
          periods.add(
              TimetablePeriod(startTime: start, endTime: ls, subject: ''));
        periods.add(TimetablePeriod(
            startTime: ls, endTime: le, isLunchBreak: true, subject: 'Lunch'));
        if (le != end)
          periods.add(
              TimetablePeriod(startTime: le, endTime: end, subject: ''));
      } else {
        periods
            .add(TimetablePeriod(startTime: start, endTime: end, subject: ''));
      }
      final idx = updated.indexWhere((t) => t.day == day);
      final newDay = TimetableDay(day: day, periods: periods);
      if (idx >= 0) {
        updated[idx] = newDay;
      } else {
        updated.add(newDay);
      }
    }
    updated.sort(
            (a, b) => _weekdays.indexOf(a.day) - _weekdays.indexOf(b.day));
    setState(() {
      d.generatedDays.addAll(d.pendingDays);
      d.pendingDays.clear();
    });
    widget.onTimetableChanged(updated);
  }

  void _mergeSubjectWise() {
    final d = widget.data;
    final updated = List<TimetableDay>.from(widget.timetable);
    final Map<String, List<TimetablePeriod>> byDay = {};
    for (final e in d.subjectEntries) {
      for (final day in e.days) {
        byDay.putIfAbsent(day, () => []);
        byDay[day]!.add(TimetablePeriod(
            subject: e.subject,
            startTime: e.startTime,
            endTime: e.endTime));
      }
    }
    for (final day in byDay.keys) {
      final newPeriods = byDay[day]!;
      final idx = updated.indexWhere((t) => t.day == day);
      if (idx >= 0) {
        for (final np in newPeriods) {
          final exists = updated[idx].periods.any(
                  (p) => p.startTime == np.startTime && p.subject == np.subject);
          if (!exists) updated[idx].periods.add(np);
        }
        updated[idx]
            .periods
            .sort((a, b) => a.startTime.compareTo(b.startTime));
      } else {
        newPeriods.sort((a, b) => a.startTime.compareTo(b.startTime));
        updated.add(TimetableDay(day: day, periods: newPeriods));
      }
    }
    updated.sort(
            (a, b) => _weekdays.indexOf(a.day) - _weekdays.indexOf(b.day));
    setState(() {
      for (final e in d.subjectEntries) {
        d.generatedDays.addAll(e.days);
      }
    });
    widget.onTimetableChanged(updated);
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    TimeOfDay initial = const TimeOfDay(hour: 8, minute: 0);
    final parts = ctrl.text.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Widget _timeField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time, size: 16),
          onPressed: () => _pickTime(ctrl),
        ),
      ),
      keyboardType: TextInputType.datetime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final timetable = widget.timetable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mode toggle ──
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(children: [
            _modeTab('Simple', !d.isSubjectWiseMode, () {
              if (d.isSubjectWiseMode) setState(() => d.isSubjectWiseMode = false);
            }),
            _modeTab('Subject-wise', d.isSubjectWiseMode, () {
              if (!d.isSubjectWiseMode)
                setState(() => d.isSubjectWiseMode = true);
            }),
          ]),
        ),
        const SizedBox(height: 16),

        if (!d.isSubjectWiseMode) ...[
          // ── Simple mode ──
          Text('Select school days',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _weekdays.map((day) {
              final isGen = d.generatedDays.contains(day);
              final isPend = d.pendingDays.contains(day);
              return GestureDetector(
                onTap: isGen
                    ? null
                    : () => setState(() {
                  if (isPend)
                    d.pendingDays.remove(day);
                  else
                    d.pendingDays.add(day);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isGen
                        ? Colors.green.shade50
                        : isPend
                        ? _kPurple
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isGen
                          ? Colors.green.shade300
                          : isPend
                          ? _kPurple
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isGen)
                      Icon(Icons.check_circle,
                          size: 13, color: Colors.green.shade600),
                    if (isPend)
                      const Icon(Icons.check, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      day.substring(0, 3),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isGen
                            ? Colors.green.shade700
                            : isPend
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _timeField(d.startController, 'School starts')),
            const SizedBox(width: 10),
            Expanded(child: _timeField(d.endController, 'School ends')),
          ]),
          const SizedBox(height: 10),
          // Lunch break toggle
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(children: [
              const Icon(Icons.restaurant, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Lunch break',
                      style: const TextStyle(fontSize: 13))),
              Switch(
                value: d.hasLunchBreak,
                activeColor: _kPurple,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) => setState(() => d.hasLunchBreak = val),
              ),
            ]),
          ),
          if (d.hasLunchBreak) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child:
                  _timeField(d.lunchStartController, 'Lunch starts')),
              const SizedBox(width: 10),
              Expanded(
                  child: _timeField(d.lunchEndController, 'Lunch ends')),
            ]),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: d.pendingDays.isEmpty ? null : _mergeSimple,
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: Text(d.pendingDays.isEmpty
                  ? 'Select days first'
                  : 'Generate for ${d.pendingDays.length} day(s)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ] else ...[
          // ── Subject-wise mode ──
          Text('Add subjects with their schedule',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          ...d.subjectEntries.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: e.subject,
                          decoration: const InputDecoration(
                            labelText: 'Subject name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => e.subject = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        onPressed: () =>
                            setState(() => d.subjectEntries.removeAt(i)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _timeField(
                          TextEditingController(text: e.startTime)
                            ..addListener(() {}),
                          'Start')),
                      const SizedBox(width: 8),
                      Expanded(child: _timeField(
                          TextEditingController(text: e.endTime)
                            ..addListener(() {}),
                          'End')),
                    ]),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _weekdays.map((day) {
                        final sel = e.days.contains(day);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (sel)
                              e.days.remove(day);
                            else
                              e.days.add(day);
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: sel ? _kPurple : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: sel
                                      ? _kPurple
                                      : Colors.grey.shade300),
                            ),
                            child: Text(day.substring(0, 3),
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: sel
                                        ? Colors.white
                                        : Colors.black54)),
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
            );
          }),
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => d.subjectEntries.add(_SubjectScheduleEntry())),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add subject'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              side: const BorderSide(color: _kPurple),
              foregroundColor: _kPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: d.subjectEntries.isEmpty ? null : _mergeSubjectWise,
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('Generate & merge timetable'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],

        // ── Timetable preview ──
        if (timetable.isNotEmpty) ...[
          const SizedBox(height: 16),
          _labelDivider('Generated timetable', context),
          const SizedBox(height: 8),
          ...timetable.map((day) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10)),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(day.day,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.blue)),
                  const Spacer(),
                  Text('${day.periods.length} periods',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.blue)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                    children: day.periods
                        .map((p) => Padding(
                      padding:
                      const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        Text(p.isLunchBreak ? '🍽️' : '📚',
                            style: const TextStyle(
                                fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                            '${p.startTime} – ${p.endTime}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        if (p.subject.isNotEmpty &&
                            !p.isLunchBreak) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(p.subject,
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                    Colors.blue.shade700),
                                overflow:
                                TextOverflow.ellipsis),
                          ),
                        ],
                      ]),
                    ))
                        .toList()),
              ),
            ]),
          )),
        ],

        // ── Advanced ──
        const SizedBox(height: 10),
        InkWell(
          onTap: () => setState(() => d.showAdvanced = !d.showAdvanced),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Icon(d.showAdvanced ? Icons.expand_less : Icons.expand_more,
                  size: 18, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('Advanced: customize periods manually',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
            ]),
          ),
        ),
        if (d.showAdvanced && timetable.isNotEmpty)
          _buildAdvancedEditor(timetable),
      ],
    );
  }

  Widget _modeTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? _kPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : Colors.black45)),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedEditor(List<TimetableDay> timetable) {
    return Column(
      children: timetable.asMap().entries.map((de) {
        final di = de.key;
        final day = de.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8, top: 4),
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: day.day,
                      isDense: true,
                      decoration: const InputDecoration(
                          labelText: 'Day',
                          border: OutlineInputBorder(),
                          isDense: true),
                      items: _weekdays
                          .map((d) =>
                          DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) => setState(() => day.day = val!),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                    onPressed: () {
                      final updated =
                      List<TimetableDay>.from(widget.timetable);
                      updated.removeAt(di);
                      widget.onTimetableChanged(updated);
                    },
                  ),
                ]),
                const SizedBox(height: 8),
                ...day.periods.asMap().entries.map((pe) {
                  final pi = pe.key;
                  final period = pe.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
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
                          decoration: const InputDecoration(
                              labelText: 'Start',
                              border: OutlineInputBorder(),
                              isDense: true),
                          onChanged: (v) => period.startTime = v,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          initialValue: period.endTime,
                          decoration: const InputDecoration(
                              labelText: 'End',
                              border: OutlineInputBorder(),
                              isDense: true),
                          onChanged: (v) => period.endTime = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.red, size: 18),
                        onPressed: () => setState(() {
                          final updated =
                          List<TimetableDay>.from(widget.timetable);
                          updated[di].periods.removeAt(pi);
                          widget.onTimetableChanged(updated);
                        }),
                      ),
                    ]),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() {
                    final updated =
                    List<TimetableDay>.from(widget.timetable);
                    updated[di]
                        .periods
                        .add(TimetablePeriod(
                        startTime: '09:00', endTime: '09:45'));
                    widget.onTimetableChanged(updated);
                  }),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add period'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  Main Screen
// ─────────────────────────────────────────────
class AddEditClassScreen extends StatefulWidget {
  final SchoolClass? existingClass;
  final bool showAppBar;
  final VoidCallback? onSaved;

  const AddEditClassScreen({
    super.key,
    this.existingClass,
    this.showAppBar = true,
    this.onSaved,
  });

  @override
  State<AddEditClassScreen> createState() => _AddEditClassScreenState();
}

class _AddEditClassScreenState extends State<AddEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _classNameController;

  // Class-level base name (shared prefix for all sections)
  String _classDisplayName = '';

  // Sections
  List<Section> _sections = [];
  final List<List<SubjectMark>> _sectionSubjectMarks = [];
  final List<_SectionTimetableData> _sectionTimetables = [];
  final List<List<TimetableDay>> _sectionTimetableDays = [];
  final List<TextEditingController> _sectionNameControllers = [];
  final List<TextEditingController> _headControllers = [];
  final List<TextEditingController> _annualFeeControllers = [];
  final List<TextEditingController> _regFeeControllers = [];
  final List<TextEditingController> _monthlyFeeControllers = [];

  bool _isSaving = false;
  bool _isClassAssigned = false;

  // Tracks which section is expanded (accordion on mobile)
  int _expandedSection = 0;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingClass;

    _classNameController =
        TextEditingController(text: existing?.name ?? '');
    _classDisplayName = _classNameController.text.trim();
    _classNameController.addListener(() {
      setState(() => _classDisplayName = _classNameController.text.trim());
    });

    // Load sections (or create default)
    final rawSections = existing?.sections != null
        ? List<Section>.from(existing!.sections)
        : <Section>[];
    if (rawSections.isEmpty) rawSections.add(Section(sectionName: ''));

    for (int i = 0; i < rawSections.length; i++) {
      _initSection(rawSections[i], i);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MuddulProvider>().startListening();
      if (widget.existingClass?.id != null) {
        final staffProvider = context.read<StaffProvider>();
        final allStaff = [
          ...staffProvider.teachers,
          ...staffProvider.staffOnly,
        ];
        final assigned = allStaff.any(
                (s) => s.assignedClasses.contains(widget.existingClass!.id));
        if (assigned && mounted) setState(() => _isClassAssigned = true);
      }
    });
  }

  void _initSection(Section sec, int i) {
    _sections.add(sec);
    _sectionSubjectMarks.add(List<SubjectMark>.from(sec.subjectMarks ?? []));

    // Parse section suffix from name
    final prefix = _classSectionPrefix();
    String suffix = sec.sectionName;
    if (suffix.startsWith(prefix)) suffix = suffix.substring(prefix.length);
    _sectionNameControllers.add(TextEditingController(text: suffix));
    _headControllers.add(
        TextEditingController(text: sec.headOfTeacher ?? ''));
    _annualFeeControllers.add(
        TextEditingController(text: sec.annualFee?.toString() ?? ''));
    _regFeeControllers.add(TextEditingController(
        text: sec.registrationFee?.toString() ?? ''));
    _monthlyFeeControllers.add(
        TextEditingController(text: sec.monthlyFee?.toString() ?? ''));

    final data = _SectionTimetableData();
    final days = <TimetableDay>[];
    if (sec.timetable != null && sec.timetable!.isNotEmpty) {
      for (final t in sec.timetable!) {
        days.add(TimetableDay(
            day: t.day,
            periods: t.periods
                .map((p) => TimetablePeriod(
                subject: p.subject,
                startTime: p.startTime,
                endTime: p.endTime,
                isLunchBreak: p.isLunchBreak))
                .toList()));
      }
      data.generatedDays = days.map((d) => d.day).toSet();
      if (days.isNotEmpty && days.first.periods.isNotEmpty) {
        data.startController.text = days.first.periods.first.startTime;
        data.endController.text = days.first.periods.last.endTime;
      }
    }
    _sectionTimetables.add(data);
    _sectionTimetableDays.add(days);
  }

  String _classSectionPrefix() {
    final name =
    _classDisplayName.trim().isEmpty ? 'Class' : _classDisplayName.trim();
    return '$name section ';
  }

  String _fullSectionName(int i) {
    return '${_classSectionPrefix()}${_sectionNameControllers[i].text.trim()}';
  }

  @override
  void dispose() {
    _classNameController.removeListener(() {});
    _classNameController.dispose();
    for (int i = 0; i < _sections.length; i++) {
      _sectionNameControllers[i].dispose();
      _headControllers[i].dispose();
      _annualFeeControllers[i].dispose();
      _regFeeControllers[i].dispose();
      _monthlyFeeControllers[i].dispose();
      _sectionTimetables[i].dispose();
    }
    super.dispose();
  }

  bool _isClassNameDuplicate(String name) {
    final normalized =
    name.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final classes = context.read<ClassProvider>().classes;
    final currentId = widget.existingClass?.id;
    for (final cls in classes) {
      if (currentId != null && cls.id == currentId) continue;
      if (cls.name.replaceAll(RegExp(r'\s+'), '').toLowerCase() ==
          normalized) return true;
    }
    return false;
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  void _addSection() {
    setState(() {
      final sec = Section(sectionName: '');
      _initSection(sec, _sections.length);
      _expandedSection = _sections.length - 1;
    });
  }

  void _removeSection(int i) {
    if (_sections.length <= 1) {
      _snack('At least one section is required');
      return;
    }
    setState(() {
      _sections.removeAt(i);
      _sectionSubjectMarks.removeAt(i);
      _sectionNameControllers[i].dispose();
      _sectionNameControllers.removeAt(i);
      _headControllers[i].dispose();
      _headControllers.removeAt(i);
      _annualFeeControllers[i].dispose();
      _annualFeeControllers.removeAt(i);
      _regFeeControllers[i].dispose();
      _regFeeControllers.removeAt(i);
      _monthlyFeeControllers[i].dispose();
      _monthlyFeeControllers.removeAt(i);
      _sectionTimetables[i].dispose();
      _sectionTimetables.removeAt(i);
      _sectionTimetableDays.removeAt(i);
      if (_expandedSection >= _sections.length) {
        _expandedSection = _sections.length - 1;
      }
    });
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Build sections
    final builtSections = <Section>[];
    for (int i = 0; i < _sections.length; i++) {
      builtSections.add(Section(
        sectionName: _fullSectionName(i),
        headOfTeacher: _headControllers[i].text.trim(),
        annualFee:
        double.tryParse(_annualFeeControllers[i].text),
        registrationFee:
        double.tryParse(_regFeeControllers[i].text),
        monthlyFee:
        double.tryParse(_monthlyFeeControllers[i].text),
        subjectMarks: List<SubjectMark>.from(_sectionSubjectMarks[i]),
        timetable: _sectionTimetableDays[i],
      ));
    }

    final schoolClass = SchoolClass(
      id: widget.existingClass?.id,
      name: _classNameController.text.trim(),
      // Class-level fields now derived from first section or left empty
      subjects: _sectionSubjectMarks.isNotEmpty
          ? List<SubjectMark>.from(_sectionSubjectMarks[0])
          : [],
      timetable: _sectionTimetableDays.isNotEmpty
          ? _sectionTimetableDays[0]
          : [],
      sections: builtSections,
    );

    try {
      final provider = context.read<ClassProvider>();
      if (widget.existingClass == null) {
        await provider.addClass(schoolClass);
      } else {
        await provider.updateClass(schoolClass);
      }
      widget.onSaved?.call();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        _snack('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── UI ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: widget.showAppBar ? _buildAppBar() : null,
      body: Form(
        key: _formKey,
        child: LayoutBuilder(builder: (ctx, constraints) {
          final isDesktop = constraints.maxWidth >= _kDesktopBreak;
          return isDesktop
              ? _buildDesktopLayout()
              : _buildMobileLayout();
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
          widget.existingClass == null ? 'Add class' : 'Edit class',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      surfaceTintColor: Colors.white,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Mobile Layout
  // ─────────────────────────────────────────
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClassNameCard(),
                const SizedBox(height: 16),
                _buildSectionsHeader(),
                const SizedBox(height: 10),
                ..._sections.asMap().entries.map((e) =>
                    _buildMobileSectionCard(e.key)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildSaveBar(),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Desktop Layout
  // ─────────────────────────────────────────
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left panel: class name + sections list
              Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      right:
                      BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildClassNameCard(),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: _buildSectionsHeader(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _sections.length,
                        itemBuilder: (ctx, i) =>
                            _buildDesktopSectionTab(i),
                      ),
                    ),
                  ],
                ),
              ),
              // Right panel: expanded section details
              Expanded(
                child: _sections.isEmpty
                    ? const Center(
                    child: Text('No sections yet'))
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildSectionDetails(
                      _expandedSection),
                ),
              ),
            ],
          ),
        ),
        _buildSaveBar(),
      ],
    );
  }

  // ─── Class name card ──────────────────────
  Widget _buildClassNameCard() {
    return _styledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Class name',
              icon: Icons.class_outlined, iconColor: _kPurple),
          const SizedBox(height: 14),
          TextFormField(
            controller: _classNameController,
            readOnly: _isClassAssigned,
            decoration: InputDecoration(
              hintText: 'e.g. Grade 5, Class 8, KG',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: _kPurple, width: 1.5),
              ),
              prefixIcon: const Icon(Icons.class_, size: 18),
              filled: _isClassAssigned,
              fillColor:
              _isClassAssigned ? Colors.grey.shade100 : null,
              suffixIcon: _isClassAssigned
                  ? Tooltip(
                  message:
                  'Remove from all staff to rename',
                  child: Icon(Icons.lock_outline,
                      color: Colors.orange.shade400, size: 18))
                  : null,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'Enter class name';
              if (_isClassNameDuplicate(v.trim()))
                return 'Class name already exists';
              return null;
            },
          ),
          if (_isClassAssigned) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(children: [
                Icon(Icons.info_outline,
                    size: 15, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Class is assigned to staff. Name locked.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800)),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _kPurpleLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: _kPurple),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Section names will auto-prefix with this class name',
                  style: const TextStyle(
                      fontSize: 11, color: _kPurple),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ─── Sections header row ──────────────────
  Widget _buildSectionsHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sections',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              Text(
                '${_sections.length} section${_sections.length != 1 ? 's' : ''}',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _addSection,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            textStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ─── Desktop: left-panel section tab ─────
  Widget _buildDesktopSectionTab(int i) {
    final isActive = _expandedSection == i;
    final suffix = _sectionNameControllers[i].text.trim();
    final displayName = suffix.isEmpty
        ? 'Section ${i + 1}'
        : '${_classSectionPrefix()}$suffix';

    return GestureDetector(
      onTap: () => setState(() => _expandedSection = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _kPurpleLight : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? _kPurpleMid : Colors.grey.shade200,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? _kPurple : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('${i + 1}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : Colors.grey)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? _kPurple
                            : Colors.black87)),
                if (_sectionSubjectMarks[i].isNotEmpty)
                  Text(
                      '${_sectionSubjectMarks[i].length} subjects',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (_sections.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 16, color: Colors.red),
              onPressed: () => _removeSection(i),
              padding: EdgeInsets.zero,
              constraints:
              const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
        ]),
      ),
    );
  }

  // ─── Mobile: accordion section card ──────
  Widget _buildMobileSectionCard(int i) {
    final isOpen = _expandedSection == i;
    final suffix = _sectionNameControllers[i].text.trim();
    final displayName = suffix.isEmpty
        ? 'Section ${i + 1}'
        : '${_classSectionPrefix()}$suffix';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen ? _kPurpleMid : Colors.grey.shade200,
          width: isOpen ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Accordion header
          InkWell(
            onTap: () => setState(
                    () => _expandedSection = isOpen ? -1 : i),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isOpen ? _kPurple : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isOpen
                                ? Colors.white
                                : Colors.grey.shade600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (_sectionSubjectMarks[i].isNotEmpty)
                        Text(
                            '${_sectionSubjectMarks[i].length} subjects selected',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                if (_sections.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                    onPressed: () => _removeSection(i),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 32, minHeight: 32),
                  ),
                const SizedBox(width: 4),
                Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400),
              ]),
            ),
          ),
          // Content
          if (isOpen)
            Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildSectionDetails(i),
            ),
        ],
      ),
    );
  }

  // ─── Section details (shared between mobile/desktop) ──
  Widget _buildSectionDetails(int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Section name
        _styledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, 'Section name',
                  icon: Icons.badge_outlined),
              const SizedBox(height: 14),
              TextFormField(
                controller: _sectionNameControllers[i],
                decoration: InputDecoration(
                  hintText: 'e.g. A, Blue, Morning',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: _kPurple, width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.group_outlined, size: 18),
                  prefixText: _classSectionPrefix().isEmpty
                      ? null
                      : _classSectionPrefix(),
                  prefixStyle: TextStyle(
                      color: Colors.grey.shade500, fontSize: 14),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty
                    ? 'Enter section suffix (e.g. A)'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Head teacher
        _styledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, 'Head of section',
                  icon: Icons.person_outline),
              const SizedBox(height: 14),
              TextFormField(
                controller: _headControllers[i],
                decoration: InputDecoration(
                  hintText: 'Teacher name (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: _kPurple, width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.person, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Fee structure
        _styledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, 'Fee structure (optional)',
                  icon: Icons.payments_outlined,
                  iconColor: const Color(0xFF2E7D32)),
              const SizedBox(height: 14),
              _feeField('Annual Fund', _annualFeeControllers[i]),
              const SizedBox(height: 10),
              _feeField(
                  'Registration fee', _regFeeControllers[i]),
              const SizedBox(height: 10),
              _feeField('Monthly fee', _monthlyFeeControllers[i]),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Subjects & Marks
        _styledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, 'Subjects & marks',
                  icon: Icons.menu_book_outlined,
                  iconColor: const Color(0xFF1565C0)),
              const SizedBox(height: 4),
              Text('Tap to select subjects and set marks',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 14),
              _SubjectMarkSelector(
                selectedSubjectMarks: _sectionSubjectMarks[i],
                onChanged: (updated) =>
                    setState(() => _sectionSubjectMarks[i] = updated),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 5. Timetable
        _styledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, 'Timetable',
                  icon: Icons.schedule_outlined,
                  iconColor: const Color(0xFFE65100)),
              const SizedBox(height: 14),
              _TimetableBuilder(
                data: _sectionTimetables[i],
                timetable: _sectionTimetableDays[i],
                onChanged: () => setState(() {}),
                onTimetableChanged: (days) =>
                    setState(() => _sectionTimetableDays[i] = days),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _feeField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPurple, width: 1.5),
        ),
        prefixText: 'Rs ',
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
    );
  }

  // ─── Save bar ─────────────────────────────
  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
        Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveClass,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPurple,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : Text(
                widget.existingClass == null
                    ? 'Save class'
                    : 'Update class',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}