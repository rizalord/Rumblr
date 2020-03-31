import 'package:flutter/material.dart';

class LogoApp extends StatelessWidget {
  const LogoApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 70,
      margin: EdgeInsets.only(top : 0),
      // color: Colors.white,
      child: Image.asset(
        'assets/img/rumblr.png',
        fit: BoxFit.fill,
      ),
    );
  }
}
