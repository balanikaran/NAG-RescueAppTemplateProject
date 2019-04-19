import 'package:app_template_project/src/blocs/validators.dart';
import 'package:app_template_project/src/helpers/firebase_authenticator.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class LoginSignUpBloc extends Object with Validators {
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();

  // recieve data from stream
  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get password => _password.stream.transform(validatePassword);
  Stream<bool> get submitValid =>
      Observable.combineLatest2(email, password, (e, p) => true);

  // add data to stream
  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changePassword => _password.sink.add;

  Future<String> submitNewUser() {
    print("submit called");
    final validEmail = _email.value;
    final validPassword = _password.value;

    FirebaseAuthenticator firebaseAuthenticator = new FirebaseAuthenticator();
    print('$validEmail and $validPassword');
    return firebaseAuthenticator.createUserWithEmailIdAndPassword(
        validEmail, validPassword);
  }

  Future<String> submitExistingUser() {
    print("submit called");
    final validEmail = _email.value;
    final validPassword = _password.value;

    FirebaseAuthenticator firebaseAuthenticator = new FirebaseAuthenticator();
    print('$validEmail and $validPassword');
    return firebaseAuthenticator.signInWithEmailIdAndPassword(
        validEmail, validPassword);
  }

  Future<String> signInWithGoogle() {
    FirebaseAuthenticator firebaseAuthenticator = new FirebaseAuthenticator();
    return firebaseAuthenticator.signInWithGoogle();
  }

  void signOutUser(){
    FirebaseAuthenticator firebaseAuthenticator = new FirebaseAuthenticator();
    firebaseAuthenticator.signOutUser();
  }

  // signInWithFacebook(){
  //   FirebaseAuthenticator firebaseAuthenticator = new FirebaseAuthenticator();
  //   firebaseAuthenticator.signInWithFacebook();
  // }

  // signInWithTwitter(){
  //   FirebaseAuthenticator firebaseAuthenticator = new FirebaseAuthenticator();
  //   firebaseAuthenticator.signInWithTwitter();
  // }

  dispose() {
    _email.close();
    _password.close();
  }
}

final loginSignUpBloc = LoginSignUpBloc();
