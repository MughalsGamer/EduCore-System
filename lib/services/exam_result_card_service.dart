import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam_result_card_model.dart';

class ExamResultCardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'exam_result_cards';

  Stream<List<ExamResultCard>> getCardsStream() {
    return _db.collection(collection).orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => ExamResultCard.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  Future<void> addCard(ExamResultCard card) async {
    await _db.collection(collection).add(card.toMap());
  }

  Future<void> updateCard(String id, ExamResultCard card) async {
    await _db.collection(collection).doc(id).update(card.toMap());
  }

  Future<void> deleteCard(String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}