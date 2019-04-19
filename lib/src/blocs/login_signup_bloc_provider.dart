import 'package:app_template_project/src/blocs/login_signup_bloc.dart';
import 'package:flutter/material.dart';

class LoginSignUpProvider extends InheritedWidget {

  final loginSignUpBloc = new LoginSignUpBloc();

  LoginSignUpProvider({Key key, Widget child})
    : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static LoginSignUpBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(LoginSignUpProvider) as LoginSignUpProvider).loginSignUpBloc;
  }

}