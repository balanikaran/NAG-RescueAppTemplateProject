import 'package:app_template_project/src/helpers/error_codes.dart';
import 'package:app_template_project/src/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

//FOR FACEBOOK LOGIN
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';

//FOR TWITTER LOGIN
// import 'package:flutter_twitter_login/flutter_twitter_login.dart';

abstract class BaseAuth {
  Future<String> createUserWithEmailIdAndPassword(
      String email, String password);

  Future<String> signInWithEmailIdAndPassword(String email, String password);

  Future<String> signInWithGoogle();

  Future<FirebaseUser> getCurrentUser();
//FOR FACEBOOK LOGIN
// Future<FirebaseUser> signInWithFacebook();

//FOR TWITTER LOGIN
// Future<FirebaseUser> signInWithTwitter();
}

class FirebaseAuthenticator implements BaseAuth {
  final firebaseAuthInstance = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser newUser;
  final fireStoreInstance = Firestore.instance;

  //FOR FACEBOOK LOGIN
  // final FacebookLogin facebookLogin = FacebookLogin();

  //FOR TWITTER LOGIN
  // TwitterLogin twitterLoginSecret = new TwitterLogin(
  //     consumerKey: "---Paste here---",
  //     consumerSecret: "---Paste here---");

  @override
  Future<String> createUserWithEmailIdAndPassword(
      String email, String password) async {
    int code;
    try {
      newUser = await firebaseAuthInstance.createUserWithEmailAndPassword(
          email: email, password: password);
      print("${newUser.toString()}");
      code = 900;
      await createUserOnFirestoreDatabase(newUser);
    } catch (error) {
      if (error.toString().contains('ERROR_WEAK_PASSWORD')) {
        code = 901;
      } else if (error.toString().contains('ERROR_INVALID_CREDENTIAL')) {
        code = 902;
      } else if (error.toString().contains('ERROR_EMAIL_ALREADY_IN_USE')) {
        await firebaseAuthInstance
            .fetchSignInMethodsForEmail(email: email)
            .then((listMethods) {
          print(listMethods.toString());
          if (listMethods.contains('google.com')) {
            code = 912;
          } else if (listMethods.contains('facebook') ||
              listMethods.contains('twitter')) {
            code = 913;
          } else {
            code = 903;
          }
        });
      } else {
        code = 911;
      }
    }
    return CustomFirebaseErrorCodes
        .customFirebaseErrors[code - 900].userMessage;
  }

  @override
  Future<String> signInWithEmailIdAndPassword(
      String email, String password) async {
    int code;
    try {
      newUser = await firebaseAuthInstance.signInWithEmailAndPassword(
          email: email, password: password);
      print("${newUser.toString()}");
      code = 900;
      await saveUserToSharedPrefs();
    } catch (error) {
      if (error.toString().contains('ERROR_WRONG_PASSWORD')) {
        await firebaseAuthInstance
            .fetchSignInMethodsForEmail(email: email)
            .then((listMethods) {
          print(listMethods.toString());
          if (listMethods.contains('google.com')) {
            code = 912;
          } else if (listMethods.contains('facebook') ||
              listMethods.contains('twitter')) {
            code = 913;
          } else {
            code = 904;
          }
        });
      } else if (error.toString().contains('ERROR_USER_NOT_FOUND')) {
        code = 905;
      } else if (error.toString().contains('ERROR_USER_DISABLED')) {
        code = 906;
      } else if (error.toString().contains('ERROR_TOO_MANY_REQUESTS')) {
        code = 907;
      } else {
        code = 911;
      }
    }
    return CustomFirebaseErrorCodes
        .customFirebaseErrors[code - 900].userMessage;
  }

  @override
  Future<String> signInWithGoogle() async {
    int code;
    try {
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential googleAuthCredentials =
          GoogleAuthProvider.getCredential(
              idToken: googleSignInAuthentication.idToken,
              accessToken: googleSignInAuthentication.accessToken);

      newUser = await firebaseAuthInstance
          .signInWithCredential(googleAuthCredentials);
      print("${newUser.toString()}");
      code = 900;
      await createUserOnFirestoreDatabase(newUser);
    } catch (error) {
      if (error.toString().contains('ERROR_INVALID_CREDENTIAL')) {
        code = 901;
      } else if (error
          .toString()
          .contains('ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL')) {
        code = 902;
      } else if (error.toString().contains('ERROR_OPERATION_NOT_ALLOWED')) {
        code = 903;
      } else if (error.toString().contains('ERROR_USER_DISABLED')) {
        code = 906;
      } else {
        code = 911;
      }
    }
    return CustomFirebaseErrorCodes
        .customFirebaseErrors[code - 900].userMessage;
  }

  Future createUserOnFirestoreDatabase(FirebaseUser newUser) async {
    String name, photoUrl;
    name = newUser.displayName ?? "";
    photoUrl = newUser.photoUrl ?? "";
    User user = User(newUser.email, name: name, photoUrl: photoUrl);
    print(user.toString());
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference reference =
          Firestore.instance.collection('users').document(newUser.uid);
      await transaction.set(reference, user.userToJson());
    });
    await saveUserToSharedPrefs();
  }

  Future<void> saveUserToSharedPrefs() async {
    print("shared prefs were called");
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    print("Shared prefs = " + newUser.email);
    sharedPrefs.setString('name', newUser.displayName);
    sharedPrefs.setString('email', newUser.email);
    sharedPrefs.setString(
        'photo_url',
        newUser.photoUrl ??
            "https://firebasestorage.googleapis.com/v0/b/app-template-project.appspot.com/o/user_profile_photos%2Ftemp%20user%20image.png?alt=media&token=dcdf34ec-56d9-46c8-8d2a-b91fa2ff8932");
  }

  void signOutUser() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.clear();
    await firebaseAuthInstance.signOut();
  }

  @override
  Future<FirebaseUser> getCurrentUser() {
    FirebaseAuth.instance.currentUser().then((user) {
      return user;
    });
  }

//FOR TWITTER LOGIN
// @override
// Future<FirebaseUser> signInWithTwitter() async {
//   TwitterLoginResult result = await twitterLoginSecret.authorize();
//   if (result.status == TwitterLoginStatus.loggedIn) {
//     try {
//       newUser = await firebaseAuthInstance.signInWithTwitter(
//           authToken: result.session.token,
//           authTokenSecret: result.session.secret);
//       return newTwitterUser;
//     } catch (error) {
//       print(error.toString());
//     }
//   }
//   return null;
// }

//FOR FACEBOOK LOGIN
// @override
// Future<FirebaseUser> signInWithFacebook() async {
//   try {
//     FacebookLoginResult facebookLoginResult = await facebookLogin
//         .logInWithReadPermissions(['email', 'public_profile']);
//     if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
//       newUser = await firebaseAuthInstance.signInWithFacebook(
//           accessToken: facebookLoginResult.accessToken.token);
//       return newFacebookUser;
//     }
//   } catch (error) {
//     print(error.toString());
//   }
//   return null;
// }
}
