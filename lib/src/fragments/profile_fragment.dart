import 'dart:io';

import 'package:app_template_project/src/custom_widgets/fancy_button.dart';
import 'package:app_template_project/src/helpers/firestore_helper.dart';
import 'package:app_template_project/src/helpers/text_helper.dart';
import 'package:app_template_project/src/screens/intermediate_login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:app_template_project/src/blocs/login_signup_bloc.dart';
import 'package:location/location.dart';

class ProfileFragment extends StatefulWidget {
  ProfileFragment({Key key}) : super(key: key);

  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  final textFieldNameController = TextEditingController();

  @override
  void dispose() {
    textFieldNameController.dispose();
    super.dispose();
  }

  void reBuildPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 125.0,
                width: 125.0,
                margin: EdgeInsets.all(24.0),
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: FutureBuilder(
                        future:
                            FirestoreHelper().getProfileUrlFromSharedPrefs(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return Material(
                              elevation: 8.0,
                              shape: CircleBorder(),
                              child: Container(
                                height: 125.0,
                                width: 125.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 3.0,
                                  ),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        NetworkImage(snapshot.data.toString()),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2.5,
                          ),
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await ImagePicker.pickImage(
                                    source: ImageSource.gallery,
                                    maxHeight: 512.0,
                                    maxWidth: 512.0)
                                .then((image) {
                              if (image != null) {
                                _showUserImageUploadDialog(context, image);
                              }
                            });
                          },
                          icon: Icon(Icons.camera_alt),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    border: Border.all(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(2.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        child: Center(
                          child: Text(
                            "Name",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder(
                            future: FirestoreHelper().getCurrentUserName(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              String name;
                              if (snapshot.hasData) {
                                name = snapshot.data;
                              } else {
                                name = "Your name here!";
                              }
                              return Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showNameEditDialog(
                                context, textFieldNameController);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    border: Border.all(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(2.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        child: Center(
                          child: Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder(
                            future: FirestoreHelper().getCurrentUserEmail(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              String email = "";
                              if (snapshot.hasData) {
                                email = snapshot.data;
                              } else {
                                email = "Your email here...";
                              }
                              return Text(
                                email,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    border: Border.all(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(2.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        child: Center(
                          child: Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder(
                            future: FirestoreHelper().getCurrentPosition(),
                            builder: (BuildContext context,
                                AsyncSnapshot<LocationData> snapshot) {
                              String name;
                              if (snapshot.hasData) {
                                name = "[${snapshot.data.latitude} °N, ${snapshot.data.longitude} °E]";
                              } else {
                                name = "Your co-ordinates here...";
                              }
                              return Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/UserUploadsPage');
                      },
                      child: Text(
                        "My items",
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FancyButton(
                      color: Colors.red,
                      text: Text(
                        "Sign Out",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        loginSignUpBloc.signOutUser();
                        Navigator.pushAndRemoveUntil(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => new IntermediateLoginPage(),
                            ),
                            (Route<dynamic> route) => false);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _showNameEditDialog(
    BuildContext context, TextEditingController controller) async {
  String initialName = await new FirestoreHelper().getCurrentUserName();
  String newName = "";
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text("Update name!"),
          content: TextField(
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.text,
            maxLines: 1,
            maxLength: 64,
            decoration: InputDecoration(
              labelText: "New name",
              helperText: "By default, previous value is saved!",
            ),
            onChanged: (name) {
              if (TextHelper().isInvalidTextForTag(name)) {
                newName = null;
              } else {
                newName = name;
              }
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () async {
                if (newName == "" || newName == null) {
                  await new FirestoreHelper()
                      .updateNameOnFirestore(initialName);
                } else {
                  await new FirestoreHelper().updateNameOnFirestore(newName);
                }
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      });
}

_showUserImageUploadDialog(BuildContext context, File image) {
  if (image != null) {
    FirebaseAuth.instance.currentUser().then((user) {
      final StorageReference reference = FirebaseStorage.instance
          .ref()
          .child('user_profile_photos')
          .child(user.uid + ".jpg");

      final StorageUploadTask task = reference.putFile(image);
      task.onComplete.then((taskSnapShot) {
        print("Object uploaded");
        reference.getDownloadURL().then((url) async {
          await FirestoreHelper().updateProfileUrlOnFirestore(url);
        });
        Navigator.of(context, rootNavigator: true).pop();
      });
    });
  }

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: _onBackPressed,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text("Uploading new profile picture!"),
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
