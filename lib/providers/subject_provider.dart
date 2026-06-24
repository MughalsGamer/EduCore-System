// ─────────────────────────────────────────────────────────────
//  providers/subject_provider.dart
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class MuddulProvider extends ChangeNotifier {
  final CollectionReference _col =
  FirebaseFirestore.instance.collection('subjects');

  List<Muddul> _mudduls = [];
  bool _loading = false;
  String? _error;

  List<Muddul> get mudduls => List.unmodifiable(_mudduls);
  bool get loading => _loading;
  String? get error => _error;

  void startListening() {
    _loading = true;
    notifyListeners();

    _col.orderBy('createdAt', descending: false).snapshots().listen(
          (snapshot) {
        _mudduls = snapshot.docs
            .map((doc) =>
            Muddul.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  // ── Code generator: first 4 letters of subjectName + serial ──
  Future<String> generateCode(String subjectName) async {
    final letters = subjectName.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    final prefix = (letters.length >= 4
        ? letters.substring(0, 4)
        : letters.padRight(4, 'x'))
        .toLowerCase();

    final snapshot = await _col
        .where('code', isGreaterThanOrEqualTo: prefix)
        .where('code', isLessThan: '${prefix}z')
        .get();

    int maxSerial = 0;
    for (final doc in snapshot.docs) {
      final code =
          (doc.data() as Map<String, dynamic>)['code'] as String? ?? '';
      if (code.startsWith(prefix)) {
        final n = int.tryParse(code.substring(prefix.length)) ?? 0;
        if (n > maxSerial) maxSerial = n;
      }
    }

    return '$prefix${(maxSerial + 1).toString().padLeft(4, '0')}';
  }

  Future<void> addMuddul(Muddul muddul) async {
    final data = muddul.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col.add(data);
  }

  Future<void> updateMuddul(Muddul muddul) async {
    if (muddul.id == null) throw Exception('ID required');
    final data = muddul.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(muddul.id).update(data);
  }

  Future<void> deleteMuddul(String id) async {
    await _col.doc(id).delete();
  }

  bool isDuplicateName(String subjectName, {String? excludeId}) {
    final normalized =
    subjectName.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    for (final m in _mudduls) {
      if (excludeId != null && m.id == excludeId) continue;
      if (m.subjectName.replaceAll(RegExp(r'\s+'), '').toLowerCase() ==
          normalized) return true;
    }
    return false;
  }
}