import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';

class ChipiBirdGame extends StatefulWidget{
  const ChipiBirdGame({super.key});

  static Future<void> show(BuildContext context){
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const ChipiBirdGame()
    );
  }

  @override
  State<ChipiBirdGame> createState() => _ChipiBirdGameState();
}

class _ChipiBirdGameState extends State<ChipiBirdGame>
  with SingleTickerProviderStateMixin{

  static const double _gameWidth = 320;
  static const double _gameHeight = 440;

  static const double _gravity = 1400;
  static const double _flapVelocity = -420;
  static const double _birdX = 90;
  static const double _birdRadius = 16;
  
  static const double _pipeWidth = 54; 
  static const double _pipeGap = 150;
  static const double _pipeSpeed = 150;
  static const double _pipeSpacing = 200;
  static const double _groundHeight = 40;

  static const String _logoAsset = 'lib/resources/images/chipilogo 2.png';
  static const String _jumpSound = 'sounds/jump.wav';

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  final Random _random = Random();
  
  static const int _audioPoolSize = 7;
  final List<AudioPlayer> _audioPool = [];
  int _audioIndex = 0;
  ui.Image? _birdImage;

  double _birdY = _gameHeight/2;
  double _birdVelocity = 0;
  final List<_Pipe> _pipes = [];

  int _score = 0;
  int _best = 0;
  _GameState _state = _GameState.idle; 

  @override
  void initState(){
    super.initState();
    _resetGame();
    _loadBirdImage();
    _initAudio();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  Future<void> _initAudio() async{
    try{
      for(int i = 0; i < _audioPoolSize; i++){
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource(_jumpSound));
        await player.setVolume(1.0);
        _audioPool.add(player);
      }
    }catch(_){

    }
  }

  Future<void> _loadBirdImage() async{
    try{
      final ImageStream stream = AssetImage(_logoAsset).resolve(ImageConfiguration.empty);
      final Completer<ui.Image> completer = Completer<ui.Image>();
      late final ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool _){
        completer.complete(info.image);
        stream.removeListener(listener);
      }, onError: (Object error, StackTrace? _){
        if(!completer.isCompleted) completer.completeError(error);
        stream.removeListener(listener);
      });
      stream.addListener(listener);

      final ui.Image image = await completer.future;
      if(!mounted) return;
      setState(() => _birdImage = image);
    } catch (_){

    }
  }

  void _playJumpSound() async{
    if(_audioPool.isEmpty) return;

    // Toma el siguiente reproductor del pool en rotación.
    final player = _audioPool[_audioIndex];
    _audioIndex = (_audioIndex + 1) % _audioPool.length;

    // Dispara sin await: no bloquea el frame del salto. Los errores se
    // ignoran para no interrumpir el juego.
    player.seek(Duration.zero).then((_) => player.resume()).catchError((_){});
  }

  @override
  void dispose() {
    _ticker.dispose();
    for(final player in _audioPool){
      player.dispose();
    }
    super.dispose();
  }

  void _resetGame(){
    _birdY = _gameHeight/2;
    _birdVelocity = 0;
    _score = 0;
    _pipes.clear();

    double startX = _gameWidth + 80;
    for(int i = 0; i < 3; i++){
      _pipes.add(_Pipe(x: startX, gapY: _randomGapY()));
      startX += _pipeSpacing;
    }

    _state = _GameState.idle;
  }

  double _randomGapY(){
    const double margin = 70;
    final double minY = margin + _pipeGap/2;
    final double maxY = _gameHeight - _groundHeight - margin - _pipeGap/2;
    return minY + _random.nextDouble() * (maxY - minY);
  }

  void _onTick(Duration elapsed){
    if(_lastTick == Duration.zero){
      _lastTick = elapsed;
      return;
    }

    final double dt = ((elapsed - _lastTick).inMicroseconds/1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;

    if(_state != _GameState.playing){
      setState(() {});
      return;
    }

    _birdVelocity += _gravity * dt;
    _birdY += _birdVelocity * dt;

    for(final pipe in _pipes){
      pipe.x -= _pipeSpeed * dt;

      if(!pipe.scored && pipe.x + _pipeWidth < _birdX){
        pipe.scored = true;
        _score++;
      }
    }

    if(_pipes.isNotEmpty && _pipes.first.x + _pipeWidth < 0){
      _pipes.removeAt(0);
      final double lastX = _pipes.last.x;
      _pipes.add(_Pipe(x: lastX + _pipeSpacing, gapY: _randomGapY()));
    }

    if(_checkCollision()){
      _endGame();
    }

    setState(() {});
  }

  bool _checkCollision(){
    if(_birdY + _birdRadius >= _gameHeight - _groundHeight) return true;
    if(_birdY - _birdRadius <= 0) return true;

    for(final pipe in _pipes){
      final bool overlapX = _birdX + _birdRadius > pipe.x && _birdX - _birdRadius < pipe.x + _pipeWidth;
      if(overlapX){
        final double gapTop = pipe.gapY - _pipeGap/2;
        final double gapBottom = pipe.gapY + _pipeGap/2;
        final bool inGap = _birdY - _birdRadius > gapTop && _birdY + _birdRadius < gapBottom;

        if(!inGap) return true;
      }
    }

    return false;
  }

  void _endGame(){
    _state = _GameState.gameOver;
    if(_score > _best) _best = _score;
  }

  void _onTap(){
    switch(_state){
      case _GameState.idle:
        _state = _GameState.playing;
        _birdVelocity = _flapVelocity;
        _playJumpSound();
        break;
      case _GameState.playing:
        _birdVelocity = _flapVelocity;
        _playJumpSound();
        break;
      case _GameState.gameOver:
        setState(_resetGame);
        break;
    }
  }

  @override
  Widget build(BuildContext context){
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: _gameWidth,
          decoration: const BoxDecoration(
            gradient: AppColors.homeGradient,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                child: Row(
                  children: [
                    const Text(
                      'ChipiBird',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Récord: $_best',
                      style: const TextStyle(
                        color: AppColors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.white,
                        size: 22,
                      )
                    )
                  ],
                ),
              ),

              GestureDetector(
                onTap: _onTap,
                child: SizedBox(
                  width: _gameHeight,
                  height: _gameHeight,
                  child: CustomPaint(
                    painter: _ChipiBirdPainter(
                      birdImage: _birdImage,
                      birdY: _birdY,
                      birdX: _birdX,
                      birdRadius: _birdRadius,
                      birdVelocity: _birdVelocity,
                      pipes: _pipes,
                      pipeWidth: _pipeWidth,
                      pipeGap: _pipeGap,
                      groundHeight: _groundHeight,
                      score: _score,
                      state: _state
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum _GameState{idle, playing, gameOver}

class _Pipe{
  double x;
  final double gapY;
  bool scored;

  _Pipe({required this.x, required this.gapY}) : scored = false;
}

class _ChipiBirdPainter extends CustomPainter{
  final ui.Image? birdImage;
  final double birdY;
  final double birdX;
  final double birdRadius;
  final double birdVelocity;
  final List<_Pipe> pipes;
  final double pipeWidth;
  final double pipeGap;
  final double groundHeight;
  final int score;
  final _GameState state;

  _ChipiBirdPainter({
    required this.birdImage,
    required this.birdY,
    required this.birdX,
    required this.birdRadius,
    required this.birdVelocity,
    required this.pipes,
    required this.pipeWidth,
    required this.pipeGap,
    required this.groundHeight,
    required this.score,
    required this.state
  });

  @override
  void paint(Canvas canvas, Size size){
    _paintTubes(canvas, size);
    _paintGround(canvas, size);
    _paintBird(canvas);
    _paintScore(canvas, size);
    _paintOverlay(canvas, size);
  }

  void _paintTubes(Canvas canvas, Size size){
    final Paint pipePaint = Paint()..color = AppColors.turquoise;
    final Paint pipeShade = Paint()..color = AppColors.gradientTop;

    for(final pipe in pipes){
      final double gapTop = pipe.gapY - pipeGap/2;
      final double gapBottom = pipe.gapY + pipeGap/2;

      final Rect top = Rect.fromLTRB(pipe.x, 0, pipe.x + pipeWidth, gapTop);
      canvas.drawRect(top, pipePaint);
      canvas.drawRect(
        Rect.fromLTWH(pipe.x - 3, gapTop - 14, pipeWidth + 6, 14),
        pipeShade
      );

      final Rect bottom = Rect.fromLTRB(
        pipe.x,
        gapBottom,
        pipe.x + pipeWidth,
        size.height - groundHeight
      );
      canvas.drawRect(bottom, pipePaint);

      canvas.drawRect(
        Rect.fromLTWH(pipe.x - 3, gapBottom, pipeWidth + 6, 14),
        pipeShade
      );
    }
  }

  void _paintGround(Canvas canvas, Size size){
    final Paint groundPaint = Paint()..color = AppColors.heroText;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - groundHeight, size.width, groundHeight),
      groundPaint
    );
  }

  void _paintBird(Canvas canvas){
    canvas.save();
    canvas.translate(birdX, birdY);

    final double tilt = (birdVelocity/600).clamp(-0.5,0.9);
    canvas.rotate(tilt);
    if(birdImage != null){
      _paintLogoBird(canvas);
    }else{
      _paintGeometricBird(canvas);
    }
    canvas.restore();
  }

  void _paintLogoBird(Canvas canvas){
    final ui.Image img = birdImage!;
    const double size = 44;
    final Rect dst = Rect.fromCenter(
      center: Offset.zero,
      width: size,
      height: size,
    );
    final Rect src = Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );
    final Paint paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(img, src, dst, paint);
  }

  void _paintGeometricBird(Canvas canvas){
    final Paint body = Paint()..color = AppColors.yellow;
    final Paint wing = Paint()..color = const Color(0xFFF5B301);
    final Paint beak = Paint()..color = const Color(0xFFFF8A00);
    final Paint comb = Paint()..color = AppColors.notificationRed;
    final Paint eyeWhite = Paint()..color = AppColors.white;
    final Paint eyeBlack = Paint()..color = AppColors.backgroundDark;

    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(Offset(i * 6.0, -birdRadius + 2), 4, comb);
    }

    canvas.drawCircle(Offset.zero, birdRadius, body);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(-3, 3),
        width: 16,
        height: 11,
      ),
      wing,
    );
    final Path beakPath = Path()
      ..moveTo(birdRadius - 2, -3)
      ..lineTo(birdRadius + 9, 0)
      ..lineTo(birdRadius - 2, 4)
      ..close();
    canvas.drawPath(beakPath, beak);

    // Ojo.
    canvas.drawCircle(const Offset(6, -5), 4.5, eyeWhite);
    canvas.drawCircle(const Offset(7, -5), 2.2, eyeBlack);
  }

  void _paintScore(Canvas canvas, Size size){
    if(state == _GameState.idle) return;

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '$score',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 44,
          fontWeight: FontWeight.w900
        )
      ),
      textDirection: TextDirection.ltr
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, 30));
  }

  void _paintOverlay(Canvas canvas, Size size){
    String? title;
    String? subtitle;

    if(state == _GameState.idle){
      title = '¡Toca para volar!';
      subtitle = 'Esquiva los tubos';
    }else if(state == _GameState.gameOver){
      title = 'Game Over';
      subtitle = 'Toca para reintentar';
    }

    if(title == null) return;

    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: AppColors.yellow,
          fontSize: 26,
          fontWeight: FontWeight.w900
        )
      ),
      textDirection: TextDirection.ltr
    )..layout();

    final TextPainter subPainter = TextPainter(
      text: TextSpan(
        text: subtitle,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600
        )
      ),
      textDirection: TextDirection.ltr
    )..layout();

    final double cy = size.height * 0.16;
    titlePainter.paint(
      canvas,
      Offset((size.width - titlePainter.width) / 2, cy)
    );
    subPainter.paint(
      canvas,
      Offset((size.width - subPainter.width) / 2, cy + 36)
    );
  }

  @override
  bool shouldRepaint(covariant _ChipiBirdPainter oldDelegate) => true;
}