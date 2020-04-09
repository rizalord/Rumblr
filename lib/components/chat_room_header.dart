import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class ChatRoomHeader extends StatelessWidget {
  final Function callBack;
  final String username, photo;
  ChatRoomHeader({this.callBack, this.photo, this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
      ),
      // color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TouchableOpacity(
            onTap: () {
              Navigator.pop(context);
            },
            activeOpacity: 0.8,
            child: Container(
              width: 65,
              height: 65,
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_left,
                size: 55,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            child: Container(
              // color: Colors.white,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 35,
                      height: 35,
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(width: 1.5, color: Colors.white),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Image.network(
                          photo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      username,
                      style: GoogleFonts.roboto(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TouchableOpacity(
            activeOpacity: 0.7,
            onTap: () {
              FocusScope.of(context).unfocus();
              callBack();
            },
            child: Container(
              width: 65,
              height: 65,
              alignment: Alignment.center,
              child: Icon(
                Icons.settings,
                size: 35,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
