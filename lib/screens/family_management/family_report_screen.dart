import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/admission_model.dart';
import '../../providers/admission_provider.dart';
import '../../services/family_report_pdf_service.dart';
import '../../services/family_report_service.dart';

// ─────────────────────────────────────────────
//  Design tokens (kept consistent with FamilyManagementScreen)
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleDeep = Color(0xFF3F3792);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleTint = Color(0xFFEDEBFA);
const _kInk = Color(0xFF1A1A2E);
const _kBorder = Color(0xFFE9E9F2);
const _kSurface = Color(0xFFF7F7FB);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);
const _kSlate = Color(0xFF6B7280);

class FamilyReportScreen extends StatefulWidget {
  const FamilyReportScreen({super.key});

  @override
  State<FamilyReportScreen> createState() => _FamilyReportScreenState();
}

class _FamilyReportScreenState extends State<FamilyReportScreen> {
  bool _isLoading = true;
  bool _isPdfBusy = false;
  String? _error;

  List<FamilyReportRow> _rows = [];
  final Set<String> _selected = {}; // familyDocId set

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final admissions = context.read<AdmissionProvider>().admissions;

      // Group by family the same way FamilyManagementScreen does,
      // so this report always matches what's shown there.
      final Map<String, List<AdmissionModel>> grouped = {};
      for (final a in admissions) {
        final key = a.familyDocId.isNotEmpty ? a.familyDocId : a.familyId;
        if (key.isEmpty) continue;
        grouped.putIfAbsent(key, () => []).add(a);
      }

      final basics = grouped.entries.map((entry) {
        final rep = entry.value.first;
        return FamilyBasicInfo(
          familyDocId: rep.familyDocId.isNotEmpty ? rep.familyDocId : entry.key,
          familyId: rep.familyId,
          familyName: rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
          fatherName: rep.fatherName,
          fatherPhone: rep.fatherPhone,
        );
      }).toList();

      final report = await FamilyReportService.buildReport(families: basics);

