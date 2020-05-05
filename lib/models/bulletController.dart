import 'dart:async';

import 'package:ball_blast/models/gunController.dart';
import 'package:ball_blast/widgets/Game.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class BulletController {
  List<BulletRow> list = [

  ];

  BulletAnim anim = BulletAnim();

  void reRender () {
    for(int i = 0; i < list.length; i++) {
      list[i].index = i;
    }
  }
}

class BulletRow {
  int index;
  int count;
  BulletRow({this.index, this.count});
}

class BulletAnim {
  Animation<double> _shootAnim;
  AnimationController _shootCont;
  Function _update;
  List<Animation<Offset>> _bulletAnimList = [];
  List<AnimationController> _bulletContList = [];
  bool _canceled = false;
  BulletController _bulletController;
  GunController _gunController;
  Timer _shootTime;
  TickerProvider _provider;
  AnimationStatus status () => _shootAnim.status;

  double value () => _shootAnim.value;

  Widget render () => Stack(
    children: _bulletController.list.map((el) => Row(
      children: List(el.count).map((e) => Padding(
        padding: const EdgeInsets.only(left: 1.0),
        child: Transform.translate(
            offset: _bulletAnimList[el.index].value,
            child: Container(
              height: 15,
              width: 7,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      image: AssetImage('assets/gunElements/bullet.png'),
                      fit: BoxFit.contain
                  )
              ),
            )
        ),
      )).toList(),
    )).toList(),
  );

  void start () {
    _canceled = false;
    _shootCont.forward();
    _shootTime = Timer.periodic(Duration(milliseconds: 1000 ~/ _gunController.shootSpeed), (timer) {
      _bulletContList.add(AnimationController(vsync: _provider, duration: Duration(seconds: 1)));
      _bulletAnimList.add(
          Tween(
              begin: _gunController.pos.getGunPos(),
              end: Offset(_gunController.pos.getGunPos().dx, -10)
          ).animate(
              _bulletContList[_bulletContList.length-1]
          )..addListener(
                  () {
                    _update();
                    if(_bulletAnimList[0].status == AnimationStatus.completed) {
                      _bulletAnimList.removeAt(0);
                      _bulletContList.removeAt(0);
                      _bulletController.list.removeAt(0);
                      _bulletController.reRender();
                    }
                  }
          )
      );
      _bulletContList[_bulletContList.length-1].forward();
      _bulletController.list.add(
          BulletRow(
              index: _bulletContList.length-1,
              count: _gunController.power
          )
      );
    });
  }

  void cancel () {
    _canceled = true;
    _shootTime.cancel();
  }

  void initial ({@required TickerProvider provider,@required Function update,@required Size wheelSize,@required BulletController bulletController,@required GunController gunController}) {
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
    _bulletController = bulletController;
    _gunController = gunController;
  }

}