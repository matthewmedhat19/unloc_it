import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeService {
  static final _db = FirebaseFirestore.instance;

  // ─── Collections ───────────────────────────────
  static CollectionReference get _challenges =>
      _db.collection('challenges');
  static CollectionReference get _teams =>
      _db.collection('teams');

  // ─── Challenges ────────────────────────────────

  /// جيب كل التحديات مرتبة حسب الـ order
  static Future<List<Map<String, dynamic>>> getChallenges() async {
    final snap = await _challenges.orderBy('order').get();
    return snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return {'id': d.id, ...data};
    }).toList();
  }

  /// أضف تحدي جديد (Admin)
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

  /// احذف تحدي (Admin)
  static Future<void> deleteChallenge(String id) async {
    await _challenges.doc(id).delete();
  }

  // ─── Teams ─────────────────────────────────────

  /// سجل فريق جديد أو رجّع الموجود
  static Future<Map<String, dynamic>> registerOrGetTeam(
      String teamName) async {
    final snap = await _teams
        .where('name', isEqualTo: teamName)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      // الفريق موجود قبل كده — رجّع بياناته
      final doc = snap.docs.first;
      return {'id': doc.id, ...(doc.data() as Map<String, dynamic>)};
    }

    // فريق جديد
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

  /// تقدّم الفريق للتحدي الجاي
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
  }

  /// Stream لحالة كل الفرق (Admin Dashboard - realtime)
  static Stream<List<Map<String, dynamic>>> teamsStream() {
    return _teams
        .orderBy('startedAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              return {'id': d.id, ...(d.data() as Map<String, dynamic>)};
            }).toList());
  }
}
