
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/app_user_Model.dart';
import '../../models/school_setting_model.dart';
import '../../providers/school_setting_prodvider.dart';
import '../../providers/app_user_provider.dart';

// ============================================================
// DESIGN TOKENS (matches EduCore purple theme)
// ============================================================
const _kInk = Color(0xFF1F2937);
const _kSlate = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kSurface = Color(0xFFF8FAFC);
const _kCard = Colors.white;

const _kPrimary = Color(0xFF534AB7);
const _kPrimaryDark = Color(0xFF433CA0);
const _kPrimaryLight = Color(0xFFF0EFFE);

const _kGreen = Color(0xFF166534);
const _kGreenBg = Color(0xFFEFFCF3);
const _kRed = Color(0xFFB91C1C);
const _kRedBg = Color(0xFFFEF2F2);
const _kOrange = Color(0xFFB45309);
const _kOrangeBg = Color(0xFFFFFBEB);

const double _kDesktopBreakpoint = 900;

const List<Map<String, String>> _kRoles = [
  {'key': 'admin', 'label': 'Admin'},
  {'key': 'accountant', 'label': 'Accountant'},
  {'key': 'teacher', 'label': 'Teacher'},
];

String _roleLabel(String key) {
  return _kRoles.firstWhere(
        (r) => r['key'] == key,
    orElse: () => {'key': key, 'label': key},
  )['label']!;
}

class SchoolSettingsScreen extends StatefulWidget {
  final bool showAppBar;
  const SchoolSettingsScreen({super.key, this.showAppBar = true});

  @override
  State<SchoolSettingsScreen> createState() => _SchoolSettingsScreenState();
}

