
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/teacher.dart';
import '../../models/salary_model.dart';
import '../../providers/employee_transaction_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/salary_provider.dart';

// ─────────────────────────────────────────────
//  Design tokens (matches EduCore brand)
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleMid = Color(0xFF6C63D4);
const _kPurpleDark = Color(0xFF433CA0);

const _kGreen = Color(0xFF166534);
const _kGreenBg = Color(0xFFEFFCF3);
const _kRed = Color(0xFFB91C1C);
const _kRedBg = Color(0xFFFEF2F2);
const _kOrange = Color(0xFFB45309);
const _kOrangeBg = Color(0xFFFFFBEB);

const _kBorder = Color(0xFFE2E8F0);
const _kSurface = Color(0xFFF8FAFC);
const _kInk = Color(0xFF1F2937);
const _kSlate = Color(0xFF64748B);

const double _kDesktopBreakpoint = 900;
const int _kFixedMonthDays = 30;

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class GenerateSalaryScreen extends StatefulWidget {
  final bool showAppBar;

  /// When provided, the screen opens in EDIT MODE for this existing
  /// salary record: employee/month are locked & pre‑filled, and
  /// Save performs an update instead of creating a new record.
  final SalaryRecord? existingRecord;

  const GenerateSalaryScreen({
    super.key,
    this.showAppBar = true,
    this.existingRecord,
  });

  bool get isEditMode => existingRecord != null;

  @override
  State<GenerateSalaryScreen> createState() => _GenerateSalaryScreenState();
}

class _GenerateSalaryScreenState extends State<GenerateSalaryScreen> {
  // ─── Three employee types ─────────────────────────────────────
  static const List<String> _types = ['teacher', 'school_staff', 'academy_staff'];
  static const Map<String, String> _typeLabels = {
    'teacher': 'Teacher',
    'school_staff': 'School Staff',
    'academy_staff': 'Academy Staff',
  };

  late String _employeeType; // one of _types

  StaffMember? _selectedEmployee;

  late int _selectedYear;
  late int _selectedMonth;

  late String _mode; // 'attendance' or 'manual'

  final _fineCtrl = TextEditingController();
  final _bonusCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // Manual mode inputs
  final _manualLeavesCtrl = TextEditingController(text: '0');

  final _searchCtrl = TextEditingController();
  bool _showSuggestions = false;
  final _searchFocus = FocusNode();

  Map<String, dynamic>? _calcResult;
  bool _isSaving = false;

  bool _markTerminated = false;

  bool _recordInLedger = false;
  double? _currentLedgerBalance;
  bool _loadingLedgerBalance = false;

  final _deductionAmountCtrl = TextEditingController();

  bool _alreadyGenerated = false;
  SalaryRecord? _existingRecord;
  bool _isCheckingDuplicate = false;

  bool get _isEditMode => widget.isEditMode;

