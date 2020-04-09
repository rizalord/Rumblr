import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

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
  String username, username2, photo, photo2, formatTime;
  bool status;

  CameraPosition _kGooglePlex;

  @override
  void initState() {
    setMarker();
    super.initState();
  }

  void setMarker() async {
    var myLoc = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // Get Nearest Match
    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(myLoc.latitude, myLoc.longitude),
        zoom: 17.685,
      );
    });

    // get nearest match

    var lat = 0.0144927536231884;
    var lon = 0.0181818181818182;
    var latitude = myLoc.latitude;
    var longitude = myLoc.longitude;
    var distance = 1;

    var lowerLat = latitude - (lat * distance);
    var lowerLon = longitude - (lon * distance);

    var greaterLat = latitude + (lat * distance);
    var greaterLon = longitude + (lon * distance);

    var lesserGeopoint = GeoPoint(lowerLat, lowerLon);
    var greaterGeopoint = GeoPoint(greaterLat, greaterLon);

    BitmapDescriptor tmpIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5),
            'assets/img/red_marker.png')
        .then((value) => value);

    Firestore.instance
        .collection('schedule')
        .where('location',
            isGreaterThanOrEqualTo: lesserGeopoint, isLessThanOrEqualTo: greaterGeopoint)
        .snapshots()
        .listen((event) {
      event.documents.forEach((element) {
        GeoPoint loc = element.data['location'];
        _marker.add(Marker(
            markerId: MarkerId("-7.982769, 112.629089"),
            position: LatLng(loc.latitude, loc.longitude),
            icon: tmpIcon,
            onTap: () {
              Future.delayed(Duration(milliseconds: 750), () {
                var df = DateFormat('hh:mm a');
                formatTime = df.format(DateTime.fromMillisecondsSinceEpoch(
                        element.data['time'])) +
                    ' - ' +
                    df.format(DateTime.fromMillisecondsSinceEpoch(
                        element.data['time'] + 3600000));
                setState(() {
                  showDetail = true;
                  username = element.data['username'];
                  username2 = element.data['username2'];
                  photo = element.data['photo'];
                  photo2 = element.data['photo2'];
                  status = DateTime.now().millisecondsSinceEpoch >=
                          element.data['time'] &&
                      DateTime.now().millisecondsSinceEpoch <
                          element.data['time'] + 3600000;
                });
              });
            }));
      });
    });

    // My Position
    _marker.add(
      Marker(
          markerId: MarkerId("-7.982769, 112.629089"),
          position: LatLng(myLoc.latitude, myLoc.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(207),
          onTap: () {
            Future.delayed(Duration(milliseconds: 750), () {
              setState(() {
                showDetail = true;
              });
            });
          }),
    );
    // _marker.addAll([
    //   Marker(
    //       markerId: MarkerId("-7.982769, 112.629089"),
    //       position: LatLng(-7.982769, 112.629089),
    //       icon: tmpIcon,
    //       onTap: () {
    //         Future.delayed(Duration(milliseconds: 750), () {
    //           setState(() {
    //             showDetail = true;
    //           });
    //         });
    //       }),
    //   Marker(
    //       markerId: MarkerId("-7.983867, 112.628780"),
    //       position: LatLng(-7.983867, 112.628780),
    //       icon: tmpIcon,
    //       onTap: () {
    //         Future.delayed(Duration(milliseconds: 750), () {
    //           setState(() {
    //             showDetail = true;
    //           });
    //         });
    //       }),
    //   Marker(
    //       markerId: MarkerId("-7.981709, 112.627854"),
    //       position: LatLng(-7.981709, 112.627854),
    //       icon: tmpIcon,
    //       onTap: () {
    //         Future.delayed(Duration(milliseconds: 750), () {
    //           setState(() {
    //             showDetail = true;
    //           });
    //         });
    //       }),
    // ]);
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _customIcon = tmpIcon;
      });
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
            _kGooglePlex != null
                ? GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: _marker,
                    gestureRecognizers: Set()
                      ..add(Factory<PanGestureRecognizer>(
                          () => PanGestureRecognizer())),
                  )
                : Center(
                    child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )),
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
                          child: DetailOpponentCard(username, username2, photo,
                              photo2, formatTime, status),
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
  String username, username2, photo, photo2, timeFormat;
  bool status;
  DetailOpponentCard(username, username2, photo, photo2, timeFormat, status) {
    this.username = username;
    this.username2 = username2;
    this.photo = photo;
    this.photo2 = photo2;
    this.timeFormat = timeFormat;
    this.status = status;
  }

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
                      child: Image.network(photo, fit: BoxFit.cover),
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
                      child: Image.network(photo2, fit: BoxFit.cover),
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
                            username,
                            style: GoogleFonts.roboto(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            username2,
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
                                status == true
                                    ? '<< Ongoing >>'
                                    : '<< Pending >>',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: status == true
                                        ? Colors.redAccent
                                        : Colors.white70,
                                    height: 3,
                                    fontStyle: FontStyle.italic),
                              ),
                              Text(
                                timeFormat,
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
