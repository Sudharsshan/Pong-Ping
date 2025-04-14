import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

class GameEngine extends StatefulWidget{
  const GameEngine({super.key});


  @override
  GameEngineState createState() => GameEngineState();
}

class GameEngineState extends State<GameEngine> with SingleTickerProviderStateMixin{

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

  // bat position offset and limiter to prevent bat from going out of boundaries
  double batOffset = 0.0;
  int offsetCount = 0;

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

  void goLeft(){
    // make the platform go left
    if(offsetCount > -5){
      offsetCount--;
      batOffset -= 25;
    }
  }

  void goRight(){
    //make the platform go right
    if(offsetCount < 5){
      offsetCount++;
      batOffset += 25;
    }
  }

  @override
  Widget build(BuildContext context){

    return Column(
        children: [
          // Game space
          Expanded(
            flex: 4,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              color: const Color.fromARGB(255, 68, 68, 68),
              padding: EdgeInsets.all(60),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.purple, width: 3),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: CustomPaint(
                  painter: Painter(ballY: _ballY, trail: _trail, batOffset: batOffset),
                  child: Container(),
                ),
              ),
            )
          ),

          // Control buttons
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left button
                IconButton(
                  onPressed: ()=> {
                    setState(() {
                      goLeft();
                    })
                  }, 
                  icon: Icon(Icons.arrow_left),
                  iconSize: MediaQuery.sizeOf(context).width*0.12,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  color: Colors.purple,
                ),
            
                // Right button
                IconButton(
                  onPressed: ()=> {
                    setState(() {
                      goRight();
                    })
                  }, 
                  icon: Icon(Icons.arrow_right),
                  iconSize: MediaQuery.sizeOf(context).width*0.12,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  color: Colors.purple,
                )
              ],
            )
          )
        ],
      );
  }
}

class Painter extends CustomPainter{
  final double ballY;
  final List<double> trail;
  final double batOffset;

  Painter({required this.ballY, required this.trail, required this.batOffset});

  @override
  void paint(Canvas canvas, Size size){
    final paint = Paint()..isAntiAlias = true;

    // Draw ball and it's trail
    final ballRadius = 15.0;
    final ballX = size.width / 2;
    final ballPosY = ballY * size.height;

    // trails
    for(int i = 0; i < trail.length; i++){
      final posY = trail[i] * size.height;

      // fade the balls
      final opacity = (1 - i / trail.length).clamp(0.0, 1.0);
      paint.color = const Color.fromARGB(255, 247, 151, 183).withOpacity(opacity * 0.6);
      final radius = ballRadius * (1 - i / (trail.length * 1.2));
      canvas.drawCircle(Offset(ballX, posY), radius, paint);
    }

    // draw the ball
    paint.color = Colors.purple;
    canvas.drawCircle(Offset(ballX, ballPosY), ballRadius, paint);

    // draw the bottom bat
    final batWidth = size.width * 0.3;
    final batHeight = 10.0;
    final batX = (size.width - batWidth) / 2 + batOffset;
    final batY = size.height * 0.91;
    paint.color = Colors.purple;
    canvas.drawRect(Rect.fromLTWH(batX, batY, batWidth, batHeight), paint);
  }

  @override
  bool shouldRepaint(covariant Painter old) => old.ballY != ballY || old.trail.length != trail.length;
}