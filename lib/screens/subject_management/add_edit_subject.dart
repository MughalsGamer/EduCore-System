  // // ─────────────────────────────────────────────────────────────
  // //  screens/muddul_management/add_edit_subject.dart
  // // ─────────────────────────────────────────────────────────────
  //
  // import 'package:flutter/material.dart';
  // import 'package:provider/provider.dart';
  // import '../../models/subject_model.dart';
  // import '../../providers/subject_provider.dart';
  //
  // class AddEditMuddulScreen extends StatefulWidget {
  //   final Muddul? existingMuddul;
  //
  //   const AddEditMuddulScreen({super.key, this.existingMuddul});
  //
  //   @override
  //   State<AddEditMuddulScreen> createState() => _AddEditMuddulScreenState();
  // }
  //
  // class _AddEditMuddulScreenState extends State<AddEditMuddulScreen> {
  //   final _formKey = GlobalKey<FormState>();
  //
  //   late TextEditingController _subjectNameController;
  //   late TextEditingController _descController;
  //   late TextEditingController _codeController;
  //
  //   bool _isSaving = false;
  //   bool _isGeneratingCode = false;
  //
  //   static const _purple = Color(0xFF534AB7);
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     final e = widget.existingMuddul;
  //     _subjectNameController = TextEditingController(text: e?.subjectName ?? '');
  //     _descController = TextEditingController(text: e?.description ?? '');
  //     _codeController = TextEditingController(text: e?.code ?? '');
  //
  //     // Auto-generate code only when adding new
  //     if (e == null) {
  //       _subjectNameController.addListener(_onNameChanged);
  //     }
  //   }
  //
  //   @override
  //   void dispose() {
  //     _subjectNameController.removeListener(_onNameChanged);
  //     _subjectNameController.dispose();
  //     _descController.dispose();
  //     _codeController.dispose();
  //     super.dispose();
  //   }
  //
  //   void _onNameChanged() async {
  //     final name = _subjectNameController.text.trim();
  //     if (name.isEmpty) {
  //       setState(() => _codeController.text = '');
  //       return;
  //     }
  //     setState(() => _isGeneratingCode = true);
  //     try {
  //       final code =
  //       await context.read<MuddulProvider>().generateCode(name);
  //       if (mounted) setState(() => _codeController.text = code);
  //     } finally {
  //       if (mounted) setState(() => _isGeneratingCode = false);
  //     }
  //   }
  //
  //   bool _isDuplicate(String name) => context
  //       .read<MuddulProvider>()
  //       .isDuplicateName(name, excludeId: widget.existingMuddul?.id);
  //
  //   Future<void> _save() async {
  //     if (!_formKey.currentState!.validate()) return;
  //     setState(() => _isSaving = true);
  //
  //     try {
  //       final provider = context.read<MuddulProvider>();
  //       final subject = Muddul(
  //         id: widget.existingMuddul?.id,
  //         subjectName: _subjectNameController.text.trim(),
  //         code: _codeController.text.trim(),
  //         description: _descController.text.trim(),
  //         createdAt: widget.existingMuddul?.createdAt ?? DateTime.now(),
  //       );
  //
  //       if (widget.existingMuddul == null) {
  //         await provider.addMuddul(subject);
  //       } else {
  //         await provider.updateMuddul(subject);
  //       }
  //
  //       if (mounted) Navigator.pop(context, true);
  //     } catch (e) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text('Error: $e'),
  //           backgroundColor: Colors.red,
  //         ));
  //       }
  //     } finally {
  //       if (mounted) setState(() => _isSaving = false);
  //     }
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     final isEditing = widget.existingMuddul != null;
  //
  //     return Scaffold(
  //       backgroundColor: Colors.grey.shade50,
  //       appBar: AppBar(
  //         title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
  //         centerTitle: true,
  //         elevation: 0,
  //         backgroundColor: Colors.white,
  //         foregroundColor: Colors.black87,
  //       ),
  //       body: Form(
  //         key: _formKey,
  //         child: SingleChildScrollView(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // ── Header banner ──
  //               Container(
  //                 width: double.infinity,
  //                 padding: const EdgeInsets.all(18),
  //                 decoration: BoxDecoration(
  //                   color: _purple,
  //                   borderRadius: BorderRadius.circular(14),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(10),
  //                       decoration: BoxDecoration(
  //                         color: Colors.white.withOpacity(0.15),
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: const Icon(Icons.book_outlined,
  //                           color: Colors.white, size: 26),
  //                     ),
  //                     const SizedBox(width: 14),
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           isEditing ? 'Update Subject' : 'New Subject',
  //                           style: const TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 17,
  //                               fontWeight: FontWeight.w600),
  //                         ),
  //                         const SizedBox(height: 2),
  //                         Text(
  //                           isEditing
  //                               ? 'Edit subject details below'
  //                               : 'Fill in the details below',
  //                           style: TextStyle(
  //                               color: Colors.white.withOpacity(0.75),
  //                               fontSize: 12),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: 24),
  //
  //               // ── Subject Name ──
  //               _fieldLabel('Subject Name'),
  //               const SizedBox(height: 6),
  //               TextFormField(
  //                 controller: _subjectNameController,
  //                 decoration: InputDecoration(
  //                   hintText: 'e.g. History, Mathematics…',
  //                   prefixIcon:
  //                   const Icon(Icons.book_outlined, color: _purple),
  //                   filled: true,
  //                   fillColor: Colors.white,
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide:
  //                     BorderSide(color: Colors.grey.shade200),
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide:
  //                     BorderSide(color: Colors.grey.shade200),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide:
  //                     const BorderSide(color: _purple, width: 1.5),
  //                   ),
  //                 ),
  //                 validator: (v) {
  //                   if (v == null || v.trim().isEmpty) {
  //                     return 'Subject name is required';
  //                   }
  //                   if (_isDuplicate(v.trim())) {
  //                     return 'This subject already exists';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 16),
  //
  //               // ── Auto Code ──
  //               _fieldLabel('Subject Code'),
  //               const SizedBox(height: 6),
  //               TextFormField(
  //                 controller: _codeController,
  //                 readOnly: true,
  //                 decoration: InputDecoration(
  //                   hintText: 'Auto-generated from name',
  //                   prefixIcon:
  //                   const Icon(Icons.tag, color: _purple),
  //                   filled: true,
  //                   fillColor: const Color(0xFFEEEDFE),
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide: BorderSide.none,
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide: BorderSide.none,
  //                   ),
  //                   suffixIcon: _isGeneratingCode
  //                       ? const Padding(
  //                     padding: EdgeInsets.all(12),
  //                     child: SizedBox(
  //                       width: 16,
  //                       height: 16,
  //                       child:
  //                       CircularProgressIndicator(strokeWidth: 2),
  //                     ),
  //                   )
  //                       : _codeController.text.isNotEmpty
  //                       ? const Icon(Icons.check_circle,
  //                       color: Colors.green, size: 20)
  //                       : null,
  //                 ),
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.w700,
  //                   color: Color(0xFF3C3489),
  //                   fontSize: 15,
  //                   letterSpacing: 1.5,
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 5, left: 4),
  //                 child: Text(
  //                   'First 4 letters + serial  •  e.g. hist0001, math0002',
  //                   style: TextStyle(
  //                       fontSize: 11, color: Colors.grey.shade400),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //
  //               // ── Description ──
  //               _fieldLabel('Description (Optional)'),
  //               const SizedBox(height: 6),
  //               TextFormField(
  //                 controller: _descController,
  //                 maxLines: 3,
  //                 decoration: InputDecoration(
  //                   hintText: 'Brief description of this subject…',
  //                   alignLabelWithHint: true,
  //                   filled: true,
  //                   fillColor: Colors.white,
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide:
  //                     BorderSide(color: Colors.grey.shade200),
  //                   ),
  //                   enabledBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide:
  //                     BorderSide(color: Colors.grey.shade200),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide:
  //                     const BorderSide(color: _purple, width: 1.5),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 32),
  //
  //               // ── Save Button ──
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 50,
  //                 child: ElevatedButton(
  //                   onPressed: _isSaving ? null : _save,
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: _purple,
  //                     foregroundColor: Colors.white,
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12)),
  //                     elevation: 0,
  //                   ),
  //                   child: _isSaving
  //                       ? const SizedBox(
  //                     width: 20,
  //                     height: 20,
  //                     child: CircularProgressIndicator(
  //                         strokeWidth: 2, color: Colors.white),
  //                   )
  //                       : Text(
  //                     isEditing ? 'Update Subject' : 'Save Subject',
  //                     style: const TextStyle(
  //                         fontSize: 15, fontWeight: FontWeight.w600),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //
  //   Widget _fieldLabel(String label) => Text(
  //     label,
  //     style: const TextStyle(
  //         fontSize: 13,
  //         fontWeight: FontWeight.w600,
  //         color: Colors.black87),
  //   );
  // }

  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../models/subject_model.dart';
  import '../../providers/subject_provider.dart';

  class AddEditMuddulScreen extends StatefulWidget {
    final Muddul? existingMuddul;
    final bool showAppBar;
    final VoidCallback? onSaved;

    const AddEditMuddulScreen({
      super.key,
      this.existingMuddul,
      this.showAppBar = true,
      this.onSaved,
    });

    @override
    State<AddEditMuddulScreen> createState() => _AddEditMuddulScreenState();
  }

  class _AddEditMuddulScreenState extends State<AddEditMuddulScreen> {
    final _formKey = GlobalKey<FormState>();

    late TextEditingController _subjectNameController;
    late TextEditingController _descController;
    late TextEditingController _codeController;

    bool _isSaving = false;
    bool _isGeneratingCode = false;

    static const _purple = Color(0xFF534AB7);

    @override
    void initState() {
      super.initState();
      final e = widget.existingMuddul;
      _subjectNameController = TextEditingController(text: e?.subjectName ?? '');
      _descController = TextEditingController(text: e?.description ?? '');
      _codeController = TextEditingController(text: e?.code ?? '');

      if (e == null) {
        _subjectNameController.addListener(_onNameChanged);
      }
    }

    @override
    void dispose() {
      _subjectNameController.removeListener(_onNameChanged);
      _subjectNameController.dispose();
      _descController.dispose();
      _codeController.dispose();
      super.dispose();
    }

    void _onNameChanged() async {
      final name = _subjectNameController.text.trim();
      if (name.isEmpty) {
        setState(() => _codeController.text = '');
        return;
      }
      setState(() => _isGeneratingCode = true);
      try {
        final code = await context.read<MuddulProvider>().generateCode(name);
        if (mounted) setState(() => _codeController.text = code);
      } finally {
        if (mounted) setState(() => _isGeneratingCode = false);
      }
    }

    bool _isDuplicate(String name) => context
        .read<MuddulProvider>()
        .isDuplicateName(name, excludeId: widget.existingMuddul?.id);

    Future<void> _save() async {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _isSaving = true);

      try {
        final provider = context.read<MuddulProvider>();
        final subject = Muddul(
          id: widget.existingMuddul?.id,
          subjectName: _subjectNameController.text.trim(),
          code: _codeController.text.trim(),
          description: _descController.text.trim(),
          createdAt: widget.existingMuddul?.createdAt ?? DateTime.now(),
        );

        if (widget.existingMuddul == null) {
          await provider.addMuddul(subject);
        } else {
          await provider.updateMuddul(subject);
        }

        widget.onSaved?.call();
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      final isEditing = widget.existingMuddul != null;

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: widget.showAppBar
            ? AppBar(
          title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        )
            : null,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header banner ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.book_outlined,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Update Subject' : 'New Subject',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEditing
                                ? 'Edit subject details below'
                                : 'Fill in the details below',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Subject Name ──
                _fieldLabel('Subject Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _subjectNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. History, Mathematics…',
                    prefixIcon: const Icon(Icons.book_outlined, color: _purple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _purple, width: 1.5),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Subject name is required';
                    }
                    if (_isDuplicate(v.trim())) {
                      return 'This subject already exists';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Auto Code ──
                _fieldLabel('Subject Code'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _codeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Auto-generated from name',
                    prefixIcon: const Icon(Icons.tag, color: _purple),
                    filled: true,
                    fillColor: const Color(0xFFEEEDFE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _isGeneratingCode
                        ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : _codeController.text.isNotEmpty
                        ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 20)
                        : null,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3C3489),
                    fontSize: 15,
                    letterSpacing: 1.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 4),
                  child: Text(
                    'First 4 letters + serial  •  e.g. hist0001, math0002',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Description ──
                _fieldLabel('Description (Optional)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Brief description of this subject…',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _purple, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Save Button ──
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : Text(
                      isEditing ? 'Update Subject' : 'Save Subject',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }

    Widget _fieldLabel(String label) => Text(
      label,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }