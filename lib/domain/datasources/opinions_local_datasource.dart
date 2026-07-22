import 'package:sqflite/sqflite.dart';
import '../data/models/opinion_model.dart';
import 'database_helper.dart';
import '../entities/opinion_with_author.dart';

class OpinionsLocalDataSource {
  final DatabaseHelper dbHelper;

  OpinionsLocalDataSource(this.dbHelper);

  Future<OpinionModel> addOpinion({
    required int movieId,
    required int userId,
    required double rating,
    required String comment
  }) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final opinion = OpinionModel(
      movieId: movieId,
      userId: userId,
      rating: rating, 
      comment: comment,
      createdAt: now);

      final id = await db.insert(
        'opinions',
        opinion.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort
      );

      return OpinionModel(
        movieId: movieId,
        userId: userId,
        rating: rating, 
        comment: comment,
        createdAt: now
      );
  }

  Future<List<OpinionModel>> getOpinionsByMovie(int movieId) async{
    final db = await dbHelper.database;
    final result = await db.query(
      'opinions',
      where: 'movie_id = ?',
      whereArgs: [movieId],
      orderBy: 'created_at DESC'
    );

    return result.map((map) => OpinionModel.fromMap(map)).toList();
  }

  Future<List<OpinionModel>> getAllOpinions() async{
    final db = await dbHelper.database;
    final result = await db.query(
      'opinions',
      orderBy: 'created_at DESC'
    );

    return result.map((map) => OpinionModel.fromMap(map)).toList();
  }

  Future<List<OpinionWithAuthor>> getAllOpinionsWithAuthor() async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT
        o.id          AS id,
        o.movie_id    AS movie_id,
        o.user_id     AS user_id,
        o.rating      AS rating,
        o.comment     AS comment,
        o.created_at  AS created_at,
        u.nombre      AS nombre,
        u.apellido    AS apellido,
        u.foto_perfil AS foto_perfil
      FROM opinions o
      INNER JOIN users u ON u.id = o.user_id
      ORDER BY o.created_at DESC
    ''');

    return rows.map((row) {
      final opinion = OpinionModel.fromMap(row).toEntity();
      return OpinionWithAuthor(
        opinion: opinion,
        authorName: row['nombre'] as String,
        authorLastName: row['apellido'] as String,
        authorPhotoPath: row['foto_perfil'] as String?,
      );
    }).toList();
  }
}