import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

class GameEngine extends StatefulWidget{
  const GameEngine({super.key});


  @override
  GameEngineState createState() => GameEngineState();
}

class GameEngineState extends State<GameEngine> with TickerProviderStateMixin{

  late Ticker ticker;
  Duration lastElapsed = Duration.zero;

  late Offset circleCenterNorm; // normalized [0.1] coordinates
  late double circleRadiusNorm; // nirmalized to smaller dimension
  final List<Offset> circleCenters = [];
  final List<double> circleRadii = [];
  int bounceCount = 0;
  
  double ballX = 0.5;
  double velocityX = 0.4;
  final RandomVar = Random();

  // Ball state
  double ballY = 0.17;      // normalized [0,1]
  double velocity = 0.0;   // in normalized units per second
  final double gravity = 1.25; // accel in normalized units/sec²

  // record the velocity needed to reach the starting height
  late final double initialVelocity;
  final paddleY = 0.9;

  // Max number of trail “particles”
  final int maxTrailLength = 20;

  // A list of past normalized Y positions
  final List<double> trail = [];

  // bat position offset and limiter to prevent bat from going out of boundaries
  double batOffset = 0.0;
  int offsetCount = 0;

  @override
  void initState() {
    super.initState();

    // Calculate the exact velocity to go from paddleY up to startY
    final startY = ballY; // 0.3
    
    // Using v^2 = 2 * g * Δy  →  v = sqrt(2 * g * (paddleY - startY))
    initialVelocity = sqrt(2 * gravity * (paddleY - startY));

    _startTicker();
    spawnCircle();
  }

  void _startTicker(){
    lastElapsed = Duration.zero;
    // start the ticker…
    ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (lastElapsed == Duration.zero) {
      // first tick, just record and return
      lastElapsed = elapsed;
      return;
    }

    // Compute delta time in seconds
    final dt = (elapsed - lastElapsed).inMilliseconds / 1000.0;
    lastElapsed = elapsed;

    // Physics
    velocity += gravity * dt; // vertical acceleration
    ballX += velocityX * dt; // horizontal move
    ballY += velocity * dt; // vertical move

    // wall collisions
    if(ballX <= 0){
      ballX = 0;
      velocityX = -velocityX;
    } else if(ballX > 1){
      ballX = 1;
      velocityX = -velocityX;
    }

    // top wall bounce
    if(ballY <= 0){
      ballY = 0;
      velocity = initialVelocity;
    }

    // Bounce the ball or game over check
    if(ballY >= paddleY){
      // calculate bat bounds in normalized coordinates
      // we know ballX is always center: 0.5 normalized (for now)
      final ballXNorm = ballX;
      // batWidth normalized:
      final batWidthNorm = 0.3;
      // bat center x normalized = 0.5 + (batOffset / screenWidth)
      final screenWidth = MediaQuery.sizeOf(context).width;
      final batOffsetNorm = batOffset / screenWidth;
      final batLeft = 0.5 - batWidthNorm / 2 + batOffsetNorm;
      final batRight = 0.5 + batWidthNorm / 2 + batOffsetNorm;

      if(ballXNorm >= batLeft && ballXNorm <= batRight){
        // hit
        ballY = paddleY;
        velocity = -initialVelocity;
      } else {
        // miss -> GAME OVER
        gameOver();
        return;
      } 
      }
      else if (ballY <= 0){
        ballY = 0;
        velocity = initialVelocity;
      }

    // // Bounce
    // if (ballY >= paddleY) {
    //   ballY = paddleY;
    //   velocity = -initialVelocity;  // reset to perfect upward speed
    // } else if (ballY <= 0) {
    //   ballY = 0;
    //   velocity = initialVelocity;   // if you also want it to bounce off the ceiling
    // }

    // 1. Add current position to the front
    trail.insert(0, ballY);

    // 2. Trim old entries
    if (trail.length > maxTrailLength) {
      trail.removeLast();
    }

    final height = MediaQuery.sizeOf(context).height;

    // ball collision
    final X = ballX - circleCenterNorm.dx;
    final Y = ballY - circleCenterNorm.dy;
    final distance = sqrt(X * X + Y * Y);
    if(distance <= circleRadiusNorm + (15.0 / height)){
      // simple reflections: compute normal
      final newX = X / distance;
      final newY = Y / distance;

      // velocity vector
      final newVelocityX = velocityX;
      final newVelocityY = velocity;

      // reflect v' = v - 2*(v-n)*n
      final dot = newVelocityX * newX + newVelocityY * newY;
      final reflectedX = newVelocityX - 2 * dot * newX;
      final reflectedY = newVelocityY - 2 * dot * newY;
      velocityX = reflectedX;
      velocity = reflectedY;

      // move ball just outside circle ot avoid sticking
      ballX = circleCenterNorm.dx + (newX * (circleRadiusNorm + 15.0 / height));
      ballY = circleCenterNorm.dy + (newY * (circleRadiusNorm + 15.0 / height));
    }

    // Trigger repaint
    setState(() {});
  }

  void gameOver(){
    ticker.stop();
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('GAME OVER', style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),),
        content: const Text('You missed the ball!', style: TextStyle(color: Color.fromARGB(255, 255, 0, 0),),),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
            resetGame();
          }, 
          child: const Text('RESTART', style: TextStyle(color: Colors.blue))
        )
      ],
    ));
  }

  void resetGame(){
    // reset state
    setState(() {
      ballY = 0.17;
      velocity = 0.0;
      trail.clear();
      batOffset = 0;
      offsetCount = 0;
    });

    ticker.dispose;

    spawnCircle();

    _startTicker();
  }

  void spawnCircle(){
    // radius betweel 0.05 to 0.1 of the screen
    circleRadiusNorm - 0.05 + RandomVar.nextDouble() * 0.05;
    // center X between radius and 1 - radius
    final centerX = circleRadiusNorm + RandomVar.nextDouble() * (1 - 2 * circleRadiusNorm);
    // center Y between 0.2 and 0.7 so it's in the middle
    final centerY = 0.2 + RandomVar.nextDouble() * 0.5;
    circleCenterNorm = Offset(centerX, centerY);
  }

  @override
  void dispose() {
    ticker.dispose();
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
                  painter: Painter(
                    ballY: ballY, 
                    trail: trail, 
                    batOffset: batOffset,
                    circleCenterNorm: circleCenterNorm,
                    circleRadiusNorm: circleRadiusNorm,
                  ),
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
  final Offset circleCenterNorm;
  final double circleRadiusNorm;

  Painter({
    required this.ballY, 
    required this.trail, 
    required this.batOffset, 
    required this.circleCenterNorm, 
    required this.circleRadiusNorm
  });

  @override
  void paint(Canvas canvas, Size size){
    final paint = Paint()..isAntiAlias = true;

    // draw obstacle circle
    final circleX = circleCenterNorm.dx * size.width;
    final circleY = circleCenterNorm.dy * size.height;
    // radius in pixels: use min dimension
    final radius = circleRadiusNorm * min(size.width, size.height);
    paint.color = Colors.redAccent.withOpacity(0.7);
    canvas.drawCircle(Offset(circleX, circleY), radius, paint);

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