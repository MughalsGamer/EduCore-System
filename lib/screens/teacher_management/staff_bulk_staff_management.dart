
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/teacher.dart';
import '../../models/class_model.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';

// ─── Constants ────────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleMid = Color(0xFF6C63D4);
const _kGreen = Color(0xFF15803D);
const _kGreenBg = Color(0xFFDCFCE7);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEE2E2);
const _kOrange = Color(0xFFD97706);
const _kOrangeBg = Color(0xFFFEF3C7);

// ─── CNIC Formatter ──────────────────────────────────────────────────────────
class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 13 ? digits.substring(0, 13) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 5 || i == 12) buffer.write('-');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ─── Row data model ──────────────────────────────────────────────────────────
class _RowData {
  final String id;
  String type;
  String name;
  String fatherOrHusbandName;
  String cnic;
  String dob;
  String gender;
  String maritalStatus;
  String? bloodGroup;
  String religion;
  String nationality;
  String address;
  String phone;
  String emergencyPhone;
  String employmentType;
  double salary;
  String? reference;
  String? note;
  String? designation;
  String? joiningDate;
  String? classId;                             // NEW: single class for quick row
  List<String> assignedClasses;
  List<String> assignedSections;
  List<String> subjects;
  bool hasError;
  String errorMsg;
  RowStatus status;

  _RowData({
    required this.id,
    this.type = 'teacher',
    this.name = '',
    this.fatherOrHusbandName = '',
    this.cnic = '',
    this.dob = '',
    this.gender = 'Male',
    this.maritalStatus = 'Single',
    this.bloodGroup,
    this.religion = '',
    this.nationality = 'Pakistani',
    this.address = '',
    this.phone = '',
    this.emergencyPhone = '',
    this.employmentType = 'Regular',
    this.salary = 0,
    this.reference,
    this.note,
    this.designation,
    this.joiningDate,
    this.classId,                              // NEW
    this.assignedClasses = const [],
    this.assignedSections = const [],
    this.subjects = const [],
    this.hasError = false,
    this.errorMsg = '',
    this.status = RowStatus.idle,
  });

  _RowData copyWith({
    String? type,
    String? name,
    String? fatherOrHusbandName,
    String? cnic,
    String? dob,
    String? gender,
    String? maritalStatus,
    Object? bloodGroup = _sentinel,
    String? religion,
    String? nationality,
    String? address,
    String? phone,
    String? emergencyPhone,
    String? employmentType,
    double? salary,
    Object? reference = _sentinel,
    Object? note = _sentinel,
    Object? designation = _sentinel,
    Object? joiningDate = _sentinel,
    Object? classId = _sentinel,               // NEW
    List<String>? assignedClasses,
    List<String>? assignedSections,
    List<String>? subjects,
    bool? hasError,
    String? errorMsg,
    RowStatus? status,
  }) =>
      _RowData(
        id: id,
        type: type ?? this.type,
        name: name ?? this.name,
        fatherOrHusbandName: fatherOrHusbandName ?? this.fatherOrHusbandName,
        cnic: cnic ?? this.cnic,
        dob: dob ?? this.dob,
        gender: gender ?? this.gender,
        maritalStatus: maritalStatus ?? this.maritalStatus,
        bloodGroup:
        bloodGroup == _sentinel ? this.bloodGroup : bloodGroup as String?,
        religion: religion ?? this.religion,
        nationality: nationality ?? this.nationality,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        emergencyPhone: emergencyPhone ?? this.emergencyPhone,
        employmentType: employmentType ?? this.employmentType,
        salary: salary ?? this.salary,
        reference: reference == _sentinel ? this.reference : reference as String?,
        note: note == _sentinel ? this.note : note as String?,
        designation:
        designation == _sentinel ? this.designation : designation as String?,
        joiningDate:
        joiningDate == _sentinel ? this.joiningDate : joiningDate as String?,
        classId:
        classId == _sentinel ? this.classId : classId as String?,
        assignedClasses: assignedClasses ?? this.assignedClasses,
        assignedSections: assignedSections ?? this.assignedSections,
        subjects: subjects ?? this.subjects,
        hasError: hasError ?? this.hasError,
        errorMsg: errorMsg ?? this.errorMsg,
        status: status ?? this.status,
      );

  bool get isEmpty => name.trim().isEmpty && phone.trim().isEmpty;

  String? validate() {
    if (name.trim().isEmpty) return 'Name required';
    if (phone.trim().isEmpty) return 'Phone required';
    return null;
  }

  StaffMember toStaffMember() {
    // Use classId if provided, otherwise fall back to assignedClasses list
    final effectiveClasses = classId != null ? [classId!] : assignedClasses;
    return StaffMember(
      type: type,
      name: name.trim(),
      fatherOrHusbandName: fatherOrHusbandName.trim(),
      cnic: cnic.trim(),
      dob: dob,
      gender: gender,
      maritalStatus: maritalStatus,
      bloodGroup: bloodGroup,
      religion: religion.trim(),
      nationality: nationality.trim(),
      address: address.trim(),
      phone: phone.trim(),
      emergencyPhone: emergencyPhone.trim(),
      employmentType: employmentType,
      salary: salary,
      reference: reference?.trim().isEmpty == true ? null : reference?.trim(),
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      designation:
      designation?.trim().isEmpty == true ? null : designation?.trim(),
      joiningDate: joiningDate?.isEmpty == true ? null : joiningDate,
      assignedClasses: effectiveClasses,
      assignedSections: assignedSections,
      subjects: subjects,
      imageBase64: null,
    );
  }
}

// sentinel for nullable copyWith
const _sentinel = Object();

enum RowStatus { idle, saving, saved, failed }

// ─── Bulk Add Screen ──────────────────────────────────────────────────────────
class BulkAddStaffScreen extends StatefulWidget {
  const BulkAddStaffScreen({super.key});

  @override
  State<BulkAddStaffScreen> createState() => _BulkAddStaffScreenState();
}