      if (!mounted) return;
      setState(() {
        _rows = report;
        _selected
          ..clear()
          ..addAll(report.map((r) => r.familyDocId));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load report: $e';
        _isLoading = false;
      });
    }
  }

  List<FamilyReportRow> get _selectedRows =>
      _rows.where((r) => _selected.contains(r.familyDocId)).toList();

  bool get _allSelected => _rows.isNotEmpty && _selected.length == _rows.length;

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(_rows.map((r) => r.familyDocId));
      }
    });
  }

  void _toggleOne(String familyDocId) {
    setState(() {
      if (_selected.contains(familyDocId)) {
        _selected.remove(familyDocId);
      } else {
        _selected.add(familyDocId);
      }
    });
  }

  Future<void> _printPdf() async {
    if (_isPdfBusy) return;
    if (_selectedRows.isEmpty) {
      _showSnack('Pehle kam az kam 1 family select karein', isError: true);
      return;
    }
    setState(() => _isPdfBusy = true);
    try {
      await FamilyReportPdfService.printReport(families: _selectedRows);
    } catch (e) {
      _showSnack('Print failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isPdfBusy = false);
    }
  }

  Future<void> _downloadPdf() async {
    if (_isPdfBusy) return;
    if (_selectedRows.isEmpty) {
      _showSnack('Pehle kam az kam 1 family select karein', isError: true);
      return;
    }
    setState(() => _isPdfBusy = true);
    try {
      await FamilyReportPdfService.downloadAndOpen(families: _selectedRows);
      _showSnack('PDF save ho gayi');
    } catch (e) {
      _showSnack('Save failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isPdfBusy = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Families Report',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        actions: [
          if (_isPdfBusy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print PDF',
              onPressed: _isLoading ? null : _printPdf,
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Save PDF',
              onPressed: _isLoading ? null : _downloadPdf,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPurple))
          : _error != null
          ? _buildError()
          : _rows.isEmpty
          ? _buildEmpty()
          : isDesktop
          ? _buildDesktop()
          : _buildMobile(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.family_restroom_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text('Koi family nahi mili',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Shared summary header ──
  Widget _summaryHeader() {
    final totalDue = _rows.where((r) => r.balance > 0).fold(0.0, (s, r) => s + r.balance);
    final totalAdvance = _rows.where((r) => r.balance < 0).fold(0.0, (s, r) => s + r.balance.abs());

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statTile('Total Families', '${_rows.length}', _kPurple, _kPurpleLight),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statTile(
                'Due (Dr)', 'Rs ${NumberFormat('#,##0').format(totalDue)}', _kRed, const Color(0xFFFEF2F2)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statTile('Advance (Cr)', 'Rs ${NumberFormat('#,##0').format(totalAdvance)}', _kGreen,
                const Color(0xFFECFDF3)),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: fg.withOpacity(0.85))),
          const SizedBox(height: 3),
          Text(value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }

  Widget _selectAllBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Checkbox(
            value: _allSelected,
            activeColor: _kPurple,
            onChanged: (_) => _toggleSelectAll(),
          ),
          Text(_allSelected ? 'Deselect All' : 'Select All',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kInk)),
          const Spacer(),
          Text('${_selected.length} / ${_rows.length} selected',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  DESKTOP — table
  // ═══════════════════════════════════════════
  Widget _buildDesktop() {
    return Column(
      children: [
        _summaryHeader(),
        _selectAllBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFFF8F9FC),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: const Row(
                      children: [
                        SizedBox(width: 40),
                        Expanded(flex: 4, child: _Th('FAMILY NAME')),
                        Expanded(flex: 4, child: _Th('FATHER NAME')),
                        Expanded(flex: 3, child: _Th('CONTACT NO')),
                        Expanded(flex: 3, child: _Th('FAMILY ID')),
                        Expanded(flex: 3, child: _Th('BALANCE (Rs)', align: TextAlign.right)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _rows.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (context, index) {
                        final r = _rows[index];
                        final isSelected = _selected.contains(r.familyDocId);
                        return InkWell(
                          onTap: () => _toggleOne(r.familyDocId),
                          child: Container(
                            color: isSelected ? _kPurpleLight.withOpacity(0.3) : null,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Checkbox(
                                    value: isSelected,
                                    activeColor: _kPurple,
                                    onChanged: (_) => _toggleOne(r.familyDocId),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(r.familyName.isNotEmpty ? r.familyName : '—',
                                      style: const TextStyle(fontSize: 12.5, color: _kInk, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(r.fatherName.isNotEmpty ? r.fatherName : '—',
                                      style: const TextStyle(fontSize: 12.5, color: _kInk)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(r.fatherPhone.isNotEmpty ? r.fatherPhone : '—',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(r.familyId.isNotEmpty ? r.familyId : '—',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: _balanceText(r.balance, align: TextAlign.right),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  //  MOBILE — card list
  // ═══════════════════════════════════════════
  Widget _buildMobile() {
    return Column(
      children: [
        _summaryHeader(),
        _selectAllBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            itemCount: _rows.length,
            itemBuilder: (context, index) {
              final r = _rows[index];
              final isSelected = _selected.contains(r.familyDocId);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? _kPurple.withOpacity(0.4) : _kBorder),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _toggleOne(r.familyDocId),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          activeColor: _kPurple,
                          onChanged: (_) => _toggleOne(r.familyDocId),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(r.familyName.isNotEmpty ? r.familyName : '—',
                                          style: const TextStyle(
                                              fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
                                    ),
                                    _balanceText(r.balance, align: TextAlign.right),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person_rounded, size: 12, color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(r.fatherName.isNotEmpty ? r.fatherName : '—',
                                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                                    const SizedBox(width: 10),
                                    Icon(Icons.phone_rounded, size: 12, color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(r.fatherPhone.isNotEmpty ? r.fatherPhone : '—',
                                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(r.familyId.isNotEmpty ? r.familyId : '—',
                                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade400)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _balanceText(double balance, {TextAlign align = TextAlign.left}) {
    final isDue = balance > 0;
    final isZero = balance == 0;
    final color = isZero ? _kSlate : (isDue ? _kRed : _kGreen);
    final label = isZero
        ? 'Rs 0'
        : 'Rs ${NumberFormat('#,##0').format(balance.abs())} ${isDue ? "Dr" : "Cr"}';
    return Text(
      label,
      textAlign: align,
      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
    );
  }
}

class _Th extends StatelessWidget {
  final String label;
  final TextAlign align;
  const _Th(this.label, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: const TextStyle(
          fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF8B8FA8), letterSpacing: 0.4),
    );
  }
}