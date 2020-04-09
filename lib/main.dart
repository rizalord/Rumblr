import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rumblr/components/text_quote.dart';
import 'package:rumblr/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './components/logo_app.dart';
import './components/sign_in_btn.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContexcontext) {
    return MaterialApp(
      home: Authentication(),
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFF420A0A)),
    );
  }
}

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool _showQuoteAndButton = false;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('uid') != null) {
        if (prefs.getString('photo') != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        } else {
          setState(() {
            _showQuoteAndButton = true;
          });   
        }
      } else {
        setState(() {
          _showQuoteAndButton = true;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3F0A0A), Color(0xFF7C0000)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LogoApp(),
                _showQuoteAndButton == true ? TextQuote() : Container(),
                _showQuoteAndButton == true ? SignInButton() : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