class _BulkAddStaffScreenState extends State<BulkAddStaffScreen> {
  final List<_RowData> _rows = [];
  bool _isSavingAll = false;
  int _savedCount = 0;
  int _failedCount = 0;
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) _addRow();
  }

  void _addRow({int count = 1}) {
    setState(() {
      for (int i = 0; i < count; i++) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _rows.add(_RowData(id: '${_nextId++}', joiningDate: today));
      }
    });
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() => _rows.removeAt(index));
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Clear All Rows?',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('All unsaved data will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _kRed, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _rows.clear();
                _savedCount = 0;
                _failedCount = 0;
                _addRow(count: 5);
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _updateRow(int index, _RowData updated) {
    setState(() => _rows[index] = updated);
  }

  List<_RowData> get _filledRows =>
      _rows.where((r) => !r.isEmpty).toList();

  Future<void> _saveAll() async {
    // Validate
    bool anyError = false;
    setState(() {
      for (int i = 0; i < _rows.length; i++) {
        if (_rows[i].isEmpty) continue;
        final err = _rows[i].validate();
        if (err != null) {
          _rows[i] = _rows[i].copyWith(hasError: true, errorMsg: err);
          anyError = true;
        } else {
          _rows[i] = _rows[i].copyWith(hasError: false, errorMsg: '');
        }
      }
    });

    if (anyError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fix errors before saving.'),
            backgroundColor: _kRed),
      );
      return;
    }

    final toSave = _filledRows;
    if (toSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No data to save. Fill at least one row.'),
            backgroundColor: _kOrange),
      );
      return;
    }

    setState(() {
      _isSavingAll = true;
      _savedCount = 0;
      _failedCount = 0;
      for (int i = 0; i < _rows.length; i++) {
        if (!_rows[i].isEmpty) {
          _rows[i] = _rows[i].copyWith(status: RowStatus.saving);
        }
      }
    });

    final provider = context.read<StaffProvider>();

    for (int i = 0; i < _rows.length; i++) {
      if (_rows[i].isEmpty || _rows[i].status == RowStatus.saved) continue;
      try {
        await provider.addStaff(_rows[i].toStaffMember());
        if (mounted) {
          setState(() {
            _rows[i] =
                _rows[i].copyWith(status: RowStatus.saved, hasError: false);
            _savedCount++;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _rows[i] = _rows[i].copyWith(
              status: RowStatus.failed,
              hasError: true,
              errorMsg: 'Save failed: $e',
            );
            _failedCount++;
          });
        }
      }
    }

    if (mounted) {
      setState(() => _isSavingAll = false);

      if (_failedCount == 0 && _savedCount > 0) {
        // Refresh providers
        provider.fetchTeachers();
        provider.fetchStaffOnly();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_savedCount record(s) saved successfully!'),
            backgroundColor: _kGreen,
          ),
        );

        // Go back to dashboard / previous screen
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$_savedCount saved${_failedCount > 0 ? ', $_failedCount failed' : ''}'),
            backgroundColor: _failedCount > 0 ? _kOrange : _kGreen,
          ),
        );
        if (_failedCount == 0) {
          provider.fetchTeachers();
          provider.fetchStaffOnly();
        }
      }
    }
  }

  void _openFullEdit(int index) {
    final data = _rows[index];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _FullEditDialog(
        data: data,
        onSave: (updated) {
          _updateRow(index, updated);
          Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bulk Add Staff / Teachers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(
              '${_filledRows.length} filled · ${_filledRows.where((r) => r.validate() == null).length} ready',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        actions: [
          TextButton.icon(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all, size: 16, color: _kRed),
            label: const Text('Clear',
                style: TextStyle(color: _kRed, fontSize: 13)),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _isSavingAll ? null : _saveAll,
              icon: _isSavingAll
                  ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_outlined, size: 16),
              label: Text(_isSavingAll ? 'Saving...' : 'Save All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // Info bar
        Container(
          color: _kPurpleLight,
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 15, color: _kPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Quick info yahan fill karein. Full details k liye ✏️ edit icon click karein.',
                style:
                TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
            if (_savedCount > 0)
              _pill('$_savedCount saved', _kGreen, _kGreenBg),
            if (_failedCount > 0) ...[
              const SizedBox(width: 6),
              _pill('$_failedCount failed', _kRed, _kRedBg)
            ],
          ]),
        ),
        // Table + add buttons (vertical scroll)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 20 : 12),
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: SingleChildScrollView(   // ONLY ONE horizontal scroll
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(),
                      const Divider(height: 1, color: Color(0xFFEEEFF3)),
                      ...List.generate(_rows.length, (i) => _BulkRow(
                        key: ValueKey(_rows[i].id),
                        data: _rows[i],
                        index: i,
                        total: _rows.length,
                        onChanged: (updated) => _updateRow(i, updated),
                        onRemove: () => _removeRow(i),
                        onFullEdit: () => _openFullEdit(i),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Add row buttons
              Row(children: [
                _addBtn('+1 Row', () => _addRow()),
                const SizedBox(width: 8),
                _addBtn('+5 Rows', () => _addRow(count: 5)),
                const SizedBox(width: 8),
                _addBtn('+10 Rows', () => _addRow(count: 10)),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          _hCell('#', width: 46),
          _hCell('Name *', width: 160),
          _hCell('Contact No *', width: 130),
          _hCell('CNIC', width: 140),
          _hCell('Type', width: 90),
          _hCell('Designation', width: 130),
          _hCell('Class', width: 140),
          _hCell('Joining Date', width: 120),
          _hCell('Salary', width: 110),
          _hCell('', width: 80),
        ],
      ),
    );
  }

  Widget _hCell(String label, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(label,
          textAlign: TextAlign.left,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8B8FA8),
              letterSpacing: 0.5)),
    );
  }

  Widget _addBtn(String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: _kPurple.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: _kPurpleLight,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.add, size: 14, color: _kPurple),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: _kPurple,
                fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _pill(String label, Color text, Color bg) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration:
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontSize: 11, color: text, fontWeight: FontWeight.w600)),
  );
}

// ─── Individual row widget ────────────────────────────────────────────────────
class _BulkRow extends StatefulWidget {
  final _RowData data;
  final int index;
  final int total;
  final ValueChanged<_RowData> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onFullEdit;

  const _BulkRow({
    super.key,
    required this.data,
    required this.index,
    required this.total,
    required this.onChanged,
    required this.onRemove,
    required this.onFullEdit,
  });

  @override
  State<_BulkRow> createState() => _BulkRowState();
}

class _BulkRowState extends State<_BulkRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _desigCtrl;
  late TextEditingController _joiningDateCtrl;
  late TextEditingController _salaryCtrl;
  String? _classId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data.name);
    _phoneCtrl = TextEditingController(text: widget.data.phone);
    _cnicCtrl = TextEditingController(text: widget.data.cnic);
    _desigCtrl =
        TextEditingController(text: widget.data.designation ?? '');
    _joiningDateCtrl = TextEditingController(
        text: widget.data.joiningDate ?? '');
    _salaryCtrl = TextEditingController(
        text: widget.data.salary > 0 ? widget.data.salary.toString() : '');

    // Set initial classId from existing data
    if (widget.data.classId != null) {
      _classId = widget.data.classId;
    } else if (widget.data.assignedClasses.isNotEmpty) {
      _classId = widget.data.assignedClasses.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _desigCtrl.dispose();
    _joiningDateCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      cnic: _cnicCtrl.text,
      designation: _desigCtrl.text.trim().isEmpty
          ? null
          : _desigCtrl.text.trim(),
      classId: _classId,
      joiningDate:
      _joiningDateCtrl.text.isEmpty ? null : _joiningDateCtrl.text,
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
    ));
  }

  Color get _rowBg {
    switch (widget.data.status) {
      case RowStatus.saved:
        return _kGreenBg.withOpacity(0.4);
      case RowStatus.failed:
        return _kRedBg.withOpacity(0.4);
      case RowStatus.saving:
        return _kPurpleLight.withOpacity(0.5);
      default:
        return widget.data.hasError
            ? _kRedBg.withOpacity(0.25)
            : Colors.transparent;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _joiningDateCtrl.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_joiningDateCtrl.text)
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      _joiningDateCtrl.text = formatted;
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = widget.data.status == RowStatus.saved;
    final isSaving = widget.data.status == RowStatus.saving;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: _rowBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row # / status
          SizedBox(
            width: 46,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: isSaving
                  ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kPurple))
                  : isSaved
                  ? const Icon(Icons.check_circle,
                  size: 16, color: _kGreen)
                  : widget.data.hasError
                  ? Tooltip(
                  message: widget.data.errorMsg,
                  child: const Icon(Icons.error_outline,
                      size: 16, color: _kRed))
                  : Text('${widget.index + 1}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500)),
            ),
          ),
          // Name
          _textCell(
            width: 160,
            controller: _nameCtrl,
            hint: 'Full name',
            enabled: !isSaved,
            onChanged: (_) => _emit(),
          ),
          // Contact
          _textCell(
            width: 130,
            controller: _phoneCtrl,
            hint: '03XX-XXXXXXX',
            keyboard: TextInputType.phone,
            enabled: !isSaved,
            onChanged: (_) => _emit(),
          ),
          // CNIC
          _textCell(
            width: 140,
            controller: _cnicCtrl,
            hint: '34101-1234567-8',
            keyboard: TextInputType.number,
            inputFormatters: [_CnicFormatter()],
            enabled: !isSaved,
            onChanged: (_) => _emit(),
          ),
          // Type
          _dropCell(
            width: 90,
            value: widget.data.type,
            items: const ['teacher', 'staff'],
            labels: const ['Teacher', 'Staff'],
            enabled: !isSaved,
            onChanged: (v) =>
                widget.onChanged(widget.data.copyWith(type: v!)),
          ),
          // Designation
          _textCell(
            width: 130,
            controller: _desigCtrl,
            hint: 'Designation',
            enabled: !isSaved,
            onChanged: (_) => _emit(),
          ),
          // Class dropdown
          _classCell(width: 140, enabled: !isSaved),
          // Joining Date
          _dateCell(width: 120, enabled: !isSaved),
          // Salary
          _textCell(
            width: 110,
            controller: _salaryCtrl,
            hint: '0',
            keyboard: TextInputType.number,
            enabled: !isSaved,
            onChanged: (_) => _emit(),
          ),
          // Actions
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isSaved)
                  IconButton(
                    icon: const Icon(Icons.edit_note,
                        size: 18, color: _kPurple),
                    onPressed: widget.onFullEdit,
                    tooltip: 'Full details edit karein',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (!isSaved)
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        size: 17,
                        color: widget.total <= 1
                            ? Colors.grey.shade300
                            : Colors.red.shade300),
                    onPressed:
                    widget.total <= 1 ? null : widget.onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _classCell({required double width, required bool enabled}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Consumer<ClassProvider>(
          builder: (_, classProv, __) {
            final classes = classProv.classes;
            if (classes.isEmpty) {
              return const Text('No classes', style: TextStyle(fontSize: 12, color: Colors.grey));
            }
            return DropdownButtonFormField<String>(
              value: _classId,
              isDense: true,
              isExpanded: true,
              decoration: _dropDecoration(),
              style: const TextStyle(fontSize: 13),
              items: classes
                  .map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name,
                      style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: enabled
                  ? (v) {
                setState(() => _classId = v);
                _emit();
              }
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _dateCell({required double width, required bool enabled}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: TextField(
          controller: _joiningDateCtrl,
          readOnly: true,
          enabled: enabled,
          decoration: _dropDecoration().copyWith(
            suffixIcon: const Icon(Icons.calendar_today,
                size: 16, color: _kPurple),
            hintText: 'YYYY-MM-DD',
          ),
          style: const TextStyle(fontSize: 13),
          onTap: enabled ? _pickDate : null,
        ),
      ),
    );
  }

  InputDecoration _dropDecoration() {
    return InputDecoration(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide:
          const BorderSide(color: _kPurple, width: 1.5)),
      filled: true,
      fillColor: Colors.white,

    );
  }

  Widget _textCell({
    required double width,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboard,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            TextStyle(fontSize: 12, color: Colors.grey.shade400),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: _kPurple, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: true,
            fillColor:
            enabled ? Colors.white : Colors.grey.shade50,
          ),
        ),
      ),
    );
  }

  Widget _dropCell({
    required double width,
    required String value,
    required List<String> items,
    List<String>? labels,
    bool enabled = true,
    required ValueChanged<String?> onChanged,
  }) {
    final displayLabels = labels ?? items;
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: DropdownButtonFormField<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide:
                const BorderSide(color: _kPurple, width: 1.5)),
            filled: true,
            fillColor:
            enabled ? Colors.white : Colors.grey.shade50,
          ),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          iconSize: 16,
          items: List.generate(
              items.length,
                  (i) => DropdownMenuItem(
                  value: items[i],
                  child: Text(displayLabels[i],
                      style: const TextStyle(fontSize: 13)))),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

