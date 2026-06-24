import 'package:flutter/foundation.dart';

import '../models/teacher.dart';
import '../services/firestore_service.dart';


class StaffProvider extends ChangeNotifier {
  final StaffFirestoreService _service = StaffFirestoreService();
  List<StaffMember> _allStaff = [];
  List<StaffMember> _teachers = [];
  List<StaffMember> _staffOnly = [];
  bool _loading = false;

  List<StaffMember> get allStaff => _allStaff;
  List<StaffMember> get teachers => _teachers;
  List<StaffMember> get staffOnly => _staffOnly;
  bool get loading => _loading;

  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();
    _allStaff = await _service.getAllStaff();
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchTeachers() async {
    _loading = true;
    notifyListeners();
    _teachers = await _service.getTeachers();
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchStaffOnly() async {
    _loading = true;
    notifyListeners();
    _staffOnly = await _service.getStaffOnly();
    _loading = false;
    notifyListeners();
  }

  Future<void> addStaff(StaffMember staff) async {
    await _service.addStaff(staff);
    await fetchAll(); // refresh main list
  }

  Future<void> updateStaff(String id, StaffMember staff) async {
    await _service.updateStaff(id, staff);
    await fetchAll();
  }

  Future<void> deleteStaff(String id) async {
    await _service.deleteStaff(id);
    await fetchAll();
  }

  // Optionally, clear and reload specific lists
  void clear() {
    _allStaff = [];
    _teachers = [];
    _staffOnly = [];
    notifyListeners();
  }
}