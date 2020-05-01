import 'package:flutter/material.dart';
class GunStencil {

  Widget wheel ({double opacity = 1.0}) => Opacity(
    opacity: opacity,
    child: Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/gunElements/wheel.png'),
              fit: BoxFit.fill
          ),
          color: Colors.transparent,
          shape: BoxShape.circle
      ),
    ),
  );

  Widget barrel ({double opacity = 1.0}) => Opacity(
    opacity: opacity,
    child: Container(
      height: 80,
      width: 40,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/gunElements/barrel.png'),
          fit: BoxFit.contain
        ),
          color: Colors.transparent,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0),)
      ),
    ),
  );
  Widget frame ({@required double height, @required double width}) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/gunElements/frame.png'),
            fit: BoxFit.contain
        ),
        color: Colors.transparent,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0),)
    ),
  );

  final Size wheelSize;

  final Size bodySize;

  GunStencil({@required this.wheelSize, @required this.bodySize,});
}