// ─── Full Edit Dialog ─────────────────────────────────────────────────────────
class _FullEditDialog extends StatefulWidget {
  final _RowData data;
  final void Function(_RowData) onSave;
  final VoidCallback onCancel;

  const _FullEditDialog({
    required this.data,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_FullEditDialog> createState() => _FullEditDialogState();
}

class _FullEditDialogState extends State<_FullEditDialog> {
  late _RowData _editedData;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _fatherCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _religionCtrl;
  late TextEditingController _nationalityCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emergencyCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _referenceCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _designationCtrl;

  String _dob = '';
  String _joiningDate = '';
  List<String> _assignedClasses = [];
  List<String> _assignedSections = [];
  List<String> _subjects = [];
  String _type = 'teacher';
  String _gender = 'Male';
  String _maritalStatus = 'Single';
  String? _bloodGroup;
  String _employmentType = 'Regular';

  final _typeOptions = ['teacher', 'staff'];
  final _genderOptions = ['Male', 'Female', 'Other'];
  final _maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  final _bloodOptions = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  final _employmentOptions = ['Contract', 'Regular', 'Daily'];

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _editedData = d;
    _nameCtrl = TextEditingController(text: d.name);
    _fatherCtrl = TextEditingController(text: d.fatherOrHusbandName);
    _cnicCtrl = TextEditingController(text: d.cnic);
    _religionCtrl = TextEditingController(text: d.religion);
    _nationalityCtrl = TextEditingController(text: d.nationality);
    _addressCtrl = TextEditingController(text: d.address);
    _phoneCtrl = TextEditingController(text: d.phone);
    _emergencyCtrl = TextEditingController(text: d.emergencyPhone);
    _salaryCtrl = TextEditingController(
        text: d.salary > 0 ? d.salary.toString() : '');
    _referenceCtrl = TextEditingController(text: d.reference ?? '');
    _noteCtrl = TextEditingController(text: d.note ?? '');
    _designationCtrl =
        TextEditingController(text: d.designation ?? '');

    _type = d.type;
    _gender = d.gender;
    _maritalStatus = d.maritalStatus;
    _bloodGroup = d.bloodGroup;
    _employmentType = d.employmentType;
    _dob = d.dob;
    _joiningDate =
        d.joiningDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _assignedClasses = List.from(d.assignedClasses);
    _assignedSections = List.from(d.assignedSections);
    _subjects = List.from(d.subjects);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fatherCtrl.dispose();
    _cnicCtrl.dispose();
    _religionCtrl.dispose();
    _nationalityCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emergencyCtrl.dispose();
    _salaryCtrl.dispose();
    _referenceCtrl.dispose();
    _noteCtrl.dispose();
    _designationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initialDate = _dob.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_dob)
        : DateTime(now.year - 25, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _pickJoiningDate() async {
    final now = DateTime.now();
    final initialDate = _joiningDate.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_joiningDate)
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(
              () => _joiningDate = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    // If user didn't touch the multi-class selector, keep the quick classId
    final String? effectiveClassId = _assignedClasses.isEmpty
        ? widget.data.classId   // preserve quick row class
        : null;
    final updated = _editedData.copyWith(
      type: _type,
      name: _nameCtrl.text.trim(),
      fatherOrHusbandName: _fatherCtrl.text.trim(),
      cnic: _cnicCtrl.text.trim(),
      dob: _dob,
      gender: _gender,
      maritalStatus: _maritalStatus,
      bloodGroup: _bloodGroup,
      religion: _religionCtrl.text.trim(),
      nationality: _nationalityCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      emergencyPhone: _emergencyCtrl.text.trim(),
      employmentType: _employmentType,
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
      reference: _referenceCtrl.text.trim().isEmpty
          ? null
          : _referenceCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty
          ? null
          : _noteCtrl.text.trim(),
      designation: _designationCtrl.text.trim().isEmpty
          ? null
          : _designationCtrl.text.trim(),
      joiningDate: _joiningDate.isEmpty ? null : _joiningDate,
      classId: effectiveClassId,
      assignedClasses: _assignedClasses,
      assignedSections: _assignedSections,
      subjects: _subjects,
      hasError: false,
      errorMsg: '',
    );
    widget.onSave(updated);
  }

  // ─── Class & Section selector ─────────────────────────────────────────
  Widget _buildClassSectionSelector() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, _) {
        final classes = classProvider.classes;
        if (classes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 15, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pehle classes add karein.',
                    style:
                    TextStyle(fontSize: 12, color: Colors.amber),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: classes.map((cls) {
                final isSelected = _assignedClasses.contains(cls.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _assignedClasses.remove(cls.id);
                        _assignedSections.removeWhere((sec) =>
                        sec.startsWith(cls.name + ' section ') ||
                            sec.startsWith(cls.name + ' Section '));
                      } else {
                        _assignedClasses.add(cls.id!);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? _kPurple : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _kPurple
                            : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          cls.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_assignedClasses.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Sections select karein:',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kPurple),
              ),
              const SizedBox(height: 8),
              ..._assignedClasses.map((classId) {
                final cls =
                classes.firstWhere((c) => c.id == classId);
                final sections = cls.sections ?? [];
                if (sections.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Row(children: [
                      Icon(Icons.info_outline,
                          size: 14,
                          color: Colors.orange.shade400),
                      const SizedBox(width: 6),
                      Text(
                        '${cls.name} mein koi section nahi hai',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700),
                      ),
                    ]),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cls.name,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: sections.map((section) {
                          final sectionName = section.sectionName;
                          final isSelected =
                          _assignedSections.contains(sectionName);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _assignedSections.remove(sectionName);
                                } else {
                                  _assignedSections.add(sectionName);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kPurple
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? _kPurple
                                      : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(Icons.check,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    sectionName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }

  // ─── Subject multi-select ──────────────────────────────────────────────
  Widget _buildSubjectSelector() {
    return Consumer<MuddulProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(
              child: CircularProgressIndicator(strokeWidth: 2));
        }
        final allSubjects =
        provider.mudduls.map((m) => m.subjectName).toSet().toList()
          ..sort();
        if (allSubjects.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(children: [
              Icon(Icons.info_outline,
                  size: 16, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Koi subject nahi mila. Pehle subjects add karein.',
                  style: TextStyle(fontSize: 12, color: Colors.amber),
                ),
              ),
            ]),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 6,
          children: allSubjects.map((subject) {
            final isSelected = _subjects.contains(subject);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _subjects.remove(subject);
                  } else {
                    _subjects.add(subject);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? _kPurple : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _kPurple : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                        isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Dialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 12,
        vertical: 24,
      ),
      child: Container(
        width: isWide ? 700 : double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kPurple, _kPurpleMid],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.person_add_alt_1_outlined,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameCtrl.text.trim().isEmpty
                            ? 'Full Details'
                            : _nameCtrl.text.trim(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        _type == 'teacher' ? 'Teacher' : 'Staff Member',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: widget.onCancel,
                ),
              ]),
            ),

            // ── Body ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: isWide
                      ? _buildDesktopForm()
                      : _buildMobileForm(),
                ),
              ),
            ),

            // ── Footer ──────────────────────────────────────────────
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _kPurple),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: _kPurple)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Save Row'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Desktop form (2-column grid) ──────────────────────────────────────
  Widget _buildDesktopForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role toggle
        _dialogSection('Role', Icons.manage_accounts_outlined, [
          Row(
            children: _typeOptions.map((t) {
              final sel = _type == t;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: sel ? _kPurple : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? _kPurple : Colors.grey.shade300),
                  ),
                  child: Text(
                    t == 'teacher' ? 'Teacher' : 'Staff',
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ]),

        // Personal Info
        _dialogSection(
            'Personal Information', Icons.person_outline, [
          _row2([
            _df('Full Name *', _nameCtrl,
                validator: (v) =>
                v!.trim().isEmpty ? 'Required' : null,
                onChanged: (_) => setState(() {})),
            _df('Designation', _designationCtrl,
                hint: 'e.g. Principal, Head Teacher...',
                onChanged: (_) => setState(() {})),
          ]),
          _row2([
            _df(
              _maritalStatus == 'Married'
                  ? 'Husband Name *'
                  : 'Father Name *',
              _fatherCtrl,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null,
            ),
            _cnicField(),
          ]),
          _row2([
            _dateField('Date of Birth', _dob, _pickDob,
                validator: (_) =>
                _dob.isEmpty ? 'Required' : null),
            _dateField('Joining Date', _joiningDate,
                _pickJoiningDate),
          ]),
          _row2([
            _dropdownField('Gender', _gender, _genderOptions,
                    (v) => setState(() => _gender = v!)),
            _dropdownField('Marital Status', _maritalStatus,
                _maritalOptions,
                    (v) => setState(() => _maritalStatus = v!)),
          ]),
          _row2([
            _dropdownField('Blood Group (Optional)', _bloodGroup,
                _bloodOptions,
                    (v) => setState(() => _bloodGroup = v),
                nullable: true),
            _df('Religion *', _religionCtrl,
                validator: (v) =>
                v!.trim().isEmpty ? 'Required' : null),
          ]),
          _df('Nationality *', _nationalityCtrl,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null),
        ]),

        // Contact
        _dialogSection(
            'Contact Information', Icons.contact_phone_outlined, [
          _df('Address *', _addressCtrl,
              maxLines: 2,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null),
          _row2([
            _df('Phone No *', _phoneCtrl,
                keyboard: TextInputType.phone,
                validator: (v) =>
                v!.trim().isEmpty ? 'Required' : null),
            _df('Emergency No *', _emergencyCtrl,
                keyboard: TextInputType.phone,
                validator: (v) =>
                v!.trim().isEmpty ? 'Required' : null),
          ]),
        ]),

        // Job Details
        _dialogSection('Job Details', Icons.work_outline, [
          _row2([
            _dropdownField('Employment Type', _employmentType,
                _employmentOptions,
                    (v) => setState(() => _employmentType = v!)),
            _salaryField(),
          ]),
        ]),

        // Classes & Sections
        _dialogSection(
            'Assigned Classes & Sections', Icons.class_outlined, [
          _buildClassSectionSelector(),
        ]),

        // Subjects
        _dialogSection(
            'Assigned Subjects', Icons.menu_book_outlined, [
          _buildSubjectSelector(),
        ]),

        // Additional Info
        _dialogSection(
            'Additional Info (Optional)', Icons.info_outline, [
          _row2([
            _df('Reference', _referenceCtrl),
            _df('Note', _noteCtrl, maxLines: 3),
          ]),
        ]),
      ],
    );
  }

  // ── Mobile form (single column) ───────────────────────────────────────
  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dialogSection('Role', Icons.manage_accounts_outlined, [
          Wrap(
            spacing: 8,
            children: _typeOptions.map((t) {
              final sel = _type == t;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _kPurple : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? _kPurple : Colors.grey.shade300),
                  ),
                  child: Text(
                    t == 'teacher' ? 'Teacher' : 'Staff',
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ]),
        _dialogSection(
            'Personal Information', Icons.person_outline, [
          _df('Full Name *', _nameCtrl,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null,
              onChanged: (_) => setState(() {})),
          _df('Designation', _designationCtrl,
              hint: 'e.g. Principal, Head Teacher...',
              onChanged: (_) => setState(() {})),
          _df(
            _maritalStatus == 'Married' ? 'Husband Name *' : 'Father Name *',
            _fatherCtrl,
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
          ),
          _cnicField(),
          _dateField('Date of Birth', _dob, _pickDob,
              validator: (_) =>
              _dob.isEmpty ? 'Required' : null),
          _dateField(
              'Joining Date', _joiningDate, _pickJoiningDate),
          _dropdownField('Gender', _gender, _genderOptions,
                  (v) => setState(() => _gender = v!)),
          _dropdownField('Marital Status', _maritalStatus,
              _maritalOptions,
                  (v) => setState(() => _maritalStatus = v!)),
          _dropdownField('Blood Group (Optional)', _bloodGroup,
              _bloodOptions,
                  (v) => setState(() => _bloodGroup = v),
              nullable: true),
          _df('Religion *', _religionCtrl,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null),
          _df('Nationality *', _nationalityCtrl,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null),
        ]),
        _dialogSection(
            'Contact Information', Icons.contact_phone_outlined, [
          _df('Address *', _addressCtrl,
              maxLines: 2,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null),
          _df('Phone No *', _phoneCtrl,
              keyboard: TextInputType.phone,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null),
          _df('Emergency No *', _emergencyCtrl,
              keyboard: TextInputType.phone,
              validator: (v) =>
              v!.trim().isEmpty ? 'Required' : null),
        ]),
        _dialogSection('Job Details', Icons.work_outline, [
          _dropdownField('Employment Type', _employmentType,
              _employmentOptions,
                  (v) => setState(() => _employmentType = v!)),
          _salaryField(),
        ]),
        _dialogSection(
            'Assigned Classes & Sections', Icons.class_outlined, [
          _buildClassSectionSelector(),
        ]),
        _dialogSection(
            'Assigned Subjects', Icons.menu_book_outlined, [
          _buildSubjectSelector(),
        ]),
        _dialogSection(
            'Additional Info (Optional)', Icons.info_outline, [
          _df('Reference', _referenceCtrl),
          _df('Note', _noteCtrl, maxLines: 3),
        ]),
      ],
    );
  }

