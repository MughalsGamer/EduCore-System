import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/exam_result_card_model.dart';
import '../../providers/student_provider.dart'; // for StudentWithContext

/// Generates one A4 page per student, styled after the school's printed
/// "Student's Result Card" template (double border frame, school header
/// with logo, marks table, auto-calculated percentage/position, and a
/// developer credit line at the bottom).
class ResultCardPdfGenerator {
  static const String schoolName = 'JS GRAMMER SCHOOL';
  static const String schoolAddress =
      'Gala Peer kando, Opposite Koti Rustam, Hafizabad Road GRW';
  static const String schoolContact = '0331-8424324';
  static const String developerCredit = 'Developed by Ali Haider — 0300-7465064';
  static const String logoAssetPath = 'assets/images/Logo.png';

  /// Builds a multi-page PDF, one page per (student, exam-card) result.
  ///
  /// [results] must all share reasonably similar subject sets per card;
  /// each result's own [ExamResultCard.subjects] is used for that page so
  /// mixed exams/classes are handled correctly.
  static Future<Uint8List> generate({
    required List<ResultCardPdfEntry> results,
  }) async {
    final doc = pw.Document();

    // Load the school logo once and reuse across all pages.
    pw.ImageProvider? logoImage;
    try {
      final logoBytes = await rootBundle.load(logoAssetPath);
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      logoImage = null; // Fall back gracefully if the asset is missing.
    }

    for (final entry in results) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => _buildPage(entry, logoImage),
        ),
      );
    }

    return doc.save();
  }

  static pw.Widget _buildPage(
      ResultCardPdfEntry entry, pw.ImageProvider? logoImage) {
    final borderColor = PdfColor.fromInt(0xFF1A237E); // deep navy blue

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 2.4),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 0.8),
        ),
        padding: const pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(entry, logoImage, borderColor),
            pw.SizedBox(height: 14),
            _buildExamLine(entry),
            pw.SizedBox(height: 10),
            _buildInfoLines(entry),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                'Marks Detail',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF7B1FA2),
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            _buildMarksTable(entry, borderColor),
            pw.SizedBox(height: 16),
            _buildSummaryRow(entry),
            pw.Spacer(),
            _buildSignatureRow(entry),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.grey400, thickness: 0.5),
            pw.Center(
              child: pw.Text(
                developerCredit,
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildHeader(
      ResultCardPdfEntry entry, pw.ImageProvider? logoImage, PdfColor borderColor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logoImage != null)
          pw.Container(
            width: 62,
            height: 62,
            child: pw.Image(logoImage, fit: pw.BoxFit.contain),
          )
        else
          pw.Container(width: 62, height: 62),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor, width: 1),
                ),
                child: pw.Text(
                  "Student's Result Card",
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: double.infinity,
                padding:
                const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: PdfColors.black,
                child: pw.Text(
                  schoolName,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                schoolAddress,
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
              pw.Text(
                'Contact # $schoolContact',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildExamLine(ResultCardPdfEntry entry) {
    return pw.Row(
      children: [
        pw.Text(
          'Exam ',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF2E7D32),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF2E7D32), width: 1),
              ),
            ),
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              entry.card.examName,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoLines(ResultCardPdfEntry entry) {
    pw.Widget line(String label, String value, {double flex = 1}) {
      return pw.Expanded(
        flex: flex.round(),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(label,
                style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 4),
            pw.Expanded(
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.7),
                  ),
                ),
                padding: const pw.EdgeInsets.only(bottom: 1),
                child: pw.Text(value, style: const pw.TextStyle(fontSize: 10.5)),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        line("Student's Name: ", entry.studentName),
        pw.SizedBox(height: 8),
        line('Father Name ', entry.fatherName),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            line('Class: ', entry.className, flex: 1),
            pw.SizedBox(width: 10),
            line('Section ', entry.sectionName, flex: 1),
            pw.SizedBox(width: 10),
            line('Roll No. ', entry.rollNo, flex: 1),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildMarksTable(ResultCardPdfEntry entry, PdfColor borderColor) {
    final subjects = entry.card.subjects;
    final obtained = entry.marks.obtainedMarks;

    int totalMax = 0;
    double totalObtained = 0;
    for (final s in subjects) {
      totalMax += s.totalMarks;
      totalObtained += obtained[s.name] ?? 0;
    }

    final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final cellStyle = const pw.TextStyle(fontSize: 10);
    final border = pw.TableBorder.all(color: borderColor, width: 0.7);

    return pw.Table(
      border: border,
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FlexColumnWidth(3.4),
        2: const pw.FlexColumnWidth(1.3),
        3: const pw.FlexColumnWidth(1.3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0F0F5)),
          children: [
            _cell('Sr.#', headerStyle, center: true),
            _cell('Subjects', headerStyle),
            _cell('Maximum', headerStyle, center: true),
            _cell('Obtained', headerStyle, center: true),
          ],
        ),
        for (var i = 0; i < subjects.length; i++)
          pw.TableRow(
            children: [
              _cell('${i + 1}.', cellStyle, center: true),
              _cell(subjects[i].name, cellStyle),
              _cell('${subjects[i].totalMarks}', cellStyle, center: true),
              _cell(_formatMarks(obtained[subjects[i].name] ?? 0), cellStyle,
                  center: true),
            ],
          ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0F0F5)),
          children: [
            pw.SizedBox(),
            _cell('Total', headerStyle, center: true),
            _cell('$totalMax', headerStyle, center: true),
            _cell(_formatMarks(totalObtained), headerStyle, center: true),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(String text, pw.TextStyle style, {bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: style,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static String _formatMarks(double v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  static pw.Widget _buildSummaryRow(ResultCardPdfEntry entry) {
    pw.Widget item(String label, String value) {
      return pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 4),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      );
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        item('Marks Percentage ', '${entry.percentage.toStringAsFixed(1)}%'),
        item('Position in Class ', entry.positionLabel),
      ],
    );
  }

  static pw.Widget _buildSignatureRow(ResultCardPdfEntry entry) {
    pw.Widget sigBlock(String label) {
      return pw.Expanded(
        child: pw.Column(
          children: [
            pw.Container(
              width: double.infinity,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 0.7),
                ),
              ),
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(
                label,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      children: [
        pw.Row(
          children: [
            sigBlock('Sign of Class Incharge'),
            pw.SizedBox(width: 20),
            sigBlock('Sign of Principal'),
            pw.SizedBox(width: 20),
            sigBlock(
                'Result Declaration Date\n${DateFormat('dd MMM yyyy').format(entry.card.date)}'),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'PDF generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
          ),
        ),
      ],
    );
  }
}

/// One resolved (student + exam card) pairing ready to be rendered as a
/// single PDF page, with percentage/position already computed against the
/// rest of the class taking the same exam card.
class ResultCardPdfEntry {
  final ExamResultCard card;
  final StudentExamMarks marks;
  final String studentName;
  final String fatherName;
  final String className;
  final String sectionName;
  final String rollNo;
  final double percentage;
  final String positionLabel;

  ResultCardPdfEntry({
    required this.card,
    required this.marks,
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.sectionName,
    required this.rollNo,
    required this.percentage,
    required this.positionLabel,
  });
}

/// Computes percentage and class position (ranked by percentage, within
/// the same exam card) for every student on that card, and returns ready
/// [ResultCardPdfEntry] objects for the given (studentId, cardId) pairs.
///
/// [studentLookup] resolves a studentId to its [StudentWithContext] so we
/// can pull name/father/roll — pass a map built from the roster you
/// already have loaded (e.g. `StudentProvider.allActiveStudents`).
List<ResultCardPdfEntry> buildResultCardEntries({
  required List<MapEntry<ExamResultCard, StudentExamMarks>> selected,
  required Map<String, StudentWithContext> studentLookup,
}) {
  // Group by card so percentage/position is computed within the same exam.
  final byCard = <String, List<StudentExamMarks>>{};
  for (final e in selected) {
    final cardId = e.key.id ?? e.key.examName + e.key.date.toIso8601String();
    byCard.putIfAbsent(cardId, () => []);
    if (!byCard[cardId]!.any((m) => m.studentId == e.value.studentId)) {
      byCard[cardId]!.add(e.value);
    }
  }

  // Precompute percentage for every student on every relevant card, then
  // rank per card.
  final cardById = <String, ExamResultCard>{};
  for (final e in selected) {
    final cardId = e.key.id ?? e.key.examName + e.key.date.toIso8601String();
    cardById[cardId] = e.key;
  }

  final percentageByCardAndStudent = <String, Map<String, double>>{};
  for (final cardId in byCard.keys) {
    final card = cardById[cardId]!;
    final totalMax =
    card.subjects.fold<int>(0, (sum, s) => sum + s.totalMarks);
    final map = <String, double>{};
    for (final sm in byCard[cardId]!) {
      final obtained = card.subjects.fold<double>(
          0, (sum, s) => sum + (sm.obtainedMarks[s.name] ?? 0));
      map[sm.studentId] = totalMax > 0 ? (obtained / totalMax) * 100 : 0;
    }
    percentageByCardAndStudent[cardId] = map;
  }

  final rankByCardAndStudent = <String, Map<String, int>>{};
  for (final cardId in percentageByCardAndStudent.keys) {
    final entries = percentageByCardAndStudent[cardId]!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final ranks = <String, int>{};
    int rank = 0;
    double? lastPct;
    int seen = 0;
    for (final e in entries) {
      seen++;
      if (lastPct == null || e.value < lastPct) {
        rank = seen;
        lastPct = e.value;
      }
      ranks[e.key] = rank;
    }
    rankByCardAndStudent[cardId] = ranks;
  }

  final results = <ResultCardPdfEntry>[];
  for (final e in selected) {
    final card = e.key;
    final sm = e.value;
    final cardId = card.id ?? card.examName + card.date.toIso8601String();
    final student = studentLookup[sm.studentId];

    final pct = percentageByCardAndStudent[cardId]?[sm.studentId] ?? 0;
    final rank = rankByCardAndStudent[cardId]?[sm.studentId];
    final classSize = byCard[cardId]?.length ?? 0;

    results.add(ResultCardPdfEntry(
      card: card,
      marks: sm,
      studentName: student?.student.name ?? sm.studentName,
      fatherName: student?.fatherName ?? '',
      className: card.className,
      sectionName: card.sectionName,
      rollNo: student?.student.studentId ?? sm.studentId,
      percentage: pct,
      positionLabel: rank != null ? '$rank of $classSize' : '-',
    ));
  }

  return results;
}