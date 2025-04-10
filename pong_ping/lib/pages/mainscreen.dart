import 'package:flutter/material.dart';
import 'package:pong_ping/customEngine/ball_bouncer.dart';

class Mainscreen extends StatelessWidget{
  const Mainscreen({super.key});


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment(0, 0),
          children: [
             BallBouncer(),

             ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200, maxHeight: 200),
              child: ListView(
                children: [
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.transparent,
                          border: Border.all(width: 5, color: Colors.purple)
                        ),
                        child: const Center(child: Text('PLAY', style: TextStyle(fontSize:20, color:  Colors.purple),),),
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.transparent,
                          border: Border.all(width: 5, color: Colors.purple)
                        ),
                        child: const Center(child: Text('SCORE SHEET', style: TextStyle(fontSize:20, color:  Colors.purple),),),
                      ),
                    ),
                ],
              ),
            )
          ],
        )
        )
    );
  }

  // navigate to settings page
  void toSettings(){

  }
}