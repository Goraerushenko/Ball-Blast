import 'dart:async';

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

  final GunController gunController = GunController();

  final BulletController bulletController = BulletController();

  @override
  void initState() {
    gunController.power = 1;
    gunController.shootSpeed = 10;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.background,
        Gun(
          gun: widget.gun,
          gunController: gunController,
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
    this.gunController,
    this.bulletController
  }) : super(key: key);
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

  void _whenGunStarted () {
    widget.bulletController.anim.start();
  }

  void _whenGunIsCanceled () {
    widget.bulletController.anim.cancel();
  }

  Widget _ballsRender () => Stack(
    children: <Widget>[

    ],
  );

  @override
  void initState() {
    _framePos = Offset(
        ((widget.gun.wheelSize.width + widget.gun.wheelSize.width / 4) - widget.gun.wheelSize.width) - 1,
        3
    );

    _barrelPos = Offset(
        (widget.gun.wheelSize.width + widget.gun.wheelSize.width / 4) - widget.gun.bodySize.width / 2,
        -widget.gun.bodySize.height + (widget.gun.wheelSize.height / 2)
    );

    widget.gunController.anim.initial (
      controller: AnimationController(vsync: this, duration: Duration(milliseconds: 100), reverseDuration: Duration(milliseconds: 0)),
      update: () => setState(() {}),
      gunController: widget.gunController,
    );

    widget.bulletController.anim.initial(
      provider: this,
      bulletController: widget.bulletController,
      wheelSize: widget.gun.wheelSize,
      update: () => setState(() {}),
      gunController: widget.gunController
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        widget.bulletController.anim.render(),
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
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),

        Listener(
          onPointerDown: (details) {
            _whenGunStarted();
          },
          onPointerUp: (details) {
            _whenGunIsCanceled();
          },
          onPointerMove: (details) {

            if(_gunPosDX + details.delta.dx > 0.0 && _gunPosDX + details.delta.dx < _getScreenPaleWidth()) {
              widget.gunController.pos.newEl(_gunPosDX, _gunPosDX + details.delta.dx);

              if(AnimationStatus.forward != widget.gunController.anim.status()) {
                widget.gunController.anim.startAnim();
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