  // ─── Section wrapper ──────────────────────────────────────────────────
  Widget _dialogSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEFF3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: _kPurpleLight,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: _kPurple),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kPurple)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _spaced(children, 10),
          ),
        ),
      ]),
    );
  }

  // ─── Field helpers ────────────────────────────────────────────────────
  Widget _row2(List<Widget> children) {
    return Row(
      children: children
          .map((w) => Expanded(child: w))
          .expand((w) => [w, const SizedBox(width: 10)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _df(
      String label,
      TextEditingController ctrl, {
        String? hint,
        int maxLines = 1,
        TextInputType? keyboard,
        String? Function(String?)? validator,
        ValueChanged<String>? onChanged,
      }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: _deco(label, hint: hint),
      validator: validator,
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _cnicField() {
    return TextFormField(
      controller: _cnicCtrl,
      keyboardType: TextInputType.number,
      maxLength: 15,
      inputFormatters: [_CnicFormatter()],
      decoration:
      _deco('CNIC (34101-1234567-8)').copyWith(counterText: ''),
      style: const TextStyle(fontSize: 13),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null; // optional in bulk
        final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
        if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
        return null;
      },
    );
  }

  Widget _salaryField() {
    return TextFormField(
      controller: _salaryCtrl,
      decoration: _deco('Salary *').copyWith(prefixText: 'Rs  '),
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 13),
      validator: (v) =>
      v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _dateField(
      String label,
      String value,
      VoidCallback onTap, {
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: _deco(label).copyWith(
        suffixIcon: const Icon(Icons.calendar_today,
            size: 16, color: _kPurple),
      ),
      style: const TextStyle(fontSize: 13),
      onTap: onTap,
      validator: validator,
    );
  }

  Widget _dropdownField<T>(
      String label,
      T value,
      List<String> items,
      ValueChanged<T?> onChanged, {
        bool nullable = false,
      }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _deco(label),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      items: [
        if (nullable)
          const DropdownMenuItem(
              value: null,
              child: Text('Select (Optional)')) as DropdownMenuItem<T>,
        ...items.map(
                (i) => DropdownMenuItem<T>(value: i as T, child: Text(i))),
      ],
      onChanged: onChanged,
    );
  }

  InputDecoration _deco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _kPurple, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  List<Widget> _spaced(List<Widget> children, double gap) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) result.add(SizedBox(height: gap));
    }
    return result;
  }
}

// ─── Bulk Edit Screen (unchanged, kept for completeness) ──────────────────────
// ... rest of the existing BulkEditStaffScreen code remains exactly as it was.
// (I am not modifying that part since the user only requested fixes to the bulk add form.)


