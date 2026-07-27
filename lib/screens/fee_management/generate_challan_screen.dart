import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admission_model.dart';
import '../../models/fee_challan_model.dart';
import '../../providers/admission_provider.dart';
import '../../providers/fee_challan_provider.dart';
import 'challan_list_screen.dart';

// ─────────────────────────────────────────────
//  Generate Fee Challan Screen
//  Family-wise (class filter skipped), Regular admissions only.
//  Auto-generation (28th of month) is NOT wired up here — this
//  screen is manual-only. Generated Date / Due Date are shown
//  pre-filled with the 28th / next-month-10th defaults but are
//  fully editable before hitting Generate.
//
//  Duplicate prevention is STUDENT-LEVEL, not family-level:
//  a family already fully challaned for the month is skipped, but a
//  family with a newly-added student (not present in that earlier
//  challan) is still selectable — only the new student's line gets
//  generated.
// ─────────────────────────────────────────────
class GenerateChallanScreen extends StatelessWidget {
  const GenerateChallanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeeChallanProvider(),
      child: const _GenerateChallanView(),
    );
  }
}

class _GenerateChallanView extends StatefulWidget {
  const _GenerateChallanView();

  @override
  State<_GenerateChallanView> createState() => _GenerateChallanViewState();
}

class _GenerateChallanViewState extends State<_GenerateChallanView> {
  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  late int _billingMonth;
  late int _billingYear;
  late DateTime _generatedDate;
  late DateTime _dueDate;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedFamilyDocIds = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _billingMonth = now.month;
    _billingYear = now.year;
    _generatedDate = _defaultGeneratedDate(_billingMonth, _billingYear);
    _dueDate = _defaultDueDate(_billingMonth, _billingYear);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<FeeChallanProvider>()
          .refreshAlreadyGenerated(_billingMonth, _billingYear);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // DateTime _defaultGeneratedDate(int month, int year) => DateTime(year, month, 28);
  DateTime _defaultGeneratedDate(int month, int year) => DateTime(year, month, 1);


  // DateTime _defaultDueDate(int month, int year) {
  //   final nextMonth = month == 12 ? 1 : month + 1;
  //   final nextYear = month == 12 ? year + 1 : year;
  //   return DateTime(nextYear, nextMonth, 10);
  // }
  DateTime _defaultDueDate(int month, int year) => DateTime(year, month, 10);


  void _onBillingMonthYearChanged() {
    setState(() {
      _generatedDate = _defaultGeneratedDate(_billingMonth, _billingYear);
      _dueDate = _defaultDueDate(_billingMonth, _billingYear);
      _selectedFamilyDocIds.clear();
    });
    context.read<FeeChallanProvider>().clearResults();
    context
        .read<FeeChallanProvider>()
        .refreshAlreadyGenerated(_billingMonth, _billingYear);
  }

