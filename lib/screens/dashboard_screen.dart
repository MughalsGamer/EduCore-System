//
//
// import 'dart:convert';
// import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:educoresystem/screens/register_user.dart';
// import 'package:educoresystem/screens/result_card_management/exam_result_card_form_screen.dart';
// import 'package:educoresystem/screens/result_card_management/result_card_management.dart';
// import 'package:educoresystem/screens/salary_managemnet/generate_salary_screen.dart';
// import 'package:educoresystem/screens/salary_managemnet/salary_list_screen.dart';
// import 'package:educoresystem/screens/salary_managemnet/salary_management_screen.dart';
// import 'package:educoresystem/screens/school%20setting/school_setting.dart';
// import 'package:educoresystem/screens/student_management/student_attendance_report_screen.dart';
// import 'package:educoresystem/screens/subject_management/subject%20list.dart';
// import 'package:educoresystem/screens/teacher_management/Staff%20Profile.dart';
// import 'package:educoresystem/screens/teacher_management/add_teacher.dart';
// import 'package:educoresystem/screens/teacher_management/add_employee_transaction.dart';
// import 'package:educoresystem/screens/teacher_management/history_transaction_screen.dart';
// import 'package:educoresystem/screens/teacher_management/staff_id_cards_screen.dart';
// import 'package:educoresystem/screens/teacher_management/staff_list_screen.dart';
// import 'package:educoresystem/screens/teacher_management/academy_staff_list_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/teacher.dart';
// import '../models/event.dart';
// import '../providers/auth_provider.dart';
// import '../providers/event_provider.dart';
// import '../providers/school_setting_prodvider.dart';
// import '../providers/teacher_provider.dart';
// import '../providers/student_provider.dart';
// import '../providers/fee_collection_provider.dart';
// import 'admission mangement/admission_list_screen.dart';
//
// import 'attendance_management/attendance_screen.dart';
// import 'class_management/class_attendance_report_screen.dart';
// import 'class_management/class_attendance_screen.dart';
//
// import 'event/add_edit_event_screen.dart';
// import 'event/event_list_screen.dart';
// import 'family_management/family management.dart';
// import 'fee_management/fee_collection_history_screen.dart';
// import 'fee_management/fee_collection_screen.dart';
// import 'fee_management/generate_challan_screen.dart';
// import 'student_management/student_list.dart';
// import 'teacher_management/teacher_list.dart';
// import 'class_management/class_list.dart';
// import 'class_management/add_class.dart';
// import 'subject_management/add_edit_subject.dart';
// import 'admission mangement/add_admission_screen.dart';
//
// // ═════════════════════════════════════════════════════════════
// //  DESIGN TOKENS — "EduCore Glass" system (refined)
// // ═════════════════════════════════════════════════════════════
// class _T {
//   static const bg = Color(0xFFF6F7FC); // softer background
//   static const ink = Color(0xFF1A1D2E);
//   static const inkSoft = Color(0xFF6B7087);
//   static const inkFaint = Color(0xFFA0A5B8);
//
//   static const primary = Color(0xFF6C5CE7);
//   static const primaryDeep = Color(0xFF4C3FCB);
//   static const primarySoft = Color(0xFFEFECFE);
//
//   static const teal = Color(0xFF0F9D6C);
//   static const tealSoft = Color(0xFFE3F7EE);
//   static const blue = Color(0xFF1C7ED6);
//   static const blueSoft = Color(0xFFE7F2FD);
//   static const amber = Color(0xFFD97706);
//   static const amberSoft = Color(0xFFFCEEDA);
//   static const rose = Color(0xFFDC4C64);
//   static const roseSoft = Color(0xFFFCE9EC);
//   static const cyan = Color(0xFF0AA9C9);
//   static const cyanSoft = Color(0xFFE1F6FA);
//
//   static const borderSoft = Color(0xFFE9EBF3);
//
//   static BoxDecoration glass({
//     double radius = 18,
//     Color tint = Colors.white,
//     double opacity = 0.75,
//     List<BoxShadow>? shadow,
//   }) {
//     return BoxDecoration(
//       color: tint.withOpacity(opacity),
//       borderRadius: BorderRadius.circular(radius),
//       border: Border.all(color: Colors.white.withOpacity(0.8), width: 0.8),
//       boxShadow: shadow ??
//           [
//             BoxShadow(
//               color: const Color(0xFF3B3F6B).withOpacity(0.04),
//               blurRadius: 16,
//               offset: const Offset(0, 6),
//               spreadRadius: -4,
//             ),
//           ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Models (unchanged)
// // ─────────────────────────────────────────────
// class _NavItem {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;
//   final int? badge;
//   const _NavItem(this.label, this.icon, this.onTap, {this.badge});
// }
//
// class _NavGroup {
//   final String label;
//   final IconData icon;
//   final List<String> memberLabels;
//   const _NavGroup(this.label, this.icon, this.memberLabels);
// }
//
// class _StatItem {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
//   final Color colorSoft;
//   final bool isLoading;
//   final bool isLive;
//   const _StatItem(this.label, this.value, this.icon, this.color, this.colorSoft,
//       {this.isLoading = false, this.isLive = false});
// }
//
// class _QuickAction {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _QuickAction(this.label, this.icon, this.onTap);
// }
//
// // ─────────────────────────────────────────────
// //  Dashboard (main)
// // ─────────────────────────────────────────────
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen>
//     with TickerProviderStateMixin {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   int _mobileNavIndex = 0;
//
//   Widget? _mainContentWidget;
//   String? _selectedLabel;
//   Widget? _rightPanelWidget;
//
//   late final Map<String, Widget Function()> _screenBuilders;
//
//   List<_NavItem>? _navItemsCache;
//   String? _navItemsCacheRole;
//   List<_QuickAction>? _quickActionsCache;
//
//   Stream<QuerySnapshot>? _todayAttendanceStream;
//   Stream<QuerySnapshot>? _classesStream;
//   String? _todayAttendanceStreamDate;
//
//   late final AnimationController _entrance;
//
//   final Set<String> _collapsedGroups = {};
//
//   // ★ For double‑back‑to‑exit
//   DateTime? _lastBackPressed;
//
//   // ✅ Bottom nav tab labels, in display order (index 0 = Dashboard)
//   static const List<String> _bottomNavLabels = [
//     'Dashboard',
//     'Students',
//     'Attendance',
//     'Fee Collection',
//     'Teachers',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // ✅ Initialize explicitly in initState (instead of a `late final` inline
//     // initializer on the field) so the AnimationController is guaranteed to
//     // be created during a valid widget-tree frame. The inline-initializer
//     // form could get lazily created/ticked in a way that raced with
//     // dispose() during hot reload, causing "Looking up a deactivated
//     // widget's ancestor is unsafe" when TickerProviderStateMixin tried to
//     // look up TickerMode on an already-deactivated element.
//     _entrance = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 450),
//     )..forward();
//     _mainContentWidget = _buildDashboardContent();
//     _selectedLabel = 'Dashboard';
//     _mobileNavIndex = 0; // Ensure bottom nav is on Dashboard
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final settingsProvider = context.read<SchoolSettingsProvider>();
//       settingsProvider.loadSettings();
//       settingsProvider.listenToSettings();
//
//       context.read<EventProvider>().listenToEvents();
//
//       context.read<StudentProvider>();
//       final staffProvider = context.read<StaffProvider>();
//       staffProvider.fetchAllLists();
//       context.read<FeeCollectionProvider>().loadHistory();
//     });
//
//     _screenBuilders = {
//       'Dashboard': () => _buildDashboardContent(),
//       'Subjects': () => const MuddulListScreen(showAppBar: false, showFAB: false),
//       'Classes': () => const ClassesListScreen(showAppBar: false, showFAB: false),
//       'Admissions': () => const AdmissionListScreen(showAppBar: false, showFAB: false),
//       'Students': () => const StudentListScreen(),
//       'Class Attendance': () => const ClassAttendanceScreen(showAppBar: false),
//       'Class Attendance Report': () => const ClassAttendanceReportScreen(),
//       'Student Attendance Report': () => const StudentAttendanceReportScreen(),
//       'Teachers': () => const TeacherListScreen(),
//       'School Staff': () => const StaffListScreen(),
//       'Academy Staff': () => const AcademyStaffListScreen(),
//       'Family': () => const FamilyManagementScreen(),
//       'Generate Challan': () => const GenerateChallanScreen(),
//       'Fee Collection': () => const FeeCollectionHistoryScreen(),
//       'Exam Result Cards': () => const StudentWiseResultCardsScreen(),
//       'New Exam Result Card': () => ExamResultCardFormScreen(),
//       'Register User': () => const RegisterUserScreen(),
//       'School Settings': () => const SchoolSettingsScreen(showAppBar: false),
//       'ID Cards': () => const StaffIdCardsScreen(showAppBar: false),
//       'Attendance': () => const AttendanceScreen(),
//       'Events': () => EventListScreen(
//         showAppBar: false,
//         showFAB: true,
//         onAddOrEdit: (existingEvent) => _openEventForm(existingEvent),
//       ),
//       'Add Subject': () => AddEditMuddulScreen(
//         showAppBar: false,
//         onSaved: () => _closeRightPanel(),
//       ),
//       'Add Class': () => AddEditClassScreen(
//         showAppBar: false,
//         onSaved: () => _closeRightPanel(),
//       ),
//       'New Admission': () => AdmissionFormScreen(
//         showAppBar: false,
//         onSaved: () => _closeRightPanel(),
//       ),
//       'Add Staff/Teacher': () => AddEditStaffScreen(
//         showAppBar: false,
//         onSaved: () => _closeRightPanel(),
//       ),
//       'Generate Salary': () => const GenerateSalaryScreen(showAppBar: false),
//       'Salary List': () => const SalaryListScreen(),
//       'Salary Adjustment': () => const SalaryManagementScreen(),
//       'Add Transaction': () => AddStaffTransactionScreen(
//         showAppBar: false,
//         onSaved: () => _closeRightPanel(),
//       ),
//       'Transaction History': () => const StaffTransactionHistoryScreen(showAppBar: false),
//     };
//   }
//
//   @override
//   void dispose() {
//     _entrance.dispose();
//     super.dispose();
//   }
//
//   static const _needsAppBarWrapperOnMobilePush = <String>{};
//
//   Widget _pushMobileScreen(String label) {
//     final screen = _screenBuilders[label]!();
//     if (!_needsAppBarWrapperOnMobilePush.contains(label)) return screen;
//     return Scaffold(
//       backgroundColor: _T.bg,
//       appBar: AppBar(
//         title: Text(label),
//         backgroundColor: Colors.white,
//         foregroundColor: _T.ink,
//         elevation: 0,
//         surfaceTintColor: Colors.white,
//       ),
//       body: screen,
//     );
//   }
//
//   // ✅ Derive the bottom-nav highlighted index from the currently selected label,
//   // instead of relying on a separately-tracked int that can go stale when the
//   // user navigates via the sidebar/drawer or presses back from a pushed screen.
//   int _bottomNavIndexForLabel(String? label) {
//     final idx = _bottomNavLabels.indexOf(label ?? 'Dashboard');
//     return idx == -1 ? 0 : idx;
//   }
//
//   // ✅ SINGLE centralized helper for every mobile push-navigation in this
//   // screen. Everything that used to call `Navigator.push(...).then(...)`
//   // separately (sidebar items, quick actions, "View all" on Events) now
//   // routes through here. Having exactly one code path means there's no risk
//   // of a stale closure, a missed `.then()`, or two different reset
//   // implementations drifting out of sync — which was the root cause of the
//   // bottom nav sometimes not returning to "Dashboard".
//   //
//   // `await`ing the push (rather than chaining `.then`) also guarantees the
//   // reset always runs on *this* State instance after the route is popped,
//   // no matter how the pop happened (back button, back arrow, swipe-back).
//   Future<void> _pushMobileAndReturnToDashboard(String label) async {
//     setState(() {
//       _selectedLabel = label;
//       _mobileNavIndex = _bottomNavIndexForLabel(label);
//     });
//
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => _pushMobileScreen(label)),
//     );
//
//     if (!mounted) return;
//     setState(() {
//       _selectedLabel = 'Dashboard';
//       _mobileNavIndex = 0;
//     });
//   }
//
//   List<_NavItem> _navItems(String role) {
//     if (_navItemsCache != null && _navItemsCacheRole == role) {
//       return _navItemsCache!;
//     }
//
//     VoidCallback go(String label) => () {
//       if (MediaQuery.of(context).size.width >= 700) {
//         setState(() {
//           _mainContentWidget = _screenBuilders[label]!();
//           _selectedLabel = label;
//           _rightPanelWidget = null;
//         });
//       } else if (label == 'Dashboard') {
//         setState(() {
//           _selectedLabel = 'Dashboard';
//           _mobileNavIndex = 0;
//         });
//         Navigator.popUntil(context, (route) => route.isFirst);
//       } else {
//         // ✅ Route through the single centralized helper (see
//         // `_pushMobileAndReturnToDashboard`) so every push/return path is
//         // identical and the bottom nav reliably re-selects Dashboard.
//         _pushMobileAndReturnToDashboard(label);
//       }
//     };
//
//     final all = <_NavItem>[
//       _NavItem('Dashboard', Icons.space_dashboard_rounded, go('Dashboard')),
//       _NavItem('Attendance', Icons.fact_check_rounded, go('Attendance')),
//       _NavItem('Class Attendance', Icons.how_to_reg_rounded, go('Class Attendance')),
//       _NavItem('Class Attendance Report', Icons.summarize_rounded, go('Class Attendance Report')),
//       _NavItem('Student Attendance Report', Icons.assignment_ind_rounded, go('Student Attendance Report')),
//
//       _NavItem('Admissions', Icons.how_to_reg_rounded, go('Admissions')),
//       _NavItem('Students', Icons.people_alt_rounded, go('Students')),
//       _NavItem('Family', Icons.family_restroom_rounded, go('Family')),
//       _NavItem('Classes', Icons.class_rounded, go('Classes')),
//       _NavItem('Subjects', Icons.menu_book_rounded, go('Subjects')),
//       _NavItem('Exam Result Cards', Icons.workspace_premium_rounded, go('Exam Result Cards')),
//
//       _NavItem('Register User', Icons.person_add_alt_1_rounded, go('Register User')),
//       _NavItem('Teachers', Icons.person_rounded, go('Teachers')),
//       _NavItem('School Staff', Icons.badge_rounded, go('School Staff')),
//       _NavItem('Academy Staff', Icons.groups_rounded, go('Academy Staff')),
//       _NavItem('ID Cards', Icons.credit_card_rounded, go('ID Cards')),
//
//       _NavItem('Generate Challan', Icons.receipt_long_rounded, go('Generate Challan')),
//       _NavItem('Fee Collection', Icons.payments_rounded, go('Fee Collection')),
//
//       _NavItem('Generate Salary', Icons.request_quote_rounded, go('Generate Salary')),
//       _NavItem('Salary List', Icons.format_list_bulleted_rounded, go('Salary List')),
//       _NavItem('Salary Adjustment', Icons.tune_rounded, go('Salary Adjustment')),
//       _NavItem('Transaction History', Icons.history_rounded, go('Transaction History')),
//
//       _NavItem('Events', Icons.celebration_rounded, go('Events')),
//
//       if (role.toLowerCase() == 'admin')
//         _NavItem('School Settings', Icons.settings_rounded, go('School Settings')),
//     ];
//
//     _navItemsCache = all;
//     _navItemsCacheRole = role;
//     return all;
//   }
//
//   static const _groups = <_NavGroup>[
//     _NavGroup('Overview', Icons.dashboard_customize_rounded, ['Dashboard']),
//     _NavGroup('Attendance', Icons.fact_check_rounded, [
//       'Attendance', 'Class Attendance', 'Class Attendance Report', 'Student Attendance Report',
//     ]),
//     _NavGroup('Admissions & Students', Icons.school_rounded, [
//       'Admissions', 'Students', 'Family', 'Classes', 'Subjects', 'Exam Result Cards',
//     ]),
//     _NavGroup('People', Icons.groups_2_rounded, [
//       'Register User', 'Teachers', 'School Staff', 'Academy Staff', 'ID Cards',
//     ]),
//     _NavGroup('Fees & Billing', Icons.payments_rounded, [
//       'Generate Challan', 'Fee Collection',
//     ]),
//     _NavGroup('Payroll', Icons.account_balance_wallet_rounded, [
//       'Generate Salary', 'Salary List', 'Salary Adjustment', 'Transaction History',
//     ]),
//     _NavGroup('Events', Icons.celebration_rounded, ['Events']),
//     _NavGroup('Settings', Icons.settings_rounded, ['School Settings']),
//   ];
//
//   List<_QuickAction> _quickActions() {
//     if (_quickActionsCache != null) return _quickActionsCache!;
//     _quickActionsCache = [
//       _QuickAction('Add Subject', Icons.menu_book_rounded, () => _openQuickAction('Add Subject')),
//       _QuickAction('Add Class', Icons.class_rounded, () => _openQuickAction('Add Class')),
//       _QuickAction('New Admission', Icons.person_add_alt_1_rounded, () => _openQuickAction('New Admission')),
//       _QuickAction('Add Staff/Teacher', Icons.badge_rounded, () => _openQuickAction('Add Staff/Teacher')),
//       _QuickAction('Add Transaction', Icons.add_card_rounded, () => _openQuickAction('Add Transaction')),
//       _QuickAction('Mark Attendance', Icons.fact_check_rounded, () {
//         if (MediaQuery.of(context).size.width >= 700) {
//           setState(() {
//             _mainContentWidget = _screenBuilders['Attendance']!();
//             _selectedLabel = 'Attendance';
//             _rightPanelWidget = null;
//           });
//         } else {
//           _pushMobileAndReturnToDashboard('Attendance');
//         }
//       }),
//     ];
//     return _quickActionsCache!;
//   }
//
//   void _openEventForm(EventModel? existingEvent) {
//     final isWide = MediaQuery.of(context).size.width >= 700;
//
//     if (isWide) {
//       setState(() {
//         _rightPanelWidget = AddEditEventScreen(
//           showAppBar: false,
//           existingEvent: existingEvent,
//           onSaved: _closeRightPanel,
//         );
//       });
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => AddEditEventScreen(
//             existingEvent: existingEvent,
//             onSaved: () => Navigator.pop(context),
//           ),
//         ),
//       );
//     }
//   }
//
//   void _openProfile(StaffMember staff, {Map<String, String>? classIdToName}) {
//     final isWide = MediaQuery.of(context).size.width >= 700;
//     final mapping = classIdToName ?? {};
//
//     if (isWide) {
//       setState(() {
//         _rightPanelWidget = _buildProfilePanel(staff, mapping);
//       });
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => StaffProfileScreen(
//             staff: staff,
//             classIdToName: mapping,
//           ),
//         ),
//       );
//     }
//   }
//
//   Widget _buildProfilePanel(StaffMember staff, Map<String, String> classIdToName) {
//     return Column(
//       children: [
//         _buildPanelHeaderCustom('Staff Profile', Icons.person_rounded),
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: StaffProfileView(
//               staff: staff,
//               classIdToName: classIdToName,
//               onClose: _closeRightPanel,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _openQuickAction(String key) {
//     if (MediaQuery.of(context).size.width >= 700) {
//       setState(() {
//         _rightPanelWidget = _screenBuilders[key]!();
//       });
//     } else {
//       // ✅ Route through the same centralized helper so returning from a
//       // quick-action form (Add Subject/Class/Admission/Staff/Transaction)
//       // also correctly re-selects "Dashboard" on the bottom nav.
//       _pushMobileAndReturnToDashboard(key);
//     }
//   }
//
//   void _closeRightPanel() {
//     setState(() {
//       _rightPanelWidget = null;
//     });
//   }
//
//   // ─── Logout confirmation ───
//   void _confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: _T.inkSoft)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Provider.of<AuthProvider>(context, listen: false).logout();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _T.rose,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Double‑back‑to‑exit handler ───
//   Future<bool> _onWillPop() async {
//     if (_lastBackPressed == null ||
//         DateTime.now().difference(_lastBackPressed!) > const Duration(seconds: 2)) {
//       _lastBackPressed = DateTime.now();
//       // Show a snackbar message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Press back again to exit'),
//           duration: Duration(seconds: 2),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
//         ),
//       );
//       return false;
//     }
//     return true; // exit
//   }
//
//   // ═══════════════════════════════════════════
//   //  SIDEBAR (updated logout with confirmation)
//   // ═══════════════════════════════════════════
//   Widget _sidebarContent(String role, String userEmail, {required bool isDrawer}) {
//     final items = _navItems(role);
//     final itemsByLabel = {for (final i in items) i.label: i};
//     final initials = userEmail.length >= 2
//         ? userEmail.substring(0, 2).toUpperCase()
//         : userEmail.toUpperCase();
//
//     final schoolSettings = context.watch<SchoolSettingsProvider>().settings;
//     final schoolName = schoolSettings.schoolName.trim().isEmpty
//         ? 'EduCore'
//         : schoolSettings.schoolName;
//     final schoolTagline = schoolSettings.city.trim().isEmpty
//         ? 'Campus Suite'
//         : schoolSettings.city;
//
//     ImageProvider? logoImage;
//     if (schoolSettings.logoBase64 != null && schoolSettings.logoBase64!.isNotEmpty) {
//       try {
//         logoImage = MemoryImage(base64Decode(schoolSettings.logoBase64!));
//       } catch (_) {
//         logoImage = null;
//       }
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
//           child: Row(
//             children: [
//               Container(
//                 width: 46,
//                 height: 46,
//                 decoration: BoxDecoration(
//                   gradient: logoImage != null
//                       ? null
//                       : const LinearGradient(
//                     colors: [_T.primary, _T.primaryDeep],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   color: logoImage != null ? Colors.transparent : null,
//                   borderRadius: BorderRadius.circular(14),
//                   image: logoImage != null
//                       ? DecorationImage(image: logoImage, fit: BoxFit.cover)
//                       : null,
//                   boxShadow: [
//                     BoxShadow(
//                       color: _T.primary.withOpacity(0.35),
//                       blurRadius: 16,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: logoImage == null
//                     ? ClipRRect(
//                   borderRadius: BorderRadius.circular(14),
//                   child: Image.asset(
//                     'assets/images/EducoreLogo.png',
//                     fit: BoxFit.cover,
//                   ),
//                 )
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(schoolName,
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                         style: const TextStyle(
//                             fontSize: 14.5,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: -0.2,
//                             color: _T.ink)),
//                     const SizedBox(height: 1),
//                     Text(schoolTagline,
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                         style: const TextStyle(fontSize: 11.5, color: _T.inkFaint)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           decoration: BoxDecoration(
//             color: _T.primarySoft,
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 15,
//                 backgroundColor: _T.primary,
//                 child: Text(initials,
//                     style: const TextStyle(
//                         fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
//               ),
//               const SizedBox(width: 9),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       userEmail.split('@').first,
//                       style: const TextStyle(
//                           fontSize: 12.5, fontWeight: FontWeight.w700, color: _T.ink),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                     Text(
//                       role.toUpperCase(),
//                       style: const TextStyle(
//                           fontSize: 9, color: _T.primaryDeep, letterSpacing: 0.6,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//             itemCount: _groups.length,
//             itemBuilder: (ctx, i) {
//               final group = _groups[i];
//               final members = group.memberLabels
//                   .where((l) => itemsByLabel.containsKey(l))
//                   .map((l) => itemsByLabel[l]!)
//                   .toList();
//               if (members.isEmpty) return const SizedBox.shrink();
//               final collapsed = _collapsedGroups.contains(group.label);
//
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 4),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     InkWell(
//                       borderRadius: BorderRadius.circular(10),
//                       onTap: () {
//                         setState(() {
//                           if (collapsed) {
//                             _collapsedGroups.remove(group.label);
//                           } else {
//                             _collapsedGroups.add(group.label);
//                           }
//                         });
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
//                         child: Row(
//                           children: [
//                             Icon(group.icon, size: 14, color: _T.inkFaint),
//                             const SizedBox(width: 7),
//                             Expanded(
//                               child: Text(group.label.toUpperCase(),
//                                   style: const TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w700,
//                                       color: _T.inkFaint,
//                                       letterSpacing: 0.7)),
//                             ),
//                             AnimatedRotation(
//                               turns: collapsed ? -0.25 : 0,
//                               duration: const Duration(milliseconds: 200),
//                               child: Icon(Icons.expand_more_rounded,
//                                   size: 15, color: _T.inkFaint.withOpacity(0.7)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     AnimatedCrossFade(
//                       duration: const Duration(milliseconds: 220),
//                       crossFadeState: collapsed
//                           ? CrossFadeState.showFirst
//                           : CrossFadeState.showSecond,
//                       firstChild: const SizedBox.shrink(),
//                       secondChild: Column(
//                         children: members.map((e) => _sbTile(e, isDrawer)).toList(),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//         const Divider(height: 1, color: _T.borderSoft),
//         Padding(
//           padding: const EdgeInsets.all(8),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(10),
//             onTap: () => _confirmLogout(context),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               child: Row(
//                 children: const [
//                   Icon(Icons.logout_rounded, size: 17, color: _T.rose),
//                   SizedBox(width: 9),
//                   Text('Logout',
//                       style: TextStyle(
//                           fontSize: 13, color: _T.rose, fontWeight: FontWeight.w600)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSidebar(String role, String userEmail) {
//     return Drawer(
//       width: 240,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(),
//       child: SafeArea(
//         child: _sidebarContent(role, userEmail, isDrawer: true),
//       ),
//     );
//   }
//
//   Widget _sbTile(_NavItem item, bool isDrawer) {
//     final isActive = item.label == (_selectedLabel ?? '');
//
//     return InkWell(
//       onTap: () {
//         if (isDrawer) Navigator.pop(context);
//         item.onTap();
//       },
//       borderRadius: BorderRadius.circular(10),
//       child: TweenAnimationBuilder<double>(
//         key: ValueKey('${item.label}_$isActive'),
//         tween: Tween(begin: isActive ? 0.92 : 1.0, end: 1.0),
//         duration: const Duration(milliseconds: 220),
//         curve: Curves.easeOutBack,
//         builder: (context, scale, child) {
//           return Transform.scale(
//             scale: isActive ? scale : 1.0,
//             alignment: Alignment.centerLeft,
//             child: child,
//           );
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeOut,
//           margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
//           padding: EdgeInsets.symmetric(
//             horizontal: 10,
//             vertical: isActive ? 10.5 : 9,
//           ),
//           decoration: BoxDecoration(
//             color: isActive ? _T.primary : Colors.transparent,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: isActive
//                 ? [
//               BoxShadow(
//                 color: _T.primary.withOpacity(0.32),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ]
//                 : null,
//           ),
//           child: Row(
//             children: [
//               AnimatedScale(
//                 scale: isActive ? 1.08 : 1.0,
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeOut,
//                 child: Icon(item.icon,
//                     size: 16.5,
//                     color: isActive ? Colors.white : _T.inkSoft),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: AnimatedDefaultTextStyle(
//                   duration: const Duration(milliseconds: 200),
//                   style: TextStyle(
//                     fontSize: isActive ? 13 : 12.5,
//                     fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//                     color: isActive ? Colors.white : _T.ink,
//                   ),
//                   child: Text(
//                     item.label,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//               if (item.badge != null)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
//                   decoration: BoxDecoration(
//                     color: isActive ? Colors.white.withOpacity(0.25) : _T.rose,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text('${item.badge}',
//                       style: const TextStyle(
//                           fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700)),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Premium Stat Card (compact & elegant) ───
//   Widget _statCard(_StatItem s, int index) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: Duration(milliseconds: 350 + index * 60),
//       curve: Curves.easeOutCubic,
//       builder: (context, v, child) {
//         return Opacity(
//           opacity: v.clamp(0.0, 1.0),
//           child: Transform.translate(
//             offset: Offset(0, (1 - v) * 12),
//             child: child,
//           ),
//         );
//       },
//       child: Container(
//         // ✅ Reduced padding (14 -> 11) so the fixed-height card (as low as
//         // ~72px on some narrow/2-column layouts) has enough room for the
//         // icon row + label + value without a RenderFlex overflow.
//         padding: const EdgeInsets.all(11),
//         decoration: _T.glass(radius: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 20,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: s.colorSoft,
//                     borderRadius: BorderRadius.circular(9),
//                   ),
//                   child: Icon(s.icon, color: s.color, size: 14),
//                 ),
//                 const Spacer(),
//                 if (s.isLive)
//                   Container(
//                     width: 5,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: _T.teal,
//                       boxShadow: [
//                         BoxShadow(
//                           color: _T.teal.withOpacity(0.35),
//                           blurRadius: 4,
//                           spreadRadius: 1,
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(s.label,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                     fontSize: 11, color: _T.inkFaint, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 1),
//             s.isLoading
//                 ? const SizedBox(
//               width: 13,
//               height: 13,
//               child: CircularProgressIndicator(strokeWidth: 2, color: _T.primary),
//             )
//                 : FittedBox(
//               fit: BoxFit.scaleDown,
//               alignment: Alignment.centerLeft,
//               child: Text(s.value,
//                   maxLines: 1,
//                   style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: -0.3,
//                       color: _T.ink)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _qaChip(_QuickAction a, int index) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: a.onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: _T.borderSoft),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF3B3F6B).withOpacity(0.04),
//                 blurRadius: 8,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(a.icon, size: 16, color: _T.primary),
//               const SizedBox(width: 6),
//               Flexible(
//                 child: Text(a.label,
//                     style: const TextStyle(
//                         fontSize: 12, fontWeight: FontWeight.w600, color: _T.ink),
//                     overflow: TextOverflow.ellipsis),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _recentFeeRow(String initials, String name, String sub, String amount, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             alignment: Alignment.center,
//             child: Text(initials,
//                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _T.ink)),
//                 Text(sub,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 11, color: _T.inkFaint)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(amount,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _T.ink)),
//         ],
//       ),
//     );
//   }
//
//   String _timeAgo(DateTime d) {
//     final diff = DateTime.now().difference(d);
//     if (diff.inMinutes < 1) return 'Just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
//     if (diff.inHours < 24) return '${diff.inHours}h ago';
//     return '${diff.inDays}d ago';
//   }
//
//   String _initialsOf(String name) {
//     final trimmed = name.trim();
//     if (trimmed.isEmpty) return '?';
//     final parts = trimmed.split(RegExp(r'\s+'));
//     if (parts.length == 1) {
//       return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
//     }
//     return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
//   }
//
//   Widget _eventReminderTile(EventModel event) {
//     final today = DateTime.now();
//     final todayOnly = DateTime(today.year, today.month, today.day);
//     final eventDay = DateTime(event.date.year, event.date.month, event.date.day);
//     final daysLeft = eventDay.difference(todayOnly).inDays;
//
//     String countdownText;
//     Color countdownColor;
//     Color countdownBg;
//     if (daysLeft > 1) {
//       countdownText = '$daysLeft days';
//       countdownColor = _T.primary;
//       countdownBg = _T.primarySoft;
//     } else if (daysLeft == 1) {
//       countdownText = 'Tomorrow';
//       countdownColor = _T.amber;
//       countdownBg = _T.amberSoft;
//     } else if (daysLeft == 0) {
//       countdownText = 'Today';
//       countdownColor = _T.teal;
//       countdownBg = _T.tealSoft;
//     } else {
//       countdownText = 'Passed';
//       countdownColor = _T.inkFaint;
//       countdownBg = const Color(0xFFEDEEF4);
//     }
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 6),
//       padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFAFAFD),
//         borderRadius: BorderRadius.circular(10),
//         border: Border(left: BorderSide(color: countdownColor, width: 3)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(event.title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                         fontSize: 12, fontWeight: FontWeight.w700, color: _T.ink)),
//                 if (event.description.isNotEmpty) ...[
//                   const SizedBox(height: 2),
//                   Text(event.description,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontSize: 10.5, color: _T.inkSoft, height: 1.3)),
//                 ],
//                 const SizedBox(height: 4),
//                 Text(_formatDate(event.date),
//                     style: const TextStyle(fontSize: 9.5, color: _T.inkFaint)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 6),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: countdownBg,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               countdownText,
//               style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: countdownColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionHeader(String title, IconData icon, {Widget? trailing}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               color: _T.primarySoft,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, size: 13, color: _T.primary),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                     fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.1, color: _T.ink)),
//           ),
//           if (trailing != null) trailing,
//         ],
//       ),
//     );
//   }
//
//   Widget _card(Widget child, {EdgeInsetsGeometry? padding}) {
//     return Container(
//       padding: padding ?? const EdgeInsets.all(14),
//       decoration: _T.glass(radius: 16),
//       child: child,
//     );
//   }
//
//   String _formatDate(DateTime d) {
//     const months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
//     return '${d.day} ${months[d.month - 1]} ${d.year}';
//   }
//
//   Widget _buildEventsCard() {
//     return Consumer<EventProvider>(
//       builder: (context, provider, _) {
//         final today = DateTime.now();
//         final todayOnly = DateTime(today.year, today.month, today.day);
//
//         final events = [...provider.events];
//         events.sort((a, b) {
//           final aDay = DateTime(a.date.year, a.date.month, a.date.day);
//           final bDay = DateTime(b.date.year, b.date.month, b.date.day);
//           final aPast = aDay.isBefore(todayOnly);
//           final bPast = bDay.isBefore(todayOnly);
//           if (aPast != bPast) return aPast ? 1 : -1;
//           return aDay.compareTo(bDay);
//         });
//         final preview = events.take(4).toList();
//
//         return _card(
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _sectionHeader(
//                 'Events',
//                 Icons.celebration_rounded,
//                 trailing: TextButton(
//                   onPressed: () {
//                     if (MediaQuery.of(context).size.width >= 700) {
//                       setState(() {
//                         _mainContentWidget = _screenBuilders['Events']!();
//                         _selectedLabel = 'Events';
//                         _rightPanelWidget = null;
//                       });
//                     } else {
//                       _pushMobileAndReturnToDashboard('Events');
//                     }
//                   },
//                   style: TextButton.styleFrom(
//                     foregroundColor: _T.primary,
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                     visualDensity: VisualDensity.compact,
//                   ),
//                   child: const Text('View all',
//                       style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
//                 ),
//               ),
//               if (provider.isLoading && events.isEmpty)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Center(child: CircularProgressIndicator(color: _T.primary)),
//                 )
//               else if (preview.isEmpty)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Icon(Icons.event_busy_rounded, size: 24, color: _T.inkFaint.withOpacity(0.6)),
//                         const SizedBox(height: 4),
//                         const Text('No events scheduled',
//                             style: TextStyle(fontSize: 11.5, color: _T.inkFaint)),
//                       ],
//                     ),
//                   ),
//                 )
//               else
//                 ...preview.map(_eventReminderTile),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // ✅ Bottom nav now derives its "active" tab from `_selectedLabel`
//   // (single source of truth) instead of a separately-tracked int that
//   // could go stale when navigating via sidebar/drawer or via back button.
//   Widget _buildBottomNav(String role) {
//     final items = _navItems(role);
//     final tabs = <_NavItem>[
//       items.firstWhere((n) => n.label == 'Dashboard'),
//       items.firstWhere((n) => n.label == 'Students'),
//       items.firstWhere((n) => n.label == 'Attendance'),
//       items.firstWhere((n) => n.label == 'Fee Collection'),
//       items.firstWhere((n) => n.label == 'Teachers'),
//     ];
//
//     final currentIndex = _bottomNavIndexForLabel(_selectedLabel);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -3)),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: SizedBox(
//           height: 58,
//           child: Row(
//             children: List.generate(tabs.length, (i) {
//               final active = currentIndex == i;
//               return Expanded(
//                 child: InkWell(
//                   onTap: () {
//                     if (i == 0) {
//                       setState(() {
//                         _selectedLabel = 'Dashboard';
//                         _mobileNavIndex = 0;
//                       });
//                       Navigator.popUntil(context, (route) => route.isFirst);
//                       return;
//                     }
//                     // ✅ Just delegate to the nav item's onTap, which now
//                     // routes through the single centralized
//                     // `_pushMobileAndReturnToDashboard` helper. No separate
//                     // setState here — avoids two competing state updates
//                     // racing each other.
//                     tabs[i].onTap();
//                   },
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: active ? _T.primarySoft : Colors.transparent,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(tabs[i].icon,
//                             size: 18, color: active ? _T.primary : _T.inkFaint),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(tabs[i].label,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                               fontSize: 9,
//                               fontWeight: active ? FontWeight.w700 : FontWeight.w500,
//                               color: active ? _T.primary : _T.inkFaint)),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPanelHeaderCustom(String title, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(bottom: BorderSide(color: _T.borderSoft)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 28,
//             height: 28,
//             decoration: BoxDecoration(color: _T.primarySoft, borderRadius: BorderRadius.circular(8)),
//             child: Icon(icon, size: 15, color: _T.primary),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _T.ink)),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close_rounded, size: 18),
//             onPressed: _closeRightPanel,
//             color: _T.inkSoft,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPanelHeader() => _buildPanelHeaderCustom('Add New', Icons.add_rounded);
//
//   // ═══════════════════════════════════════════
//   //  DASHBOARD CONTENT (refreshed design)
//   // ═══════════════════════════════════════════
//   Widget _buildDashboardContent() {
//     final auth = Provider.of<AuthProvider>(context, listen: false);
//     final hour = DateTime.now().hour;
//     final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
//     final userFirst = (auth.user?.email ?? 'there').split('@').first;
//
//     final today = DateTime.now();
//     final todayStr =
//         '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
//
//     if (_todayAttendanceStream == null || _todayAttendanceStreamDate != todayStr) {
//       _todayAttendanceStreamDate = todayStr;
//       _todayAttendanceStream = FirebaseFirestore.instance
//           .collection('attendance')
//           .where('date', isEqualTo: todayStr)
//           .snapshots();
//     }
//     _classesStream ??= FirebaseFirestore.instance
//         .collection('schools')
//         .doc('school1')
//         .collection('classes')
//         .snapshots();
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Greeting card (sleeker)
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [_T.primaryDeep, _T.primary],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: _T.primary.withOpacity(0.25),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                   spreadRadius: -4,
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('$greeting, $userFirst',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                         letterSpacing: -0.2)),
//                 const SizedBox(height: 4),
//                 Text("Here's what's happening across your campus.",
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 18),
//           _sectionHeader('Quick Actions', Icons.bolt_rounded),
//           Wrap(
//             spacing: 6,
//             runSpacing: 6,
//             children: List.generate(
//                 _quickActions().length, (i) => _qaChip(_quickActions()[i], i)),
//           ),
//
//           const SizedBox(height: 20),
//           _sectionHeader('Live Overview', Icons.insights_rounded),
//
//           Consumer2<StudentProvider, StaffProvider>(
//             builder: (context, studentProvider, staffProvider, _) {
//               final totalStudents = studentProvider.students.length;
//               final totalTeachers = staffProvider.teachers.length;
//               final totalStaff =
//                   staffProvider.schoolStaff.length + staffProvider.academyStaff.length;
//
//               return StreamBuilder<QuerySnapshot>(
//                 stream: _classesStream,
//                 builder: (context, classSnap) {
//                   final classCount = classSnap.hasData ? classSnap.data!.docs.length : null;
//
//                   return StreamBuilder<QuerySnapshot>(
//                     stream: _todayAttendanceStream,
//                     builder: (context, attSnap) {
//                       String attendancePct = '—';
//                       if (attSnap.hasData) {
//                         final docs = attSnap.data!.docs;
//                         final markable = docs.where((d) {
//                           final status =
//                               (d.data() as Map<String, dynamic>)['status'] as String? ?? '';
//                           return status.isNotEmpty && status != 'holiday';
//                         }).toList();
//                         if (markable.isNotEmpty) {
//                           final present = markable.where((d) {
//                             final status = (d.data() as Map<String, dynamic>)['status'] as String?;
//                             return status == 'present' || status == 'late';
//                           }).length;
//                           attendancePct = '${(present / markable.length * 100).round()}%';
//                         }
//                       }
//
//                       final stats = <_StatItem>[
//                         _StatItem('Students', '$totalStudents', Icons.people_alt_rounded,
//                             _T.blue, _T.blueSoft, isLive: true),
//                         _StatItem('Teachers & Staff', '${totalTeachers + totalStaff}',
//                             Icons.groups_2_rounded, _T.teal, _T.tealSoft, isLive: true),
//                         _StatItem(
//                             'Classes',
//                             classCount != null ? '$classCount' : '—',
//                             Icons.class_rounded,
//                             _T.amber,
//                             _T.amberSoft,
//                             isLoading: classCount == null),
//                         _StatItem(
//                             "Today's Attendance",
//                             attendancePct,
//                             Icons.fact_check_rounded,
//                             _T.primary,
//                             _T.primarySoft,
//                             isLoading: !attSnap.hasData,
//                             isLive: true),
//                       ];
//
//                       return LayoutBuilder(builder: (ctx, box) {
//                         final w = box.maxWidth;
//                         final isMobile = w < 700;
//                         final crossCount = isMobile ? 2 : 4;
//                         // ✅ Narrow phones (< 360 logical px) get a lower
//                         // (taller-relative) aspect ratio so the stat card's
//                         // icon row + label + value never gets squeezed into
//                         // an overflow — fixes RenderFlex overflow on small
//                         // mobile screens, especially with larger system font
//                         // scaling.
//                         // ✅ Lowered further (was 1.35/1.6) after real-device
//                         // logs showed a 132.4x71.7 card still overflowing by
//                         // ~4px with system font scaling in play. Combined
//                         // with the reduced card padding above, this gives
//                         // reliable headroom across narrow phones.
//                         final aspectRatio = isMobile
//                             ? (w < 360 ? 1.15 : 1.35)
//                             : 1.4;
//                         return GridView.count(
//                           crossAxisCount: crossCount,
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           crossAxisSpacing: 8,
//                           mainAxisSpacing: 8,
//                           childAspectRatio: aspectRatio,
//                           children: List.generate(
//                               stats.length, (i) => _statCard(stats[i], i)),
//                         );
//                       });
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//
//           const SizedBox(height: 20),
//           Consumer<FeeCollectionProvider>(
//             builder: (context, feeProvider, _) {
//               return LayoutBuilder(builder: (ctx, box) {
//                 final wide = box.maxWidth >= 620;
//                 final recentColors = [_T.blue, _T.teal, _T.cyan, _T.amber, _T.rose];
//
//                 final recent = feeProvider.history.take(5).toList();
//
//                 final recentCard = _card(Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _sectionHeader('Recent Fee Collections', Icons.receipt_long_rounded),
//                     if (feeProvider.isLoadingHistory && recent.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 20),
//                         child: Center(child: CircularProgressIndicator(color: _T.primary)),
//                       )
//                     else if (recent.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 20),
//                         child: Center(
//                           child: Text('No payments recorded yet',
//                               style: TextStyle(fontSize: 11.5, color: _T.inkFaint)),
//                         ),
//                       )
//                     else
//                       ...List.generate(recent.length, (i) {
//                         final c = recent[i];
//                         final color = recentColors[i % recentColors.length];
//                         return Column(
//                           children: [
//                             _recentFeeRow(
//                               _initialsOf(c.familyName.isNotEmpty ? c.familyName : c.fatherName),
//                               c.familyName.isNotEmpty ? c.familyName : c.fatherName,
//                               '${c.paymentMethod} · ${_timeAgo(c.paymentDate)}',
//                               'Rs ${c.amount.toStringAsFixed(0)}',
//                               color,
//                             ),
//                             if (i < recent.length - 1)
//                               const Divider(height: 1, color: _T.borderSoft),
//                           ],
//                         );
//                       }),
//                   ],
//                 ));
//
//                 final eventsCard = _buildEventsCard();
//
//                 if (wide) {
//                   return IntrinsicHeight(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(flex: 3, child: recentCard),
//                         const SizedBox(width: 10),
//                         Expanded(flex: 2, child: eventsCard),
//                       ],
//                     ),
//                   );
//                 }
//                 return Column(children: [recentCard, const SizedBox(height: 10), eventsCard]);
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─────────────────────────
//   //  BUILD
//   // ─────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context);
//     final role = auth.role ?? 'teacher';
//     final email = auth.user?.email ?? 'user@school.pk';
//     final isWide = MediaQuery.of(context).size.width >= 700;
//
//     final schoolSettings = context.watch<SchoolSettingsProvider>().settings;
//     final schoolNameForAppBar =
//     schoolSettings.schoolName.trim().isEmpty ? 'Citizens Model School' : schoolSettings.schoolName;
//
//     ImageProvider? appBarLogoImage;
//     if (schoolSettings.logoBase64 != null && schoolSettings.logoBase64!.isNotEmpty) {
//       try {
//         appBarLogoImage = MemoryImage(base64Decode(schoolSettings.logoBase64!));
//       } catch (_) {
//         appBarLogoImage = null;
//       }
//     }
//
//     // Wrap Scaffold with PopScope to handle back button on mobile
//     return PopScope(
//       canPop: false, // we handle it manually
//       onPopInvoked: (bool didPop) async {
//         if (didPop) return;
//         final shouldPop = await _onWillPop();
//         if (shouldPop) {
//           Navigator.of(context).pop();
//         }
//       },
//       child: Scaffold(
//         key: _scaffoldKey,
//         backgroundColor: _T.bg,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           scrolledUnderElevation: 1,
//           leadingWidth: isWide ? 0 : 48,
//           leading: isWide
//               ? null
//               : IconButton(
//             icon: const Icon(Icons.menu_rounded, color: _T.ink),
//             onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//           ),
//           // App bar title — logo center on mobile, left on desktop
//           title: isWide
//               ? Row(
//             children: [
//               SizedBox(
//                 height: 85,
//                 child: Image.asset(
//                   'assets/images/EduCoreSystem.png',
//                   fit: BoxFit.contain,
//                   alignment: Alignment.centerLeft,
//                 ),
//               ),
//               const SizedBox(width: 12),
//             ],
//           )
//               : Center(
//             child: SizedBox(
//               height: 70,
//               // ✅ Bound the width too — Image.asset inside a Center with
//               // only a height constraint tries to size itself to its
//               // intrinsic aspect ratio, which can exceed the AppBar's
//               // narrow title slot on small screens and throw a RenderFlex
//               // overflow. Capping width to a fraction of screen width
//               // fixes this while BoxFit.contain keeps the logo un-stretched.
//               width: MediaQuery.of(context).size.width * 0.55,
//               child: Image.asset(
//                 'assets/images/EduCoreSystem.png',
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//           actions: [
//             if (isWide)
//               Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 320),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.school_outlined, size: 14, color: _T.inkFaint),
//                       const SizedBox(width: 4),
//                       Flexible(
//                         child: Text(schoolNameForAppBar,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 12, color: _T.inkSoft)),
//                       ),
//                       const SizedBox(width: 14),
//                       const Icon(Icons.account_circle_outlined, size: 14, color: _T.inkFaint),
//                       const SizedBox(width: 4),
//                       Flexible(
//                         child: Text(email.split('@').first,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 12, color: _T.inkSoft)),
//                       ),
//                       const SizedBox(width: 12),
//                     ],
//                   ),
//                 ),
//               ),
//             IconButton(
//               icon: const Icon(Icons.logout_rounded, size: 20, color: _T.rose),
//               tooltip: 'Logout',
//               onPressed: () => _confirmLogout(context),
//             ),
//           ],
//         ),
//         drawer: isWide ? null : _buildSidebar(role, email),
//         bottomNavigationBar: isWide ? null : _buildBottomNav(role),
//         body: isWide
//             ? Row(
//           children: [
//             SizedBox(
//               width: 240,
//               child: Container(
//                 color: Colors.white,
//                 child: SafeArea(
//                   child: _sidebarContent(role, email, isDrawer: false),
//                 ),
//               ),
//             ),
//             const VerticalDivider(width: 1, color: _T.borderSoft),
//             Expanded(
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: FadeTransition(
//                       opacity: _entrance,
//                       child: _mainContentWidget ?? const SizedBox.shrink(),
//                     ),
//                   ),
//                   AnimatedPositioned(
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeOut,
//                     top: 0,
//                     right: _rightPanelWidget == null
//                         ? -(MediaQuery.of(context).size.width - 240)
//                         : 0,
//                     bottom: 0,
//                     width: MediaQuery.of(context).size.width - 240,
//                     child: _rightPanelWidget != null
//                         ? Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.10),
//                             blurRadius: 16,
//                             offset: const Offset(-4, 0),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           _buildPanelHeader(),
//                           Expanded(child: _rightPanelWidget!),
//                         ],
//                       ),
//                     )
//                         : const SizedBox.shrink(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         )
//             : (_selectedLabel == 'Dashboard'
//             ? _buildDashboardContent()
//             : _mainContentWidget ?? _buildDashboardContent()),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educoresystem/screens/register_user.dart';
import 'package:educoresystem/screens/result_card_management/exam_result_card_form_screen.dart';
import 'package:educoresystem/screens/result_card_management/result_card_management.dart';
import 'package:educoresystem/screens/salary_managemnet/generate_salary_screen.dart';
import 'package:educoresystem/screens/salary_managemnet/salary_list_screen.dart';
import 'package:educoresystem/screens/salary_managemnet/salary_management_screen.dart';
import 'package:educoresystem/screens/school%20setting/school_setting.dart';
import 'package:educoresystem/screens/student_management/student_attendance_report_screen.dart';
import 'package:educoresystem/screens/subject_management/subject%20list.dart';
import 'package:educoresystem/screens/teacher_management/Staff%20Profile.dart';
import 'package:educoresystem/screens/teacher_management/add_teacher.dart';
import 'package:educoresystem/screens/teacher_management/add_employee_transaction.dart';
import 'package:educoresystem/screens/teacher_management/history_transaction_screen.dart';
import 'package:educoresystem/screens/teacher_management/staff_id_cards_screen.dart';
import 'package:educoresystem/screens/teacher_management/staff_list_screen.dart';
import 'package:educoresystem/screens/teacher_management/academy_staff_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/teacher.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/school_setting_prodvider.dart';
import '../providers/teacher_provider.dart';
import '../providers/student_provider.dart';
import '../providers/fee_collection_provider.dart';
import 'admission mangement/admission_list_screen.dart';

import 'attendance_management/attendance_screen.dart';
import 'class_management/class_attendance_report_screen.dart';
import 'class_management/class_attendance_screen.dart';

import 'event/add_edit_event_screen.dart';
import 'event/event_list_screen.dart';
import 'family_management/family management.dart';
import 'fee_management/fee_collection_history_screen.dart';
import 'fee_management/fee_collection_screen.dart';
import 'fee_management/generate_challan_screen.dart';
import 'student_management/student_list.dart';
import 'teacher_management/teacher_list.dart';
import 'class_management/class_list.dart';
import 'class_management/add_class.dart';
import 'subject_management/add_edit_subject.dart';
import 'admission mangement/add_admission_screen.dart';

// ═════════════════════════════════════════════════════════════
//  DESIGN TOKENS — "EduCore Glass" system (refined)
// ═════════════════════════════════════════════════════════════
class _T {
  static const bg = Color(0xFFF6F7FC); // softer background
  static const ink = Color(0xFF1A1D2E);
  static const inkSoft = Color(0xFF6B7087);
  static const inkFaint = Color(0xFFA0A5B8);

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
  static const cyan = Color(0xFF0AA9C9);
  static const cyanSoft = Color(0xFFE1F6FA);

  static const borderSoft = Color(0xFFE9EBF3);

  static BoxDecoration glass({
    double radius = 18,
    Color tint = Colors.white,
    double opacity = 0.75,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      color: tint.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.8), width: 0.8),
      boxShadow: shadow ??
          [
            BoxShadow(
              color: const Color(0xFF3B3F6B).withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
    );
  }
}

// ─────────────────────────────────────────────
//  Models (unchanged)
// ─────────────────────────────────────────────
class _NavItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  const _NavItem(this.label, this.icon, this.onTap, {this.badge});
}

class _NavGroup {
  final String label;
  final IconData icon;
  final List<String> memberLabels;
  const _NavGroup(this.label, this.icon, this.memberLabels);
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color colorSoft;
  final bool isLoading;
  final bool isLive;
  const _StatItem(this.label, this.value, this.icon, this.color, this.colorSoft,
      {this.isLoading = false, this.isLive = false});
}

class _QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.onTap);
}

// ─────────────────────────────────────────────
//  Dashboard (main)
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _mobileNavIndex = 0;

  Widget? _mainContentWidget;
  String? _selectedLabel;
  Widget? _rightPanelWidget;

  late final Map<String, Widget Function()> _screenBuilders;

  List<_NavItem>? _navItemsCache;
  String? _navItemsCacheRole;
  List<_QuickAction>? _quickActionsCache;

  Stream<QuerySnapshot>? _todayAttendanceStream;
  Stream<QuerySnapshot>? _classesStream;
  String? _todayAttendanceStreamDate;

  late final AnimationController _entrance;

  final Set<String> _collapsedGroups = {};

  // ★ For double‑back‑to‑exit
  DateTime? _lastBackPressed;

  // ✅ Bottom nav tab labels, in display order (index 0 = Dashboard)
  static const List<String> _bottomNavLabels = [
    'Dashboard',
    'Students',
    'Attendance',
    'Fee Collection',
    'Teachers',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Initialize explicitly in initState (instead of a `late final` inline
    // initializer on the field) so the AnimationController is guaranteed to
    // be created during a valid widget-tree frame. The inline-initializer
    // form could get lazily created/ticked in a way that raced with
    // dispose() during hot reload, causing "Looking up a deactivated
    // widget's ancestor is unsafe" when TickerProviderStateMixin tried to
    // look up TickerMode on an already-deactivated element.
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _mainContentWidget = _buildDashboardContent();
    _selectedLabel = 'Dashboard';
    _mobileNavIndex = 0; // Ensure bottom nav is on Dashboard

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SchoolSettingsProvider>();
      settingsProvider.loadSettings();
      settingsProvider.listenToSettings();

      context.read<EventProvider>().listenToEvents();

      context.read<StudentProvider>();
      final staffProvider = context.read<StaffProvider>();
      staffProvider.fetchAllLists();
      context.read<FeeCollectionProvider>().loadHistory();
    });

    _screenBuilders = {
      'Dashboard': () => _buildDashboardContent(),
      'Subjects': () => const MuddulListScreen(showAppBar: false, showFAB: false),
      'Classes': () => const ClassesListScreen(showAppBar: false, showFAB: false),
      'Admissions': () => const AdmissionListScreen(showAppBar: false, showFAB: false),
      'Students': () => const StudentListScreen(),
      'Class Attendance': () => const ClassAttendanceScreen(showAppBar: false),
      'Class Attendance Report': () => const ClassAttendanceReportScreen(),
      'Student Attendance Report': () => const StudentAttendanceReportScreen(),
      'Teachers': () => const TeacherListScreen(),
      'School Staff': () => const StaffListScreen(),
      'Academy Staff': () => const AcademyStaffListScreen(),
      'Family': () => const FamilyManagementScreen(),
      'Generate Challan': () => const GenerateChallanScreen(),
      'Fee Collection': () => const FeeCollectionHistoryScreen(),
      'Exam Result Cards': () => const StudentWiseResultCardsScreen(),
      'New Exam Result Card': () => ExamResultCardFormScreen(),
      'Register User': () => const RegisterUserScreen(),
      'School Settings': () => const SchoolSettingsScreen(showAppBar: false),
      'ID Cards': () => const StaffIdCardsScreen(showAppBar: false),
      'Attendance': () => const AttendanceScreen(),
      'Events': () => EventListScreen(
        showAppBar: false,
        showFAB: true,
        onAddOrEdit: (existingEvent) => _openEventForm(existingEvent),
      ),
      'Add Subject': () => AddEditMuddulScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
      'Add Class': () => AddEditClassScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
      'New Admission': () => AdmissionFormScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
      'Add Staff/Teacher': () => AddEditStaffScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
      'Generate Salary': () => const GenerateSalaryScreen(showAppBar: false),
      'Salary List': () => const SalaryListScreen(),
      'Salary Adjustment': () => const SalaryManagementScreen(),
      'Add Transaction': () => AddStaffTransactionScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
      'Transaction History': () => const StaffTransactionHistoryScreen(showAppBar: false),
    };
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  static const _needsAppBarWrapperOnMobilePush = <String>{};

  Widget _pushMobileScreen(String label) {
    final screen = _screenBuilders[label]!();
    if (!_needsAppBarWrapperOnMobilePush.contains(label)) return screen;
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        title: Text(label),
        backgroundColor: Colors.white,
        foregroundColor: _T.ink,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: screen,
    );
  }

  // ✅ Derive the bottom-nav highlighted index from the currently selected label,
  // instead of relying on a separately-tracked int that can go stale when the
  // user navigates via the sidebar/drawer or presses back from a pushed screen.
  int _bottomNavIndexForLabel(String? label) {
    final idx = _bottomNavLabels.indexOf(label ?? 'Dashboard');
    return idx == -1 ? 0 : idx;
  }

  // ✅ SINGLE centralized helper for every mobile push-navigation in this
  // screen. Everything that used to call `Navigator.push(...).then(...)`
  // separately (sidebar items, quick actions, "View all" on Events) now
  // routes through here. Having exactly one code path means there's no risk
  // of a stale closure, a missed `.then()`, or two different reset
  // implementations drifting out of sync — which was the root cause of the
  // bottom nav sometimes not returning to "Dashboard".
  //
  // `await`ing the push (rather than chaining `.then`) also guarantees the
  // reset always runs on *this* State instance after the route is popped,
  // no matter how the pop happened (back button, back arrow, swipe-back).
  Future<void> _pushMobileAndReturnToDashboard(String label) async {
    setState(() {
      _selectedLabel = label;
      _mobileNavIndex = _bottomNavIndexForLabel(label);
    });

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _pushMobileScreen(label)),
    );

    if (!mounted) return;
    setState(() {
      _selectedLabel = 'Dashboard';
      _mobileNavIndex = 0;
    });
  }

  List<_NavItem> _navItems(String role) {
    if (_navItemsCache != null && _navItemsCacheRole == role) {
      return _navItemsCache!;
    }

    VoidCallback go(String label) => () {
      if (MediaQuery.of(context).size.width >= 700) {
        setState(() {
          _mainContentWidget = _screenBuilders[label]!();
          _selectedLabel = label;
          _rightPanelWidget = null;
        });
      } else if (label == 'Dashboard') {
        setState(() {
          _selectedLabel = 'Dashboard';
          _mobileNavIndex = 0;
        });
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // ✅ Route through the single centralized helper (see
        // `_pushMobileAndReturnToDashboard`) so every push/return path is
        // identical and the bottom nav reliably re-selects Dashboard.
        _pushMobileAndReturnToDashboard(label);
      }
    };

    final all = <_NavItem>[
      _NavItem('Dashboard', Icons.space_dashboard_rounded, go('Dashboard')),
      _NavItem('Attendance', Icons.fact_check_rounded, go('Attendance')),
      _NavItem('Class Attendance', Icons.how_to_reg_rounded, go('Class Attendance')),
      _NavItem('Class Attendance Report', Icons.summarize_rounded, go('Class Attendance Report')),
      _NavItem('Student Attendance Report', Icons.assignment_ind_rounded, go('Student Attendance Report')),

      _NavItem('Admissions', Icons.how_to_reg_rounded, go('Admissions')),
      _NavItem('Students', Icons.people_alt_rounded, go('Students')),
      _NavItem('Family', Icons.family_restroom_rounded, go('Family')),
      _NavItem('Classes', Icons.class_rounded, go('Classes')),
      _NavItem('Subjects', Icons.menu_book_rounded, go('Subjects')),
      _NavItem('Exam Result Cards', Icons.workspace_premium_rounded, go('Exam Result Cards')),

      _NavItem('Register User', Icons.person_add_alt_1_rounded, go('Register User')),
      _NavItem('Teachers', Icons.person_rounded, go('Teachers')),
      _NavItem('School Staff', Icons.badge_rounded, go('School Staff')),
      _NavItem('Academy Staff', Icons.groups_rounded, go('Academy Staff')),
      _NavItem('ID Cards', Icons.credit_card_rounded, go('ID Cards')),

      _NavItem('Generate Challan', Icons.receipt_long_rounded, go('Generate Challan')),
      _NavItem('Fee Collection', Icons.payments_rounded, go('Fee Collection')),

      _NavItem('Generate Salary', Icons.request_quote_rounded, go('Generate Salary')),
      _NavItem('Salary List', Icons.format_list_bulleted_rounded, go('Salary List')),
      _NavItem('Salary Adjustment', Icons.tune_rounded, go('Salary Adjustment')),
      _NavItem('Transaction History', Icons.history_rounded, go('Transaction History')),

      _NavItem('Events', Icons.celebration_rounded, go('Events')),

      if (role.toLowerCase() == 'admin')
        _NavItem('School Settings', Icons.settings_rounded, go('School Settings')),
    ];

    _navItemsCache = all;
    _navItemsCacheRole = role;
    return all;
  }

  static const _groups = <_NavGroup>[
    _NavGroup('Overview', Icons.dashboard_customize_rounded, ['Dashboard']),
    _NavGroup('Attendance', Icons.fact_check_rounded, [
      'Attendance', 'Class Attendance', 'Class Attendance Report', 'Student Attendance Report',
    ]),
    _NavGroup('Admissions & Students', Icons.school_rounded, [
      'Admissions', 'Students', 'Family', 'Classes', 'Subjects', 'Exam Result Cards',
    ]),
    _NavGroup('People', Icons.groups_2_rounded, [
      'Register User', 'Teachers', 'School Staff', 'Academy Staff', 'ID Cards',
    ]),
    _NavGroup('Fees & Billing', Icons.payments_rounded, [
      'Generate Challan', 'Fee Collection',
    ]),
    _NavGroup('Payroll', Icons.account_balance_wallet_rounded, [
      'Generate Salary', 'Salary List', 'Salary Adjustment', 'Transaction History',
    ]),
    _NavGroup('Events', Icons.celebration_rounded, ['Events']),
    _NavGroup('Settings', Icons.settings_rounded, ['School Settings']),
  ];

  List<_QuickAction> _quickActions() {
    if (_quickActionsCache != null) return _quickActionsCache!;
    _quickActionsCache = [
      _QuickAction('Add Subject', Icons.menu_book_rounded, () => _openQuickAction('Add Subject')),
      _QuickAction('Add Class', Icons.class_rounded, () => _openQuickAction('Add Class')),
      _QuickAction('New Admission', Icons.person_add_alt_1_rounded, () => _openQuickAction('New Admission')),
      _QuickAction('Add Staff/Teacher', Icons.badge_rounded, () => _openQuickAction('Add Staff/Teacher')),
      _QuickAction('Add Transaction', Icons.add_card_rounded, () => _openQuickAction('Add Transaction')),
      _QuickAction('Mark Attendance', Icons.fact_check_rounded, () {
        if (MediaQuery.of(context).size.width >= 700) {
          setState(() {
            _mainContentWidget = _screenBuilders['Attendance']!();
            _selectedLabel = 'Attendance';
            _rightPanelWidget = null;
          });
        } else {
          _pushMobileAndReturnToDashboard('Attendance');
        }
      }),
    ];
    return _quickActionsCache!;
  }

  void _openEventForm(EventModel? existingEvent) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    if (isWide) {
      setState(() {
        _rightPanelWidget = AddEditEventScreen(
          showAppBar: false,
          existingEvent: existingEvent,
          onSaved: _closeRightPanel,
        );
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditEventScreen(
            existingEvent: existingEvent,
            onSaved: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  void _openProfile(StaffMember staff, {Map<String, String>? classIdToName}) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    final mapping = classIdToName ?? {};

    if (isWide) {
      setState(() {
        _rightPanelWidget = _buildProfilePanel(staff, mapping);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StaffProfileScreen(
            staff: staff,
            classIdToName: mapping,
          ),
        ),
      );
    }
  }

  Widget _buildProfilePanel(StaffMember staff, Map<String, String> classIdToName) {
    return Column(
      children: [
        _buildPanelHeaderCustom('Staff Profile', Icons.person_rounded),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: StaffProfileView(
              staff: staff,
              classIdToName: classIdToName,
              onClose: _closeRightPanel,
            ),
          ),
        ),
      ],
    );
  }

  void _openQuickAction(String key) {
    if (MediaQuery.of(context).size.width >= 700) {
      setState(() {
        _rightPanelWidget = _screenBuilders[key]!();
      });
    } else {
      // ✅ Route through the same centralized helper so returning from a
      // quick-action form (Add Subject/Class/Admission/Staff/Transaction)
      // also correctly re-selects "Dashboard" on the bottom nav.
      _pushMobileAndReturnToDashboard(key);
    }
  }

  void _closeRightPanel() {
    setState(() {
      _rightPanelWidget = null;
    });
  }

  // ─── Logout confirmation ───
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _T.inkSoft)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _T.rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ─── Double‑back‑to‑exit handler ───
  Future<bool> _onWillPop() async {
    if (_lastBackPressed == null ||
        DateTime.now().difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = DateTime.now();
      // Show a snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      );
      return false;
    }
    return true; // exit
  }

  // ═══════════════════════════════════════════
  //  SIDEBAR (updated logout with confirmation)
  // ═══════════════════════════════════════════
  Widget _sidebarContent(String role, String userEmail, {required bool isDrawer}) {
    final items = _navItems(role);
    final itemsByLabel = {for (final i in items) i.label: i};
    final initials = userEmail.length >= 2
        ? userEmail.substring(0, 2).toUpperCase()
        : userEmail.toUpperCase();

    final schoolSettings = context.watch<SchoolSettingsProvider>().settings;
    final schoolName = schoolSettings.schoolName.trim().isEmpty
        ? 'EduCore'
        : schoolSettings.schoolName;
    final schoolTagline = schoolSettings.city.trim().isEmpty
        ? 'Campus Suite'
        : schoolSettings.city;

    ImageProvider? logoImage;
    if (schoolSettings.logoBase64 != null && schoolSettings.logoBase64!.isNotEmpty) {
      try {
        logoImage = MemoryImage(base64Decode(schoolSettings.logoBase64!));
      } catch (_) {
        logoImage = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: logoImage != null
                      ? null
                      : const LinearGradient(
                    colors: [_T.primary, _T.primaryDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  color: logoImage != null ? Colors.transparent : null,
                  borderRadius: BorderRadius.circular(14),
                  image: logoImage != null
                      ? DecorationImage(image: logoImage, fit: BoxFit.cover)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: _T.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: logoImage == null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/EducoreLogo.png',
                    fit: BoxFit.cover,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schoolName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: _T.ink)),
                    const SizedBox(height: 1),
                    Text(schoolTagline,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 11.5, color: _T.inkFaint)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _T.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: _T.primary,
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail.split('@').first,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700, color: _T.ink),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 9, color: _T.primaryDeep, letterSpacing: 0.6,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            itemCount: _groups.length,
            itemBuilder: (ctx, i) {
              final group = _groups[i];
              final members = group.memberLabels
                  .where((l) => itemsByLabel.containsKey(l))
                  .map((l) => itemsByLabel[l]!)
                  .toList();
              if (members.isEmpty) return const SizedBox.shrink();
              final collapsed = _collapsedGroups.contains(group.label);

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          if (collapsed) {
                            _collapsedGroups.remove(group.label);
                          } else {
                            _collapsedGroups.add(group.label);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
                        child: Row(
                          children: [
                            Icon(group.icon, size: 14, color: _T.inkFaint),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(group.label.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _T.inkFaint,
                                      letterSpacing: 0.7)),
                            ),
                            AnimatedRotation(
                              turns: collapsed ? -0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(Icons.expand_more_rounded,
                                  size: 15, color: _T.inkFaint.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: collapsed
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: members.map((e) => _sbTile(e, isDrawer)).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: _T.borderSoft),
        Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _confirmLogout(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.logout_rounded, size: 17, color: _T.rose),
                  SizedBox(width: 9),
                  Text('Logout',
                      style: TextStyle(
                          fontSize: 13, color: _T.rose, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(String role, String userEmail) {
    return Drawer(
      width: 240,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: _sidebarContent(role, userEmail, isDrawer: true),
      ),
    );
  }

  Widget _sbTile(_NavItem item, bool isDrawer) {
    final isActive = item.label == (_selectedLabel ?? '');

    return InkWell(
      onTap: () {
        if (isDrawer) Navigator.pop(context);
        item.onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: TweenAnimationBuilder<double>(
        key: ValueKey('${item.label}_$isActive'),
        tween: Tween(begin: isActive ? 0.92 : 1.0, end: 1.0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: isActive ? scale : 1.0,
            alignment: Alignment.centerLeft,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: isActive ? 10.5 : 9,
          ),
          decoration: BoxDecoration(
            color: isActive ? _T.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: _T.primary.withOpacity(0.32),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedScale(
                scale: isActive ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(item.icon,
                    size: 16.5,
                    color: isActive ? Colors.white : _T.inkSoft),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isActive ? 13 : 12.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : _T.ink,
                  ),
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              if (item.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.25) : _T.rose,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${item.badge}',
                      style: const TextStyle(
                          fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Premium Stat Card (compact & elegant) ───
  Widget _statCard(_StatItem s, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 12),
            child: child,
          ),
        );
      },
      child: Container(
        // ✅ Reduced padding (14 -> 11) so the fixed-height card (as low as
        // ~72px on some narrow/2-column layouts) has enough room for the
        // icon row + label + value without a RenderFlex overflow.
        padding: const EdgeInsets.all(11),
        decoration: _T.glass(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: s.colorSoft,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(s.icon, color: s.color, size: 14),
                ),
                const Spacer(),
                if (s.isLive)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _T.teal,
                      boxShadow: [
                        BoxShadow(
                          color: _T.teal.withOpacity(0.35),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(s.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, color: _T.inkFaint, fontWeight: FontWeight.w600)),
            const SizedBox(height: 1),
            s.isLoading
                ? const SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(strokeWidth: 2, color: _T.primary),
            )
                : FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(s.value,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: _T.ink)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qaChip(_QuickAction a, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: a.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _T.borderSoft),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B3F6B).withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(a.icon, size: 16, color: _T.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(a.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: _T.ink),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentFeeRow(String initials, String name, String sub, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(initials,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _T.ink)),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: _T.inkFaint)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(amount,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _T.ink)),
        ],
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _initialsOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Widget _eventReminderTile(EventModel event) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final eventDay = DateTime(event.date.year, event.date.month, event.date.day);
    final daysLeft = eventDay.difference(todayOnly).inDays;

    String countdownText;
    Color countdownColor;
    Color countdownBg;
    if (daysLeft > 1) {
      countdownText = '$daysLeft days';
      countdownColor = _T.primary;
      countdownBg = _T.primarySoft;
    } else if (daysLeft == 1) {
      countdownText = 'Tomorrow';
      countdownColor = _T.amber;
      countdownBg = _T.amberSoft;
    } else if (daysLeft == 0) {
      countdownText = 'Today';
      countdownColor = _T.teal;
      countdownBg = _T.tealSoft;
    } else {
      countdownText = 'Passed';
      countdownColor = _T.inkFaint;
      countdownBg = const Color(0xFFEDEEF4);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFD),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: countdownColor, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: _T.ink)),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: _T.inkSoft, height: 1.3)),
                ],
                const SizedBox(height: 4),
                Text(_formatDate(event.date),
                    style: const TextStyle(fontSize: 9.5, color: _T.inkFaint)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: countdownBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              countdownText,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: countdownColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _T.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 13, color: _T.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.1, color: _T.ink)),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _card(Widget child, {EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: _T.glass(radius: 16),
      child: child,
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _buildEventsCard() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        final events = [...provider.events];
        events.sort((a, b) {
          final aDay = DateTime(a.date.year, a.date.month, a.date.day);
          final bDay = DateTime(b.date.year, b.date.month, b.date.day);
          final aPast = aDay.isBefore(todayOnly);
          final bPast = bDay.isBefore(todayOnly);
          if (aPast != bPast) return aPast ? 1 : -1;
          return aDay.compareTo(bDay);
        });
        final preview = events.take(4).toList();

        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                'Events',
                Icons.celebration_rounded,
                trailing: TextButton(
                  onPressed: () {
                    if (MediaQuery.of(context).size.width >= 700) {
                      setState(() {
                        _mainContentWidget = _screenBuilders['Events']!();
                        _selectedLabel = 'Events';
                        _rightPanelWidget = null;
                      });
                    } else {
                      _pushMobileAndReturnToDashboard('Events');
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _T.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('View all',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
              if (provider.isLoading && events.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(color: _T.primary)),
                )
              else if (preview.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy_rounded, size: 24, color: _T.inkFaint.withOpacity(0.6)),
                        const SizedBox(height: 4),
                        const Text('No events scheduled',
                            style: TextStyle(fontSize: 11.5, color: _T.inkFaint)),
                      ],
                    ),
                  ),
                )
              else
                ...preview.map(_eventReminderTile),
            ],
          ),
        );
      },
    );
  }

  // ✅ Bottom nav now derives its "active" tab from `_selectedLabel`
  // (single source of truth) instead of a separately-tracked int that
  // could go stale when navigating via sidebar/drawer or via back button.
  Widget _buildBottomNav(String role) {
    final items = _navItems(role);
    final tabs = <_NavItem>[
      items.firstWhere((n) => n.label == 'Dashboard'),
      items.firstWhere((n) => n.label == 'Students'),
      items.firstWhere((n) => n.label == 'Attendance'),
      items.firstWhere((n) => n.label == 'Fee Collection'),
      items.firstWhere((n) => n.label == 'Teachers'),
    ];

    final currentIndex = _bottomNavIndexForLabel(_selectedLabel);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final active = currentIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (i == 0) {
                      setState(() {
                        _selectedLabel = 'Dashboard';
                        _mobileNavIndex = 0;
                      });
                      Navigator.popUntil(context, (route) => route.isFirst);
                      return;
                    }
                    // ✅ Just delegate to the nav item's onTap, which now
                    // routes through the single centralized
                    // `_pushMobileAndReturnToDashboard` helper. No separate
                    // setState here — avoids two competing state updates
                    // racing each other.
                    tabs[i].onTap();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: active ? _T.primarySoft : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(tabs[i].icon,
                            size: 18, color: active ? _T.primary : _T.inkFaint),
                      ),
                      const SizedBox(height: 2),
                      Text(tabs[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? _T.primary : _T.inkFaint)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelHeaderCustom(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _T.borderSoft)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: _T.primarySoft, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: _T.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _T.ink)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: _closeRightPanel,
            color: _T.inkSoft,
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader() => _buildPanelHeaderCustom('Add New', Icons.add_rounded);

  // ═══════════════════════════════════════════
  //  DASHBOARD CONTENT (refreshed design)
  // ═══════════════════════════════════════════
  Widget _buildDashboardContent() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    final userFirst = (auth.user?.email ?? 'there').split('@').first;

    final today = DateTime.now();
    final todayStr =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (_todayAttendanceStream == null || _todayAttendanceStreamDate != todayStr) {
      _todayAttendanceStreamDate = todayStr;
      _todayAttendanceStream = FirebaseFirestore.instance
          .collection('attendance')
          .where('date', isEqualTo: todayStr)
          .snapshots();
    }
    _classesStream ??= FirebaseFirestore.instance
        .collection('schools')
        .doc('school1')
        .collection('classes')
        .snapshots();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card (sleeker)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_T.primaryDeep, _T.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _T.primary.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$greeting, $userFirst',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2)),
                const SizedBox(height: 4),
                Text("Here's what's happening across your campus.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _sectionHeader('Quick Actions', Icons.bolt_rounded),
          // ✅ On mobile, lay out Quick Action buttons as an equal-size,
          // centered 2-column grid (instead of a left-aligned, content-hugging
          // Wrap where each chip took only as much width as its label
          // needed). Desktop/wide keeps the original Wrap behavior.
          LayoutBuilder(builder: (ctx, box) {
            final isMobile = box.maxWidth < 700;
            if (isMobile) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.6,
                children: List.generate(
                    _quickActions().length, (i) => _qaChip(_quickActions()[i], i)),
              );
            }
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(
                  _quickActions().length, (i) => _qaChip(_quickActions()[i], i)),
            );
          }),

          const SizedBox(height: 20),
          _sectionHeader('Live Overview', Icons.insights_rounded),

          Consumer2<StudentProvider, StaffProvider>(
            builder: (context, studentProvider, staffProvider, _) {
              final totalStudents = studentProvider.students.length;
              final totalTeachers = staffProvider.teachers.length;
              final totalStaff =
                  staffProvider.schoolStaff.length + staffProvider.academyStaff.length;

              return StreamBuilder<QuerySnapshot>(
                stream: _classesStream,
                builder: (context, classSnap) {
                  final classCount = classSnap.hasData ? classSnap.data!.docs.length : null;

                  return StreamBuilder<QuerySnapshot>(
                    stream: _todayAttendanceStream,
                    builder: (context, attSnap) {
                      String attendancePct = '—';
                      if (attSnap.hasData) {
                        final docs = attSnap.data!.docs;
                        final markable = docs.where((d) {
                          final status =
                              (d.data() as Map<String, dynamic>)['status'] as String? ?? '';
                          return status.isNotEmpty && status != 'holiday';
                        }).toList();
                        if (markable.isNotEmpty) {
                          final present = markable.where((d) {
                            final status = (d.data() as Map<String, dynamic>)['status'] as String?;
                            return status == 'present' || status == 'late';
                          }).length;
                          attendancePct = '${(present / markable.length * 100).round()}%';
                        }
                      }

                      final stats = <_StatItem>[
                        _StatItem('Students', '$totalStudents', Icons.people_alt_rounded,
                            _T.blue, _T.blueSoft, isLive: true),
                        _StatItem('Teachers & Staff', '${totalTeachers + totalStaff}',
                            Icons.groups_2_rounded, _T.teal, _T.tealSoft, isLive: true),
                        _StatItem(
                            'Classes',
                            classCount != null ? '$classCount' : '—',
                            Icons.class_rounded,
                            _T.amber,
                            _T.amberSoft,
                            isLoading: classCount == null),
                        _StatItem(
                            "Today's Attendance",
                            attendancePct,
                            Icons.fact_check_rounded,
                            _T.primary,
                            _T.primarySoft,
                            isLoading: !attSnap.hasData,
                            isLive: true),
                      ];

                      return LayoutBuilder(builder: (ctx, box) {
                        final w = box.maxWidth;
                        final isMobile = w < 700;
                        final crossCount = isMobile ? 2 : 4;
                        // ✅ Narrow phones (< 360 logical px) get a lower
                        // (taller-relative) aspect ratio so the stat card's
                        // icon row + label + value never gets squeezed into
                        // an overflow — fixes RenderFlex overflow on small
                        // mobile screens, especially with larger system font
                        // scaling.
                        // ✅ Lowered further (was 1.35/1.6) after real-device
                        // logs showed a 132.4x71.7 card still overflowing by
                        // ~4px with system font scaling in play. Combined
                        // with the reduced card padding above, this gives
                        // reliable headroom across narrow phones.
                        final aspectRatio = isMobile
                            ? (w < 360 ? 1.15 : 1.35)
                            : 1.4;
                        return GridView.count(
                          crossAxisCount: crossCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: aspectRatio,
                          children: List.generate(
                              stats.length, (i) => _statCard(stats[i], i)),
                        );
                      });
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),
          Consumer<FeeCollectionProvider>(
            builder: (context, feeProvider, _) {
              return LayoutBuilder(builder: (ctx, box) {
                final wide = box.maxWidth >= 620;
                final recentColors = [_T.blue, _T.teal, _T.cyan, _T.amber, _T.rose];

                final recent = feeProvider.history.take(5).toList();

                final recentCard = _card(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sectionHeader('Recent Fee Collections', Icons.receipt_long_rounded),
                    if (feeProvider.isLoadingHistory && recent.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: _T.primary)),
                      )
                    else if (recent.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('No payments recorded yet',
                              style: TextStyle(fontSize: 11.5, color: _T.inkFaint)),
                        ),
                      )
                    else
                      ...List.generate(recent.length, (i) {
                        final c = recent[i];
                        final color = recentColors[i % recentColors.length];
                        return Column(
                          children: [
                            _recentFeeRow(
                              _initialsOf(c.familyName.isNotEmpty ? c.familyName : c.fatherName),
                              c.familyName.isNotEmpty ? c.familyName : c.fatherName,
                              '${c.paymentMethod} · ${_timeAgo(c.paymentDate)}',
                              'Rs ${c.amount.toStringAsFixed(0)}',
                              color,
                            ),
                            if (i < recent.length - 1)
                              const Divider(height: 1, color: _T.borderSoft),
                          ],
                        );
                      }),
                  ],
                ));

                final eventsCard = _buildEventsCard();

                if (wide) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: recentCard),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: eventsCard),
                      ],
                    ),
                  );
                }
                return Column(children: [recentCard, const SizedBox(height: 10), eventsCard]);
              });
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────
  //  BUILD
  // ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.role ?? 'teacher';
    final email = auth.user?.email ?? 'user@school.pk';
    final isWide = MediaQuery.of(context).size.width >= 700;

    final schoolSettings = context.watch<SchoolSettingsProvider>().settings;
    final schoolNameForAppBar =
    schoolSettings.schoolName.trim().isEmpty ? 'Citizens Model School' : schoolSettings.schoolName;

    ImageProvider? appBarLogoImage;
    if (schoolSettings.logoBase64 != null && schoolSettings.logoBase64!.isNotEmpty) {
      try {
        appBarLogoImage = MemoryImage(base64Decode(schoolSettings.logoBase64!));
      } catch (_) {
        appBarLogoImage = null;
      }
    }

    // Wrap Scaffold with PopScope to handle back button on mobile
    return PopScope(
      canPop: false, // we handle it manually
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          SystemNavigator.pop();        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _T.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          leadingWidth: isWide ? 0 : 48,
          leading: isWide
              ? null
              : IconButton(
            icon: const Icon(Icons.menu_rounded, color: _T.ink),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          // App bar title — logo center on mobile, left on desktop
          title: isWide
              ? Row(
            children: [
              SizedBox(
                height: 85,
                child: Image.asset(
                  'assets/images/EduCoreSystem.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(width: 12),
            ],
          )
              : Center(
            child: SizedBox(
              height: 70,
              // ✅ Bound the width too — Image.asset inside a Center with
              // only a height constraint tries to size itself to its
              // intrinsic aspect ratio, which can exceed the AppBar's
              // narrow title slot on small screens and throw a RenderFlex
              // overflow. Capping width to a fraction of screen width
              // fixes this while BoxFit.contain keeps the logo un-stretched.
              width: MediaQuery.of(context).size.width * 0.55,
              child: Image.asset(
                'assets/images/EduCoreSystem.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          actions: [
            if (isWide)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_outlined, size: 14, color: _T.inkFaint),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(schoolNameForAppBar,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: _T.inkSoft)),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.account_circle_outlined, size: 14, color: _T.inkFaint),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(email.split('@').first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: _T.inkSoft)),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20, color: _T.rose),
              tooltip: 'Logout',
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        drawer: isWide ? null : _buildSidebar(role, email),
        bottomNavigationBar: isWide ? null : _buildBottomNav(role),
        body: isWide
            ? Row(
          children: [
            SizedBox(
              width: 240,
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  child: _sidebarContent(role, email, isDrawer: false),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: _T.borderSoft),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FadeTransition(
                      opacity: _entrance,
                      child: _mainContentWidget ?? const SizedBox.shrink(),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    top: 0,
                    right: _rightPanelWidget == null
                        ? -(MediaQuery.of(context).size.width - 240)
                        : 0,
                    bottom: 0,
                    width: MediaQuery.of(context).size.width - 240,
                    child: _rightPanelWidget != null
                        ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(-4, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPanelHeader(),
                          Expanded(child: _rightPanelWidget!),
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        )
            : (_selectedLabel == 'Dashboard'
            ? _buildDashboardContent()
            : _mainContentWidget ?? _buildDashboardContent()),
      ),
    );
  }
}