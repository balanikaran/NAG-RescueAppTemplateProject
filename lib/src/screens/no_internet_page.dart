import 'package:app_template_project/src/helpers/internet_connectivity_check.dart';
import 'package:flutter/material.dart';

class NoInternetPage extends StatefulWidget {
  @override
  _NoInternetPageState createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("😵", style: TextStyle(fontSize: 32.0),),
                SizedBox(height: 20.0,),
                Text("No internet connection, please try after a while. Tap the button when connection is avalaible",style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                SizedBox(height: 20.0,),
                IconButton(icon: Icon(Icons.refresh), onPressed: () async {
                  await InternetConnectivityCheck.getConnectionStatus().then((status){
                    print(status);
                    if(status){
                      Navigator.of(context).pop();
                    }
                  });
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
