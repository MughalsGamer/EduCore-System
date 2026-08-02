  //
  // import 'package:flutter/material.dart';
  // import 'package:intl/intl.dart';
  // import 'package:provider/provider.dart';
  //
  // import '../../models/teacher.dart';
  // import '../../providers/salary_adjustment_history_provider.dart';
  // import '../../providers/teacher_provider.dart';
  // import 'salary_adjustment_screen.dart';
  //
  // const _kPurple = Color(0xFF534AB7);
  // const _kPurpleLight = Color(0xFFF0EFFE);
  // const _kGreen = Color(0xFF15803D);
  // const _kGreenBg = Color(0xFFDCFCE7);
  // const _kRed = Color(0xFFB91C1C);
  // const _kRedBg = Color(0xFFFEE2E2);
  //
  // /// Shows ONLY employees who already have at least one salary_history
  // /// record. Each row shows current salary and the most recent change;
  // /// tapping opens the full increment/decrement + history screen.
  // ///
  // /// A "+ Add Adjustment" button is the entry point for picking ANY
  // /// employee (staff or teacher) — including ones with zero history —
  // /// so the very first salary adjustment for someone can always be made
  // /// from here. Once an employee has at least one record, they also show
  // /// up in the list below automatically.
  // class SalaryManagementScreen extends StatefulWidget {
  //   final bool showAppBar;
  //
  //   const SalaryManagementScreen({super.key, this.showAppBar = true});
  //
  //   @override
  //   State<SalaryManagementScreen> createState() =>
  //       _SalaryManagementScreenState();
  // }
  //
  // class _SalaryManagementScreenState extends State<SalaryManagementScreen> {
  //   final _searchCtrl = TextEditingController();
  //   String _searchQuery = '';
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     Future.microtask(
  //             () => context.read<SalaryHistoryProvider>().loadAllSummaries());
  //     _searchCtrl.addListener(() {
  //       setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
  //     });
  //   }
  //
  //   @override
  //   void dispose() {
  //     _searchCtrl.dispose();
  //     super.dispose();
  //   }
  //
  //   List<EmployeeSalarySummary> _filtered(List<EmployeeSalarySummary> all) {
  //     if (_searchQuery.isEmpty) return all;
  //     return all
  //         .where((e) =>
  //     e.staff.name.toLowerCase().contains(_searchQuery) ||
  //         (e.staff.designation ?? '').toLowerCase().contains(_searchQuery))
  //         .toList();
  //   }
  //
  //   Future<void> _openEmployee(StaffMember staff) async {
  //     await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => SalaryAdjustmentScreen(staff: staff),
  //       ),
  //     );
  //     if (mounted) {
  //       context.read<SalaryHistoryProvider>().loadAllSummaries();
  //     }
  //   }
  //
  //   Future<void> _openEmployeePicker() async {
  //     // Make sure staff + teacher lists are loaded before showing the picker.
  //     final staffProvider = context.read<StaffProvider>();
  //     if (staffProvider.allStaff.isEmpty) {
  //       await staffProvider.fetchAll();
  //     }
  //
  //     if (!mounted) return;
  //
  //     final selected = await showModalBottomSheet<StaffMember>(
  //       context: context,
  //       isScrollControlled: true,
  //       backgroundColor: Colors.transparent,
  //       builder: (_) => const _EmployeePickerSheet(),
  //     );
  //
  //     if (selected != null && mounted) {
  //       _openEmployee(selected);
  //     }
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     final body = _buildBody();
  //     if (!widget.showAppBar) return body;
  //
  //     return Scaffold(
  //       backgroundColor: const Color(0xFFF5F6FA),
  //       appBar: AppBar(
  //         backgroundColor: _kPurple,
  //         foregroundColor: Colors.white,
  //         elevation: 0,
  //         title: const Text('Salary Management',
  //             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
  //       ),
  //       floatingActionButton: FloatingActionButton.extended(
  //         backgroundColor: _kPurple,
  //         foregroundColor: Colors.white,
  //         onPressed: _openEmployeePicker,
  //         icon: const Icon(Icons.add),
  //         label: const Text('Add Adjustment'),
  //       ),
  //       body: body,
  //     );
  //   }
  //
  //   Widget _buildBody() {
  //     return Consumer<SalaryHistoryProvider>(
  //       builder: (context, provider, _) {
  //         final filtered = _filtered(provider.summaries);
  //
  //         return Column(
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: TextField(
  //                       controller: _searchCtrl,
  //                       decoration: InputDecoration(
  //                         hintText: 'Search by name or designation…',
  //                         hintStyle: TextStyle(
  //                             fontSize: 13, color: Colors.grey.shade400),
  //                         prefixIcon: const Icon(Icons.search,
  //                             size: 18, color: Colors.grey),
  //                         filled: true,
  //                         fillColor: Colors.white,
  //                         contentPadding: const EdgeInsets.symmetric(
  //                             horizontal: 12, vertical: 0),
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide: BorderSide(color: Colors.grey.shade300),
  //                         ),
  //                         enabledBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide: BorderSide(color: Colors.grey.shade300),
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide: const BorderSide(color: _kPurple),
  //                         ),
  //                       ),
  //                       style: const TextStyle(fontSize: 13),
  //                     ),
  //                   ),
  //                   // Also offer the button here for wide/desktop layouts
  //                   // where a FAB may be less discoverable.
  //                   const SizedBox(width: 8),
  //                   ElevatedButton.icon(
  //                     onPressed: _openEmployeePicker,
  //                     icon: const Icon(Icons.add, size: 18),
  //                     label: const Text('Add Adjustment'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: _kPurple,
  //                       foregroundColor: Colors.white,
  //                       elevation: 0,
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 16, vertical: 14),
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10)),
  //                       textStyle: const TextStyle(
  //                           fontSize: 13, fontWeight: FontWeight.w600),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Expanded(
  //               child: provider.loading
  //                   ? const Center(
  //                   child: CircularProgressIndicator(color: _kPurple))
  //                   : filtered.isEmpty
  //                   ? _buildEmpty()
  //                   : ListView.builder(
  //                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
  //                 itemCount: filtered.length,
  //                 itemBuilder: (ctx, i) =>
  //                     _employeeCard(filtered[i]),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  //
  //   Widget _buildEmpty() {
  //     return Center(
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.payments_outlined,
  //                 size: 48, color: Colors.grey.shade300),
  //             const SizedBox(height: 12),
  //             Text(
  //               _searchQuery.isEmpty
  //                   ? 'No salary changes recorded yet.'
  //                   : 'No results for "$_searchQuery"',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
  //             ),
  //             if (_searchQuery.isEmpty) ...[
  //               const SizedBox(height: 4),
  //               Text(
  //                 'Tap "Add Adjustment" above to give someone their first increment or decrement.',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
  //               ),
  //             ],
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   Widget _employeeCard(EmployeeSalarySummary summary) {
  //     final staff = summary.staff;
  //     final latest = summary.latestChange;
  //     final isIncrement = latest.isIncrement;
  //     final color = isIncrement ? _kGreen : _kRed;
  //     final bgColor = isIncrement ? _kGreenBg : _kRedBg;
  //     final icon =
  //     isIncrement ? Icons.trending_up_rounded : Icons.trending_down_rounded;
  //
  //     return Container(
  //       margin: const EdgeInsets.only(bottom: 10),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(14),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.04),
  //             blurRadius: 8,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: InkWell(
  //         onTap: () => _openEmployee(staff),
  //         borderRadius: BorderRadius.circular(14),
  //         child: Padding(
  //           padding: const EdgeInsets.all(14),
  //           child: Row(
  //             children: [
  //               CircleAvatar(
  //                 radius: 24,
  //                 backgroundColor: _kPurpleLight,
  //                 child: Text(
  //                   staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
  //                   style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                       color: _kPurple),
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(staff.name,
  //                         style: const TextStyle(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w600,
  //                             color: Color(0xFF1A1A2E))),
  //                     if (staff.designation?.isNotEmpty == true)
  //                       Padding(
  //                         padding: const EdgeInsets.only(top: 2),
  //                         child: Text(staff.designation!,
  //                             style: TextStyle(
  //                                 fontSize: 11, color: Colors.grey.shade600)),
  //                       ),
  //                     const SizedBox(height: 6),
  //                     Row(
  //                       children: [
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 8, vertical: 3),
  //                           decoration: BoxDecoration(
  //                             color: bgColor,
  //                             borderRadius: BorderRadius.circular(20),
  //                           ),
  //                           child: Row(
  //                             mainAxisSize: MainAxisSize.min,
  //                             children: [
  //                               Icon(icon, size: 12, color: color),
  //                               const SizedBox(width: 3),
  //                               Text(
  //                                 'Rs ${_formatMoney(latest.amount)}',
  //                                 style: TextStyle(
  //                                     fontSize: 11,
  //                                     fontWeight: FontWeight.w600,
  //                                     color: color),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         const SizedBox(width: 6),
  //                         Text('on ${latest.date}',
  //                             style: TextStyle(
  //                                 fontSize: 11, color: Colors.grey.shade500)),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.end,
  //                 children: [
  //                   const Text('Current',
  //                       style: TextStyle(fontSize: 10, color: Colors.grey)),
  //                   Text('Rs ${_formatMoney(staff.salary)}',
  //                       style: const TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w700,
  //                           color: Color(0xFF1A1A2E))),
  //                   const SizedBox(height: 4),
  //                   Text('${summary.history.length} change(s)',
  //                       style: TextStyle(
  //                           fontSize: 10, color: Colors.grey.shade500)),
  //                 ],
  //               ),
  //               const SizedBox(width: 4),
  //               Icon(Icons.chevron_right_rounded,
  //                   color: Colors.grey.shade400, size: 20),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }
  //
  // /// Bottom sheet used to pick any Staff or Teacher (regardless of whether
  // /// they have salary history yet) so the first-ever adjustment can be made.
  // class _EmployeePickerSheet extends StatefulWidget {
  //   const _EmployeePickerSheet();
  //
  //   @override
  //   State<_EmployeePickerSheet> createState() => _EmployeePickerSheetState();
  // }
  //
  // class _EmployeePickerSheetState extends State<_EmployeePickerSheet> {
  //   final _searchCtrl = TextEditingController();
  //   String _query = '';
  //
  //   @override
  //   void dispose() {
  //     _searchCtrl.dispose();
  //     super.dispose();
  //   }
  //
  //   List<StaffMember> _filtered(List<StaffMember> all) {
  //     var list = all.where((s) => s.isActive).toList();
  //     // Remove type filter
  //     if (_query.isNotEmpty) {
  //       list = list
  //           .where((s) =>
  //       s.name.toLowerCase().contains(_query) ||
  //           (s.designation ?? '').toLowerCase().contains(_query))
  //           .toList();
  //     }
  //     list.sort((a, b) => a.name.compareTo(b.name));
  //     return list;
  //   }
  //   @override
  //   Widget build(BuildContext context) {
  //     final staffProvider = context.watch<StaffProvider>();
  //     final all = staffProvider.allStaff;
  //     final filtered = _filtered(all);
  //
  //     return DraggableScrollableSheet(
  //       initialChildSize: 0.75,
  //       minChildSize: 0.5,
  //       maxChildSize: 0.92,
  //       expand: false,
  //       builder: (context, scrollController) {
  //         return Container(
  //           decoration: const BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //           ),
  //           child: Column(
  //             children: [
  //               const SizedBox(height: 10),
  //               Container(
  //                 width: 40,
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade300,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
  //                 child: Row(
  //                   children: [
  //                     const Icon(Icons.person_search_rounded,
  //                         color: _kPurple, size: 20),
  //                     const SizedBox(width: 8),
  //                     const Expanded(
  //                       child: Text(
  //                         'Select Employee',
  //                         style: TextStyle(
  //                             fontSize: 16, fontWeight: FontWeight.w700),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.close),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16),
  //                 child: TextField(
  //                   controller: _searchCtrl,
  //                   onChanged: (v) =>
  //                       setState(() => _query = v.toLowerCase()),
  //                   decoration: InputDecoration(
  //                     hintText: 'Search by name or designation…',
  //                     hintStyle:
  //                     TextStyle(fontSize: 13, color: Colors.grey.shade400),
  //                     prefixIcon: const Icon(Icons.search,
  //                         size: 18, color: Colors.grey),
  //                     filled: true,
  //                     fillColor: const Color(0xFFF5F6FA),
  //                     contentPadding: const EdgeInsets.symmetric(
  //                         horizontal: 12, vertical: 0),
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                       borderSide: BorderSide.none,
  //                     ),
  //                   ),
  //                   style: const TextStyle(fontSize: 13),
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16),
  //                 child: Row(
  //                   children: [
  //                     _filterChip('All', 'all'),
  //                     const SizedBox(width: 8),
  //                     _filterChip('Teachers', 'teacher'),
  //                     const SizedBox(width: 8),
  //                     _filterChip('Staff', 'staff'),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               const Divider(height: 1),
  //               Expanded(
  //                 child: staffProvider.loading
  //                     ? const Center(
  //                     child: CircularProgressIndicator(color: _kPurple))
  //                     : filtered.isEmpty
  //                     ? Center(
  //                   child: Text(
  //                     'No employees found.',
  //                     style: TextStyle(
  //                         fontSize: 13, color: Colors.grey.shade500),
  //                   ),
  //                 )
  //                     : ListView.separated(
  //                   controller: scrollController,
  //                   padding: const EdgeInsets.symmetric(vertical: 8),
  //                   itemCount: filtered.length,
  //                   separatorBuilder: (_, __) => const Divider(
  //                       height: 1, color: Color(0xFFF0F0F0)),
  //                   itemBuilder: (ctx, i) {
  //                     final s = filtered[i];
  //                     return ListTile(
  //                       leading: CircleAvatar(
  //                         radius: 20,
  //                         backgroundColor: _kPurpleLight,
  //                         child: Text(
  //                           s.name.isNotEmpty
  //                               ? s.name[0].toUpperCase()
  //                               : '?',
  //                           style: const TextStyle(
  //                               fontSize: 14,
  //                               fontWeight: FontWeight.bold,
  //                               color: _kPurple),
  //                         ),
  //                       ),
  //                       title: Text(s.name,
  //                           style: const TextStyle(
  //                               fontSize: 14,
  //                               fontWeight: FontWeight.w600)),
  //                       subtitle: Text(
  //                         [
  //                           s.type == 'teacher' ? 'Teacher' : 'Staff',
  //                           if (s.designation?.isNotEmpty == true)
  //                             s.designation!,
  //                         ].join(' • '),
  //                         style: TextStyle(
  //                             fontSize: 12, color: Colors.grey.shade600),
  //                       ),
  //                       trailing: Text(
  //                         'Rs ${_formatMoney(s.salary)}',
  //                         style: const TextStyle(
  //                             fontSize: 13,
  //                             fontWeight: FontWeight.w700,
  //                             color: _kPurple),
  //                       ),
  //                       onTap: () => Navigator.pop(context, s),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   }
  //
  //   Widget _filterChip(String label, String value) {
  //     final selected = _typeFilter == value;
  //     return GestureDetector(
  //       onTap: () => setState(() => _typeFilter = value),
  //       child: AnimatedContainer(
  //         duration: const Duration(milliseconds: 150),
  //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
  //         decoration: BoxDecoration(
  //           color: selected ? _kPurple : Colors.grey.shade100,
  //           borderRadius: BorderRadius.circular(20),
  //           border: Border.all(
  //             color: selected ? _kPurple : Colors.grey.shade300,
  //             width: selected ? 1.5 : 0.8,
  //           ),
  //         ),
  //         child: Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w600,
  //             color: selected ? Colors.white : Colors.grey.shade700,
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }
  //
  // String _formatMoney(double value) {
  //   return NumberFormat('#,##0').format(value);
  // }
  //


  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:provider/provider.dart';

  import '../../models/teacher.dart';
  import '../../providers/salary_adjustment_history_provider.dart';
  import '../../providers/teacher_provider.dart';
  import 'salary_adjustment_screen.dart';

  const _kPurple = Color(0xFF534AB7);
  const _kPurpleLight = Color(0xFFF0EFFE);
  const _kGreen = Color(0xFF15803D);
  const _kGreenBg = Color(0xFFDCFCE7);
  const _kRed = Color(0xFFB91C1C);
  const _kRedBg = Color(0xFFFEE2E2);

  /// Shows ONLY employees who already have at least one salary_history
  /// record. Each row shows current salary and the most recent change;
  /// tapping opens the full increment/decrement + history screen.
  ///
  /// A "+ Add Adjustment" button is the entry point for picking ANY
  /// employee (staff or teacher) — including ones with zero history —
  /// so the very first salary adjustment for someone can always be made
  /// from here. Once an employee has at least one record, they also show
  /// up in the list below automatically.
  class SalaryManagementScreen extends StatefulWidget {
    final bool showAppBar;

    const SalaryManagementScreen({super.key, this.showAppBar = true});

    @override
    State<SalaryManagementScreen> createState() =>
        _SalaryManagementScreenState();
  }

  class _SalaryManagementScreenState extends State<SalaryManagementScreen> {
    final _searchCtrl = TextEditingController();
    String _searchQuery = '';

    @override
    void initState() {
      super.initState();
      Future.microtask(
              () => context.read<SalaryHistoryProvider>().loadAllSummaries());
      _searchCtrl.addListener(() {
        setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
      });
    }

    @override
    void dispose() {
      _searchCtrl.dispose();
      super.dispose();
    }

    List<EmployeeSalarySummary> _filtered(List<EmployeeSalarySummary> all) {
      if (_searchQuery.isEmpty) return all;
      return all
          .where((e) =>
      e.staff.name.toLowerCase().contains(_searchQuery) ||
          (e.staff.designation ?? '').toLowerCase().contains(_searchQuery))
          .toList();
    }

    Future<void> _openEmployee(StaffMember staff) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SalaryAdjustmentScreen(staff: staff),
        ),
      );
      if (mounted) {
        context.read<SalaryHistoryProvider>().loadAllSummaries();
      }
    }

    Future<void> _openEmployeePicker() async {
      // Make sure staff + teacher lists are loaded before showing the picker.
      final staffProvider = context.read<StaffProvider>();
      if (staffProvider.allStaff.isEmpty) {
        await staffProvider.fetchAll();
      }

      if (!mounted) return;

      final selected = await showModalBottomSheet<StaffMember>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _EmployeePickerSheet(),
      );

      if (selected != null && mounted) {
        _openEmployee(selected);
      }
    }

    @override
    Widget build(BuildContext context) {
      final body = _buildBody();
      if (!widget.showAppBar) return body;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: _kPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Salary Management',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _kPurple,
          foregroundColor: Colors.white,
          onPressed: _openEmployeePicker,
          icon: const Icon(Icons.add),
          label: const Text('Add Adjustment'),
        ),
        body: body,
      );
    }

    Widget _buildBody() {
      return Consumer<SalaryHistoryProvider>(
        builder: (context, provider, _) {
          final filtered = _filtered(provider.summaries);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search by name or designation…',
                          hintStyle: TextStyle(
                              fontSize: 13, color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.search,
                              size: 18, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _kPurple),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    // Also offer the button here for wide/desktop layouts
                    // where a FAB may be less discoverable.
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _openEmployeePicker,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Adjustment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.loading
                    ? const Center(
                    child: CircularProgressIndicator(color: _kPurple))
                    : filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) =>
                      _employeeCard(filtered[i]),
                ),
              ),
            ],
          );
        },
      );
    }

    Widget _buildEmpty() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.payments_outlined,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isEmpty
                    ? 'No salary changes recorded yet.'
                    : 'No results for "$_searchQuery"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Tap "Add Adjustment" above to give someone their first increment or decrement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget _employeeCard(EmployeeSalarySummary summary) {
      final staff = summary.staff;
      final latest = summary.latestChange;
      final isIncrement = latest.isIncrement;
      final color = isIncrement ? _kGreen : _kRed;
      final bgColor = isIncrement ? _kGreenBg : _kRedBg;
      final icon =
      isIncrement ? Icons.trending_up_rounded : Icons.trending_down_rounded;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _openEmployee(staff),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _kPurpleLight,
                  child: Text(
                    staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kPurple),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E))),
                      if (staff.designation?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(staff.designation!,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600)),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 12, color: color),
                                const SizedBox(width: 3),
                                Text(
                                  'Rs ${_formatMoney(latest.amount)}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('on ${latest.date}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Current',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('Rs ${_formatMoney(staff.salary)}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 4),
                    Text('${summary.history.length} change(s)',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Bottom sheet used to pick any Staff or Teacher (regardless of whether
  /// they have salary history yet) so the first-ever adjustment can be made.
  /// Unified view – no teacher/staff filter, just all active employees.
  class _EmployeePickerSheet extends StatefulWidget {
    const _EmployeePickerSheet();

    @override
    State<_EmployeePickerSheet> createState() => _EmployeePickerSheetState();
  }

  class _EmployeePickerSheetState extends State<_EmployeePickerSheet> {
    final _searchCtrl = TextEditingController();
    String _query = '';

    @override
    void dispose() {
      _searchCtrl.dispose();
      super.dispose();
    }

    List<StaffMember> _filtered(List<StaffMember> all) {
      var list = all.where((s) => s.isActive).toList();
      if (_query.isNotEmpty) {
        list = list
            .where((s) =>
        s.name.toLowerCase().contains(_query) ||
            (s.designation ?? '').toLowerCase().contains(_query))
            .toList();
      }
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    }

    @override
    Widget build(BuildContext context) {
      final staffProvider = context.watch<StaffProvider>();
      final all = staffProvider.allStaff;
      final filtered = _filtered(all);

      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search_rounded,
                          color: _kPurple, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Select Employee',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) =>
                        setState(() => _query = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search by name or designation…',
                      hintStyle:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 10),
                // Removed filter chips – all employees shown together.
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: staffProvider.loading
                      ? const Center(
                      child: CircularProgressIndicator(color: _kPurple))
                      : filtered.isEmpty
                      ? Center(
                    child: Text(
                      'No employees found.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                  )
                      : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: Color(0xFFF0F0F0)),
                    itemBuilder: (ctx, i) {
                      final s = filtered[i];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: _kPurpleLight,
                          child: Text(
                            s.name.isNotEmpty
                                ? s.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _kPurple),
                          ),
                        ),
                        title: Text(s.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          [
                            // Always show "Staff" because we've unified all employees.
                            'Staff',
                            if (s.designation?.isNotEmpty == true)
                              s.designation!,
                          ].join(' • '),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: Text(
                          'Rs ${_formatMoney(s.salary)}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kPurple),
                        ),
                        onTap: () => Navigator.pop(context, s),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  String _formatMoney(double value) {
    return NumberFormat('#,##0').format(value);
  }
