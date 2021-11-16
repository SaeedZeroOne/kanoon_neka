import 'package:flutter/material.dart';
import 'homepage.dart' as hp;

void main() {
  runApp(Kanoon());
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class Kanoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'IranSans',
        primarySwatch: Colors.blue,
      ),
      home: hp.HomePage(),
      scrollBehavior: NoGlowBehavior(),
    );
  }
}
