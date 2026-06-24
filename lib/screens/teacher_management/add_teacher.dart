
import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart' as web;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/class_model.dart';
import '../../models/teacher.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../services/firestore_service.dart';

// ───── Subject multi‑select (unchanged) ─────
class _SubjectMultiSelect extends StatelessWidget {
  final List<String> selectedSubjects;
  final ValueChanged<List<String>> onChanged;
  const _SubjectMultiSelect({required this.selectedSubjects, required this.onChanged});
  static const _purple = Color(0xFF534AB7);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MuddulProvider>();
    final allSubjects = provider.mudduls.map((m) => m.subjectName).toSet().toList()..sort();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (allSubjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
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
                'No subjects found. Add subjects first.',
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: allSubjects.map((subject) {
        final isSelected = selectedSubjects.contains(subject);
        return GestureDetector(
          onTap: () {
            final updated = List<String>.from(selectedSubjects);
            if (isSelected) updated.remove(subject);
            else updated.add(subject);
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? _purple : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _purple : Colors.grey.shade300,
                width: isSelected ? 1.5 : 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                ],
                Text(
                  subject,
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
    );
  }
}

// ───── Main Add/Edit Screen ─────
class AddEditStaffScreen extends StatefulWidget {
  final StaffMember? existingStaff;
  const AddEditStaffScreen({super.key, this.existingStaff});

  @override
  State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends State<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = StaffFirestoreService();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _fatherOrHusbandCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _religionCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // Selections
  String _type = 'staff';
  String _gender = 'Male';
  String _maritalStatus = 'Single';
  String? _bloodGroup;
  String _employmentType = 'Regular';
  String _dob = '';
  String? _assignedClass;
  List<String> _subjects = [];

  // Image: store as bytes (cross‑platform)
  Uint8List? _imageBytes;
  String? _existingImageBase64;
  bool _isSaving = false;

  final _typeOptions = ['teacher', 'staff'];
  final _genderOptions = ['Male', 'Female', 'Other'];
  final _maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  final _bloodOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final _employmentOptions = ['Contract', 'Regular', 'Daily'];

  @override
  void initState() {
    super.initState();
    final s = widget.existingStaff;
    if (s != null) {
      _type = s.type;
      _nameCtrl.text = s.name;
      _fatherOrHusbandCtrl.text = s.fatherOrHusbandName;
      _cnicCtrl.text = s.cnic;
      _dob = s.dob;
      _gender = s.gender;
      _maritalStatus = s.maritalStatus;
      _bloodGroup = s.bloodGroup;
      _religionCtrl.text = s.religion;
      _nationalityCtrl.text = s.nationality;
      _addressCtrl.text = s.address;
      _phoneCtrl.text = s.phone;
      _emergencyPhoneCtrl.text = s.emergencyPhone;
      _employmentType = s.employmentType;
      _salaryCtrl.text = s.salary.toString();
      _referenceCtrl.text = s.reference ?? '';
      _noteCtrl.text = s.note ?? '';
      _existingImageBase64 = s.imageBase64;
      _assignedClass = s.assignedClass;
      _subjects = List<String>.from(s.subjects);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fatherOrHusbandCtrl.dispose();
    _cnicCtrl.dispose();
    _religionCtrl.dispose();
    _nationalityCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _salaryCtrl.dispose();
    _referenceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ───── Image picker (works on mobile & web) ─────
  Future<void> _pickImage() async {
    if (kIsWeb) {
      // ✅ Correct static method call for web
      final bytes = await web.ImagePickerWeb.getImageAsBytes();   // ✅ Correct method
      if (bytes != null) {
        setState(() {
          _imageBytes = bytes;
          _existingImageBase64 = null;
        });
      }
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _existingImageBase64 = null;
        });
      }
    }
  }

  // ───── Date picker ─────
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initialDate = _dob.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_dob)
        : DateTime(now.year - 20, 1, 1);
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

  // ───── Save ─────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    String? base64Image = _existingImageBase64;
    if (_imageBytes != null) {
      base64Image = await _service.compressAndEncodeBytes(_imageBytes!);
    }

    final staff = StaffMember(
      id: widget.existingStaff?.id,
      type: _type,
      name: _nameCtrl.text.trim(),
      fatherOrHusbandName: _fatherOrHusbandCtrl.text.trim(),
      cnic: _cnicCtrl.text.trim(),
      dob: _dob,
      gender: _gender,
      maritalStatus: _maritalStatus,
      bloodGroup: _bloodGroup,
      religion: _religionCtrl.text.trim(),
      nationality: _nationalityCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      emergencyPhone: _emergencyPhoneCtrl.text.trim(),
      employmentType: _employmentType,
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
      reference: _referenceCtrl.text.trim().isEmpty ? null : _referenceCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      imageBase64: base64Image,
      assignedClass: _assignedClass,
      subjects: _subjects,
    );

    final provider = context.read<StaffProvider>();
    try {
      if (widget.existingStaff == null) {
        await provider.addStaff(staff);
      } else {
        await provider.updateStaff(widget.existingStaff!.id!, staff);
      }
      if (mounted) Navigator.pop(context, true);
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

  // ───── UI helpers ─────
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, child) {
        final classes = classProvider.classes;
        return DropdownButtonFormField<String>(
          value: _assignedClass,
          isExpanded: true,
          hint: const Text('Select Class (optional)'),
          items: classes.map((cls) {
            return DropdownMenuItem<String>(
              value: cls.id,
              child: Text(cls.name, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) => setState(() => _assignedClass = val),
          decoration: const InputDecoration(
            labelText: 'Assigned Class',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.class_),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingStaff != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? 'Edit ${_type == 'teacher' ? 'Teacher' : 'Staff'}'
            : 'Add Staff / Teacher'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Image picker ──
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : (_existingImageBase64 != null
                      ? MemoryImage(base64Decode(_existingImageBase64!))
                      : null),
                  child: (_imageBytes == null && _existingImageBase64 == null)
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Pick Photo (Optional)'),
              ),
              const SizedBox(height: 10),

              // ── Staff/Teacher toggle ──
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'staff', label: Text('Staff')),
                  ButtonSegment(value: 'teacher', label: Text('Teacher')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 12),

              // ── Assigned Class ──
              _buildClassDropdown(),
              const SizedBox(height: 12),

              // ── Personal Information ──
              _buildSectionCard('Personal Information', [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fatherOrHusbandCtrl,
                  decoration: InputDecoration(
                    labelText: _maritalStatus == 'Married' ? 'Husband Name *' : 'Father Name *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cnicCtrl,
                  decoration: const InputDecoration(
                    labelText: 'CNIC * (e.g., 12345-1234567-1)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 15,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
                    if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(text: _dob),
                  onTap: _pickDob,
                  validator: (_) => _dob.isEmpty ? 'Please select date of birth' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => _gender = v!),
                  decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _maritalStatus,
                  items: _maritalOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => _maritalStatus = v!),
                  decoration: const InputDecoration(labelText: 'Marital Status *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: _bloodGroup,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Select (Optional)')),
                    ..._bloodOptions.map((b) => DropdownMenuItem(value: b, child: Text(b))),
                  ],
                  onChanged: (v) => setState(() => _bloodGroup = v),
                  decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _religionCtrl,
                  decoration: const InputDecoration(labelText: 'Religion *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nationalityCtrl,
                  decoration: const InputDecoration(labelText: 'Nationality *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ]),

              // ── Contact Information ──
              _buildSectionCard('Contact Information', [
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Address *', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone No *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emergencyPhoneCtrl,
                  decoration: const InputDecoration(labelText: 'Emergency No *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ]),

              // ── Job Details ──
              _buildSectionCard('Job Details', [
                DropdownButtonFormField<String>(
                  value: _employmentType,
                  items: _employmentOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _employmentType = v!),
                  decoration: const InputDecoration(labelText: 'Employment Type *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryCtrl,
                  decoration: const InputDecoration(labelText: 'Salary *', border: OutlineInputBorder(), prefixText: '\$ '),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ]),

              // ── Assigned Subjects ──
              _buildSectionCard('Assigned Subjects (Optional)', [
                Text('Tap subjects to assign them to this person.',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                _SubjectMultiSelect(
                  selectedSubjects: _subjects,
                  onChanged: (updated) => setState(() => _subjects = updated),
                ),
              ]),

              // ── Additional Info ──
              _buildSectionCard('Additional Info (Optional)', [
                TextFormField(
                  controller: _referenceCtrl,
                  decoration: const InputDecoration(labelText: 'Reference', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder()),
                ),
              ]),

              // ── Save button ──
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEdit ? 'Update' : 'Save'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}