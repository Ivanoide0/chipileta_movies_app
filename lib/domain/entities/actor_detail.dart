class ActorDetail {
  final int id;
  final String name;
  final String biography;
  final String birthday;
  final String deathday;
  final String placeOfBirth;
  final String profilePath;
  final String knownForDepartment;
  final double popularity;
  final int gender;
  final String imdbId;
  final String instagramId;
  final List<ActorCredit> knownCredits;

  const ActorDetail({
    required this.id,
    required this.name,
    required this.biography,
    required this.birthday,
    required this.deathday,
    required this.placeOfBirth,
    required this.profilePath,
    required this.knownForDepartment,
    required this.popularity,
    required this.gender,
    required this.imdbId,
    required this.instagramId,
    required this.knownCredits,
  });

  factory ActorDetail.fromJson(Map<String, dynamic> json) {
    final combinedCredits =
        json['combined_credits'] as Map<String, dynamic>?;

    final cast = combinedCredits?['cast'] as List<dynamic>? ?? const [];

    final credits = cast
        .whereType<Map<String, dynamic>>()
        .map(ActorCredit.fromJson)
        .where((item) => item.title.trim().isNotEmpty)
        .toList();

    credits.sort((a, b) => b.voteCount.compareTo(a.voteCount));

    final externalIds =
        json['external_ids'] as Map<String, dynamic>? ?? const {};

    return ActorDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Actor desconocido',
      biography: json['biography'] as String? ?? '',
      birthday: json['birthday'] as String? ?? '',
      deathday: json['deathday'] as String? ?? '',
      placeOfBirth: json['place_of_birth'] as String? ?? '',
      profilePath: json['profile_path'] as String? ?? '',
      knownForDepartment:
          json['known_for_department'] as String? ?? 'Acting',
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      gender: json['gender'] as int? ?? 0,
      imdbId: externalIds['imdb_id'] as String? ?? '',
      instagramId: externalIds['instagram_id'] as String? ?? '',
      knownCredits: credits.take(12).toList(growable: false),
    );
  }

  String get genderLabel {
    switch (gender) {
      case 1:
        return 'Femenino';
      case 2:
        return 'Masculino';
      case 3:
        return 'No binario';
      default:
        return 'No especificado';
    }
  }

  String get departmentLabel {
    switch (knownForDepartment) {
      case 'Acting':
        return 'Actuación';
      case 'Directing':
        return 'Dirección';
      case 'Writing':
        return 'Guion';
      case 'Production':
        return 'Producción';
      default:
        return knownForDepartment;
    }
  }
}

class ActorCredit {
  final int id;
  final String title;
  final String mediaType;
  final String character;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;

  const ActorCredit({
    required this.id,
    required this.title,
    required this.mediaType,
    required this.character,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
  });

  factory ActorCredit.fromJson(Map<String, dynamic> json) {
    return ActorCredit(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ??
          json['name'] as String? ??
          'Sin título',
      mediaType: json['media_type'] as String? ?? '',
      character: json['character'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      releaseDate: json['release_date'] as String? ??
          json['first_air_date'] as String? ??
          '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }

  String get year {
    if (releaseDate.length < 4) return 'Sin año';
    return releaseDate.substring(0, 4);
  }

  String get mediaTypeLabel {
    if (mediaType == 'tv') return 'Serie';
    if (mediaType == 'movie') return 'Película';
    return 'Contenido';
  }
}