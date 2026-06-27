// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/admission_model.dart';
// import '../../models/class_model.dart';
// import '../../providers/admission_provider.dart';
// import '../../providers/class_provider.dart';
//
// // ─────────────────────────────────────────────
// //  Helper: per-student UI state
// // ─────────────────────────────────────────────
// class _StudentFormState {
//   AdmissionStudent data;
//
//   // Fee controllers (so user can edit)
//   final TextEditingController annualFeeCtrl;
//   final TextEditingController registrationFeeCtrl;
//   final TextEditingController monthlyFeeCtrl;
//   final TextEditingController nameCtrl;
//   final TextEditingController rollNoCtrl;
//   final TextEditingController cnicCtrl;
//   final TextEditingController studentIdCtrl;
//
//   bool loadingFees = false;
//
//   _StudentFormState({AdmissionStudent? student})
//       : data = student ?? AdmissionStudent(),
//         annualFeeCtrl =
//         TextEditingController(text: student?.annualFee?.toStringAsFixed(0) ?? ''),
//         registrationFeeCtrl = TextEditingController(
//             text: student?.registrationFee?.toStringAsFixed(0) ?? ''),
//         monthlyFeeCtrl =
//         TextEditingController(text: student?.monthlyFee?.toStringAsFixed(0) ?? ''),
//         nameCtrl = TextEditingController(text: student?.name ?? ''),
//         rollNoCtrl = TextEditingController(text: student?.classRollNo ?? ''),
//         cnicCtrl = TextEditingController(text: student?.bFormCnic ?? ''),
//         studentIdCtrl = TextEditingController(text: student?.studentId ?? '');
//
//   void dispose() {
//     annualFeeCtrl.dispose();
//     registrationFeeCtrl.dispose();
//     monthlyFeeCtrl.dispose();
//     nameCtrl.dispose();
//     rollNoCtrl.dispose();
//     cnicCtrl.dispose();
//     studentIdCtrl.dispose();
//   }
//
//   void syncFees() {
//     data.annualFee = double.tryParse(annualFeeCtrl.text);
//     data.registrationFee = double.tryParse(registrationFeeCtrl.text);
//     data.monthlyFee = double.tryParse(monthlyFeeCtrl.text);
//     data.classRollNo = rollNoCtrl.text.trim().isEmpty ? null : rollNoCtrl.text.trim();
//     data.bFormCnic = cnicCtrl.text.trim().isEmpty ? null : cnicCtrl.text.trim();
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Main Admission Form Screen
// // ─────────────────────────────────────────────
// class AdmissionFormScreen extends StatefulWidget {
//   final AdmissionModel? existing;
//   const AdmissionFormScreen({super.key, this.existing});
//
//   @override
//   State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
// }
//
// class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   late AdmissionType _type;
//   String _admissionId = '';
//   DateTime _admissionDate = DateTime.now();
//   bool _generatingId = false;
//   bool _isSaving = false;
//
//   // Previous school
//   final _prevSchoolCtrl = TextEditingController();
//   final _prevClassCtrl = TextEditingController();
//   final _prevMarksCtrl = TextEditingController();
//
//   // Family
//   final _familyNameCtrl = TextEditingController();
//   String _familyId = '';
//   bool _generatingFamilyId = false;
//
//   // Parents
//   final _fatherNameCtrl = TextEditingController();
//   final _fatherOccCtrl = TextEditingController();
//   final _fatherCnicCtrl = TextEditingController();
//   final _fatherPhoneCtrl = TextEditingController();
//   final _motherNameCtrl = TextEditingController();
//   final _motherCnicCtrl = TextEditingController();
//   final _motherPhoneCtrl = TextEditingController();
//   final _casteCtrl = TextEditingController();
//   final _addressCtrl = TextEditingController();
//
//   // Students
//   final List<_StudentFormState> _studentForms = [];
//
//   static const _purple = Color(0xFF534AB7);
//
//   @override
//   void initState() {
//     super.initState();
//     final ex = widget.existing;
//     _type = ex?.type ?? AdmissionType.preAdmission;
//     _admissionId = ex?.inquiryOrRegId ?? '';
//     _admissionDate = ex?.admissionDate ?? DateTime.now();
//
//     _prevSchoolCtrl.text = ex?.previousSchoolName ?? '';
//     _prevClassCtrl.text = ex?.previousClassName ?? '';
//     _prevMarksCtrl.text = ex?.previousClassMarks ?? '';
//
//     _familyNameCtrl.text = ex?.familyName ?? '';
//     _familyId = ex?.familyId ?? '';
//
//     _fatherNameCtrl.text = ex?.fatherName ?? '';
//     _fatherOccCtrl.text = ex?.fatherOccupation ?? '';
//     _fatherCnicCtrl.text = ex?.fatherCnic ?? '';
//     _fatherPhoneCtrl.text = ex?.fatherPhone ?? '';
//     _motherNameCtrl.text = ex?.motherName ?? '';
//     _motherCnicCtrl.text = ex?.motherCnic ?? '';
//     _motherPhoneCtrl.text = ex?.motherPhone ?? '';
//     _casteCtrl.text = ex?.caste ?? '';
//     _addressCtrl.text = ex?.address ?? '';
//
//     final students = ex?.students ?? [AdmissionStudent()];
//     for (final s in students) {
//       _studentForms.add(_StudentFormState(student: s));
//     }
//
//     // Auto-generate ID for new admission
//     if (ex == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) => _generateAdmissionId());
//     }
//   }
//
//   @override
//   void dispose() {
//     _prevSchoolCtrl.dispose();
//     _prevClassCtrl.dispose();
//     _prevMarksCtrl.dispose();
//     _familyNameCtrl.dispose();
//     _fatherNameCtrl.dispose();
//     _fatherOccCtrl.dispose();
//     _fatherCnicCtrl.dispose();
//     _fatherPhoneCtrl.dispose();
//     _motherNameCtrl.dispose();
//     _motherCnicCtrl.dispose();
//     _motherPhoneCtrl.dispose();
//     _casteCtrl.dispose();
//     _addressCtrl.dispose();
//     for (final f in _studentForms) f.dispose();
//     super.dispose();
//   }
//
//   // ── ID Generators ──
//   Future<void> _generateAdmissionId() async {
//     setState(() => _generatingId = true);
//     final provider = context.read<AdmissionProvider>();
//     _admissionId = await provider.generateAdmissionId(_type);
//     setState(() => _generatingId = false);
//   }
//
//   Future<void> _generateFamilyId() async {
//     final name = _familyNameCtrl.text.trim();
//     if (name.isEmpty) {
//       _snack('Enter family name first');
//       return;
//     }
//     setState(() => _generatingFamilyId = true);
//     final provider = context.read<AdmissionProvider>();
//     _familyId = await provider.generateFamilyId(name);
//     setState(() => _generatingFamilyId = false);
//   }
//
//   Future<void> _generateStudentId(int idx) async {
//     final name = _studentForms[idx].nameCtrl.text.trim();
//     if (name.isEmpty) {
//       _snack('Enter student name first');
//       return;
//     }
//     final provider = context.read<AdmissionProvider>();
//     final id = await provider.generateStudentId(name);
//     setState(() {
//       _studentForms[idx].data.studentId = id;
//       _studentForms[idx].studentIdCtrl.text = id;
//     });
//   }
//
//   // ── Fetch fees from class/section ──
//   Future<void> _fetchFees(int idx) async {
//     final form = _studentForms[idx];
//     final classId = form.data.classId;
//     if (classId == null) return;
//
//     setState(() => form.loadingFees = true);
//     final fees = await context
//         .read<AdmissionProvider>()
//         .fetchFees(classId, form.data.sectionName);
//     setState(() {
//       form.annualFeeCtrl.text =
//           fees['annualFee']?.toStringAsFixed(0) ?? '';
//       form.registrationFeeCtrl.text =
//           fees['registrationFee']?.toStringAsFixed(0) ?? '';
//       form.monthlyFeeCtrl.text =
//           fees['monthlyFee']?.toStringAsFixed(0) ?? '';
//       form.data.annualFee = fees['annualFee'];
//       form.data.registrationFee = fees['registrationFee'];
//       form.data.monthlyFee = fees['monthlyFee'];
//       form.loadingFees = false;
//     });
//   }
//
//   // ── Pick image ──
//   // ── Pick & compress image (mobile + web) ──
//   Future<void> _pickImage(int idx) async {
//     final picker = ImagePicker();
//
//     // Pick without pre-compression — we handle it ourselves
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//
//     final rawBytes = await picked.readAsBytes();
//     final compressed = await _compressToBase64(rawBytes);
//
//     if (compressed != null && mounted) {
//       setState(() => _studentForms[idx].data.picBase64 = compressed);
//     }
//   }
//
//   /// Resize to max 120 × 120 px, JPEG quality 35.
//   /// Result: ~3–8 KB base64 — safe for Firestore on every platform.
//   Future<String?> _compressToBase64(Uint8List rawBytes) async {
//     try {
//       // Decode — works on mobile, web, desktop (pure Dart)
//       final original = img.decodeImage(rawBytes);
//       if (original == null) return null;
//
//       // Resize: keep aspect ratio, longest side ≤ 120 px
//       final img.Image thumbnail;
//       if (original.width >= original.height) {
//         thumbnail = img.copyResize(original, width: 120);
//       } else {
//         thumbnail = img.copyResize(original, height: 120);
//       }
//
//       // Encode to JPEG at quality 35 (tiny file, acceptable for avatars)
//       final jpegBytes = img.encodeJpg(thumbnail, quality: 35);
//
//       // Safety check — should never fail after resize but just in case
//       if (jpegBytes.length > 50 * 1024) {          // still > 50 KB?
//         final jpegBytes2 = img.encodeJpg(thumbnail, quality: 15);
//         return base64Encode(jpegBytes2);
//       }
//
//       return base64Encode(jpegBytes);
//     } catch (e) {
//       debugPrint('Image compression failed: $e');
//       return null;
//     }
//   }
//
//   // Future<void> _pickImage(int idx) async {
//   //   final picker = ImagePicker();
//   //   final picked = await picker.pickImage(
//   //       source: ImageSource.gallery, maxWidth: 600, imageQuality: 70);
//   //   if (picked == null) return;
//   //   final bytes = await picked.readAsBytes();
//   //   final base64Str = base64Encode(bytes);
//   //   setState(() => _studentForms[idx].data.picBase64 = base64Str);
//   // }
//
//   // ── Date picker ──
//   Future<void> _pickDate(
//       BuildContext context, DateTime current, ValueChanged<DateTime> onPicked) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: current,
//       firstDate: DateTime(1990),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) onPicked(picked);
//   }
//
//   void _snack(String msg) =>
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//
//   // ── Save ──
//
//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_admissionId.isEmpty) {
//       _snack('Please wait for ID generation');
//       return;
//     }
//
//     setState(() => _isSaving = true);
//
//     // Sync all student form data
//     for (final f in _studentForms) {
//       f.data.name = f.nameCtrl.text.trim();
//       f.syncFees();
//     }
//
//     final admission = AdmissionModel(
//       id: widget.existing?.id,
//       type: _type,
//       inquiryOrRegId: _admissionId,
//       admissionDate: _admissionDate,
//       previousSchoolName:
//       _prevSchoolCtrl.text.trim().isEmpty ? null : _prevSchoolCtrl.text.trim(),
//       previousClassName:
//       _prevClassCtrl.text.trim().isEmpty ? null : _prevClassCtrl.text.trim(),
//       previousClassMarks:
//       _prevMarksCtrl.text.trim().isEmpty ? null : _prevMarksCtrl.text.trim(),
//       familyId: _familyId,
//       familyName: _familyNameCtrl.text.trim(),
//       fatherName: _fatherNameCtrl.text.trim(),
//       fatherOccupation: _fatherOccCtrl.text.trim().isEmpty
//           ? null
//           : _fatherOccCtrl.text.trim(),
//       fatherCnic: _fatherCnicCtrl.text.trim().isEmpty
//           ? null
//           : _fatherCnicCtrl.text.trim(),
//       fatherPhone: _fatherPhoneCtrl.text.trim(),
//       motherName: _motherNameCtrl.text.trim(),
//       motherCnic:
//       _motherCnicCtrl.text.trim().isEmpty ? null : _motherCnicCtrl.text.trim(),
//       motherPhone:
//       _motherPhoneCtrl.text.trim().isEmpty ? null : _motherPhoneCtrl.text.trim(),
//       caste: _casteCtrl.text.trim().isEmpty ? null : _casteCtrl.text.trim(),
//       address:
//       _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
//       students: _studentForms.map((f) => f.data).toList(),
//     );
//
//     try {
//       await context.read<AdmissionProvider>().saveAdmission(admission);
//       if (mounted) {
//         _snack('Admission saved successfully!');
//         Navigator.pop(context, _type);   // ← CHANGED: return admission type
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Error: $e'), backgroundColor: Colors.red));
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//   // Future<void> _save() async {
//   //   if (!_formKey.currentState!.validate()) return;
//   //   if (_admissionId.isEmpty) {
//   //     _snack('Please wait for ID generation');
//   //     return;
//   //   }
//   //
//   //   setState(() => _isSaving = true);
//   //
//   //   // Sync all student form data
//   //   for (final f in _studentForms) {
//   //     f.data.name = f.nameCtrl.text.trim();
//   //     f.syncFees();
//   //   }
//   //
//   //   final admission = AdmissionModel(
//   //     id: widget.existing?.id,
//   //     type: _type,
//   //     inquiryOrRegId: _admissionId,
//   //     admissionDate: _admissionDate,
//   //     previousSchoolName:
//   //     _prevSchoolCtrl.text.trim().isEmpty ? null : _prevSchoolCtrl.text.trim(),
//   //     previousClassName:
//   //     _prevClassCtrl.text.trim().isEmpty ? null : _prevClassCtrl.text.trim(),
//   //     previousClassMarks:
//   //     _prevMarksCtrl.text.trim().isEmpty ? null : _prevMarksCtrl.text.trim(),
//   //     familyId: _familyId,
//   //     familyName: _familyNameCtrl.text.trim(),
//   //     fatherName: _fatherNameCtrl.text.trim(),
//   //     fatherOccupation: _fatherOccCtrl.text.trim().isEmpty
//   //         ? null
//   //         : _fatherOccCtrl.text.trim(),
//   //     fatherCnic: _fatherCnicCtrl.text.trim().isEmpty
//   //         ? null
//   //         : _fatherCnicCtrl.text.trim(),
//   //     fatherPhone: _fatherPhoneCtrl.text.trim(),
//   //     motherName: _motherNameCtrl.text.trim(),
//   //     motherCnic:
//   //     _motherCnicCtrl.text.trim().isEmpty ? null : _motherCnicCtrl.text.trim(),
//   //     motherPhone:
//   //     _motherPhoneCtrl.text.trim().isEmpty ? null : _motherPhoneCtrl.text.trim(),
//   //     caste: _casteCtrl.text.trim().isEmpty ? null : _casteCtrl.text.trim(),
//   //     address:
//   //     _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
//   //     students: _studentForms.map((f) => f.data).toList(),
//   //   );
//   //
//   //   try {
//   //     await context.read<AdmissionProvider>().saveAdmission(admission);
//   //     if (mounted) {
//   //       _snack('Admission saved successfully!');
//   //       Navigator.pop(context, true);
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//   //           content: Text('Error: $e'), backgroundColor: Colors.red));
//   //     }
//   //   } finally {
//   //     if (mounted) setState(() => _isSaving = false);
//   //   }
//   // }
//
//   // ────────────────────────────────────────────
//   //  BUILD
//   // ────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.existing != null;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEdit ? 'Edit Admission' : 'New Admission'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTypeToggle(),
//               const SizedBox(height: 20),
//               _buildAdmissionIdRow(),
//               const SizedBox(height: 16),
//               _buildDateRow(),
//               const SizedBox(height: 24),
//               _buildSectionTitle('Previous School Info'),
//               _buildPreviousSchoolSection(),
//               const SizedBox(height: 24),
//               _buildSectionTitle('Family Info'),
//               _buildFamilySection(),
//               const SizedBox(height: 24),
//               _buildSectionTitle('Parent Details'),
//               _buildParentSection(),
//               const SizedBox(height: 24),
//               _buildSectionTitle('Student Details'),
//               ..._buildAllStudentCards(),
//               const SizedBox(height: 12),
//               _buildAddStudentButton(),
//               const SizedBox(height: 32),
//               _buildSaveButton(),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Type Toggle ──
//   Widget _buildTypeToggle() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(4),
//       child: Row(
//         children: AdmissionType.values.map((t) {
//           final selected = _type == t;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () async {
//                 if (_type == t) return;
//                 setState(() => _type = t);
//                 await _generateAdmissionId();
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: selected ? _purple : Colors.transparent,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     t.label,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: selected ? Colors.white : Colors.black54,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   // ── Admission ID Row ──
//   Widget _buildAdmissionIdRow() {
//     final label =
//     _type == AdmissionType.preAdmission ? 'Inquiry ID' : 'Registration ID';
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.badge_outlined, size: 18, color: _purple),
//                 const SizedBox(width: 8),
//                 Text('$label: ',
//                     style: const TextStyle(
//                         fontSize: 13, color: Colors.black54)),
//                 _generatingId
//                     ? const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(strokeWidth: 2))
//                     : Text(
//                   _admissionId.isEmpty ? '—' : _admissionId,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       color: _purple),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Date Row ──
//   Widget _buildDateRow() {
//     final label = _type == AdmissionType.preAdmission
//         ? 'Inquiry Date'
//         : 'Registration Date';
//     return InkWell(
//       onTap: () => _pickDate(context, _admissionDate,
//               (d) => setState(() => _admissionDate = d)),
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade400),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.calendar_today_outlined, size: 18),
//             const SizedBox(width: 10),
//             Text(label,
//                 style: const TextStyle(fontSize: 13, color: Colors.black54)),
//             const Spacer(),
//             Text(
//               '${_admissionDate.day.toString().padLeft(2, '0')}/'
//                   '${_admissionDate.month.toString().padLeft(2, '0')}/'
//                   '${_admissionDate.year}',
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(width: 6),
//             const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Previous School ──
//   Widget _buildPreviousSchoolSection() {
//     return Column(
//       children: [
//         _field(_prevSchoolCtrl, 'Previous School Name', Icons.school_outlined,
//             required: false),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//                 child: _field(_prevClassCtrl, 'Previous Class', Icons.class_,
//                     required: false)),
//             const SizedBox(width: 12),
//             Expanded(
//                 child: _field(_prevMarksCtrl, 'Marks / Grade',
//                     Icons.grade_outlined,
//                     required: false)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // ── Family ──
//   Widget _buildFamilySection() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: _familyNameCtrl,
//                 decoration: const InputDecoration(
//                   labelText: 'Family Name *',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.family_restroom),
//                 ),
//                 validator: (v) =>
//                 v == null || v.trim().isEmpty ? 'Required' : null,
//               ),
//             ),
//             const SizedBox(width: 10),
//             ElevatedButton.icon(
//               onPressed: _generatingFamilyId ? null : _generateFamilyId,
//               icon: _generatingFamilyId
//                   ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2, color: Colors.white))
//                   : const Icon(Icons.auto_fix_high, size: 18),
//               label: const Text('Gen ID'),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: _purple, foregroundColor: Colors.white),
//             ),
//           ],
//         ),
//         if (_familyId.isNotEmpty) ...[
//           const SizedBox(height: 8),
//           Container(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.purple.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.purple.shade200),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.tag, size: 16, color: _purple),
//                 const SizedBox(width: 8),
//                 Text('Family ID: ',
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                 Text(_familyId,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: _purple,
//                         fontSize: 13)),
//               ],
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   // ── Parents ──
//   Widget _buildParentSection() {
//     final isPre = _type == AdmissionType.preAdmission;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Father
//         _sectionSubTitle('Father Details'),
//         const SizedBox(height: 8),
//         _field(_fatherNameCtrl, 'Father Name *', Icons.person),
//         const SizedBox(height: 10),
//         _field(_fatherOccCtrl, 'Occupation${isPre ? ' (Optional)' : ' *'}',
//             Icons.work_outline,
//             required: !isPre),
//         const SizedBox(height: 10),
//         _field(
//             _fatherCnicCtrl, 'Father CNIC${isPre ? ' (Optional)' : ' *'}',
//             Icons.credit_card,
//             required: !isPre),
//         const SizedBox(height: 10),
//         _field(_fatherPhoneCtrl, 'Father Phone *', Icons.phone,
//             keyboard: TextInputType.phone),
//         const SizedBox(height: 20),
//
//         // Mother
//         _sectionSubTitle('Mother Details'),
//         const SizedBox(height: 8),
//         _field(_motherNameCtrl, 'Mother Name *', Icons.person_outline),
//         const SizedBox(height: 10),
//         _field(_motherCnicCtrl, 'Mother CNIC (Optional)', Icons.credit_card,
//             required: false),
//         const SizedBox(height: 10),
//         _field(_motherPhoneCtrl, 'Mother Phone (Optional)', Icons.phone,
//             required: false, keyboard: TextInputType.phone),
//         const SizedBox(height: 20),
//
//         // Extra
//         Row(
//           children: [
//             Expanded(
//                 child: _field(_casteCtrl, 'Caste (Optional)',
//                     Icons.diversity_3_outlined,
//                     required: false)),
//             const SizedBox(width: 12),
//           ],
//         ),
//         const SizedBox(height: 10),
//         _field(_addressCtrl, 'Address (Optional)', Icons.home_outlined,
//             required: false, maxLines: 2),
//       ],
//     );
//   }
//
//   // ── All Student Cards ──
//   List<Widget> _buildAllStudentCards() {
//     return _studentForms.asMap().entries.map((entry) {
//       final idx = entry.key;
//       return _buildStudentCard(idx);
//     }).toList();
//   }
//
//   Widget _buildStudentCard(int idx) {
//     final form = _studentForms[idx];
//     final isPre = _type == AdmissionType.preAdmission;
//     final classes = context.watch<ClassProvider>().classes;
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _purple,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'Student ${idx + 1}',
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 const Spacer(),
//                 if (_studentForms.length > 1)
//                   IconButton(
//                     icon: const Icon(Icons.delete_outline, color: Colors.red),
//                     onPressed: () => setState(() {
//                       _studentForms[idx].dispose();
//                       _studentForms.removeAt(idx);
//                     }),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 14),
//
//             // Photo
//             Center(
//               child: GestureDetector(
//                 onTap: () => _pickImage(idx),
//                 child: Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey.shade200,
//                     border: Border.all(color: _purple, width: 2),
//                     image: form.data.picBase64 != null
//                         ? DecorationImage(
//                         image: MemoryImage(
//                             base64Decode(form.data.picBase64!)),
//                         fit: BoxFit.cover)
//                         : null,
//                   ),
//                   child: form.data.picBase64 == null
//                       ? const Icon(Icons.camera_alt_outlined,
//                       color: Colors.grey, size: 30)
//                       : null,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Center(
//               child: Text('Tap to add photo',
//                   style: TextStyle(fontSize: 11, color: Colors.grey)),
//             ),
//             const SizedBox(height: 14),
//
//             // Name + auto Student ID
//             TextFormField(
//               controller: form.nameCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Student Name *',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.person),
//               ),
//               validator: (v) =>
//               v == null || v.trim().isEmpty ? 'Enter student name' : null,
//               onChanged: (v) => form.data.name = v,
//             ),
//             const SizedBox(height: 10),
//
//             // Student ID
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.fingerprint, size: 18, color: _purple),
//                         const SizedBox(width: 8),
//                         Text('Student ID: ',
//                             style: const TextStyle(
//                                 fontSize: 13, color: Colors.black54)),
//                         Text(
//                           form.data.studentId.isEmpty
//                               ? '—'
//                               : form.data.studentId,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: _purple,
//                               fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton.icon(
//                   onPressed: () => _generateStudentId(idx),
//                   icon: const Icon(Icons.auto_fix_high, size: 16),
//                   label: const Text('Gen'),
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: _purple,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 14)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//
//             // Class + Section
//             _buildClassSectionDropdown(idx, classes),
//             const SizedBox(height: 10),
//
//             // Roll No
//             TextFormField(
//               controller: form.rollNoCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Class Roll No (Optional)',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.format_list_numbered),
//               ),
//             ),
//             const SizedBox(height: 10),
//
//             // B-Form / CNIC
//             TextFormField(
//               controller: form.cnicCtrl,
//               decoration: InputDecoration(
//                 labelText:
//                 'B-Form / CNIC${isPre ? ' (Optional)' : ' *'}',
//                 border: const OutlineInputBorder(),
//                 prefixIcon: const Icon(Icons.credit_card_outlined),
//               ),
//               keyboardType: TextInputType.number,
//               validator: isPre
//                   ? null
//                   : (v) => v == null || v.trim().isEmpty ? 'Required' : null,
//             ),
//             const SizedBox(height: 10),
//
//             // DOB
//             InkWell(
//               onTap: () => _pickDate(
//                   context,
//                   form.data.dob ?? DateTime(2010),
//                       (d) => setState(() => form.data.dob = d)),
//               borderRadius: BorderRadius.circular(8),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 14),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade400),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.cake_outlined, size: 18),
//                     const SizedBox(width: 10),
//                     const Text('Date of Birth *',
//                         style: TextStyle(
//                             fontSize: 13, color: Colors.black54)),
//                     const Spacer(),
//                     Text(
//                       form.data.dob != null
//                           ? '${form.data.dob!.day.toString().padLeft(2, '0')}/'
//                           '${form.data.dob!.month.toString().padLeft(2, '0')}/'
//                           '${form.data.dob!.year}'
//                           : 'Select Date',
//                       style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                           color: form.data.dob != null
//                               ? Colors.black87
//                               : Colors.grey),
//                     ),
//                     const Icon(Icons.edit_outlined,
//                         size: 16, color: Colors.grey),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 14),
//
//             // Fees
//             _buildFeesCard(idx, isPre),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Class + Section Dropdown ──
//   Widget _buildClassSectionDropdown(int idx, List<SchoolClass> classes) {
//     final form = _studentForms[idx];
//
//     // Find selected class
//     SchoolClass? selectedClass;
//     if (form.data.classId != null) {
//       try {
//         selectedClass =
//             classes.firstWhere((c) => c.id == form.data.classId);
//       } catch (_) {}
//     }
//
//     final sections = selectedClass?.sections ?? [];
//
//     return Column(
//       children: [
//         DropdownButtonFormField<String>(
//           value: form.data.classId,
//           decoration: const InputDecoration(
//             labelText: 'Class *',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.class_),
//           ),
//           items: classes
//               .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
//               .toList(),
//           onChanged: (val) async {
//             setState(() {
//               form.data.classId = val;
//               form.data.className =
//                   classes.firstWhere((c) => c.id == val).name;
//               form.data.sectionId = null;
//               form.data.sectionName = null;
//             });
//             await _fetchFees(idx);
//           },
//           validator: (v) => v == null ? 'Select class' : null,
//         ),
//         if (sections.isNotEmpty) ...[
//           const SizedBox(height: 10),
//           DropdownButtonFormField<String>(
//             value: form.data.sectionName,
//             decoration: const InputDecoration(
//               labelText: 'Section (Optional)',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.group_outlined),
//             ),
//             items: sections
//                 .map((s) => DropdownMenuItem(
//                 value: s.sectionName, child: Text(s.sectionName)))
//                 .toList(),
//             onChanged: (val) async {
//               setState(() {
//                 form.data.sectionName = val;
//               });
//               await _fetchFees(idx);
//             },
//           ),
//         ],
//       ],
//     );
//   }
//
//   // ── Fees Card ──
//   Widget _buildFeesCard(int idx, bool isPre) {
//     final form = _studentForms[idx];
//     return Card(
//       color: Colors.grey.shade50,
//       elevation: 0,
//       shape:
//       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.payments_outlined, size: 16, color: _purple),
//                 const SizedBox(width: 6),
//                 Text(
//                   isPre
//                       ? 'Fee (fetched from class, editable)'
//                       : 'Fee Structure *',
//                   style: Theme.of(context).textTheme.labelLarge,
//                 ),
//                 if (form.loadingFees) ...[
//                   const Spacer(),
//                   const SizedBox(
//                       width: 14,
//                       height: 14,
//                       child: CircularProgressIndicator(strokeWidth: 2)),
//                 ],
//               ],
//             ),
//             const SizedBox(height: 10),
//             TextFormField(
//               controller: form.annualFeeCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Annual Fee',
//                 border: OutlineInputBorder(),
//                 prefixText: 'Rs ',
//                 isDense: true,
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: form.registrationFeeCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Registration Fee',
//                 border: OutlineInputBorder(),
//                 prefixText: 'Rs ',
//                 isDense: true,
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: form.monthlyFeeCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Monthly Fee',
//                 border: OutlineInputBorder(),
//                 prefixText: 'Rs ',
//                 isDense: true,
//               ),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Add Student Button ──
//   Widget _buildAddStudentButton() {
//     return OutlinedButton.icon(
//       onPressed: () =>
//           setState(() => _studentForms.add(_StudentFormState())),
//       icon: const Icon(Icons.person_add_outlined),
//       label: const Text('+ Add More Student'),
//       style: OutlinedButton.styleFrom(
//         minimumSize: const Size(double.infinity, 48),
//         foregroundColor: _purple,
//         side: BorderSide(color: _purple),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   // ── Save Button ──
//   Widget _buildSaveButton() {
//     return ElevatedButton(
//       onPressed: _isSaving ? null : _save,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _purple,
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: _isSaving
//           ? const SizedBox(
//           width: 22,
//           height: 22,
//           child: CircularProgressIndicator(
//               strokeWidth: 2, color: Colors.white))
//           : Text(
//         widget.existing == null ? 'Save Admission' : 'Update Admission',
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   // ── Helpers ──
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 4,
//             height: 18,
//             decoration: BoxDecoration(
//               color: _purple,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(title,
//               style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87)),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionSubTitle(String title) => Padding(
//     padding: const EdgeInsets.only(bottom: 4),
//     child: Text(title,
//         style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 13,
//             color: Colors.grey.shade700)),
//   );
//
//   Widget _field(
//       TextEditingController ctrl,
//       String label,
//       IconData icon, {
//         bool required = true,
//         TextInputType keyboard = TextInputType.text,
//         int maxLines = 1,
//       }) {
//     return TextFormField(
//       controller: ctrl,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         prefixIcon: Icon(icon),
//       ),
//       keyboardType: keyboard,
//       maxLines: maxLines,
//       validator: required
//           ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
//           : null,
//     );
//   }
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/admission_model.dart';
import '../../models/class_model.dart';
import '../../providers/admission_provider.dart';
import '../../providers/class_provider.dart';

