import 'dart:ffi';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:rumblr/components/cards/detail_card.dart';
import 'package:rumblr/components/home_header.dart';
import 'package:rumblr/pages/chat_room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class HomeMain extends StatefulWidget {
  final Function setView;
  HomeMain({this.setView});

  @override
  State<StatefulWidget> createState() => HomeMainState();
}

class HomeMainState extends State<HomeMain> {
  var _listData = [];
  bool showFight = false;
  double showFightOpacity = 0.0;
  String _enemyUsername, _enemyImage, _myImage, peerId;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () {
      _getOpponents();
    });
    super.initState();
  }

  void _getOpponents() async {
    var myPos = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // Get Nearest Opponent
    _getNearestLocation(myPos.latitude, myPos.longitude, 1);
  }

  void _getNearestLocation(latitude, longitude, distance) async {
    // ~1 mile of lat and lon in degrees
    var lat = 0.0144927536231884;
    var lon = 0.0181818181818182;

    var lowerLat = latitude - (lat * distance);
    var lowerLon = longitude - (lon * distance);

    var greaterLat = latitude + (lat * distance);
    var greaterLon = longitude + (lon * distance);

    var lesserGeopoint = GeoPoint(lowerLat, lowerLon);
    var greaterGeopoint = GeoPoint(greaterLat, greaterLon);

    SharedPreferences pref = await SharedPreferences.getInstance();
    var uid = pref.getString('uid');

    Firestore.instance
        .collection("users")
        .where('geo',
            isGreaterThanOrEqualTo: lesserGeopoint,
            isLessThanOrEqualTo: greaterGeopoint)
        .limit(4)
        .snapshots()
        .listen((QuerySnapshot event) {
      List<DocumentSnapshot> tmp = [];
      event.documents.forEach((element) {
        if (element['uid'] != uid) {
          setState(() {
            tmp.add(element);
          });
        }
      });

      if (tmp.length <= 3) {
        tmp.forEach((DocumentSnapshot element) {
          setState(() {
            _listData.add(element);
          });
        });
      } else {
        for (var i = 0; i < 3; i++) {
          if (tmp[i]['uid'] != uid) {
            setState(() {
              _listData.add(event.documents[i]);
            });
          }
        }
      }

      // no opponent
      if (event.documents.length == 0) {
        _getAnyOpponent();
      }
    });
  }

  _getAnyOpponent() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var uid = pref.getString('uid');

    Firestore.instance.collection('users').limit(3).snapshots().listen((event) {
      setState(() {
        if (event.documents.length <= 3) {
          event.documents
              .where((item) => item['uid'] != uid)
              .forEach((DocumentSnapshot element) {
            _listData.add(element);
          });
        } else {
          for (var i = 0; i < 3; i++) {
            if (event.documents[i]['uid'] != uid) {
              _listData.add(event.documents[i]);
            }
          }
        }
      });
    });
  }

  void _passOpponent() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var uid = pref.getString('uid');

    setState(() {
      if (_listData.length != 0) {
        Firestore.instance
            .collection('users')
            .orderBy('uid')
            .startAfter([_listData.last['uid']])
            .limit(2)
            .snapshots()
            .listen((QuerySnapshot snapshot) async {
              // print(snapshot.documents.length);
              List<DocumentSnapshot> listing = [];
              snapshot.documents.forEach((element) {
                if (element['uid'] != uid) {
                  listing.add(element);
                }
              });

              _listData.removeAt(0);

              try {
                listing.elementAt(0) != null
                    ? _listData.add(listing.elementAt(0))
                    : null;
              } catch (e) {
                //
              }

              // no opponent
              if (snapshot.documents.length == 0) {
                // var myPos = await Geolocator()
                //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                // _getNearestLocation(myPos.latitude, myPos.longitude, 1);
              }
            });
      }
    });
  }

  void _setFight() async {
    if (_listData.length != 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uid = prefs.getString('uid');
      var photo = prefs.getString('photo');

      _setFirebaseChat();

      setState(() {
        showFight = true;
        _enemyImage = _listData.first['photo'];
        _myImage = photo;
        _enemyUsername = _listData.first['username'];
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            showFightOpacity = 1.0;
          });
        });
      });
    }
  }

  void getChat() {
    var id = this.peerId;
    var username = _listData.first['username'];
    var photo = _listData.first['photo'];
    var opponentId = _listData.first['uid'];

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatRoom(
                  id: id,
                  opponentId: opponentId,
                  photo: photo,
                  username: username,
                )));
    setState(() {
      showFightOpacity = 0.0;
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          showFight = false;
        });
      });
    });
  }

  void _setFirebaseChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String enemyId = _listData.first['uid'];
    String myId = prefs.getString('uid');
    String myPhoto = prefs.getString('photo');
    String myUsername = prefs.getString('username');

    var peerId = enemyId.substring(0, 5) + myId.substring(0, 5);
    this.peerId = peerId;
    var nowTime = DateTime.now().millisecondsSinceEpoch;

    Firestore.instance
        .collection('messages')
        .document(peerId)
        .collection(peerId)
        .document(nowTime.toString())
        .setData({'time': nowTime, 'message': null, 'senderId': myId});

    Firestore.instance.collection('messages').document(peerId).setData(
      {
        'id1': myId,
        'id2': enemyId,
        'photo1': myPhoto,
        'photo2': _listData.first['photo'],
        'username1': myUsername,
        'username2': _listData.first['username'],
        'scheduled': false,
        'scheduledId': null
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.1),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3F0A0A), Color(0xFF7C0000)],
            ),
          ),
          child: Column(
            children: <Widget>[
              HomeHeader(setView: widget.setView),
              Flexible(
                child: _listData.length != 0
                    ? Stack(
                        children: _listData
                            .map((item) => AnimatedPositioned(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  top: 8 *
                                      (_listData.indexOf(item) + 1).toDouble(),
                                  left: 8 *
                                      (_listData.indexOf(item) + 1).toDouble(),
                                  right: 8 *
                                      (_listData.indexOf(item) + 1).toDouble(),
                                  child: DetailCard(
                                      name: item['username'],
                                      stars: item['totalFights'] / 5 == 0
                                          ? 1
                                          : (item['totalFights'].toDouble() / 5)
                                                      .floor() >
                                                  5
                                              ? 5
                                              : (item['totalFights']
                                                          .toDouble() /
                                                      5)
                                                  .floor(),
                                      uri: item['photo']),
                                ))
                            .toList()
                            .reversed
                            .toList(),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.width * 0.95,
                        child: Center(
                          child: Text(
                            'No Opponent Yet',
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 27,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
              ),
              TouchableOpacity(
                activeOpacity: 0.7,
                onTap: () {
                  _setFight();
                },
                child: Container(
                  width: 120,
                  height: 62,
                  margin: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    'FIGHT',
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              TouchableOpacity(
                activeOpacity: 0.7,
                onTap: _passOpponent,
                child: Container(
                  width: 80,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(0.6), width: 2),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    'PASS',
                    style: GoogleFonts.roboto(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              )
            ],
          ),
        ),
        showFight == true
            ? Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    opacity: showFightOpacity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF3F0A0A).withOpacity(0.7),
                            Color(0xFF7C0000).withOpacity(0.7)
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'FIGHT ON',
                            style: GoogleFonts.sedgwickAve(
                              fontSize: 60,
                              color: Colors.white,
                            ),
                          ),
                          PhotoVersusCard(
                              enemyImage: _enemyImage, myImage: _myImage),
                          TextForBattle(enemyUsername: this._enemyUsername),
                          BtnChat(callback: this.getChat),
                          TouchableOpacity(
                            activeOpacity: 0.8,
                            onTap: () {
                              setState(() {
                                showFightOpacity = 0.0;
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    showFight = false;
                                  });
                                });
                              });
                            },
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(45)),
                              child: Icon(
                                Icons.close,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}

