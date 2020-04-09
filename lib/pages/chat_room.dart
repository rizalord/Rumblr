import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rumblr/components/chat_room_header.dart';
import 'package:rumblr/pages/home.dart';
import 'package:rumblr/pages/schedule_fight.dart';
import 'package:rumblr/pages/scheduled_fight.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class ChatRoom extends StatefulWidget {
  final String id, username, photo, opponentId;

  ChatRoom({this.id, this.username, this.photo, this.opponentId});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String id, username, photo, myId, opponentId;
  int totalFight;
  ScrollController _scrollController = ScrollController();

  List _listchat = [
    {
      "userId": 1,
      "message": "Bro, your face is pissing me off. Wanna throw down?",
    },
    {
      "userId": 2,
      "message": "Hell yeah bro, I'mma f*ck you up.",
    },
    {
      "userId": 1,
      "message": "Cool, meet me behind 5th Ave Deli parking lot. Tonight. 9PM.",
    },
    {
      "userId": 2,
      "message": "Done.",
    },
    {
      "userId": 2,
      "message": "I'm infront of you.",
    },
  ];
  bool showStatus = false;
  var _formKey = GlobalKey<FormState>();
  var _textController = TextEditingController();

  @override
  void initState() {
    this.id = widget.id;
    this.username = widget.username;
    this.photo = widget.photo;
    this.opponentId = widget.opponentId;

    Future.delayed(
        Duration(milliseconds: 0), () => this.getData(id, username, photo));
    super.initState();
  }

  void getData(id, username, photo) async {
    Map myData = await this._myData(); // {username:, uid: , photo:}

    Firestore.instance
        .collection('users')
        .document(opponentId)
        .snapshots()
        .listen((event) {
      setState(() {
        myId = myData['uid'];
        totalFight = event.data['totalFights'];
      });
    });
  }

  _myData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return {
      'username': prefs.getString('username'),
      'uid': prefs.getString('uid'),
      'photo': prefs.getString('photo'),
    };
  }

  void onSubmit(context) {
    if (_textController.text.trim().length > 0) {
      var time = DateTime.now().millisecondsSinceEpoch;
      print(time);
      Firestore.instance
          .collection('messages')
          .document(id)
          .collection(id)
          .document(time.toString())
          .setData({
        'message': _textController.text.trim().toString(),
        'senderId': myId,
        'time': time
      }).whenComplete(() {
        FocusScope.of(context).unfocus();
        _textController.text = '';
        _scrollController.animateTo(MediaQuery.of(context).size.height,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3F0A0A),
            Color(0xFF7D0101),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              ChatRoomHeader(
                callBack: () {
                  setState(() {
                    showStatus = !showStatus;
                  });
                },
                photo: photo,
                username: username,
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          TwoButtons(
                            id: id,
                            opponentId: opponentId,
                            photo: photo,
                            username: username,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: <Widget>[
                                  TextTips(),
                                  StreamBuilder(
                                    stream: Firestore.instance
                                        .collection('messages')
                                        .document(id)
                                        .collection(id)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        List<DocumentSnapshot> data =
                                            snapshot.data.documents;
                                        data = data
                                            .where((element) =>
                                                element.data['message'] != null)
                                            .toList();
                                        List anotherData = data.map((e) {
                                          if (e.data['senderId'] !=
                                              opponentId) {
                                            return SelfMessage(
                                                text: e.data['message']);
                                          } else {
                                            var index = data.indexOf(e);
                                            var newIndex = index == 0
                                                ? 0
                                                : data[index]['senderId'] ==
                                                        data[index - 1]
                                                            ['senderId']
                                                    ? 1
                                                    : 0;
                                            return OpponentMessage(
                                                index: newIndex,
                                                text: e.data['message']);
                                          }
                                        }).toList();

                                        return Column(
                                          children: anotherData,
                                        );
                                      } else {
                                        return SelfMessage(text: 'nice');
                                      }
                                    },
                                  )
                                  // ListView.builder(
                                  //   shrinkWrap: true,
                                  //   physics: NeverScrollableScrollPhysics(),
                                  //   itemCount: _listchat.length,
                                  //   itemBuilder: (context, index) {
                                  //     return _listchat[index]['userId'] == 1
                                  //         ? SelfMessage(
                                  //             text: _listchat[index]['message'])
                                  //         : OpponentMessage(
                                  //             index: _listchat[index]
                                  //                         ['userId'] ==
                                  //                     _listchat[index - 1]
                                  //                         ['userId']
                                  //                 ? 1
                                  //                 : 0,
                                  //             text: _listchat[index]['message'],
                                  //           );
                                  //   },
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 65,
                            // color: Colors.white.withOpacity(0.2),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Form(
                                    key: _formKey,
                                    child: Container(
                                      height: 45,
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(45),
                                          color: Colors.white),
                                      child: TextFormField(
                                        controller: _textController,
                                        textAlign: TextAlign.left,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        cursorColor: Colors.black,
                                        style: TextStyle(fontSize: 19),
                                        decoration: InputDecoration(
                                          hintText: 'Type a message',
                                          hintStyle: TextStyle(
                                              fontSize: 19,
                                              color: Colors.black
                                                  .withOpacity(0.2)),
                                          contentPadding: EdgeInsets.only(
                                              left: 15, right: 15, bottom: 4.5),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SendButton(onTap: this.onSubmit)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    showStatus == true
                        ? Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 20.0, sigmaY: 20.0),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.1),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          width: 100,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.grey
                                                    .withOpacity(0.7)),
                                          ),
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Text(
                                            'STATS',
                                            style: GoogleFonts.roboto(
                                                fontStyle: FontStyle.italic,
                                                color: Color(
                                                  0xFF430B0B,
                                                ),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 17),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              children: <Widget>[
                                                StatsItem(
                                                    text: 'Age: ',
                                                    value: 'N/A'),
                                                StatsItem(
                                                    text: 'Level: ',
                                                    value: 'Amateur'),
                                                StatsItem(
                                                    text: 'Total Fight: ',
                                                    value:
                                                        totalFight.toString()),
                                                StatsItem(
                                                    text: 'Last fight: ',
                                                    value: '-'),
                                                StatsItem(
                                                    text: 'Height/Weight: ',
                                                    value: '-/-'),
                                                StatsItem(
                                                    text: 'MMA Speciality: ',
                                                    value: '-'),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StatsItem extends StatelessWidget {
  final String text, value;

  const StatsItem({Key key, this.text, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.only(bottom: 13),
      child: Row(
        children: <Widget>[
          Text(
            text,
            style: GoogleFonts.roboto(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(.8),
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final Function onTap;

  const SendButton({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.8,
      onTap: () {
        onTap(context);
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          color: Colors.red.withOpacity(0.7),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.send,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}

class OpponentMessage extends StatelessWidget {
  final String text;
  final int index;

  const OpponentMessage({Key key, this.index, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            index == 0
                ? Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(width: 1.5, color: Colors.white),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        'https://pbs.twimg.com/profile_images/1057448315573362688/KHCCg0_K_400x400.jpg',
                      ),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.only(left: 10, right: 10),
                  ),
            Container(
              margin: EdgeInsets.only(right: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5),
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Text(
                text,
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 15.5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SelfMessage extends StatelessWidget {
  final String text;
  const SelfMessage({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 100),
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
              decoration: BoxDecoration(
                  color: Color(0xFF00B0FF),
                  borderRadius: BorderRadius.circular(15)),
              child: Text(
                text,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 15.5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TextTips extends StatelessWidget {
  const TextTips({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 7.5, right: 7.5),
      margin: EdgeInsets.only(bottom: 5),
      alignment: Alignment.center,
      child: Text(
        'Chat to heat up for a fight. Pro-tip: tell your match what you don\'t like about their picture.',
        style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontStyle: FontStyle.italic,
            fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TwoButtons extends StatelessWidget {
  final String id, opponentId, username, photo;
  const TwoButtons(
      {Key key, this.id, this.opponentId, this.username, this.photo})
      : super(key: key);

  void out(context) {
    Firestore.instance
        .collection('messages')
        .document(id)
        .snapshots()
        .listen((event) {
      var sId = event.data['scheduledId'];
      Firestore.instance
          .collection('schedule')
          .document(sId)
          .delete()
          .whenComplete(() {
        Firestore.instance
            .collection('messages')
            .document(id)
            .delete()
            .whenComplete(() {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
            stream: Firestore.instance
                .collection('messages')
                .document(id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map data = snapshot.data.data;

                if (data['scheduled'] == false) {
                  return SchedulingBtn(data: {
                    'opponentId': opponentId,
                    'username': username,
                    'photo': photo,
                    'messageId': id
                  });
                } else {
                  return ScheduledBtn(id: data['scheduledId']);
                }
              }
              return Expanded(child: Container());
            },
          ),
          TouchableOpacity(
            activeOpacity: 0.7,
            onTap: () {
              this.out(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2.2,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white.withOpacity(0.9), width: 2),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                'OUT',
                style: GoogleFonts.roboto(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledBtn extends StatelessWidget {
  final String id;

  const ScheduledBtn({Key key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.7,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ScheduledFight(id: id)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.2,
        height: 40,
        margin: EdgeInsets.only(right: 7.5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
            borderRadius: BorderRadius.circular(5)),
        child: Text(
          'SEE SCHEDULE',
          style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

class SchedulingBtn extends StatelessWidget {
  final Map data;
  SchedulingBtn({this.data});

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.7,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ScheduleFight(data: data)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.2,
        height: 40,
        margin: EdgeInsets.only(right: 7.5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
            borderRadius: BorderRadius.circular(5)),
        child: Text(
          'SCHEDULE FIGHT',
          style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