// ─────────────────────────────────────────────
//  Helper: per-student UI state
// ─────────────────────────────────────────────
class _StudentFormState {
  AdmissionStudent data;

  final TextEditingController annualFeeCtrl;
  final TextEditingController registrationFeeCtrl;
  final TextEditingController monthlyFeeCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController rollNoCtrl;
  final TextEditingController cnicCtrl;
  final TextEditingController studentIdCtrl;

  bool loadingFees = false;

  _StudentFormState({AdmissionStudent? student})
      : data = student ?? AdmissionStudent(),
        annualFeeCtrl = TextEditingController(
            text: student?.annualFee?.toStringAsFixed(0) ?? ''),
        registrationFeeCtrl = TextEditingController(
            text: student?.registrationFee?.toStringAsFixed(0) ?? ''),
        monthlyFeeCtrl = TextEditingController(
            text: student?.monthlyFee?.toStringAsFixed(0) ?? ''),
        nameCtrl = TextEditingController(text: student?.name ?? ''),
        rollNoCtrl = TextEditingController(text: student?.classRollNo ?? ''),
        cnicCtrl = TextEditingController(text: student?.bFormCnic ?? ''),
        studentIdCtrl = TextEditingController(text: student?.studentId ?? '');

  void dispose() {
    annualFeeCtrl.dispose();
    registrationFeeCtrl.dispose();
    monthlyFeeCtrl.dispose();
    nameCtrl.dispose();
    rollNoCtrl.dispose();
    cnicCtrl.dispose();
    studentIdCtrl.dispose();
  }

