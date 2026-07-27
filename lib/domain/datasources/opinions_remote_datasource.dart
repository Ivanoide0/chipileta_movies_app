import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/opinion_model.dart';
import '../entities/opinion_with_author.dart';

class OpinionsRemoteDataSource {
  final FirebaseFirestore _firestore;

  OpinionsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _opinions =>
      _firestore.collection('opinions');

  Future<OpinionModel> addOpinion({
    required int movieId,
    required String userId,
    required double rating,
    required String comment,
    required String authorName,
    required String authorLastName,
    String? authorPhotoPath,
  }) async {
    final now = DateTime.now();
    final opinion = OpinionModel(
      movieId: movieId,
      userId: userId,
      rating: rating,
      comment: comment,
      createdAt: now,
      authorName: authorName,
      authorLastName: authorLastName,
      authorPhotoPath: authorPhotoPath,
    );

    final docRef = await _opinions.add(opinion.toFirestoreMap());

    return OpinionModel(
      id: docRef.id,
      movieId: movieId,
      userId: userId,
      rating: rating,
      comment: comment,
      createdAt: now,
      authorName: authorName,
      authorLastName: authorLastName,
      authorPhotoPath: authorPhotoPath,
    );
  }

  Future<List<OpinionModel>> getOpinionsByMovie(int movieId) async {
    final snapshot = await _opinions
        .where('movie_id', isEqualTo: movieId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => OpinionModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<List<OpinionModel>> getAllOpinions() async {
    final snapshot =
        await _opinions.orderBy('created_at', descending: true).get();

    return snapshot.docs
        .map((doc) => OpinionModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<List<OpinionWithAuthor>> getAllOpinionsWithAuthor() async {
    final snapshot =
        await _opinions.orderBy('created_at', descending: true).get();

    // Sin JOIN: los datos del autor ya vienen dentro de cada documento.
    return snapshot.docs.map((doc) {
      final model = OpinionModel.fromFirestore(doc.id, doc.data());
      return OpinionWithAuthor(
        opinion: model.toEntity(),
        authorName: model.authorName,
        authorLastName: model.authorLastName,
        authorPhotoPath: model.authorPhotoPath,
      );
    }).toList();
  }
}