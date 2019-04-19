import 'package:app_template_project/src/screens/add_new_item_page.dart';
import 'package:app_template_project/src/screens/error_page.dart';
import 'package:app_template_project/src/screens/home_page.dart';
import 'package:app_template_project/src/screens/intermediate_login_page.dart';
import 'package:app_template_project/src/screens/splash_screen.dart';
import 'package:app_template_project/src/screens/temp_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Name of the app",
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/TempPage': (BuildContext context) => TempPage(),
        '/HomePage': (BuildContext context) => HomePage(),
        '/ErrorPage': (BuildContext context) => ErrorPage(),
        '/IntermediateLoginPage':(BuildContext context) => IntermediateLoginPage(),
        '/AddNewItemPage': (BuildContext context) => AddNewItemPage(),
      },
    );
  }
}
