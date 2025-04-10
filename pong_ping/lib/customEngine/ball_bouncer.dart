import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // for Ticker

class BallBouncer extends StatefulWidget{
  const BallBouncer({super.key});


  @override
  BounceController createState() => BounceController();
}

class BounceController extends State<BallBouncer> with SingleTickerProviderStateMixin{
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Ball state
  double _ballY = 0.5;      // normalized [0,1]
  double _velocity = 0.0;   // in normalized units per second
  final double _gravity = 1.0; // accel in normalized units/sec²

  @override
  void initState() {
    super.initState();

    // Create the ticker
    _ticker = this.createTicker(_onTick)
      ..start();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      // first tick, just record and return
      _lastElapsed = elapsed;
      return;
    }

    // Compute delta time in seconds
    final delta = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;

    // Physics: gravity + position update
    _velocity += _gravity * delta;
    _ballY += _velocity * delta;

    // Bounce logic
    const paddleY = 0.9;
    if (_ballY >= paddleY) {
      _ballY = paddleY;
      _velocity = -_velocity * 1; // no damping
    } else if (_ballY <= 0) {
      _ballY = 0;
      _velocity = -_velocity;
    }

    // Trigger repaint
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BallPainter(ballY: _ballY),
      child: Container(),
    );
  }
}

class _BallPainter extends CustomPainter {
  final double ballY; // normalized [0,1]

  _BallPainter({required this.ballY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // 1. Draw background color
    paint.color = Colors.black87;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 2. Draw paddle (rectangle at bottom-ish)
    final paddleWidth = size.width * 0.6;
    final paddleHeight = 20.0;
    final paddleX = (size.width - paddleWidth) / 2;
    final paddleY = size.height * 0.9;
    paint.color = Colors.white70;
    canvas.drawRect(
      Rect.fromLTWH(paddleX, paddleY, paddleWidth, paddleHeight),
      paint,
    );

    // 3. Draw ball
    final ballRadius = 15.0;
    final ballX = size.width / 2;
    final ballPosY = ballY * size.height;
    paint.color = Colors.orangeAccent;
    canvas.drawCircle(Offset(ballX, ballPosY), ballRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _BallPainter old) {
    // repaint whenever the ball moves
    return old.ballY != ballY;
  }
}