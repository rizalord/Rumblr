import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailCard extends StatelessWidget {
  final String name, uri;
  final int stars;

  DetailCard({Key key, this.name, this.uri, this.stars}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.4),
        border: Border.all(
          width: 4,
          color: Color(0xFFA93132),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.width * 0.95,
            child: Image.network(
              uri,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment(0, 1.5),
                    colors: [Colors.transparent, Colors.black.withOpacity(1)]),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: 65,
              padding:
                  EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
              // color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    name,
                    style: GoogleFonts.roboto(
                        fontSize: 18, color: Colors.white.withOpacity(0.85)),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 22.5,
                              child: Row(
                                children: [
                                  for (var i = 0; i < stars; i++)
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.bottomLeft,
                              height: 22.5,
                              child: Text(
                                stars >= 1 && stars < 3
                                    ? 'Amateur'
                                    : stars >= 3 && stars < 5
                                        ? 'Rookie'
                                        : 'Pro',
                                style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
