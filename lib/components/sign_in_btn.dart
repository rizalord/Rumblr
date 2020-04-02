import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rumblr/pages/form_register_first.dart';
import 'package:rumblr/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class SignInButton extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void _signInHandler(context) async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    // Shared Pref
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', user.uid.toString()); // SET USERID
    prefs.setString('name', user.displayName.toString()); // SET NAME

    // FireStore
    if (authResult.additionalUserInfo.isNewUser) {
      await Firestore.instance.collection('users').document(user.uid).setData({
        'uid': user.uid.toString(),
        'name': user.displayName.toString(),
      });

      // Navigate to Register Form
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => FormRegisterFirst()));
    } else {
      // Check Photo
      await Firestore.instance
          .collection('users')
          .where('uid', isEqualTo: user.uid.toString())
          .snapshots()
          .listen((QuerySnapshot event) async {
        if (event.documents[0]['photo'] == null) {
          // No Photo
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => FormRegisterFirst()));
        } else {
          // With Photo
          var tmp = await Geolocator()
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          prefs.setString('photo', event.documents[0]['photo']);
          prefs.setString('username', event.documents[0]['username']);
          prefs.setInt('totalFights', 0);
          prefs.setDouble('lat', tmp.latitude);
          prefs.setDouble('lon', tmp.longitude);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.9,
      onTap: () {
        _signInHandler(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 55,
              height: 55,
              padding: EdgeInsets.all(15),
              child: Image.asset('assets/img/google_logo.png'),
            ),
            Container(
              width: (MediaQuery.of(context).size.width * 0.85) - 88,
              height: 55,
              alignment: Alignment.center,
              child: Text(
                'LOGIN WITH GOOGLE',
                style: GoogleFonts.roboto(
                    color: Color(0xFF707070),
                    fontSize: 16,
                    fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }
}
