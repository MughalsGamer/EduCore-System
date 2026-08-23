
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/salary_adjustment_history.dart';
import '../../models/teacher.dart';
import '../../providers/salary_adjustment_history_provider.dart';

const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kGreen = Color(0xFF15803D);
const _kGreenBg = Color(0xFFDCFCE7);
const _kRed = Color(0xFFB91C1C);
const _kRedBg = Color(0xFFFEE2E2);

/// Full increment/decrement screen for a single staff/teacher, with the
/// complete history shown below the form. Opened from the Staff/Teacher
/// list (per-row button) or from the Salary Management screen.
class SalaryAdjustmentScreen extends StatefulWidget {
  final StaffMember staff;
  final bool showAppBar;

  const SalaryAdjustmentScreen({
    super.key,
    required this.staff,
    this.showAppBar = true,
  });

  @override
  State<SalaryAdjustmentScreen> createState() =>
      _SalaryAdjustmentScreenState();
}

class _SalaryAdjustmentScreenState extends State<SalaryAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  String _changeType = 'increment';
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isSaving = false;
  String? _deletingRecordId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context
        .read<SalaryHistoryProvider>()
        .loadHistoryForStaff(widget.staff.id!));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  double get _currentSalary => widget.staff.salary;

  double get _newSalary {
    final entered = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    return _changeType == 'increment'
        ? _currentSalary + entered
        : _currentSalary - entered;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final enteredAmount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final computedNewSalary = _newSalary;
    if (_changeType == 'decrement' && computedNewSalary < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New salary cannot be negative.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<SalaryHistoryProvider>().applySalaryChange(
        staff: widget.staff,
        changeType: _changeType,
        newSalary: computedNewSalary,
        reason: _reasonCtrl.text.trim(),
        date: _date,
      );
      if (mounted) {
        _amountCtrl.clear();
        _reasonCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_changeType == 'increment'
                ? 'Salary incremented successfully.'
                : 'Salary decremented successfully.'),
            backgroundColor: _kGreen,
          ),
        );
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

  Future<void> _confirmDelete(SalaryHistory record) async {
    final isLatest = context
        .read<SalaryHistoryProvider>()
        .currentStaffHistory
        .isNotEmpty &&
        context.read<SalaryHistoryProvider>().currentStaffHistory.first.id ==
            record.id;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete this entry?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          isLatest
              ? 'This is the most recent salary change. Deleting it will '
              'also revert the current salary back to Rs '
              '${_formatMoney(record.oldSalary)}.'
              : 'This will permanently remove this history entry.\n\n'
              'Note: this is not the latest entry, so the current salary '
              'will NOT be changed.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: _kRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deletingRecordId = record.id);
    try {
      final reverted =
      await context.read<SalaryHistoryProvider>().deleteHistoryRecord(
        staff: widget.staff,
        record: record,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reverted
                ? 'Entry deleted. Current salary reverted to Rs ${_formatMoney(record.oldSalary)}.'
                : 'Entry deleted.'),
            backgroundColor: _kGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _deletingRecordId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildFormCard(),
          const SizedBox(height: 16),
          _buildHistorySection(),
        ],
      ),
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Salary Adjustment',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      body: body,
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPurple, Color(0xFF6C63D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Text(
              widget.staff.name.isNotEmpty
                  ? widget.staff.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.staff.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(
                  widget.staff.designation?.isNotEmpty == true
                      ? widget.staff.designation!
                      : (widget.staff.type == 'teacher'
                      ? 'Teacher'
                      : 'Staff'),
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Current Salary',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
              const SizedBox(height: 2),
              Text('Rs ${_formatMoney(widget.staff.salary)}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Adjustment',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            // Increment / Decrement toggle
            Row(
              children: [
                Expanded(
                  child: _typeToggleButton(
                    label: 'Increment',
                    icon: Icons.trending_up_rounded,
                    color: _kGreen,
                    bgColor: _kGreenBg,
                    selected: _changeType == 'increment',
                    onTap: () => setState(() => _changeType = 'increment'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _typeToggleButton(
                    label: 'Decrement',
                    icon: Icons.trending_down_rounded,
                    color: _kRed,
                    bgColor: _kRedBg,
                    selected: _changeType == 'decrement',
                    onTap: () => setState(() => _changeType = 'decrement'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: _inputDeco(
                _changeType == 'increment'
                    ? 'Increment Amount *'
                    : 'Decrement Amount *',
                prefixText: 'Rs  ',
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: _date),
              decoration: _inputDeco('Effective Date *').copyWith(
                suffixIcon: const Icon(Icons.calendar_today,
                    size: 18, color: _kPurple),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonCtrl,
              maxLines: 2,
              decoration: _inputDeco('Reason *',
                  hint: 'e.g. Annual increment, Performance bonus...'),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            // Preview row: old -> new
            if (_amountCtrl.text.trim().isNotEmpty)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _kPurpleLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Old Salary',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        Text('Rs ${_formatMoney(_currentSalary)}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 18, color: _kPurple),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('New Salary',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        Text(
                          'Rs ${_formatMoney(_newSalary)}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _changeType == 'increment'
                                  ? _kGreen
                                  : _kRed),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Text(
                  _changeType == 'increment'
                      ? 'Apply Increment'
                      : 'Apply Decrement',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeToggleButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? bgColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: selected ? color : Colors.grey.shade500),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Consumer<SalaryHistoryProvider>(
      builder: (context, provider, _) {
        final history = provider.currentStaffHistory;
        return Container(
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
                  const Icon(Icons.history_rounded, size: 18, color: _kPurple),
                  const SizedBox(width: 8),
                  const Text('Complete History',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (provider.loading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kPurple),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (!provider.loading && history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('No salary changes recorded yet.',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                )
              else
                ...history.asMap().entries.map(
                      (entry) => _historyTile(
                    entry.value,
                    isLatest: entry.key == 0,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _historyTile(SalaryHistory h, {required bool isLatest}) {
    final isIncrement = h.isIncrement;
    final color = isIncrement ? _kGreen : _kRed;
    final bgColor = isIncrement ? _kGreenBg : _kRedBg;
    final icon = isIncrement
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final isDeleting = _deletingRecordId == h.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIX: Row → Wrap so type/amount/LATEST badge/date wrap to a
                // second line instead of overflowing on narrow screens.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      isIncrement ? 'Increment' : 'Decrement',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color),
                    ),
                    Text(
                      '${isIncrement ? '+' : '-'} Rs ${_formatMoney(h.amount)}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color),
                    ),
                    if (isLatest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kPurpleLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'LATEST',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _kPurple),
                        ),
                      ),
                    Text(h.date,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text('Rs ${_formatMoney(h.oldSalary)}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 12, color: Colors.grey),
                    ),
                    Flexible(
                      child: Text('Rs ${_formatMoney(h.newSalary)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                if (h.reason.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    h.reason,
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          isDeleting
              ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _kRed))
              : InkWell(
            onTap: () => _confirmDelete(h),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.delete_outline_rounded,
                  size: 19, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
  InputDecoration _inputDeco(String label,
      {String? hint, String? prefixText}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
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
    );
  }
}

String _formatMoney(double value) {
  return NumberFormat('#,##0').format(value);
}