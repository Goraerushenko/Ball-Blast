import 'package:ball_blast/widgets/Game.dart';
import 'package:ball_blast/models/gunStencil.dart';
import 'package:flutter/material.dart';


class GamePage extends StatefulWidget {

  GamePage({
    Key key,
    this.wheelSize,
    this.bodySize,
  }) : super(key: key);

  final Size wheelSize;

  final Size bodySize;

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.of(context).pop()),
      body: Game(
        size: MediaQuery.of(context).size,
        gun: GunStencil(
          wheelSize: widget.wheelSize,
          bodySize:  widget.bodySize,
        ),
        menu: Container(),
        background: Container(
          color: Colors.grey,
        ),
      )
    );
  }
}




