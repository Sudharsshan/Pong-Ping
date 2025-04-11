import 'package:flutter/material.dart';
import 'package:pong_ping/customEngine/gameEngine.dart';

class GameArena extends StatefulWidget{
  const GameArena({super.key});


  @override
  GameArenaState createState() => GameArenaState();
}

class GameArenaState extends State<GameArena> with SingleTickerProviderStateMixin{

  // some variables for positions
  double upperPing = 0, lowerPing = 0;

  @override
  void initState() {
    super.initState();
  }

  void goLeft(){
    // make the platform go left
  }

  void goRight(){
    //make the platform go right
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Game space
          Expanded(
            flex: 4,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              color: const Color.fromARGB(255, 68, 68, 68),
              padding: EdgeInsets.all(60),
              child: GameEngine(),
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
                      goLeft();
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
      ),
    );


  }
}