  // Regular admissions only, grouped by familyDocId. Class filtering
  // is skipped — every regular student in the family rides along.
  List<FamilyForChallan> _buildEligibleFamilies(List<AdmissionModel> admissions) {
    final regular = admissions.where((a) => a.type == AdmissionType.regular).toList();

    final Map<String, List<AdmissionModel>> grouped = {};
    for (final a in regular) {
      if (a.familyDocId.isEmpty) continue; // needs a valid family link
      grouped.putIfAbsent(a.familyDocId, () => []).add(a);
    }

    final List<FamilyForChallan> result = [];
    grouped.forEach((familyDocId, admissionsForFamily) {
      final rep = admissionsForFamily.first;
      final students = admissionsForFamily
          .expand((a) => a.students)
          .where((s) => s.studentId.isNotEmpty)
          .toList();
      if (students.isEmpty) return;

      result.add(FamilyForChallan(
        familyDocId: familyDocId,
        familyId: rep.familyId,
        familyName: rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
        fatherName: rep.fatherName,
        fatherPhone: rep.fatherPhone,
        students: students,
      ));
    });

    result.sort(
            (a, b) => a.familyName.toLowerCase().compareTo(b.familyName.toLowerCase()));
    return result;
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final admissions = context.watch<AdmissionProvider>().admissions;
    final eligibleFamilies = _buildEligibleFamilies(admissions);

    final filtered = eligibleFamilies.where((f) {
      final q = _searchQuery.toLowerCase();
      return q.isEmpty ||
          f.familyName.toLowerCase().contains(q) ||
          f.fatherName.toLowerCase().contains(q) ||
          f.familyId.toLowerCase().contains(q) ||
          f.fatherPhone.contains(q);
    }).toList();

    final challanProvider = context.watch<FeeChallanProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text('Generate Fee Challan'),
        centerTitle: true,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Challan List',
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<FeeChallanProvider>(),
                    child: const ChallanListScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          if (challanProvider.error != null) _buildErrorBanner(challanProvider),
          if (challanProvider.lastGeneratedChallans.isNotEmpty ||
              challanProvider.lastGenerationSkippedCount > 0)
            _buildResultsBanner(challanProvider),
          _buildSearchAndSelectAll(filtered, challanProvider),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final family = filtered[i];
                final fullyDone = challanProvider.isFamilyFullyGenerated(family);
                final partiallyDone =
                challanProvider.isFamilyPartiallyGenerated(family);
                final eligibleCount =
                    challanProvider.eligibleStudentsFor(family).length;
                final selected = _selectedFamilyDocIds.contains(family.familyDocId);
                return _FamilySelectTile(
                  family: family,
                  selected: selected,
                  fullyGenerated: fullyDone,
                  partiallyGenerated: partiallyDone,
                  eligibleStudentCount: eligibleCount,
                  onTap: fullyDone
                      ? null
                      : () {
                    setState(() {
                      if (selected) {
                        _selectedFamilyDocIds.remove(family.familyDocId);
                      } else {
                        _selectedFamilyDocIds.add(family.familyDocId);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(eligibleFamilies, challanProvider),
    );
  }

  // ── Date + Month/Year Header ──
  Widget _buildDateHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF534AB7), Color(0xFF6C63CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Billing Month',
              style: TextStyle(
                  color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 3, child: _monthDropdown()),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _yearDropdown()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _dateField('Generated Date', _generatedDate,
                        (d) => setState(() => _generatedDate = d)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateField('Due Date (Last Date)', _dueDate,
                        (d) => setState(() => _dueDate = d)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _billingMonth,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
          items: List.generate(12, (i) => i + 1)
              .map((m) => DropdownMenuItem(
            value: m,
            child: Text(FeeChallanModel.monthNames[m],
                style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _billingMonth = v);
            _onBillingMonthYearChanged();
          },
        ),
      ),
    );
  }

  // Year list is generated relative to today's date every time this
  // widget builds (currentYear - 1 .. currentYear + 4), so it always
  // includes the current year and automatically slides forward into
  // 2030, 2031, etc. with no manual code update ever needed. As a
  // safety net, _billingYear is folded in too, in case it was ever
  // set outside this range (e.g. editing an old record).
  Widget _yearDropdown() {
    final currentYear = DateTime.now().year;
    final years = {currentYear - 1, currentYear, currentYear + 1, currentYear + 2,
      currentYear + 3, currentYear + 4, _billingYear}.toList()
      ..sort();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _billingYear,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
          items: years
              .map((y) => DropdownMenuItem(
            value: y,
            child: Text('$y', style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => _billingYear = v);
            _onBillingMonthYearChanged();
          },
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime value, ValueChanged<DateTime> onPicked) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(_fmt(value),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Error banner ──
  Widget _buildErrorBanner(FeeChallanProvider p) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(p.error!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade400, size: 18),
            onPressed: p.clearError,
          ),
        ],
      ),
    );
  }