// class _FullEditDialog extends StatefulWidget {
//   final _RowData data;
//   final void Function(_RowData) onSave;
//   final VoidCallback onCancel;
//
//   const _FullEditDialog({
//     required this.data,
//     required this.onSave,
//     required this.onCancel,
//   });
//
//   @override
//   State<_FullEditDialog> createState() => _FullEditDialogState();
// }
//
// class _FullEditDialogState extends State<_FullEditDialog> {
//   late _RowData _editedData;
//   final _formKey = GlobalKey<FormState>();
//
//   late TextEditingController _nameCtrl;
//   late TextEditingController _fatherCtrl;
//   late TextEditingController _cnicCtrl;
//   late TextEditingController _religionCtrl;
//   late TextEditingController _nationalityCtrl;
//   late TextEditingController _addressCtrl;
//   late TextEditingController _phoneCtrl;
//   late TextEditingController _emergencyCtrl;
//   late TextEditingController _salaryCtrl;
//   late TextEditingController _referenceCtrl;
//   late TextEditingController _noteCtrl;
//   late TextEditingController _designationCtrl;
//
//   String _dob = '';
//   String _joiningDate = '';
//   List<String> _assignedClasses = [];
//   List<String> _assignedSections = [];
//   List<String> _subjects = [];
//   String _type = 'teacher';
//   String _gender = 'Male';
//   String _maritalStatus = 'Single';
//   String? _bloodGroup;
//   String _employmentType = 'Regular';
//
//   final _typeOptions = ['teacher', 'staff'];
//   final _genderOptions = ['Male', 'Female', 'Other'];
//   final _maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
//   final _bloodOptions = [
//     'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
//   ];
//   final _employmentOptions = ['Contract', 'Regular', 'Daily'];
//
//   @override
//   void initState() {
//     super.initState();
//     final d = widget.data;
//     _editedData = d;
//     _nameCtrl = TextEditingController(text: d.name);
//     _fatherCtrl = TextEditingController(text: d.fatherOrHusbandName);
//     _cnicCtrl = TextEditingController(text: d.cnic);
//     _religionCtrl = TextEditingController(text: d.religion);
//     _nationalityCtrl = TextEditingController(text: d.nationality);
//     _addressCtrl = TextEditingController(text: d.address);
//     _phoneCtrl = TextEditingController(text: d.phone);
//     _emergencyCtrl = TextEditingController(text: d.emergencyPhone);
//     _salaryCtrl = TextEditingController(
//         text: d.salary > 0 ? d.salary.toString() : '');
//     _referenceCtrl = TextEditingController(text: d.reference ?? '');
//     _noteCtrl = TextEditingController(text: d.note ?? '');
//     _designationCtrl =
//         TextEditingController(text: d.designation ?? '');
//
//     _type = d.type;
//     _gender = d.gender;
//     _maritalStatus = d.maritalStatus;
//     _bloodGroup = d.bloodGroup;
//     _employmentType = d.employmentType;
//     _dob = d.dob;
//     _joiningDate =
//         d.joiningDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
//     _assignedClasses = List.from(d.assignedClasses);
//     _assignedSections = List.from(d.assignedSections);
//     _subjects = List.from(d.subjects);
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _fatherCtrl.dispose();
//     _cnicCtrl.dispose();
//     _religionCtrl.dispose();
//     _nationalityCtrl.dispose();
//     _addressCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emergencyCtrl.dispose();
//     _salaryCtrl.dispose();
//     _referenceCtrl.dispose();
//     _noteCtrl.dispose();
//     _designationCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickDob() async {
//     final now = DateTime.now();
//     final initialDate = _dob.isNotEmpty
//         ? DateFormat('yyyy-MM-dd').parse(_dob)
//         : DateTime(now.year - 25, 1, 1);
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(1940),
//       lastDate: now,
//     );
//     if (picked != null) {
//       setState(() => _dob = DateFormat('yyyy-MM-dd').format(picked));
//     }
//   }
//
//   Future<void> _pickJoiningDate() async {
//     final now = DateTime.now();
//     final initialDate = _joiningDate.isNotEmpty
//         ? DateFormat('yyyy-MM-dd').parse(_joiningDate)
//         : now;
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(2000),
//       lastDate: now,
//     );
//     if (picked != null) {
//       setState(
//               () => _joiningDate = DateFormat('yyyy-MM-dd').format(picked));
//     }
//   }
//
//   void _save() {
//     if (!_formKey.currentState!.validate()) return;
//     final updated = _editedData.copyWith(
//       type: _type,
//       name: _nameCtrl.text.trim(),
//       fatherOrHusbandName: _fatherCtrl.text.trim(),
//       cnic: _cnicCtrl.text.trim(),
//       dob: _dob,
//       gender: _gender,
//       maritalStatus: _maritalStatus,
//       bloodGroup: _bloodGroup,
//       religion: _religionCtrl.text.trim(),
//       nationality: _nationalityCtrl.text.trim(),
//       address: _addressCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       emergencyPhone: _emergencyCtrl.text.trim(),
//       employmentType: _employmentType,
//       salary: double.tryParse(_salaryCtrl.text) ?? 0,
//       reference: _referenceCtrl.text.trim().isEmpty
//           ? null
//           : _referenceCtrl.text.trim(),
//       note: _noteCtrl.text.trim().isEmpty
//           ? null
//           : _noteCtrl.text.trim(),
//       designation: _designationCtrl.text.trim().isEmpty
//           ? null
//           : _designationCtrl.text.trim(),
//       joiningDate: _joiningDate.isEmpty ? null : _joiningDate,
//       assignedClasses: _assignedClasses,
//       assignedSections: _assignedSections,
//       subjects: _subjects,
//       hasError: false,
//       errorMsg: '',
//     );
//     widget.onSave(updated);
//   }
//
//   // ─── Class & Section selector ─────────────────────────────────────────
//   Widget _buildClassSectionSelector() {
//     return Consumer<ClassProvider>(
//       builder: (context, classProvider, _) {
//         final classes = classProvider.classes;
//         if (classes.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.amber.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.amber.shade200),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.info_outline,
//                     size: 15, color: Colors.amber.shade700),
//                 const SizedBox(width: 8),
//                 const Expanded(
//                   child: Text(
//                     'Pehle classes add karein.',
//                     style:
//                     TextStyle(fontSize: 12, color: Colors.amber),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Wrap(
//               spacing: 8,
//               runSpacing: 6,
//               children: classes.map((cls) {
//                 final isSelected = _assignedClasses.contains(cls.id);
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       if (isSelected) {
//                         _assignedClasses.remove(cls.id);
//                         _assignedSections.removeWhere((sec) =>
//                         sec.startsWith(cls.name + ' section ') ||
//                             sec.startsWith(cls.name + ' Section '));
//                       } else {
//                         _assignedClasses.add(cls.id!);
//                       }
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 150),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 7),
//                     decoration: BoxDecoration(
//                       color: isSelected ? _kPurple : Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected
//                             ? _kPurple
//                             : Colors.grey.shade300,
//                         width: isSelected ? 1.5 : 0.8,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         if (isSelected) ...[
//                           const Icon(Icons.check,
//                               size: 14, color: Colors.white),
//                           const SizedBox(width: 4),
//                         ],
//                         Text(
//                           cls.name,
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             color: isSelected
//                                 ? Colors.white
//                                 : Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//             if (_assignedClasses.isNotEmpty) ...[
//               const SizedBox(height: 14),
//               Text(
//                 'Sections select karein:',
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: _kPurple),
//               ),
//               const SizedBox(height: 8),
//               ..._assignedClasses.map((classId) {
//                 final cls =
//                 classes.firstWhere((c) => c.id == classId);
//                 final sections = cls.sections ?? [];
//                 if (sections.isEmpty) {
//                   return Padding(
//                     padding: const EdgeInsets.only(left: 4, bottom: 8),
//                     child: Row(children: [
//                       Icon(Icons.info_outline,
//                           size: 14,
//                           color: Colors.orange.shade400),
//                       const SizedBox(width: 6),
//                       Text(
//                         '${cls.name} mein koi section nahi hai',
//                         style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.orange.shade700),
//                       ),
//                     ]),
//                   );
//                 }
//                 return Padding(
//                   padding: const EdgeInsets.only(left: 4, bottom: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(cls.name,
//                           style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey.shade700)),
//                       const SizedBox(height: 6),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 6,
//                         children: sections.map((section) {
//                           final sectionName = section.sectionName;
//                           final isSelected =
//                           _assignedSections.contains(sectionName);
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 if (isSelected) {
//                                   _assignedSections.remove(sectionName);
//                                 } else {
//                                   _assignedSections.add(sectionName);
//                                 }
//                               });
//                             },
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 150),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 7),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? _kPurple
//                                     : Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? _kPurple
//                                       : Colors.grey.shade300,
//                                   width: isSelected ? 1.5 : 0.8,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   if (isSelected) ...[
//                                     const Icon(Icons.check,
//                                         size: 14, color: Colors.white),
//                                     const SizedBox(width: 4),
//                                   ],
//                                   Text(
//                                     sectionName,
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w500,
//                                       color: isSelected
//                                           ? Colors.white
//                                           : Colors.black87,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ],
//           ],
//         );
//       },
//     );
//   }
//
//   // ─── Subject multi-select ──────────────────────────────────────────────
//   Widget _buildSubjectSelector() {
//     return Consumer<MuddulProvider>(
//       builder: (context, provider, _) {
//         if (provider.loading) {
//           return const Center(
//               child: CircularProgressIndicator(strokeWidth: 2));
//         }
//         final allSubjects =
//         provider.mudduls.map((m) => m.subjectName).toSet().toList()
//           ..sort();
//         if (allSubjects.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.amber.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.amber.shade200),
//             ),
//             child: Row(children: [
//               Icon(Icons.info_outline,
//                   size: 16, color: Colors.amber.shade700),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text(
//                   'Koi subject nahi mila. Pehle subjects add karein.',
//                   style: TextStyle(fontSize: 12, color: Colors.amber),
//                 ),
//               ),
//             ]),
//           );
//         }
//         return Wrap(
//           spacing: 8,
//           runSpacing: 6,
//           children: allSubjects.map((subject) {
//             final isSelected = _subjects.contains(subject);
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (isSelected) {
//                     _subjects.remove(subject);
//                   } else {
//                     _subjects.add(subject);
//                   }
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 150),
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 7),
//                 decoration: BoxDecoration(
//                   color: isSelected ? _kPurple : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: isSelected ? _kPurple : Colors.grey.shade300,
//                     width: isSelected ? 1.5 : 0.8,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (isSelected) ...[
//                       const Icon(Icons.check,
//                           size: 14, color: Colors.white),
//                       const SizedBox(width: 4),
//                     ],
//                     Text(
//                       subject,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color:
//                         isSelected ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
//
//   // ─── Build ────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width >= 700;
//
//     return Dialog(
//       shape:
//       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding: EdgeInsets.symmetric(
//         horizontal: isWide ? 40 : 12,
//         vertical: 24,
//       ),
//       child: Container(
//         width: isWide ? 700 : double.infinity,
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.92,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ── Header ──────────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [_kPurple, _kPurpleMid],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius:
//                 BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: Row(children: [
//                 const Icon(Icons.person_add_alt_1_outlined,
//                     color: Colors.white70, size: 20),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _nameCtrl.text.trim().isEmpty
//                             ? 'Full Details'
//                             : _nameCtrl.text.trim(),
//                         style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white),
//                       ),
//                       Text(
//                         _type == 'teacher' ? 'Teacher' : 'Staff Member',
//                         style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.white.withOpacity(0.7)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white70),
//                   onPressed: widget.onCancel,
//                 ),
//               ]),
//             ),
//
//             // ── Body ────────────────────────────────────────────────
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Form(
//                   key: _formKey,
//                   child: isWide
//                       ? _buildDesktopForm()
//                       : _buildMobileForm(),
//                 ),
//               ),
//             ),
//
//             // ── Footer ──────────────────────────────────────────────
//             const Divider(height: 1),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   OutlinedButton(
//                     onPressed: widget.onCancel,
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: _kPurple),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(color: _kPurple)),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton.icon(
//                     onPressed: _save,
//                     icon: const Icon(Icons.check, size: 16),
//                     label: const Text('Save Row'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _kPurple,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Desktop form (2-column grid) ──────────────────────────────────────
//   Widget _buildDesktopForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Role toggle
//         _dialogSection('Role', Icons.manage_accounts_outlined, [
//           Row(
//             children: _typeOptions.map((t) {
//               final sel = _type == t;
//               return GestureDetector(
//                 onTap: () => setState(() => _type = t),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 150),
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 20, vertical: 8),
//                   margin: const EdgeInsets.only(right: 10),
//                   decoration: BoxDecoration(
//                     color: sel ? _kPurple : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: sel ? _kPurple : Colors.grey.shade300),
//                   ),
//                   child: Text(
//                     t == 'teacher' ? 'Teacher' : 'Staff',
//                     style: TextStyle(
//                       color: sel ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ]),
//
//         // Personal Info
//         _dialogSection(
//             'Personal Information', Icons.person_outline, [
//           _row2([
//             _df('Full Name *', _nameCtrl,
//                 validator: (v) =>
//                 v!.trim().isEmpty ? 'Required' : null,
//                 onChanged: (_) => setState(() {})),
//             _df('Designation', _designationCtrl,
//                 hint: 'e.g. Principal, Head Teacher...',
//                 onChanged: (_) => setState(() {})),
//           ]),
//           _row2([
//             _df(
//               _maritalStatus == 'Married'
//                   ? 'Husband Name *'
//                   : 'Father Name *',
//               _fatherCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null,
//             ),
//             _cnicField(),
//           ]),
//           _row2([
//             _dateField('Date of Birth', _dob, _pickDob,
//                 validator: (_) =>
//                 _dob.isEmpty ? 'Required' : null),
//             _dateField('Joining Date', _joiningDate,
//                 _pickJoiningDate),
//           ]),
//           _row2([
//             _dropdownField('Gender', _gender, _genderOptions,
//                     (v) => setState(() => _gender = v!)),
//             _dropdownField('Marital Status', _maritalStatus,
//                 _maritalOptions,
//                     (v) => setState(() => _maritalStatus = v!)),
//           ]),
//           _row2([
//             _dropdownField('Blood Group (Optional)', _bloodGroup,
//                 _bloodOptions,
//                     (v) => setState(() => _bloodGroup = v),
//                 nullable: true),
//             _df('Religion *', _religionCtrl,
//                 validator: (v) =>
//                 v!.trim().isEmpty ? 'Required' : null),
//           ]),
//           _df('Nationality *', _nationalityCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//         ]),
//
//         // Contact
//         _dialogSection(
//             'Contact Information', Icons.contact_phone_outlined, [
//           _df('Address *', _addressCtrl,
//               maxLines: 2,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//           _row2([
//             _df('Phone No *', _phoneCtrl,
//                 keyboard: TextInputType.phone,
//                 validator: (v) =>
//                 v!.trim().isEmpty ? 'Required' : null),
//             _df('Emergency No *', _emergencyCtrl,
//                 keyboard: TextInputType.phone,
//                 validator: (v) =>
//                 v!.trim().isEmpty ? 'Required' : null),
//           ]),
//         ]),
//
//         // Job Details
//         _dialogSection('Job Details', Icons.work_outline, [
//           _row2([
//             _dropdownField('Employment Type', _employmentType,
//                 _employmentOptions,
//                     (v) => setState(() => _employmentType = v!)),
//             _salaryField(),
//           ]),
//         ]),
//
//         // Classes & Sections
//         _dialogSection(
//             'Assigned Classes & Sections', Icons.class_outlined, [
//           _buildClassSectionSelector(),
//         ]),
//
//         // Subjects
//         _dialogSection(
//             'Assigned Subjects', Icons.menu_book_outlined, [
//           _buildSubjectSelector(),
//         ]),
//
//         // Additional Info
//         _dialogSection(
//             'Additional Info (Optional)', Icons.info_outline, [
//           _row2([
//             _df('Reference', _referenceCtrl),
//             _df('Note', _noteCtrl, maxLines: 3),
//           ]),
//         ]),
//       ],
//     );
//   }
//
//   // ── Mobile form (single column) ───────────────────────────────────────
//   Widget _buildMobileForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _dialogSection('Role', Icons.manage_accounts_outlined, [
//           Wrap(
//             spacing: 8,
//             children: _typeOptions.map((t) {
//               final sel = _type == t;
//               return GestureDetector(
//                 onTap: () => setState(() => _type = t),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 150),
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 20, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: sel ? _kPurple : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: sel ? _kPurple : Colors.grey.shade300),
//                   ),
//                   child: Text(
//                     t == 'teacher' ? 'Teacher' : 'Staff',
//                     style: TextStyle(
//                       color: sel ? Colors.white : Colors.black87,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ]),
//         _dialogSection(
//             'Personal Information', Icons.person_outline, [
//           _df('Full Name *', _nameCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null,
//               onChanged: (_) => setState(() {})),
//           _df('Designation', _designationCtrl,
//               hint: 'e.g. Principal, Head Teacher...',
//               onChanged: (_) => setState(() {})),
//           _df(
//             _maritalStatus == 'Married' ? 'Husband Name *' : 'Father Name *',
//             _fatherCtrl,
//             validator: (v) => v!.trim().isEmpty ? 'Required' : null,
//           ),
//           _cnicField(),
//           _dateField('Date of Birth', _dob, _pickDob,
//               validator: (_) =>
//               _dob.isEmpty ? 'Required' : null),
//           _dateField(
//               'Joining Date', _joiningDate, _pickJoiningDate),
//           _dropdownField('Gender', _gender, _genderOptions,
//                   (v) => setState(() => _gender = v!)),
//           _dropdownField('Marital Status', _maritalStatus,
//               _maritalOptions,
//                   (v) => setState(() => _maritalStatus = v!)),
//           _dropdownField('Blood Group (Optional)', _bloodGroup,
//               _bloodOptions,
//                   (v) => setState(() => _bloodGroup = v),
//               nullable: true),
//           _df('Religion *', _religionCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//           _df('Nationality *', _nationalityCtrl,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//         ]),
//         _dialogSection(
//             'Contact Information', Icons.contact_phone_outlined, [
//           _df('Address *', _addressCtrl,
//               maxLines: 2,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//           _df('Phone No *', _phoneCtrl,
//               keyboard: TextInputType.phone,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//           _df('Emergency No *', _emergencyCtrl,
//               keyboard: TextInputType.phone,
//               validator: (v) =>
//               v!.trim().isEmpty ? 'Required' : null),
//         ]),
//         _dialogSection('Job Details', Icons.work_outline, [
//           _dropdownField('Employment Type', _employmentType,
//               _employmentOptions,
//                   (v) => setState(() => _employmentType = v!)),
//           _salaryField(),
//         ]),
//         _dialogSection(
//             'Assigned Classes & Sections', Icons.class_outlined, [
//           _buildClassSectionSelector(),
//         ]),
//         _dialogSection(
//             'Assigned Subjects', Icons.menu_book_outlined, [
//           _buildSubjectSelector(),
//         ]),
//         _dialogSection(
//             'Additional Info (Optional)', Icons.info_outline, [
//           _df('Reference', _referenceCtrl),
//           _df('Note', _noteCtrl, maxLines: 3),
//         ]),
//       ],
//     );
//   }
//
//   // ─── Section wrapper ──────────────────────────────────────────────────
//   Widget _dialogSection(
//       String title, IconData icon, List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFEEEFF3)),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: const BoxDecoration(
//             color: _kPurpleLight,
//             borderRadius:
//             BorderRadius.vertical(top: Radius.circular(12)),
//           ),
//           child: Row(children: [
//             Icon(icon, size: 16, color: _kPurple),
//             const SizedBox(width: 8),
//             Text(title,
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: _kPurple)),
//           ]),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: _spaced(children, 10),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   // ─── Field helpers ────────────────────────────────────────────────────
//   Widget _row2(List<Widget> children) {
//     return Row(
//       children: children
//           .map((w) => Expanded(child: w))
//           .expand((w) => [w, const SizedBox(width: 10)])
//           .toList()
//         ..removeLast(),
//     );
//   }
//
//   Widget _df(
//       String label,
//       TextEditingController ctrl, {
//         String? hint,
//         int maxLines = 1,
//         TextInputType? keyboard,
//         String? Function(String?)? validator,
//         ValueChanged<String>? onChanged,
//       }) {
//     return TextFormField(
//       controller: ctrl,
//       maxLines: maxLines,
//       keyboardType: keyboard,
//       onChanged: onChanged,
//       decoration: _deco(label, hint: hint),
//       validator: validator,
//       style: const TextStyle(fontSize: 13),
//     );
//   }
//
//   Widget _cnicField() {
//     return TextFormField(
//       controller: _cnicCtrl,
//       keyboardType: TextInputType.number,
//       maxLength: 15,
//       inputFormatters: [_CnicFormatter()],
//       decoration:
//       _deco('CNIC (34101-1234567-8)').copyWith(counterText: ''),
//       style: const TextStyle(fontSize: 13),
//       validator: (v) {
//         if (v == null || v.trim().isEmpty) return null; // optional in bulk
//         final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
//         if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
//         return null;
//       },
//     );
//   }
//
//   Widget _salaryField() {
//     return TextFormField(
//       controller: _salaryCtrl,
//       decoration: _deco('Salary *').copyWith(prefixText: 'Rs  '),
//       keyboardType: TextInputType.number,
//       style: const TextStyle(fontSize: 13),
//       validator: (v) =>
//       v == null || v.trim().isEmpty ? 'Required' : null,
//     );
//   }
//
//   Widget _dateField(
//       String label,
//       String value,
//       VoidCallback onTap, {
//         String? Function(String?)? validator,
//       }) {
//     return TextFormField(
//       readOnly: true,
//       controller: TextEditingController(text: value),
//       decoration: _deco(label).copyWith(
//         suffixIcon: const Icon(Icons.calendar_today,
//             size: 16, color: _kPurple),
//       ),
//       style: const TextStyle(fontSize: 13),
//       onTap: onTap,
//       validator: validator,
//     );
//   }
//
//   Widget _dropdownField<T>(
//       String label,
//       T value,
//       List<String> items,
//       ValueChanged<T?> onChanged, {
//         bool nullable = false,
//       }) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       decoration: _deco(label),
//       style: const TextStyle(fontSize: 13, color: Colors.black87),
//       items: [
//         if (nullable)
//           const DropdownMenuItem(
//               value: null,
//               child: Text('Select (Optional)')) as DropdownMenuItem<T>,
//         ...items.map(
//                 (i) => DropdownMenuItem<T>(value: i as T, child: Text(i))),
//       ],
//       onChanged: onChanged,
//     );
//   }
//
//   InputDecoration _deco(String label, {String? hint}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       labelStyle: const TextStyle(fontSize: 12),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: _kPurple, width: 1.5),
//       ),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     );
//   }
//
//   List<Widget> _spaced(List<Widget> children, double gap) {
//     final result = <Widget>[];
//     for (int i = 0; i < children.length; i++) {
//       result.add(children[i]);
//       if (i < children.length - 1) result.add(SizedBox(height: gap));
//     }
//     return result;
//   }
// }

