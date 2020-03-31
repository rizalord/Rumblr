import 'package:flutter/material.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'right_arrow.dart';

import 'logo_header.dart';

class MapRight extends StatelessWidget {
  final Function setView;
  const MapRight({Key key, this.setView}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TouchableOpacity(
            activeOpacity: 0.8,
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 65,
              height: 65,
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_left,
                size: 55,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          LogoHeader(),
          Container(
            width: 65,
            height: 65,
          ),
        ],
      ),
    );
  }
}
