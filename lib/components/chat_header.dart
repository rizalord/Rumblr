import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import './../pages/chat_list_page.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.8,
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatList()));
      },
      child: Container(
        width: 65,
        height: 65,
        alignment: Alignment.center,
        child: FaIcon(
          FontAwesomeIcons.comments,
          size: 35,
          color: Color(0xFFA08585),
        ),
      ),
    );
  }
}
