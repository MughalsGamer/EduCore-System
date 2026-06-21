import 'package:flutter/material.dart';
import '../models/fee_structure.dart';
import '../models/fee_receipt.dart';
import '../services/firestore_service.dart';

class FeeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<FeeStructure> _structures = [];
  List<FeeReceipt> _receipts = [];
  bool _loading = false;

  List<FeeStructure> get structures => _structures;
  List<FeeReceipt> get receipts => _receipts;
  bool get loading => _loading;

  Future<void> fetchStructures() async {
    _structures = await _firestoreService.getFeeStructures();
    notifyListeners();
  }

  Future<void> addStructure(FeeStructure fs) async {
    await _firestoreService.addFeeStructure(fs);
    await fetchStructures();
  }

  Future<void> addReceipt(FeeReceipt receipt) async {
    await _firestoreService.addFeeReceipt(receipt);
    notifyListeners();
  }

  Future<void> fetchAllReceipts() async {
    _loading = true;
    notifyListeners();
    _receipts = await _firestoreService.getAllReceipts();
    _loading = false;
    notifyListeners();
  }

  Future<List<FeeReceipt>> fetchReceiptsByStudent(String studentId) async {
    return await _firestoreService.getReceiptsByStudent(studentId);
  }
}