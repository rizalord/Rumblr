import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> _marker = {};
  final LatLng _currentPosition = LatLng(-7.982705, 112.628799);
  BitmapDescriptor _customIcon;
  bool showDetail = false;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-7.982705, 112.628799),
    zoom: 17.4746,
  );

  @override
  void initState() {
    setMarker();
    super.initState();
  }

  void setMarker() async {
    BitmapDescriptor tmpIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5),
            'assets/img/red_marker.png')
        .then((value) => value);
    _marker.addAll([
      Marker(
          markerId: MarkerId("-7.982769, 112.629089"),
          position: LatLng(-7.982769, 112.629089),
          icon: tmpIcon,
          onTap: () {
            Future.delayed(Duration(milliseconds: 750), () {
              setState(() {
                showDetail = true;
              });
            });
          }),
      Marker(
          markerId: MarkerId("-7.983867, 112.628780"),
          position: LatLng(-7.983867, 112.628780),
          icon: tmpIcon,
          onTap: () {
            Future.delayed(Duration(milliseconds: 750), () {
              setState(() {
                showDetail = true;
              });
            });
          }),
      Marker(
          markerId: MarkerId("-7.981709, 112.627854"),
          position: LatLng(-7.981709, 112.627854),
          icon: tmpIcon,
          onTap: () {
            Future.delayed(Duration(milliseconds: 750), () {
              setState(() {
                showDetail = true;
              });
            });
          }),
    ]);
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _customIcon = tmpIcon;
      });
      print(_customIcon);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _marker,
              gestureRecognizers: Set()
                ..add(Factory<PanGestureRecognizer>(
                    () => PanGestureRecognizer())),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Explore fights happening near you.',
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic),
                    ),
                    Text(
                      'Tap a location to see fight details.',
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            _customIcon == null
                ? Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black.withOpacity(0.4),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Container(),
            showDetail == true
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showDetail = false;
                        });
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: AnimatedOpacity(
                          duration: Duration(seconds: 1),
                          curve: Curves.easeIn,
                          opacity: showDetail == true ? 1.0 : 0.0,
                          child: DetailOpponentCard(),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class DetailOpponentCard extends StatelessWidget {
  const DetailOpponentCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.7,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Color(0xFF650103),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 2, color: Color(0xFFA93132))),
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.31,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.45),
                      border: Border.all(
                        width: 2,
                        color: Colors.white,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.45),
                      child: Image.network(
                          'https://i.pinimg.com/originals/29/d4/fe/29d4fea595a81b16bcdae6ebf295ab86.jpg',
                          fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child:
                        Image.asset('assets/img/versus.png', fit: BoxFit.cover),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.45),
                      border: Border.all(
                        width: 2,
                        color: Colors.white,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.45),
                      child: Image.network(
                          'https://pbs.twimg.com/profile_images/487475122001805312/jBX4VpgE_400x400.jpeg',
                          fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'eminem87',
                            style: GoogleFonts.roboto(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'bogel58',
                            style: GoogleFonts.roboto(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '<< Ongoing >>',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.redAccent,
                                    height: 3,
                                    fontStyle: FontStyle.italic),
                              ),
                              Text(
                                '08:00 PM - 09.00 PM',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.96)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