  // ── Results banner (post-generation preview) ──
  Widget _buildResultsBanner(FeeChallanProvider p) {
    final count = p.lastGeneratedChallans.length;
    final skipped = p.lastGenerationSkippedCount;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  count > 0
                      ? '$count challan${count != 1 ? 's' : ''} generated'
                      '${skipped > 0 ? ' • $skipped skipped (already generated)' : ''}'
                      : 'All selected families already have a challan for this month',
                  style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.green.shade400, size: 18),
                onPressed: p.clearResults,
              ),
            ],
          ),
          if (count > 0) ...[
            const SizedBox(height: 4),
            ...p.lastGeneratedChallans.map((c) => _GeneratedChallanCard(challan: c)),
          ],
        ],
      ),
    );
  }

  // ── Search + Select All ──
  Widget _buildSearchAndSelectAll(List<FamilyForChallan> filtered, FeeChallanProvider p) {
    final selectableIds = filtered
        .where((f) => !p.isFamilyFullyGenerated(f))
        .map((f) => f.familyDocId)
        .toSet();
    final allSelected =
        selectableIds.isNotEmpty && selectableIds.every(_selectedFamilyDocIds.contains);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search family...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: _purple, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: selectableIds.isEmpty
                ? null
                : () {
              setState(() {
                if (allSelected) {
                  _selectedFamilyDocIds.removeAll(selectableIds);
                } else {
                  _selectedFamilyDocIds.addAll(selectableIds);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: _lightPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                allSelected ? 'Clear All' : 'Select All',
                style:
                const TextStyle(color: _purple, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No eligible family found' : 'No search results found',
            style:
            TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            'Only students with Regular admission are eligible',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Bottom action bar ──
  Widget _buildBottomBar(List<FamilyForChallan> eligibleFamilies, FeeChallanProvider p) {
    final selectedFamilies = eligibleFamilies
        .where((f) => _selectedFamilyDocIds.contains(f.familyDocId))
        .toList();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${selectedFamilies.length} family selected',
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: (selectedFamilies.isEmpty || p.isGenerating)
                  ? null
                  : () => _confirmAndGenerate(selectedFamilies),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: p.isGenerating
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Generate Challan', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndGenerate(List<FamilyForChallan> selected) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Challans?'),
        content: Text(
            'Challans will be generated for ${selected.length} famil${selected.length != 1 ? 'ies' : 'y'} '
                'for ${FeeChallanModel.monthNames[_billingMonth]} $_billingYear.\n\n'
                'Generated Date: ${_fmt(_generatedDate)}\nDue Date: ${_fmt(_dueDate)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _purple, foregroundColor: Colors.white),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    await context.read<FeeChallanProvider>().generateChallans(
      families: selected,
      month: _billingMonth,
      year: _billingYear,
      generatedDate: _generatedDate,
      dueDate: _dueDate,
    );

    if (!mounted) return;
    setState(() => _selectedFamilyDocIds.clear());
  }
}

// ─────────────────────────────────────────────
//  Family Select Tile
// ─────────────────────────────────────────────
class _FamilySelectTile extends StatelessWidget {
  final FamilyForChallan family;
  final bool selected;
  final bool fullyGenerated;
  final bool partiallyGenerated;
  final int eligibleStudentCount;
  final VoidCallback? onTap;

  const _FamilySelectTile({
    required this.family,
    required this.selected,
    required this.fullyGenerated,
    required this.partiallyGenerated,
    required this.eligibleStudentCount,
    required this.onTap,
  });

  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  @override
  Widget build(BuildContext context) {
    final totalMonthly =
    family.students.fold<double>(0, (s, st) => s + (st.monthlyFee ?? 0));

    return Opacity(
      opacity: fullyGenerated ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: selected ? 3 : 1,
        shadowColor: _purple.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? _purple : Colors.transparent, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  fullyGenerated
                      ? Icons.check_circle
                      : (selected ? Icons.check_circle : Icons.circle_outlined),
                  color: fullyGenerated
                      ? Colors.green.shade400
                      : (selected ? _purple : Colors.grey.shade300),
                  size: 22,
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _lightPurple,
                  child: Text(
                    family.familyName.isNotEmpty ? family.familyName[0].toUpperCase() : 'F',
                    style: const TextStyle(color: _purple, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(family.familyName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(
                        '${family.students.length} student${family.students.length != 1 ? 's' : ''} • ${family.fatherName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (partiallyGenerated) ...[
                        const SizedBox(height: 3),
                        Text(
                          '$eligibleStudentCount new student(s) — the rest already have a challan',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (totalMonthly > 0)
                      Text('Rs ${totalMonthly.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: _purple, fontSize: 13)),
                    if (fullyGenerated)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Generated',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )
                    else if (partiallyGenerated)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Partial',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Generated Challan Card — expandable, per-student breakdown
// ─────────────────────────────────────────────
class _GeneratedChallanCard extends StatefulWidget {
  final FeeChallanModel challan;
  const _GeneratedChallanCard({required this.challan});

  @override
  State<_GeneratedChallanCard> createState() => _GeneratedChallanCardState();
}

class _GeneratedChallanCardState extends State<_GeneratedChallanCard> {
  bool _expanded = false;
  static const _purple = Color(0xFF534AB7);

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final c = widget.challan;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.challanNumber} — ${c.familyName}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('${c.monthLabel} ${c.year}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Text('Rs ${c.grandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: _purple, fontSize: 13)),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade400, size: 18),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 12),
                  ...c.students.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(s.name,
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  if (s.isFirstChallan) ...[
                                    const SizedBox(width: 5),
                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('1st Challan',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text('Rs ${s.lineTotal.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        if (s.isFirstChallan) ...[
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Admission: Rs ${s.registrationFee.toStringAsFixed(0)}  •  '
                                  'Annual: Rs ${s.annualFee.toStringAsFixed(0)}  •  '
                                  'Monthly: Rs ${s.monthlyFee.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )),
                  const Divider(height: 12),
                  _totalRow('Current Month', c.currentMonthTotal),
                  if (c.previousBalance > 0) _totalRow('Previous Balance', c.previousBalance),
                  if (c.previousBalance < 0) _totalRow('Advance Carried Forward', c.previousBalance),
                  _totalRow('Grand Total', c.grandTotal, bold: true),
                  const SizedBox(height: 4),
                  Text('Due: ${_fmtDate(c.dueDate)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: bold ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
          Text('Rs ${value.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 12,
                  color: bold ? _purple : Colors.black87,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
        ],
      ),
    );
  }
}
//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// // ─────────────────────────────────────────────
// //  Per-Student Line Item inside a Challan
// //  First-ever challan for a student carries
// //  Admission (registration) + Annual + Monthly.
// //  Every challan after that carries Monthly only.
// // ─────────────────────────────────────────────
// class ChallanStudentLine {
//   String studentId;
//   String name;
//   String? className;
//   String? sectionName;
//   double monthlyFee;
//   double annualFee;        // > 0 only when isFirstChallan == true
//   double registrationFee;  // > 0 only when isFirstChallan == true (Admission Fee)
//   bool isFirstChallan;
//
//   ChallanStudentLine({
//     required this.studentId,
//     required this.name,
//     this.className,
//     this.sectionName,
//     this.monthlyFee = 0,
//     this.annualFee = 0,
//     this.registrationFee = 0,
//     this.isFirstChallan = false,
//   });
//
//   double get lineTotal => monthlyFee + annualFee + registrationFee;
//
//   Map<String, dynamic> toMap() => {
//     'studentId': studentId,
//     'name': name,
//     'className': className,
//     'sectionName': sectionName,
//     'monthlyFee': monthlyFee,
//     'annualFee': annualFee,
//     'registrationFee': registrationFee,
//     'isFirstChallan': isFirstChallan,
//   };
//
//   factory ChallanStudentLine.fromMap(Map<String, dynamic> m) => ChallanStudentLine(
//     studentId: m['studentId'] ?? '',
//     name: m['name'] ?? '',
//     className: m['className'],
//     sectionName: m['sectionName'],
//     monthlyFee: (m['monthlyFee'] as num?)?.toDouble() ?? 0,
//     annualFee: (m['annualFee'] as num?)?.toDouble() ?? 0,
//     registrationFee: (m['registrationFee'] as num?)?.toDouble() ?? 0,
//     isFirstChallan: m['isFirstChallan'] ?? false,
//   );
// }
//
// // ─────────────────────────────────────────────
// //  Fee Challan — one document per family, per billing month.
// //
// //  There is intentionally NO separate "ledger" collection.
// //  Per the original scenario design, the ledger is a runtime
// //  view that combines these challans (Debit) with fee_collections
// //  (Credit, once that payment screen is built). This challan
// //  document IS the debit-side ledger entry.
// // ─────────────────────────────────────────────
// class FeeChallanModel {
//   String? id;
//   String challanNumber;      // e.g. CH-0001
//
//   String familyDocId;        // Firestore doc id of the family (families collection)
//   String familyId;           // Human-readable, e.g. KHA-0001
//   String familyName;
//   String fatherName;
//   String fatherPhone;
//
//   int month;                 // 1-12, billing month (not necessarily == generatedDate.month)
//   int year;
//
//   DateTime generatedDate;    // When this challan was actually generated/printed
//   DateTime dueDate;          // Last date to pay
//
//   List<ChallanStudentLine> students;
//
//   double currentMonthTotal;  // sum of all student lineTotal for this challan
//   double previousBalance;    // running balance carried from earlier challans
//   double amountPaid;         // 0 until a payment/collection screen updates it
//
//   DateTime createdAt;
//
//   FeeChallanModel({
//     this.id,
//     this.challanNumber = '',
//     this.familyDocId = '',
//     this.familyId = '',
//     this.familyName = '',
//     this.fatherName = '',
//     this.fatherPhone = '',
//     required this.month,
//     required this.year,
//     required this.generatedDate,
//     required this.dueDate,
//     List<ChallanStudentLine>? students,
//     this.currentMonthTotal = 0,
//     this.previousBalance = 0,
//     this.amountPaid = 0,
//     DateTime? createdAt,
//   })  : students = students ?? [],
//         createdAt = createdAt ?? DateTime.now();
//
//   double get grandTotal => currentMonthTotal + previousBalance;
//   double get remainingBalance => grandTotal - amountPaid;
//
//   /// negative previousBalance handling is automatic here — if a future
//   /// payment screen ever pays MORE than grandTotal, remainingBalance goes
//   /// negative and the NEXT challan's previousBalance will pick that up as
//   /// an advance credit, exactly like the original scenario doc describes.
//   String get status {
//     if (amountPaid <= 0) return 'pending';
//     if (amountPaid >= grandTotal) return 'paid';
//     return 'partial';
//   }
//
//   List<String> get studentIds => students.map((s) => s.studentId).toList();
//
//   Map<String, dynamic> toMap() => {
//     'challanNumber': challanNumber,
//     'familyDocId': familyDocId,
//     'familyId': familyId,
//     'familyName': familyName,
//     'fatherName': fatherName,
//     'fatherPhone': fatherPhone,
//     'month': month,
//     'year': year,
//     'generatedDate': generatedDate.toIso8601String(),
//     'dueDate': dueDate.toIso8601String(),
//     'students': students.map((s) => s.toMap()).toList(),
//     'studentIds': studentIds,
//     'currentMonthTotal': currentMonthTotal,
//     'previousBalance': previousBalance,
//     'amountPaid': amountPaid,
//     'createdAt': FieldValue.serverTimestamp(),
//   };
//
//   factory FeeChallanModel.fromFirestore(DocumentSnapshot doc) {
//     final m = doc.data() as Map<String, dynamic>;
//     return FeeChallanModel(
//       id: doc.id,
//       challanNumber: m['challanNumber'] ?? '',
//       familyDocId: m['familyDocId'] ?? '',
//       familyId: m['familyId'] ?? '',
//       familyName: m['familyName'] ?? '',
//       fatherName: m['fatherName'] ?? '',
//       fatherPhone: m['fatherPhone'] ?? '',
//       month: (m['month'] as num?)?.toInt() ?? 1,
//       year: (m['year'] as num?)?.toInt() ?? DateTime.now().year,
//       generatedDate: m['generatedDate'] != null
//           ? DateTime.tryParse(m['generatedDate']) ?? DateTime.now()
//           : DateTime.now(),
//       dueDate: m['dueDate'] != null
//           ? DateTime.tryParse(m['dueDate']) ?? DateTime.now()
//           : DateTime.now(),
//       students: (m['students'] as List<dynamic>?)
//           ?.map((s) => ChallanStudentLine.fromMap(Map<String, dynamic>.from(s as Map)))
//           .toList() ??
//           [],
//       currentMonthTotal: (m['currentMonthTotal'] as num?)?.toDouble() ?? 0,
//       previousBalance: (m['previousBalance'] as num?)?.toDouble() ?? 0,
//       amountPaid: (m['amountPaid'] as num?)?.toDouble() ?? 0,
//     );
//   }
//
//   static const List<String> monthNames = [
//     '', 'January', 'February', 'March', 'April', 'May', 'June',
//     'July', 'August', 'September', 'October', 'November', 'December'
//   ];
//
//   String get monthLabel => (month >= 1 && month <= 12) ? monthNames[month] : '—';
// }