  void syncFees() {
    data.annualFee = double.tryParse(annualFeeCtrl.text);
    data.registrationFee = double.tryParse(registrationFeeCtrl.text);
    data.monthlyFee = double.tryParse(monthlyFeeCtrl.text);
    data.classRollNo =
    rollNoCtrl.text.trim().isEmpty ? null : rollNoCtrl.text.trim();
    data.bFormCnic =
    cnicCtrl.text.trim().isEmpty ? null : cnicCtrl.text.trim();
  }
}

// ─────────────────────────────────────────────
//  Main Admission Form Screen
// ─────────────────────────────────────────────
class AdmissionFormScreen extends StatefulWidget {
  final AdmissionModel? existing;

  final bool showAppBar;
  final VoidCallback? onSaved;
  const AdmissionFormScreen({
    super.key,
    this.existing,
    this.showAppBar = true,
    this.onSaved,
  });

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late AdmissionType _type;
  String _admissionId = '';
  DateTime _admissionDate = DateTime.now();
  bool _generatingId = false;
  bool _isSaving = false;

  // Previous school
  final _prevSchoolCtrl = TextEditingController();
  final _prevClassCtrl = TextEditingController();
  final _prevMarksCtrl = TextEditingController();

  // Family — new/existing toggle
  bool _isExistingFamily = false;
  AdmissionModel? _selectedFamily;
  final _familySearchCtrl = TextEditingController();
  List<AdmissionModel> _familySearchResults = [];
  bool _isSearchingFamily = false;

