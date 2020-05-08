import 'dart:math';
import 'package:ball_blast/models/bulletController.dart';
import 'package:flutter/material.dart';

enum RenderStatus {

  render,

  rendered
}

class BallController {
  List<BallInfo> infoList = [];

  BallAnim anim = BallAnim();

  Offset getBallPos (BallInfo ball) {
    RenderBox box = ball.key.currentContext.findRenderObject();
    return box.localToGlobal(Offset.zero);
  }

  String intToTextInt (String str) {
    String letter = '';
    if (str.length > 3) {
      letter = 'k';
    }
    return letter == '' ? str : str[1] == '0' ? '${str[0]}$letter' : '${str[0]}.${str[1]}$letter';
  }

  Color _getColorByHealth (int health) {
    Color willReturn;
    Map<int, Color> colorsList = {
      0: Colors.lightBlueAccent[100],
      60: Colors.blue[300],
      120: Colors.blueAccent[200],
      180: Colors.greenAccent[100],
      250: Colors.lightGreen[200],
      400: Colors.red[300],
      700: Colors.red[400],
      1000: Colors.red[600],
      1500: Colors.red[900],
    };
    colorsList.keys.forEach((el) => willReturn = health >= el ? colorsList[el] : willReturn );
    return willReturn ?? Colors.black;
  }

  Widget render () => Stack(
      children: infoList.map((el) => Transform.translate(
        offset: el.ballAnim.value,
        child: Container(
          height: el.ballSize,
          width: el.ballSize,
          decoration: BoxDecoration(
              color: _getColorByHealth(el.health),
              shape: BoxShape.circle
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    key: el.key,
                    height: 0.5,
                    width: 0.5,
                    color: Colors.red,
                  ),
                ),
                Center(
                  child: Text(intToTextInt(el.health.toString()), style: TextStyle(color: Colors.white, fontSize: el.textSizeAnim.value),),
                ),
              ],
            ),
          ),
        ),
      )).toList()
  );

  void listReRender () {
    for(int i = 0; i < infoList.length; i++) {
      infoList[i].index = i;
    }
  }

}

class BallInfo {
  int index;
  RenderStatus renderStatus = RenderStatus.render;
  double ballSize;
  GlobalKey key = GlobalKey();
  AnimationController ballCont;
  Animation<Offset> ballAnim;
  AnimationController textSizeCont;
  Animation<double> textSizeAnim;
  int health;
  BallInfo({ this.ballSize, this.health, this.index});
}

class BallAnim {
  Size _screenSize;
  BallController _ballController;
  TickerProvider _provider;
  Function _update;
  int _bulletPower;

  void thanKill (int i) {
    _ballController.infoList.removeAt(i);
    _ballController.listReRender();
    newBall();
  }

  bool hitVerIf (BallInfo ball, BulletInfo bullet) {
    if(ball.renderStatus == RenderStatus.rendered) {
      final Offset ballPos = _ballController.getBallPos(ball);
      double fromBulletToBall = sqrt(pow((ballPos.dx - bullet.anim.value.dx), 2) + pow(( ballPos.dy - bullet.anim.value.dy), 2));
      if(fromBulletToBall <= ball.ballSize / 2 + 5  &&  bullet.visible) {
        return true;
      }
    }
    return false;
  }

  void thanHit (int i) {
    _ballController.infoList[i].health -= _bulletPower;
    if(_ballController.infoList[i].textSizeAnim.status == AnimationStatus.dismissed) _ballController.infoList[i].textSizeCont.forward();
  }

  void newBall () {
    List<double> sizeList = [];
    for (int i = 2; i < 6; i++) {
      sizeList.add(_screenSize.width * (i / 10));
    }
    double ballSize = sizeList[Random().nextInt(sizeList.length)];
    final BallInfo ballInfo = BallInfo(
      health: Random().nextInt(10000),
      ballSize: ballSize
    );
    // el.ballSize * 0.3
    ballInfo.textSizeCont = AnimationController(vsync: _provider, duration: Duration(milliseconds: 500));
    ballInfo.textSizeAnim = Tween(
      begin: ballSize * 0.4,
      end: ballSize * 0.7
    ).animate( ballInfo.textSizeCont)..addListener(() {
      if (ballInfo.textSizeAnim.status == AnimationStatus.forward) {
        ballInfo.textSizeCont.reverse();
      }
    });
    _ballController.infoList.add(ballInfo);
    _ballController.infoList[_ballController.infoList.length-1].index = _ballController.infoList.length-1;
    final bool leftSide = Random().nextInt(2).toInt() == 0;
    final int addHeight = Random().nextInt((_screenSize.height * 0.3).toInt());
    _ballController.infoList[_ballController.infoList.length-1].ballCont = AnimationController(vsync: _provider,duration: Duration(seconds: 2));
    _ballController.infoList[_ballController.infoList.length-1].ballAnim =  Tween(
        begin: Offset(leftSide ? -ballInfo.ballSize : _screenSize.width + ballInfo.ballSize, addHeight.toDouble()),
        end:  Offset(leftSide ? 10.0 : _screenSize.width -  ballInfo.ballSize- 10, addHeight.toDouble())
    ).animate(
        CurvedAnimation(
            parent: _ballController.infoList[_ballController.infoList.length-1].ballCont,
            curve: Curves.ease
        )
    )..addListener(() {
      _update();
      if (ballInfo.renderStatus != RenderStatus.rendered) {
        ballInfo.renderStatus = RenderStatus.rendered;
      }
    });
    _ballController.infoList[_ballController.infoList.length-1].ballCont.forward();
  }

  void initial ({
    @required TickerProvider provider,
    @required Function update,
    @required Size screenSize,
    @required BallController ballController,
    @required int bulletPower}) {

    _ballController = ballController;
    _provider = provider;
    _bulletPower = bulletPower;
    _screenSize = screenSize;
    _update = update;
  }
}