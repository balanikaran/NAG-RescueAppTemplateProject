import 'package:app_template_project/src/helpers/firestore_helper.dart';
import 'package:app_template_project/src/models/item.dart';
import 'package:app_template_project/src/screens/edit_item_page.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:flutter/material.dart';

class UserUploadsPage extends StatefulWidget {
  UserUploadsPage({Key key}) : super(key: key);

  @override
  _UserUploadsPageState createState() => _UserUploadsPageState();
}

class _UserUploadsPageState extends State<UserUploadsPage>
    implements AutomaticKeepAliveClientMixin<UserUploadsPage> {
  ScrollController _scrollController;
  List<Item> _uploadedItems;
  Item _lastUploadedItem;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    print("feeds init called");
    _uploadedItems = [];
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    this._getInitialUploadedItems();
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose was called for feeds fragment");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          "My Items",
          style: TextStyle(color: Colors.black),
        ),
        brightness: Brightness.light,
        centerTitle: true,
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
        _uploadedItems = [];
        _getInitialUploadedItems();
      });
    });
  }

  Future<Null> _fakeFutureForRefresh() {
    return Future.delayed(Duration(seconds: 1), () {});
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // fetch more
      print("end me a gya hu me oye!");
      _getNextFiveUploadedItems();
    }
  }

  Widget _bodyToShow() {
    return _uploadedItems.isEmpty ? _loadingBody() : _listViewBody();
  }

  Widget _listViewBody() {
    return Container(
      child: ListView(
        controller: _scrollController,
        children: _uploadedItems.map((Item item) {
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

  void _getInitialUploadedItems() async {
    if (_uploadedItems.length > 0) {
      _lastUploadedItem = _uploadedItems.last;
    } else {
      List<Item> initialFeedItems =
      await FirestoreHelper().getInitialUploadedItems();
      if (this.mounted) {
        setState(() {
          print("set state was called for feeds fragment a");
          _uploadedItems.addAll(initialFeedItems);
          _lastUploadedItem = _uploadedItems.last;
        });
      }
    }
  }

  void _getNextFiveUploadedItems() async {
    List<Item> nextFiveItems =
    await FirestoreHelper().getNextFiveUploadedItems(_lastUploadedItem);
    if (this.mounted) {
      setState(() {
        print("set state was called for feeds fragment b");
        _uploadedItems.addAll(nextFiveItems);
        _lastUploadedItem = _uploadedItems.last;
      });
    }
  }

  Widget _makeCard(Item item) {
    return Card(
      elevation: 2.0,
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
                Icons.edit,
              ),
              onPressed: () async {
                //open for editing
                final shouldRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditItemPage(item),
                  ),
                ) ?? false;
                if(shouldRefresh){
                  setState(() {
                    _refresh();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void updateKeepAlive() {
    // TODO: implement updateKeepAlive
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
