
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/school_setting_model.dart';
import '../../models/teacher.dart'; // StaffMember Model
import '../../providers/teacher_provider.dart'; // StaffProvider
import '../../providers/school_setting_prodvider.dart';

// ============================================================
// NEW THEME (EXACTLY MATCHING IMAGE)
// ============================================================
const _kCardWidth = 380.0;
const _kCardHeight = 560.0;
const _kBlack = Color(0xFF1A1A1A);
const _kOrange = Color(0xFFF17A00); // Bright Orange
const _kSurface = Color(0xFFF8FAFC);

// ============================================================
// Clippers for the Specific Geometric Curves
// ============================================================
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_HeaderClipper old) => false;
}

class _FooterClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width / 2, -20, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_FooterClipper old) => false;
}

// ============================================================
// MAIN SCREEN
// ============================================================
class StaffIdCardsScreen extends StatefulWidget {
  final bool showAppBar;
  const StaffIdCardsScreen({super.key, this.showAppBar = true});

  @override
  State<StaffIdCardsScreen> createState() => _StaffIdCardsScreenState();
}

class _StaffIdCardsScreenState extends State<StaffIdCardsScreen> {
  String _searchQuery = '';
  String _roleFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchAll();
    });
  }

  List<StaffMember> _getFilteredStaff(List<StaffMember> allStaff) {
    return allStaff.where((staff) {
      // 🚀 SIRF ACTIVE (isActive == true) EMPLOYEES KA CARD SHOW HOGA
      if (!staff.isActive) return false;

      final matchesSearch = staff.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter == 'All' || staff.type == _roleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final schoolProvider = context.watch<SchoolSettingsProvider>();
    final List<StaffMember> filteredStaff = _getFilteredStaff(staffProvider.allStaff);

    final body = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: staffProvider.loading
                ? const Center(child: CircularProgressIndicator(color: _kOrange))
                : filteredStaff.isEmpty
                ? const Center(child: Text('No active staff members found.', style: TextStyle(color: Colors.grey)))
                : LayoutBuilder(builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 700 ? 1 : constraints.maxWidth < 1100 ? 2 : 3;
              return GridView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  // ✅ FIX: Exact aspect ratio remove ki extra 0.05
                  childAspectRatio: _kCardWidth / _kCardHeight,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredStaff.length,
                itemBuilder: (context, index) {
                  return _IdCardFlipWidget(
                    staff: filteredStaff[index],
                    schoolSettings: schoolProvider.settings,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );

    if (!widget.showAppBar) return Scaffold(body: body);

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text('Employee ID Cards', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
        leading: const BackButton(color: Colors.black87),
      ),
      body: body,
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search by name...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kOrange, width: 1.5)),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _filterChip('All', _roleFilter == 'All', () => setState(() => _roleFilter = 'All')),
            _filterChip('Teachers', _roleFilter == 'teacher', () => setState(() => _roleFilter = 'teacher')),
            _filterChip('Staff Only', _roleFilter == 'staff', () => setState(() => _roleFilter = 'staff')),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: _kOrange.withOpacity(0.15),
      labelStyle: TextStyle(color: isSelected ? _kOrange : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: isSelected ? _kOrange : Colors.grey.shade300, width: 1),
    );
  }
}

// ============================================================
// FLIP CARD WIDGET (Front + Back)
// ============================================================
class _IdCardFlipWidget extends StatefulWidget {
  final StaffMember staff;
  final SchoolSettings schoolSettings;
  const _IdCardFlipWidget({required this.staff, required this.schoolSettings});

  @override
  State<_IdCardFlipWidget> createState() => _IdCardFlipWidgetState();
}

class _IdCardFlipWidgetState extends State<_IdCardFlipWidget> {
  bool _isFlipped = false;
  void _toggleFlip() => setState(() => _isFlipped = !_isFlipped);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedSwitcher(
        // ✅ FIX: Animation slow kar di (500ms se 700ms)
        duration: const Duration(milliseconds: 700),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnim = Tween(begin: 0.5, end: 0.0).animate(animation);
          return RotationTransition(
            turns: rotateAnim,
            child: child,
          );
        },
        child: _isFlipped
            ? _IdCardBack(key: const ValueKey('back'), staff: widget.staff, schoolSettings: widget.schoolSettings)
            : _IdCardFront(key: const ValueKey('front'), staff: widget.staff, schoolSettings: widget.schoolSettings),
      ),
    );
  }
}

// Helper widget to display the transparent school logo
class _TransparentLogo extends StatelessWidget {
  final SchoolSettings settings;
  final double size;
  const _TransparentLogo(this.settings, {this.size = 36});

  @override
  Widget build(BuildContext context) {
    if (settings.logoBase64 != null && settings.logoBase64!.isNotEmpty) {
      try {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: MemoryImage(base64Decode(settings.logoBase64!)),
              fit: BoxFit.contain, // 🚀 Background transparent
            ),
          ),
        );
      } catch (_) {
        return _fallbackLogo(size);
      }
    }
    return _fallbackLogo(size);
  }

  Widget _fallbackLogo(double size) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.school, color: Colors.white, size: 24),
    );
  }
}

