import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart'; // Make sure google_fonts is in pubspec.yaml

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = !kIsWeb && MediaQuery.of(context).size.width < 600;
    final logoSize = isMobile ? 120.0 : 180.0;
    final fontSize = isMobile ? 28.0 : 42.0;
    final subFontSize = isMobile ? 12.0 : 16.0;
    final loaderSize = isMobile ? 24.0 : 30.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FA), // matches dashboard bg
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ─── Logo with shadow ───
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/EducoreLogo.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Gradient Text "EduCore System" ───
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF4C3FCB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'EduCore System',
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white, // will be replaced by shader
                  shadows: [
                    Shadow(
                      color: Color(0xFF6C5CE7).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ─── Tagline ───
            Text(
              'Campus Management Suite',
              style: TextStyle(
                fontSize: subFontSize,
                color: const Color(0xFF9598AC),
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // ─── Loader ───
            SizedBox(
              width: loaderSize,
              height: loaderSize,
              child: const CircularProgressIndicator(
                color: Color(0xFF6C5CE7),
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 16),

            // ─── Loading text ───
            Text(
              'Loading your campus...',
              style: TextStyle(
                fontSize: subFontSize * 0.9,
                color: const Color(0xFF9598AC).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}