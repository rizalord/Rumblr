import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rumblr/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FormRegisterFirst extends StatefulWidget {
  @override
  _FormRegisterFirstState createState() => _FormRegisterFirstState();
}

class _FormRegisterFirstState extends State<FormRegisterFirst> {
  final _formKey = GlobalKey<FormState>();
  File _imagePath;

  void _nextHandler(context) async {
    // validate photo
    if (_imagePath == null) {
      Fluttertoast.showToast(
          msg: 'Pick your photo first!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red.withOpacity(0.5),
          textColor: Colors.white,
          fontSize: 16.0,
          gravity: ToastGravity.BOTTOM);
    }

    if (_formKey.currentState.validate() && _imagePath != null) {
      // validate success
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uid = prefs.getString('uid');
      StorageReference ref =
          FirebaseStorage.instance.ref().child('images').child(uid + '.jpg');
      StorageUploadTask uploadTask = ref.putFile(_imagePath);

      // String url = await (await uploadTask.onComplete).ref.getDownloadURL();

      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  Future _getImage() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: MediaQuery.of(context).size.width * .6,
      maxWidth: MediaQuery.of(context).size.width * .6,
    );

    setState(() {
      _imagePath = image == null ? _imagePath : image;
    });

  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  width: MediaQuery.of(context).size.width * .6,
                  height: MediaQuery.of(context).size.width * .6,
                  margin: EdgeInsets.only(bottom: 40),
                  // color: Colors.white,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * .6),
                          // color: Colors.pink,
                        ),
                        child: _imagePath == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width * .6),
                                child: Image.asset(
                                  'assets/img/default_profile.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width * .6),
                                child: Image.file(
                                  _imagePath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Positioned(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(40),
                            color: Colors.red.withOpacity(0.8),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        right: 14,
                        bottom: 14,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 3,
                  bottom: 3,
                ),
                margin: EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.7)),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Please enter your username';
                      else if (value.length <= 5)
                        return 'Your username is too short';

                      return null;
                    },
                    cursorColor: Colors.white.withOpacity(0.8),
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        // labelText: 'Username',
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 2),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 2),
                        ),
                        contentPadding: EdgeInsets.only(left: 5, right: 5)),
                  ),
                ),
              ),
              TouchableOpacity(
                activeOpacity: 0.7,
                onTap:() { _nextHandler(context); },
                child: Container(
                  width: 100,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(7)),
                  child: Text(
                    'NEXT',
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
