import 'package:flutter/material.dart';

class GunController {
  List<Map<String, double>> gunPos = [];
  Animation<double> flowAnim;
  int power;
  int shootSpeed;
  GlobalKey gunKey = GlobalKey();
  Map<String, double> posListClipper () {
    List<Map<String, double>> curList = gunPos;
    Map<String, double> clippedPart;
    clippedPart = {
      'previos': curList[0]['previos'],
      'now': curList[curList.length-1]['now'],
    };
    clear();
    return clippedPart;
  }
  void clear () => gunPos = [];
  GunController({this.power, this.shootSpeed});
}