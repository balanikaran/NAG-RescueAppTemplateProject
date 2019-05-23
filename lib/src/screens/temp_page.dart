import 'package:flutter/material.dart';

class TempPage extends StatefulWidget {
  @override
  _TempPageState createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Temp page"),
    );
  }

  // Widget _handleCurrentScreen() {
  //   return new StreamBuilder<FirebaseUser>(
  //       stream: FirebaseAuth.instance.onAuthStateChanged,
  //       builder: (BuildContext context, snapshot) {
  //         print(" 1 + ${snapshot.data}");
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           print(" 2 + ${snapshot.data}");
  //           return ErrorPage();
  //         } else {
  //           if (snapshot.hasData) {
  //             print(" 3 + ${snapshot.data}");
  //             return ErrorPage();
  //           }
  //           print("${snapshot.data}");
  //           return ErrorPage();
  //         }
  //       });
  // }
}
