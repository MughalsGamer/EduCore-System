import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';  // Correct import
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/accountant_dashboard.dart';
import 'screens/teacher_dashboard.dart';

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'School Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Roboto',
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.user == null) {
      return const LoginScreen();
    }
    switch (auth.role) {
      case 'admin':
        return const AdminDashboard();
      case 'accountant':
        return const AccountantDashboard();
      case 'teacher':
        return const TeacherDashboard();
      default:
        return const LoginScreen();
    }
  }
}