import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _connectionErrorText = "";
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> _connectivityStreamSubscription;

  @override
  void initState() {
    super.initState();
    connectivity = new Connectivity();
    connectivity.checkConnectivity().then((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        Timer(Duration(seconds: 2), () {
          _moveToIntermediatePage();
        });
      } else {
        print("no wifi/mobile");
        _connectivityStreamSubscription = connectivity.onConnectivityChanged
            .listen((ConnectivityResult result) {
          print("inside listen");
          if (result == ConnectivityResult.wifi ||
              result == ConnectivityResult.mobile) {
            // connection exists - move to login or signup page
            print("wifi/mobile");
            Timer(Duration(seconds: 2), () {
              _moveToIntermediatePage();
            });
          }
        });
        setState(() {
          _connectionErrorText = "No Internet Connection";
        });
      }
    });
  }

  @override
  void dispose() {
    if (_connectivityStreamSubscription != null) {
      _connectivityStreamSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        'assets/images/relief_portal_citizens.png',
                        scale: 1,
                        width: 100.0,
                        height: 100.0,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Powered by",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Container(
                          width: 50.0,
                          child: Image.asset('assets/images/nag_logo_2.png'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      strokeWidth: 4.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                    SizedBox(
                      width: 20.0,
                      height: 20.0,
                    ),
                    Text(
                      _connectionErrorText,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _moveToIntermediatePage() {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/HomePage');
      } else {
        Navigator.of(context).pushReplacementNamed('/IntermediateLoginPage');
      }
    });
  }
}
