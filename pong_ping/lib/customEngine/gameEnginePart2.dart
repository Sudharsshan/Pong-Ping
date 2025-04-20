import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

class GameEnginePart2 extends StatefulWidget {
  const GameEnginePart2({super.key});

  @override
  State<GameEnginePart2> createState() => _GameArenaState();
}

class _GameArenaState extends State<GameEnginePart2> with TickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final Random _random = Random();
  
  // Ball properties
  double _ballX = 0.5;
  double _ballY = 0.2;
  double _ballSpeedX = 0.25;
  double _ballSpeedY = 0.0;
  final double _gravity = 1.8;
  final double _ballRadius = 15.0;
  
  // Bat properties
  final double _batWidth = 0.3;
  double _batX = 0.35;
  final double _batHeight = 15.0;
  final double _batY = 0.9;
  final double _batSpeed = 20;
  
  // Game elements
  final List<Offset> _obstacles = [];
  final List<double> _obstacleRadii = [];
  int _score = 0;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _spawnObstacles();
    _startGame();
  }

  void _startGame() {
    _lastElapsed = Duration.zero;
    _ticker = createTicker(_update)..start();
  }

  void _update(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final dt = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    _lastElapsed = elapsed;

    if (!_gameOver) {
      _updateBallPosition(dt);
      _checkCollisions();
      _checkBatCollision();
      _checkObstacleCollisions();
    }

    setState(() {});
  }

  void _updateBallPosition(double dt) {
    _ballSpeedY += _gravity * dt;
    _ballX += _ballSpeedX * dt;
    _ballY += _ballSpeedY * dt;

    // Wall collisions
    if (_ballX <= 0 || _ballX >= 1) {
      _ballSpeedX *= -1;
      _ballX = _ballX.clamp(0.0, 1.0);
    }
  }

  void _checkCollisions() {
    // Ceiling collision
    if (_ballY <= 0) {
      _ballY = 0;
      _ballSpeedY = _ballSpeedY.abs();
    }

    // Floor collision (game over)
    if (_ballY >= 1) {
      _gameOver = true;
      _ticker.stop();
    }
  }

  void _checkBatCollision() {
    final batLeft = _batX;
    final batRight = _batX + _batWidth;
    final ballCenterX = _ballX;
    
    if (_ballY >= _batY - 0.02 && 
        ballCenterX >= batLeft && 
        ballCenterX <= batRight) {
      _ballY = _batY - 0.02;
      _ballSpeedY = -_ballSpeedY.abs();
      _score += 5;
      
      // Add horizontal direction change based on hit position
      final hitPosition = (ballCenterX - batLeft) / _batWidth;
      _ballSpeedX = (hitPosition - 0.5) * 2;
    }
  }

  void _checkObstacleCollisions() {
    final screenSize = MediaQuery.sizeOf(context);
    
    for (int i = 0; i < _obstacles.length; i++) {
      final obstacle = _obstacles[i];
      final radius = _obstacleRadii[i];
      
      final dx = (_ballX - obstacle.dx) * screenSize.width;
      final dy = (_ballY - obstacle.dy) * screenSize.height;
      final distance = sqrt(dx * dx + dy * dy);
      final minDistance = _ballRadius + radius;

      if (distance < minDistance) {
        // Calculate collision normal
        final normalX = dx / distance;
        final normalY = dy / distance;
        
        // Reflect velocity
        final dot = _ballSpeedX * normalX + _ballSpeedY * normalY;
        _ballSpeedX = _ballSpeedX - 2 * dot * normalX;
        _ballSpeedY = _ballSpeedY - 2 * dot * normalY;
        
        // Reposition ball
        final overlap = minDistance - distance;
        _ballX += normalX * overlap / screenSize.width;
        _ballY += normalY * overlap / screenSize.height;
        
        // Remove obstacle and increase score
        _obstacles.removeAt(i);
        _obstacleRadii.removeAt(i);
        _score += 10;
        break;
      }
    }
  }

  void _spawnObstacles() {
    for (int i = 0; i < 5; i++) {
      bool validPosition;
      late double x, y, radius;
      
      do {
        validPosition = true;
        radius = 0.04 + _random.nextDouble() * 0.06;
        x = radius + _random.nextDouble() * (1 - 2 * radius);
        y = 0.3 + _random.nextDouble() * 0.5;
        
        // Check for existing obstacles
        for (final obstacle in _obstacles) {
          final dx = (x - obstacle.dx) * 100;
          final dy = (y - obstacle.dy) * 100;
          if (sqrt(dx * dx + dy * dy) < (radius + _obstacleRadii[_obstacles.indexOf(obstacle)]) * 100) {
            validPosition = false;
            break;
          }
        }
      } while (!validPosition);
      
      _obstacles.add(Offset(x, y));
      _obstacleRadii.add(radius);
    }
  }

  void _resetGame() {
    _ballX = 0.5;
    _ballY = 0.2;
    _ballSpeedX = 0.25;
    _ballSpeedY = 0.0;
    _batX = 0.35;
    _score = 0;
    _gameOver = false;
    _obstacles.clear();
    _obstacleRadii.clear();
    _spawnObstacles();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Obstacles
                ..._obstacles.map((obstacle) => Positioned(
                  left: obstacle.dx * size.width - _obstacleRadii[_obstacles.indexOf(obstacle)] * size.width,
                  top: obstacle.dy * size.height - _obstacleRadii[_obstacles.indexOf(obstacle)] * size.width,
                  child: Container(
                    width: _obstacleRadii[_obstacles.indexOf(obstacle)] * size.width * 2,
                    height: _obstacleRadii[_obstacles.indexOf(obstacle)] * size.width * 2,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                )),

                // Ball
                Positioned(
                  left: _ballX * size.width - _ballRadius,
                  top: _ballY * size.height - _ballRadius,
                  child: Container(
                    width: _ballRadius * 2,
                    height: _ballRadius * 2,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Bat
                Positioned(
                  left: _batX * size.width,
                  top: _batY * size.height,
                  child: Container(
                    width: size.width * _batWidth,
                    height: _batHeight,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Score
                Positioned(
                  top: 20,
                  right: 20,
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                )
              ],
            ),
          ),

          // Controls
          Container(
            height: 80,
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() {
                    _batX = (_batX - _batSpeed / size.width).clamp(0.0, 1.0 - _batWidth);
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _resetGame,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () => setState(() {
                    _batX = (_batX + _batSpeed / size.width).clamp(0.0, 1.0 - _batWidth);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}