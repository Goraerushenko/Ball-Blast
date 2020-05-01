import 'package:ball_blast/pages/loadingPage.dart';
import 'package:flutter/material.dart';

void runGame () => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Helper(),
    );
  }
}

class Helper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoadingPage(
        size: MediaQuery.of(context).size
    );
  }
}