  bool _isMonthValidForEmployee(int year, int month) {
    if (_selectedEmployee == null) return true;
    final joinDateStr = _selectedEmployee!.joiningDate;
    if (joinDateStr == null || joinDateStr.isEmpty) return true;
    try {
      final joinDate = DateTime.parse(joinDateStr);
      if (year < joinDate.year) return false;
      if (year == joinDate.year && month < joinDate.month) return false;
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();

    final rec = widget.existingRecord;
    _employeeType = rec?.employeeType ?? 'teacher';
    _selectedYear = rec?.year ?? DateTime.now().year;
    _selectedMonth = rec?.month ?? DateTime.now().month;
    _mode = rec?.mode ?? 'attendance';

    if (rec != null) {
      _fineCtrl.text = rec.fine == rec.fine.roundToDouble()
          ? rec.fine.toStringAsFixed(0)
          : rec.fine.toString();
      _bonusCtrl.text = rec.bonus == rec.bonus.roundToDouble()
          ? rec.bonus.toStringAsFixed(0)
          : rec.bonus.toString();
      _noteCtrl.text = rec.note ?? '';
      _manualLeavesCtrl.text = '${rec.leaves}';
      _searchCtrl.text = rec.employeeName;
      _markTerminated = rec.isTerminated;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final staffProvider = context.read<StaffProvider>();
      // ── Load all employees (you need to implement fetchAllStaff in StaffProvider) ──
      // If you don't have fetchAllStaff, you can call the individual fetches:
      // staffProvider.fetchTeachers();
      // staffProvider.fetchStaffOnly();
      // staffProvider.fetchAcademyStaff(); // if you have it
      // For now, we assume staffProvider.fetchAllStaff() exists.
      if (staffProvider.allStaff.isEmpty) {
        staffProvider.fetchAllStaff();
      }

      if (_isEditMode) {
        _hydrateSelectedEmployeeForEdit();
      }
    });

    _fineCtrl.addListener(_recalculateIfManual);
    _bonusCtrl.addListener(_recalculateIfManual);
    _manualLeavesCtrl.addListener(_recalculateIfManual);
    _deductionAmountCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fineCtrl.dispose();
    _bonusCtrl.dispose();
    _noteCtrl.dispose();
    _manualLeavesCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _deductionAmountCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────
  //  Edit‑mode helper
  // ───────────────────────────────────────────
  void _hydrateSelectedEmployeeForEdit() {
    final rec = widget.existingRecord;
    if (rec == null) return;

    final staffProvider = context.read<StaffProvider>();
    // Search in allStaff (includes all types)
    StaffMember? match;
    for (final e in staffProvider.allStaff) {
      if (e.id == rec.employeeId) {
        match = e;
        break;
      }
    }

    setState(() {
      _selectedEmployee = match ??
          StaffMember(
            id: rec.employeeId,
            name: rec.employeeName,
            salary: rec.baseSalary,
            designation: rec.designation,
            address: '',
            cnic: '',
            dob: '2000-01-01',
            emergencyPhone: '',
            employmentType: '',
            fatherOrHusbandName: '',
            gender: '',
            maritalStatus: '',
            nationality: '',
            phone: '',
            religion: '',
            type: _employeeType,
          );
      _searchCtrl.text = _selectedEmployee!.name;
    });

    setState(() {
      _calcResult = {
        'baseSalary': rec.baseSalary,
        'workingDays': rec.workingDays,
        'leaves': rec.leaves,
        'perDayRate': rec.perDayRate,
        'absentDeduction': rec.absentDeduction,
        'fine': rec.fine,
        'bonus': rec.bonus,
        'netSalary': rec.netSalary,
      };
    });

    setState(() {
      _recordInLedger = rec.recordInLedger;
      _deductionAmountCtrl.text = rec.recordInLedger && rec.ledgerDeductionAmount != 0
          ? (rec.ledgerDeductionAmount == rec.ledgerDeductionAmount.roundToDouble()
          ? rec.ledgerDeductionAmount.toStringAsFixed(0)
          : rec.ledgerDeductionAmount.toString())
          : '';
    });

    _fetchLedgerBalance();
  }

  // ─── Filter employees by selected type ──────────────────────
  List<StaffMember> get _sourceList {
    final staffProvider = context.watch<StaffProvider>();
    return staffProvider.allStaff
        .where((s) => s.type == _employeeType)
        .toList();
  }

  List<StaffMember> get _filteredEmployees {
    final query = _searchCtrl.text.trim().toLowerCase();
    final list = _sourceList;
    if (query.isEmpty) return list;
    return list.where((e) => e.name.toLowerCase().contains(query)).toList();
  }

  double get _fine => double.tryParse(_fineCtrl.text.trim()) ?? 0;
  double get _bonus => double.tryParse(_bonusCtrl.text.trim()) ?? 0;

  double get _deductionAmount {
    if (!_recordInLedger) return 0;
    return double.tryParse(_deductionAmountCtrl.text.trim()) ?? 0;
  }

  double get _payableNetSalary {
    final calculatedNet = (_calcResult?['netSalary'] as double?) ?? 0;
    return calculatedNet - _deductionAmount;
  }

  String? _joiningAdjustedNote() {
    final jd = _selectedEmployee?.effectiveJoiningDate;
    if (jd == null || jd.isEmpty) return null;
    try {
      final parsed = DateTime.parse(jd);
      if (parsed.year == _selectedYear && parsed.month == _selectedMonth) {
        final monthEnd = DateTime(_selectedYear, _selectedMonth + 1, 0);
        final days = monthEnd.day - parsed.day + 1;
        return 'Joined ${DateFormat('d MMM yyyy').format(parsed)} — salary calculated for '
            '$days day${days == 1 ? '' : 's'} (${parsed.day}–${monthEnd.day} '
            '${DateFormat('MMM').format(monthEnd)}).';
      }
    } catch (_) {}
    return null;
  }

  // ─── Type switch ─────────────────────────────────────────────
  void _switchType(String type) {
    if (_isEditMode) return; // locked in edit mode
    setState(() {
      _employeeType = type;
      _selectedEmployee = null;
      _searchCtrl.clear();
      _calcResult = null;
      _markTerminated = false;
      _resetDuplicateState();
      _resetDeductionAmount();
    });
  }

  void _pickEmployee(StaffMember member) {
    if (_isEditMode) return;
    setState(() {
      _selectedEmployee = member;
      _searchCtrl.text = member.name;
      _showSuggestions = false;
      _markTerminated = false;
      _currentLedgerBalance = null;
      _resetDeductionAmount();
    });
    _searchFocus.unfocus();
    _checkDuplicate();
    _fetchLedgerBalance();
  }

  void _resetDeductionAmount() {
    _recordInLedger = false;
    _deductionAmountCtrl.text = '';
  }

  Future<void> _fetchLedgerBalance() async {
    if (_selectedEmployee?.id == null) return;
    setState(() => _loadingLedgerBalance = true);
    try {
      final txnProvider = context.read<StaffTransactionProvider>();
      double balance = await txnProvider.getEmployeeBalance(_selectedEmployee!.id!);

      if (_isEditMode && widget.existingRecord?.id != null) {
        final linked = await txnProvider.getTransactionBySalaryRecordId(
          employeeId: _selectedEmployee!.id!,
          salaryRecordId: widget.existingRecord!.id!,
        );
        if (linked != null) {
          balance += linked.amount;
        }
      }

      if (mounted) setState(() => _currentLedgerBalance = balance);
    } catch (e) {
      debugPrint('Error fetching ledger balance: $e');
    } finally {
      if (mounted) setState(() => _loadingLedgerBalance = false);
    }
  }

  void _switchMode(String mode) {
    setState(() {
      _mode = mode;
      _calcResult = null;
    });
    if (_selectedEmployee != null && (!_alreadyGenerated || _isEditMode)) {
      if (mode == 'attendance') {
        _runAttendanceCalculation();
      } else {
        _recalculateManual();
      }
    }
  }

  Future<void> _openMonthYearPicker() async {
    if (_isEditMode) return;
    final result = await _showMonthYearPicker(
      context: context,
      initialYear: _selectedYear,
      initialMonth: _selectedMonth,
    );
    if (result == null) return;

    if (!_isMonthValidForEmployee(result.year, result.month)) {
      final joinDateStr = _selectedEmployee!.joiningDate;
      String? formattedJoin;
      if (joinDateStr != null && joinDateStr.isNotEmpty) {
        try {
          final jd = DateTime.parse(joinDateStr);
          formattedJoin = DateFormat('MMMM yyyy').format(jd);
        } catch (_) {}
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Salary cannot be generated for a month prior to the employee\'s joining date. '
                'Please select a month from ${formattedJoin ?? 'joining month'} onwards.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _selectedYear = result.year;
      _selectedMonth = result.month;
      _calcResult = null;
    });
    _checkDuplicate();
  }

  // ───────────────────────────────────────────
  //  Duplicate check – skipped in edit mode
  // ───────────────────────────────────────────
  Future<void> _checkDuplicate() async {
    if (_isEditMode) return;
    if (_selectedEmployee == null) return;

    setState(() => _isCheckingDuplicate = true);

    try {
      final provider = context.read<SalaryProvider>();
      final existing = await provider.checkAlreadyGenerated(
        _selectedEmployee!.id!,
        _selectedYear,
        _selectedMonth,
      );
      if (!mounted) return;
      setState(() {
        _existingRecord = existing;
        _alreadyGenerated = existing != null;
        _isCheckingDuplicate = false;
        if (existing != null) {
          _calcResult = null;
        }
      });

      if (!_alreadyGenerated && _mode == 'attendance') {
        _runAttendanceCalculation();
      } else if (!_alreadyGenerated && _mode == 'manual') {
        _recalculateManual();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingDuplicate = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking duplicate: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _resetDuplicateState() {
    _alreadyGenerated = false;
    _existingRecord = null;
    _isCheckingDuplicate = false;
  }

  // ───────────────────────────────────────────
  //  Calculations
  // ───────────────────────────────────────────
  Future<void> _runAttendanceCalculation() async {
    if (_selectedEmployee == null) return;
    final provider = context.read<SalaryProvider>();
    try {
      final result = await provider.calculateAttendanceBased(
        employeeId: _selectedEmployee!.id!,
        baseSalary: _selectedEmployee!.salary,
        year: _selectedYear,
        month: _selectedMonth,
        joiningDate: _selectedEmployee!.effectiveJoiningDate,
        fine: _fine,
        bonus: _bonus,
      );
      if (mounted) {
        setState(() => _calcResult = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _recalculateManual() {
    if (_selectedEmployee == null) return;
    final provider = context.read<SalaryProvider>();
    final leaves = int.tryParse(_manualLeavesCtrl.text.trim()) ?? 0;
    final result = provider.calculateManual(
      baseSalary: _selectedEmployee!.salary,
      year: _selectedYear,
      month: _selectedMonth,
      joiningDate: _selectedEmployee!.effectiveJoiningDate,
      leaves: leaves,
      fine: _fine,
      bonus: _bonus,
    );
    setState(() => _calcResult = result);
  }

  void _recalculateIfManual() {
    if (_alreadyGenerated && !_isEditMode) return;
    if (_mode == 'manual') {
      _recalculateManual();
    } else if (_mode == 'attendance' && _calcResult != null) {
      final base = _calcResult!['baseSalary'] as double;
      final absentDeduction = _calcResult!['absentDeduction'] as double;
      setState(() {
        _calcResult = {
          ..._calcResult!,
          'fine': _fine,
          'bonus': _bonus,
          'netSalary': base - absentDeduction - _fine + _bonus,
        };
      });
    }
  }

  Future<void> _save() async {
    if (_isEditMode) {
      await _saveEdit();
    } else {
      await _saveNew();
    }
  }

  Future<void> _saveEdit() async {
    final rec = widget.existingRecord!;
    if (_calcResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calculation not ready yet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<SalaryProvider>();

    try {
      final totalDaysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      final txnProvider = context.read<StaffTransactionProvider>();

      await provider.updateFullSalary(
        docId: rec.id!,
        baseSalary: _calcResult!['baseSalary'] as double,
        totalDaysInMonth: totalDaysInMonth,
        workingDays: _calcResult!['workingDays'] as int,
        leaves: _calcResult!['leaves'] as int,
        perDayRate: _calcResult!['perDayRate'] as double,
        absentDeduction: _calcResult!['absentDeduction'] as double,
        fine: _fine,
        bonus: _bonus,
        netSalary: _calcResult!['netSalary'] as double,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        mode: _mode,
        isTerminated: _markTerminated,
        transactionProvider: txnProvider,
        recordInLedger: _recordInLedger,
        ledgerDeductionAmount: _recordInLedger ? _deductionAmount : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Salary updated for ${rec.employeeName} — Rs ${NumberFormat('#,##0').format(_calcResult!['netSalary'])}.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
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

  Future<void> _saveNew() async {
    if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an employee first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_calcResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for the salary calculation to complete.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_alreadyGenerated) {
      return;
    }

    if (_markTerminated) {
      final confirmed = await _confirmTerminationDialog();
      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<SalaryProvider>();
    try {
      final existing = await provider.checkAlreadyGenerated(
        _selectedEmployee!.id!,
        _selectedYear,
        _selectedMonth,
      );

      if (existing != null) {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _alreadyGenerated = true;
            _existingRecord = existing;
          });
          _showAlreadyGeneratedDialog(existing);
        }
        return;
      }

      final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, _selectedMonth));
      final totalDaysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      final generatedDate = DateTime.now();

      final record = SalaryRecord(
        employeeId: _selectedEmployee!.id!,
        employeeName: _selectedEmployee!.name,
        employeeType: _employeeType, // one of the three
        designation: _selectedEmployee!.designation,
        year: _selectedYear,
        month: _selectedMonth,
        mode: _mode,
        baseSalary: _calcResult!['baseSalary'] as double,
        totalDaysInMonth: totalDaysInMonth,
        workingDays: _calcResult!['workingDays'] as int,
        leaves: _calcResult!['leaves'] as int,
        perDayRate: _calcResult!['perDayRate'] as double,
        absentDeduction: _calcResult!['absentDeduction'] as double,
        fine: _fine,
        bonus: _bonus,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        netSalary: _calcResult!['netSalary'] as double,
        status: 'Pending',
        isTerminated: _markTerminated,
        generatedDate: generatedDate,
      );

      final txnProvider = context.read<StaffTransactionProvider>();
      await provider.saveSalary(
        record,
        transactionProvider: txnProvider,
        recordInLedger: _recordInLedger,
        ledgerDeductionAmount: _recordInLedger ? _deductionAmount : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _markTerminated
                    ? 'Final salary of Rs ${NumberFormat('#,##0').format(record.netSalary)} generated for ${record.employeeName} — $monthName $_selectedYear. Employee marked as Terminated on ${DateFormat('dd MMM yyyy').format(generatedDate)}.'
                    : 'Salary of Rs ${NumberFormat('#,##0').format(record.netSalary)} generated for ${record.employeeName} — $monthName $_selectedYear.'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }
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

  Future<bool?> _confirmTerminationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.person_off_rounded, color: _kRed),
            SizedBox(width: 10),
            Text('Terminate Employee?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          '${_selectedEmployee?.name} will be marked as Terminated once this salary is generated. '
              'They will be removed from the regular Staff list.\n\n'
              'You can undo this later by deleting this salary record, or by reinstating them from the Terminated Employees list.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRed,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Yes, Terminate'),
          ),
        ],
      ),
    );
  }

  void _showAlreadyGeneratedDialog(SalaryRecord existing) {
    final monthName =
    DateFormat('MMMM').format(DateTime(existing.year, existing.month));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: _kOrange),
            SizedBox(width: 10),
            Text('Already Generated',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'A salary record for ${existing.employeeName} — $monthName ${existing.year} '
              'already exists (Rs ${NumberFormat('#,##0').format(existing.netSalary)}, '
              'status: ${existing.status}).\n\n'
              'Generating salary again for the same month is not allowed.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPurple,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedEmployee = null;
      _searchCtrl.clear();
      _fineCtrl.clear();
      _bonusCtrl.clear();
      _noteCtrl.clear();
      _manualLeavesCtrl.text = '0';
      _calcResult = null;
      _markTerminated = false;
      _currentLedgerBalance = null;
      _resetDuplicateState();
      _resetDeductionAmount();
    });
  }

  String get _initials {
    final name = _selectedEmployee?.name.trim() ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  // ───────────────────────────────────────────
  //  UI components
  // ───────────────────────────────────────────
  Widget _buildAlreadyGeneratedWarning() {
    if (_existingRecord == null) return const SizedBox.shrink();
    final record = _existingRecord!;
    final monthName = DateFormat('MMMM').format(DateTime(record.year, record.month));
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kOrangeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOrange.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: _kOrange, size: 20),
              const SizedBox(width: 10),
              const Text('Already Generated',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _kOrange)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'A salary record already exists for ${record.employeeName} — $monthName ${record.year}.',
            style: const TextStyle(fontSize: 13, color: _kOrange),
          ),
          const SizedBox(height: 6),
          Text(
            'Net Salary: Rs ${NumberFormat('#,##0').format(record.netSalary)}',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: _kOrange, fontSize: 13),
          ),
          Text(
            'Status: ${record.status}',
            style: const TextStyle(fontSize: 12, color: _kOrange),
          ),
          const SizedBox(height: 10),
          Text(
            'To generate salary for a different month, change the month above.',
            style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildEditModeBanner() {
    final rec = widget.existingRecord!;
    final monthName = DateFormat('MMMM').format(DateTime(rec.year, rec.month));
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kPurpleLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note_rounded, color: _kPurple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Editing salary of ${rec.employeeName} — $monthName ${rec.year}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kPurpleDark),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Three‑type toggle ───────────────────────────────────────
  Widget _typeToggle() {
    final locked = _isEditMode;
    return Opacity(
      opacity: locked ? 0.6 : 1.0,
      child: IgnorePointer(
        ignoring: locked,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: _types.map((type) {
              final selected = _employeeType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _switchType(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                    decoration: BoxDecoration(
                      color: selected ? _kPurple : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type == 'teacher'
                              ? Icons.school_rounded
                              : (type == 'school_staff'
                              ? Icons.badge_rounded
                              : Icons.business_center_rounded),
                          size: 14,
                          color: selected ? Colors.white : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _typeLabels[type]!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Icon(
                    //       type == 'teacher'
                    //           ? Icons.school_rounded
                    //           : (type == 'school_staff'
                    //           ? Icons.badge_rounded
                    //           : Icons.business_center_rounded),
                    //       size: 16,
                    //       color: selected ? Colors.white : Colors.grey.shade600,
                    //     ),
                    //     const SizedBox(width: 6),
                    //     Text(
                    //       _typeLabels[type]!,
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w600,
                    //         color: selected ? Colors.white : Colors.grey.shade700,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _employeeSearchField() {
    if (_isEditMode) {
      return TextFormField(
        controller: _searchCtrl,
        enabled: false,
        decoration: InputDecoration(
          labelText: '${_typeLabels[_employeeType]} (locked)',
          prefixIcon: const Icon(Icons.person_outline, size: 20),
          suffixIcon: const Icon(Icons.lock_outline, size: 18, color: _kSlate),
          labelStyle: const TextStyle(fontSize: 13),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
    }

    final staffProvider = context.watch<StaffProvider>();
    final isLoading = staffProvider.loading && _sourceList.isEmpty;

    return TapRegion(
      onTapOutside: (_) {
        if (_showSuggestions) setState(() => _showSuggestions = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            onTap: () => setState(() => _showSuggestions = true),
            onChanged: (v) {
              setState(() {
                _showSuggestions = true;
                if (_selectedEmployee != null && v != _selectedEmployee!.name) {
                  _selectedEmployee = null;
                  _calcResult = null;
                  _markTerminated = false;
                  _resetDuplicateState();
                }
              });
            },
            decoration: InputDecoration(
              labelText: 'Search ${_typeLabels[_employeeType]} Name *',
              hintText: 'Start typing a name…',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _selectedEmployee != null
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  : null,
              labelStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kPurple, width: 1.5),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          if (_showSuggestions) ...[
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: isLoading
                  ? const Padding(
                padding: EdgeInsets.all(16),
                child:
                Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
                  : _filteredEmployees.isEmpty
                  ? Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'No ${_typeLabels[_employeeType]} found.',
                  style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              )
                  : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredEmployees.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, i) {
                  final e = _filteredEmployees[i];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: _kPurpleLight,
                      child: Text(
                        e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kPurple),
                      ),
                    ),
                    title: Text(e.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      'Rs ${NumberFormat('#,##0').format(e.salary)}'
                          '${(e.designation ?? '').isNotEmpty ? ' · ${e.designation}' : ''}',
                      style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    onTap: () => _pickEmployee(e),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _selectedEmployeeCard() {
    if (_selectedEmployee == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kPurpleLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _kPurple,
            child: Text(_initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedEmployee!.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                Text(
                  'Base Salary: Rs ${NumberFormat('#,##0').format(_selectedEmployee!.salary)}'
                      '${(_selectedEmployee!.designation ?? '').isNotEmpty ? ' · ${_selectedEmployee!.designation}' : ''}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _terminationToggleCard() {
    final disabled = _alreadyGenerated && !_isEditMode;
    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: IgnorePointer(
        ignoring: disabled,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _markTerminated ? _kRedBg : _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _markTerminated ? _kRed.withOpacity(0.4) : _kBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _markTerminated ? _kRed.withOpacity(0.12) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_off_rounded,
                  size: 18,
                  color: _markTerminated ? _kRed : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mark as Terminated',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _markTerminated ? _kRed : _kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _markTerminated
                          ? 'This will be treated as their final salary. Employee will move to Terminated list.'
                          : 'Turn on if this employee is leaving the school.',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _markTerminated,
                activeColor: _kRed,
                onChanged: _selectedEmployee == null
                    ? null
                    : (v) => setState(() => _markTerminated = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ledgerDeductionCard() {
    if (_selectedEmployee == null) return const SizedBox.shrink();

    final currentBalance = _currentLedgerBalance ?? 0;
    final deductionAmount = _deductionAmount;
    final projectedBalance =
    _recordInLedger ? (currentBalance - deductionAmount) : currentBalance;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current balance row
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 16, color: _kPurple),
              const SizedBox(width: 8),
              const Text('Current Balance',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _kInk)),
              const Spacer(),
              if (_loadingLedgerBalance)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  'Rs ${NumberFormat('#,##0').format(currentBalance.abs())}'
                      '${currentBalance == 0 ? '' : (currentBalance > 0 ? ' (owes)' : ' (owed)')}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: currentBalance > 0
                        ? _kRed
                        : (currentBalance < 0 ? _kGreen : _kSlate),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 10),

          // Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deduct from Balance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _recordInLedger ? _kPurple : _kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Turn on to deduct an amount from this salary and reduce what the employee owes.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _recordInLedger,
                activeColor: _kPurple,
                onChanged: (v) {
                  setState(() {
                    _recordInLedger = v;
                    if (!v) _deductionAmountCtrl.text = '';
                  });
                },
              ),
            ],
          ),

          if (_recordInLedger) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _deductionAmountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Deduction Amount',
                hintText: '0',
                helperText: 'This amount is subtracted from Net Salary and from the balance.',
                helperMaxLines: 2,
                labelStyle: const TextStyle(fontSize: 13),
                helperStyle: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                prefixText: 'Rs  ',
                prefixIcon: const Icon(Icons.trending_down_rounded, size: 18, color: _kPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kPurple, width: 1.5),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],

          if (_recordInLedger && deductionAmount != 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _kPurpleLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_down_rounded, size: 14, color: _kPurple),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Balance after this deduction: Rs ${NumberFormat('#,##0').format(projectedBalance.abs())}'
                          '${projectedBalance == 0 ? '' : (projectedBalance > 0 ? ' (owes)' : ' (owed)')}',
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _kPurpleDark),
                    ),
                  ),
                ],
              ),
            ),
            if (_payableNetSalary < 0) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _kRedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: _kRed),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'This deduction exceeds the net salary — Net Salary will show as negative '
                            '(Rs ${NumberFormat('#,##0').format(_payableNetSalary.abs())} owed back), meaning the school owes the employee.',
                        style: const TextStyle(fontSize: 10.5, color: _kRed, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _monthYearChip() {
    final locked = _isEditMode;
    return Opacity(
      opacity: locked ? 0.6 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: locked ? null : _openMonthYearPicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: _kSlate),
              const SizedBox(width: 10),
              Text(
                DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk),
              ),
              const SizedBox(width: 6),
              if (locked)
                const Icon(Icons.lock_outline, size: 15, color: _kSlate)
              else
                const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeToggle() {
    final disabled = _alreadyGenerated && !_isEditMode;
    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: IgnorePointer(
        ignoring: disabled,
        child: Row(
          children: [
            Expanded(
              child: _modeCard(
                mode: 'attendance',
                title: 'Attendance-Based',
                subtitle: 'Auto-calculated from attendance records',
                icon: Icons.fact_check_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _modeCard(
                mode: 'manual',
                title: 'Manual Entry',
                subtitle: 'You enter leaves yourself',
                icon: Icons.edit_note_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeCard({
    required String mode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _kPurpleLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kPurple : Colors.grey.shade300,
            width: selected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: selected ? _kPurple : Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? _kPurple : Colors.black87,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, size: 16, color: _kPurple),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _manualInputs() {
    final disabled = _alreadyGenerated && !_isEditMode;
    final workingDaysLabel =
    _calcResult != null ? '${_calcResult!['workingDays']}' : '$_kFixedMonthDays';
    return TextFormField(
      controller: _manualLeavesCtrl,
      keyboardType: TextInputType.number,
      enabled: !disabled,
      decoration: _fieldDeco('Leaves (Absents) *').copyWith(
        helperText: _joiningAdjustedNote() ??
            'Month is always treated as $workingDaysLabel days',
        helperMaxLines: 2,
        helperStyle: TextStyle(fontSize: 11, color: Colors.grey.shade500),
      ),
    );
  }

  Widget _attendanceSummary() {
    final provider = context.watch<SalaryProvider>();
    if (_alreadyGenerated && !_isEditMode) return const SizedBox.shrink();

    if (provider.calculating) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2, color: _kPurple),
      );
    }

    if (_calcResult == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Select an employee to auto-calculate attendance-based salary.',
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ),
          ],
        ),
      );
    }

    final workingDays = _calcResult!['workingDays'] as int;
    final joiningNote = _joiningAdjustedNote();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (joiningNote != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _kPurpleLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: _kPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(joiningNote,
                        style: const TextStyle(
                            fontSize: 11, color: _kPurpleDark, height: 1.3)),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              _miniStat('Working Days', '$workingDays', _kPurple),
              _miniStat('Absents', '${_calcResult!['leaves']}', _kRed),
              _miniStat('Present', '${provider.lastPresentDays}', _kGreen),
              _miniStat('Holidays', '${provider.lastHolidaysExcluded}', _kOrange),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rule: month treated as $workingDays days · Sundays/holidays excluded · '
                'unmarked or "absent" days deducted at Rs ${NumberFormat('#,##0').format(_calcResult!['perDayRate'])}/day.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _fineAndBonusFields() {
    final disabled = _alreadyGenerated && !_isEditMode;
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _fineCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: !disabled,
            decoration: _fieldDeco('Fine / Deduction (Optional)').copyWith(
              prefixText: 'Rs  ',
              prefixIcon: const Icon(Icons.remove_circle_outline,
                  size: 18, color: _kRed),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _bonusCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: !disabled,
            decoration: _fieldDeco('Bonus / Addition (Optional)').copyWith(
              prefixText: 'Rs  ',
              prefixIcon:
              const Icon(Icons.add_circle_outline, size: 18, color: _kGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _noteField() {
    final disabled = _alreadyGenerated && !_isEditMode;
    return TextFormField(
      controller: _noteCtrl,
      maxLines: 2,
      enabled: !disabled,
      decoration: _fieldDeco('Note (Optional)').copyWith(
        hintText: 'Any remarks about this salary…',
        alignLabelWithHint: true,
      ),
    );
  }

  InputDecoration _fieldDeco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kPurple, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _netSalaryPreview() {
    if ((_alreadyGenerated && !_isEditMode) || _calcResult == null) {
      return const SizedBox.shrink();
    }

    final base = _calcResult!['baseSalary'] as double;
    final deduction = _calcResult!['absentDeduction'] as double;
    final fine = _calcResult!['fine'] as double;
    final bonus = _calcResult!['bonus'] as double;
    final showBalanceDeduction = _recordInLedger && _selectedEmployee != null;
    final balanceDeductionAmount = _deductionAmount;
    final payableNet = _payableNetSalary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _markTerminated ? [_kRed, const Color(0xFF7F1D1D)] : [_kPurple, _kPurpleMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Salary Breakdown',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              if (_markTerminated) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('TERMINATED',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _breakdownRow('Base Salary', base, positive: true),
          _breakdownRow('Absent Deduction', -deduction),
          if (fine > 0) _breakdownRow('Fine', -fine),
          if (bonus > 0) _breakdownRow('Bonus', bonus, positive: true),
          if (showBalanceDeduction && balanceDeductionAmount != 0)
            _breakdownRow('Balance Deduction', -balanceDeductionAmount),
          const SizedBox(height: 10),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_markTerminated ? 'Final Net Salary' : 'Net Salary',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              Text(
                '${payableNet < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(payableNet.abs())}',
                style: TextStyle(
                    color: payableNet < 0 ? const Color(0xFFFFD1D1) : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, double value, {bool positive = false}) {
    final sign = value < 0 ? '- ' : (positive ? '' : '');
    final displayVal = value.abs();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
          Text(
            '$sign Rs ${NumberFormat('#,##0').format(displayVal)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _saveButton({double? width, double height = 50}) {
    if (_alreadyGenerated && !_isEditMode) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton.icon(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.grey.shade600,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.lock_outline, size: 18),
          label: const Text('Already Generated',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _markTerminated ? _kRed : _kPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: _isSaving
            ? const SizedBox(
          height: 18,
          width: 18,
          child:
          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Icon(
            _markTerminated
                ? Icons.person_off_rounded
                : (_isEditMode ? Icons.save_rounded : Icons.save_rounded),
            size: 18),
        label: Text(
          _isSaving
              ? (_isEditMode ? 'Updating…' : 'Generating…')
              : (_markTerminated
              ? (_isEditMode ? 'Update Final Salary' : 'Generate Final Salary')
              : (_isEditMode ? 'Update Salary' : 'Generate Salary')),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _kPurple),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _kPurple)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ───────────────────────────────────────────
  //  Build
  // ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;

    final formContent = SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 28 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),


          // Header card (acts as the top bar — includes back arrow)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPurple, _kPurpleMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                if (!_isEditMode && Navigator.of(context).canPop())
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  )
                else
                  const SizedBox(width: 4),
                const SizedBox(width: 8),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                      _isEditMode ? Icons.edit_rounded : Icons.payments_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEditMode ? 'Edit Salary' : 'Generate Salary',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       colors: [_kPurple, _kPurpleMid],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //     borderRadius: BorderRadius.circular(14),
          //   ),
          //   child: Row(
          //     children: [
          //       Container(
          //         width: 42,
          //         height: 42,
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.2),
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Icon(
          //             _isEditMode ? Icons.edit_rounded : Icons.payments_rounded,
          //             color: Colors.white, size: 22),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: Text(
          //           _isEditMode ? 'Edit Salary' : 'Generate Salary',
          //           style: const TextStyle(
          //               color: Colors.white,
          //               fontSize: 15,
          //               fontWeight: FontWeight.w600),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 16),

          if (_isEditMode) _buildEditModeBanner(),

          _sectionCard('Select Employee', Icons.person_search_outlined, [
            _typeToggle(),
            const SizedBox(height: 12),
            _employeeSearchField(),
            _selectedEmployeeCard(),
          ]),

          if (_selectedEmployee != null) ...[
            _sectionCard('Employment Status', Icons.badge_outlined, [
              _terminationToggleCard(),
            ]),
          ],

          _sectionCard('Salary Month', Icons.calendar_month_outlined, [
            _monthYearChip(),
          ]),

          if (!_isEditMode && _alreadyGenerated) _buildAlreadyGeneratedWarning(),

          _sectionCard('Calculation Method', Icons.calculate_outlined, [
            _modeToggle(),
            const SizedBox(height: 14),
            if (_mode == 'manual') _manualInputs(),
            if (_mode == 'attendance') _attendanceSummary(),
          ]),

          if (_isEditMode || !_alreadyGenerated) ...[
            _sectionCard('Adjustments', Icons.tune_rounded, [
              _fineAndBonusFields(),
              const SizedBox(height: 14),
              _noteField(),
            ]),

            if (_selectedEmployee != null) ...[
              _sectionCard(
                'Balance & Transactions',
                Icons.account_balance_wallet_outlined,
                [_ledgerDeductionCard()],
              ),
            ],

            if (_calcResult != null) ...[
              _netSalaryPreview(),
              const SizedBox(height: 20),
            ],
          ],

          _saveButton(width: double.infinity),
          const SizedBox(height: 20),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return Material(
        color: _kSurface,
        child: formContent,
      );
    }

    final bodyWidget = isDesktop
        ? Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        shadowColor: Colors.black26,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: formContent,
          ),
        ),
      ),
    )
        : formContent;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
        title: Text(_isEditMode ? 'Edit Salary' : 'Generate Salary',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      body: SafeArea(
        child: bodyWidget,
      ),
    );
  }
}

// ─── Month/Year picker (unchanged) ──────────────────────────────
class _MonthYearPickerResult {
  final int year;
  final int month;
  _MonthYearPickerResult(this.year, this.month);
}

Future<_MonthYearPickerResult?> _showMonthYearPicker({
  required BuildContext context,
  required int initialYear,
  required int initialMonth,
}) {
  final currentYear = DateTime.now().year;
  return showDialog<_MonthYearPickerResult>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (context) {
      return _MonthYearPickerDialog(
        initialYear: initialYear,
        initialMonth: initialMonth,
        maxYear: currentYear,
      );
    },
  );
}

class _MonthYearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int maxYear;
  const _MonthYearPickerDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.maxYear,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _year;
  late int _month;
  bool _showYearGrid = false;
  late final ScrollController _yearScrollController;

  static const int _minYear = 2015;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
    final index = _year - _minYear;
    final estimatedOffset = (index ~/ 3) * 64.0;
    _yearScrollController = ScrollController(
      initialScrollOffset: estimatedOffset > 0 ? estimatedOffset : 0,
    );
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  void _goToPreviousYear() {
    if (_year - 1 < _minYear) return;
    setState(() => _year -= 1);
  }

  void _goToNextYear() {
    if (_year + 1 > widget.maxYear) return;
    setState(() => _year += 1);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              SizedBox(
                height: 260,
                child: _showYearGrid ? _buildYearGrid() : _buildMonthGrid(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL',
                      style:
                      TextStyle(fontWeight: FontWeight.w600, color: _kSlate)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: _kSlate),
          onPressed: _showYearGrid ? null : _goToPreviousYear,
        ),
        Expanded(
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _showYearGrid = !_showYearGrid),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_year',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: _kInk),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showYearGrid ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: _kSlate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: _kSlate),
          onPressed:
          (_showYearGrid || _year + 1 > widget.maxYear) ? null : _goToNextYear,
        ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isFuture = _year == widget.maxYear && month > DateTime.now().month;
        final isSelected = month == _month && _year == widget.initialYear;
        final label = DateFormat('MMM').format(DateTime(0, month));

        return _PickerCell(
          label: label,
          isSelected: isSelected,
          isDisabled: isFuture,
          onTap: isFuture
              ? null
              : () {
            Navigator.of(context).pop(_MonthYearPickerResult(_year, month));
          },
        );
      },
    );
  }

  Widget _buildYearGrid() {
    final years = List.generate(
      widget.maxYear - _minYear + 1,
          (i) => _minYear + i,
    );

    return GridView.builder(
      controller: _yearScrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == _year;

        return _PickerCell(
          label: '$year',
          isSelected: isSelected,
          isDisabled: false,
          onTap: () {
            setState(() {
              _year = year;
              _showYearGrid = false;
            });
          },
        );
      },
    );
  }
}

class _PickerCell extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _PickerCell({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _kPurple : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _kPurple : _kBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDisabled
                  ? Colors.grey.shade300
                  : (isSelected ? Colors.white : _kInk),
            ),
          ),
        ),
      ),
    );
  }
}