// ─── Bulk Edit Screen ─────────────────────────────────────────────────────────

enum _EditField {
  employmentType,
  gender,
  designation,
  type,
  nationality,
  religion,
}

extension _EditFieldLabel on _EditField {
  String get label {
    switch (this) {
      case _EditField.employmentType:
        return 'Employment Type';
      case _EditField.gender:
        return 'Gender';
      case _EditField.designation:
        return 'Designation';
      case _EditField.type:
        return 'Role (Teacher/Staff)';
      case _EditField.nationality:
        return 'Nationality';
      case _EditField.religion:
        return 'Religion';
    }
  }

  IconData get icon {
    switch (this) {
      case _EditField.employmentType:
        return Icons.work_outline;
      case _EditField.gender:
        return Icons.person_outline;
      case _EditField.designation:
        return Icons.badge_outlined;
      case _EditField.type:
        return Icons.manage_accounts_outlined;
      case _EditField.nationality:
        return Icons.flag_outlined;
      case _EditField.religion:
        return Icons.book_outlined;
    }
  }
}

class BulkEditStaffScreen extends StatefulWidget {
  final String? initialTypeFilter;

  const BulkEditStaffScreen({super.key, this.initialTypeFilter});

  @override
  State<BulkEditStaffScreen> createState() => _BulkEditStaffScreenState();
}

