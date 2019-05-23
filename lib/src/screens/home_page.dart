import 'package:app_template_project/src/fragments/feeds_fragment.dart';
import 'package:app_template_project/src/fragments/maps_fragment.dart';
import 'package:app_template_project/src/fragments/profile_fragment.dart';
import 'package:app_template_project/src/screens/add_new_item_page.dart';
import 'package:app_template_project/src/screens/user_uploads_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _pageTitle = "Home";
  int _index = 1, count;
  PageController _pageController;

  final PageStorageBucket pageStorageBucket = PageStorageBucket();

  ProfileFragment profileFragment = ProfileFragment(
    key: PageStorageKey('profileFragmentKey'),
  );
  FeedsFragment dashboardFragment = FeedsFragment(
    key: PageStorageKey('dashboardFragmentKey'),
  );
  MapsFragment mapFragment = MapsFragment(
    key: PageStorageKey('mapsFragmentKey'),
  );
  List<Widget> pages;

  @override
  void initState() {
    super.initState();
    print("home init called");
    _pageController = PageController();
    pages = [profileFragment, dashboardFragment, mapFragment];
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/AddNewItemPage': (BuildContext context) => AddNewItemPage(),
        '/UserUploadsPage': (BuildContext context) => UserUploadsPage()
      },
      debugShowCheckedModeBanner: false,
      title: "App home screen",
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            _pageTitle,
            style: TextStyle(color: Colors.black),
          ),
          brightness: Brightness.light,
          centerTitle: true,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _tabSelected,
          currentIndex: _index,
          items: [
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user),
              title: Text("Profile"),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.map),
              title: Text('Maps'),
            ),
          ],
        ),
        body: PageStorage(
          bucket: pageStorageBucket,
          child: _getRespectedWidget(),
        ),
      ),
    );
  }

  Widget _getRespectedWidget() {
    switch (_index) {
      case 0: // user profile
        return pages[_index];
        break;
      case 1: // dashboard/home
        return pages[_index];
        break;
      case 2: // maps fragment
        return pages[_index];
        break;
      default:
        return Container(
          child: Text("No particular index found!"),
        );
    }
  }

  void _tabSelected(int index) {
    print(index);
    setState(() {
      if (index == 0) {
        setState(() {
          _pageTitle = "User Profile";
          _index = 0;
        });
      } else if (index == 1) {
        setState(() {
          _pageTitle = "Home";
          _index = 1;
        });
      } else if (index == 2) {
        _pageTitle = "Maps";
        _index = 2;
      }
    });
  }
}
