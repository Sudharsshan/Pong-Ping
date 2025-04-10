import 'package:flutter/material.dart';

class Mainscreen extends StatelessWidget{
  const Mainscreen({super.key});


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          // background
          Container(color: Colors.amber,), // put a GIF for better visuals

          // foreground
          ConstrainedBox(
            constraints: BoxConstraints.tight(Size(100, 80)),
            child: ListView(
              semanticChildCount: 2,
              children: [
                // Play button
                GestureDetector(
                  child: Text('PLAY'),
                ),

                // Settings button
                GestureDetector(
                  child: Text('SETTINGS'),
                )
              ],
            ),
          )
            ],
          )
    );
  }

  // navigate to settings page
  void toSettings(){

  }
}