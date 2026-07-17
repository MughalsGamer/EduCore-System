import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/salary_model.dart';

class SalaryFirestoreService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('salaries');

  /// One salary record per (employeeId + year + month).
  /// Returns the existing record if one is already generated, else null.
  Future<SalaryRecord?> checkAlreadyGenerated(
      String employeeId, int year, int month) async {
    final snap = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return SalaryRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> saveSalary(SalaryRecord record) async {
    final data = record.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _collection.add(data);
  }
}
