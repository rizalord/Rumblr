import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class MapHeader extends StatelessWidget {
  final Function setView;

  const MapHeader({
    Key key,
    this.setView
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.8,
      onTap: (){
        this.setView(0);
      },
      child: Container(
        width: 65,
        height: 65,
        alignment: Alignment.center,
        child: FaIcon(
          FontAwesomeIcons.mapMarkedAlt,
          size: 35,
          color: Color(0xFFA08585),
        ),
      ),
    );
  }
}
