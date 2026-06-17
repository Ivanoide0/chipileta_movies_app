import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:flutter/material.dart';

class HomeSections extends StatelessWidget {
  final List<Movie> recommendations;
  final List<Movie> movies;
  final List<Movie> series;
  final Map<int, String> movieGenres;
  final Map<int, String> tvGenres;

  const HomeSections({
    super.key,
    required this.recommendations,
    required this.movies,
    required this.series,
    required this.movieGenres,
    required this.tvGenres,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Chipi recomendaciones',
            action: 'Ver todo',
          ),
          const SizedBox(height: 12),
          _Recommendations(
            movies: recommendations.take(10).toList(),
            genres: movieGenres,
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Chipi lista de películas'),
          const SizedBox(height: 12),
          _MediaList(
            movies: movies.take(3).toList(),
            genres: movieGenres,
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Chipi lista de series'),
          const SizedBox(height: 12),
          _MediaList(
            movies: series.take(3).toList(),
            genres: tvGenres,
          ),
          const SizedBox(height: 28),
          const _OpinionsTitle(),
          const SizedBox(height: 28),
          const _Opinions(),
          const SizedBox(height: 24),
          const _StaticOpinionField(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;

  const _SectionTitle({
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: AppColors.yellow,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _Recommendations extends StatelessWidget {
  final List<Movie> movies;
  final Map<int, String> genres;

  const _Recommendations({
    required this.movies,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const _EmptyMessage('No hay recomendaciones disponibles.');
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final movie = movies[index];

          return SizedBox(
            width: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    width: 88,
                    height: 128,
                    child: _MovieImage(path: movie.posterPath),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _genreText(movie, genres),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MediaList extends StatelessWidget {
  final List<Movie> movies;
  final Map<int, String> genres;

  const _MediaList({
    required this.movies,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const _EmptyMessage('No hay contenido disponible.');
    }

    return Column(
      children: [
        for (var index = 0; index < movies.length; index++) ...[
          _MediaTile(
            movie: movies[index],
            genres: genres,
          ),
          if (index < movies.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MediaTile extends StatelessWidget {
  final Movie movie;
  final Map<int, String> genres;

  const _MediaTile({
    required this.movie,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = movie.backdropPath.isNotEmpty
        ? movie.backdropPath
        : movie.posterPath;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 88,
            height: 62,
            child: _MovieImage(path: imagePath),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _genreText(movie, genres),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.yellow,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpinionsTitle extends StatelessWidget {
  const _OpinionsTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.dividerBlue,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Chipi opiniones',
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.dividerBlue,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _Opinions extends StatelessWidget {
  const _Opinions();

  static const List<_Opinion> opinions = [
    _Opinion('Tarun kumar', 'TK', 4.5),
    _Opinion('Abhishek Kumar', 'AK', 5.0),
    _Opinion('Mohit Yadav', 'MY', 5.0),
    _Opinion('Payal Yadav', 'PY', 5.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < opinions.length; index++) ...[
          _OpinionTile(opinion: opinions[index]),
          if (index < opinions.length - 1) const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _OpinionTile extends StatelessWidget {
  final _Opinion opinion;

  const _OpinionTile({required this.opinion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.white70,
          child: Text(
            opinion.initials,
            style: const TextStyle(
              color: AppColors.heroText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opinion.name,
                style: const TextStyle(
                  color: AppColors.yellow,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Chipi fantástico! ......',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.white70,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.star_rounded,
          color: AppColors.yellow,
          size: 15,
        ),
        const SizedBox(width: 3),
        Text(
          opinion.rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.yellow,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StaticOpinionField extends StatelessWidget {
  const _StaticOpinionField();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.white70,
          width: 1.4,
        ),
      ),
      child: const Text(
        'Deja tu chipi opinión aquí....',
        style: TextStyle(
          color: AppColors.white54,
          fontSize: 9,
        ),
      ),
    );
  }
}

class _MovieImage extends StatelessWidget {
  final String path;

  const _MovieImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w500$path',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : const _ImagePlaceholder(showLoader: true);
      },
      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool showLoader;

  const _ImagePlaceholder({
    this.showLoader = false,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.imagePlaceholder,
      child: Center(
        child: showLoader
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.yellow,
                ),
              )
            : const Icon(
                Icons.movie_outlined,
                color: AppColors.white54,
              ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.white70,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _Opinion {
  final String name;
  final String initials;
  final double rating;

  const _Opinion(
    this.name,
    this.initials,
    this.rating,
  );
}

String _genreText(Movie movie, Map<int, String> genres) {
  final names = movie.genreIds
      .map((id) => genres[id])
      .whereType<String>()
      .take(2)
      .toList();

  return names.isEmpty ? 'Sin género' : names.join(', ');
}