// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:provider/provider.dart';
//
// import '../../providers/admission_provider.dart';
// import '../../providers/fee_collection_provider.dart';
//
// // ─────────────────────────────────────────────
// //  Fee Collection Screen
// //  Family-wise payment collection against the family's
// //  latest challan (or standalone if none exists yet).
// //
// //  - Search box + keyboard (Up/Down/Enter) + mouse click,
// //    both work identically.
// //  - First regular-admission student's pic shown (compressed).
// //  - Selecting a family loads its current balance instantly.
// //  - Amount entry shows a live "balance after" preview.
// //  - Desktop: two-column layout (list left, form right).
// //  - Mobile: single column, form appears after selection.
// // ─────────────────────────────────────────────
// class FeeCollectionScreen extends StatefulWidget {
//   const FeeCollectionScreen({super.key});
//
//   @override
//   State<FeeCollectionScreen> createState() => _FeeCollectionScreenState();
// }
//
// class _FeeCollectionScreenState extends State<FeeCollectionScreen> {
//   static const _purple = Color(0xFF534AB7);
//   static const _lightPurple = Color(0xFFEEECFA);
//
//   final _searchCtrl = TextEditingController();
//   final _searchFocusNode = FocusNode();
//   final _amountCtrl = TextEditingController();
//   final _noteCtrl = TextEditingController();
//
//   String _query = '';
//   List<FamilyForCollection> _allFamilies = [];
//   List<FamilyForCollection> _filtered = [];
//   int _highlightedIndex = -1;
//
//   FamilyForCollection? _selectedFamily;
//   DateTime _paymentDate = DateTime.now();
//   String _paymentMethod = 'Cash';
//   bool _isSaving = false;
//
//   // Cache decoded/compressed thumbnails so we don't re-decode base64
//   // on every rebuild while scrolling the search list.
//   final Map<String, Uint8List> _thumbCache = {};
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _refreshFamilyList());
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     _searchFocusNode.dispose();
//     _amountCtrl.dispose();
//     _noteCtrl.dispose();
//     super.dispose();
//   }
//
//   void _refreshFamilyList() {
//     final admissions = context.read<AdmissionProvider>().admissions;
//     _allFamilies = FeeCollectionProvider.buildFamilyList(admissions);
//     _applyFilter();
//   }
//
//   void _applyFilter() {
//     final q = _query.trim().toLowerCase();
//     setState(() {
//       _filtered = q.isEmpty
//           ? _allFamilies
//           : _allFamilies
//           .where((f) =>
//       f.familyName.toLowerCase().contains(q) ||
//           f.fatherName.toLowerCase().contains(q) ||
//           f.familyId.toLowerCase().contains(q) ||
//           f.fatherPhone.contains(q))
//           .toList();
//       _highlightedIndex = _filtered.isEmpty ? -1 : 0;
//     });
//   }
//
//   // ── Keyboard navigation ──
//   void _handleKey(KeyEvent event) {
//     if (event is! KeyDownEvent) return;
//     if (_filtered.isEmpty) return;
//
//     if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       setState(() {
//         _highlightedIndex =
//             (_highlightedIndex + 1).clamp(0, _filtered.length - 1);
//       });
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       setState(() {
//         _highlightedIndex =
//             (_highlightedIndex - 1).clamp(0, _filtered.length - 1);
//       });
//     } else if (event.logicalKey == LogicalKeyboardKey.enter) {
//       if (_highlightedIndex >= 0 && _highlightedIndex < _filtered.length) {
//         _selectFamily(_filtered[_highlightedIndex]);
//       }
//     }
//   }
//
//   Future<void> _selectFamily(FamilyForCollection family) async {
//     setState(() {
//       _selectedFamily = family;
//       _amountCtrl.clear();
//       _noteCtrl.clear();
//       _paymentDate = DateTime.now();
//       _paymentMethod = 'Cash';
//     });
//     await context.read<FeeCollectionProvider>().loadBalanceForFamily(family.familyDocId);
//   }
//
//   void _clearSelection() {
//     setState(() {
//       _selectedFamily = null;
//       _amountCtrl.clear();
//       _noteCtrl.clear();
//       _searchCtrl.clear();
//       _query = '';
//     });
//     context.read<FeeCollectionProvider>().clearSelection();
//     _applyFilter();
//     _searchFocusNode.requestFocus();
//   }
//
//   // ── Image compression for list thumbnails (cached) ──
//   Uint8List? _thumbnailFor(String? base64Str) {
//     if (base64Str == null || base64Str.isEmpty) return null;
//     final cached = _thumbCache[base64Str];
//     if (cached != null) return cached;
//     try {
//       final raw = base64Decode(base64Str);
//       final decoded = img.decodeImage(raw);
//       if (decoded == null) return null;
//       final resized = decoded.width >= decoded.height
//           ? img.copyResize(decoded, width: 60)
//           : img.copyResize(decoded, height: 60);
//       final bytes = Uint8List.fromList(img.encodeJpg(resized, quality: 60));
//       _thumbCache[base64Str] = bytes;
//       return bytes;
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _paymentDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2035),
//     );
//     if (picked != null) setState(() => _paymentDate = picked);
//   }
//
//   Future<void> _savePayment() async {
//     if (_selectedFamily == null) return;
//     final amount = double.tryParse(_amountCtrl.text.trim());
//     if (amount == null || amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Sahi amount likhein')),
//       );
//       return;
//     }
//
//     setState(() => _isSaving = true);
//     final provider = context.read<FeeCollectionProvider>();
//     final ok = await provider.collectFee(
//       family: _selectedFamily!,
//       amount: amount,
//       paymentDate: _paymentDate,
//       paymentMethod: _paymentMethod,
//       note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
//     );
//     if (!mounted) return;
//     setState(() => _isSaving = false);
//
//     if (ok) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Fee collect ho gayi!')),
//       );
//       _clearSelection();
//     } else if (provider.error != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   String _fmtMoney(double v) {
//     final neg = v < 0;
//     final abs = v.abs().toStringAsFixed(0);
//     return '${neg ? '-' : ''}Rs $abs';
//   }
//
//   String _fmtDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//   @override
//   Widget build(BuildContext context) {
//     // Keep the family list synced whenever AdmissionProvider updates.
//     context.watch<AdmissionProvider>();
//     if (_allFamilies.isEmpty && _filtered.isEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) => _refreshFamilyList());
//     }
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5FA),
//       appBar: AppBar(
//         title: const Text('Fee Collection'),
//         centerTitle: true,
//         backgroundColor: _purple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final isWide = constraints.maxWidth >= 900;
//           return isWide ? _buildWideLayout() : _buildNarrowLayout();
//         },
//       ),
//     );
//   }
//
//   // ── Desktop / wide layout: list left, form right ──
//   Widget _buildWideLayout() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 4,
//             child: _buildCard(child: _buildSearchAndList()),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             flex: 5,
//             child: _buildCard(
//               child: _selectedFamily == null
//                   ? _buildEmptyFormState()
//                   : _buildForm(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Mobile / narrow layout: single column, form after selection ──
//   Widget _buildNarrowLayout() {
//     if (_selectedFamily == null) {
//       return Padding(
//         padding: const EdgeInsets.all(12),
//         child: _buildCard(child: _buildSearchAndList()),
//       );
//     }
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               TextButton.icon(
//                 onPressed: _clearSelection,
//                 icon: const Icon(Icons.arrow_back, size: 18),
//                 label: const Text('Change Family'),
//                 style: TextButton.styleFrom(foregroundColor: _purple),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           _buildCard(child: _buildForm()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCard({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   // ── Search box + keyboard-navigable list ──
//   Widget _buildSearchAndList() {
//     return KeyboardListener(
//       focusNode: FocusNode(),
//       onKeyEvent: _handleKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Search Family',
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade700)),
//           const SizedBox(height: 8),
//           TextField(
//             controller: _searchCtrl,
//             focusNode: _searchFocusNode,
//             autofocus: true,
//             decoration: InputDecoration(
//               hintText: 'Family name, father, ID ya phone...',
//               hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
//               prefixIcon: const Icon(Icons.search, color: _purple, size: 20),
//               suffixIcon: _searchCtrl.text.isNotEmpty
//                   ? IconButton(
//                 icon: const Icon(Icons.clear, size: 18),
//                 onPressed: () {
//                   _searchCtrl.clear();
//                   _query = '';
//                   _applyFilter();
//                 },
//               )
//                   : null,
//               filled: true,
//               fillColor: Colors.grey.shade50,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               contentPadding:
//               const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             ),
//             onChanged: (v) {
//               _query = v;
//               _applyFilter();
//             },
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '↑ ↓ se select, Enter se confirm',
//             style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey.shade400,
//                 fontStyle: FontStyle.italic),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: _filtered.isEmpty
//                 ? Center(
//               child: Text(
//                 _query.isEmpty ? 'Koi family nahi mili' : 'No results',
//                 style: TextStyle(color: Colors.grey.shade400),
//               ),
//             )
//                 : ListView.builder(
//               itemCount: _filtered.length,
//               itemBuilder: (context, i) {
//                 final f = _filtered[i];
//                 final isHighlighted = i == _highlightedIndex;
//                 final isSelected =
//                     _selectedFamily?.familyDocId == f.familyDocId;
//                 return _FamilyTile(
//                   family: f,
//                   thumbnail: _thumbnailFor(f.firstStudentPicBase64),
//                   isHighlighted: isHighlighted,
//                   isSelected: isSelected,
//                   onTap: () => _selectFamily(f),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyFormState() {
//     return SizedBox(
//       height: 400,
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.payments_outlined, size: 56, color: Colors.grey.shade300),
//             const SizedBox(height: 12),
//             Text(
//               'Family select karein fee collect karne ke liye',
//               style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Payment Form ──
//   Widget _buildForm() {
//     final collProvider = context.watch<FeeCollectionProvider>();
//     final family = _selectedFamily!;
//     final balance = collProvider.currentBalance;
//     final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
//     final balanceAfter = balance - amount;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Family header
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 22,
//               backgroundColor: _lightPurple,
//               backgroundImage: _thumbnailFor(family.firstStudentPicBase64) != null
//                   ? MemoryImage(_thumbnailFor(family.firstStudentPicBase64)!)
//                   : null,
//               child: _thumbnailFor(family.firstStudentPicBase64) == null
//                   ? Text(
//                 family.familyName.isNotEmpty
//                     ? family.familyName[0].toUpperCase()
//                     : 'F',
//                 style: const TextStyle(
//                     color: _purple, fontWeight: FontWeight.bold),
//               )
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(family.familyName,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 16)),
//                   Text(
//                     '${family.fatherName} • ${family.familyId} • ${family.studentCount} student(s)',
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//
//         // Current balance
//         collProvider.isLoadingBalance
//             ? const Padding(
//           padding: EdgeInsets.symmetric(vertical: 20),
//           child: Center(
//               child: SizedBox(
//                   width: 22,
//                   height: 22,
//                   child: CircularProgressIndicator(strokeWidth: 2))),
//         )
//             : Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: balance > 0
//                 ? Colors.orange.shade50
//                 : (balance < 0 ? Colors.green.shade50 : Colors.grey.shade50),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: balance > 0
//                   ? Colors.orange.shade200
//                   : (balance < 0 ? Colors.green.shade200 : Colors.grey.shade200),
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 balance > 0
//                     ? Icons.account_balance_wallet_outlined
//                     : Icons.check_circle_outline,
//                 size: 20,
//                 color: balance > 0 ? Colors.orange.shade700 : Colors.green.shade700,
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       balance > 0
//                           ? 'Current Balance (Pending)'
//                           : (balance < 0 ? 'Advance Balance' : 'No Balance Due'),
//                       style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//                     ),
//                     Text(
//                       _fmtMoney(balance),
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: balance > 0
//                               ? Colors.orange.shade800
//                               : (balance < 0 ? Colors.green.shade800 : Colors.black87)),
//                     ),
//                   ],
//                 ),
//               ),
//               if (collProvider.latestChallan != null)
//                 Text(
//                   collProvider.latestChallan!.challanNumber,
//                   style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//
//         // Amount field
//         TextField(
//           controller: _amountCtrl,
//           keyboardType: const TextInputType.numberWithOptions(decimal: false),
//           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           onChanged: (_) => setState(() {}),
//           style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           decoration: InputDecoration(
//             labelText: 'Collect Amount',
//             prefixText: 'Rs ',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           ),
//         ),
//         const SizedBox(height: 10),
//
//         // Balance-after preview
//         if (amount > 0)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: _lightPurple,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Row(
//               children: [
//                 Text(_fmtMoney(balance),
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
//                 const SizedBox(width: 8),
//                 const Icon(Icons.arrow_forward, size: 14, color: _purple),
//                 const SizedBox(width: 8),
//                 Text(
//                   _fmtMoney(balanceAfter),
//                   style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: balanceAfter > 0
//                           ? Colors.orange.shade800
//                           : (balanceAfter < 0 ? Colors.green.shade800 : Colors.black87)),
//                 ),
//                 const Spacer(),
//                 Text('after collection',
//                     style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//               ],
//             ),
//           ),
//         const SizedBox(height: 16),
//
//         // Date + Method
//         Row(
//           children: [
//             Expanded(
//               child: InkWell(
//                 onTap: _pickDate,
//                 borderRadius: BorderRadius.circular(10),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade400),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.calendar_today_outlined, size: 16),
//                       const SizedBox(width: 8),
//                       Text(_fmtDate(_paymentDate), style: const TextStyle(fontSize: 13)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: DropdownButtonFormField<String>(
//                 value: _paymentMethod,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 ),
//                 items: ['Cash', 'Bank', 'Online']
//                     .map((m) => DropdownMenuItem(value: m, child: Text(m)))
//                     .toList(),
//                 onChanged: (v) => setState(() => _paymentMethod = v ?? 'Cash'),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//
//         TextField(
//           controller: _noteCtrl,
//           decoration: InputDecoration(
//             labelText: 'Note (Optional)',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//           maxLines: 2,
//         ),
//         const SizedBox(height: 20),
//
//         ElevatedButton(
//           onPressed: _isSaving ? null : _savePayment,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _purple,
//             foregroundColor: Colors.white,
//             minimumSize: const Size(double.infinity, 50),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           child: _isSaving
//               ? const SizedBox(
//               width: 22,
//               height: 22,
//               child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//               : const Text('Collect & Save',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Family search-result tile
// // ─────────────────────────────────────────────
// class _FamilyTile extends StatelessWidget {
//   final FamilyForCollection family;
//   final Uint8List? thumbnail;
//   final bool isHighlighted;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _FamilyTile({
//     required this.family,
//     required this.thumbnail,
//     required this.isHighlighted,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   static const _purple = Color(0xFF534AB7);
//   static const _lightPurple = Color(0xFFEEECFA);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 6),
//       decoration: BoxDecoration(
//         color: isSelected
//             ? _lightPurple
//             : (isHighlighted ? Colors.grey.shade100 : Colors.transparent),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: isSelected
//               ? _purple
//               : (isHighlighted ? Colors.grey.shade300 : Colors.transparent),
//         ),
//       ),
//       child: ListTile(
//         dense: true,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         leading: CircleAvatar(
//           radius: 18,
//           backgroundColor: _lightPurple,
//           backgroundImage: thumbnail != null ? MemoryImage(thumbnail!) : null,
//           child: thumbnail == null
//               ? Text(
//             family.familyName.isNotEmpty
//                 ? family.familyName[0].toUpperCase()
//                 : 'F',
//             style: const TextStyle(
//                 color: _purple, fontWeight: FontWeight.bold, fontSize: 13),
//           )
//               : null,
//         ),
//         title: Text(family.familyName,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//         subtitle: Text(
//           '${family.fatherName} • ${family.familyId}',
//           style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//           overflow: TextOverflow.ellipsis,
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../../providers/admission_provider.dart';
import '../../providers/fee_collection_provider.dart';