  final _familyNameCtrl = TextEditingController();
  String _familyId = '';
  bool _generatingFamilyId = false;

  // Parents
  final _fatherNameCtrl = TextEditingController();
  final _fatherOccCtrl = TextEditingController();
  final _fatherCnicCtrl = TextEditingController();
  final _fatherPhoneCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();
  final _motherCnicCtrl = TextEditingController();
  final _motherPhoneCtrl = TextEditingController();
  final _casteCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Students
  final List<_StudentFormState> _studentForms = [];

  static const _purple = Color(0xFF534AB7);

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _type = ex?.type ?? AdmissionType.preAdmission;
    _admissionId = ex?.inquiryOrRegId ?? '';
    _admissionDate = ex?.admissionDate ?? DateTime.now();

    _prevSchoolCtrl.text = ex?.previousSchoolName ?? '';
    _prevClassCtrl.text = ex?.previousClassName ?? '';
    _prevMarksCtrl.text = ex?.previousClassMarks ?? '';

    _familyNameCtrl.text = ex?.familyName ?? '';
    _familyId = ex?.familyId ?? '';

    _fatherNameCtrl.text = ex?.fatherName ?? '';
    _fatherOccCtrl.text = ex?.fatherOccupation ?? '';
    _fatherCnicCtrl.text = ex?.fatherCnic ?? '';
    _fatherPhoneCtrl.text = ex?.fatherPhone ?? '';
    _motherNameCtrl.text = ex?.motherName ?? '';
    _motherCnicCtrl.text = ex?.motherCnic ?? '';
    _motherPhoneCtrl.text = ex?.motherPhone ?? '';
    _casteCtrl.text = ex?.caste ?? '';
    _addressCtrl.text = ex?.address ?? '';

