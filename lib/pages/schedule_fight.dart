import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class ScheduleFight extends StatefulWidget {
  final Map data;

  ScheduleFight({this.data});

  @override
  _ScheduleFightState createState() => _ScheduleFightState();
}

class _ScheduleFightState extends State<ScheduleFight> {
  CameraPosition _myPosition;
  Completer<GoogleMapController> _controller = Completer();
  bool loading = true;
  bool loadSet = false;
  final Set<Marker> _markers = {};
  DateTime _setTime;
  bool enableSet = false;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () async {
      var tmpPos = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _myPosition = CameraPosition(
            target: LatLng(tmpPos.latitude, tmpPos.longitude), zoom: 17.856);
        loading = false;
      });
    });
    super.initState();
  }

  void _authenticateSchedule() {
    if (enableSet == false) {
      Fluttertoast.showToast(
          msg: 'Schedule cannot be empty!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      // success
      this.saveData();
    }
  }

  void saveData() async {
    setState(() {
      loadSet = true;
    });

    var date = _setTime.millisecondsSinceEpoch;
    var location = GeoPoint(
        _markers.first.position.latitude, _markers.first.position.longitude);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DocumentReference docRef =
        Firestore.instance.collection('schedule').document();
    var passData = {
      'id': prefs.getString('uid'),
      'username': prefs.getString('username'),
      'photo': prefs.getString('photo'),
      'id2': widget.data['opponentId'],
      'username2': widget.data['username'],
      'photo2': widget.data['photo'],
      'messageId': widget.data['messageId'],
      'location': location,
      'time': date,
      'docRef': docRef.documentID
    };

    Firestore.instance
        .collection('schedule')
        .document(docRef.documentID)
        .setData(passData)
        .whenComplete(() {
      Firestore.instance
          .collection('messages')
          .document(widget.data['messageId'])
          .updateData({
        'scheduled': true,
        'scheduledId': docRef.documentID
      }).whenComplete(() {
        setState(() {
          loadSet = false;
        });
        Fluttertoast.showToast(
            msg: 'The match schedule has been set!',
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 15.0);
        Navigator.pop(context);
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
            Color(0xFF7D0101),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Header(opacity: 0.7, callback: this._authenticateSchedule),
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
                                onTap: (LatLng pointer) {
                                  setState(() {
                                    _markers.clear();
                                    _markers.add(Marker(
                                        markerId: MarkerId(pointer.toString()),
                                        position: pointer,
                                        icon: BitmapDescriptor.defaultMarker));
                                    print(_markers.length);
                                    print(_setTime);
                                    if (_markers.length > 0 &&
                                        _setTime != null) {
                                      setState(() {
                                        enableSet = true;
                                      });
                                    }
                                  });
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
                                      'Tap to set up a place.',
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  height: 60,
                  width: 120,
                  child: TouchableOpacity(
                    activeOpacity: 0.8,
                    onTap: () {
                      DatePicker.showTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (date) {
                          setState(() {
                            _setTime = date;

                            if (_markers.length > 0 && _setTime != null) {
                              setState(() {
                                enableSet = true;
                              });
                            }
                          });
                        },
                        currentTime:
                            _setTime == null ? DateTime.now() : _setTime,
                        locale: LocaleType.id,
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withOpacity(0.8), width: 2),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Set Time',
                        style: GoogleFonts.roboto(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            loadSet == true
                ? Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.7))),
                      ),
                    ),
                  )
                : Container(),
          ],
        )),
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
  final double opacity;
  final Function callback;
  const Header({Key key, this.opacity, this.callback}) : super(key: key);

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
          Container(
            width: 60,
          ),
          Text(
            'Set Schedule',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 20,
            ),
          ),
          TouchableOpacity(
            activeOpacity: 0.7,
            onTap: callback,
            child: Container(
              width: 60,
              child: Icon(
                Icons.check,
                color: Colors.white.withOpacity(opacity),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
