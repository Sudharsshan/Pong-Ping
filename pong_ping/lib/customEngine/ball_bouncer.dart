import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // for Ticker
import 'dart:math';

class BallBouncer extends StatefulWidget{
  const BallBouncer({super.key});


  @override
  BounceController createState() => BounceController();
}

class BounceController extends State<BallBouncer> with SingleTickerProviderStateMixin{
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Ball state
  double _ballY = 0.3;      // normalized [0,1]
  double _velocity = 0.0;   // in normalized units per second
  final double _gravity = 1.0; // accel in normalized units/sec²

  // record the velocity needed to reach the starting height
  late final double _initialVelocity;
  final paddleY = 0.9;

  // Max number of trail “particles”
  final int _maxTrailLength = 20;

  // A list of past normalized Y positions
  final List<double> _trail = [];


  @override
  void initState() {
    super.initState();

    // Calculate the exact velocity to go from paddleY up to startY
    final startY = _ballY; // 0.3
    
    // Using v^2 = 2 * g * Δy  →  v = sqrt(2 * g * (paddleY - startY))
    _initialVelocity = sqrt(2 * _gravity * (paddleY - startY));

    // start the ticker…
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      // first tick, just record and return
      _lastElapsed = elapsed;
      return;
    }

    // Compute delta time in seconds
    final dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;

    // Physics
    _velocity += _gravity * dt;
    _ballY += _velocity * dt;

    // Bounce
    if (_ballY >= paddleY) {
      _ballY = paddleY;
      _velocity = -_initialVelocity;  // reset to perfect upward speed
    } else if (_ballY <= 0) {
      _ballY = 0;
      _velocity = _initialVelocity;   // if you also want it to bounce off the ceiling
    }

    // 1. Add current position to the front
    _trail.insert(0, _ballY);

    // 2. Trim old entries
    if (_trail.length > _maxTrailLength) {
      _trail.removeLast();
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
      painter: _BallPainter(ballY: _ballY, trail: _trail),
      child: Container(),
    );
  }
}

class _BallPainter extends CustomPainter {
  final double ballY; // normalized [0,1]
  final List<double> trail;

  _BallPainter({required this.ballY, required this.trail});

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
    final paddleY = size.height * 0.91;
    paint.color = Colors.deepPurple;
    canvas.drawRect(
      Rect.fromLTWH(paddleX, paddleY, paddleWidth, paddleHeight),
      paint,
    );

    // 3. Draw ball & Trail: draw circles for each past position
    final ballRadius = 15.0;
    final ballX = size.width / 2;
    final ballPosY = ballY * size.height;
    // forst trails
    for (int i = 0; i < trail.length; i++) {
      final posY = trail[i] * size.height;
      // opacity fades from 1.0 down to ~0.0
      final opacity = (1 - i / trail.length).clamp(0.0, 1.0);
      paint.color = const Color.fromARGB(255, 247, 151, 183).withOpacity(opacity * 0.6);
      // optionally shrink the circle slightly
      final radius = ballRadius * (1 - i / (trail.length * 1.2));
      canvas.drawCircle(Offset(ballX, posY), radius, paint);
    }
    // then ball on top
    paint.color = const Color.fromARGB(255, 255, 38, 110);
    canvas.drawCircle(Offset(ballX, ballPosY), ballRadius, paint); 
  }

  @override
  bool shouldRepaint(covariant _BallPainter old) =>
      old.ballY != ballY || old.trail.length != trail.length;
}