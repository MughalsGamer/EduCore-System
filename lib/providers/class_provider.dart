import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/class_model.dart';

class ClassProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ClassModel> _classes = [];
  bool _loading = false;

  List<ClassModel> get classes => _classes;
  bool get loading => _loading;

  // -------- Fetch all classes (with sections) --------
  Future<void> fetchClasses() async {
    _loading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('classes').get();
      final List<ClassModel> temp = [];
      for (final doc in snapshot.docs) {
        final classData = ClassModel.fromMap(doc.data(), doc.id);
        // Load sections from subcollection
        final sectionsSnapshot = await doc.reference.collection('sections').get();
        classData.sections = sectionsSnapshot.docs
            .map((sDoc) => SectionModel.fromMap(sDoc.data(), id: sDoc.id))
            .toList();
        temp.add(classData);
      }
      _classes = temp;
    } catch (e) {
      // handle error
      _classes = [];
    }
    _loading = false;
    notifyListeners();
  }

  // -------- Add new class (with sections as subcollection) --------
  Future<void> addClass(ClassModel classData) async {
    _loading = true;
    notifyListeners();
    try {
      // Add main document
      final docRef = await _firestore.collection('classes').add(classData.toMap());

      // If sections exist, save them as subdocuments
      if (classData.hasSections && classData.sections.isNotEmpty) {
        final batch = _firestore.batch();
        for (final section in classData.sections) {
          final sectionRef = docRef.collection('sections').doc();
          batch.set(sectionRef, section.toMap());
        }
        await batch.commit();
      }

      // Reload or add to local list
      final newClass = ClassModel.fromMap(
        (await docRef.get()).data()!,
        docRef.id,
      );
      // Keep the sections we just saved (they are already in classData.sections)
      if (classData.hasSections) {
        newClass.sections = classData.sections;
      }
      _classes.add(newClass);
    } catch (e) {
      // handle error
    }
    _loading = false;
    notifyListeners();
  }

  // -------- Update class (replace sections) --------
  Future<void> updateClass(String classId, ClassModel updatedData) async {
    _loading = true;
    notifyListeners();
    try {
      final docRef = _firestore.collection('classes').doc(classId);
      await docRef.update(updatedData.toMap());

      // Handle sections: replace all with new ones
      if (updatedData.hasSections) {
        // Delete existing sections
        final existingSections = await docRef.collection('sections').get();
        final batch = _firestore.batch();
        for (final doc in existingSections.docs) {
          batch.delete(doc.reference);
        }
        // Add new sections
        for (final section in updatedData.sections) {
          final sectionRef = docRef.collection('sections').doc();
          batch.set(sectionRef, section.toMap());
        }
        await batch.commit();
      } else {
        // If sections disabled, ensure no sections remain
        final existingSections = await docRef.collection('sections').get();
        final batch = _firestore.batch();
        for (final doc in existingSections.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Update local list
      final index = _classes.indexWhere((c) => c.id == classId);
      if (index != -1) {
        _classes[index] = updatedData;
        // reload sections for consistency
        if (updatedData.hasSections) {
          final sectionsSnapshot = await docRef.collection('sections').get();
          updatedData.sections = sectionsSnapshot.docs
              .map((sDoc) => SectionModel.fromMap(sDoc.data(), id: sDoc.id))
              .toList();
        }
      }
    } catch (e) {
      // handle error
    }
    _loading = false;
    notifyListeners();
  }

  // -------- Delete class (and its subcollection) --------
  Future<void> deleteClass(String classId) async {
    _loading = true;
    notifyListeners();
    try {
      final docRef = _firestore.collection('classes').doc(classId);
      // Delete subcollection sections
      final sections = await docRef.collection('sections').get();
      final batch = _firestore.batch();
      for (final doc in sections.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(docRef);
      await batch.commit();

      _classes.removeWhere((c) => c.id == classId);
    } catch (e) {
      // Re-throw to let UI handle error
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}