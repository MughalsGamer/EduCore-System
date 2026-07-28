//
// //running code
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/fee_challan_model.dart';
// import '../../pdf_files/fee_challan_pdf_service.dart';
// import '../../providers/fee_challan_provider.dart';
// import '../../providers/school_setting_prodvider.dart';
//
// class ChallanListScreen extends StatefulWidget {
//   const ChallanListScreen({super.key});
//
//   @override
//   State<ChallanListScreen> createState() => _ChallanListScreenState();
// }
//
// class _ChallanListScreenState extends State<ChallanListScreen> {
//   static const _purple = Color(0xFF534AB7);
//   static const _lightPurple = Color(0xFFEEECFA);
//
//   int? _filterMonth = DateTime.now().month;
//   int? _filterYear = DateTime.now().year;
//
//   final _searchCtrl = TextEditingController();
//   String _searchQuery = '';
//
//   bool _selectMode = false;
//   final Set<String> _selectedIds = {};
//   bool _bulkBusy = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       context
//           .read<FeeChallanProvider>()
//           .loadAllChallans(month: _filterMonth, year: _filterYear);
//       final settingsProvider = context.read<SchoolSettingsProvider>();
//       if (settingsProvider.settings.schoolName.isEmpty && !settingsProvider.loading) {
//         settingsProvider.loadSettings();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   void _reload() {
//     context
//         .read<FeeChallanProvider>()
//         .loadAllChallans(month: _filterMonth, year: _filterYear);
//   }
//
//   String _fmtDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//   List<FeeChallanModel> _applySearch(List<FeeChallanModel> list) {
//     final q = _searchQuery.toLowerCase();
//     if (q.isEmpty) return list;
//     return list.where((c) {
//       return c.familyName.toLowerCase().contains(q) ||
//           c.fatherName.toLowerCase().contains(q) ||
//           c.familyId.toLowerCase().contains(q) ||
//           c.challanNumber.toLowerCase().contains(q);
//     }).toList();
//   }
//
//   void _toggleSelectMode() {
//     setState(() {
//       if (_selectMode) {
//         _selectMode = false;
//         _selectedIds.clear();
//       } else {
//         _selectMode = true;
//       }
//     });
//   }
//
//   void _selectAll(List<FeeChallanModel> challans) {
//     setState(() {
//       final allIds = challans.map((c) => c.id!).toSet();
//       if (_selectedIds.length == allIds.length) {
//         _selectedIds.clear();
//       } else {
//         _selectedIds
//           ..clear()
//           ..addAll(allIds);
//       }
//     });
//   }
//
//   void _toggleItem(String id) {
//     setState(() {
//       if (_selectedIds.contains(id)) {
//         _selectedIds.remove(id);
//         if (_selectedIds.isEmpty) _selectMode = false;
//       } else {
//         _selectedIds.add(id);
//       }
//     });
//   }
//
//   // ─── Single challan PDF actions ───
//   Future<void> _printSingle(FeeChallanModel challan) async {
//     final settings = context.read<SchoolSettingsProvider>().settings;
//     try {
//       await FeeChallanPdfService.printChallan(challan, settings);
//     } catch (e) {
//       _showSnack('Print failed: $e', isError: true);
//     }
//   }
//
//   Future<void> _saveSingle(FeeChallanModel challan) async {
//     final settings = context.read<SchoolSettingsProvider>().settings;
//     try {
//       await FeeChallanPdfService.downloadAndOpen(challan, settings);
//       _showSnack('Challan saved');
//     } catch (e) {
//       _showSnack('Save failed: $e', isError: true);
//     }
//   }
//
//   // ─── Bulk PDF actions ───
//   Future<void> _bulkPrint(List<FeeChallanModel> allChallans) async {
//     if (_selectedIds.isEmpty || _bulkBusy) return;
//     final selected = allChallans.where((c) => _selectedIds.contains(c.id)).toList();
//     if (selected.isEmpty) return;
//
//     setState(() => _bulkBusy = true);
//     final settings = context.read<SchoolSettingsProvider>().settings;
//     try {
//       await FeeChallanPdfService.bulkPrint(selected, settings);
//     } catch (e) {
//       _showSnack('Print failed: $e', isError: true);
//     } finally {
//       if (mounted) setState(() => _bulkBusy = false);
//     }
//   }
//
//   Future<void> _bulkSave(List<FeeChallanModel> allChallans) async {
//     if (_selectedIds.isEmpty || _bulkBusy) return;
//     final selected = allChallans.where((c) => _selectedIds.contains(c.id)).toList();
//     if (selected.isEmpty) return;
//
//     setState(() => _bulkBusy = true);
//     final settings = context.read<SchoolSettingsProvider>().settings;
//     try {
//       await FeeChallanPdfService.bulkDownload(selected, settings);
//       _showSnack('${selected.length} challans saved');
//     } catch (e) {
//       _showSnack('Save failed: $e', isError: true);
//     } finally {
//       if (mounted) setState(() => _bulkBusy = false);
//     }
//   }
//
//   void _showSnack(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   // ─── Build methods ───
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<FeeChallanProvider>();
//     final challans = _applySearch(provider.allChallans);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5FA),
//       appBar: AppBar(
//         title: _selectMode
//             ? Text('${_selectedIds.length} selected')
//             : const Text('Fee Challans'),
//         centerTitle: true,
//         backgroundColor: _purple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           if (_selectMode) ...[
//             IconButton(
//               icon: const Icon(Icons.select_all),
//               tooltip: 'Select All',
//               onPressed: () => _selectAll(challans),
//             ),
//             IconButton(
//               icon: const Icon(Icons.close),
//               tooltip: 'Cancel',
//               onPressed: _toggleSelectMode,
//             ),
//           ] else ...[
//             IconButton(
//               icon: const Icon(Icons.checklist_outlined),
//               tooltip: 'Select',
//               onPressed: challans.isEmpty ? null : _toggleSelectMode,
//             ),
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: provider.isLoadingList ? null : _reload,
//             ),
//           ],
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildFilters(),
//           if (provider.listError != null) _buildErrorBanner(provider),
//           Expanded(
//             child: provider.isLoadingList
//                 ? const Center(child: CircularProgressIndicator(color: _purple))
//                 : challans.isEmpty
//                 ? _buildEmpty()
//                 : LayoutBuilder(
//               builder: (context, constraints) {
//                 final isDesktop = constraints.maxWidth >= 800;
//                 return isDesktop
//                     ? _buildDesktopTable(challans, provider)
//                     : _buildMobileList(challans, provider);
//               },
//             ),
//           ),
//           if (_selectedIds.isNotEmpty && _selectMode) _buildBulkActionBar(challans),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBulkActionBar(List<FeeChallanModel> challans) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.grey.shade200)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2)),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           children: [
//             const Icon(Icons.checklist, color: _purple, size: 20),
//             const SizedBox(width: 8),
//             Text('${_selectedIds.length} selected',
//                 style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//             const Spacer(),
//             OutlinedButton.icon(
//               onPressed: _bulkBusy ? null : () => _bulkPrint(challans),
//               icon: _bulkBusy
//                   ? const SizedBox(
//                   width: 14,
//                   height: 14,
//                   child: CircularProgressIndicator(strokeWidth: 2))
//                   : Icon(Icons.print_outlined, size: 16, color: Colors.grey.shade700),
//               label: Text('Print',
//                   style: TextStyle(
//                       color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: Colors.grey.shade300),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               ),
//             ),
//             const SizedBox(width: 10),
//             ElevatedButton.icon(
//               onPressed: _bulkBusy ? null : () => _bulkSave(challans),
//               icon: _bulkBusy
//                   ? const SizedBox(
//                   width: 14,
//                   height: 14,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                   : const Icon(Icons.download_rounded, size: 16, color: Colors.white),
//               label: const Text('Save',
//                   style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _purple,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilters() {
//     final currentYear = DateTime.now().year;
//     final years = {
//       currentYear - 2, currentYear - 1, currentYear, currentYear + 1,
//       currentYear + 2, currentYear + 3, if (_filterYear != null) _filterYear!,
//     }.toList()
//       ..sort();
//
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 flex: 3,
//                 child: _dropdownShell(
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<int?>(
//                       value: _filterMonth,
//                       isExpanded: true,
//                       hint: const Text('All Months',
//                           style: TextStyle(fontSize: 13, color: Colors.black87)),
//                       icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
//                       items: [
//                         const DropdownMenuItem<int?>(
//                           value: null,
//                           child: Text('All Months', style: TextStyle(fontSize: 13)),
//                         ),
//                         ...List.generate(12, (i) => i + 1).map(
//                               (m) => DropdownMenuItem<int?>(
//                             value: m,
//                             child: Text(FeeChallanModel.monthNames[m],
//                                 style: const TextStyle(fontSize: 13)),
//                           ),
//                         ),
//                       ],
//                       onChanged: (v) {
//                         setState(() => _filterMonth = v);
//                         _reload();
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 flex: 2,
//                 child: _dropdownShell(
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<int?>(
//                       value: _filterYear,
//                       isExpanded: true,
//                       hint: const Text('All Years',
//                           style: TextStyle(fontSize: 13, color: Colors.black87)),
//                       icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
//                       items: [
//                         const DropdownMenuItem<int?>(
//                           value: null,
//                           child: Text('All Years', style: TextStyle(fontSize: 13)),
//                         ),
//                         ...years.map(
//                               (y) => DropdownMenuItem<int?>(
//                             value: y,
//                             child: Text('$y', style: const TextStyle(fontSize: 13)),
//                           ),
//                         ),
//                       ],
//                       onChanged: (v) {
//                         setState(() => _filterYear = v);
//                         _reload();
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5FA),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: TextField(
//               controller: _searchCtrl,
//               onChanged: (v) => setState(() => _searchQuery = v.trim()),
//               decoration: InputDecoration(
//                 hintText: 'Search by family, father or challan number...',
//                 hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
//                 prefixIcon: const Icon(Icons.search, color: _purple, size: 20),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 10),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _dropdownShell({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       height: 46,
//       decoration: BoxDecoration(
//         color: _lightPurple,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       alignment: Alignment.center,
//       child: child,
//     );
//   }
//
//   Widget _buildErrorBanner(FeeChallanProvider p) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(p.listError!,
//                 style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
//           const SizedBox(height: 16),
//           Text(
//             _searchQuery.isEmpty ? 'No challans found' : 'No search results found',
//             style: TextStyle(
//                 color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMobileList(List<FeeChallanModel> challans, FeeChallanProvider provider) {
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
//       itemCount: challans.length,
//       itemBuilder: (context, i) {
//         final c = challans[i];
//         final isSelected = _selectedIds.contains(c.id);
//         return _ChallanCard(
//           challan: c,
//           selectMode: _selectMode,
//           selected: isSelected,
//           onTap: _selectMode ? () => _toggleItem(c.id!) : null,
//           onDelete: () => _confirmDelete(c, provider),
//           onPrint: () => _printSingle(c),
//           onSave: () => _saveSingle(c),
//         );
//       },
//     );
//   }
//
//   Widget _buildDesktopTable(List<FeeChallanModel> challans, FeeChallanProvider provider) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: _lightPurple,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
//               ),
//               child: Row(
//                 children: [
//                   if (_selectMode) const SizedBox(width: 40),
//                   const Expanded(flex: 2, child: _HeaderCell('Challan #')),
//                   const Expanded(flex: 3, child: _HeaderCell('Family')),
//                   const Expanded(flex: 2, child: _HeaderCell('Month')),
//                   const Expanded(flex: 1, child: _HeaderCell('Students')),
//                   const Expanded(flex: 2, child: _HeaderCell('Grand Total')),
//                   const Expanded(flex: 2, child: _HeaderCell('Status')),
//                   const Expanded(flex: 2, child: _HeaderCell('Due Date')),
//                   const SizedBox(width: 96),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: challans.length,
//                 separatorBuilder: (_, __) =>
//                     Divider(height: 1, color: Colors.grey.shade100),
//                 itemBuilder: (context, i) {
//                   final c = challans[i];
//                   return _ChallanRow(
//                     challan: c,
//                     selectMode: _selectMode,
//                     selected: _selectedIds.contains(c.id),
//                     onToggleSelect: () => _toggleItem(c.id!),
//                     onDelete: () => _confirmDelete(c, provider),
//                     onPrint: () => _printSingle(c),
//                     onSave: () => _saveSingle(c),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _confirmDelete(FeeChallanModel challan, FeeChallanProvider provider) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Delete this challan?'),
//         content: Text(
//             '${challan.challanNumber} — ${challan.familyName}\n'
//                 '${challan.monthLabel} ${challan.year}\n\n'
//                 'This action cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed != true) return;
//     if (!mounted) return;
//
//     final ok = await provider.deleteChallan(challan);
//     if (!mounted) return;
//
//     _showSnack(
//       ok ? 'Challan deleted' : (provider.listError ?? 'Delete failed'),
//       isError: !ok,
//     );
//   }
// }
//
// // ─── Desktop table header cell ───
// class _HeaderCell extends StatelessWidget {
//   final String text;
//   const _HeaderCell(this.text);
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(text,
//         style: TextStyle(
//             fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700));
//   }
// }
//
// // ─── Desktop table row ───
// class _ChallanRow extends StatefulWidget {
//   final FeeChallanModel challan;
//   final bool selectMode;
//   final bool selected;
//   final VoidCallback onToggleSelect;
//   final VoidCallback onDelete;
//   final VoidCallback onPrint;
//   final VoidCallback onSave;
//
//   const _ChallanRow({
//     required this.challan,
//     required this.selectMode,
//     required this.selected,
//     required this.onToggleSelect,
//     required this.onDelete,
//     required this.onPrint,
//     required this.onSave,
//   });
//
//   @override
//   State<_ChallanRow> createState() => _ChallanRowState();
// }
//
// class _ChallanRowState extends State<_ChallanRow> {
//   bool _expanded = false;
//   static const _purple = Color(0xFF534AB7);
//
//   String _fmtDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//   @override
//   Widget build(BuildContext context) {
//     final c = widget.challan;
//     return Container(
//       color: _expanded ? const Color(0xFFFAFAFF) : Colors.transparent,
//       child: Column(
//         children: [
//           InkWell(
//             onTap: widget.selectMode
//                 ? widget.onToggleSelect
//                 : () => setState(() => _expanded = !_expanded),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Row(
//                 children: [
//                   if (widget.selectMode)
//                     SizedBox(
//                       width: 40,
//                       child: Checkbox(
//                         value: widget.selected,
//                         onChanged: (_) => widget.onToggleSelect(),
//                         activeColor: _purple,
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         visualDensity: VisualDensity.compact,
//                       ),
//                     )
//                   else ...[
//                     Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                         color: Colors.grey.shade400, size: 20),
//                     const SizedBox(width: 6),
//                   ],
//                   Expanded(
//                       flex: 2,
//                       child: Text(c.challanNumber,
//                           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
//                   Expanded(
//                     flex: 3,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(c.familyName,
//                             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//                         Text(c.fatherName,
//                             style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                       flex: 2,
//                       child:
//                       Text('${c.monthLabel} ${c.year}', style: const TextStyle(fontSize: 13))),
//                   Expanded(
//                       flex: 1,
//                       child: Text('${c.students.length}', style: const TextStyle(fontSize: 13))),
//                   Expanded(
//                       flex: 2,
//                       child: Text('Rs ${c.grandTotal.toStringAsFixed(0)}',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, color: _purple, fontSize: 13))),
//                   Expanded(flex: 2, child: _StatusChip(status: c.status)),
//                   Expanded(
//                       flex: 2,
//                       child: Text(_fmtDate(c.dueDate),
//                           style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
//                   SizedBox(
//                     width: 96,
//                     child: widget.selectMode
//                         ? const SizedBox.shrink()
//                         : Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.print_outlined, color: Colors.grey.shade600, size: 18),
//                           onPressed: widget.onPrint,
//                           tooltip: 'Print',
//                           visualDensity: VisualDensity.compact,
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.download_rounded, color: _purple, size: 18),
//                           onPressed: widget.onSave,
//                           tooltip: 'Save',
//                           visualDensity: VisualDensity.compact,
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18),
//                           onPressed: widget.onDelete,
//                           tooltip: 'Delete',
//                           visualDensity: VisualDensity.compact,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (_expanded && !widget.selectMode)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(46, 0, 16, 16),
//               child: _ChallanDetailPanel(challan: c),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Mobile card ───
// class _ChallanCard extends StatefulWidget {
//   final FeeChallanModel challan;
//   final bool selectMode;
//   final bool selected;
//   final VoidCallback? onTap;
//   final VoidCallback onDelete;
//   final VoidCallback onPrint;
//   final VoidCallback onSave;
//
//   const _ChallanCard({
//     required this.challan,
//     required this.selectMode,
//     required this.selected,
//     required this.onTap,
//     required this.onDelete,
//     required this.onPrint,
//     required this.onSave,
//   });
//
//   @override
//   State<_ChallanCard> createState() => _ChallanCardState();
// }
//
// class _ChallanCardState extends State<_ChallanCard> {
//   bool _expanded = false;
//   static const _purple = Color(0xFF534AB7);
//   static const _lightPurple = Color(0xFFEEECFA);
//
//   String _fmtDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//   @override
//   Widget build(BuildContext context) {
//     final c = widget.challan;
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: widget.selected ? 3 : 1,
//       shadowColor: _purple.withOpacity(0.1),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//         side: BorderSide(
//             color: widget.selected ? _purple : Colors.transparent, width: 1.5),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: widget.selectMode ? widget.onTap : () => setState(() => _expanded = !_expanded),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   if (widget.selectMode) ...[
//                     Icon(
//                       widget.selected ? Icons.check_circle : Icons.circle_outlined,
//                       color: widget.selected ? _purple : Colors.grey.shade300,
//                       size: 22,
//                     ),
//                     const SizedBox(width: 10),
//                   ],
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: _lightPurple,
//                     child: Text(
//                       c.familyName.isNotEmpty ? c.familyName[0].toUpperCase() : 'F',
//                       style: const TextStyle(color: _purple, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(c.familyName,
//                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                         const SizedBox(height: 2),
//                         Text('${c.challanNumber} • ${c.monthLabel} ${c.year}',
//                             style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                       ],
//                     ),
//                   ),
//                   if (!widget.selectMode) ...[
//                     IconButton(
//                       icon: Icon(Icons.print_outlined, color: Colors.grey.shade600, size: 20),
//                       onPressed: widget.onPrint,
//                       tooltip: 'Print',
//                       visualDensity: VisualDensity.compact,
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.download_rounded, color: _purple, size: 20),
//                       onPressed: widget.onSave,
//                       tooltip: 'Save',
//                       visualDensity: VisualDensity.compact,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
//                       onPressed: widget.onDelete,
//                       tooltip: 'Delete',
//                       visualDensity: VisualDensity.compact,
//                     ),
//                     Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                         color: Colors.grey.shade400, size: 20),
//                   ],
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('${c.students.length} student${c.students.length != 1 ? 's' : ''}',
//                       style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                   _StatusChip(status: c.status),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Due: ${_fmtDate(c.dueDate)}',
//                       style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
//                   Text('Rs ${c.grandTotal.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, color: _purple, fontSize: 15)),
//                 ],
//               ),
//               if (_expanded && !widget.selectMode) ...[
//                 const SizedBox(height: 10),
//                 const Divider(height: 1),
//                 const SizedBox(height: 10),
//                 _ChallanDetailPanel(challan: c),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Shared expanded detail panel ───
// class _ChallanDetailPanel extends StatelessWidget {
//   final FeeChallanModel challan;
//   const _ChallanDetailPanel({required this.challan});
//
//   static const _purple = Color(0xFF534AB7);
//
//   String _fmtDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//   @override
//   Widget build(BuildContext context) {
//     final c = challan;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Family ID: ${c.familyId}',
//             style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//         if (c.fatherPhone.isNotEmpty) ...[
//           const SizedBox(height: 2),
//           Text('Phone: ${c.fatherPhone}',
//               style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//         ],
//         const SizedBox(height: 10),
//         Text('Students',
//             style: TextStyle(
//                 fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
//         const SizedBox(height: 6),
//         ...c.students.map((s) => Padding(
//           padding: const EdgeInsets.only(bottom: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Flexible(
//                           child: Text(s.name,
//                               style: const TextStyle(
//                                   fontSize: 12, fontWeight: FontWeight.w600),
//                               overflow: TextOverflow.ellipsis),
//                         ),
//                         if (s.className != null && s.className!.isNotEmpty) ...[
//                           const SizedBox(width: 5),
//                           Text('(${s.className}${s.sectionName != null && s.sectionName!.isNotEmpty ? ' - ${s.sectionName}' : ''})',
//                               style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                         ],
//                         if (s.isFirstChallan) ...[
//                           const SizedBox(width: 5),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 5, vertical: 1),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade50,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text('1st Challan',
//                                 style: TextStyle(
//                                     fontSize: 9,
//                                     color: Colors.orange.shade700,
//                                     fontWeight: FontWeight.w600)),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   Text('Rs ${s.lineTotal.toStringAsFixed(0)}',
//                       style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 4, top: 2),
//                 child: Text(
//                   s.isFirstChallan
//                       ? 'Admission: Rs ${s.registrationFee.toStringAsFixed(0)}  •  '
//                       'Annual: Rs ${s.annualFee.toStringAsFixed(0)}  •  '
//                       'Monthly: Rs ${s.monthlyFee.toStringAsFixed(0)}'
//                       : 'Monthly: Rs ${s.monthlyFee.toStringAsFixed(0)}',
//                   style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
//                 ),
//               ),
//             ],
//           ),
//         )),
//         const SizedBox(height: 4),
//         const Divider(height: 12),
//         _totalRow('Current Month', c.currentMonthTotal),
//         if (c.previousBalance > 0) _totalRow('Previous Balance', c.previousBalance),
//         if (c.previousBalance < 0) _totalRow('Advance Carried Forward', c.previousBalance),
//         _totalRow('Grand Total', c.grandTotal, bold: true),
//         _totalRow('Amount Paid', c.amountPaid),
//         _totalRow('Remaining Balance', c.remainingBalance, bold: true),
//         const SizedBox(height: 6),
//         Text('Generated: ${_fmtDate(c.generatedDate)}   •   Due: ${_fmtDate(c.dueDate)}',
//             style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//       ],
//     );
//   }
//
//   Widget _totalRow(String label, double value, {bool bold = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: TextStyle(
//                   fontSize: 12,
//                   color: bold ? Colors.black87 : Colors.grey.shade600,
//                   fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
//           Text('Rs ${value.toStringAsFixed(0)}',
//               style: TextStyle(
//                   fontSize: 12,
//                   color: bold ? _purple : Colors.black87,
//                   fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Status chip ───
// class _StatusChip extends StatelessWidget {
//   final String status;
//   const _StatusChip({required this.status});
//
//   @override
//   Widget build(BuildContext context) {
//     Color bg;
//     Color fg;
//     String label;
//     switch (status) {
//       case 'paid':
//         bg = Colors.green.shade50;
//         fg = Colors.green.shade700;
//         label = 'Paid';
//         break;
//       case 'partial':
//         bg = Colors.orange.shade50;
//         fg = Colors.orange.shade700;
//         label = 'Partial';
//         break;
//       default:
//         bg = Colors.red.shade50;
//         fg = Colors.red.shade700;
//         label = 'Pending';
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
//       child: Text(label,
//           style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700)),
//     );
//   }
// }
//
//



//running code



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/fee_challan_model.dart';
import '../../pdf_files/fee_challan_pdf_service.dart';
import '../../providers/fee_challan_provider.dart';
import '../../providers/fee_collection_provider.dart';
import '../../providers/school_setting_prodvider.dart';

class ChallanListScreen extends StatefulWidget {
  const ChallanListScreen({super.key});

  @override
  State<ChallanListScreen> createState() => _ChallanListScreenState();
}

class _ChallanListScreenState extends State<ChallanListScreen> {
  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  int? _filterMonth = DateTime.now().month;
  int? _filterYear = DateTime.now().year;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  bool _selectMode = false;
  final Set<String> _selectedIds = {};
  bool _bulkBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<FeeChallanProvider>()
          .loadAllChallans(month: _filterMonth, year: _filterYear);
      final settingsProvider = context.read<SchoolSettingsProvider>();
      if (settingsProvider.settings.schoolName.isEmpty && !settingsProvider.loading) {
        settingsProvider.loadSettings();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    context
        .read<FeeChallanProvider>()
        .loadAllChallans(month: _filterMonth, year: _filterYear);
  }

  List<FeeChallanModel> _applySearch(List<FeeChallanModel> list) {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return list;
    return list.where((c) {
      return c.familyName.toLowerCase().contains(q) ||
          c.fatherName.toLowerCase().contains(q) ||
          c.familyId.toLowerCase().contains(q) ||
          c.challanNumber.toLowerCase().contains(q);
    }).toList();
  }

  void _toggleSelectMode() {
    setState(() {
      if (_selectMode) {
        _selectMode = false;
        _selectedIds.clear();
      } else {
        _selectMode = true;
      }
    });
  }

  void _selectAll(List<FeeChallanModel> challans) {
    setState(() {
      final allIds = challans.map((c) => c.id!).toSet();
      if (_selectedIds.length == allIds.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(allIds);
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // ─── Single challan PDF actions ───
  Future<void> _printSingle(FeeChallanModel challan) async {
    final settings = context.read<SchoolSettingsProvider>().settings;
    try {
      await FeeChallanPdfService.printChallan(challan, settings);
    } catch (e) {
      _showSnack('Print failed: $e', isError: true);
    }
  }

  Future<void> _saveSingle(FeeChallanModel challan) async {
    final settings = context.read<SchoolSettingsProvider>().settings;
    try {
      await FeeChallanPdfService.downloadAndOpen(challan, settings);
      _showSnack('Challan saved');
    } catch (e) {
      _showSnack('Save failed: $e', isError: true);
    }
  }

  // ─── Bulk PDF actions ───
  Future<void> _bulkPrint(List<FeeChallanModel> allChallans) async {
    if (_selectedIds.isEmpty || _bulkBusy) return;
    final selected = allChallans.where((c) => _selectedIds.contains(c.id)).toList();
    if (selected.isEmpty) return;

    setState(() => _bulkBusy = true);
    final settings = context.read<SchoolSettingsProvider>().settings;
    try {
      await FeeChallanPdfService.bulkPrint(selected, settings);
    } catch (e) {
      _showSnack('Print failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _bulkBusy = false);
    }
  }

  Future<void> _bulkSave(List<FeeChallanModel> allChallans) async {
    if (_selectedIds.isEmpty || _bulkBusy) return;
    final selected = allChallans.where((c) => _selectedIds.contains(c.id)).toList();
    if (selected.isEmpty) return;

    setState(() => _bulkBusy = true);
    final settings = context.read<SchoolSettingsProvider>().settings;
    try {
      await FeeChallanPdfService.bulkDownload(selected, settings);
      _showSnack('${selected.length} challans saved');
    } catch (e) {
      _showSnack('Save failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _bulkBusy = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Build methods ───
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeeChallanProvider>();
    final challans = _applySearch(provider.allChallans);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: _selectMode
            ? Text('${_selectedIds.length} selected')
            : const Text('Fee Challans'),
        centerTitle: true,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Select All',
              onPressed: () => _selectAll(challans),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: _toggleSelectMode,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist_outlined),
              tooltip: 'Select',
              onPressed: challans.isEmpty ? null : _toggleSelectMode,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: provider.isLoadingList ? null : _reload,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          if (provider.listError != null) _buildErrorBanner(provider),
          Expanded(
            child: provider.isLoadingList
                ? const Center(child: CircularProgressIndicator(color: _purple))
                : challans.isEmpty
                ? _buildEmpty()
                : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 800;
                return isDesktop
                    ? _buildDesktopTable(challans, provider)
                    : _buildMobileList(challans, provider);
              },
            ),
          ),
          if (_selectedIds.isNotEmpty && _selectMode) _buildBulkActionBar(challans),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar(List<FeeChallanModel> challans) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(Icons.checklist, color: _purple, size: 20),
            const SizedBox(width: 8),
            Text('${_selectedIds.length} selected',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _bulkBusy ? null : () => _bulkPrint(challans),
              icon: _bulkBusy
                  ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.print_outlined, size: 16, color: Colors.grey.shade700),
              label: Text('Print',
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _bulkBusy ? null : () => _bulkSave(challans),
              icon: _bulkBusy
                  ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download_rounded, size: 16, color: Colors.white),
              label: const Text('Save',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final currentYear = DateTime.now().year;
    final years = {
      currentYear - 2, currentYear - 1, currentYear, currentYear + 1,
      currentYear + 2, currentYear + 3, if (_filterYear != null) _filterYear!,
    }.toList()
      ..sort();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _dropdownShell(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _filterMonth,
                      isExpanded: true,
                      hint: const Text('All Months',
                          style: TextStyle(fontSize: 13, color: Colors.black87)),
                      icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Months', style: TextStyle(fontSize: 13)),
                        ),
                        ...List.generate(12, (i) => i + 1).map(
                              (m) => DropdownMenuItem<int?>(
                            value: m,
                            child: Text(FeeChallanModel.monthNames[m],
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => _filterMonth = v);
                        _reload();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _dropdownShell(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _filterYear,
                      isExpanded: true,
                      hint: const Text('All Years',
                          style: TextStyle(fontSize: 13, color: Colors.black87)),
                      icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Years', style: TextStyle(fontSize: 13)),
                        ),
                        ...years.map(
                              (y) => DropdownMenuItem<int?>(
                            value: y,
                            child: Text('$y', style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => _filterYear = v);
                        _reload();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search by family, father or challan number...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: _purple, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownShell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 46,
      decoration: BoxDecoration(
        color: _lightPurple,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildErrorBanner(FeeChallanProvider p) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(p.listError!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No challans found' : 'No search results found',
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<FeeChallanModel> challans, FeeChallanProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: challans.length,
      itemBuilder: (context, i) {
        final c = challans[i];
        final isSelected = _selectedIds.contains(c.id);
        return _ChallanCard(
          challan: c,
          selectMode: _selectMode,
          selected: isSelected,
          onTap: _selectMode ? () => _toggleItem(c.id!) : null,
          onDelete: () => _confirmDelete(c, provider),
          onPrint: () => _printSingle(c),
          onSave: () => _saveSingle(c),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<FeeChallanModel> challans, FeeChallanProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _lightPurple,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  if (_selectMode) const SizedBox(width: 40),
                  const Expanded(flex: 2, child: _HeaderCell('Challan #')),
                  const Expanded(flex: 3, child: _HeaderCell('Family')),
                  const Expanded(flex: 2, child: _HeaderCell('Month')),
                  const Expanded(flex: 1, child: _HeaderCell('Students')),
                  const Expanded(flex: 2, child: _HeaderCell('This Month')),
                  const Expanded(flex: 2, child: _HeaderCell('Due Date')),
                  const SizedBox(width: 96),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: challans.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, i) {
                  final c = challans[i];
                  return _ChallanRow(
                    challan: c,
                    selectMode: _selectMode,
                    selected: _selectedIds.contains(c.id),
                    onToggleSelect: () => _toggleItem(c.id!),
                    onDelete: () => _confirmDelete(c, provider),
                    onPrint: () => _printSingle(c),
                    onSave: () => _saveSingle(c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(FeeChallanModel challan, FeeChallanProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this challan?'),
        content: Text(
            '${challan.challanNumber} — ${challan.familyName}\n'
                '${challan.monthLabel} ${challan.year}\n\n'
                'This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final ok = await provider.deleteChallan(challan);
    if (!mounted) return;

    _showSnack(
      ok ? 'Challan deleted' : (provider.listError ?? 'Delete failed'),
      isError: !ok,
    );
  }
}

// ─── Desktop table header cell ───
class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700));
  }
}

// ─── Desktop table row ───
class _ChallanRow extends StatefulWidget {
  final FeeChallanModel challan;
  final bool selectMode;
  final bool selected;
  final VoidCallback onToggleSelect;
  final VoidCallback onDelete;
  final VoidCallback onPrint;
  final VoidCallback onSave;

  const _ChallanRow({
    required this.challan,
    required this.selectMode,
    required this.selected,
    required this.onToggleSelect,
    required this.onDelete,
    required this.onPrint,
    required this.onSave,
  });

  @override
  State<_ChallanRow> createState() => _ChallanRowState();
}

class _ChallanRowState extends State<_ChallanRow> {
  bool _expanded = false;
  static const _purple = Color(0xFF534AB7);

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final c = widget.challan;
    return Container(
      color: _expanded ? const Color(0xFFFAFAFF) : Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: widget.selectMode
                ? widget.onToggleSelect
                : () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (widget.selectMode)
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: widget.selected,
                        onChanged: (_) => widget.onToggleSelect(),
                        activeColor: _purple,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  else ...[
                    Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                      flex: 2,
                      child: Text(c.challanNumber,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.familyName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(c.fatherName,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child:
                      Text('${c.monthLabel} ${c.year}', style: const TextStyle(fontSize: 13))),
                  Expanded(
                      flex: 1,
                      child: Text('${c.students.length}', style: const TextStyle(fontSize: 13))),
                  Expanded(
                      flex: 2,
                      child: Text('Rs ${c.currentMonthTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: _purple, fontSize: 13))),
                  Expanded(
                      flex: 2,
                      child: Text(_fmtDate(c.dueDate),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                  SizedBox(
                    width: 96,
                    child: widget.selectMode
                        ? const SizedBox.shrink()
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.print_outlined, color: Colors.grey.shade600, size: 18),
                          onPressed: widget.onPrint,
                          tooltip: 'Print',
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_rounded, color: _purple, size: 18),
                          onPressed: widget.onSave,
                          tooltip: 'Save',
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18),
                          onPressed: widget.onDelete,
                          tooltip: 'Delete',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && !widget.selectMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(46, 0, 16, 16),
              child: _ChallanDetailPanel(challan: c),
            ),
        ],
      ),
    );
  }
}

// ─── Mobile card ───
class _ChallanCard extends StatefulWidget {
  final FeeChallanModel challan;
  final bool selectMode;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback onDelete;
  final VoidCallback onPrint;
  final VoidCallback onSave;

  const _ChallanCard({
    required this.challan,
    required this.selectMode,
    required this.selected,
    required this.onTap,
    required this.onDelete,
    required this.onPrint,
    required this.onSave,
  });

  @override
  State<_ChallanCard> createState() => _ChallanCardState();
}

class _ChallanCardState extends State<_ChallanCard> {
  bool _expanded = false;
  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final c = widget.challan;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: widget.selected ? 3 : 1,
      shadowColor: _purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: widget.selected ? _purple : Colors.transparent, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.selectMode ? widget.onTap : () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.selectMode) ...[
                    Icon(
                      widget.selected ? Icons.check_circle : Icons.circle_outlined,
                      color: widget.selected ? _purple : Colors.grey.shade300,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                  ],
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _lightPurple,
                    child: Text(
                      c.familyName.isNotEmpty ? c.familyName[0].toUpperCase() : 'F',
                      style: const TextStyle(color: _purple, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.familyName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('${c.challanNumber} • ${c.monthLabel} ${c.year}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  if (!widget.selectMode) ...[
                    IconButton(
                      icon: Icon(Icons.print_outlined, color: Colors.grey.shade600, size: 20),
                      onPressed: widget.onPrint,
                      tooltip: 'Print',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, color: _purple, size: 20),
                      onPressed: widget.onSave,
                      tooltip: 'Save',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                    ),
                    Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${c.students.length} student${c.students.length != 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text('Due: ${_fmtDate(c.dueDate)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Rs ${c.currentMonthTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: _purple, fontSize: 15)),
              ),
              if (_expanded && !widget.selectMode) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _ChallanDetailPanel(challan: c),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared expanded detail panel ───
// Shows student-wise breakdown (from the challan itself, a pure
// debit entry) plus the family's LIVE running balance, fetched from
// FeeCollectionProvider only when this panel is actually expanded.
class _ChallanDetailPanel extends StatefulWidget {
  final FeeChallanModel challan;
  const _ChallanDetailPanel({required this.challan});

  @override
  State<_ChallanDetailPanel> createState() => _ChallanDetailPanelState();
}

class _ChallanDetailPanelState extends State<_ChallanDetailPanel> {
  static const _purple = Color(0xFF534AB7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<FeeCollectionProvider>()
          .loadBalanceForFamily(widget.challan.familyDocId);
    });
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtMoney(double v) {
    final neg = v < 0;
    final abs = v.abs().toStringAsFixed(0);
    return '${neg ? '-' : ''}Rs $abs';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challan;
    final collProvider = context.watch<FeeCollectionProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Family ID: ${c.familyId}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        if (c.fatherPhone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text('Phone: ${c.fatherPhone}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
        const SizedBox(height: 10),
        Text('Students',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        ...c.students.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(s.name,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (s.className != null && s.className!.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Text('(${s.className}${s.sectionName != null && s.sectionName!.isNotEmpty ? ' - ${s.sectionName}' : ''})',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                        if (s.isFirstChallan) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('1st Challan',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text('Rs ${s.lineTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 2),
                child: Text(
                  s.isFirstChallan
                      ? 'Admission: Rs ${s.registrationFee.toStringAsFixed(0)}  •  '
                      'Annual: Rs ${s.annualFee.toStringAsFixed(0)}  •  '
                      'Monthly: Rs ${s.monthlyFee.toStringAsFixed(0)}'
                      : 'Monthly: Rs ${s.monthlyFee.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 4),
        const Divider(height: 12),
        _totalRow('This Challan (Debit)', c.currentMonthTotal, bold: true),
        const SizedBox(height: 8),

        // Live family balance — sum(all challans) - sum(all collections)
        collProvider.isLoadingBalance
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
        )
            : Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: collProvider.currentBalance > 0
                ? Colors.orange.shade50
                : (collProvider.currentBalance < 0
                ? Colors.green.shade50
                : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                collProvider.currentBalance > 0
                    ? 'Family Balance (Pending)'
                    : (collProvider.currentBalance < 0
                    ? 'Family Advance Balance'
                    : 'Family Balance'),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                _fmtMoney(collProvider.currentBalance),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: collProvider.currentBalance > 0
                        ? Colors.orange.shade800
                        : (collProvider.currentBalance < 0
                        ? Colors.green.shade800
                        : Colors.black87)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text('Generated: ${_fmtDate(c.generatedDate)}   •   Due: ${_fmtDate(c.dueDate)}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: bold ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
          Text('Rs ${value.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 12,
                  color: bold ? _purple : Colors.black87,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
        ],
      ),
    );
  }
}