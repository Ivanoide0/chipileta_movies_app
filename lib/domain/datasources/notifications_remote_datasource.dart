import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/app_notification.dart';

class NotificationsRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('notifications');

  Future<void> addLike({
    required String recipientUid,
    required int movieId,
    required String movieTitle,
    required String moviePoster,
  }) async {
    await _col(recipientUid).add({
      'type': 'like',
      'movie_id': movieId,
      'movie_title': movieTitle,
      'movie_poster': moviePoster,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': false,
    });
  }

  Future<List<AppNotification>> getForUser(String uid) async {
    final snapshot =
        await _col(uid).orderBy('created_at', descending: true).get();

    return snapshot.docs.map((doc) {
      final map = doc.data();
      return AppNotification(
        remoteId: doc.id,
        movieId: (map['movie_id'] as num?)?.toInt() ?? 0,
        movieTitle: map['movie_title'] as String? ?? '',
        moviePoster: map['movie_poster'] as String? ?? '',
        type: NotificationType.like,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
            DateTime.now(),
        isRead: map['is_read'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> markAllRead(String uid) async {
    final snapshot = await _col(uid).where('is_read', isEqualTo: false).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  Future<void> delete(String uid, String remoteId) async {
    await _col(uid).doc(remoteId).delete();
  }

  Future<void> clearAll(String uid) async {
    final snapshot = await _col(uid).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
