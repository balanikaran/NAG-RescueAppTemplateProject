import 'dart:io';

import 'package:app_template_project/src/helpers/firestore_helper.dart';
import 'package:app_template_project/src/helpers/text_helper.dart';
import 'package:app_template_project/src/models/item.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditItemPage extends StatefulWidget {
  final Item existingItem;

  EditItemPage(this.existingItem);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  Item editableItem;
  List<File> _newImages = [];
  List<String> deletedImagesUrls = [];
  GlobalKey<ScaffoldState> scaffoldState;
  TextEditingController textFieldNameController,
      textFieldQuantityController,
      textFieldDescriptionController,
      textFieldTagNameController;

  @override
  void initState() {
    super.initState();
    editableItem = widget.existingItem;
    scaffoldState = GlobalKey<ScaffoldState>();
    textFieldNameController = TextEditingController(text: editableItem.name);
    textFieldQuantityController =
        TextEditingController(text: editableItem.quantity.toString());
    textFieldDescriptionController =
        TextEditingController(text: editableItem.description);
    textFieldTagNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Edit uploaded item",
      home: Scaffold(
        key: scaffoldState,
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.save,
                color: Colors.green,
              ),
              onPressed: _validateUploadAndPop,
            ),
          ],
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            "Edit uploaded item",
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
                  controller: textFieldNameController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  maxLength: 64,
                  decoration: InputDecoration(
                    labelText: "Item name",
                  ),
                  onChanged: (name) {
                    editableItem.name = name;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0),
                child: TextField(
                  controller: textFieldQuantityController,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  maxLength: 4,
                  decoration: InputDecoration(
                      labelText: "Quantity", hintText: "Upto 9999"),
                  onChanged: (quantity) {
                    if (quantity != null) {
                      editableItem.quantity = int.tryParse(quantity) ?? 0;
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0),
                child: TextField(
                  controller: textFieldDescriptionController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  maxLength: 1024,
                  decoration: InputDecoration(
                    labelText: "Description",
                  ),
                  onChanged: (description) {
                    editableItem.description = description;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(16.0),
                child: Center(
                    child: Wrap(
                  children: _buildTagsRow(),
                  spacing: 10.0,
                  alignment: WrapAlignment.center,
                )),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text("${editableItem.tags.length} TAG(s) ADDED..."),
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
                  child: Text(
                      "${editableItem.photoUrls.length + _newImages.length} IMAGE(s) ADDED..."),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Note: If location for this item is changed, please delete the item and upload again.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                    child: FlatButton(
                      onPressed: () async {
                        // delete the item
                        await FirestoreHelper().deleteItemFromDatabase(editableItem.documentId, context);
                      },
                      child: Text(
                        "Delete this item",
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTagsRow() {
    List<Widget> rowItems = [];
    if (editableItem.tags.length > 0) {
      editableItem.tags.forEach((tag) {
        Widget item = Chip(
          deleteIcon: Icon(
            Icons.cancel,
            color: Colors.grey,
          ),
          onDeleted: () {
            setState(() {
              editableItem.tags.remove(tag);
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

    if (editableItem.tags.length < 5) {
      Widget item = RawMaterialButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            _showTagEditDialog(context, textFieldTagNameController);
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
              controller: controller,
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
                      !editableItem.tags.contains(newTag)) {
                    editableItem.tags.add(newTag);
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
    if (editableItem.photoUrls.length > 0) {
      editableItem.photoUrls.forEach((itemImage) {
        Widget item = Container(
          height: 100.0,
          width: 100.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(itemImage),
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
                            print(editableItem.photoUrls.toString());
                            editableItem.photoUrls.remove(itemImage);
                            deletedImagesUrls.add(itemImage);
                            print(editableItem.photoUrls.toString());
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

    if (_newImages.length > 0) {
      _newImages.forEach((itemImage) {
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
                            print(_newImages.toString());
                            _newImages.remove(itemImage);
                            print(_newImages.toString());
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

    if ((editableItem.photoUrls.length + _newImages.length) < 5) {
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
                    _newImages.add(image);
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
    if (editableItem.name == null ||
        TextHelper().isInvalidTextForItem(editableItem.name)) {
      _showErrorSnackBar("Invalid item name!");
    } else if (editableItem.quantity <= 0 ||
        editableItem.quantity.isNaN ||
        editableItem.quantity > 9999) {
      _showErrorSnackBar("Invalid Item quantity!");
    } else if (editableItem.description == null ||
        TextHelper().isInvalidTextForItem(editableItem.description)) {
      _showErrorSnackBar("Invalid item description!");
    } else if (editableItem.tags.length <= 0) {
      _showErrorSnackBar("Tags of item is not added!");
    } else if (editableItem.photoUrls.length <= 0 && _newImages.length <= 0) {
      _showErrorSnackBar("Image of item is not added!");
    } else {
      //upload image and finally upload item to firestore then pop the page!
      _showUploadingDialog();
      await FirestoreHelper().editItemInDatabase(
          editableItem, _newImages, deletedImagesUrls, context);
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
                  "Uploading item data! Please wait, this may take time! For location update, re-uploading is required!"),
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
    Future.delayed(Duration(milliseconds: 2), () {
      return false;
    });
  }
}
