import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class ScheduledFight extends StatefulWidget {
  final String id;

  ScheduledFight({this.id});

  @override
  _ScheduledFightState createState() => _ScheduledFightState();
}

class _ScheduledFightState extends State<ScheduledFight> {
  CameraPosition _myPosition;
  Completer<GoogleMapController> _controller = Completer();
  bool loading = true;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    print(widget.id);
    Future.delayed(Duration(milliseconds: 0), () async {
      // var tmpPos = await Geolocator()
      //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      Firestore.instance
          .collection('schedule')
          .document(widget.id)
          .snapshots()
          .listen((event) {
        GeoPoint loc = event.data['location'];
        DateTime date = DateTime.fromMillisecondsSinceEpoch(event.data['time']);
        print(date.hour);

        setState(() {
          _myPosition = CameraPosition(
              target: LatLng(loc.latitude, loc.longitude), zoom: 17.856);
          loading = false;
          _markers.add(
            Marker(
                markerId: MarkerId('1'),
                position: LatLng(loc.latitude, loc.longitude),
                icon: BitmapDescriptor.defaultMarker),
          );
        });
      });
    });
    super.initState();
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
              Header(),
              Expanded(
                child: loading == true
                    ? LoadingWidget()
                    : Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: GoogleMap(
                              markers: _markers,
                              mapType: MapType.normal,
                              initialCameraPosition:
                                  _myPosition != null ? _myPosition : null,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                            ),
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
                                    '18.00 - 19.00',
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TouchableOpacity(
            activeOpacity: 0.7,
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              width: 60,
              child: Icon(
                Icons.chevron_left,
                size: 40,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            'Schedule',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 20,
            ),
          ),
          Container(
            width: 60,
          ),
        ],
      ),
    );
  }
}
