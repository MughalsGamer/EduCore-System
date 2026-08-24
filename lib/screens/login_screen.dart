
import 'package:educoresystem/screens/register_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// ═════════════════════════════════════════════════════════════
//  DESIGN TOKENS — "EduCore Glass" system (matches dashboard_screen.dart)
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
  static const rose = Color(0xFFDC4C64);
  static const roseSoft = Color(0xFFFCE9EC);

  static const borderSoft = Color(0xFFE7E8F2);

  static BoxDecoration glass({
    double radius = 22,
    Color tint = Colors.white,
    double opacity = 0.86,
  }) {
    return BoxDecoration(
      color: tint.withOpacity(opacity),
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text.trim(), _passwordController.text.trim());
      // Successful login – AuthGate will handle redirection automatically
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: _T.rose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, anim, __) => const RegisterUserScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.03, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    );
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
          child: _BrandPanel(),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: _T.bg,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
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
  //  MOBILE — full-width centered form, gradient header
  // ═══════════════════════════════════════════
  Widget _buildMobileLayout() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, box) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fade,
                      child: Column(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_T.primary, _T.primaryDeep],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _T.primary.withOpacity(0.35),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.school_rounded,
                                color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 18),
                          const Text('Welcome back',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: _T.ink)),
                          const SizedBox(height: 6),
                          const Text('Sign in to manage your campus',
                              style: TextStyle(fontSize: 13.5, color: _T.inkFaint)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SHARED FORM CARD
  // ═══════════════════════════════════════════
  Widget _buildForm({required bool isWide}) {
    return Container(
      padding: EdgeInsets.all(isWide ? 0 : 24),
      decoration: isWide ? null : _T.glass(radius: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWide) ...[
              const Text('Welcome back',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: _T.ink)),
              const SizedBox(height: 6),
              const Text('Sign in to manage your campus',
                  style: TextStyle(fontSize: 13.5, color: _T.inkFaint)),
              const SizedBox(height: 28),
            ],
            _FieldLabel('Email'),
            const SizedBox(height: 7),
            _GlassField(
              controller: _emailController,
              hint: 'you@school.edu',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter your email' : null,
            ),
            const SizedBox(height: 18),
            _FieldLabel('Password'),
            const SizedBox(height: 7),
            _GlassField(
              controller: _passwordController,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
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
            const SizedBox(height: 26),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _T.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _T.primary.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                      _T.primaryDeep.withOpacity(0.15)),
                ),
                onPressed: _isLoading ? null : _login,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoading
                      ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    key: ValueKey('label'),
                    'Sign in',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     const Text("Don't have an account?",
            //         style: TextStyle(fontSize: 13, color: _T.inkFaint)),
            //     TextButton(
            //       onPressed: _isLoading ? null : _goToRegister,
            //       style: TextButton.styleFrom(
            //         foregroundColor: _T.primary,
            //         padding: const EdgeInsets.symmetric(horizontal: 6),
            //         minimumSize: Size.zero,
            //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //       ),
            //       child: const Text('Create one',
            //           style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  LEFT BRANDING PANEL (web only)
// ═════════════════════════════════════════════════════════════
class _BrandPanel extends StatelessWidget {
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
          // Soft decorative circles for depth
          Positioned(
            top: -80,
            right: -60,
            child: _softCircle(240, 0.10),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _softCircle(300, 0.08),
          ),
          Positioned(
            bottom: 140,
            right: 60,
            child: _softCircle(90, 0.14),
          ),
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
                    const Text('Run your whole campus\nfrom one calm place.',
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                            letterSpacing: -0.8,
                            color: Colors.white)),
                    const SizedBox(height: 16),
                    Text(
                      'Admissions, attendance, fees and staff — one system that keeps your school moving.',
                      style: TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: Colors.white.withOpacity(0.82)),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _statChip('Attendance'),
                        const SizedBox(width: 10),
                        _statChip('Fees'),
                        const SizedBox(width: 10),
                        _statChip('Payroll'),
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

  Widget _softCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _statChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  SHARED FORM PRIMITIVES (used by both Login & Register)
// ═════════════════════════════════════════════════════════════
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w700, color: _T.ink));
  }
}

class _GlassField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _GlassField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  State<_GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<_GlassField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
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
          prefixIcon: Icon(widget.icon,
              size: 19, color: _focused ? _T.primary : _T.inkFaint),
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