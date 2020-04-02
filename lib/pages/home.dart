import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    // Future.delayed(Duration(milliseconds: 0) , () async{
    //   await FirebaseAuth.instance.signOut();
    //   await GoogleSignIn().signOut();
    //   SharedPreferences preferences = await SharedPreferences.getInstance();
    //   preferences.clear();

    // });
    
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