class _BulkEditStaffScreenState extends State<BulkEditStaffScreen> {
  final Set<String> _selectedIds = {};
  String _typeFilter = 'all';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  bool _isSaving = false;
  final Map<String, String> _saveStatus = {};

  @override
  void initState() {
    super.initState();
    _typeFilter = widget.initialTypeFilter ?? 'all';
    _searchCtrl.addListener(
            () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
    Future.microtask(() {
      context.read<StaffProvider>().fetchTeachers();
      context.read<StaffProvider>().fetchStaffOnly();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<StaffMember> _filteredList(StaffProvider provider) {
    List<StaffMember> all;
    if (_typeFilter == 'teacher') {
      all = provider.teachers;
    } else if (_typeFilter == 'staff') {
      all = provider.staffOnly;
    } else {
      all = [...provider.teachers, ...provider.staffOnly];
    }
    if (_searchQuery.isEmpty) return all;
    return all
        .where((s) =>
    s.name.toLowerCase().contains(_searchQuery) ||
        s.phone.toLowerCase().contains(_searchQuery) ||
        (s.designation ?? '').toLowerCase().contains(_searchQuery))
        .toList();
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id))
        _selectedIds.remove(id);
      else
        _selectedIds.add(id);
    });
  }

  void _selectAll(List<StaffMember> list) {
    setState(() {
      if (_selectedIds.length == list.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(list.map((s) => s.id!));
      }
    });
  }

