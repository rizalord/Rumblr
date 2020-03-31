import 'package:flutter/material.dart';
import './home_main.dart';
import './home_map.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var initialPage = 1;
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: initialPage, keepPage: false);
    super.initState();
  }

  void setView(index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          pageSnapping: true,
          children: <Widget>[
            HomeMap(setView: this.setView),
            HomeMain(setView: this.setView),
          ],
        ),
      ),
    );
  }
}
