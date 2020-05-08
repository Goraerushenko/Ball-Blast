import 'dart:math';

import 'package:ball_blast/models/ballController.dart';
import 'package:ball_blast/models/bulletController.dart';
import 'package:flutter/material.dart';
import '../models/gunController.dart';
import '../models/gunStencil.dart';

class Game extends StatefulWidget {
  Game({
    Key key,
    @required this.background,
    @required this.menu,
    @required this.gun,
    @required this.size,
  }) : super(key: key);

  final Widget background;
  final Widget menu;
  final GunStencil gun;
  final Size size;

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {

  final BallController ballController = BallController();

  final GunController gunController = GunController();

  final BulletController bulletController = BulletController();

  @override
  void initState() {
    gunController.power = 1;
    gunController.shootSpeed = 40;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.background,
        Gun(
          size: widget.size,
          gun: widget.gun,
          gunController: gunController,
          ballController: ballController,
          bulletController: bulletController,
        )
      ],
    );
  }
}

class Gun extends StatefulWidget {
  Gun({
    Key key,
    this.gun,
    this.size,
    this.gunController,
    this.bulletController,
    this.ballController
  }) : super(key: key);
  final Size size;
  @required final BallController ballController;
  @required final BulletController bulletController;
  @required final GunStencil gun;
  @required final GunController gunController;

  @override
  _GunState createState() => _GunState();
}

class _GunState extends State<Gun> with TickerProviderStateMixin {
  double _gunPosDX = 0.0;
  Offset _barrelPos;
  Offset _framePos;

  double _getScreenPaleWidth () {
    final double gunWidth =  (widget.gun.wheelSize.width * 2 + widget.gun.wheelSize.width / 2);
    return MediaQuery.of(context).size.width - gunWidth ;
  }

    void _onPointerDown () {
    widget.bulletController.anim.start();
  }

  void _onPointerUp () {
    widget.bulletController.anim.cancel();
  }

  //-------------------------------------------
  @override
  void initState() {
    _gunPosDX = widget.size.width / 2 - widget.gun.wheelSize.width / 4 - widget.gun.wheelSize.width;
    _framePos = Offset(
        ((widget.gun.wheelSize.width + widget.gun.wheelSize.width / 4) - widget.gun.wheelSize.width) - 1,
        3
    );

    _barrelPos = Offset(
        (widget.gun.wheelSize.width + widget.gun.wheelSize.width / 4) - widget.gun.bodySize.width / 2,
        -widget.gun.bodySize.height + (widget.gun.wheelSize.height / 2)
    );

    widget.ballController.anim.initial(
      screenSize: widget.size,
      bulletPower: widget.gunController.power,
      provider: this,
      update: () => setState(() {}),
      ballController: widget.ballController,
    );

    widget.ballController.anim.newBall();

    widget.ballController.anim.newBall();

    widget.gunController.anim.initial (
      provider: this,
      update: () => setState(() {}),
      gunController: widget.gunController,
      startPos: _gunPosDX
    );

    widget.bulletController.anim.initial(
      provider: this,
      bulletController: widget.bulletController,
      wheelSize: widget.gun.wheelSize,
      update: () => setState(() {}),
      gunController: widget.gunController,
      ballController: widget.ballController,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        widget.bulletController.render(),
       widget.ballController.render(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(
                widget.gunController.anim.value() < 0 ?
                0.0 :
                (widget.gunController.anim.value() > _getScreenPaleWidth() ?
                _getScreenPaleWidth() :
                widget.gunController.anim.value()),
                -70
            ),
            child: Stack(
              children: <Widget>[
                Transform.translate(
                  offset: _framePos,
                  child: widget.gun.frame(
                      height: widget.gun.wheelSize.height / 2,
                      width: widget.gun.wheelSize.width * 2
                  ),
                ),

                Transform.translate(
                  offset: Offset(_barrelPos.dx, _barrelPos.dy + widget.bulletController.anim.value()),
                  child: widget.gun.barrel(),
                ),

                Row(
                  children: <Widget>[
                    Transform.rotate(
                      angle: widget.gunController.anim.getWheelRotation(),
                      child: widget.gun.wheel(),
                    ),
                    SizedBox(width: widget.gun.wheelSize.width / 2,),
                    Transform.rotate(
                      angle: widget.gunController.anim.getWheelRotation(),
                      child: widget.gun.wheel(),
                    ),
                  ],
                ),

                Transform.translate(
                  offset: Offset(_barrelPos.dx + widget.gun.bodySize.width / 2, _barrelPos.dy + 5),
                  child: Container(
                    key: widget.gunController.pos.gunKey,
                    height: 1,
                    width: 1,
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),

        Listener(
          onPointerDown: (details) {


            _onPointerDown();
          },
          onPointerUp: (details) {
            _onPointerUp();
          },
          onPointerMove: (details) {
            if(_gunPosDX + details.delta.dx > 0.0 && _gunPosDX + details.delta.dx < _getScreenPaleWidth()) {
              widget.gunController.pos.newEl(_gunPosDX, _gunPosDX + details.delta.dx);

              if(AnimationStatus.forward != widget.gunController.anim.status()) {
                widget.gunController.anim.start();
              }

              _gunPosDX +=  details.delta.dx;
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }


}
