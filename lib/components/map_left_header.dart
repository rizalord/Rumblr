import 'package:flutter/material.dart';
import 'right_arrow.dart';

import 'logo_header.dart';

class MapLeft extends StatelessWidget {
  final Function setView;
  const MapLeft({
    Key key,
    this.setView
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 65,
            height: 65,
          ),
          LogoHeader(),
          RightArrow(setView : this.setView),
        ],
      ),
    );
  }
}
