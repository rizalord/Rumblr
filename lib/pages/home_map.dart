import 'package:flutter/material.dart';
import 'package:rumblr/components/map_left_header.dart';
import './../components/maps.dart';

class HomeMap extends StatefulWidget {

  final Function setView;
  HomeMap({this.setView});

  @override
  State<StatefulWidget> createState() => HomeMapState();
}

class HomeMapState extends State<HomeMap> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3F0A0A), Color(0xFF7C0000)],
        ),
      ),
      child: Column(
        children: <Widget>[
          MapLeft(setView : widget.setView),
          Maps()
        ],
      ),
    );
  }
}