  void _openBulkEditSheet(List<StaffMember> allList) {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select at least one person to edit.'),
            backgroundColor: _kRed),
      );
      return;
    }
    final selected =
    allList.where((s) => _selectedIds.contains(s.id)).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BulkEditSheet(
        selected: selected,
        onApply: (field, value) => _applyBulkEdit(field, value, allList),
      ),
    );
  }

  Future<void> _applyBulkEdit(
      _EditField field, String value, List<StaffMember> allList) async {
    Navigator.pop(context);
    final selected =
    allList.where((s) => _selectedIds.contains(s.id)).toList();

    setState(() {
      _isSaving = true;
      for (final s in selected) _saveStatus[s.id!] = 'saving';
    });

    final provider = context.read<StaffProvider>();
    int saved = 0, failed = 0;

    for (final s in selected) {
      try {
        final updated = _applyField(s, field, value);
        await provider.updateStaff(s.id!, updated);
        if (mounted) {
          setState(() => _saveStatus[s.id!] = 'saved');
          saved++;
        }
      } catch (e) {
        if (mounted) {
          setState(() => _saveStatus[s.id!] = 'failed');
          failed++;
        }
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      provider.fetchTeachers();
      provider.fetchStaffOnly();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '$saved updated${failed > 0 ? ', $failed failed' : ''}'),
          backgroundColor: failed > 0 ? Colors.orange : _kGreen,
        ),
      );
    }
  }

  StaffMember _applyField(
      StaffMember s, _EditField field, String value) {
    return StaffMember(
      id: s.id,
      type: field == _EditField.type ? value : s.type,
      name: s.name,
      fatherOrHusbandName: s.fatherOrHusbandName,
      cnic: s.cnic,
      dob: s.dob,
      gender: field == _EditField.gender ? value : s.gender,
      maritalStatus: s.maritalStatus,
      bloodGroup: s.bloodGroup,
      religion: field == _EditField.religion ? value : s.religion,
      nationality:
      field == _EditField.nationality ? value : s.nationality,
      address: s.address,
      phone: s.phone,
      emergencyPhone: s.emergencyPhone,
      employmentType:
      field == _EditField.employmentType ? value : s.employmentType,
      salary: s.salary,
      reference: s.reference,
      note: s.note,
      designation:
      field == _EditField.designation ? value : s.designation,
      joiningDate: s.joiningDate,
      imageBase64: s.imageBase64,
      assignedClasses: s.assignedClasses,
      assignedSections: s.assignedSections ?? [],
      subjects: s.subjects,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();
    final filtered = _filteredList(provider);
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bulk Edit Staff / Teachers',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              Text(
                  '${_selectedIds.length} selected · ${filtered.length} visible',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
            ]),
        actions: [
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _openBulkEditSheet(filtered),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label:
                Text('Edit ${_selectedIds.length} Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: Column(children: [
        // Filter & search
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(children: [
            _filterChip('All', 'all'),
            const SizedBox(width: 8),
            _filterChip('Teachers', 'teacher'),
            const SizedBox(width: 8),
            _filterChip('Staff', 'staff'),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, designation…',
                    hintStyle: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search,
                        size: 17, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(color: _kPurple)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FC),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        if (_selectedIds.isNotEmpty)
          Container(
            color: _kPurpleLight,
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Icon(Icons.check_circle,
                  size: 16, color: _kPurple),
              const SizedBox(width: 8),
              Text('${_selectedIds.length} selected',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kPurple)),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    setState(() => _selectedIds.clear()),
                child: const Text('Deselect all',
                    style: TextStyle(fontSize: 12, color: _kPurple)),
              ),
            ]),
          ),
        Expanded(
          child: provider.loading
              ? const Center(
              child: CircularProgressIndicator(color: _kPurple))
              : filtered.isEmpty
              ? _buildEmpty()
              : Column(children: [
            InkWell(
              onTap: () => _selectAll(filtered),
              child: Container(
                color: const Color(0xFFF8F9FC),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(children: [
                  Checkbox(
                    value: _selectedIds.length ==
                        filtered.length &&
                        filtered.isNotEmpty,
                    tristate: _selectedIds.isNotEmpty &&
                        _selectedIds.length < filtered.length,
                    onChanged: (_) => _selectAll(filtered),
                    activeColor: _kPurple,
                  ),
                  Text(
                    _selectedIds.length == filtered.length
                        ? 'Deselect all'
                        : 'Select all (${filtered.length})',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700),
                  ),
                ]),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1),
                itemBuilder: (ctx, i) =>
                    _buildListItem(filtered[i], isDesktop),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildListItem(StaffMember s, bool isDesktop) {
    final isSelected = _selectedIds.contains(s.id);
    final status = _saveStatus[s.id];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isSelected
          ? _kPurpleLight.withOpacity(0.6)
          : status == 'saved'
          ? _kGreenBg.withOpacity(0.4)
          : status == 'failed'
          ? _kRedBg.withOpacity(0.4)
          : Colors.white,
      child: InkWell(
        onTap: () => _toggleSelect(s.id!),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          child: Row(children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelect(s.id!),
              activeColor: _kPurple,
            ),
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 20,
              backgroundColor: _kPurpleLight,
              child: Text(
                  s.name.isNotEmpty
                      ? s.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kPurple)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(width: 8),
                      _typeBadge(s.type),
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (s.designation?.isNotEmpty == true)
                          s.designation!,
                        s.phone,
                        s.employmentType
                      ].join(' · '),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ]),
            ),
            if (status == 'saving')
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kPurple))
            else if (status == 'saved')
              const Icon(Icons.check_circle,
                  size: 18, color: _kGreen)
            else if (status == 'failed')
                const Icon(Icons.error_outline, size: 18, color: _kRed)
              else if (isDesktop && isSelected)
                  const Icon(Icons.check, size: 18, color: _kPurple),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.people_outline,
          size: 48, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text(
        _searchQuery.isEmpty
            ? 'No records found.'
            : 'No results for "$_searchQuery"',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      ),
    ]),
  );

  Widget _filterChip(String label, String value) {
    final isActive = _typeFilter == value;
    return GestureDetector(
      onTap: () => setState(() {
        _typeFilter = value;
        _selectedIds.clear();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _kPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? _kPurple : Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : Colors.grey.shade700)),
      ),
    );
  }

  Widget _typeBadge(String type) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: type == 'teacher'
          ? _kPurpleLight
          : const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      type == 'teacher' ? 'Teacher' : 'Staff',
      style: TextStyle(
          fontSize: 10,
          color: type == 'teacher'
              ? _kPurple
              : const Color(0xFF2E7D32),
          fontWeight: FontWeight.w600),
    ),
  );
}

// ─── Bottom sheet for bulk edit ───────────────────────────────────────────────
class _BulkEditSheet extends StatefulWidget {
  final List<StaffMember> selected;
  final Future<void> Function(_EditField field, String value) onApply;

  const _BulkEditSheet(
      {required this.selected, required this.onApply});

  @override
  State<_BulkEditSheet> createState() => _BulkEditSheetState();
}

class _BulkEditSheetState extends State<_BulkEditSheet> {
  _EditField? _chosenField;
  String _chosenValue = '';
  final _textCtrl = TextEditingController();

  final _fieldOptions = _EditField.values;
  final Map<_EditField, List<String>> _dropdownOptions = {
    _EditField.employmentType: ['Regular', 'Contract', 'Daily'],
    _EditField.gender: ['Male', 'Female', 'Other'],
    _EditField.type: ['teacher', 'staff'],
  };

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  bool get _isDropdown =>
      _chosenField != null &&
          _dropdownOptions.containsKey(_chosenField);
  bool get _isText =>
      _chosenField != null &&
          !_dropdownOptions.containsKey(_chosenField);
  bool get _canApply =>
      _chosenField != null && _chosenValue.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _kPurpleLight,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.edit_outlined,
                      size: 18, color: _kPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bulk Edit',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text('Editing ${widget.selected.length} people',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ]),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ]),
            ),
            const Divider(height: 1),
            if (widget.selected.length <= 6)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.selected
                      .map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _kPurpleLight,
                        borderRadius:
                        BorderRadius.circular(20)),
                    child: Text(s.name,
                        style: const TextStyle(
                            fontSize: 12, color: _kPurple)),
                  ))
                      .toList(),
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Field choose karein:',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fieldOptions.map((f) {
                        final isSelected = _chosenField == f;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _chosenField = f;
                              _chosenValue = '';
                              _textCtrl.clear();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _kPurple
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isSelected
                                      ? _kPurple
                                      : Colors.grey.shade300),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(f.icon,
                                      size: 15,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(f.label,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87)),
                                ]),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_chosenField != null) ...[
                      const SizedBox(height: 20),
                      Text(
                          'New value for "${_chosenField!.label}":',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 10),
                      if (_isDropdown) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                          _dropdownOptions[_chosenField]!.map((opt) {
                            final isActive = _chosenValue == opt;
                            final displayOpt = opt == 'teacher'
                                ? 'Teacher'
                                : opt == 'staff'
                                ? 'Staff'
                                : opt;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _chosenValue = opt),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? _kPurple
                                      : Colors.grey.shade100,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  border: Border.all(
                                      color: isActive
                                          ? _kPurple
                                          : Colors.grey.shade300),
                                ),
                                child: Text(displayOpt,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isActive
                                            ? Colors.white
                                            : Colors.black87)),
                              ),
                            );
                          }).toList(),
                        ),
                      ] else if (_isText) ...[
                        TextField(
                          controller: _textCtrl,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText:
                            'Naya ${_chosenField!.label} enter karein...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: _kPurple, width: 1.5)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                          onChanged: (v) =>
                              setState(() => _chosenValue = v),
                        ),
                      ],
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _canApply
                            ? () => widget.onApply(
                            _chosenField!, _chosenValue)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPurple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          Colors.grey.shade200,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _canApply
                              ? 'Apply to ${widget.selected.length} people'
                              : 'Field & value select karein',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}







































