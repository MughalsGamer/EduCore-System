import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

const _purple = Color(0xFF534AB7);

class AddEditEventScreen extends StatefulWidget {
  final bool showAppBar;
  final EventModel? existingEvent; // null = add mode, otherwise edit mode
  final VoidCallback? onSaved;

  const AddEditEventScreen({
    super.key,
    this.showAppBar = true,
    this.existingEvent,
    this.onSaved,
  });

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  DateTime _selectedDate = DateTime.now();
  bool _isActive = true;
  bool _isSaving = false;

  bool get _isEditMode => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _selectedDate = e?.date ?? DateTime.now();
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
            colorScheme: const ColorScheme.light(primary: _purple),
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<EventProvider>();

    try {
      if (_isEditMode) {
        final updated = widget.existingEvent!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          date: _selectedDate,
          isActive: _isActive,
        );
        await provider.updateEvent(updated);
      } else {
        await provider.addEvent(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          date: _selectedDate,
        );
      }

      if (!mounted) return;

      if (_isEditMode) {
        // Edit ke baad panel band, wapis list dikhao
        widget.onSaved?.call();
      } else {
        // Add mode: form clear kardo, taake multi-add asaan ho (panel khula rahe)
        _titleCtrl.clear();
        _descCtrl.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _isActive = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event add ho gaya. Agla event add kar sakte hain.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? 'Edit Event' : 'Add New Event',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isEditMode
                  ? 'Event ki details update karein'
                  : 'Naya event add karein — save karne ke baad form dobara khali ho jayega taake agla event add kar saken',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            const Text('Title',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              decoration: _inputDecoration('e.g. Annual Sports Day'),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title required hai' : null,
            ),
            const SizedBox(height: 16),

            const Text('Description',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: _inputDecoration('Event ki details likhein...'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Description required hai'
                  : null,
            ),
            const SizedBox(height: 16),

            const Text('Date',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: _purple),
                    const SizedBox(width: 10),
                    Text(_formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 13)),
                    const Spacer(),
                    if (_selectedDate.isBefore(
                        DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day)))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Past date',
                            style: TextStyle(
                                fontSize: 10, color: Colors.red.shade700)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_isEditMode)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeColor: _purple,
                title: const Text('Active',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                subtitle: const Text(
                  'Date guzarne ke baad ye khud disable ho jayega',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : Text(_isEditMode ? 'Update Event' : 'Save Event'),
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.showAppBar) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Event' : 'Add Event'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: content,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        borderSide: const BorderSide(color: _purple, width: 1.5),
      ),
    );
  }
}