    final students = ex?.students ?? [AdmissionStudent()];
    for (final s in students) {
      _studentForms.add(_StudentFormState(student: s));
    }

    if (ex == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _generateAdmissionId());
    }
  }

  @override
  void dispose() {
    _prevSchoolCtrl.dispose();
    _prevClassCtrl.dispose();
    _prevMarksCtrl.dispose();
    _familyNameCtrl.dispose();
    _familySearchCtrl.dispose(); // ← NEW
    _fatherNameCtrl.dispose();
    _fatherOccCtrl.dispose();
    _fatherCnicCtrl.dispose();
    _fatherPhoneCtrl.dispose();
    _motherNameCtrl.dispose();
    _motherCnicCtrl.dispose();
    _motherPhoneCtrl.dispose();
    _casteCtrl.dispose();
    _addressCtrl.dispose();
    for (final f in _studentForms) f.dispose();
    super.dispose();
  }

  // ── ID Generators ──
  Future<void> _generateAdmissionId() async {
    setState(() => _generatingId = true);
    _admissionId =
    await context.read<AdmissionProvider>().generateAdmissionId(_type);
    setState(() => _generatingId = false);
  }

  Future<void> _generateFamilyId() async {
    final name = _familyNameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Enter family name first');
      return;
    }
    setState(() => _generatingFamilyId = true);
    _familyId =
    await context.read<AdmissionProvider>().generateFamilyId(name);
    setState(() => _generatingFamilyId = false);
  }

  Future<void> _generateStudentId(int idx) async {
    final name = _studentForms[idx].nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Enter student name first');
      return;
    }
    final id =
    await context.read<AdmissionProvider>().generateStudentId(name);
    setState(() {
      _studentForms[idx].data.studentId = id;
      _studentForms[idx].studentIdCtrl.text = id;
    });
  }

  // ── Existing Family Search ──────────────────────────
  Future<void> _searchFamily() async {
    final query = _familySearchCtrl.text.trim();
    if (query.isEmpty) {
      _snack('Family name likhain search k liye');
      return;
    }
    setState(() => _isSearchingFamily = true);
    final results =
    await context.read<AdmissionProvider>().searchFamilies(query);
    setState(() {
      _familySearchResults = results;
      _isSearchingFamily = false;
      if (results.isEmpty) _snack('Koi family nahi mili — naya naam try karein');
    });
  }

  void _selectFamily(AdmissionModel admission) {
    setState(() {
      _selectedFamily = admission;
      // Fill family fields
      _familyNameCtrl.text = admission.familyName;
      _familyId = admission.familyId;
      // Fill parent fields from selected family
      _fatherNameCtrl.text = admission.fatherName;
      _fatherOccCtrl.text = admission.fatherOccupation ?? '';
      _fatherCnicCtrl.text = admission.fatherCnic ?? '';
      _fatherPhoneCtrl.text = admission.fatherPhone;
      _motherNameCtrl.text = admission.motherName;
      _motherCnicCtrl.text = admission.motherCnic ?? '';
      _motherPhoneCtrl.text = admission.motherPhone ?? '';
      _casteCtrl.text = admission.caste ?? '';
      _addressCtrl.text = admission.address ?? '';
      // Clear search state
      _familySearchResults = [];
      _familySearchCtrl.clear();
    });
  }

  void _detachFamily() {
    setState(() {
      _selectedFamily = null;
      _familySearchResults = [];
      _familySearchCtrl.clear();
      // Clear parent fields so user can fill fresh
      _familyNameCtrl.clear();
      _familyId = '';
      _fatherNameCtrl.clear();
      _fatherOccCtrl.clear();
      _fatherCnicCtrl.clear();
      _fatherPhoneCtrl.clear();
      _motherNameCtrl.clear();
      _motherCnicCtrl.clear();
      _motherPhoneCtrl.clear();
      _casteCtrl.clear();
      _addressCtrl.clear();
    });
  }

  // ── Fees ──
  Future<void> _fetchFees(int idx) async {
    final form = _studentForms[idx];
    final classId = form.data.classId;
    if (classId == null) return;
    setState(() => form.loadingFees = true);
    final fees = await context
        .read<AdmissionProvider>()
        .fetchFees(classId, form.data.sectionName);
    setState(() {
      form.annualFeeCtrl.text = fees['annualFee']?.toStringAsFixed(0) ?? '';
      form.registrationFeeCtrl.text =
          fees['registrationFee']?.toStringAsFixed(0) ?? '';
      form.monthlyFeeCtrl.text = fees['monthlyFee']?.toStringAsFixed(0) ?? '';
      form.data.annualFee = fees['annualFee'];
      form.data.registrationFee = fees['registrationFee'];
      form.data.monthlyFee = fees['monthlyFee'];
      form.loadingFees = false;
    });
  }

  // ── Image Pick + Compress ──
  Future<void> _pickImage(int idx) async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final compressed =
    await _compressToBase64(await picked.readAsBytes());
    if (compressed != null && mounted) {
      setState(() => _studentForms[idx].data.picBase64 = compressed);
    }
  }

  Future<String?> _compressToBase64(Uint8List rawBytes) async {
    try {
      final original = img.decodeImage(rawBytes);
      if (original == null) return null;
      final thumbnail = original.width >= original.height
          ? img.copyResize(original, width: 120)
          : img.copyResize(original, height: 120);
      final jpegBytes = img.encodeJpg(thumbnail, quality: 35);
      if (jpegBytes.length > 50 * 1024) {
        return base64Encode(img.encodeJpg(thumbnail, quality: 15));
      }
      return base64Encode(jpegBytes);
    } catch (e) {
      debugPrint('Image compression failed: $e');
      return null;
    }
  }

  // ── Date Picker ──
  Future<void> _pickDate(BuildContext context, DateTime current,
      ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) onPicked(picked);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  // ── Save ──
  Future<void> _save() async {
    // Extra guard: existing family selected nahi
    if (_isExistingFamily && _selectedFamily == null) {
      _snack('Existing family select karein ya "Nai Family" choose karein');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_admissionId.isEmpty) {
      _snack('Please wait for ID generation');
      return;
    }

    setState(() => _isSaving = true);

    for (final f in _studentForms) {
      f.data.name = f.nameCtrl.text.trim();
      f.syncFees();
    }

    final admission = AdmissionModel(
      // ... fill all fields ...
    );

    try {
      await context.read<AdmissionProvider>().saveAdmission(admission);
      if (mounted) {
        _snack('Admission saved successfully!');
        widget.onSaved?.call();   // ✅ Added
        Navigator.pop(context, _type);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  // Future<void> _save() async {
  //   // Extra guard: existing family selected nahi
  //   if (_isExistingFamily && _selectedFamily == null) {
  //     _snack('Existing family select karein ya "Nai Family" choose karein');
  //     return;
  //   }
  //
  //   if (!_formKey.currentState!.validate()) return;
  //   if (_admissionId.isEmpty) {
  //     _snack('Please wait for ID generation');
  //     return;
  //   }
  //
  //   setState(() => _isSaving = true);
  //
  //   for (final f in _studentForms) {
  //     f.data.name = f.nameCtrl.text.trim();
  //     f.syncFees();
  //   }
  //
  //   final admission = AdmissionModel(
  //     id: widget.existing?.id,
  //     type: _type,
  //     inquiryOrRegId: _admissionId,
  //     admissionDate: _admissionDate,
  //     previousSchoolName: _prevSchoolCtrl.text.trim().isEmpty
  //         ? null
  //         : _prevSchoolCtrl.text.trim(),
  //     previousClassName: _prevClassCtrl.text.trim().isEmpty
  //         ? null
  //         : _prevClassCtrl.text.trim(),
  //     previousClassMarks: _prevMarksCtrl.text.trim().isEmpty
  //         ? null
  //         : _prevMarksCtrl.text.trim(),
  //     familyId: _familyId,
  //     familyName: _familyNameCtrl.text.trim(),
  //     fatherName: _fatherNameCtrl.text.trim(),
  //     fatherOccupation: _fatherOccCtrl.text.trim().isEmpty
  //         ? null
  //         : _fatherOccCtrl.text.trim(),
  //     fatherCnic: _fatherCnicCtrl.text.trim().isEmpty
  //         ? null
  //         : _fatherCnicCtrl.text.trim(),
  //     fatherPhone: _fatherPhoneCtrl.text.trim(),
  //     motherName: _motherNameCtrl.text.trim(),
  //     motherCnic: _motherCnicCtrl.text.trim().isEmpty
  //         ? null
  //         : _motherCnicCtrl.text.trim(),
  //     motherPhone: _motherPhoneCtrl.text.trim().isEmpty
  //         ? null
  //         : _motherPhoneCtrl.text.trim(),
  //     caste: _casteCtrl.text.trim().isEmpty ? null : _casteCtrl.text.trim(),
  //     address:
  //     _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
  //     students: _studentForms.map((f) => f.data).toList(),
  //   );
  //
  //   try {
  //     await context.read<AdmissionProvider>().saveAdmission(admission);
  //     if (mounted) {
  //       _snack('Admission saved successfully!');
  //       Navigator.pop(context, _type);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text('Error: $e'), backgroundColor: Colors.red));
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isSaving = false);
  //   }
  // }

  // ────────────────────────────────────────────
  //  BUILD
  // ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Admission' : 'New Admission'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 20),
              _buildAdmissionIdRow(),
              const SizedBox(height: 16),
              _buildDateRow(),
              const SizedBox(height: 24),
              _buildSectionTitle('Previous School Info'),
              _buildPreviousSchoolSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Family Info'),
              _buildFamilySection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Parent Details'),
              _buildParentSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Student Details'),
              ..._buildAllStudentCards(),
              const SizedBox(height: 12),
              _buildAddStudentButton(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Type Toggle ──
  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: AdmissionType.values.map((t) {
          final selected = _type == t;
          return Expanded(
            child: GestureDetector(
              onTap: () async {
                if (_type == t) return;
                setState(() => _type = t);
                await _generateAdmissionId();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? _purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    t.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Admission ID Row ──
  Widget _buildAdmissionIdRow() {
    final label = _type == AdmissionType.preAdmission
        ? 'Inquiry ID'
        : 'Registration ID';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.badge_outlined, size: 18, color: _purple),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          _generatingId
              ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
            _admissionId.isEmpty ? '—' : _admissionId,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: _purple),
          ),
        ],
      ),
    );
  }

  // ── Date Row ──
  Widget _buildDateRow() {
    final label = _type == AdmissionType.preAdmission
        ? 'Inquiry Date'
        : 'Registration Date';
    return InkWell(
      onTap: () => _pickDate(
          context, _admissionDate, (d) => setState(() => _admissionDate = d)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 10),
            Text(label,
                style:
                const TextStyle(fontSize: 13, color: Colors.black54)),
            const Spacer(),
            Text(
              '${_admissionDate.day.toString().padLeft(2, '0')}/'
                  '${_admissionDate.month.toString().padLeft(2, '0')}/'
                  '${_admissionDate.year}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ── Previous School ──
  Widget _buildPreviousSchoolSection() {
    return Column(
      children: [
        _field(_prevSchoolCtrl, 'Previous School Name',
            Icons.school_outlined,
            required: false),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _field(
                    _prevClassCtrl, 'Previous Class', Icons.class_,
                    required: false)),
            const SizedBox(width: 12),
            Expanded(
                child: _field(_prevMarksCtrl, 'Marks / Grade',
                    Icons.grade_outlined,
                    required: false)),
          ],
        ),
      ],
    );
  }

  // ── Family Section (MODIFIED) ──
  Widget _buildFamilySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Toggle Row ──
        Row(
          children: [
            Expanded(
              child: _familyToggleBtn(
                label: '🆕  Nai Family',
                isSelected: !_isExistingFamily,
                onTap: () {
                  if (!_isExistingFamily) return;
                  setState(() {
                    _isExistingFamily = false;
                    _selectedFamily = null;
                    _familySearchResults = [];
                    _familySearchCtrl.clear();
                    // Clear pre-filled parent data
                    _familyNameCtrl.clear();
                    _familyId = '';
                    _fatherNameCtrl.clear();
                    _fatherOccCtrl.clear();
                    _fatherCnicCtrl.clear();
                    _fatherPhoneCtrl.clear();
                    _motherNameCtrl.clear();
                    _motherCnicCtrl.clear();
                    _motherPhoneCtrl.clear();
                    _casteCtrl.clear();
                    _addressCtrl.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _familyToggleBtn(
                label: '🔍  Existing Family',
                isSelected: _isExistingFamily,
                onTap: () {
                  if (_isExistingFamily) return;
                  setState(() => _isExistingFamily = true);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Existing Family Mode ──
        if (_isExistingFamily) ...[
          if (_selectedFamily == null) ...[
            // Search field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _familySearchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Family Name se search karein',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      hintText: 'e.g. Khan, Ahmed...',
                    ),
                    onFieldSubmitted: (_) => _searchFamily(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isSearchingFamily ? null : _searchFamily,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  child: _isSearchingFamily
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('Search'),
                ),
              ],
            ),
            // Search Results
            if (_familySearchResults.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: _familySearchResults
                      .map((f) => _buildFamilyResultTile(f))
                      .toList(),
                ),
              ),
            ],
          ] else ...[
            // Selected Family Card
            Container(
              padding: const EdgeInsets.all(14),
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
                      Icon(Icons.check_circle,
                          color: Colors.green.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFamily!.familyName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _detachFamily,
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Change'),
                        style: TextButton.styleFrom(
                            foregroundColor: _purple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${_selectedFamily!.familyId}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    'Father: ${_selectedFamily!.fatherName}  •  ${_selectedFamily!.fatherPhone}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade700),
                  ),
                  if (_selectedFamily!.motherName.isNotEmpty)
                    Text(
                      'Mother: ${_selectedFamily!.motherName}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                ],
              ),
            ),
          ],
        ] else ...[
          // ── New Family Mode ──
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _familyNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Family Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _generatingFamilyId ? null : _generateFamilyId,
                icon: _generatingFamilyId
                    ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_fix_high, size: 18),
                label: const Text('Gen ID'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
          if (_familyId.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.tag, size: 16, color: _purple),
                  const SizedBox(width: 8),
                  Text('Family ID: ',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  Text(_familyId,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _purple,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  // ── Family Toggle Button Helper ──
  Widget _familyToggleBtn({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _purple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
              isSelected ? _purple : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ── Family Search Result Tile ──
  Widget _buildFamilyResultTile(AdmissionModel f) {
    final isFirst = _familySearchResults.first.familyId == f.familyId;
    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: Colors.grey.shade200),
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: _purple.withOpacity(0.1),
            child: Text(
              f.familyName.isNotEmpty
                  ? f.familyName[0].toUpperCase()
                  : 'F',
              style: TextStyle(
                  color: _purple, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            f.familyName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            '${f.fatherName}  •  ID: ${f.familyId}',
            style:
            TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: ElevatedButton(
            onPressed: () => _selectFamily(f),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              minimumSize: const Size(64, 34),
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: const Text('Select'),
          ),
        ),
      ],
    );
  }

  // ── Parent Section (MODIFIED) ──
  Widget _buildParentSection() {
    // Existing family selected → read-only card
    if (_isExistingFamily && _selectedFamily != null) {
      return _buildReadOnlyParentCard();
    }
    // Otherwise → editable fields
    final isPre = _type == AdmissionType.preAdmission;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionSubTitle('Father Details'),
        const SizedBox(height: 8),
        _field(_fatherNameCtrl, 'Father Name *', Icons.person),
        const SizedBox(height: 10),
        _field(
            _fatherOccCtrl,
            'Occupation${isPre ? ' (Optional)' : ' *'}',
            Icons.work_outline,
            required: !isPre),
        const SizedBox(height: 10),
        _field(
            _fatherCnicCtrl,
            'Father CNIC${isPre ? ' (Optional)' : ' *'}',
            Icons.credit_card,
            required: !isPre),
        const SizedBox(height: 10),
        _field(_fatherPhoneCtrl, 'Father Phone *', Icons.phone,
            keyboard: TextInputType.phone),
        const SizedBox(height: 20),

        _sectionSubTitle('Mother Details'),
        const SizedBox(height: 8),
        // ✅ Mother Name → OPTIONAL now
        _field(_motherNameCtrl, 'Mother Name (Optional)',
            Icons.person_outline,
            required: false),
        const SizedBox(height: 10),
        _field(_motherCnicCtrl, 'Mother CNIC (Optional)',
            Icons.credit_card,
            required: false),
        const SizedBox(height: 10),
        _field(_motherPhoneCtrl, 'Mother Phone (Optional)', Icons.phone,
            required: false, keyboard: TextInputType.phone),
        const SizedBox(height: 20),

        Row(children: [
          Expanded(
              child: _field(_casteCtrl, 'Caste (Optional)',
                  Icons.diversity_3_outlined,
                  required: false)),
        ]),
        const SizedBox(height: 10),
        _field(_addressCtrl, 'Address (Optional)', Icons.home_outlined,
            required: false, maxLines: 2),
      ],
    );
  }

  // ── Read-only Parent Card (when existing family selected) ──
  Widget _buildReadOnlyParentCard() {
    final f = _selectedFamily!;

    Widget infoRow(IconData icon, String label, String? value) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text('$label: ',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline,
                  color: Colors.blue.shade400, size: 15),
              const SizedBox(width: 6),
              Text(
                'Parent details — existing family se liye gaye',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Father
          Text('Father',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _purple)),
          const SizedBox(height: 4),
          infoRow(Icons.person, 'Name', f.fatherName),
          infoRow(Icons.phone, 'Phone', f.fatherPhone),
          infoRow(Icons.credit_card, 'CNIC', f.fatherCnic),
          infoRow(Icons.work_outline, 'Occupation', f.fatherOccupation),

          if (f.motherName.isNotEmpty) ...[
            const Divider(height: 16),
            Text('Mother',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: _purple)),
            const SizedBox(height: 4),
            infoRow(Icons.person_outline, 'Name', f.motherName),
            infoRow(Icons.phone_outlined, 'Phone', f.motherPhone),
            infoRow(Icons.credit_card_outlined, 'CNIC', f.motherCnic),
          ],

          if (f.caste != null && f.caste!.isNotEmpty) ...[
            const Divider(height: 16),
            infoRow(
                Icons.diversity_3_outlined, 'Caste', f.caste),
          ],
          if (f.address != null && f.address!.isNotEmpty)
            infoRow(Icons.home_outlined, 'Address', f.address),
        ],
      ),
    );
  }

  // ── All Student Cards ──
  List<Widget> _buildAllStudentCards() {
    return _studentForms.asMap().entries.map((entry) {
      return _buildStudentCard(entry.key);
    }).toList();
  }

  Widget _buildStudentCard(int idx) {
    final form = _studentForms[idx];
    final isPre = _type == AdmissionType.preAdmission;
    final classes = context.watch<ClassProvider>().classes;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Student ${idx + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                if (_studentForms.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red),
                    onPressed: () => setState(() {
                      _studentForms[idx].dispose();
                      _studentForms.removeAt(idx);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Photo
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(idx),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: _purple, width: 2),
                    image: form.data.picBase64 != null
                        ? DecorationImage(
                        image: MemoryImage(
                            base64Decode(form.data.picBase64!)),
                        fit: BoxFit.cover)
                        : null,
                  ),
                  child: form.data.picBase64 == null
                      ? const Icon(Icons.camera_alt_outlined,
                      color: Colors.grey, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text('Tap to add photo',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            const SizedBox(height: 14),

            // Student Name
            TextFormField(
              controller: form.nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Student Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Enter student name'
                  : null,
              onChanged: (v) => form.data.name = v,
            ),
            const SizedBox(height: 10),

            // Student ID
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border:
                      Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.fingerprint,
                            size: 18, color: _purple),
                        const SizedBox(width: 8),
                        const Text('Student ID: ',
                            style: TextStyle(
                                fontSize: 13, color: Colors.black54)),
                        Text(
                          form.data.studentId.isEmpty
                              ? '—'
                              : form.data.studentId,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _purple,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _generateStudentId(idx),
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text('Gen'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildClassSectionDropdown(idx, classes),
            const SizedBox(height: 10),

            TextFormField(
              controller: form.rollNoCtrl,
              decoration: const InputDecoration(
                labelText: 'Class Roll No (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: form.cnicCtrl,
              decoration: InputDecoration(
                labelText:
                'B-Form / CNIC${isPre ? ' (Optional)' : ' *'}',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.credit_card_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: isPre
                  ? null
                  : (v) => v == null || v.trim().isEmpty
                  ? 'Required'
                  : null,
            ),
            const SizedBox(height: 10),

            // DOB
            InkWell(
              onTap: () => _pickDate(
                  context,
                  form.data.dob ?? DateTime(2010),
                      (d) => setState(() => form.data.dob = d)),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined, size: 18),
                    const SizedBox(width: 10),
                    const Text('Date of Birth *',
                        style: TextStyle(
                            fontSize: 13, color: Colors.black54)),
                    const Spacer(),
                    Text(
                      form.data.dob != null
                          ? '${form.data.dob!.day.toString().padLeft(2, '0')}/'
                          '${form.data.dob!.month.toString().padLeft(2, '0')}/'
                          '${form.data.dob!.year}'
                          : 'Select Date',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: form.data.dob != null
                              ? Colors.black87
                              : Colors.grey),
                    ),
                    const Icon(Icons.edit_outlined,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            _buildFeesCard(idx, isPre),
          ],
        ),
      ),
    );
  }

  // ── Class + Section Dropdown ──
  Widget _buildClassSectionDropdown(
      int idx, List<SchoolClass> classes) {
    final form = _studentForms[idx];
    SchoolClass? selectedClass;
    if (form.data.classId != null) {
      try {
        selectedClass =
            classes.firstWhere((c) => c.id == form.data.classId);
      } catch (_) {}
    }
    final sections = selectedClass?.sections ?? [];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: form.data.classId,
          decoration: const InputDecoration(
            labelText: 'Class *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.class_),
          ),
          items: classes
              .map((c) =>
              DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: (val) async {
            setState(() {
              form.data.classId = val;
              form.data.className =
                  classes.firstWhere((c) => c.id == val).name;
              form.data.sectionId = null;
              form.data.sectionName = null;
            });
            await _fetchFees(idx);
          },
          validator: (v) => v == null ? 'Select class' : null,
        ),
        if (sections.isNotEmpty) ...[
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: form.data.sectionName,
            decoration: const InputDecoration(
              labelText: 'Section (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.group_outlined),
            ),
            items: sections
                .map((s) => DropdownMenuItem(
                value: s.sectionName, child: Text(s.sectionName)))
                .toList(),
            onChanged: (val) async {
              setState(() => form.data.sectionName = val);
              await _fetchFees(idx);
            },
          ),
        ],
      ],
    );
  }

  // ── Fees Card ──
  Widget _buildFeesCard(int idx, bool isPre) {
    final form = _studentForms[idx];
    return Card(
      color: Colors.grey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined, size: 16, color: _purple),
                const SizedBox(width: 6),
                Text(
                  isPre
                      ? 'Fee (fetched from class, editable)'
                      : 'Fee Structure *',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (form.loadingFees) ...[
                  const Spacer(),
                  const SizedBox(
                      width: 14,
                      height: 14,
                      child:
                      CircularProgressIndicator(strokeWidth: 2)),
                ],
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: form.annualFeeCtrl,
              decoration: const InputDecoration(
                labelText: 'Annual Fee',
                border: OutlineInputBorder(),
                prefixText: 'Rs ',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: form.registrationFeeCtrl,
              decoration: const InputDecoration(
                labelText: 'Registration Fee',
                border: OutlineInputBorder(),
                prefixText: 'Rs ',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: form.monthlyFeeCtrl,
              decoration: const InputDecoration(
                labelText: 'Monthly Fee',
                border: OutlineInputBorder(),
                prefixText: 'Rs ',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Student ──
  Widget _buildAddStudentButton() {
    return OutlinedButton.icon(
      onPressed: () =>
          setState(() => _studentForms.add(_StudentFormState())),
      icon: const Icon(Icons.person_add_outlined),
      label: const Text('+ Add More Student'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        foregroundColor: _purple,
        side: BorderSide(color: _purple),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Save Button ──
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSaving
          ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white))
          : Text(
        widget.existing == null
            ? 'Save Admission'
            : 'Update Admission',
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Helpers ──
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: _purple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _sectionSubTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(title,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.grey.shade700)),
  );

  Widget _field(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        bool required = true,
        TextInputType keyboard = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
          : null,
    );
  }
}