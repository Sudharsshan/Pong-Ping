import 'package:flutter/material.dart';
import 'package:pong_ping/customEngine/ball_bouncer.dart';

class Mainscreen extends StatelessWidget{
  const Mainscreen({super.key});


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: BallBouncer())
    );
  }

  // navigate to settings page
  void toSettings(){

  }
}