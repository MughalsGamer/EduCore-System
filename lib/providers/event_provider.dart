import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  final CollectionReference _eventsRef =
  FirebaseFirestore.instance.collection('events');

  List<EventModel> _events = [];
  bool _isLoading = false;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;

  /// Sirf active events (list me sab dikhane hain tou ye use na karein,
  /// filtering UI level pe bhi ho sakti hai)
  List<EventModel> get activeEvents =>
      _events.where((e) => e.isActive).toList();

  StreamSubscription<QuerySnapshot>? _sub;

  /// Live listener — Firestore change hote hi list update ho jayegi
  void listenToEvents() {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();

    _sub = _eventsRef
        .orderBy('date', descending: false)
        .snapshots()
        .listen((snapshot) async {
      final loaded = snapshot.docs
          .map((doc) =>
          EventModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      _events = loaded;
      _isLoading = false;
      notifyListeners();

      // Expired events ko silently auto-disable karo (batch update)
      await _autoDisableExpiredEvents(loaded);
    });
  }

  Future<void> _autoDisableExpiredEvents(List<EventModel> loaded) async {
    final toDisable =
    loaded.where((e) => e.isActive && e.isExpired).toList();
    if (toDisable.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final e in toDisable) {
      batch.update(_eventsRef.doc(e.id), {'isActive': false});
    }
    await batch.commit();
    // snapshots() listener khud hi naya data la dega, alag se setState nahi chahiye
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime date,
  }) async {
    await _eventsRef.add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEvent(EventModel event) async {
    await _eventsRef.doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _eventsRef.doc(id).delete();
  }

  Future<void> toggleActive(EventModel event) async {
    await _eventsRef.doc(event.id).update({'isActive': !event.isActive});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}