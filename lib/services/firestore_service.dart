import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/class_model.dart';
import '../models/fee_structure.dart';
import '../models/fee_receipt.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- Students ----------
  CollectionReference get studentsCollection =>
      _db.collection('schools').doc('school1').collection('students');

  Future<List<Student>> getStudents() async {
    QuerySnapshot snapshot = await studentsCollection.get();
    return snapshot.docs
        .map((doc) => Student.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addStudent(Student student) {
    return studentsCollection.add(student.toMap());
  }

  Future<void> updateStudent(String id, Student student) {
    return studentsCollection.doc(id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) {
    return studentsCollection.doc(id).delete();
  }

  // ---------- Teachers ----------
  CollectionReference get teachersCollection =>
      _db.collection('schools').doc('school1').collection('teachers');

  Future<List<Teacher>> getTeachers() async {
    QuerySnapshot snapshot = await teachersCollection.get();
    return snapshot.docs
        .map((doc) => Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addTeacher(Teacher teacher) {
    return teachersCollection.add(teacher.toMap());
  }

  Future<void> updateTeacher(String id, Teacher teacher) {
    return teachersCollection.doc(id).update(teacher.toMap());
  }

  Future<void> deleteTeacher(String id) {
    return teachersCollection.doc(id).delete();
  }

  // ---------- Classes ----------
  CollectionReference get classesCollection =>
      _db.collection('schools').doc('school1').collection('classes');

  Future<List<ClassModel>> getClasses() async {
    QuerySnapshot snapshot = await classesCollection.get();
    return snapshot.docs
        .map((doc) => ClassModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addClass(ClassModel classModel) {
    return classesCollection.add(classModel.toMap());
  }

  // ---------- Fee Structure ----------
  CollectionReference get feeStructureCollection =>
      _db.collection('schools').doc('school1').collection('feeStructures');

  Future<List<FeeStructure>> getFeeStructures() async {
    QuerySnapshot snapshot = await feeStructureCollection.get();
    return snapshot.docs
        .map((doc) => FeeStructure.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addFeeStructure(FeeStructure fs) {
    return feeStructureCollection.add(fs.toMap());
  }

  // ---------- Fee Receipts ----------
  CollectionReference get feeReceiptsCollection =>
      _db.collection('schools').doc('school1').collection('feeReceipts');

  Future<void> addFeeReceipt(FeeReceipt receipt) {
    return feeReceiptsCollection.add(receipt.toMap());
  }

  Future<List<FeeReceipt>> getReceiptsByStudent(String studentId) async {
    QuerySnapshot snapshot = await feeReceiptsCollection
        .where('studentId', isEqualTo: studentId)
        .get();
    return snapshot.docs
        .map((doc) => FeeReceipt.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<FeeReceipt>> getAllReceipts() async {
    QuerySnapshot snapshot = await feeReceiptsCollection.get();
    return snapshot.docs
        .map((doc) => FeeReceipt.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // ---------- Expenses ----------
  CollectionReference get expensesCollection =>
      _db.collection('schools').doc('school1').collection('expenses');

  Future<void> addExpense(Expense expense) {
    return expensesCollection.add(expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    QuerySnapshot snapshot = await expensesCollection.get();
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}