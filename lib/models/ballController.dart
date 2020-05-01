import 'package:flutter/material.dart';

class BallController {
  List<BallInfo> infoList = [];
  List<Animation<Offset>> animList = [];
  List<AnimatedContainer> contList = [];
}

class BallInfo {
  List<Offset> trajectory = [];
  int index;
  Size ballSize;
  int health;
}