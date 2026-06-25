import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';   // if not already present, add it

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educoresystem/models/admission_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/class_model.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/fee_structure.dart';
import '../models/fee_receipt.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- Students ----------
  CollectionReference get studentsCollection =>
      _db.collection('schools').doc('school1').collection('students');

  Future<List<Student>> getStudents() async {
    final snapshot = await studentsCollection.get();
    return snapshot.docs
        .map((doc) =>
        Student.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addStudent(Student student) =>
      studentsCollection.add(student.toMap());

  Future<void> updateStudent(String id, Student student) =>
      studentsCollection.doc(id).update(student.toMap());

  Future<void> deleteStudent(String id) =>
      studentsCollection.doc(id).delete();

  // ---------- Teachers ----------
  CollectionReference get teachersCollection =>
      _db.collection('schools').doc('school1').collection('teachers');

  // Future<List<Teacher>> getTeachers() async {
  //   final snapshot = await teachersCollection.get();
  //   return snapshot.docs
  //       .map((doc) =>
  //       Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
  //       .toList();
  // }
  //
  // Future<void> addTeacher(Teacher teacher) =>
  //     teachersCollection.add(teacher.toMap());
  //
  // Future<void> updateTeacher(String id, Teacher teacher) =>
  //     teachersCollection.doc(id).update(teacher.toMap());
  //
  // Future<void> deleteTeacher(String id) =>
  //     teachersCollection.doc(id).delete();

  // ---------- Classes (SchoolClass) ----------
  CollectionReference get classesCollection =>
      _db.collection('schools').doc('school1').collection('classes');

  // Method returning Stream for real-time updates
  Stream<List<SchoolClass>> getClassesStream() {
    return classesCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => SchoolClass.fromFirestore(doc))
        .toList());
  }

  // Future-based fetch (ek baar ke liye)
  Future<List<SchoolClass>> getClassesOnce() async {
    final snapshot = await classesCollection.get();
    return snapshot.docs
        .map((doc) => SchoolClass.fromFirestore(doc))
        .toList();
  }

  Future<void> addClass(SchoolClass schoolClass) =>
      classesCollection.add(schoolClass.toMap());

  Future<void> updateClass(String id, SchoolClass schoolClass) =>
      classesCollection.doc(id).update(schoolClass.toMap());

  Future<bool> deleteClassSafe(String classDocId, String className) async {
    final studentsSnap = await studentsCollection
        .where('className', isEqualTo: className)
        .limit(1)
        .get();
    if (studentsSnap.docs.isNotEmpty) return false;

    final teachersSnap = await teachersCollection
        .where('assignedClass', isEqualTo: className)
        .limit(1)
        .get();
    if (teachersSnap.docs.isNotEmpty) return false;

    await classesCollection.doc(classDocId).delete();
    return true;
  }

  // ---------- Fee Structure ----------
  CollectionReference get feeStructureCollection =>
      _db.collection('schools').doc('school1').collection('feeStructures');

  Future<List<FeeStructure>> getFeeStructures() async {
    final snapshot = await feeStructureCollection.get();
    return snapshot.docs
        .map((doc) => FeeStructure.fromMap(
        doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addFeeStructure(FeeStructure fs) =>
      feeStructureCollection.add(fs.toMap());

  // ---------- Fee Receipts ----------
  CollectionReference get feeReceiptsCollection =>
      _db.collection('schools').doc('school1').collection('feeReceipts');

  Future<void> addFeeReceipt(FeeReceipt receipt) =>
      feeReceiptsCollection.add(receipt.toMap());

  Future<List<FeeReceipt>> getReceiptsByStudent(String studentId) async {
    final snapshot = await feeReceiptsCollection
        .where('studentId', isEqualTo: studentId)
        .get();
    return snapshot.docs
        .map((doc) =>
        FeeReceipt.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<FeeReceipt>> getAllReceipts() async {
    final snapshot = await feeReceiptsCollection.get();
    return snapshot.docs
        .map((doc) =>
        FeeReceipt.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // ---------- Expenses ----------
  CollectionReference get expensesCollection =>
      _db.collection('schools').doc('school1').collection('expenses');

  Future<void> addExpense(Expense expense) =>
      expensesCollection.add(expense.toMap());

  Future<List<Expense>> getExpenses() async {
    final snapshot = await expensesCollection.get();
    return snapshot.docs
        .map((doc) =>
        Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }


}





class StaffFirestoreService {
  // 🔽 Add this line
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _teacherCollection() =>
      _firestore.collection('teachers');

  CollectionReference<Map<String, dynamic>> _staffCollection() =>
      _firestore.collection('staff');



  // ── NEW: Compress Uint8List and return base64 ──
  // ── Compress Uint8List and return base64 (web-safe) ──
  Future<String> compressAndEncodeBytes(Uint8List bytes) async {
    if (kIsWeb) {
      // flutter_image_compress does NOT support web (Pica.js fails)
      // Just encode raw bytes directly — no compression on web
      return base64Encode(bytes);
    }

    // Mobile/desktop: compress normally
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 600,
      minHeight: 600,
      quality: 70,
    );
    return base64Encode(compressed);
  }
  // Future<String> compressAndEncodeBytes(Uint8List bytes) async {
  //   final compressed = await FlutterImageCompress.compressWithList(
  //     bytes as Uint8List,
  //     minWidth: 600,
  //     minHeight: 600,
  //     quality: 70,
  //   );
  //   return base64Encode(compressed);
  // }

  // ── Keep the old File‑based method for compatibility ──
  Future<String?> compressAndEncode(File imageFile) async {
    final bytes = await imageFile.readAsBytes();   // already Uint8List
    return compressAndEncodeBytes(bytes);          // no cast needed
  }

  // ── CRUD methods ──
  Future<void> addStaff(StaffMember staff) async {
    final data = staff.toMap();
    if (staff.type == 'teacher') {
      await _teacherCollection().add(data);
    } else {
      await _staffCollection().add(data);
    }
  }

  Future<void> updateStaff(String id, StaffMember updatedStaff) async {
    // 1. Find where the document currently lives
    final teacherDoc = await _teacherCollection().doc(id).get();
    final staffDoc = await _staffCollection().doc(id).get();

    String? currentCollection;
    if (teacherDoc.exists) {
      currentCollection = 'teachers';
    } else if (staffDoc.exists) {
      currentCollection = 'staff';
    } else {
      // Document not found – fallback: just add (shouldn't happen normally)
      await addStaff(updatedStaff);
      return;
    }

    final data = updatedStaff.toMap();

    // 2. If type hasn’t changed → normal update
    if (currentCollection == updatedStaff.type) {
      if (currentCollection == 'teachers') {
        await _teacherCollection().doc(id).update(data);
      } else {
        await _staffCollection().doc(id).update(data);
      }
    }
    // 3. Type changed → delete from old collection and add to new with the SAME id
    else {
      // delete from old
      if (currentCollection == 'teachers') {
        await _teacherCollection().doc(id).delete();
      } else {
        await _staffCollection().doc(id).delete();
      }

      // add to new using set (so we keep the same document ID)
      if (updatedStaff.type == 'teacher') {
        await _teacherCollection().doc(id).set(data);
      } else {
        await _staffCollection().doc(id).set(data);
      }
    }
  }


  Future<void> deleteStaff(String id) async {
    final batch = _firestore.batch();
    batch.delete(_teacherCollection().doc(id));
    batch.delete(_staffCollection().doc(id));
    await batch.commit();
  }

  Future<List<StaffMember>> getAllStaff() async {
    final teacherSnap = await _teacherCollection().get();
    final staffSnap = await _staffCollection().get();

    final teachers = teacherSnap.docs
        .map((doc) => StaffMember.fromMap(doc.data(), doc.id))
        .toList();
    final staff = staffSnap.docs
        .map((doc) => StaffMember.fromMap(doc.data(), doc.id))
        .toList();

    return [...teachers, ...staff];
  }

  Future<List<StaffMember>> getTeachers() async {
    final snap = await _teacherCollection().get();
    return snap.docs.map((doc) => StaffMember.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<StaffMember>> getStaffOnly() async {
    final snap = await _staffCollection().get();
    return snap.docs.map((doc) => StaffMember.fromMap(doc.data(), doc.id)).toList();
  }



}