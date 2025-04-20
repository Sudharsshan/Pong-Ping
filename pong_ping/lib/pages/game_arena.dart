import 'package:flutter/material.dart';
import 'package:pong_ping/customEngine/gameEnginePart2.dart';

class GameArena extends StatefulWidget{
  const GameArena({super.key});


  @override
  GameArenaState createState() => GameArenaState();
}

class GameArenaState extends State<GameArena> with SingleTickerProviderStateMixin{


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameEnginePart2(),
    );
  }
}