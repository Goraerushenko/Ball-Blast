import 'dart:async';

import 'package:ball_blast/models/bulletController.dart';
import 'package:flutter/material.dart';
import '../models/gunController.dart';
import '../models/gunStencil.dart';

class GameStatus {
  final bool active = true;
  final bool menu = false;
}

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
    gunController.power = 2;
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

  double _xPosOfGun = 0.0;
  Offset _barrelPos;
  Offset _framePos;
  Timer _shootTime;
  bool _canceled = false;
  List<Animation<Offset>> _bulletAnimList = [];
  List<AnimationController> _bulletContList = [];
  AnimationController _shotCont;
  AnimationController _flowCont;
  Animation<double> _flowAnim;
  Animation<double> _shotAnim;
  Animation<double> _wheelAnim;
  AnimationController _wheelCont;

  Animation<double> _stencilAnimFlow ({@required double begin, @required double end, @required Function addListener}) {
    _flowCont = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    return  Tween(
        begin: begin,
        end: end
    ).animate(CurvedAnimation(
        curve: Curves.linear,
        parent: _flowCont
    ))..addListener(() => setState(() {
      if(_flowAnim.status == AnimationStatus.completed ) {
        if(widget.gunController.gunPos.length != 0) {
          addListener();
        }
      }
    }));
  }

  Offset _getGunPos () {
    RenderBox box = widget.gunController.gunKey.currentContext.findRenderObject();
    Offset curPos =  box.localToGlobal(Offset.zero) ?? Offset(0, 0);
    int power = widget.gunController.power;
    curPos = Offset(curPos.dx -  ((power*5 + power-1) / 2), curPos.dy);
    return curPos;
  }

  double _getScreenPaleWidth () {
    final double gunWidth =  (widget.gun.wheelSize.width * 2 + widget.gun.wheelSize.width / 2);
    return MediaQuery.of(context).size.width - gunWidth ;
  }

  void _whenGunStarted () {
    _canceled = false;
    _shotCont.forward();
    _shootTime = Timer.periodic(Duration(milliseconds: 1000 ~/ widget.gunController.shootSpeed), (timer) {
      _bulletContList.add(AnimationController(vsync: this, duration: Duration(milliseconds: 1000)));
      _bulletAnimList.add(
          Tween(
              begin: _getGunPos(),
              end: Offset(_getGunPos().dx, -10)
          ).animate(
              _bulletContList[_bulletContList.length-1]
          )..addListener(
                  () => setState(() {
                if(_bulletAnimList[0].status == AnimationStatus.completed) {
                  _bulletAnimList.removeAt(0);
                  _bulletContList.removeAt(0);
                  widget.bulletController.list.removeAt(0);
                  widget.bulletController.reRender();
                }
              })
          )
      );
      _bulletContList[_bulletContList.length-1].forward();
      widget.bulletController.list.add(
          BulletRow(
              index: _bulletContList.length-1,
              count: widget.gunController.power
          )
      );
    });
  }

  void _createSecondAnimation ({@required double begin, @required double end}) {
    _flowAnim = _stencilAnimFlow(
        begin: begin,
        end: end,
        addListener: () {
          Map<String, double> firstEl = widget.gunController.posListClipper();
          _createSecondAnimation(
              begin: firstEl['previos'],
              end: firstEl['now']
          );
          _flowCont.forward();
        }
    );
  }

  void _createFirstFlowAnim () {
    Map<String, double> clipped = widget.gunController.posListClipper();
    _flowAnim = _stencilAnimFlow(
        begin: clipped['previos'],
        end: clipped['now'],
        addListener: () {
          clipped = widget.gunController.posListClipper();
          Map<String, double> firstEl = clipped;
          _createSecondAnimation(begin: firstEl['previos'], end: firstEl['now']);
          _flowCont.forward();
        }
    );
    _flowCont.forward();
  }

  void _whenGunIsCanceled () {
    _canceled = true;
    _shootTime.cancel();
  }

  void _createAnimations () {
    _shotCont = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _shotAnim = Tween(
        begin: 0.0,
        end: widget.gun.wheelSize.width * 0.25
    ).animate(_shotCont)
      ..addListener(
              () => setState(
                  () {
                if (_shotAnim.status == AnimationStatus.dismissed) {
                  if (!_canceled) {
                    _shotCont.forward();
                  }
                } else if (_shotAnim.status == AnimationStatus.completed){
                  _shotCont.reverse();
                }
              }
          )
      );

    _flowCont = AnimationController(vsync: this, duration: Duration(seconds: 1));

    _wheelCont = AnimationController(vsync: this, duration: Duration(seconds: 10));

    _wheelAnim = Tween(
        begin: 0.0,
        end: 20.0
    ).animate(_wheelCont)..addListener(() => setState(() { if(_wheelAnim.status == AnimationStatus.completed) _wheelCont.reverse();}));

    _wheelCont.forward();
    _flowAnim = Tween(begin: 0.0, end: 0.0).animate(_flowCont);
  }

  Widget _bulletsRender () => Stack(
    children: widget.bulletController.list.map((el) => Row(
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

    _createAnimations ();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(
                _flowAnim.value < 0 ?
                  0.0 :
                  (_flowAnim.value > _getScreenPaleWidth() ?
                    _getScreenPaleWidth() :
                    _flowAnim.value),
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
                  offset: Offset(_barrelPos.dx, _barrelPos.dy + _shotAnim.value),
                  child: widget.gun.barrel(),
                ),

                Row(
                  children: <Widget>[
                    Transform.rotate(
                      angle: _flowAnim.value * 0.05,
                      child: widget.gun.wheel(),
                    ),
                    SizedBox(width: widget.gun.wheelSize.width / 2,),
                    Transform.rotate(
                      angle: _flowAnim.value * 0.05,
                      child: widget.gun.wheel(),
                    ),
                  ],
                ),

                Transform.translate(
                  offset: Offset(widget.gun.wheelSize.width + widget.gun.wheelSize.width / 4, -widget.gun.bodySize.height),
                  child: Container(
                    key: widget.gunController.gunKey,
                    height: 1,
                    width: 1,
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
        _bulletsRender(),
        Listener(
          onPointerDown: (details) {
            _whenGunStarted();
          },
          onPointerUp: (details) {
            _whenGunIsCanceled();
          },
          onPointerMove: (details) {

            if(_xPosOfGun + details.delta.dx > 0.0 && _xPosOfGun + details.delta.dx < _getScreenPaleWidth()) {
              widget.gunController.gunPos.add({
                'previos': _xPosOfGun,
                'now': _xPosOfGun + details.delta.dx
              });

              if(AnimationStatus.forward != _flowAnim.status) {
                _createFirstFlowAnim();
              }
              _xPosOfGun +=  details.delta.dx;
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