// ─────────────────────────────────────────────
//  Fee Collection Screen
//  Family-wise payment collection against the family's
//  latest challan (or standalone if none exists yet).
//
//  - Search box + keyboard (Up/Down/Enter) + mouse click,
//    both work identically.
//  - First regular-admission student's pic shown (compressed).
//  - Selecting a family loads its current balance instantly.
//  - Amount entry shows a live "balance after" preview.
//  - Desktop: two-column layout (list left, form right).
//  - Mobile: single column, form appears after selection.
// ─────────────────────────────────────────────
class FeeCollectionScreen extends StatefulWidget {
  const FeeCollectionScreen({super.key});

  @override
  State<FeeCollectionScreen> createState() => _FeeCollectionScreenState();
}

class _FeeCollectionScreenState extends State<FeeCollectionScreen> {
  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  final _searchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _query = '';
  List<FamilyForCollection> _allFamilies = [];
  List<FamilyForCollection> _filtered = [];
  int _highlightedIndex = -1;

  FamilyForCollection? _selectedFamily;
  DateTime _paymentDate = DateTime.now();
  String _paymentMethod = 'Cash';
  bool _isSaving = false;

  // Cache decoded/compressed thumbnails so we don't re-decode base64
  // on every rebuild while scrolling the search list.
  final Map<String, Uint8List> _thumbCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshFamilyList());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _refreshFamilyList() {
    final admissions = context.read<AdmissionProvider>().admissions;
    _allFamilies = FeeCollectionProvider.buildFamilyList(admissions);
    _applyFilter();
  }

  void _applyFilter() {
    final q = _query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allFamilies
          : _allFamilies
          .where((f) =>
      f.familyName.toLowerCase().contains(q) ||
          f.fatherName.toLowerCase().contains(q) ||
          f.familyId.toLowerCase().contains(q) ||
          f.fatherPhone.contains(q))
          .toList();
      _highlightedIndex = _filtered.isEmpty ? -1 : 0;
    });
  }

  // ── Keyboard navigation ──
  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_filtered.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _highlightedIndex =
            (_highlightedIndex + 1).clamp(0, _filtered.length - 1);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex =
            (_highlightedIndex - 1).clamp(0, _filtered.length - 1);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < _filtered.length) {
        _selectFamily(_filtered[_highlightedIndex]);
      }
    }
  }

  Future<void> _selectFamily(FamilyForCollection family) async {
    setState(() {
      _selectedFamily = family;
      _amountCtrl.clear();
      _noteCtrl.clear();
      _paymentDate = DateTime.now();
      _paymentMethod = 'Cash';
    });
    await context.read<FeeCollectionProvider>().loadBalanceForFamily(family.familyDocId);
  }

  void _clearSelection() {
    setState(() {
      _selectedFamily = null;
      _amountCtrl.clear();
      _noteCtrl.clear();
      _searchCtrl.clear();
      _query = '';
    });
    context.read<FeeCollectionProvider>().clearSelection();
    _applyFilter();
    _searchFocusNode.requestFocus();
  }

  // ── Image compression for list thumbnails (cached) ──
  Uint8List? _thumbnailFor(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    final cached = _thumbCache[base64Str];
    if (cached != null) return cached;
    try {
      final raw = base64Decode(base64Str);
      final decoded = img.decodeImage(raw);
      if (decoded == null) return null;
      final resized = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: 60)
          : img.copyResize(decoded, height: 60);
      final bytes = Uint8List.fromList(img.encodeJpg(resized, quality: 60));
      _thumbCache[base64Str] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _savePayment() async {
    if (_selectedFamily == null) return;
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sahi amount likhein')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<FeeCollectionProvider>();
    final ok = await provider.collectFee(
      family: _selectedFamily!,
      amount: amount,
      paymentDate: _paymentDate,
      paymentMethod: _paymentMethod,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fee collect ho gayi!')),
      );
      _clearSelection();
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
      );
    }
  }

  String _fmtMoney(double v) {
    final neg = v < 0;
    final abs = v.abs().toStringAsFixed(0);
    return '${neg ? '-' : ''}Rs $abs';
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    // Keep the family list synced whenever AdmissionProvider updates.
    context.watch<AdmissionProvider>();
    if (_allFamilies.isEmpty && _filtered.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshFamilyList());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text('Fee Collection'),
        centerTitle: true,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return isWide ? _buildWideLayout() : _buildNarrowLayout();
        },
      ),
    );
  }

  // ── Desktop / wide layout: list left, form right ──
  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _buildCard(child: _buildSearchAndList()),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: _buildCard(
              child: _selectedFamily == null
                  ? _buildEmptyFormState()
                  : _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile / narrow layout: single column, form after selection ──
  Widget _buildNarrowLayout() {
    if (_selectedFamily == null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: _buildCard(child: _buildSearchAndList()),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: _clearSelection,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Change Family'),
                style: TextButton.styleFrom(foregroundColor: _purple),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildCard(child: _buildForm()),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Search box + keyboard-navigable list ──
  Widget _buildSearchAndList() {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Family',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Family name, father, ID ya phone...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: _purple, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  _query = '';
                  _applyFilter();
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (v) {
              _query = v;
              _applyFilter();
            },
          ),
          const SizedBox(height: 4),
          Text(
            '↑ ↓ se select, Enter se confirm',
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Text(
                _query.isEmpty ? 'Koi family nahi mili' : 'No results',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            )
                : ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final f = _filtered[i];
                final isHighlighted = i == _highlightedIndex;
                final isSelected =
                    _selectedFamily?.familyDocId == f.familyDocId;
                return _FamilyTile(
                  family: f,
                  thumbnail: _thumbnailFor(f.firstStudentPicBase64),
                  isHighlighted: isHighlighted,
                  isSelected: isSelected,
                  onTap: () => _selectFamily(f),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFormState() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payments_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Family select karein fee collect karne ke liye',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Payment Form ──
  Widget _buildForm() {
    final collProvider = context.watch<FeeCollectionProvider>();
    final family = _selectedFamily!;
    final balance = collProvider.currentBalance;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final balanceAfter = balance - amount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Family header
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _lightPurple,
              backgroundImage: _thumbnailFor(family.firstStudentPicBase64) != null
                  ? MemoryImage(_thumbnailFor(family.firstStudentPicBase64)!)
                  : null,
              child: _thumbnailFor(family.firstStudentPicBase64) == null
                  ? Text(
                family.familyName.isNotEmpty
                    ? family.familyName[0].toUpperCase()
                    : 'F',
                style: const TextStyle(
                    color: _purple, fontWeight: FontWeight.bold),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(family.familyName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    '${family.fatherName} • ${family.familyId} • ${family.studentCount} student(s)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current balance
        collProvider.isLoadingBalance
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
              child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2))),
        )
            : Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: balance > 0
                ? Colors.orange.shade50
                : (balance < 0 ? Colors.green.shade50 : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: balance > 0
                  ? Colors.orange.shade200
                  : (balance < 0 ? Colors.green.shade200 : Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Icon(
                balance > 0
                    ? Icons.account_balance_wallet_outlined
                    : Icons.check_circle_outline,
                size: 20,
                color: balance > 0 ? Colors.orange.shade700 : Colors.green.shade700,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance > 0
                          ? 'Current Balance (Pending)'
                          : (balance < 0 ? 'Advance Balance' : 'No Balance Due'),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    Text(
                      _fmtMoney(balance),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: balance > 0
                              ? Colors.orange.shade800
                              : (balance < 0 ? Colors.green.shade800 : Colors.black87)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Amount field
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: 'Collect Amount',
            prefixText: 'Rs ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 10),

        // Balance-after preview
        if (amount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _lightPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(_fmtMoney(balance),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 14, color: _purple),
                const SizedBox(width: 8),
                Text(
                  _fmtMoney(balanceAfter),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: balanceAfter > 0
                          ? Colors.orange.shade800
                          : (balanceAfter < 0 ? Colors.green.shade800 : Colors.black87)),
                ),
                const Spacer(),
                Text('after collection',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Date + Method
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16),
                      const SizedBox(width: 8),
                      Text(_fmtDate(_paymentDate), style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                items: ['Cash', 'Bank', 'Online']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMethod = v ?? 'Cash'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(
            labelText: 'Note (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _isSaving ? null : _savePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSaving
              ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Collect & Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Family search-result tile
// ─────────────────────────────────────────────
class _FamilyTile extends StatelessWidget {
  final FamilyForCollection family;
  final Uint8List? thumbnail;
  final bool isHighlighted;
  final bool isSelected;
  final VoidCallback onTap;

  const _FamilyTile({
    required this.family,
    required this.thumbnail,
    required this.isHighlighted,
    required this.isSelected,
    required this.onTap,
  });

  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? _lightPurple
            : (isHighlighted ? Colors.grey.shade100 : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? _purple
              : (isHighlighted ? Colors.grey.shade300 : Colors.transparent),
        ),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: _lightPurple,
          backgroundImage: thumbnail != null ? MemoryImage(thumbnail!) : null,
          child: thumbnail == null
              ? Text(
            family.familyName.isNotEmpty
                ? family.familyName[0].toUpperCase()
                : 'F',
            style: const TextStyle(
                color: _purple, fontWeight: FontWeight.bold, fontSize: 13),
          )
              : null,
        ),
        title: Text(family.familyName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(
          '${family.fatherName} • ${family.familyId}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}