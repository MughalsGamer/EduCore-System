

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart'; // navigate to dashboard instead of login

// ═════════════════════════════════════════════════════════════
//  DESIGN TOKENS — "EduCore Glass" system (matches dashboard_screen.dart
//  and login_screen.dart)
// ═════════════════════════════════════════════════════════════
class _T {
  static const bg = Color(0xFFF3F4FA);
  static const ink = Color(0xFF171B2E);
  static const inkSoft = Color(0xFF676C82);
  static const inkFaint = Color(0xFF9598AC);

  static const primary = Color(0xFF6C5CE7);
  static const primaryDeep = Color(0xFF4C3FCB);
  static const primarySoft = Color(0xFFEFECFE);

  static const teal = Color(0xFF0F9D6C);
  static const tealSoft = Color(0xFFE3F7EE);
  static const blue = Color(0xFF1C7ED6);
  static const blueSoft = Color(0xFFE7F2FD);
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFCEEDA);
  static const rose = Color(0xFFDC4C64);
  static const roseSoft = Color(0xFFFCE9EC);

  static const borderSoft = Color(0xFFE7E8F2);

  static BoxDecoration glass({double radius = 24}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.86),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF3B3F6B).withOpacity(0.08),
          blurRadius: 32,
          offset: const Offset(0, 16),
          spreadRadius: -12,
        ),
      ],
    );
  }
}

class _RoleOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color colorSoft;
  const _RoleOption(this.value, this.label, this.icon, this.color, this.colorSoft);
}

const _roleOptions = <_RoleOption>[
  _RoleOption('admin', 'Admin', Icons.shield_rounded, _T.rose, _T.roseSoft),
  _RoleOption('accountant', 'Accountant', Icons.calculate_rounded, _T.amber, _T.amberSoft),
  _RoleOption('teacher', 'Teacher', Icons.person_rounded, _T.blue, _T.blueSoft),
];

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'teacher';
  bool _isLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  )..forward();
  late final Animation<double> _fade =
  CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _entrance.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User registered successfully!'),
          backgroundColor: _T.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      // Firebase auto signs-in the newly created user, so navigate straight
      // to the Dashboard instead of the Login screen, clearing all routes.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: _T.rose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _T.bg,
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  // ═══════════════════════════════════════════
  //  WEB / WIDE — split screen: branding + form
  // ═══════════════════════════════════════════
  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _RegisterBrandPanel(),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: _T.bg,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: _buildForm(isWide: true),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  //  MOBILE — full-width centered form
  // ═══════════════════════════════════════════
  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: _T.ink),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: _T.borderSoft),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_T.primary, _T.primaryDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: _T.primary.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text('Create account',
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: _T.ink)),
                  const SizedBox(height: 5),
                  const Text('Add a new staff member to EduCore',
                      style: TextStyle(fontSize: 13.5, color: _T.inkFaint)),
                ],
              ),
            ),
            const SizedBox(height: 26),
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: _buildForm(isWide: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SHARED FORM CARD
  // ═══════════════════════════════════════════
  Widget _buildForm({required bool isWide}) {
    return Container(
      padding: EdgeInsets.all(isWide ? 0 : 22),
      decoration: isWide ? null : _T.glass(radius: 22),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWide) ...[
              const Text('Create account',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: _T.ink)),
              const SizedBox(height: 6),
              const Text('Add a new staff member to EduCore',
                  style: TextStyle(fontSize: 13.5, color: _T.inkFaint)),
              const SizedBox(height: 26),
            ],
            const Text('Full name',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _T.ink)),
            const SizedBox(height: 7),
            _RField(
              controller: _nameController,
              hint: 'Jane Doe',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            const Text('Email',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _T.ink)),
            const SizedBox(height: 7),
            _RField(
              controller: _emailController,
              hint: 'name@school.edu',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter an email' : null,
            ),
            const SizedBox(height: 16),
            const Text('Password',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _T.ink)),
            const SizedBox(height: 7),
            _RField(
              controller: _passwordController,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter a password' : null,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 19,
                  color: _T.inkFaint,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Role',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _T.ink)),
            const SizedBox(height: 9),
            Row(
              children: _roleOptions.map((r) {
                final selected = _selectedRole == r.value;
                final isLast = r == _roleOptions.last;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 8),
                    child: _RoleChip(
                      option: r,
                      selected: selected,
                      onTap: () => setState(() => _selectedRole = r.value),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _T.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _T.primary.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(_T.primaryDeep.withOpacity(0.15)),
                ),
                onPressed: _isLoading ? null : _register,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoading
                      ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                      : const Text(
                    key: ValueKey('label'),
                    'Register user',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  LEFT BRANDING PANEL (web only) — register variant
// ═════════════════════════════════════════════════════════════
class _RegisterBrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_T.primaryDeep, _T.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -70, left: -60, child: _circle(220, 0.10)),
          Positioned(bottom: -110, right: -70, child: _circle(280, 0.08)),
          Positioned(top: 160, right: 70, child: _circle(80, 0.14)),
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 56, 56, 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('EduCore',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Bring your whole team\ninto one workspace.',
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                            letterSpacing: -0.8,
                            color: Colors.white)),
                    const SizedBox(height: 16),
                    Text(
                      'Register admins, accountants and teachers with the exact access each role needs.',
                      style: TextStyle(fontSize: 14.5, height: 1.5, color: Colors.white.withOpacity(0.82)),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _RegisterBrandPanel._roleDot(Icons.shield_rounded, 'Admin'),
                        const SizedBox(width: 18),
                        _RegisterBrandPanel._roleDot(Icons.calculate_rounded, 'Accountant'),
                        const SizedBox(width: 18),
                        _RegisterBrandPanel._roleDot(Icons.person_rounded, 'Teacher'),
                      ],
                    ),
                  ],
                ),
                Text('© ${DateTime.now().year} EduCore Systems',
                    style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.55))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)),
  );

  static Widget _roleDot(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Icon(icon, size: 19, color: Colors.white),
        ),
        const SizedBox(height: 7),
        Text(label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  ROLE SELECTOR CHIP
// ═════════════════════════════════════════════════════════════
class _RoleChip extends StatelessWidget {
  final _RoleOption option;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? option.colorSoft : const Color(0xFFFAFAFD),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? option.color : _T.borderSoft,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(option.icon, size: 18, color: selected ? option.color : _T.inkFaint),
            const SizedBox(height: 5),
            Text(option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? option.color : _T.inkSoft,
                )),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  TEXT FIELD (local copy of the glass field used in LoginScreen so this
//  file has no compile-time dependency beyond the DashboardScreen import)
// ═════════════════════════════════════════════════════════════
class _RField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _RField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  State<_RField> createState() => _RFieldState();
}

class _RFieldState extends State<_RField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFD),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _focused ? _T.primary : _T.borderSoft,
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: _focused
            ? [
          BoxShadow(
            color: _T.primary.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: const TextStyle(fontSize: 14, color: _T.ink, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 14, color: _T.inkFaint, fontWeight: FontWeight.w400),
          prefixIcon: Icon(widget.icon, size: 19, color: _focused ? _T.primary : _T.inkFaint),
          suffixIcon: widget.suffix,
          filled: false,
          border: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 11, color: _T.rose, fontWeight: FontWeight.w600),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        ),
      ),
    );
  }
}