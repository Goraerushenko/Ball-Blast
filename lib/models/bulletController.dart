import 'dart:async';
import 'dart:math';
import 'package:ball_blast/models/gunController.dart';
import 'package:flutter/material.dart';

import 'ballController.dart';

class BulletController {
  List<BulletInfo> infoList = [];

  Widget render () => Stack(
    children: infoList.map((el) => Row(
      children: List(el.count).map((e) => Padding(
        padding: const EdgeInsets.only(left: 1.0),
        child: Transform.translate(
            offset: el.anim.value,
            child: el.visible ? Container(
              height: 20,
              width: 10,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      image: AssetImage('assets/gunElements/bullet.png'),
                      fit: BoxFit.contain
                  )
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 2,
                  width: 2,
                  color: Colors.transparent,
                  key: el.key,
                ),
              ),
            ) : SizedBox()
        ),
      )).toList(),
    )).toList(),
  );

  Offset getBulletPos (BulletInfo info) {
    RenderBox box = info.key.currentContext.findRenderObject();
    return box.localToGlobal(Offset.zero);
  }
  BulletAnim anim = BulletAnim();
  void listReRender () {
    for(int i = 0; i < infoList.length; i++) {
      infoList[i].index = i;
    }
  }
}

class BulletInfo {
  bool visible = true;
  int index;
  int count;
  GlobalKey key = GlobalKey();
  Animation<Offset> anim ;
  AnimationController cont;
  BulletInfo({this.index, this.count, this.anim, this.cont});
}

class BulletAnim {
  Animation<double> _shootAnim;
  AnimationController _shootCont;
  GunController _gunController;
  BallController _ballController;
  BulletController _bulletController;
  TickerProvider _provider;
  double value () => _shootAnim.value;
  AnimationStatus status () => _shootAnim.status;
  Function _update;
  bool _canceled = false;
  Timer _shootTime;

  void start () {
    _canceled = false;
    _shootCont.forward();
    _shootTime = Timer.periodic(Duration(milliseconds: 1000 ~/  _gunController.shootSpeed), (timer) {
      final bullet = BulletInfo(
        index: _bulletController.infoList.length,
        cont: AnimationController(vsync: _provider, duration: Duration(seconds: 1)),
        count: 1,
      );
      _bulletController.infoList.add(bullet);
      _bulletController.infoList[_bulletController.infoList.length-1].anim = Tween(
          begin: _gunController.pos.getGunPos(),
          end: Offset(_gunController.pos.getGunPos().dx, -10)
      ).animate(
          _bulletController.infoList[_bulletController.infoList.length-1].cont
      )..addListener(
              () {
            if(bullet.index == 0) {
              _update();
              _bulletController.infoList.forEach((bullet) {
                for (var i = 0; i < _ballController.infoList.length; i++) {
                  if(_ballController.anim.hitVerIf(_ballController.infoList[i], bullet)) {
                    bullet.visible = false;
                    _ballController.anim.thanHit(i);
                    if (_ballController.infoList[i].health <= 0) {
                      _ballController.anim.thanKill(i);
                      break;
                    }
                  }
                }
              });
            }
            if (bullet.anim.status == AnimationStatus.completed) {
              bullet.cont.stop();
              _bulletController.infoList.removeAt(0);
              _bulletController.listReRender();
            }
          }
      );
      bullet.cont.forward();
    });
  }


  void initial ({
    @required TickerProvider provider,
    @required Function update,
    @required Size wheelSize,
    @required BulletController bulletController,
    @required GunController gunController,
    @required BallController ballController,}) {
    _bulletController = bulletController;
    _ballController = ballController;
    _provider = provider;
    _shootCont = AnimationController(vsync: provider, duration: Duration(milliseconds: 100));
    _update = update;
    _shootAnim = Tween(
        begin: 0.0,
        end: wheelSize.width * 0.25
    ).animate(_shootCont)
      ..addListener(
              () {
            _update();
            if (status() == AnimationStatus.dismissed) {
              if (!_canceled) {
                _shootCont.forward();
              }
            } else if (status() == AnimationStatus.completed){
              _shootCont.reverse();
            }
          }
      );
    _gunController = gunController;
  }

  void cancel () {
    _canceled = true;
    _shootTime.cancel();
  }

}