import 'dart:convert'; // ✅ Fix: adds base64Decode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/admission_provider.dart';

class AddAdmissionScreen extends StatefulWidget {
  const AddAdmissionScreen({super.key});

  @override
  State<AddAdmissionScreen> createState() => _AddAdmissionScreenState();
}

class _AddAdmissionScreenState extends State<AddAdmissionScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdmissionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Admission Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Mode toggle ---
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'family', label: Text('Family Wise')),
                  ButtonSegment(value: 'individual', label: Text('Individual')),
                ],
                selected: {provider.admissionType},
                onSelectionChanged: (val) =>
                    provider.setAdmissionType(val.first),
              ),
              const SizedBox(height: 16),

              // --- Admission Details (common) ---
              _buildAdmissionDetails(provider),
              const Divider(height: 32),

              // --- Family fields (only family) ---
              if (provider.admissionType == 'family') ...[
                _buildFamilyFields(provider),
                const Divider(height: 32),
              ],

              // --- Parent Information ---
              _buildParentSection(provider),
              const Divider(height: 32),

              // --- Children ---
              _buildChildrenSection(provider),
              const SizedBox(height: 24),

              // --- Submit ---
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await provider.submit();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Admission added!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                  icon: provider.isLoading
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: const Text('Submit Admission'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdmissionDetails(AdmissionProvider p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admission Details',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: p.admissionDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  p.admissionDate = date;
                  // ✅ Fix: use setState instead of casting context as Element
                  setState(() {});
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Admission Date',
                    border: OutlineInputBorder()),
                child: Text(p.admissionDate != null
                    ? DateFormat('dd-MM-yyyy').format(p.admissionDate!)
                    : 'Select Date'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.previousClass,
              decoration: const InputDecoration(
                  labelText: 'Previous Class (Optional)',
                  border: OutlineInputBorder()),
              onChanged: (v) => p.previousClass = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.previousSchool,
              decoration: const InputDecoration(
                  labelText: 'Previous School (Optional)',
                  border: OutlineInputBorder()),
              onChanged: (v) => p.previousSchool = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyFields(AdmissionProvider p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Family System',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: p.familyName,
              decoration: const InputDecoration(
                  labelText: 'Family Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              onChanged: (v) => p.familyName = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentSection(AdmissionProvider p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parent Information',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: p.fatherName,
              decoration: const InputDecoration(
                  labelText: 'Father Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              onChanged: (v) => p.fatherName = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.fatherCNIC,
              decoration: const InputDecoration(
                  labelText: 'Father CNIC', border: OutlineInputBorder()),
              onChanged: (v) => p.fatherCNIC = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.occupation,
              decoration: const InputDecoration(
                  labelText: 'Occupation', border: OutlineInputBorder()),
              onChanged: (v) => p.occupation = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.phone,
              decoration: const InputDecoration(
                  labelText: 'Phone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
              onChanged: (v) => p.phone = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.motherName,
              decoration: const InputDecoration(
                  labelText: 'Mother Name', border: OutlineInputBorder()),
              onChanged: (v) => p.motherName = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.motherCNIC,
              decoration: const InputDecoration(
                  labelText: 'Mother CNIC', border: OutlineInputBorder()),
              onChanged: (v) => p.motherCNIC = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.address,
              decoration: const InputDecoration(
                  labelText: 'Address', border: OutlineInputBorder()),
              onChanged: (v) => p.address = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: p.city,
              decoration: const InputDecoration(
                  labelText: 'City', border: OutlineInputBorder()),
              onChanged: (v) => p.city = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenSection(AdmissionProvider p) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Student Information',
                style: Theme.of(context).textTheme.titleMedium),
            if (p.admissionType == 'family')
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Child'),
                onPressed: p.addChild,
              ),
          ],
        ),
        ...p.children.asMap().entries.map((entry) {
          final idx = entry.key;
          final child = entry.value;
          return _buildSingleChildForm(p, idx, child);
        }),
      ],
    );
  }

  Widget _buildSingleChildForm(
      AdmissionProvider p, int index, ChildFormData child) { // ✅ Fix: ChildFormData (public)
    final image = p.getChildImage(index); // ✅ Fix: use public getter instead of p._childImages[index]

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Child ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (p.admissionType == 'family' && p.children.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => p.removeChild(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Student Picture
            Center(
              child: GestureDetector(
                onTap: () => p.pickImage(index),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  // ✅ Fix: resolved ImageProvider type mismatch with explicit typing
                  backgroundImage: image != null
                      ? FileImage(image) as ImageProvider<Object>
                      : (child.studentPictureBase64 != null
                      ? MemoryImage(
                    base64Decode(child.studentPictureBase64!), // ✅ Fix: base64Decode now available via dart:convert import
                  ) as ImageProvider<Object>
                      : null),
                  child: image == null && child.studentPictureBase64 == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: child.rollNo,
              decoration: const InputDecoration(
                  labelText: 'Roll No', border: OutlineInputBorder()),
              onChanged: (v) => child.rollNo = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: child.studentName,
              decoration: const InputDecoration(
                  labelText: 'Student Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              onChanged: (v) => child.studentName = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: child.bFormCNIC,
              decoration: const InputDecoration(
                  labelText: 'B-Form / CNIC No', border: OutlineInputBorder()),
              onChanged: (v) => child.bFormCNIC = v,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: child.dob ?? DateTime(2010),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  child.dob = date;
                  setState(() {}); // ✅ Fix: use setState instead of casting context as Element
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Date of Birth', border: OutlineInputBorder()),
                child: Text(child.dob != null
                    ? DateFormat('dd-MM-yyyy').format(child.dob!)
                    : 'Select DOB'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: child.studentClass,
              decoration: const InputDecoration(
                  labelText: 'Class', border: OutlineInputBorder()),
              onChanged: (v) => child.studentClass = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: child.section,
              decoration: const InputDecoration(
                  labelText: 'Section (Optional)', border: OutlineInputBorder()),
              onChanged: (v) => child.section = v,
            ),
            const SizedBox(height: 16),
            Text('Fee Schedule',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildFeeField('Monthly Fee', child.monthlyFee,
                    (v) => child.monthlyFee = double.tryParse(v) ?? 0),
            _buildFeeField('Books Charges', child.booksCharges,
                    (v) => child.booksCharges = double.tryParse(v) ?? 0),
            _buildFeeField('Uniform Charges', child.uniformCharges,
                    (v) => child.uniformCharges = double.tryParse(v) ?? 0),
            _buildFeeField('Stationery Charges', child.stationeryCharges,
                    (v) => child.stationeryCharges = double.tryParse(v) ?? 0),
            _buildFeeField('Transport Fee', child.transportFee,
                    (v) => child.transportFee = double.tryParse(v) ?? 0),
            _buildFeeField('Security Fee', child.securityFee,
                    (v) => child.securityFee = double.tryParse(v) ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeField(
      String label, double initial, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: initial == 0 ? '' : initial.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }
}