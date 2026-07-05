import 'package:flutter/material.dart';

/// Shared design tokens for the Attendance module.
///
/// Centralizing this avoids the previous pattern of every screen
/// redefining its own `_purple`, its own status color map, and its own
/// spacing constants (which had already drifted slightly out of sync
/// between screens).
class AttendanceTheme {
  AttendanceTheme._();

  // ── Brand ──
  static const primary = Color(0xFF534AB7);
  static const primaryDark = Color(0xFF433C93);
  static const primaryLight = Color(0xFFEEEDFE);
  static const surfaceMuted = Color(0xFFF6F6F9);

  // ── Neutrals ──
  static const border = Color(0xFFE6E6EC);
  static const borderStrong = Color(0xFFD3D3DE);
  static const textPrimary = Color(0xFF1D1B2E);
  static const textSecondary = Color(0xFF6B697D);
  static const textMuted = Color(0xFF9997A8);

  // ── Status semantics ──
  static const present = Color(0xFF2F7A3C);
  static const absent = Color(0xFFC23B5F);
  static const leave = Color(0xFFB07106);
  static const halfDay = Color(0xFF1E6FBF);

  static const Map<String, Color> statusColors = {
    'Present': present,
    'Absent': absent,
    'Leave': leave,
    'Half Day': halfDay,
  };

  static const Map<String, IconData> statusIcons = {
    'Present': Icons.check_circle_rounded,
    'Absent': Icons.cancel_rounded,
    'Leave': Icons.beach_access_rounded,
    'Half Day': Icons.incomplete_circle_rounded,
  };

  static Color statusColor(String status) =>
      statusColors[status] ?? textMuted;

  static IconData statusIcon(String status) =>
      statusIcons[status] ?? Icons.circle_outlined;

  // ── Breakpoint ──
  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  // ── Reusable text styles ──
  static const h1 = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary);
  static const h2 = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary);
  static const label = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary);
  static const body = TextStyle(fontSize: 13, color: textPrimary);
  static const caption = TextStyle(fontSize: 11, color: textMuted);

  static BoxDecoration card({Color? color, double radius = 14}) =>
      BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      );

  static InputDecoration fieldDecoration(String hint, {Widget? prefixIcon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: textMuted),
        prefixIcon: prefixIcon,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      );
}

/// A small status pill used consistently across list rows, calendar dots,
/// and picker sheets — the one visual signature the whole module shares.
class StatusPill extends StatelessWidget {
  final String status;
  final bool filled;
  final VoidCallback? onTap;
  final bool selected;

  const StatusPill({
    super.key,
    required this.status,
    this.filled = false,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AttendanceTheme.statusColor(status);
    final isFilled = filled || selected;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isFilled ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(isFilled ? 0 : 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AttendanceTheme.statusIcon(status),
            size: 14,
            color: isFilled ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFilled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: child,
    );
  }
}

/// Small colored dot used inside calendar day cells (compact form of a
/// status indicator, where a full pill would not fit).
class StatusDot extends StatelessWidget {
  final String status;
  const StatusDot({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AttendanceTheme.statusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Consistent empty-state block used across all attendance screens.
class AttendanceEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AttendanceEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AttendanceTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AttendanceTheme.primary, size: 26),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AttendanceTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: AttendanceTheme.textMuted)),
        ],
      ),
    );
  }
}

/// Consistent inline error banner (used when a Firestore call fails, so
/// the user gets an actionable message instead of a silently stuck
/// loading spinner or a blank screen).
class AttendanceErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AttendanceErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AttendanceTheme.absent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AttendanceTheme.absent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AttendanceTheme.absent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 12.5, color: AttendanceTheme.textPrimary)),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AttendanceTheme.absent)),
          ),
        ],
      ),
    );
  }
}