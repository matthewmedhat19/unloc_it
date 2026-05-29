import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeService {
  static final _db = FirebaseFirestore.instance;

  // ─── Collections ───────────────────────────────
  static CollectionReference get _challenges =>
      _db.collection('challenges');
  static CollectionReference get _teams =>
      _db.collection('teams');
  static CollectionReference get _notifications =>
      _db.collection('notifications');

  // ─── Challenges ────────────────────────────────

  static Future<List<Map<String, dynamic>>> getChallenges() async {
    final snap = await _challenges.orderBy('order').get();
    return snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return {'id': d.id, ...data};
    }).toList();
  }

  static Future<void> addChallenge({
    required String title,
    required String description,
    required String password,
    required int order,
  }) async {
    await _challenges.add({
      'title': title,
      'description': description,
      'password': password,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteChallenge(String id) async {
    await _challenges.doc(id).delete();
  }

  // ─── Teams ─────────────────────────────────────

  static Future<Map<String, dynamic>> registerOrGetTeam(
      String teamName) async {
    final snap = await _teams
        .where('name', isEqualTo: teamName)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      return {'id': doc.id, ...(doc.data() as Map<String, dynamic>)};
    }

    final ref = await _teams.add({
      'name': teamName,
      'currentChallengeIndex': 0,
      'done': false,
      'startedAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });

    return {
      'id': ref.id,
      'name': teamName,
      'currentChallengeIndex': 0,
      'done': false,
    };
  }

  static Future<void> advanceTeam({
    required String teamId,
    required int nextIndex,
    required int totalChallenges,
  }) async {
    final bool done = nextIndex >= totalChallenges;
    await _teams.doc(teamId).update({
      'currentChallengeIndex': nextIndex,
      'done': done,
      if (done) 'completedAt': FieldValue.serverTimestamp(),
    });

    // لو الفريق خلص → ابعت notification للأدمن
    if (done) {
      final teamDoc = await _teams.doc(teamId).get();
      final teamName =
          (teamDoc.data() as Map<String, dynamic>)['name'] as String? ?? '';
      await addNotification(
        title: '🏆 فريق خلص!',
        body: '"$teamName" خلص كل التحديات!',
        teamName: teamName,
      );
    }
  }

  // ─── Notifications ─────────────────────────────

  /// أضف notification جديدة
  static Future<void> addNotification({
    required String title,
    required String body,
    required String teamName,
  }) async {
    await _notifications.add({
      'title': title,
      'body': body,
      'teamName': teamName,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// علّم كل الـ notifications كـ مقروءة
  static Future<void> markAllNotificationsRead() async {
    final snap =
    await _notifications.where('read', isEqualTo: false).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  /// Stream للـ notifications الغير مقروءة
  static Stream<List<Map<String, dynamic>>> unreadNotificationsStream() {
    return _notifications
        .where('read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      return {'id': d.id, ...(d.data() as Map<String, dynamic>)};
    }).toList());
  }

  /// Stream لكل الـ notifications (للتاريخ)
  static Stream<List<Map<String, dynamic>>> allNotificationsStream() {
    return _notifications
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      return {'id': d.id, ...(d.data() as Map<String, dynamic>)};
    }).toList());
  }

  /// Stream لحالة كل الفرق
  static Stream<List<Map<String, dynamic>>> teamsStream() {
    return _teams
        .orderBy('startedAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      return {'id': d.id, ...(d.data() as Map<String, dynamic>)};
    }).toList());
  }
}