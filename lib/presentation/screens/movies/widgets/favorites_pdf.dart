import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:chipileta_movies_app/domain/entities/movie.dart';

/// Paleta de la app reutilizada en el PDF (ver AppColors).
const _navy = PdfColor.fromInt(0xFF19264F);
const _teal = PdfColor.fromInt(0xFF08706D);
const _tealMid = PdfColor.fromInt(0xFF075A68);
const _yellow = PdfColor.fromInt(0xFFFFD91A);
const _turquoise = PdfColor.fromInt(0xFF00CDB8);
const _card = PdfColor.fromInt(0xFFEAF1F2);
const _placeholder = PdfColor.fromInt(0xFF234B62);

/// Estrella dibujada como SVG (Helvetica no trae el glifo ★).
String _starSvg(String hex) =>
    '<svg viewBox="0 0 24 24"><path fill="$hex" '
    'd="M12 2l2.9 6.3 6.9.8-5.1 4.7 1.4 6.8L12 17.8 5.9 21.4l1.4-6.8L2.2 9.9l6.9-.8z"/></svg>';

pw.Widget _star(double size, String hex) => pw.SizedBox(
      width: size,
      height: size,
      child: pw.SvgImage(svg: _starSvg(hex)),
    );

/// Genera el PDF y abre la hoja para compartir.
Future<void> shareFavoritesPdf(List<Movie> movies) async {
  await Printing.sharePdf(
    bytes: await _buildFavoritesPdf(movies),
    filename: 'favoritos_chipileta.pdf',
  );
}

/// Genera el PDF y abre el diálogo del sistema para guardarlo/descargarlo.
Future<void> downloadFavoritesPdf(List<Movie> movies) async {
  await Printing.layoutPdf(
    name: 'favoritos_chipileta.pdf',
    onLayout: (_) async => _buildFavoritesPdf(movies),
  );
}

Future<Uint8List> _buildFavoritesPdf(List<Movie> movies) async {
  // Descarga los pósters en paralelo; null si la película no tiene imagen o falla.
  final posters = await Future.wait(movies.map(_loadPoster));

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
      ),
      header: (_) => _header(movies.length),
      build: (_) => [
        for (var i = 0; i < movies.length; i++) ...[
          _movieCard(movies[i], posters[i]),
          pw.SizedBox(height: 12),
        ],
      ],
    ),
  );

  return doc.save();
}

Future<pw.ImageProvider?> _loadPoster(Movie movie) async {
  final path = movie.posterPath.isNotEmpty ? movie.posterPath : movie.backdropPath;
  if (path.isEmpty) return null;
  try {
    return await networkImage('https://image.tmdb.org/t/p/w342$path');
  } catch (_) {
    return null; // ponytail: póster opcional, si falla seguimos sin él
  }
}

pw.Widget _header(int count) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 16),
    padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: const pw.BoxDecoration(
      gradient: pw.LinearGradient(colors: [_teal, _tealMid, _navy]),
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(14)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Mis películas favoritas',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Chipi+ $count título${count == 1 ? '' : 's'}',
                style: const pw.TextStyle(color: _yellow, fontSize: 11),
              ),
            ],
          ),
        ),
        pw.Container(
          width: 34,
          height: 34,
          decoration: const pw.BoxDecoration(
            color: _yellow,
            shape: pw.BoxShape.circle,
          ),
          alignment: pw.Alignment.center,
          child: _star(18, '#19264F'),
        ),
      ],
    ),
  );
}

pw.Widget _movieCard(Movie movie, pw.ImageProvider? poster) {
  final year = movie.releaseDate?.year;
  final meta = <String>[
    movie.mediaTypeLabel,
    if (year != null) '$year',
    if (movie.runtime != null && movie.runtime! > 0) '${movie.runtime} min',
  ].join('  •  ');

  return pw.Container(
    decoration: const pw.BoxDecoration(
      color: _card,
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
    ),
    padding: const pw.EdgeInsets.all(10),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.ClipRRect(
          horizontalRadius: 8,
          verticalRadius: 8,
          child: poster != null
              ? pw.Image(poster, width: 78, height: 116, fit: pw.BoxFit.cover)
              : pw.Container(width: 78, height: 116, color: _placeholder),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                movie.title,
                maxLines: 2,
                style: pw.TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(children: [
                _star(11, '#FFD91A'),
                pw.SizedBox(width: 3),
                pw.Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: pw.TextStyle(
                    color: _tealMid,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    meta,
                    style: const pw.TextStyle(color: _tealMid, fontSize: 10),
                  ),
                ),
              ]),
              if (movie.genres.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  movie.genres.join('  ·  '),
                  style: pw.TextStyle(
                    color: _turquoise,
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Text(
                movie.overview.isNotEmpty
                    ? movie.overview
                    : 'Sin sinopsis disponible.',
                maxLines: 5,
                style: const pw.TextStyle(color: _navy, fontSize: 10, lineSpacing: 1.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
