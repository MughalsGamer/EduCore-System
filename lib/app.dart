import 'package:educoresystem/providers/subject_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/class_provider.dart';
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/fee_provider.dart';
import 'providers/expense_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ClassProvider>(create: (_) => ClassProvider()),
        ChangeNotifierProvider<StudentProvider>(create: (_) => StudentProvider()),
        ChangeNotifierProvider<StaffProvider>(create: (_) => StaffProvider()),
        ChangeNotifierProvider<FeeProvider>(create: (_) => FeeProvider()),
        ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => MuddulProvider()..startListening()),
      ],
      child: MaterialApp(
        title: 'School Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
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
    // Single dashboard for all roles
    return const DashboardScreen();
  }
}