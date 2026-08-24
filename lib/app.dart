//
// import 'package:educoresystem/providers/admission_provider.dart';
// import 'package:educoresystem/providers/app_user_provider.dart';
// import 'package:educoresystem/providers/attendance_provider.dart';
// import 'package:educoresystem/providers/class_attendance_provider.dart';
// import 'package:educoresystem/providers/class_attendance_report_provider.dart';
// import 'package:educoresystem/providers/employee_transaction_provider.dart';
// import 'package:educoresystem/providers/event_provider.dart';
// import 'package:educoresystem/providers/exam_result_card_provider.dart';
// import 'package:educoresystem/providers/fee_collection_provider.dart';
// import 'package:educoresystem/providers/salary_adjustment_history_provider.dart';
// import 'package:educoresystem/providers/salary_provider.dart';
// import 'package:educoresystem/providers/school_setting_prodvider.dart';
// import 'package:educoresystem/providers/subject_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'providers/auth_provider.dart';
// import 'providers/class_provider.dart';
// import 'providers/student_provider.dart';
// import 'providers/teacher_provider.dart';
// import 'providers/fee_provider.dart';
// import 'providers/expense_provider.dart';
// import 'screens/login_screen.dart';
// import 'screens/dashboard_screen.dart';
//
// // ★ NEW — Global RouteObserver so any screen can subscribe as a
// // RouteAware and get notified (didPopNext) when a pushed screen on
// // top of it is popped and it becomes visible again. Used by
// // AttendanceScreen to reset to the current date and auto-refresh
// // whenever the user returns to it (e.g. from Attendance History).
// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
//
// class SchoolApp extends StatelessWidget {
//   const SchoolApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AdmissionProvider()),
//         ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
//         ChangeNotifierProvider<ClassProvider>(create: (_) => ClassProvider()),
//         ChangeNotifierProvider<StudentProvider>(create: (_) => StudentProvider()),
//         ChangeNotifierProvider<StaffProvider>(create: (_) => StaffProvider()),
//         ChangeNotifierProxyProvider<StaffProvider, AttendanceProvider>(
//           create: (context) => AttendanceProvider(context.read<StaffProvider>()),
//           update: (context, staffProvider, attendanceProvider) {
//             return attendanceProvider ?? AttendanceProvider(staffProvider);
//           },
//         ),
//         ChangeNotifierProvider<FeeProvider>(create: (_) => FeeProvider()),
//         ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
//         ChangeNotifierProvider(create: (_) => MuddulProvider()..startListening()),
//         ChangeNotifierProvider(create: (_) => SchoolSettingsProvider()),
//         ChangeNotifierProvider(create: (_) => AppUserProvider()),
//         ChangeNotifierProvider(create: (_) => SalaryHistoryProvider()),
//         ChangeNotifierProvider(create: (_) => StaffTransactionProvider()),
//         ChangeNotifierProvider(create: (_) => SalaryProvider()),   // ← ADD THIS
//         ChangeNotifierProvider(create: (_) => FeeCollectionProvider()),
//         ChangeNotifierProvider(create: (_) => ClassAttendanceProvider()),
//         ChangeNotifierProvider(create: (_) => ClassAttendanceReportProvider()),
//         ChangeNotifierProvider(create: (_) => ExamResultCardProvider()),
//         ChangeNotifierProvider(create: (_) => EventProvider()), // ★ ADD THIS
//
//
//       ],
//       child: MaterialApp(
//         title: 'School Management',
//         debugShowCheckedModeBanner: false,
//         navigatorObservers: [routeObserver], // ★ NEW
//         theme: ThemeData(
//           primarySwatch: Colors.indigo,
//           fontFamily: 'Roboto',
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ),
//         home: const AuthGate(),
//       ),
//     );
//   }
// }
//
// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context);
//     if (auth.user == null) {
//       return const LoginScreen();
//     }
//     // Single dashboard for all roles
//     return const DashboardScreen();
//   }
// }


import 'package:educoresystem/providers/admission_provider.dart';
import 'package:educoresystem/providers/app_user_provider.dart';
import 'package:educoresystem/providers/attendance_provider.dart';
import 'package:educoresystem/providers/class_attendance_provider.dart';
import 'package:educoresystem/providers/class_attendance_report_provider.dart';
import 'package:educoresystem/providers/employee_transaction_provider.dart';
import 'package:educoresystem/providers/event_provider.dart';
import 'package:educoresystem/providers/exam_result_card_provider.dart';
import 'package:educoresystem/providers/fee_collection_provider.dart';
import 'package:educoresystem/providers/salary_adjustment_history_provider.dart';
import 'package:educoresystem/providers/salary_provider.dart';
import 'package:educoresystem/providers/school_setting_prodvider.dart';
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
import 'screens/splash_screen.dart'; // ⬅️ NEW import

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdmissionProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ClassProvider>(create: (_) => ClassProvider()),
        ChangeNotifierProvider<StudentProvider>(create: (_) => StudentProvider()),
        ChangeNotifierProvider<StaffProvider>(create: (_) => StaffProvider()),
        ChangeNotifierProxyProvider<StaffProvider, AttendanceProvider>(
          create: (context) => AttendanceProvider(context.read<StaffProvider>()),
          update: (context, staffProvider, attendanceProvider) {
            return attendanceProvider ?? AttendanceProvider(staffProvider);
          },
        ),
        ChangeNotifierProvider<FeeProvider>(create: (_) => FeeProvider()),
        ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => MuddulProvider()..startListening()),
        ChangeNotifierProvider(create: (_) => SchoolSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AppUserProvider()),
        ChangeNotifierProvider(create: (_) => SalaryHistoryProvider()),
        ChangeNotifierProvider(create: (_) => StaffTransactionProvider()),
        ChangeNotifierProvider(create: (_) => SalaryProvider()),
        ChangeNotifierProvider(create: (_) => FeeCollectionProvider()),
        ChangeNotifierProvider(create: (_) => ClassAttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ClassAttendanceReportProvider()),
        ChangeNotifierProvider(create: (_) => ExamResultCardProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'School Management',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
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

// ─── AuthGate with Splash Screen ───
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: auth.isLoading
          ? const SplashScreen(key: ValueKey('splash'))
          : (auth.user == null
          ? const LoginScreen(key: ValueKey('login'))
          : const DashboardScreen(key: ValueKey('dashboard'))),
    );
  }
}