import 'dart:async';

import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class MapsFragment extends StatefulWidget {
  MapsFragment({Key key}) : super(key: key);

  @override
  State createState() => MapsFragmentState();
}

class MapsFragmentState extends State<MapsFragment> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  bool _gettingCurrentLocation;
  LocationData currentLocation;
  GlobalKey<ScaffoldState> scaffoldState;
  CameraPosition _defaultCameraPosition;

  @override
  initState() {
    super.initState();
    scaffoldState = GlobalKey<ScaffoldState>();
    _gettingCurrentLocation = true;
    _getCurrentPositionAndSetLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      body: _gettingCurrentLocation ? _showLoading() : _showMap(),
    );
  }

  Widget _showLoading(){
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _showMap(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GoogleMap(
        minMaxZoomPreference: MinMaxZoomPreference(10, null),
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        initialCameraPosition: _defaultCameraPosition,
        myLocationEnabled: true,
        mapType: MapType.normal,
        markers: Set<Marker>.of(_markers.values),
        onMapCreated: _onMapCreated,
        onCameraMove: _onCameraMove,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    MarkerId centerMarkerId = MarkerId("centerMarkerId");
    Marker centerMarker = Marker(
        markerId: centerMarkerId,
        position: _defaultCameraPosition.target,
        draggable: false);
    setState(() {
      _markers[centerMarkerId] = centerMarker;
    });
  }

  void _onCameraMove(CameraPosition position) {
    print(position.target);
    MarkerId centerMarkerId = MarkerId("centerMarkerId");
    Marker centerMarker = Marker(
        markerId: centerMarkerId, position: position.target, draggable: false);
    setState(() {
      _markers[centerMarkerId] = centerMarker;
    });

    getDataInArea(
            area: Area(
                GeoPoint(position.target.latitude, position.target.longitude),
                100),
            source: Firestore.instance.collection('artifacts'),
            mapper: (DocumentSnapshot documentSnapshot) {
              GeoPoint geoPoint = documentSnapshot['location'];
              return <MarkerId, Marker>{
                MarkerId(documentSnapshot.documentID): Marker(
                    markerId: MarkerId(documentSnapshot.documentID),
                    draggable: false,
                    infoWindow: InfoWindow(
                        title: documentSnapshot['name'],
                        snippet: "Quantity: " +
                            documentSnapshot['quantity'].toString()),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                    position: LatLng(geoPoint.latitude, geoPoint.longitude))
              };
            },
            locationFieldNameInDB: 'location')
        .listen((List<Map<MarkerId, Marker>> onData) {
      onData.forEach((marker) {
        _markers.addAll(marker);
        setState(() {});
      });
    });
  }

  void _getCurrentPositionAndSetLocation() async {
    var location = new Location();
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();
      _defaultCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 8);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
        _defaultCameraPosition = CameraPosition(
          target: LatLng(37.3075336, -122.1045299),
          zoom: 8,
        );
        var snackBar = SnackBar(
          content: Text(
              "Location Permission was denied, so default location will be used!"),
        );
        scaffoldState.currentState.showSnackBar(snackBar);
      }
    }
    setState(() {
      _gettingCurrentLocation = false;
    });
  }
}
