import 'dart:io';

import 'package:app_template_project/src/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

abstract class BaseFirestoreHelper {
  Future<void> updateNameOnFirestore(String name);

  Future<String> getCurrentUserName();

  Future<String> getCurrentUserEmail();

  Future<bool> updateProfileUrlOnFirestore(String profileUrl);

  Future<String> getProfileUrlFromSharedPrefs();

  Future<bool> uploadNewItemToDatabase(
      String name,
      int quantity,
      String description,
      List<String> tags,
      List<File> images,
      BuildContext context);
}

class FirestoreHelper extends BaseFirestoreHelper {
  FirebaseUser firebaseUser;
  LocationData position;
//  StreamController<QuerySnapshot> itemsStream =
//      BehaviorSubject<QuerySnapshot>();


  @override
  Future<void> updateNameOnFirestore(String name) async {
    firebaseUser = await FirebaseAuth.instance.currentUser();
    print("Hey," + firebaseUser.uid);
    DocumentReference reference =
        Firestore.instance.collection('users').document(firebaseUser.uid);
    await Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(reference, {'name': name}).then((onValue) {
        _updateNameInSharedPrefs(name);
      });
    });
  }

  void _updateNameInSharedPrefs(String name) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', name);
  }

  @override
  Future<String> getCurrentUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('name');
  }

  @override
  Future<String> getCurrentUserEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('email');
  }

  @override
  Future<String> getProfileUrlFromSharedPrefs() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('photo_url');
  }

  @override
  Future<bool> updateProfileUrlOnFirestore(String photoUrl) async {
    firebaseUser = await FirebaseAuth.instance.currentUser();
    DocumentReference reference =
        Firestore.instance.collection('users').document(firebaseUser.uid);
    await Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction
          .update(reference, {'photo_url': photoUrl}).then((onValue) {
        _updateProfileUrlInSharedPrefs(photoUrl).then((result) {
          return result;
        });
      });
    });
    return false;
  }

  Future<bool> _updateProfileUrlInSharedPrefs(String photoUrl) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('photo_url', photoUrl).then((onValue) {
      return true;
    });
    return false;
  }

  @override
  Future<bool> uploadNewItemToDatabase(
      String name,
      int quantity,
      String description,
      List<String> tags,
      List<File> images,
      BuildContext context) async {
    DateTime dateTime = DateTime.now();
    List<String> artifactPhotoUrls = [];
    String byName;
    firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser.displayName == null) {
      byName = firebaseUser.email;
    } else {
      byName = firebaseUser.displayName;
    }
    await getCurrentPosition();

    images.forEach((image) {
      StorageReference storageRef = FirebaseStorage.instance
          .ref()
          .child('artifacts_images')
          .child(firebaseUser.uid +
              dateTime.toString() +
              images.indexOf(image).toString() +
              ".jpg");
      StorageUploadTask task = storageRef.putFile(image);
      task.onComplete.then((taskSnapshot) {
        print("Artifact object uploaded");
        storageRef.getDownloadURL().then((url) {
          artifactPhotoUrls.add(url);

          if (artifactPhotoUrls.length == images.length) {
            print("all images uploaded");

            Firestore.instance.runTransaction((Transaction transaction) async {
              DocumentReference reference =
                  Firestore.instance.collection('artifacts').document();
              await transaction.set(reference, {
                'name': name,
                'by_name': byName,
                'by_uid': firebaseUser.uid,
                'time_added': dateTime,
                'photo_urls': artifactPhotoUrls,
                'location': GeoPoint(position.latitude, position.longitude),
                'quantity': quantity,
                "description": description,
                "tags": tags,
                "document_id": reference.documentID,
              });
            }).then((onValue) {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop(true);
            });
          }
        });
      });
    });
  }

  Future<LocationData> getCurrentPosition() async {
    print("location method was called");
    LocationData currentLocation;
    var location = new Location();
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();
      position = currentLocation;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
      currentLocation = null;
    }
    print(position.latitude.toString() + " --------------------------------- ");
    return position;
  }

  Future<List<Item>> getInitialFeedItems() async {
    List<Item> initialItems = [];
    Firestore firestoreInstance = Firestore.instance;
    firestoreInstance.settings(
        persistenceEnabled: true, timestampsInSnapshotsEnabled: true);
    final querySnapshot = await firestoreInstance
        .collection('artifacts')
        .orderBy('time_added', descending: true)
        .limit(10)
        .getDocuments();
    initialItems
        .addAll(querySnapshot.documents.map((DocumentSnapshot document) {
      return Item.fromDocumentSnapshot(document);
    }).toList());
    return initialItems;
  }

  Future<List<Item>> getNextFiveFeedItems(Item lastItem) async {
    List<Item> nextFiveItems = [];
    print("next five called");
    final querySnapshot = await Firestore.instance
        .collection('artifacts')
        .orderBy('time_added', descending: true)
        .limit(5)
        .startAfter([lastItem.timeAdded]).getDocuments();
    nextFiveItems
        .addAll(querySnapshot.documents.map((DocumentSnapshot document) {
      return Item.fromDocumentSnapshot(document);
    }).toList());
    return nextFiveItems;
  }

  Future<bool> editItemInDatabase(Item editedItem, List<File> newImages,
      List<String> deletedImagesUrls, BuildContext context) async {
    print("i was called");
    DateTime dateTime = DateTime.now();
    List<String> artifactNewPhotoUrls = [];
    firebaseUser = await FirebaseAuth.instance.currentUser();

    if (newImages.length > 0) {
      newImages.forEach((image) {
        StorageReference storageRef = FirebaseStorage.instance
            .ref()
            .child('artifacts_images')
            .child(firebaseUser.uid +
                dateTime.toString() +
                newImages.indexOf(image).toString() +
                ".jpg");
        StorageUploadTask task = storageRef.putFile(image);
        task.onComplete.then((taskSnapshot) {
          print("New image uploaded");
          storageRef.getDownloadURL().then((url) {
            artifactNewPhotoUrls.add(url);

            if ((editedItem.photoUrls.length + newImages.length) ==
                (editedItem.photoUrls.length + artifactNewPhotoUrls.length)) {
              editedItem.photoUrls.addAll(artifactNewPhotoUrls);

              print(editedItem.photoUrls.toString());
              print("We can now move to updating firestore");
              Firestore.instance
                  .runTransaction((Transaction transaction) async {
                DocumentReference reference = Firestore.instance
                    .collection('artifacts')
                    .document(editedItem.documentId);
                await transaction.update(reference, editedItem.itemToJson());
              }).then((onValue) {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context).pop(true);
              });
            }
          });
        });
      });
    } else {
      Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentReference reference = Firestore.instance
            .collection('artifacts')
            .document(editedItem.documentId);
        await transaction.update(reference, editedItem.itemToJson());
      }).then((onValue) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop(true);
      });
    }
  }

  Future<List<Item>> getInitialUploadedItems() async {
    List<Item> initialItems = [];
    firebaseUser = await FirebaseAuth.instance.currentUser();
    String uid = firebaseUser.uid;
    Firestore firestoreInstance = Firestore.instance;
    firestoreInstance.settings(
        persistenceEnabled: true, timestampsInSnapshotsEnabled: true);
    final querySnapshot = await firestoreInstance
        .collection('artifacts')
        .where('by_uid', isEqualTo: uid)
        .orderBy('time_added', descending: true)
        .limit(10)
        .getDocuments();
    initialItems
        .addAll(querySnapshot.documents.map((DocumentSnapshot document) {
      return Item.fromDocumentSnapshot(document);
    }).toList());
    return initialItems;
  }

  Future<List<Item>> getNextFiveUploadedItems(Item lastItem) async {
    List<Item> nextFiveItems = [];
    print("next five called");
    firebaseUser = await FirebaseAuth.instance.currentUser();
    String uid = firebaseUser.uid;
    final querySnapshot = await Firestore.instance
        .collection('artifacts')
        .where('by_uid', isEqualTo: uid)
        .orderBy('time_added', descending: true)
        .limit(5)
        .startAfter([lastItem.timeAdded]).getDocuments();
    nextFiveItems
        .addAll(querySnapshot.documents.map((DocumentSnapshot document) {
      return Item.fromDocumentSnapshot(document);
    }).toList());
    return nextFiveItems;
  }

  Future<bool> deleteItemFromDatabase(String documentId, BuildContext context) async {
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      DocumentReference reference = Firestore.instance
          .collection('artifacts')
          .document(documentId);
      await myTransaction.delete(reference);
    }).then((onValue){
      Navigator.of(context).pop(true);
    });
  }
}
