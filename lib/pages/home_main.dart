import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:rumblr/components/cards/detail_card.dart';
import 'package:rumblr/components/home_header.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class HomeMain extends StatefulWidget {
  final Function setView;
  HomeMain({this.setView});

  @override
  State<StatefulWidget> createState() => HomeMainState();
}

class HomeMainState extends State<HomeMain> {
  var _listData = [
    {
      "uri":
          'https://i.pinimg.com/originals/54/13/34/541334f83463f82e29bc59300de0fe27.jpg',
      "name": 'mattyice67',
      "stars": 2,
      "visible": true
    },
    {
      "uri":
          'https://pbs.twimg.com/profile_images/1079976263157248000/HFfW_o61_400x400.jpg',
      "name": 'omarin712',
      "stars": 3,
      "visible": true
    },
    {
      "uri":
          'https://m.ayobandung.com/images-bandung/post/articles/2018/11/09/40331/cecep.jpg',
      "name": 'cecepgans45',
      "stars": 4,
      "visible": true
    },
  ];

  bool showFight = false;
  double showFightOpacity = 0.0;

  void _passOpponent() {
    setState(() {
      var tmp = _listData.first;
      _listData.removeAt(0);
      _listData.add(tmp);
    });
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
                child: Stack(
                  children: _listData
                      .map((item) => AnimatedPositioned(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                            top: 8 * (_listData.indexOf(item) + 1).toDouble(),
                            left: 8 * (_listData.indexOf(item) + 1).toDouble(),
                            right: 8 * (_listData.indexOf(item) + 1).toDouble(),
                            child: DetailCard(
                                name: item['name'],
                                stars: item['stars'],
                                uri: item['uri']),
                          ))
                      .toList()
                      .reversed
                      .toList(),
                ),
              ),
              TouchableOpacity(
                activeOpacity: 0.7,
                onTap: () {
                  setState(() {
                    showFight = true;
                    Future.delayed(Duration(milliseconds: 500), () {
                      setState(() {
                        showFightOpacity = 1.0;
                      });
                    });
                  });
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
                          PhotoVersusCard(),
                          TextForBattle(),
                          BtnChat(),
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
  const BtnChat({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.7,
      onTap: () {},
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
  const TextForBattle({
    Key key,
  }) : super(key: key);

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
          'You and mattyice67 both want to throw down. Start chatting to arrange a time and location, then broadcast the final fight details to draw a crowd.',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            fontSize: 17,
            height: 1.5
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class PhotoVersusCard extends StatelessWidget {
  const PhotoVersusCard({
    Key key,
  }) : super(key: key);

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
                  child: Image.network(
                    'https://pbs.twimg.com/profile_images/1138535538208718849/hViVs-Vi_400x400.jpg',
                    fit: BoxFit.cover,
                  ),
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
                  child: Image.network(
                    'https://i1.sndcdn.com/avatars-000604045011-842orv-t200x200.jpg',
                    fit: BoxFit.cover,
                  ),
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