class _SchoolSettingsScreenState extends State<SchoolSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _sessionYearCtrl;
  late final TextEditingController _currencyCtrl;
  late final TextEditingController _timezoneCtrl;
  late final TextEditingController _fineCtrl;

  Uint8List? _pickedLogoBytes; // freshly picked, not yet saved
  String? _existingLogoBase64; // currently saved logo
  bool _initializedFromProvider = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _sessionYearCtrl = TextEditingController();
    _currencyCtrl = TextEditingController();
    _timezoneCtrl = TextEditingController();
    _fineCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SchoolSettingsProvider>();
      await provider.loadSettings();
      _applySettingsToFields(provider.settings);

      // ★ NEW — start listening to the registered users list
      context.read<AppUserProvider>().listenToUsers();
    });
  }

  void _applySettingsToFields(SchoolSettings s) {
    if (_initializedFromProvider) return;
    _initializedFromProvider = true;
    setState(() {
      _nameCtrl.text = s.schoolName;
      _emailCtrl.text = s.email;
      _phoneCtrl.text = s.phone;
      _cityCtrl.text = s.city;
      _countryCtrl.text = s.country;
      _addressCtrl.text = s.address;
      _sessionYearCtrl.text = s.sessionYear;
      _currencyCtrl.text = s.currency;
      _timezoneCtrl.text = s.timezone;
      _fineCtrl.text = s.finederDay == 0 ? '' : s.finederDay.toString();
      _existingLogoBase64 = s.logoBase64;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _addressCtrl.dispose();
    _sessionYearCtrl.dispose();
    _currencyCtrl.dispose();
    _timezoneCtrl.dispose();
    _fineCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedLogoBytes = bytes;
    });
  }

  void _removeLogo() {
    setState(() {
      _pickedLogoBytes = null;
      _existingLogoBase64 = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SchoolSettingsProvider>();

    String? logoBase64 = _existingLogoBase64;
    if (_pickedLogoBytes != null) {
      logoBase64 = base64Encode(_pickedLogoBytes!);
    }

    final updated = SchoolSettings(
      schoolName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      sessionYear: _sessionYearCtrl.text.trim(),
      currency: _currencyCtrl.text.trim(),
      timezone: _timezoneCtrl.text.trim(),
      finederDay: double.tryParse(_fineCtrl.text.trim()) ?? 0,
      logoBase64: logoBase64,
    );

    final ok = await provider.saveSettings(updated);

    if (!mounted) return;
    setState(() {
      _pickedLogoBytes = null;
      _existingLogoBase64 = logoBase64;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'School settings saved successfully.'
            : (provider.error ?? 'Failed to save settings.')),
        backgroundColor: ok ? _kGreen : _kRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SchoolSettingsProvider>();

    // Re-apply once data actually arrives from Firestore.
    if (!provider.loading && !_initializedFromProvider) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applySettingsToFields(provider.settings);
      });
    }

    final body = LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
      final horizontalPad = isDesktop ? 28.0 : 14.0;

      if (provider.loading) {
        return const Center(
          child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPad, 20, horizontalPad, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(isDesktop),
              const SizedBox(height: 16),
              _buildMainCard(isDesktop),
              const SizedBox(height: 16),
              _buildUsersCard(isDesktop), // ★ REPLACED _buildAccountInfoCard
            ],
          ),
        ),
      );
    });

    if (!widget.showAppBar) {
      return Container(color: _kSurface, child: body);
    }

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'School Settings',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: _kInk),
        ),
        backgroundColor: _kCard,
        surfaceTintColor: _kCard,
        foregroundColor: _kInk,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
      ),
      body: body,
    );
  }

  // ── Header / Hero card with gradient ──
  Widget _buildHeaderCard(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, _kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('School Settings',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                SizedBox(height: 3),
                Text('Manage your school profile & preferences',
                    style: TextStyle(fontSize: 12.5, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Main form card ──
  Widget _buildMainCard(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: isDesktop
          ? IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 200, child: _buildLogoPicker()),
            const SizedBox(width: 24),
            Expanded(child: _buildFormFields(isDesktop)),
          ],
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _buildLogoPicker()),
          const SizedBox(height: 20),
          _buildFormFields(isDesktop),
        ],
      ),
    );
  }

  // ── Logo picker — modern circular avatar with edit badge ──
  Widget _buildLogoPicker() {
    ImageProvider? image;
    if (_pickedLogoBytes != null) {
      image = MemoryImage(_pickedLogoBytes!);
    } else if (_existingLogoBase64 != null && _existingLogoBase64!.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(_existingLogoBase64!));
      } catch (_) {
        image = null;
      }
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kPrimaryLight,
                border: Border.all(color: _kBorder, width: 2),
                image: image != null
                    ? DecorationImage(image: image, fit: BoxFit.cover)
                    : null,
              ),
              child: image == null
                  ? const Icon(Icons.school_rounded, size: 46, color: _kPrimary)
                  : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: InkWell(
                onTap: _pickLogo,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('School Logo',
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.upload_rounded, size: 15, color: _kPrimary),
              label: const Text('Upload',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kPrimary)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            if (image != null)
              TextButton.icon(
                onPressed: _removeLogo,
                icon: const Icon(Icons.delete_outline_rounded, size: 15, color: _kRed),
                label: const Text('Remove',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kRed)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── Form fields grid ──
  Widget _buildFormFields(bool isDesktop) {
    Widget row(List<Widget> children) {
      if (!isDesktop) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children
              .expand((w) => [w, const SizedBox(height: 14)])
              .toList()
            ..removeLast(),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .expand((w) => [Expanded(child: w), const SizedBox(width: 14)])
            .toList()
          ..removeLast(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row([
          _field(_nameCtrl, 'School Name', Icons.school_outlined, required: true),
          _field(_emailCtrl, 'Email', Icons.email_outlined,
              required: true, keyboardType: TextInputType.emailAddress),
        ]),
        const SizedBox(height: 14),
        row([
          _field(_phoneCtrl, 'Phone', Icons.call_outlined,
              keyboardType: TextInputType.phone),
          _field(_cityCtrl, 'City', Icons.location_city_outlined),
          _field(_countryCtrl, 'Country', Icons.public_outlined),
        ]),
        const SizedBox(height: 14),
        _field(_addressCtrl, 'Address', Icons.home_outlined, maxLines: 3),
        const SizedBox(height: 14),
        row([
          _field(_sessionYearCtrl, 'Session Year', Icons.calendar_today_outlined,
              hint: 'e.g. 2025-2026'),
          _field(_currencyCtrl, 'Currency', Icons.attach_money_rounded,
              hint: 'e.g. PKR'),
          _field(_timezoneCtrl, 'Timezone', Icons.schedule_outlined,
              hint: 'e.g. Asia/Karachi'),
          _field(_fineCtrl, 'Fine / Day', Icons.money_off_csred_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        ]),
        const SizedBox(height: 22),
        _buildSaveButton(),
      ],
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        bool required = false,
        String? hint,
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk),
            children: required
                ? const [
              TextSpan(
                  text: ' *',
                  style: TextStyle(color: _kRed, fontWeight: FontWeight.w700))
            ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
          style: const TextStyle(fontSize: 13.5, color: _kInk),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
            prefixIcon: maxLines == 1
                ? Icon(icon, size: 18, color: _kSlate)
                : Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(icon, size: 18, color: _kSlate),
            ),
            filled: true,
            fillColor: _kSurface,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _kRed)),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final provider = context.watch<SchoolSettingsProvider>();
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: provider.saving ? null : _save,
        icon: provider.saving
            ? const SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.check_rounded, size: 18),
        label: Text(provider.saving ? 'Saving...' : 'Save Settings',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  // ============================================================
  // ★ NEW — Registered Users card (replaces the old static
  // "Account Info" block). Lists every account from the `users`
  // Firestore collection with name, role, password, and an
  // active/deactivate switch. Tapping a row (or its edit icon)
  // opens a dialog to edit name / role / password / status.
  // ============================================================
  Widget _buildUsersCard(bool isDesktop) {
    final userProvider = context.watch<AppUserProvider>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group_rounded, size: 17, color: _kPrimary),
              const SizedBox(width: 8),
              const Text('Registered Users',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _kInk)),
              const Spacer(),
              if (!userProvider.loading)
                Text('${userProvider.users.length} total',
                    style: const TextStyle(fontSize: 11.5, color: _kSlate)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Everyone who can sign in to EduCore — edit their name, role, password, or deactivate access.',
            style: TextStyle(fontSize: 11.5, color: _kSlate),
          ),
          const SizedBox(height: 14),
          if (userProvider.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
              ),
            )
          else if (userProvider.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(userProvider.error!,
                  style: const TextStyle(fontSize: 12.5, color: _kRed)),
            )
          else if (userProvider.users.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No registered users found.',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500)),
              )
            else
              (isDesktop
                  ? _buildUsersTable(userProvider.users)
                  : _buildUsersMobileList(userProvider.users)),
        ],
      ),
    );
  }

  // ── Desktop/tablet: compact table ──
  Widget _buildUsersTable(List<AppUser> users) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: _kPrimaryLight,
            child: Row(
              children: const [
                Expanded(
                    flex: 3,
                    child: Text('NAME',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800, color: _kPrimaryDark))),
                Expanded(
                    flex: 3,
                    child: Text('EMAIL',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800, color: _kPrimaryDark))),
                Expanded(
                    flex: 2,
                    child: Text('ROLE',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800, color: _kPrimaryDark))),
                Expanded(
                    flex: 2,
                    child: Text('PASSWORD',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800, color: _kPrimaryDark))),
                Expanded(
                    flex: 2,
                    child: Text('STATUS',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800, color: _kPrimaryDark))),
                SizedBox(width: 40),
              ],
            ),
          ),
          ...List.generate(users.length, (i) {
            final u = users[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: i.isEven ? _kCard : _kSurface.withOpacity(0.6),
                border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: _kPrimaryLight,
                          child: Text(
                            u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            u.name.isEmpty ? '—' : u.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(u.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: _kSlate)),
                  ),
                  Expanded(
                    flex: 2,
                    child: _RolePill(role: u.role),
                  ),
                  Expanded(
                    flex: 2,
                    child: _PasswordReveal(password: u.password),
                  ),
                  Expanded(
                    flex: 2,
                    child: _StatusSwitch(
                      isActive: u.isActive,
                      onChanged: (val) =>
                          context.read<AppUserProvider>().setActive(u.uid, val),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 17, color: _kSlate),
                      onPressed: () => _openEditUserDialog(u),
                      tooltip: 'Edit user',
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Mobile: stacked cards ──
  Widget _buildUsersMobileList(List<AppUser> users) {
    return Column(
      children: List.generate(users.length, (i) {
        final u = users[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: _kPrimaryLight,
                    child: Text(
                      u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(u.name.isEmpty ? '—' : u.name,
                            style: const TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
                        Text(u.email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: _kSlate)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: _kSlate),
                    onPressed: () => _openEditUserDialog(u),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _RolePill(role: u.role),
                  const SizedBox(width: 10),
                  _PasswordReveal(password: u.password),
                  const Spacer(),
                  _StatusSwitch(
                    isActive: u.isActive,
                    onChanged: (val) =>
                        context.read<AppUserProvider>().setActive(u.uid, val),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Edit dialog: name, role, password, active toggle ──
  Future<void> _openEditUserDialog(AppUser user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final passwordCtrl = TextEditingController(text: user.password);
    String role = user.role;
    bool isActive = user.isActive;
    bool obscure = true;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.manage_accounts_rounded, color: _kPrimary),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Edit User',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: _kInk)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(user.email,
                        style: const TextStyle(fontSize: 12, color: _kSlate)),
                    const SizedBox(height: 16),
                    const Text('Name',
                        style: TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: _kSurface,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(color: _kBorder)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(color: _kBorder)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(color: _kPrimary, width: 1.4)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Role',
                        style: TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: _kBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: role,
                          isExpanded: true,
                          isDense: true,
                          items: _kRoles
                              .map((r) => DropdownMenuItem(
                            value: r['key'],
                            child: Text(r['label']!,
                                style: const TextStyle(fontSize: 13.5, color: _kInk)),
                          ))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setDialogState(() => role = v);
                          },
                          icon: const Icon(Icons.keyboard_arrow_down, color: _kSlate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Password',
                        style: TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: obscure,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: _kSurface,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: _kSlate),
                          onPressed: () =>
                              setDialogState(() => obscure = !obscure),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(color: _kBorder)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(color: _kBorder)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(color: _kPrimary, width: 1.4)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Note: this updates the stored profile password. It does not change the account\'s actual sign-in password in Firebase Auth.',
                        style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Account Active',
                              style: TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
                        ),
                        Switch(
                          value: isActive,
                          activeColor: _kPrimary,
                          onChanged: (v) => setDialogState(() => isActive = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('CANCEL',
                              style: TextStyle(fontWeight: FontWeight.w600, color: _kSlate)),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: () async {
                            final updated = user.copyWith(
                              name: nameCtrl.text.trim(),
                              role: role,
                              password: passwordCtrl.text,
                              isActive: isActive,
                            );
                            final ok = await context
                                .read<AppUserProvider>()
                                .updateUser(updated);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'User updated successfully.'
                                      : 'Failed to update user.'),
                                  backgroundColor: ok ? _kGreen : _kRed,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9)),
                            elevation: 0,
                          ),
                          child: const Text('Save Changes',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

// ============================================================
// Small reusable pieces for the Users list
// ============================================================
class _RolePill extends StatelessWidget {
  final String role;
  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    switch (role) {
      case 'admin':
        color = _kPrimary;
        bg = _kPrimaryLight;
        break;
      case 'accountant':
        color = _kGreen;
        bg = _kGreenBg;
        break;
      default:
        color = _kOrange;
        bg = _kOrangeBg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _roleLabel(role),
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _PasswordReveal extends StatefulWidget {
  final String password;
  const _PasswordReveal({required this.password});

  @override
  State<_PasswordReveal> createState() => _PasswordRevealState();
}

class _PasswordRevealState extends State<_PasswordReveal> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final display = widget.password.isEmpty
        ? '—'
        : (_visible ? widget.password : '•' * widget.password.length.clamp(4, 10));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            display,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: _kInk),
          ),
        ),
        if (widget.password.isNotEmpty)
          InkWell(
            onTap: () => setState(() => _visible = !_visible),
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 15,
                color: _kSlate,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusSwitch extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;
  const _StatusSwitch({required this.isActive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? _kGreen : _kRed,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isActive ? _kGreen : _kRed),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: isActive,
            activeColor: _kGreen,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}