// ============================================================
// FRONT CARD (MATCHING IMAGE DESIGN)
// ============================================================
class _IdCardFront extends StatelessWidget {
  final StaffMember staff;
  final SchoolSettings schoolSettings;
  const _IdCardFront({required this.staff, required this.schoolSettings, super.key});

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _kOrange),
          const SizedBox(width: 10),
          Text('$label : ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolName = schoolSettings.schoolName.trim().isEmpty ? 'DEMO SCHOOL' : schoolSettings.schoolName.toUpperCase();
    final address = schoolSettings.address.trim().isEmpty ? 'Demod, Demod, Pakistan' : schoolSettings.address;
    final roleText = staff.type == 'teacher' ? 'TEACHER' : 'STAFF';

    // ✅ FIX: BoxConstraints aur mainAxisSize add kiya RenderFlex overflow khatam karne ke liye
    return Container(
      key: key,
      constraints: const BoxConstraints(maxWidth: _kCardWidth, maxHeight: _kCardHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.max, // ✅ Adds full height
        children: [
          // ─── BLACK HEADER WITH ORANGE CURVE ───
          Stack(
            children: [
              Container(height: 130, color: _kOrange),
              ClipPath(
                clipper: _HeaderClipper(),
                child: Container(
                  height: 126,
                  color: _kBlack,
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _TransparentLogo(schoolSettings, size: 48),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(schoolName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)),
                          const SizedBox(height: 2),
                          Text('LEARN • GROW • SUCCEED', style: TextStyle(color: _kOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─── CIRCULAR PROFILE PHOTO ───
          Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kOrange, width: 4),
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: staff.imageBase64 != null
                    ? MemoryImage(base64Decode(staff.imageBase64!))
                    : null,
                child: staff.imageBase64 == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
          ),

          // ─── NAME & ROLE BADGE ───
          Transform.translate(
            offset: const Offset(0, -25),
            child: Column(
              children: [
                Text(
                  staff.name.toUpperCase(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _kOrange),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kBlack,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.assignment_ind_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(roleText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── PERSONAL INFO ───
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Father / Husband', staff.fatherOrHusbandName, Icons.person_outline),
                _infoRow('CNIC', staff.cnic, Icons.assignment_ind_outlined),
                _infoRow('Date of Birth', staff.dob, Icons.calendar_today_outlined),
                _infoRow('Gender', staff.gender, Icons.wc),
                _infoRow('Marital Status', staff.maritalStatus, Icons.favorite_border),
                _infoRow('Blood Group', staff.bloodGroup ?? '-', Icons.water_drop_outlined),
                _infoRow('Religion', staff.religion, Icons.nightlight_round),
                _infoRow('Nationality', staff.nationality, Icons.language),
              ],
            ),
          ),

          const Spacer(),

          // ─── BLACK FOOTER WITH CURVE ───
          ClipPath(
            clipper: _FooterClipper(),
            child: Container(
              height: 50,
              color: _kBlack,
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: _kOrange, size: 18),
                  const SizedBox(width: 8),
                  Text(address, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BACK CARD (MATCHING IMAGE DESIGN)
// ============================================================
class _IdCardBack extends StatelessWidget {
  final StaffMember staff;
  final SchoolSettings schoolSettings;
  const _IdCardBack({required this.staff, required this.schoolSettings, super.key});

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(color: _kOrange, borderRadius: BorderRadius.circular(20)),
        child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _kOrange),
          const SizedBox(width: 8),
          Text('$label : ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 12, color: Colors.black87), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _policyRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 5, color: _kOrange),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 10.5, color: Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolName = schoolSettings.schoolName.trim().isEmpty ? 'DEMO SCHOOL' : schoolSettings.schoolName.toUpperCase();
    final address = schoolSettings.address.trim().isEmpty ? 'Demod, Demod, Pakistan' : schoolSettings.address;
    final assignedClasses = staff.assignedSections.isEmpty ? '1' : staff.assignedSections.join(', ');

    // ✅ FIX: BoxConstraints aur mainAxisSize add kiya RenderFlex overflow khatam karne ke liye
    return Container(
      key: key,
      constraints: const BoxConstraints(maxWidth: _kCardWidth, maxHeight: _kCardHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.max, // ✅ Adds full height
        children: [
          // ─── TOP BLACK HEADER WITH LOGO ───
          Stack(
            children: [
              Container(height: 100, color: _kOrange),
              ClipPath(
                clipper: _HeaderClipper(),
                child: Container(
                  height: 96,
                  color: _kBlack,
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TransparentLogo(schoolSettings, size: 44),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(schoolName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                          Text('LEARN • GROW • SUCCEED', style: TextStyle(color: _kOrange, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─── CONTACT INFO ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('CONTACT INFORMATION'),
                _detailRow(Icons.location_on, 'Address', address),
                _detailRow(Icons.phone, 'Phone', schoolSettings.phone.trim().isEmpty ? '03007465064' : schoolSettings.phone),
                _detailRow(Icons.warning_amber_rounded, 'Emergency', staff.emergencyPhone),
                const Divider(height: 20),
                _sectionHeader('JOB DETAILS'),
                _detailRow(Icons.work_outline, 'Employment Type', staff.employmentType),
                _detailRow(Icons.calendar_today, 'Assigned Classes', assignedClasses),
                const Divider(height: 20),
              ],
            ),
          ),

          // ─── POLICIES ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _policyRow('This card is the property of Demo School.'),
                _policyRow('This card must be carried at all times.'),
                _policyRow('If found, please return to the school office.'),
              ],
            ),
          ),

          const Spacer(),

          // ─── BOTTOM BLACK FOOTER ───
          ClipPath(
            clipper: _FooterClipper(),
            child: Container(
              height: 55,
              color: _kBlack,
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // children: [
                //   Container(
                //     padding: const EdgeInsets.all(6),
                //     decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                //     child: const Icon(Icons.school, color: _kOrange, size: 20),
                //   ),
                //   const SizedBox(width: 10),
                //   Text(schoolName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                // ],
                // Inside _IdCardBack.build(), in the footer Row:
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    // ✅ School logo instead of cap icon
                    child: _TransparentLogo(schoolSettings, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(schoolName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


