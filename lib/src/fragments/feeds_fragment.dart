import 'dart:io';

import 'package:app_template_project/src/helpers/firestore_helper.dart';
import 'package:app_template_project/src/models/item.dart';
import 'package:app_template_project/src/screens/edit_item_page.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedsFragment extends StatefulWidget {
  FeedsFragment({Key key}) : super(key: key);

  @override
  _FeedsFragmentState createState() => _FeedsFragmentState();
}

class _FeedsFragmentState extends State<FeedsFragment>
    implements AutomaticKeepAliveClientMixin<FeedsFragment> {
  ScrollController _scrollController;
  List<Item> _feedsItems;
  Item _lastFeedItem;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    print("feeds init called");
    _feedsItems = [];
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    this._getInitialFeedItems();
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose was called for feeds fragment");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNewItemPage,
        child: Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: _bodyToShow(),
      ),
    );
  }

  Future<Null> _refresh() {
    return _fakeFutureForRefresh().then((onValue) {
      setState(() {
        _feedsItems = [];
        _getInitialFeedItems();
      });
    });
  }

  Future<Null> _fakeFutureForRefresh() {
    return Future.delayed(Duration(seconds: 2), () {});
  }

  void _navigateToAddNewItemPage() async {
    final shouldRefresh =
        await Navigator.of(context).pushNamed('/AddNewItemPage') ?? false;
    if (shouldRefresh) {
      setState(() {
        _refresh();
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // fetch more
      print("end me a gya hu me oye!");
      _getNextFiveFeedItems();
    }
  }

  Widget _bodyToShow() {
    return _feedsItems.isEmpty ? _loadingBody() : _listViewBody();
  }

  Widget _listViewBody() {
    return Container(
      child: ListView(
        controller: _scrollController,
        children: _feedsItems.map((Item item) {
          return _makeCard(item);
        }).toList(),
      ),
    );
  }

  Widget _loadingBody() {
    return Container(
      child: Center(
        child: Text("Loading Data..."),
      ),
    );
  }

  void _getInitialFeedItems() async {
    if (_feedsItems.length > 0) {
      _lastFeedItem = _feedsItems.last;
    } else {
      List<Item> initialFeedItems =
          await FirestoreHelper().getInitialFeedItems();
      if (this.mounted) {
        setState(() {
          print("set state was called for feeds fragment a");
          _feedsItems.addAll(initialFeedItems);
          _lastFeedItem = _feedsItems.last;
        });
      }
    }
  }

  void _getNextFiveFeedItems() async {
    List<Item> nextFiveItems =
        await FirestoreHelper().getNextFiveFeedItems(_lastFeedItem);
    if (this.mounted) {
      setState(() {
        print("set state was called for feeds fragment b");
        _feedsItems.addAll(nextFiveItems);
        _lastFeedItem = _feedsItems.last;
      });
    }
  }

  Widget _makeCard(Item item) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        // decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        child: _makeListTileForItem(item),
      ),
    );
  }

  Widget _makeListTileForItem(Item item) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
                item.name + " [Available: " + item.quantity.toString() + "]"),
            subtitle: Text(
                "by " + item.byName + ", " + timeAgo.format(item.timeAdded)),
            trailing: IconButton(
              icon: Icon(
                Icons.navigation,
              ),
              onPressed: () async {
                //launch a new activity to show the location on map
                String googleUrl =
                    'http://maps.google.com/?q=${item.location.latitude},${item.location.longitude}';
                String appleUrl =
                    'https://maps.apple.com/?sll=${item.location.latitude},${item.location.longitude}';
                if (await canLaunch(googleUrl)) {
                  await launch(googleUrl);
                } else if (await canLaunch(appleUrl)) {
                  print('launching apple url');
                  await launch(appleUrl);
                } else {
                  throw 'Could not launch $googleUrl';
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 4.0, right: 4.0),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _buildItemImagesListView(item.photoUrls),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Text("Tags: " + item.tags.toString()),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding:
                EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
            child: Text("Description: " + item.description),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemImagesListView(List<String> photoUrls) {
    List<Widget> itemImages = [];
    photoUrls.forEach((url) {
      Widget image = Container(
        width: MediaQuery.of(context).size.width - 38,
        color: Colors.red,
        height: MediaQuery.of(context).size.width - 38,
        child: Image.network(
          url,
          fit: BoxFit.cover,
        ),
        margin: EdgeInsets.only(left: 4.0, right: 4.0),
      );

      itemImages.add(image);
    });

    return itemImages;
  }

  @override
  void updateKeepAlive() {
    // TODO: implement updateKeepAlive
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
