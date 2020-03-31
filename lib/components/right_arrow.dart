import 'package:flutter/material.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class RightArrow extends StatelessWidget {
  final Function setView;

  const RightArrow({Key key, this.setView}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.8,
      onTap: () {
        setView(1);
      },
      child: Container(
        width: 65,
        height: 65,
        alignment: Alignment.center,
        child: Icon(
          Icons.chevron_right,
          size: 55,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
