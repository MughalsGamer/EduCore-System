import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/employee_trasaction_model.dart';
import '../../models/teacher.dart';
import '../../providers/employee_transaction_provider.dart';
import '../../providers/teacher_provider.dart';


// ─────────────────────────────────────────────
//  Constants (matches EduCore brand)
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleMid = Color(0xFF6C63D4);

const _kCategories = <String>[
  'Advance',
  'Loan',
  'Expense',
  'Fine',
  'Reimbursement',
  'Others',
];

const _kCategoryIcons = <String, IconData>{
  'Advance': Icons.payments_outlined,
  'Loan': Icons.account_balance_outlined,
  'Expense': Icons.receipt_long_outlined,
  'Fine': Icons.gavel_outlined,
  'Reimbursement': Icons.assignment_return_outlined,
  'Others': Icons.more_horiz_rounded,
};

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class AddStaffTransactionScreen extends StatefulWidget {
  final bool showAppBar;
  final VoidCallback? onSaved;

  const AddStaffTransactionScreen({
    super.key,
    this.showAppBar = true,
    this.onSaved,
  });

  @override
  State<AddStaffTransactionScreen> createState() =>
      _AddStaffTransactionScreenState();
}

class _AddStaffTransactionScreenState
    extends State<AddStaffTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _customCategoryCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  String _employeeType = 'teacher'; // 'teacher' or 'staff'
  StaffMember? _selectedEmployee;
  DateTime _selectedDate = DateTime.now();
  String _category = 'Advance';
  bool _isSaving = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    // Make sure staff/teacher lists are loaded so the search box has data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final staffProvider = context.read<StaffProvider>();
      if (staffProvider.teachers.isEmpty) staffProvider.fetchTeachers();
      if (staffProvider.staffOnly.isEmpty) staffProvider.fetchStaffOnly();
    });
    _searchFocus.addListener(() {
      setState(() => _showSuggestions = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _customCategoryCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<StaffMember> get _sourceList {
    final staffProvider = context.watch<StaffProvider>();
    return _employeeType == 'teacher'
        ? staffProvider.teachers
        : staffProvider.staffOnly;
  }

  List<StaffMember> get _filteredEmployees {
    final query = _searchCtrl.text.trim().toLowerCase();
    final list = _sourceList;
    if (query.isEmpty) return list;
    return list
        .where((e) => e.name.toLowerCase().contains(query))
        .toList();
  }

  void _switchType(String type) {
    setState(() {
      _employeeType = type;
      _selectedEmployee = null;
      _searchCtrl.clear();
    });
  }

  void _pickEmployee(StaffMember member) {
    setState(() {
      _selectedEmployee = member;
      _searchCtrl.text = member.name;
      _showSuggestions = false;
    });
    _searchFocus.unfocus();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _kPurple),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an employee first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (_category == 'Others' && _customCategoryCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify the "Others" category name.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final txn = StaffTransaction(
      employeeId: _selectedEmployee!.id!,
      employeeName: _selectedEmployee!.name,
      employeeType: _employeeType,
      date: _selectedDate,
      category: _category,
      customCategory: _category == 'Others'
          ? _customCategoryCtrl.text.trim()
          : null,
      amount: double.tryParse(_amountCtrl.text.trim()) ?? 0,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    try {
      await context.read<StaffTransactionProvider>().addTransaction(txn);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${txn.displayCategory} of Rs ${txn.amount.toStringAsFixed(0)} saved for ${txn.employeeName}.'),
            backgroundColor: Colors.green,
          ),
        );
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          _resetForm();
        }
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

  void _resetForm() {
    setState(() {
      _selectedEmployee = null;
      _searchCtrl.clear();
      _amountCtrl.clear();
      _noteCtrl.clear();
      _customCategoryCtrl.clear();
      _category = 'Advance';
      _selectedDate = DateTime.now();
    });
  }

  String get _initials {
    final name = _selectedEmployee?.name.trim() ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  // ─────────────────────────────────────────────
  //  Shared: Type toggle
  // ─────────────────────────────────────────────
  Widget _typeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['teacher', 'staff'].map((t) {
          final selected = _employeeType == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchType(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? _kPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      t == 'teacher'
                          ? Icons.school_rounded
                          : Icons.badge_rounded,
                      size: 16,
                      color: selected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t == 'teacher' ? 'Teacher' : 'Staff',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Shared: Employee search field + suggestions
  // ─────────────────────────────────────────────
  Widget _employeeSearchField() {
    final staffProvider = context.watch<StaffProvider>();
    final isLoading = staffProvider.loading && _sourceList.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          onChanged: (v) {
            setState(() {
              _showSuggestions = true;
              if (_selectedEmployee != null && v != _selectedEmployee!.name) {
                _selectedEmployee = null;
              }
            });
          },
          decoration: InputDecoration(
            labelText:
            'Search ${_employeeType == 'teacher' ? 'Teacher' : 'Staff'} Name *',
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
          validator: (_) =>
          _selectedEmployee == null ? 'Please select an employee' : null,
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
              child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
                : _filteredEmployees.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'No ${_employeeType == 'teacher' ? 'teacher' : 'staff'} found.',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500),
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
                      e.name.isNotEmpty
                          ? e.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kPurple),
                    ),
                  ),
                  title: Text(e.name,
                      style: const TextStyle(fontSize: 13)),
                  subtitle: (e.designation ?? '').isNotEmpty
                      ? Text(e.designation!,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500))
                      : null,
                  onTap: () => _pickEmployee(e),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Shared: Date field
  // ─────────────────────────────────────────────
  Widget _dateField() {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
          text: DateFormat('dd MMM, yyyy').format(_selectedDate)),
      decoration: InputDecoration(
        labelText: 'Date *',
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon: const Icon(Icons.calendar_today, size: 18),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: _kPurple),
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
      onTap: _pickDate,
    );
  }

  // ─────────────────────────────────────────────
  //  Shared: Category chips
  // ─────────────────────────────────────────────
  Widget _categorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kCategories.map((cat) {
            final isSelected = _category == cat;
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                    Icon(
                      _kCategoryIcons[cat],
                      size: 15,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_category == 'Others') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _customCategoryCtrl,
            decoration: InputDecoration(
              labelText: 'Specify Category Name *',
              hintText: 'e.g. Medical, Bonus, Gift…',
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
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Shared: Amount field
  // ─────────────────────────────────────────────
  Widget _amountField() {
    return TextFormField(
      controller: _amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Amount *',
        prefixText: 'Rs  ',
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
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        final val = double.tryParse(v.trim());
        if (val == null || val <= 0) return 'Enter a valid amount';
        return null;
      },
    );
  }

  // ─────────────────────────────────────────────
  //  Shared: Note field
  // ─────────────────────────────────────────────
  Widget _noteField() {
    return TextFormField(
      controller: _noteCtrl,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Note (Optional)',
        hintText: 'Any additional details…',
        alignLabelWithHint: true,
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
    );
  }

  Widget _saveButton({double? width, double height = 50}) {
    final saving = context.watch<StaffTransactionProvider>().saving;
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        onPressed: (_isSaving || saving) ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: (_isSaving || saving)
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(
          (_isSaving || saving) ? 'Saving…' : 'Save Transaction',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Selected employee preview card
  // ─────────────────────────────────────────────
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
                  '${_employeeType == 'teacher' ? 'Teacher' : 'Staff'}'
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

  // ─────────────────────────────────────────────
  //  MOBILE LAYOUT
  // ─────────────────────────────────────────────
  Widget _buildMobileLayout() {
    final body = Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'New Advance / Loan / Expense Entry',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard([
              Text('Employee',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              _typeToggle(),
              const SizedBox(height: 12),
              _employeeSearchField(),
              _selectedEmployeeCard(),
            ]),
            const SizedBox(height: 12),
            _sectionCard([
              _dateField(),
            ]),
            const SizedBox(height: 12),
            _sectionCard([
              _categorySelector(),
            ]),
            const SizedBox(height: 12),
            _sectionCard([
              _amountField(),
              const SizedBox(height: 14),
              _noteField(),
            ]),
            const SizedBox(height: 20),
            _saveButton(width: double.infinity),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add Transaction',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      body: body,
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      width: double.infinity,
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
        children: children,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DESKTOP LAYOUT
  // ─────────────────────────────────────────────
  Widget _buildDesktopLayout() {
    final content = Form(
      key: _formKey,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _kPurpleLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: _kPurple, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Advance / Loan / Expense Entry',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Record a financial transaction against a teacher or staff member',
                            style:
                            TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _desktopSection('Select Employee', Icons.person_search_outlined, [
                  SizedBox(width: 260, child: _typeToggle()),
                  const SizedBox(height: 14),
                  _employeeSearchField(),
                  _selectedEmployeeCard(),
                ]),
                _desktopSection(
                    'Transaction Details', Icons.receipt_long_outlined, [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _dateField()),
                      const SizedBox(width: 14),
                      Expanded(child: _amountField()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _categorySelector(),
                ]),
                _desktopSection('Additional Info', Icons.info_outline, [
                  _noteField(),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (widget.onSaved != null) {
                          _resetForm();
                        } else {
                          Navigator.maybePop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _kPurple),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reset',
                          style: TextStyle(color: _kPurple)),
                    ),
                    const SizedBox(width: 12),
                    _saveButton(width: 200, height: 48),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );

    if (!widget.showAppBar) {
      return Container(color: const Color(0xFFF0F2F8), child: content);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: content,
    );
  }

  Widget _desktopSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _kPurpleLight,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: _kPurple),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _kPurple),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }
}