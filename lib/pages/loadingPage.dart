import 'package:ball_blast/models/gunStencil.dart';
import 'package:flutter/material.dart';

import 'gamePage.dart';

class LoadingPage extends StatefulWidget {

  LoadingPage({
    Key key,
    this.size
  }) : super(key: key);

  final Size size;

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with TickerProviderStateMixin{
  Animation<double> _loadAnim;
  AnimationController _loadCont;
  GlobalKey _wheelKey = GlobalKey();
  GlobalKey _bodyKey = GlobalKey();
  List<Size> _sizes = [];

  @override
  void initState() {
    _loadCont = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _loadAnim = Tween (
      begin: 0.0,
      end: widget.size.width - 100
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: _loadCont
      )
    )..addListener(
        () => setState(() {
          if(_loadCont.status == AnimationStatus.completed) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GamePage(
                wheelSize: _sizes[0],
                bodySize:  _sizes[1]
              ))
            );
          }
        })
    );
    Future.delayed(Duration(milliseconds: 50), () {
      _sizes = [_wheelKey.currentContext.size, _bodyKey.currentContext.size];
      _loadCont.forward();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.blue,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      height: 20,
                      width: widget.size.width - 100,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 20,
                          width: _loadAnim.value,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20.0))
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${(_loadAnim.value / (widget.size.width - 100) * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0
                      ),
                    )
                  ],
                ),
              ),
            )
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              key: _wheelKey,
              child: GunStencil(
                wheelSize: Size(0, 0),
                bodySize:  Size(0, 0),
              ).wheel(
                opacity: 0.0
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              key: _bodyKey,
              child: GunStencil(
                wheelSize: Size(0, 0),
                bodySize:  Size(0, 0),
              ).barrel(
                  opacity: 0.0
              ),
            ),
          ),
        ],
      ),
    );
  }
}
