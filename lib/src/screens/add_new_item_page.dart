import 'dart:io';

import 'package:app_template_project/src/helpers/firestore_helper.dart';
import 'package:app_template_project/src/helpers/internet_connectivity_check.dart';
import 'package:app_template_project/src/helpers/text_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddNewItemPage extends StatefulWidget {
  @override
  _AddNewItemPageState createState() => _AddNewItemPageState();
}

class _AddNewItemPageState extends State<AddNewItemPage> {
  String _itemName, _itemDescription;
  List<String> _itemTags = [];
  int _itemQuantity = 0;
  List<File> _itemImages = [];
  GlobalKey<ScaffoldState> scaffoldState;
  final textFieldNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scaffoldState = GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Add a new item to firestore database",
      home: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.done),
          label: Text("OK"),
          onPressed: _validateUploadAndPop,
        ),
        key: scaffoldState,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            "Add to Database",
            style: TextStyle(color: Colors.black),
          ),
          brightness: Brightness.light,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  maxLength: 64,
                  decoration: InputDecoration(
                    labelText: "Item name",
                  ),
                  onChanged: (name) {
                    _itemName = name;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  maxLength: 4,
                  decoration: InputDecoration(
                      labelText: "Quantity", hintText: "Upto 9999"),
                  onChanged: (quantity) {
                    if (quantity != null) {
                      _itemQuantity = int.tryParse(quantity) ?? 0;
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  maxLength: 1024,
                  decoration: InputDecoration(
                    labelText: "Description",
                  ),
                  onChanged: (description) {
                    _itemDescription = description;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(16.0),
                child: Center(
                    child: Wrap(
                  spacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: _buildTagsRow(),
                )),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text("${_itemTags.length} TAG(s) ADDED..."),
                ),
              ),
              Container(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: Wrap(
                    spacing: 10.0,
                    alignment: WrapAlignment.center,
                    children: _buildImagesRow(),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text("${_itemImages.length} IMAGE(s) ADDED..."),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Note: Your current location will be shared and saved for this item!",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTagsRow() {
    List<Widget> rowItems = [];
    if (_itemTags.length > 0) {
      _itemTags.forEach((tag) {
        Widget item = Chip(
          deleteIcon: Icon(
            Icons.cancel,
            color: Colors.grey,
          ),
          onDeleted: () {
            setState(() {
              print(_itemTags.toString());
              _itemTags.remove(tag);
              print(_itemTags.toString());
            });
          },
          label: Text(
            tag,
            style: TextStyle(fontSize: 18.0),
          ),
        );
        rowItems.add(item);
      });
    }

    if (_itemTags.length < 5) {
      Widget item = RawMaterialButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            _showTagEditDialog(context, textFieldNameController);
          },
          fillColor: Colors.blueAccent,
          constraints: BoxConstraints(maxWidth: 70.0, maxHeight: 70.0),
          shape: CircleBorder());
      rowItems.add(item);
    }

    return rowItems;
  }

  _showTagEditDialog(
      BuildContext context, TextEditingController controller) async {
    String newTag = "";
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text("Add a tag!"),
            content: TextField(
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              maxLines: 1,
              maxLength: 64,
              decoration: InputDecoration(
                labelText: "New tag",
              ),
              onChanged: (tag) {
                if (TextHelper().isInvalidTextForTag(tag)) {
                  newTag = null;
                } else {
                  newTag = tag;
                }
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () async {
                  if (newTag != "" &&
                      newTag != null &&
                      !_itemTags.contains(newTag)) {
                    _itemTags.add(newTag);
                  }
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        });
  }

  List<Widget> _buildImagesRow() {
    List<Widget> rowItems = [];
    if (_itemImages.length > 0) {
      _itemImages.forEach((itemImage) {
        Widget item = Container(
          height: 100.0,
          width: 100.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(itemImage),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: SizedBox(
                      height: 25.0,
                      width: 25.0,
                      child: IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _itemImages.remove(itemImage);
                          });
                        },
                      ),
                    )),
              ),
            ],
          ),
        );
        rowItems.add(item);
      });
    }

    if (_itemImages.length < 5) {
      Widget item = SizedBox(
        height: 50.0,
        width: 50.0,
        child: IconButton(
            icon: Icon(
              Icons.add_a_photo,
              color: Colors.grey,
            ),
            onPressed: () async {
              await ImagePicker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 300.0,
                      maxHeight: 300.0)
                  .then((image) {
                if (image != null) {
                  setState(() {
                    _itemImages.add(image);
                  });
                }
              });
            }),
      );
      rowItems.add(item);
    }
    return rowItems;
  }

  void _validateUploadAndPop() async {
    if (_itemName == null || TextHelper().isInvalidTextForItem(_itemName)) {
      _showErrorSnackBar("Invalid item name!");
    } else if (_itemQuantity <= 0 ||
        _itemQuantity.isNaN ||
        _itemQuantity > 9999) {
      _showErrorSnackBar("Invalid Item quantity!");
    } else if (_itemDescription == null ||
        TextHelper().isInvalidTextForItem(_itemDescription)) {
      _showErrorSnackBar("Invalid item description!");
    } else if (_itemTags.length <= 0) {
      _showErrorSnackBar("Tags of item is not added!");
    } else if (_itemImages.length <= 0) {
      _showErrorSnackBar("Image of item is not added!");
    } else {
      await InternetConnectivityCheck.getConnectionStatus().then((status) async {
        if (status){
          //upload image and finally upload item to FireStore then pop the page!
          _showUploadingDialog();
          await FirestoreHelper().uploadNewItemToDatabase(_itemName, _itemQuantity,
              _itemDescription, _itemTags, _itemImages, context);
        }else{
          // no internet connection page
          Navigator.of(context).pushNamed('/NoInternetPage');
        }
      });

    }
  }

  void _showErrorSnackBar(String errorMessage) {
    var snackBar = SnackBar(
      content: Text(errorMessage),
    );
    scaffoldState.currentState.showSnackBar(snackBar);
  }

  void _showUploadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: _onBackPressed,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              title: Text(
                  "Fetching your location and uploading item data! Please wait, this may take time!"),
              content: Container(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(),
                alignment: Alignment.center,
              ),
            ),
          );
        });
  }

  Future<bool> _onBackPressed() {
    return Future.delayed(Duration(milliseconds: 2), () {
      return false;
    });
  }
}
