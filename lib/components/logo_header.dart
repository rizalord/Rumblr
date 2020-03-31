import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65 * 2.0,
      height: 65,
      // color: Colors.white,
      child: Image.asset(
        'assets/img/rumblr.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

