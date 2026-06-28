//
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../models/class_model.dart';
// import '../../models/teacher.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/subject_provider.dart';
// import '../../providers/teacher_provider.dart';
// import '../../services/firestore_service.dart';
//
// // ─── CNIC Formatter ───────────────────────────────────────────────────────────
// class _CnicFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
//     final limited = digits.length > 13 ? digits.substring(0, 13) : digits;
//     final buffer = StringBuffer();
//     for (int i = 0; i < limited.length; i++) {
//       if (i == 5 || i == 12) buffer.write('-');
//       buffer.write(limited[i]);
//     }
//     final formatted = buffer.toString();
//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }
//
// // ─── Constants ───────────────────────────────────────────────────────────────
// const _kPurple = Color(0xFF534AB7);
// const _kPurpleLight = Color(0xFFF0EFFE);
// const _kPurpleMid = Color(0xFF6C63D4);
//
// // ─── Subject Multi-Select ─────────────────────────────────────────────────────
// class _SubjectMultiSelect extends StatelessWidget {
//   final List<String> selectedSubjects;
//   final ValueChanged<List<String>> onChanged;
//   const _SubjectMultiSelect({
//     required this.selectedSubjects,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<MuddulProvider>();
//     final allSubjects =
//     provider.mudduls.map((m) => m.subjectName).toSet().toList()..sort();
//
//     if (provider.loading) {
//       return const Center(child: CircularProgressIndicator(strokeWidth: 2));
//     }
//     if (allSubjects.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.amber.shade50,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.amber.shade200),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
//             const SizedBox(width: 8),
//             const Expanded(
//               child: Text(
//                 'No subjects found. Add subjects first.',
//                 style: TextStyle(fontSize: 12, color: Colors.amber),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Wrap(
//       spacing: 8,
//       runSpacing: 6,
//       children: allSubjects.map((subject) {
//         final isSelected = selectedSubjects.contains(subject);
//         return GestureDetector(
//           onTap: () {
//             final updated = List<String>.from(selectedSubjects);
//             isSelected ? updated.remove(subject) : updated.add(subject);
//             onChanged(updated);
//           },
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             padding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//             decoration: BoxDecoration(
//               color: isSelected ? _kPurple : Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: isSelected ? _kPurple : Colors.grey.shade300,
//                 width: isSelected ? 1.5 : 0.8,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (isSelected) ...[
//                   const Icon(Icons.check, size: 14, color: Colors.white),
//                   const SizedBox(width: 4),
//                 ],
//                 Text(
//                   subject,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: isSelected ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
// // ─── Main Screen ──────────────────────────────────────────────────────────────
// class AddEditStaffScreen extends StatefulWidget {
//   final StaffMember? existingStaff;
//   final bool showAppBar;
//   final VoidCallback? onSaved;
//
//   const AddEditStaffScreen({
//     super.key,
//     this.existingStaff,
//     this.showAppBar = true,
//     this.onSaved,
//   });
//
//   @override
//   State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
// }
//
// class _AddEditStaffScreenState extends State<AddEditStaffScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _service = StaffFirestoreService();
//
//   // Controllers
//   final _nameCtrl = TextEditingController();
//   final _fatherOrHusbandCtrl = TextEditingController();
//   final _cnicCtrl = TextEditingController();
//   final _religionCtrl = TextEditingController();
//   final _nationalityCtrl = TextEditingController();
//   final _addressCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _emergencyPhoneCtrl = TextEditingController();
//   final _salaryCtrl = TextEditingController();
//   final _referenceCtrl = TextEditingController();
//   final _noteCtrl = TextEditingController();
//   final _designationCtrl = TextEditingController();
//
//   // State
//   String _type = 'staff';
//   String _gender = 'Male';
//   String _maritalStatus = 'Single';
//   String? _bloodGroup;
//   String _employmentType = 'Regular';
//   String _dob = '';
//   String _joiningDate = '';
//   List<String> _assignedClasses = [];
//   List<String> _subjects = [];
//   Uint8List? _imageBytes;
//   String? _existingImageBase64;
//   bool _isSaving = false;
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
//     final s = widget.existingStaff;
//     if (s != null) {
//       _type = s.type;
//       _nameCtrl.text = s.name;
//       _fatherOrHusbandCtrl.text = s.fatherOrHusbandName;
//       _cnicCtrl.text = s.cnic;
//       _dob = s.dob;
//       _gender = s.gender;
//       _maritalStatus = s.maritalStatus;
//       _bloodGroup = s.bloodGroup;
//       _religionCtrl.text = s.religion;
//       _nationalityCtrl.text = s.nationality;
//       _addressCtrl.text = s.address;
//       _phoneCtrl.text = s.phone;
//       _emergencyPhoneCtrl.text = s.emergencyPhone;
//       _employmentType = s.employmentType;
//       _salaryCtrl.text = s.salary.toString();
//       _referenceCtrl.text = s.reference ?? '';
//       _noteCtrl.text = s.note ?? '';
//       _designationCtrl.text = s.designation ?? '';
//       _existingImageBase64 = s.imageBase64;
//       _assignedClasses = List<String>.from(s.assignedClasses);
//       _subjects = List<String>.from(s.subjects);
//       _joiningDate = s.joiningDate ?? '';
//     } else {
//       _joiningDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _fatherOrHusbandCtrl.dispose();
//     _cnicCtrl.dispose();
//     _religionCtrl.dispose();
//     _nationalityCtrl.dispose();
//     _addressCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emergencyPhoneCtrl.dispose();
//     _salaryCtrl.dispose();
//     _referenceCtrl.dispose();
//     _noteCtrl.dispose();
//     _designationCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//     final rawBytes = await picked.readAsBytes();
//
//     Uint8List? finalBytes;
//     if (kIsWeb) {
//       finalBytes = rawBytes;
//     } else {
//       final compressed = await _compressToBytes(rawBytes);
//       finalBytes = compressed;
//     }
//
//     if (finalBytes != null && mounted) {
//       setState(() {
//         _imageBytes = finalBytes;
//         _existingImageBase64 = null;
//       });
//     }
//   }
//
//   Future<Uint8List?> _compressToBytes(Uint8List rawBytes) async {
//     try {
//       final original = img.decodeImage(rawBytes);
//       if (original == null) return null;
//       final thumbnail = original.width >= original.height
//           ? img.copyResize(original, width: 300)
//           : img.copyResize(original, height: 300);
//       final jpegBytes = img.encodeJpg(thumbnail, quality: 70);
//       if (jpegBytes.length > 100 * 1024) {
//         return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 40));
//       }
//       return Uint8List.fromList(jpegBytes);
//     } catch (e) {
//       debugPrint('Image compression failed: $e');
//       return null;
//     }
//   }
//
//   Future<void> _pickDob() async {
//     final now = DateTime.now();
//     final initialDate = _dob.isNotEmpty
//         ? DateFormat('yyyy-MM-dd').parse(_dob)
//         : DateTime(now.year - 20, 1, 1);
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
//       setState(() => _joiningDate = DateFormat('yyyy-MM-dd').format(picked));
//     }
//   }
//
//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSaving = true);
//
//     String? base64Image = _existingImageBase64;
//     if (_imageBytes != null) {
//       base64Image = base64Encode(_imageBytes!);
//     }
//
//     final staff = StaffMember(
//       id: widget.existingStaff?.id,
//       type: _type,
//       name: _nameCtrl.text.trim(),
//       fatherOrHusbandName: _fatherOrHusbandCtrl.text.trim(),
//       cnic: _cnicCtrl.text.trim(),
//       dob: _dob,
//       gender: _gender,
//       maritalStatus: _maritalStatus,
//       bloodGroup: _bloodGroup,
//       religion: _religionCtrl.text.trim(),
//       nationality: _nationalityCtrl.text.trim(),
//       address: _addressCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       emergencyPhone: _emergencyPhoneCtrl.text.trim(),
//       employmentType: _employmentType,
//       salary: double.tryParse(_salaryCtrl.text) ?? 0,
//       reference: _referenceCtrl.text.trim().isEmpty
//           ? null
//           : _referenceCtrl.text.trim(),
//       note:
//       _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
//       designation: _designationCtrl.text.trim().isEmpty
//           ? null
//           : _designationCtrl.text.trim(),
//       joiningDate: _joiningDate.isEmpty ? null : _joiningDate,
//       imageBase64: base64Image,
//       assignedClasses: _assignedClasses,
//       subjects: _subjects,
//     );
//
//     final provider = context.read<StaffProvider>();
//     try {
//       if (widget.existingStaff == null) {
//         await provider.addStaff(staff);
//       } else {
//         await provider.updateStaff(widget.existingStaff!.id!, staff);
//       }
//       if (mounted) {
//         if (widget.onSaved != null) {
//           widget.onSaved!();
//         } else {
//           Navigator.pop(context, true);
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//
//   // ── Helpers ──────────────────────────────────────────────────────────────
//
//   ImageProvider? get _currentImage {
//     if (_imageBytes != null) return MemoryImage(_imageBytes!);
//     if (_existingImageBase64 != null)
//       return MemoryImage(base64Decode(_existingImageBase64!));
//     return null;
//   }
//
//   String get _initials {
//     final name = _nameCtrl.text.trim();
//     if (name.isEmpty) return '?';
//     final parts = name.split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return name[0].toUpperCase();
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // MOBILE LAYOUT
//   // ─────────────────────────────────────────────────────────────────────────
//   Widget _buildMobileLayout(bool isEdit) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: _kPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           isEdit
//               ? 'Edit ${_type == 'teacher' ? 'Teacher' : 'Staff'}'
//               : 'Add Staff / Teacher',
//           style: const TextStyle(
//               fontWeight: FontWeight.w600, fontSize: 17),
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               // Profile photo + type toggle
//               _buildMobileProfileHeader(),
//               const SizedBox(height: 16),
//
//               // Sections
//               _mobileSection('Assigned Classes', Icons.class_outlined, [
//                 _buildClassChips(),
//               ]),
//               _mobileSection(
//                   'Personal Information', Icons.person_outline, [
//                 _mobileField(
//                   label: 'Full Name',
//                   controller: _nameCtrl,
//                   required: true,
//                   onChanged: (_) => setState(() {}),
//                 ),
//                 _mobileField(
//                   label: 'Designation',
//                   controller: _designationCtrl,
//                   hint: 'e.g. Principal, Head Teacher...',
//                   icon: Icons.badge_outlined,
//                 ),
//                 _mobileField(
//                   label: _maritalStatus == 'Married'
//                       ? 'Husband Name'
//                       : 'Father Name',
//                   controller: _fatherOrHusbandCtrl,
//                   required: true,
//                 ),
//                 _mobileCnicField(),
//                 _mobileDateField(
//                   label: 'Date of Birth',
//                   value: _dob,
//                   onTap: _pickDob,
//                   required: true,
//                   validator: (_) => _dob.isEmpty
//                       ? 'Please select date of birth'
//                       : null,
//                 ),
//                 _mobileDateField(
//                   label: 'Joining Date',
//                   value: _joiningDate,
//                   onTap: _pickJoiningDate,
//                 ),
//                 _mobileDropdown<String>(
//                   label: 'Gender',
//                   value: _gender,
//                   items: _genderOptions,
//                   onChanged: (v) => setState(() => _gender = v!),
//                 ),
//                 _mobileDropdown<String>(
//                   label: 'Marital Status',
//                   value: _maritalStatus,
//                   items: _maritalOptions,
//                   onChanged: (v) => setState(() => _maritalStatus = v!),
//                 ),
//                 _mobileDropdown<String?>(
//                   label: 'Blood Group (Optional)',
//                   value: _bloodGroup,
//                   items: _bloodOptions,
//                   nullable: true,
//                   onChanged: (v) => setState(() => _bloodGroup = v),
//                 ),
//                 _mobileField(
//                     label: 'Religion',
//                     controller: _religionCtrl,
//                     required: true),
//                 _mobileField(
//                     label: 'Nationality',
//                     controller: _nationalityCtrl,
//                     required: true),
//               ]),
//               _mobileSection(
//                   'Contact Information', Icons.contact_phone_outlined, [
//                 _mobileField(
//                     label: 'Address',
//                     controller: _addressCtrl,
//                     required: true,
//                     maxLines: 3),
//                 _mobileField(
//                     label: 'Phone No',
//                     controller: _phoneCtrl,
//                     required: true,
//                     keyboard: TextInputType.phone),
//                 _mobileField(
//                     label: 'Emergency No',
//                     controller: _emergencyPhoneCtrl,
//                     required: true,
//                     keyboard: TextInputType.phone),
//               ]),
//               _mobileSection('Job Details', Icons.work_outline, [
//                 _mobileDropdown<String>(
//                   label: 'Employment Type',
//                   value: _employmentType,
//                   items: _employmentOptions,
//                   onChanged: (v) =>
//                       setState(() => _employmentType = v!),
//                 ),
//                 _mobileSalaryField(),
//               ]),
//               _mobileSection(
//                   'Assigned Subjects', Icons.menu_book_outlined, [
//                 _SubjectMultiSelect(
//                   selectedSubjects: _subjects,
//                   onChanged: (v) => setState(() => _subjects = v),
//                 ),
//               ]),
//               _mobileSection(
//                   'Additional Info', Icons.info_outline, [
//                 _mobileField(
//                     label: 'Reference', controller: _referenceCtrl),
//                 _mobileField(
//                     label: 'Note',
//                     controller: _noteCtrl,
//                     maxLines: 3),
//               ]),
//               const SizedBox(height: 24),
//               _buildSaveButton(isEdit),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMobileProfileHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [_kPurple, _kPurpleMid],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           // Avatar
//           GestureDetector(
//             onTap: _pickImage,
//             child: Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 44,
//                   backgroundColor: Colors.white.withOpacity(0.25),
//                   backgroundImage: _currentImage,
//                   child: _currentImage == null
//                       ? Text(
//                     _initials,
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   )
//                       : null,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                           color: _kPurple, width: 2),
//                     ),
//                     child: const Icon(Icons.camera_alt,
//                         size: 14, color: _kPurple),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           // Staff / Teacher toggle
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: _typeOptions.map((t) {
//                 final selected = _type == t;
//                 return GestureDetector(
//                   onTap: () => setState(() => _type = t),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 24, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: selected
//                           ? Colors.white
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Text(
//                       t == 'teacher' ? 'Teacher' : 'Staff',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                         color: selected
//                             ? _kPurple
//                             : Colors.white,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _mobileSection(
//       String title, IconData icon, List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Theme(
//         data: Theme.of(context)
//             .copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           initiallyExpanded: true,
//           leading: Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               color: _kPurpleLight,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, size: 18, color: _kPurple),
//           ),
//           title: Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//               color: Color(0xFF1A1A2E),
//             ),
//           ),
//           iconColor: _kPurple,
//           collapsedIconColor: Colors.grey,
//           children: [
//             Padding(
//               padding:
//               const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: _withSpacing(children, 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // DESKTOP LAYOUT
//   // ─────────────────────────────────────────────────────────────────────────
//   Widget _buildDesktopLayout(bool isEdit) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F8),
//       body: Form(
//         key: _formKey,
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Left Panel (sticky) ──
//             SizedBox(
//               width: 280,
//               child: Container(
//                 height: double.infinity,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [_kPurple, _kPurpleMid],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 32, horizontal: 24),
//                   child: Column(
//                     children: [
//                       // Back
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: TextButton.icon(
//                           onPressed: () => Navigator.pop(context),
//                           icon: const Icon(
//                               Icons.arrow_back_ios_new_rounded,
//                               size: 14,
//                               color: Colors.white70),
//                           label: const Text('Back',
//                               style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 13)),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       // Avatar
//                       GestureDetector(
//                         onTap: _pickImage,
//                         child: Stack(
//                           children: [
//                             CircleAvatar(
//                               radius: 56,
//                               backgroundColor:
//                               Colors.white.withOpacity(0.25),
//                               backgroundImage: _currentImage,
//                               child: _currentImage == null
//                                   ? Text(
//                                 _initials,
//                                 style: const TextStyle(
//                                   fontSize: 36,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               )
//                                   : null,
//                             ),
//                             Positioned(
//                               bottom: 4,
//                               right: 4,
//                               child: Container(
//                                 width: 32,
//                                 height: 32,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                       color: _kPurple, width: 2),
//                                 ),
//                                 child: const Icon(Icons.camera_alt,
//                                     size: 16, color: _kPurple),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         'Tap to change photo',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.6),
//                           fontSize: 11,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       // Name preview
//                       ListenableBuilder(
//                         listenable: _nameCtrl,
//                         builder: (context, _) => Text(
//                           _nameCtrl.text.trim().isEmpty
//                               ? 'Full Name'
//                               : _nameCtrl.text.trim(),
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       ListenableBuilder(
//                         listenable: _designationCtrl,
//                         builder: (context, _) =>
//                         _designationCtrl.text.trim().isEmpty
//                             ? const SizedBox()
//                             : Padding(
//                           padding:
//                           const EdgeInsets.only(top: 4),
//                           child: Text(
//                             _designationCtrl.text.trim(),
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white
//                                   .withOpacity(0.75),
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       // Staff / Teacher toggle
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: _typeOptions.map((t) {
//                             final selected = _type == t;
//                             return GestureDetector(
//                               onTap: () => setState(() => _type = t),
//                               child: AnimatedContainer(
//                                 duration:
//                                 const Duration(milliseconds: 200),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 8),
//                                 decoration: BoxDecoration(
//                                   color: selected
//                                       ? Colors.white
//                                       : Colors.transparent,
//                                   borderRadius:
//                                   BorderRadius.circular(30),
//                                 ),
//                                 child: Text(
//                                   t == 'teacher'
//                                       ? 'Teacher'
//                                       : 'Staff',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 13,
//                                     color: selected
//                                         ? _kPurple
//                                         : Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                       const SizedBox(height: 28),
//                       const Divider(color: Colors.white24),
//                       const SizedBox(height: 16),
//                       // Quick info pills
//                       _leftInfoRow(
//                           Icons.calendar_today_outlined, _joiningDate.isEmpty
//                           ? 'Joining: —'
//                           : 'Joined: $_joiningDate'),
//                       const SizedBox(height: 10),
//                       _leftInfoRow(Icons.work_outline, _employmentType),
//                       const SizedBox(height: 10),
//                       _leftInfoRow(Icons.person_outline, _gender),
//                       if (_bloodGroup != null) ...[
//                         const SizedBox(height: 10),
//                         _leftInfoRow(
//                             Icons.bloodtype_outlined, _bloodGroup!),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // ── Right Panel (scrollable) ──
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(28),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Text(
//                       isEdit
//                           ? 'Edit ${_type == 'teacher' ? 'Teacher' : 'Staff'} Profile'
//                           : 'Add New ${_type == 'teacher' ? 'Teacher' : 'Staff Member'}',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1A1A2E),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       isEdit
//                           ? 'Update the information below'
//                           : 'Fill in the details below to add a new member',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//
//                     // ── Assigned Classes ──
//                     _desktopSection(
//                       'Assigned Classes',
//                       Icons.class_outlined,
//                       [
//                         _buildClassChips(),
//                       ],
//                     ),
//
//                     // ── Personal Information ──
//                     _desktopSection(
//                       'Personal Information',
//                       Icons.person_outline,
//                       [
//                         _desktopRow([
//                           _deskField(
//                             label: 'Full Name *',
//                             controller: _nameCtrl,
//                             validator: (v) => v == null ||
//                                 v.trim().isEmpty
//                                 ? 'Required'
//                                 : null,
//                             onChanged: (_) => setState(() {}),
//                           ),
//                           _deskField(
//                             label: 'Designation (Optional)',
//                             controller: _designationCtrl,
//                             hint: 'e.g. Principal, Head Teacher...',
//                             prefixIcon: Icons.badge_outlined,
//                             onChanged: (_) => setState(() {}),
//                           ),
//                         ]),
//                         _desktopRow([
//                           _deskField(
//                             label: _maritalStatus == 'Married'
//                                 ? 'Husband Name *'
//                                 : 'Father Name *',
//                             controller: _fatherOrHusbandCtrl,
//                             validator: (v) => v == null ||
//                                 v.trim().isEmpty
//                                 ? 'Required'
//                                 : null,
//                           ),
//                           _deskCnicField(),
//                         ]),
//                         _desktopRow([
//                           _deskDateField(
//                             label: 'Date of Birth *',
//                             value: _dob,
//                             onTap: _pickDob,
//                             validator: (_) => _dob.isEmpty
//                                 ? 'Please select date of birth'
//                                 : null,
//                           ),
//                           _deskDateField(
//                             label: 'Joining Date',
//                             value: _joiningDate,
//                             onTap: _pickJoiningDate,
//                           ),
//                         ]),
//                         _desktopRow([
//                           _deskDropdown<String>(
//                             label: 'Gender *',
//                             value: _gender,
//                             items: _genderOptions,
//                             onChanged: (v) =>
//                                 setState(() => _gender = v!),
//                           ),
//                           _deskDropdown<String>(
//                             label: 'Marital Status *',
//                             value: _maritalStatus,
//                             items: _maritalOptions,
//                             onChanged: (v) =>
//                                 setState(() => _maritalStatus = v!),
//                           ),
//                         ]),
//                         _desktopRow([
//                           _deskDropdown<String?>(
//                             label: 'Blood Group (Optional)',
//                             value: _bloodGroup,
//                             items: _bloodOptions,
//                             nullable: true,
//                             onChanged: (v) =>
//                                 setState(() => _bloodGroup = v),
//                           ),
//                           _deskField(
//                             label: 'Religion *',
//                             controller: _religionCtrl,
//                             validator: (v) => v == null ||
//                                 v.trim().isEmpty
//                                 ? 'Required'
//                                 : null,
//                           ),
//                         ]),
//                         _deskField(
//                           label: 'Nationality *',
//                           controller: _nationalityCtrl,
//                           validator: (v) => v == null ||
//                               v.trim().isEmpty
//                               ? 'Required'
//                               : null,
//                         ),
//                       ],
//                     ),
//
//                     // ── Contact Information ──
//                     _desktopSection(
//                       'Contact Information',
//                       Icons.contact_phone_outlined,
//                       [
//                         _deskField(
//                           label: 'Address *',
//                           controller: _addressCtrl,
//                           maxLines: 2,
//                           validator: (v) => v == null ||
//                               v.trim().isEmpty
//                               ? 'Required'
//                               : null,
//                         ),
//                         _desktopRow([
//                           _deskField(
//                             label: 'Phone No *',
//                             controller: _phoneCtrl,
//                             keyboard: TextInputType.phone,
//                             validator: (v) => v == null ||
//                                 v.trim().isEmpty
//                                 ? 'Required'
//                                 : null,
//                           ),
//                           _deskField(
//                             label: 'Emergency No *',
//                             controller: _emergencyPhoneCtrl,
//                             keyboard: TextInputType.phone,
//                             validator: (v) => v == null ||
//                                 v.trim().isEmpty
//                                 ? 'Required'
//                                 : null,
//                           ),
//                         ]),
//                       ],
//                     ),
//
//                     // ── Job Details ──
//                     _desktopSection(
//                       'Job Details',
//                       Icons.work_outline,
//                       [
//                         _desktopRow([
//                           _deskDropdown<String>(
//                             label: 'Employment Type *',
//                             value: _employmentType,
//                             items: _employmentOptions,
//                             onChanged: (v) => setState(
//                                     () => _employmentType = v!),
//                           ),
//                           _deskSalaryField(),
//                         ]),
//                       ],
//                     ),
//
//                     // ── Assigned Subjects ──
//                     _desktopSection(
//                       'Assigned Subjects (Optional)',
//                       Icons.menu_book_outlined,
//                       [
//                         _SubjectMultiSelect(
//                           selectedSubjects: _subjects,
//                           onChanged: (v) =>
//                               setState(() => _subjects = v),
//                         ),
//                       ],
//                     ),
//
//                     // ── Additional Info ──
//                     _desktopSection(
//                       'Additional Info (Optional)',
//                       Icons.info_outline,
//                       [
//                         _desktopRow([
//                           _deskField(
//                               label: 'Reference',
//                               controller: _referenceCtrl),
//                           _deskField(
//                               label: 'Note',
//                               controller: _noteCtrl,
//                               maxLines: 3),
//                         ]),
//                       ],
//                     ),
//
//                     const SizedBox(height: 8),
//                     // Save button row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         OutlinedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(color: _kPurple),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 28, vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: const Text('Cancel',
//                               style: TextStyle(color: _kPurple)),
//                         ),
//                         const SizedBox(width: 12),
//                         SizedBox(
//                           width: 160,
//                           height: 48,
//                           child: _buildSaveButton(isEdit),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _desktopSection(
//       String title, IconData icon, List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//             decoration: BoxDecoration(
//               color: _kPurpleLight,
//               borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(14)),
//             ),
//             child: Row(
//               children: [
//                 Icon(icon, size: 18, color: _kPurple),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14,
//                     color: _kPurple,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: _withSpacing(children, 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _desktopRow(List<Widget> children) {
//     return Row(
//       children: children
//           .map((w) => Expanded(child: w))
//           .expand((w) => [w, const SizedBox(width: 14)])
//           .toList()
//         ..removeLast(),
//     );
//   }
//
//   // ─── Desktop Field Helpers ─────────────────────────────────────────────────
//   Widget _deskField({
//     required String label,
//     required TextEditingController controller,
//     String? hint,
//     IconData? prefixIcon,
//     int maxLines = 1,
//     TextInputType? keyboard,
//     FormFieldValidator<String>? validator,
//     ValueChanged<String>? onChanged,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboard,
//       decoration: _inputDeco(label, hint: hint, icon: prefixIcon),
//       validator: validator,
//       onChanged: onChanged,
//     );
//   }
//
//   Widget _deskCnicField() {
//     return TextFormField(
//       controller: _cnicCtrl,
//       keyboardType: TextInputType.number,
//       maxLength: 15,
//       inputFormatters: [_CnicFormatter()],
//       decoration: _inputDeco('CNIC * (e.g., 34101-1234567-8)')
//           .copyWith(counterText: ''),
//       validator: (v) {
//         if (v == null || v.trim().isEmpty) return 'Required';
//         final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
//         if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
//         return null;
//       },
//     );
//   }
//
//   Widget _deskDateField({
//     required String label,
//     required String value,
//     required VoidCallback onTap,
//     FormFieldValidator<String>? validator,
//   }) {
//     return TextFormField(
//       readOnly: true,
//       controller: TextEditingController(text: value),
//       decoration: _inputDeco(label).copyWith(
//         suffixIcon:
//         const Icon(Icons.calendar_today, size: 18, color: _kPurple),
//       ),
//       onTap: onTap,
//       validator: validator,
//     );
//   }
//
//   Widget _deskDropdown<T>({
//     required String label,
//     required T value,
//     required List<String> items,
//     required ValueChanged<T?> onChanged,
//     bool nullable = false,
//   }) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       decoration: _inputDeco(label),
//       items: [
//         if (nullable)
//           const DropdownMenuItem(
//               value: null, child: Text('Select (Optional)')) as DropdownMenuItem<T>,
//         ...items.map((i) =>
//             DropdownMenuItem<T>(value: i as T, child: Text(i))),
//       ],
//       onChanged: onChanged,
//     );
//   }
//
//   Widget _deskSalaryField() {
//     return TextFormField(
//       controller: _salaryCtrl,
//       decoration:
//       _inputDeco('Salary *').copyWith(prefixText: 'Rs  '),
//       keyboardType: TextInputType.number,
//       validator: (v) =>
//       v == null || v.trim().isEmpty ? 'Required' : null,
//     );
//   }
//
//   // ─── Mobile Field Helpers ──────────────────────────────────────────────────
//   Widget _mobileField({
//     required String label,
//     required TextEditingController controller,
//     String? hint,
//     IconData? icon,
//     int maxLines = 1,
//     bool required = false,
//     TextInputType? keyboard,
//     ValueChanged<String>? onChanged,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboard,
//       onChanged: onChanged,
//       decoration: _inputDeco(required ? '$label *' : label,
//           hint: hint, icon: icon),
//       validator: required
//           ? (v) =>
//       v == null || v.trim().isEmpty ? 'Required' : null
//           : null,
//     );
//   }
//
//   Widget _mobileCnicField() {
//     return TextFormField(
//       controller: _cnicCtrl,
//       decoration:
//       _inputDeco('CNIC * (e.g., 34101-1234567-8)').copyWith(
//         counterText: '',
//       ),
//       keyboardType: TextInputType.number,
//       maxLength: 15,
//       inputFormatters: [_CnicFormatter()],
//       validator: (v) {
//         if (v == null || v.trim().isEmpty) return 'Required';
//         final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
//         if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
//         return null;
//       },
//     );
//   }
//
//   Widget _mobileSalaryField() {
//     return TextFormField(
//       controller: _salaryCtrl,
//       decoration: _inputDeco('Salary *').copyWith(prefixText: 'Rs  '),
//       keyboardType: TextInputType.number,
//       validator: (v) =>
//       v == null || v.trim().isEmpty ? 'Required' : null,
//     );
//   }
//
//   Widget _mobileDateField({
//     required String label,
//     required String value,
//     required VoidCallback onTap,
//     bool required = false,
//     FormFieldValidator<String>? validator,
//   }) {
//     return TextFormField(
//       readOnly: true,
//       controller: TextEditingController(text: value),
//       decoration: _inputDeco(required ? '$label *' : label).copyWith(
//         suffixIcon:
//         const Icon(Icons.calendar_today, size: 18, color: _kPurple),
//       ),
//       onTap: onTap,
//       validator: validator,
//     );
//   }
//
//   Widget _mobileDropdown<T>({
//     required String label,
//     required T value,
//     required List<String> items,
//     required ValueChanged<T?> onChanged,
//     bool nullable = false,
//   }) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       decoration: _inputDeco(label),
//       items: [
//         if (nullable)
//           const DropdownMenuItem(
//               value: null,
//               child: Text('Select (Optional)')) as DropdownMenuItem<T>,
//         ...items.map((i) =>
//             DropdownMenuItem<T>(value: i as T, child: Text(i))),
//       ],
//       onChanged: onChanged,
//     );
//   }
//
//   // ─── Class Chips (shared) ──────────────────────────────────────────────────
//   Widget _buildClassChips() {
//     return Consumer<ClassProvider>(
//       builder: (context, classProvider, _) {
//         final classes = classProvider.classes;
//         if (classes.isEmpty) {
//           return Text('No classes found.',
//               style: TextStyle(color: Colors.grey.shade500, fontSize: 13));
//         }
//         return Wrap(
//           spacing: 8,
//           runSpacing: 6,
//           children: classes.map((cls) {
//             final isSelected = _assignedClasses.contains(cls.id);
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (isSelected) {
//                     _assignedClasses.remove(cls.id);
//                   } else {
//                     _assignedClasses.add(cls.id!);
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
//                     color: isSelected
//                         ? _kPurple
//                         : Colors.grey.shade300,
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
//                       cls.name,
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
//   // ─── Shared Helpers ────────────────────────────────────────────────────────
//   InputDecoration _inputDeco(String label,
//       {String? hint, IconData? icon}) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       prefixIcon: icon != null ? Icon(icon, size: 18) : null,
//       labelStyle: const TextStyle(fontSize: 13),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: _kPurple, width: 1.5),
//       ),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//     );
//   }
//
//   Widget _leftInfoRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.white60),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(color: Colors.white, fontSize: 13),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSaveButton(bool isEdit) {
//     return ElevatedButton(
//       onPressed: _isSaving ? null : _save,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _kPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10)),
//         padding:
//         const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//       ),
//       child: _isSaving
//           ? const SizedBox(
//           height: 20,
//           width: 20,
//           child: CircularProgressIndicator(
//               strokeWidth: 2, color: Colors.white))
//           : Text(
//         isEdit ? 'Update' : 'Save',
//         style: const TextStyle(
//             fontWeight: FontWeight.w600, fontSize: 15),
//       ),
//     );
//   }
//
//   List<Widget> _withSpacing(List<Widget> children, double spacing) {
//     final result = <Widget>[];
//     for (int i = 0; i < children.length; i++) {
//       result.add(children[i]);
//       if (i < children.length - 1) result.add(SizedBox(height: spacing));
//     }
//     return result;
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.existingStaff != null;
//     final isDesktop = MediaQuery.of(context).size.width >= 720;
//
//     if (isDesktop) return _buildDesktopLayout(isEdit);
//     return _buildMobileLayout(isEdit);
//   }
// }

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/class_model.dart';
import '../../models/teacher.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../services/firestore_service.dart';

// ─── CNIC Formatter ───────────────────────────────────────────────────────────
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

// ─── Constants ───────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleMid = Color(0xFF6C63D4);

// ─── Subject Multi-Select ─────────────────────────────────────────────────────
class _SubjectMultiSelect extends StatelessWidget {
  final List<String> selectedSubjects;
  final ValueChanged<List<String>> onChanged;
  const _SubjectMultiSelect({
    required this.selectedSubjects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MuddulProvider>();
    final allSubjects =
    provider.mudduls.map((m) => m.subjectName).toSet().toList()..sort();

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
            isSelected ? updated.remove(subject) : updated.add(subject);
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AddEditStaffScreen extends StatefulWidget {
  final StaffMember? existingStaff;
  final bool showAppBar;
  final VoidCallback? onSaved;
  final String? initialType;                    // ← NEW


  const AddEditStaffScreen({
    super.key,
    this.existingStaff,
    this.showAppBar = true,
    this.onSaved,
    this.initialType,                           // ← NEW

  });

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
  final _designationCtrl = TextEditingController();

  // State
  String _type = 'staff';
  String _gender = 'Male';
  String _maritalStatus = 'Single';
  String? _bloodGroup;
  String _employmentType = 'Regular';
  String _dob = '';
  String _joiningDate = '';
  List<String> _assignedClasses = [];
  List<String> _assignedSections = [];  // NEW: stores full section names
  List<String> _subjects = [];
  Uint8List? _imageBytes;
  String? _existingImageBase64;
  bool _isSaving = false;

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
    final s = widget.existingStaff;
    // Set initial type if provided (only for new staff, not editing)
    if (widget.initialType != null && s == null) {
      _type = widget.initialType!;
    }
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
      _designationCtrl.text = s.designation ?? '';
      _existingImageBase64 = s.imageBase64;
      _assignedClasses = List<String>.from(s.assignedClasses);
      _assignedSections = List<String>.from(s.assignedSections ?? []); // NEW
      _subjects = List<String>.from(s.subjects);
      _joiningDate = s.joiningDate ?? '';
    } else {
      _joiningDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
    _designationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final rawBytes = await picked.readAsBytes();

    Uint8List? finalBytes;
    if (kIsWeb) {
      finalBytes = rawBytes;
    } else {
      final compressed = await _compressToBytes(rawBytes);
      finalBytes = compressed;
    }

    if (finalBytes != null && mounted) {
      setState(() {
        _imageBytes = finalBytes;
        _existingImageBase64 = null;
      });
    }
  }

  Future<Uint8List?> _compressToBytes(Uint8List rawBytes) async {
    try {
      final original = img.decodeImage(rawBytes);
      if (original == null) return null;
      final thumbnail = original.width >= original.height
          ? img.copyResize(original, width: 300)
          : img.copyResize(original, height: 300);
      final jpegBytes = img.encodeJpg(thumbnail, quality: 70);
      if (jpegBytes.length > 100 * 1024) {
        return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 40));
      }
      return Uint8List.fromList(jpegBytes);
    } catch (e) {
      debugPrint('Image compression failed: $e');
      return null;
    }
  }

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
      setState(() => _joiningDate = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // NEW VALIDATION: if any class is assigned, at least one section must be chosen
    if (_assignedClasses.isNotEmpty && _assignedSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one section for the assigned class(es).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? base64Image = _existingImageBase64;
    if (_imageBytes != null) {
      base64Image = base64Encode(_imageBytes!);
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
      reference: _referenceCtrl.text.trim().isEmpty
          ? null
          : _referenceCtrl.text.trim(),
      note:
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      designation: _designationCtrl.text.trim().isEmpty
          ? null
          : _designationCtrl.text.trim(),
      joiningDate: _joiningDate.isEmpty ? null : _joiningDate,
      imageBase64: base64Image,
      assignedClasses: _assignedClasses,
      assignedSections: _assignedSections,  // NEW
      subjects: _subjects,
    );

    final provider = context.read<StaffProvider>();
    try {
      if (widget.existingStaff == null) {
        await provider.addStaff(staff);
      } else {
        await provider.updateStaff(widget.existingStaff!.id!, staff);
      }
      if (mounted) {
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  ImageProvider? get _currentImage {
    if (_imageBytes != null) return MemoryImage(_imageBytes!);
    if (_existingImageBase64 != null)
      return MemoryImage(base64Decode(_existingImageBase64!));
    return null;
  }

  String get _initials {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NEW: Class & Section selector widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildClassSectionSelector() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, _) {
        final classes = classProvider.classes;
        if (classes.isEmpty) {
          return Text('No classes found.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Existing class chips
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
                        // Remove all sections belonging to this class
                        _assignedSections.removeWhere(
                              (sec) => sec.startsWith(cls.name + ' section '),
                        );
                      } else {
                        _assignedClasses.add(cls.id!);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                          const Icon(Icons.check, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          cls.name,
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

            // For each selected class, show its sections
            if (_assignedClasses.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Select sections for assigned classes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kPurple,
                ),
              ),
              const SizedBox(height: 8),
              ..._assignedClasses.map((classId) {
                final cls = classes.firstWhere((c) => c.id == classId);
                return _buildSectionChipsForClass(cls);
              }),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionChipsForClass(SchoolClass cls) {
    // Get sections of this class
    final sections = cls.sections ?? [];
    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: Colors.orange.shade400),
            const SizedBox(width: 6),
            Text(
              '${cls.name} has no sections defined',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cls.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: sections.map((section) {
              // The section's full name (e.g., "Grade 5 section A")
              final sectionName = section.sectionName;
              final isSelected = _assignedSections.contains(sectionName);
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                        const Icon(Icons.check, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        sectionName,
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
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOBILE LAYOUT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(bool isEdit) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit
              ? 'Edit ${_type == 'teacher' ? 'Teacher' : 'Staff'}'
              : 'Add Staff / Teacher',
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile photo + type toggle
              _buildMobileProfileHeader(),
              const SizedBox(height: 16),

              // Sections
              _mobileSection('Assigned Classes', Icons.class_outlined, [
                _buildClassSectionSelector(),  // ← updated widget
              ]),
              _mobileSection(
                  'Personal Information', Icons.person_outline, [
                _mobileField(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  required: true,
                  onChanged: (_) => setState(() {}),
                ),
                _mobileField(
                  label: 'Designation',
                  controller: _designationCtrl,
                  hint: 'e.g. Principal, Head Teacher...',
                  icon: Icons.badge_outlined,
                ),
                _mobileField(
                  label: _maritalStatus == 'Married'
                      ? 'Husband Name'
                      : 'Father Name',
                  controller: _fatherOrHusbandCtrl,
                  required: true,
                ),
                _mobileCnicField(),
                _mobileDateField(
                  label: 'Date of Birth',
                  value: _dob,
                  onTap: _pickDob,
                  required: true,
                  validator: (_) => _dob.isEmpty
                      ? 'Please select date of birth'
                      : null,
                ),
                _mobileDateField(
                  label: 'Joining Date',
                  value: _joiningDate,
                  onTap: _pickJoiningDate,
                ),
                _mobileDropdown<String>(
                  label: 'Gender',
                  value: _gender,
                  items: _genderOptions,
                  onChanged: (v) => setState(() => _gender = v!),
                ),
                _mobileDropdown<String>(
                  label: 'Marital Status',
                  value: _maritalStatus,
                  items: _maritalOptions,
                  onChanged: (v) => setState(() => _maritalStatus = v!),
                ),
                _mobileDropdown<String?>(
                  label: 'Blood Group (Optional)',
                  value: _bloodGroup,
                  items: _bloodOptions,
                  nullable: true,
                  onChanged: (v) => setState(() => _bloodGroup = v),
                ),
                _mobileField(
                    label: 'Religion',
                    controller: _religionCtrl,
                    required: true),
                _mobileField(
                    label: 'Nationality',
                    controller: _nationalityCtrl,
                    required: true),
              ]),
              _mobileSection(
                  'Contact Information', Icons.contact_phone_outlined, [
                _mobileField(
                    label: 'Address',
                    controller: _addressCtrl,
                    required: true,
                    maxLines: 3),
                _mobileField(
                    label: 'Phone No',
                    controller: _phoneCtrl,
                    required: true,
                    keyboard: TextInputType.phone),
                _mobileField(
                    label: 'Emergency No',
                    controller: _emergencyPhoneCtrl,
                    required: true,
                    keyboard: TextInputType.phone),
              ]),
              _mobileSection('Job Details', Icons.work_outline, [
                _mobileDropdown<String>(
                  label: 'Employment Type',
                  value: _employmentType,
                  items: _employmentOptions,
                  onChanged: (v) =>
                      setState(() => _employmentType = v!),
                ),
                _mobileSalaryField(),
              ]),
              _mobileSection(
                  'Assigned Subjects', Icons.menu_book_outlined, [
                _SubjectMultiSelect(
                  selectedSubjects: _subjects,
                  onChanged: (v) => setState(() => _subjects = v),
                ),
              ]),
              _mobileSection(
                  'Additional Info', Icons.info_outline, [
                _mobileField(
                    label: 'Reference', controller: _referenceCtrl),
                _mobileField(
                    label: 'Note',
                    controller: _noteCtrl,
                    maxLines: 3),
              ]),
              const SizedBox(height: 24),
              _buildSaveButton(isEdit),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPurple, _kPurpleMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  backgroundImage: _currentImage,
                  child: _currentImage == null
                      ? Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _kPurple, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: _kPurple),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Staff / Teacher toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _typeOptions.map((t) {
                final selected = _type == t;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      t == 'teacher' ? 'Teacher' : 'Staff',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: selected
                            ? _kPurple
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _kPurpleLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: _kPurple),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
          iconColor: _kPurple,
          collapsedIconColor: Colors.grey,
          children: [
            Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _withSpacing(children, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DESKTOP LAYOUT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(bool isEdit) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left Panel (sticky) ──
            SizedBox(
              width: 280,
              child: Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kPurple, _kPurpleMid],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32, horizontal: 24),
                  child: Column(
                    children: [
                      // Back
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 14,
                              color: Colors.white70),
                          label: const Text('Back',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Avatar
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor:
                              Colors.white.withOpacity(0.25),
                              backgroundImage: _currentImage,
                              child: _currentImage == null
                                  ? Text(
                                _initials,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                                  : null,
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _kPurple, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 16, color: _kPurple),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to change photo',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Name preview
                      ListenableBuilder(
                        listenable: _nameCtrl,
                        builder: (context, _) => Text(
                          _nameCtrl.text.trim().isEmpty
                              ? 'Full Name'
                              : _nameCtrl.text.trim(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListenableBuilder(
                        listenable: _designationCtrl,
                        builder: (context, _) =>
                        _designationCtrl.text.trim().isEmpty
                            ? const SizedBox()
                            : Padding(
                          padding:
                          const EdgeInsets.only(top: 4),
                          child: Text(
                            _designationCtrl.text.trim(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Staff / Teacher toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _typeOptions.map((t) {
                            final selected = _type == t;
                            return GestureDetector(
                              onTap: () => setState(() => _type = t),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius:
                                  BorderRadius.circular(30),
                                ),
                                child: Text(
                                  t == 'teacher'
                                      ? 'Teacher'
                                      : 'Staff',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: selected
                                        ? _kPurple
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      // Quick info pills
                      _leftInfoRow(
                          Icons.calendar_today_outlined, _joiningDate.isEmpty
                          ? 'Joining: —'
                          : 'Joined: $_joiningDate'),
                      const SizedBox(height: 10),
                      _leftInfoRow(Icons.work_outline, _employmentType),
                      const SizedBox(height: 10),
                      _leftInfoRow(Icons.person_outline, _gender),
                      if (_bloodGroup != null) ...[
                        const SizedBox(height: 10),
                        _leftInfoRow(
                            Icons.bloodtype_outlined, _bloodGroup!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // ── Right Panel (scrollable) ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      isEdit
                          ? 'Edit ${_type == 'teacher' ? 'Teacher' : 'Staff'} Profile'
                          : 'Add New ${_type == 'teacher' ? 'Teacher' : 'Staff Member'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEdit
                          ? 'Update the information below'
                          : 'Fill in the details below to add a new member',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Assigned Classes ──
                    _desktopSection(
                      'Assigned Classes',
                      Icons.class_outlined,
                      [
                        _buildClassSectionSelector(),  // ← updated widget
                      ],
                    ),

                    // ── Personal Information ──
                    _desktopSection(
                      'Personal Information',
                      Icons.person_outline,
                      [
                        _desktopRow([
                          _deskField(
                            label: 'Full Name *',
                            controller: _nameCtrl,
                            validator: (v) => v == null ||
                                v.trim().isEmpty
                                ? 'Required'
                                : null,
                            onChanged: (_) => setState(() {}),
                          ),
                          _deskField(
                            label: 'Designation (Optional)',
                            controller: _designationCtrl,
                            hint: 'e.g. Principal, Head Teacher...',
                            prefixIcon: Icons.badge_outlined,
                            onChanged: (_) => setState(() {}),
                          ),
                        ]),
                        _desktopRow([
                          _deskField(
                            label: _maritalStatus == 'Married'
                                ? 'Husband Name *'
                                : 'Father Name *',
                            controller: _fatherOrHusbandCtrl,
                            validator: (v) => v == null ||
                                v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                          _deskCnicField(),
                        ]),
                        _desktopRow([
                          _deskDateField(
                            label: 'Date of Birth *',
                            value: _dob,
                            onTap: _pickDob,
                            validator: (_) => _dob.isEmpty
                                ? 'Please select date of birth'
                                : null,
                          ),
                          _deskDateField(
                            label: 'Joining Date',
                            value: _joiningDate,
                            onTap: _pickJoiningDate,
                          ),
                        ]),
                        _desktopRow([
                          _deskDropdown<String>(
                            label: 'Gender *',
                            value: _gender,
                            items: _genderOptions,
                            onChanged: (v) =>
                                setState(() => _gender = v!),
                          ),
                          _deskDropdown<String>(
                            label: 'Marital Status *',
                            value: _maritalStatus,
                            items: _maritalOptions,
                            onChanged: (v) =>
                                setState(() => _maritalStatus = v!),
                          ),
                        ]),
                        _desktopRow([
                          _deskDropdown<String?>(
                            label: 'Blood Group (Optional)',
                            value: _bloodGroup,
                            items: _bloodOptions,
                            nullable: true,
                            onChanged: (v) =>
                                setState(() => _bloodGroup = v),
                          ),
                          _deskField(
                            label: 'Religion *',
                            controller: _religionCtrl,
                            validator: (v) => v == null ||
                                v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ]),
                        _deskField(
                          label: 'Nationality *',
                          controller: _nationalityCtrl,
                          validator: (v) => v == null ||
                              v.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ],
                    ),

                    // ── Contact Information ──
                    _desktopSection(
                      'Contact Information',
                      Icons.contact_phone_outlined,
                      [
                        _deskField(
                          label: 'Address *',
                          controller: _addressCtrl,
                          maxLines: 2,
                          validator: (v) => v == null ||
                              v.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        _desktopRow([
                          _deskField(
                            label: 'Phone No *',
                            controller: _phoneCtrl,
                            keyboard: TextInputType.phone,
                            validator: (v) => v == null ||
                                v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                          _deskField(
                            label: 'Emergency No *',
                            controller: _emergencyPhoneCtrl,
                            keyboard: TextInputType.phone,
                            validator: (v) => v == null ||
                                v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ]),
                      ],
                    ),

                    // ── Job Details ──
                    _desktopSection(
                      'Job Details',
                      Icons.work_outline,
                      [
                        _desktopRow([
                          _deskDropdown<String>(
                            label: 'Employment Type *',
                            value: _employmentType,
                            items: _employmentOptions,
                            onChanged: (v) => setState(
                                    () => _employmentType = v!),
                          ),
                          _deskSalaryField(),
                        ]),
                      ],
                    ),

                    // ── Assigned Subjects ──
                    _desktopSection(
                      'Assigned Subjects (Optional)',
                      Icons.menu_book_outlined,
                      [
                        _SubjectMultiSelect(
                          selectedSubjects: _subjects,
                          onChanged: (v) =>
                              setState(() => _subjects = v),
                        ),
                      ],
                    ),

                    // ── Additional Info ──
                    _desktopSection(
                      'Additional Info (Optional)',
                      Icons.info_outline,
                      [
                        _desktopRow([
                          _deskField(
                              label: 'Reference',
                              controller: _referenceCtrl),
                          _deskField(
                              label: 'Note',
                              controller: _noteCtrl,
                              maxLines: 3),
                        ]),
                      ],
                    ),

                    const SizedBox(height: 8),
                    // Save button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _kPurple),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: _kPurple)),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          height: 48,
                          child: _buildSaveButton(isEdit),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopSection(
      String title, IconData icon, List<Widget> children) {
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
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
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
                    color: _kPurple,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _withSpacing(children, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopRow(List<Widget> children) {
    return Row(
      children: children
          .map((w) => Expanded(child: w))
          .expand((w) => [w, const SizedBox(width: 14)])
          .toList()
        ..removeLast(),
    );
  }

  // ─── Desktop Field Helpers ─────────────────────────────────────────────────
  Widget _deskField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboard,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: _inputDeco(label, hint: hint, icon: prefixIcon),
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _deskCnicField() {
    return TextFormField(
      controller: _cnicCtrl,
      keyboardType: TextInputType.number,
      maxLength: 15,
      inputFormatters: [_CnicFormatter()],
      decoration: _inputDeco('CNIC * (e.g., 34101-1234567-8)')
          .copyWith(counterText: ''),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
        if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
        return null;
      },
    );
  }

  Widget _deskDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: _inputDeco(label).copyWith(
        suffixIcon:
        const Icon(Icons.calendar_today, size: 18, color: _kPurple),
      ),
      onTap: onTap,
      validator: validator,
    );
  }

  Widget _deskDropdown<T>({
    required String label,
    required T value,
    required List<String> items,
    required ValueChanged<T?> onChanged,
    bool nullable = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _inputDeco(label),
      items: [
        if (nullable)
          const DropdownMenuItem(
              value: null, child: Text('Select (Optional)')) as DropdownMenuItem<T>,
        ...items.map((i) =>
            DropdownMenuItem<T>(value: i as T, child: Text(i))),
      ],
      onChanged: onChanged,
    );
  }

  Widget _deskSalaryField() {
    return TextFormField(
      controller: _salaryCtrl,
      decoration:
      _inputDeco('Salary *').copyWith(prefixText: 'Rs  '),
      keyboardType: TextInputType.number,
      validator: (v) =>
      v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }

  // ─── Mobile Field Helpers ──────────────────────────────────────────────────
  Widget _mobileField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    bool required = false,
    TextInputType? keyboard,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: _inputDeco(required ? '$label *' : label,
          hint: hint, icon: icon),
      validator: required
          ? (v) =>
      v == null || v.trim().isEmpty ? 'Required' : null
          : null,
    );
  }

  Widget _mobileCnicField() {
    return TextFormField(
      controller: _cnicCtrl,
      decoration:
      _inputDeco('CNIC * (e.g., 34101-1234567-8)').copyWith(
        counterText: '',
      ),
      keyboardType: TextInputType.number,
      maxLength: 15,
      inputFormatters: [_CnicFormatter()],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
        if (!regex.hasMatch(v.trim())) return 'Invalid CNIC format';
        return null;
      },
    );
  }

  Widget _mobileSalaryField() {
    return TextFormField(
      controller: _salaryCtrl,
      decoration: _inputDeco('Salary *').copyWith(prefixText: 'Rs  '),
      keyboardType: TextInputType.number,
      validator: (v) =>
      v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _mobileDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool required = false,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: _inputDeco(required ? '$label *' : label).copyWith(
        suffixIcon:
        const Icon(Icons.calendar_today, size: 18, color: _kPurple),
      ),
      onTap: onTap,
      validator: validator,
    );
  }

  Widget _mobileDropdown<T>({
    required String label,
    required T value,
    required List<String> items,
    required ValueChanged<T?> onChanged,
    bool nullable = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _inputDeco(label),
      items: [
        if (nullable)
          const DropdownMenuItem(
              value: null,
              child: Text('Select (Optional)')) as DropdownMenuItem<T>,
        ...items.map((i) =>
            DropdownMenuItem<T>(value: i as T, child: Text(i))),
      ],
      onChanged: onChanged,
    );
  }

  // ─── Shared Helpers ────────────────────────────────────────────────────────
  InputDecoration _inputDeco(String label,
      {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
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

  Widget _leftInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white60),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return ElevatedButton(
      onPressed: _isSaving ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: _isSaving
          ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white))
          : Text(
        isEdit ? 'Update' : 'Save',
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> children, double spacing) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) result.add(SizedBox(height: spacing));
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingStaff != null;
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    if (isDesktop) return _buildDesktopLayout(isEdit);
    return _buildMobileLayout(isEdit);
  }
}