import 'package:flutter/material.dart';
import 'package:rumblr/components/chat_header.dart';
import 'package:rumblr/components/logo_header.dart';
import 'package:rumblr/components/map_header.dart';

class HomeHeader extends StatelessWidget {
  final Function setView;

  const HomeHeader({
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
          MapHeader(setView : this.setView),
          LogoHeader(),
          ChatHeader(),
        ],
      ),
    );
  }
}

