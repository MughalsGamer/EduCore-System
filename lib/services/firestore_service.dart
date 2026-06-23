import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<Teacher>> getTeachers() async {
    final snapshot = await teachersCollection.get();
    return snapshot.docs
        .map((doc) =>
        Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addTeacher(Teacher teacher) =>
      teachersCollection.add(teacher.toMap());

  Future<void> updateTeacher(String id, Teacher teacher) =>
      teachersCollection.doc(id).update(teacher.toMap());

  Future<void> deleteTeacher(String id) =>
      teachersCollection.doc(id).delete();

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