import 'package:flutter/foundation.dart';
import '../models/exam_result_card_model.dart';
import '../services/exam_result_card_service.dart';

class ExamResultCardProvider extends ChangeNotifier {
  final ExamResultCardService _service = ExamResultCardService();
  List<ExamResultCard> _cards = [];
  bool _isLoading = false;
  String? _error;

  List<ExamResultCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExamResultCardProvider() {
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cards = await _service.getCardsStream().first;
      _isLoading = false;
      notifyListeners();
      // Continue listening for real-time updates
      _service.getCardsStream().listen((cards) {
        _cards = cards;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // In exam_result_card_provider.dart

  Future<void> updateStudentMarks(
      String cardId, String studentId, Map<String, double> marks) async {
    // Find the card in current list
    final cardIndex = _cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) throw Exception('Card not found');
    final card = _cards[cardIndex];

    // Update the student's marks
    final updatedStudentMarks = card.studentMarks.map((sm) {
      if (sm.studentId == studentId) {
        return StudentExamMarks(
          studentId: sm.studentId,
          studentName: sm.studentName,
          obtainedMarks: marks,
        );
      }
      return sm;
    }).toList();

    final updatedCard = card.copyWith(studentMarks: updatedStudentMarks);
    await _service.updateCard(cardId, updatedCard);
  }

  Future<void> removeStudentFromCard(String cardId, String studentId) async {
    final cardIndex = _cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) throw Exception('Card not found');
    final card = _cards[cardIndex];

    final updatedStudentMarks =
    card.studentMarks.where((sm) => sm.studentId != studentId).toList();

    if (updatedStudentMarks.isEmpty) {
      // If no students left, delete the whole card
      await _service.deleteCard(cardId);
    } else {
      final updatedCard = card.copyWith(studentMarks: updatedStudentMarks);
      await _service.updateCard(cardId, updatedCard);
    }
  }

  Future<void> addCard(ExamResultCard card) async {
    try {
      await _service.addCard(card);
      // The stream will update the list automatically
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCard(String id, ExamResultCard card) async {
    try {
      await _service.updateCard(id, card);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCard(String id) async {
    try {
      await _service.deleteCard(id);
    } catch (e) {
      rethrow;
    }
  }
}