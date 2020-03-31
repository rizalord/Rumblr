import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextQuote extends StatelessWidget {
  const TextQuote({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 190,
      margin: EdgeInsets.only(top: 35 , bottom : 65),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Casualty-free',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 35,
              height: 1.4,
            ),
          ),
          Text(
            'casual fighting',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 35,
              height: 1.4
            ),
          ),
          Text(
            'for free',
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 35,
              height: 1.4
            ),
          ),
        ],
      ),
    );
  }
}
