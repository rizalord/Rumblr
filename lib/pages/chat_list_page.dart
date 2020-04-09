import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rumblr/pages/chat_room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../components/map_right_header.dart';

class ChatList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatListState();
}

class ChatListState extends State<ChatList> {
  List _data = [];
  StreamSubscription<QuerySnapshot> subOne;
  StreamSubscription<QuerySnapshot> subTwo;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () {
      _getChatContact();
    });
    super.initState();
  }

  void _getChatContact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var myId = prefs.getString('uid');

    subOne = Firestore.instance
        .collection('messages')
        .where('id1', isEqualTo: myId)
        .snapshots()
        .listen((event) {
      if (event.documents.length > 0) {
        // found
        event.documents.forEach((element) {
          var docId = element['id2'].toString().substring(0, 5) +
              element['id1'].toString().substring(0, 5);
          StreamSubscription<QuerySnapshot> subs1 = Firestore.instance
              .collection('messages')
              .document(docId)
              .collection(docId)
              .orderBy('time', descending: true)
              .limit(1)
              .snapshots()
              .listen((eventTwo) {
            if (this.mounted) {
              setState(() {
                if (_data.indexOf({
                      'id': element['id1'],
                      'photo': element['photo1'],
                      'username': element['username1'],
                      'message': eventTwo.documents[0].data['message'],
                      'chatId': docId,
                      'time' : eventTwo.documents[0].data['time']
                    }) ==
                    -1) {
                  _data.add({
                    'id': element['id2'],
                    'photo': element['photo2'],
                    'username': element['username2'],
                    'message': eventTwo.documents[0].data['message'],
                    'chatId': docId,
                    'time' : eventTwo.documents[0].data['time']
                  });
                }
              });
            }
          });

          Future.delayed(Duration(seconds: 1), () {
            subs1.cancel();
          });
        });
      }
    });

    Future.delayed(Duration(seconds: 1), () {
      subOne.cancel();
    });

    // Second Part
    subTwo = Firestore.instance
        .collection('messages')
        .where('id2', isEqualTo: myId)
        .snapshots()
        .listen((event) {
      if (event.documents.length > 0) {
        // found
        event.documents.forEach((element) {
          var docId = element['id2'].toString().substring(0, 5) +
              element['id1'].toString().substring(0, 5);
          StreamSubscription<QuerySnapshot> subs2 = Firestore.instance
              .collection('messages')
              .document(docId)
              .collection(docId)
              .orderBy('time', descending: true)
              .limit(1)
              .snapshots()
              .listen((eventTwo) {
            if (this.mounted) {
              setState(() {
                if (_data.indexOf({
                      'id': element['id1'],
                      'photo': element['photo1'],
                      'username': element['username1'],
                      'message': eventTwo.documents[0].data['message'],
                      'chatId': docId
                    }) ==
                    -1) {
                  _data.add({
                    'id': element['id1'],
                    'photo': element['photo1'],
                    'username': element['username1'],
                    'message': eventTwo.documents[0].data['message'],
                    'chatId': docId
                  });
                }
              });
            }
          });

          Future.delayed(Duration(seconds: 1), () {
            subs2.cancel();
          });
        });
      }
    });

    Future.delayed(Duration(seconds: 1), () {
      subTwo.cancel();
    });
  }

  void dismissChat(id){
    Firestore.instance.collection('messages').document(id).delete().whenComplete(() {
      setState(() {
        _data = _data.where((element) => element['chatId'] != id).toList();
      });
    });
    
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
            Color(0xFF3F0A0A),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              MapRight(),
              Expanded(
                child: Container(
                  child: _data.length > 0
                      ? ListView.builder(
                          itemCount: _data.length,
                          itemBuilder: (context, index) => ChatCard(
                            photo: _data[index]['photo'],
                            username: _data[index]['username'],
                            id: _data[index]['chatId'],
                            opponentId: _data[index]['id'],
                            message: _data[index]['message'],
                            time : _data[index]['time'],
                            callback: this.dismissChat,
                          ),
                        )
                      : Center(
                          child: Text(
                            'No Opponents yet.',
                            style: GoogleFonts.roboto(
                                fontSize: 17,
                                color: Colors.white,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final String photo, username, id, message, opponentId;
  final int time;
  final Function callback;
  const ChatCard(
      {Key key,
      this.photo,
      this.username,
      this.id,
      this.message,
      this.opponentId,
      this.time,
      this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (DismissDirection direction){
        callback(id);
      },
      background: Container(
        color: Colors.red.withOpacity(0.4),
        child: Center(
          child: Text(
            'Pussy Out',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic),
          ),
        ),
      ),
      key: Key(id),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF68453F).withOpacity(0.7),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        child: ListTile(
          contentPadding:
              EdgeInsets.only(top: 7, bottom: 7, left: 15, right: 15),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatRoom(
                        id: id,
                        username: username,
                        photo: photo,
                        opponentId: opponentId)));
          },
          onLongPress: () {},
          title: Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            message != null ? message : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
          leading: ClipRRect(
            borderRadius:
                BorderRadius.circular(MediaQuery.of(context).size.width),
            child: Image.network(
              photo,
              width: MediaQuery.of(context).size.width * 0.14,
              height: MediaQuery.of(context).size.width * 0.14,
              fit: BoxFit.cover,
            ),
          ),
          trailing: Text(
            DateFormat('hh:mm').format(DateTime.fromMillisecondsSinceEpoch(time)) ,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.68),
            ),
          ),
        ),
      ),
    );
  }
}
