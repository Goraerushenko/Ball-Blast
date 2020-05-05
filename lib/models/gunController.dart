import 'package:flutter/material.dart';

class GunController {
  Pos pos = Pos();

  int power;

  int shootSpeed;

  Anim anim = Anim();

  GunController({this.power, this.shootSpeed});
}

class Pos {
  List<Map<String, double>>  listPos = [];
  GlobalKey gunKey = GlobalKey();
  Offset getGunPos () {
    RenderBox box = gunKey.currentContext.findRenderObject();
    Offset curPos =  box.localToGlobal(Offset.zero) ?? Offset(0, 0);
    curPos = Offset(curPos.dx - 3.5, curPos.dy);
    return curPos;
  }
  void newEl (double previous, double cur) {
    listPos.add(
        {
          'previos': previous,
          'cur': cur
        }
    );
  }
}


class Anim {
  GunController _gunController;

  Animation<double> _flowAnim;

  Function _update;

  AnimationStatus status () => _flowAnim.status;

  double value () => _flowAnim.value;

  AnimationController _flowCont;

  Animation<double> _stencilAnimFlow ({@required double begin, @required double end, @required Function addListener}) {
    _flowCont.reverse();
    return  Tween (
        begin: begin,
        end: end
    ).animate(CurvedAnimation(
        curve: Curves.linear,
        parent: _flowCont
    ))..addListener(() {
      _update();
      if(status() == AnimationStatus.completed ) {
        if(_gunController.pos.listPos.length != 0) {
          addListener();
        }
      }
    });
  }

  Map<String, double> _posListClipper () {
    List<Map<String, double>> curList = _gunController.pos.listPos;
    Map<String, double> clippedPart;
    clippedPart = {
      'previos': curList[0]['previos'],
      'cur': curList[curList.length-1]['cur'],
    };
    _gunController.pos.listPos = [];
    return clippedPart;
  }

  double getWheelRotation () =>  _flowAnim.value * 0.05;

  void _nextAnim ({@required double begin, @required double end}) {
    _flowAnim = _stencilAnimFlow(
        begin: begin,
        end: end,
        addListener: () {
          Map<String, double> firstEl = _posListClipper();
          _nextAnim(
              begin: firstEl['previos'],
              end: firstEl['cur']
          );
          _flowCont.forward();
        }
    );
  }

  void startAnim () {
    Map<String, double> clipped = _posListClipper();
    _flowAnim = _stencilAnimFlow (
        end: clipped['cur'],
        begin: clipped['previos'],
        addListener: () {
          clipped = _posListClipper();
          Map<String, double> firstEl = clipped;
          _nextAnim(begin: firstEl['previos'], end: firstEl['cur']);
          _flowCont.forward();
        }
    );
    _flowCont.forward();
  }

  void initial ({AnimationController controller, Function update, GunController gunController}) {
    _flowCont = controller;
    _update = update;
    _gunController = gunController;
    _flowAnim = Tween(begin: 0.0, end: 0.0).animate(_flowCont);
  }
}