class BtnChat extends StatelessWidget {
  final Function callback;

  const BtnChat({Key key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.7,
      onTap: () {
        callback();
      },
      child: Container(
        width: 120,
        height: 62,
        margin: EdgeInsets.only(bottom: 30),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(5)),
        child: Text(
          'CHAT',
          style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

class TextForBattle extends StatelessWidget {
  final String enemyUsername;

  const TextForBattle({Key key, this.enemyUsername}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 50.22,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        // height: MediaQuery.of(context).size.width * 0.5,
        margin: EdgeInsets.only(bottom: 30),
        // color: Colors.white,
        child: Text(
          'You and ${enemyUsername} both want to throw down. Start chatting to arrange a time and location, then broadcast the final fight details to draw a crowd.',
          style: GoogleFonts.roboto(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              fontSize: 17,
              height: 1.5),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class PhotoVersusCard extends StatelessWidget {
  final String myImage, enemyImage;
  const PhotoVersusCard({Key key, this.myImage, this.enemyImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.width * 0.5,
      margin: EdgeInsets.only(top: 12, bottom: 12),
      // color: Colors.white,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: (MediaQuery.of(context).size.width * 0.8) / 2.25,
                height: (MediaQuery.of(context).size.width * 0.8) / 2.25,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  border: Border.all(
                    width: 2.5,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.8),
                  child:
                      CachedNetworkImage(imageUrl: myImage, fit: BoxFit.cover),
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width * 0.8) / 2.25,
                height: (MediaQuery.of(context).size.width * 0.8) / 2.25,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  border: Border.all(
                    width: 2.5,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.8),
                  child: CachedNetworkImage(
                      imageUrl: enemyImage, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          Positioned(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.5,
              // color: Colors.red.withOpacity(0.2),
              alignment: Alignment.center,
              child: IconShadowWidget(
                Icon(
                  Icons.flash_on,
                  size: 100,
                  color: Colors.white,
                ),
                shadowColor: Colors.black.withOpacity(0.4),
              ),
            ),
          )
        ],
      ),
    );
  }
}
