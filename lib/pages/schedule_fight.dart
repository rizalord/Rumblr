import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

class ScheduleFight extends StatefulWidget {
  @override
  _ScheduleFightState createState() => _ScheduleFightState();
}

class _ScheduleFightState extends State<ScheduleFight> {
  CameraPosition _myPosition;
  Completer<GoogleMapController> _controller = Completer();
  bool loading = true;
  final Set<Marker> _markers = {};

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
                              onTap: (LatLng pointer) {
                                setState(() {
                                  _markers.clear();
                                  _markers.add(Marker(
                                      markerId: MarkerId(pointer.toString()),
                                      position: pointer,
                                      icon: BitmapDescriptor.defaultMarker));
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
                    DatePicker.showTimePicker(context, showTitleActions: true,
                        onChanged: (date) {
                      print('date changed');
                    }, onConfirm: (date) {
                      print('confirm date');
                    }, currentTime: DateTime.now(), locale: LocaleType.id);
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
          Container(
            width: 60,
            child: Icon(
              Icons.check,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
