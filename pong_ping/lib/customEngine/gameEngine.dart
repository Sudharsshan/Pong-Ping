import 'package:flutter/material.dart';

class GameEngine extends StatefulWidget{

  @override
  GameEngineState createState() => GameEngineState();
}

class GameEngineState extends State<GameEngine> with SingleTickerProviderStateMixin{

  @override
  Widget build(BuildContext context){

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.purple, width: 3),
        borderRadius: BorderRadius.circular(30)
      ),
      child: Text('Play Arena', style: TextStyle(color: Colors.purple),),
    );
  }
}