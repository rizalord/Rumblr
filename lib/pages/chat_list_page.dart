import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rumblr/pages/chat_room.dart';
import './../components/map_right_header.dart';

class ChatList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatListState();
}

class ChatListState extends State<ChatList> {
  final List _data = [1, 2, 3, 4, 5, 6, 7, 8, 9];

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
                          itemBuilder: (context, index) => ChatCard(),
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
  const ChatCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
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
      key: Key('key'),
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
                context, MaterialPageRoute(builder: (context) => ChatRoom()));
          },
          onLongPress: () {},
          title: Text(
            'Eric Seidel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Yo, I\'m waiting you in park this night.',
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
                'https://pbs.twimg.com/profile_images/947228834121658368/z3AHPKHY_400x400.jpg'),
          ),
          trailing: Text(
            '08.04',
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
