import 'package:app_template_project/src/blocs/login_signup_bloc.dart';
import 'package:app_template_project/src/custom_widgets/fancy_button.dart';
import 'package:app_template_project/src/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/*
This page checks if the user has already logged in/ signed up
Else it promts for signin or login first
Or user exists it shows home page
*/

enum FormType {
  login,
  register,
}

class IntermediateLoginPage extends StatefulWidget {
  @override
  _IntermediateLoginPageState createState() => _IntermediateLoginPageState();
}

class _IntermediateLoginPageState extends State<IntermediateLoginPage> {
  final _formKey = GlobalKey<FormState>();
  FormType _formType = FormType.register;
  String errorMessageString = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login or Signup Page",
      home: Scaffold(
        body: Container(
          width: double.infinity,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _appLogoAndName(),
                      SizedBox(height: 24.0),
                      _loginOrSignupForm(),
                      SizedBox(height: 24.0),
                      _socialMedia(),
                      SizedBox(height: 24.0),
                      _switchLoginTypes(),
                      SizedBox(height: 8.0)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appLogoAndName() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 130.0,
          width: 130.0,
          child: Image.asset('assets/images/relief_portal_citizens.png'),
        ),
        SizedBox(
          height: 5.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Powered by"),
            SizedBox(
              width: 5.0,
            ),
            Container(
              width: 50.0,
              child: Image.asset('assets/images/nag_logo_2.png'),
            )
          ],
        ),
      ],
    );
  }

  Widget _loginOrSignupForm() {
    if (_formType == FormType.login) {
      return _createVaryingForm("Login");
    } else {
      return _createVaryingForm("Sign Up");
    }
  }

  Widget _createVaryingForm(String formButtonLabel) {
    return Container(
      margin: EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 0.0),
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                formButtonLabel + " Page",
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                title: StreamBuilder(
                  stream: loginSignUpBloc.email,
                  builder: (context, snapshot) {
                    return TextField(
                      onChanged: loginSignUpBloc.changeEmail,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "Email",
                        errorText: snapshot.error,
                        contentPadding:
                            EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0)),
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                title: StreamBuilder(
                  stream: loginSignUpBloc.password,
                  builder: (context, snapshot) {
                    return TextField(
                      obscureText: true,
                      onChanged: loginSignUpBloc.changePassword,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "Password",
                        errorText: snapshot.error,
                        contentPadding:
                            EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0)),
                      ),
                    );
                  },
                ),
              ),
              StreamBuilder(
                stream: loginSignUpBloc.submitValid,
                builder: (context, snapshot) {
                  return FancyButton(
                    onPressed: () {
                      Future<String> statusMessage;
                      if (formButtonLabel == "Login" && snapshot.hasData) {
                        statusMessage = loginSignUpBloc.submitExistingUser();
                        statusMessage.then((statusMessage) {
                          _checkStatusAndNavigate(statusMessage);
                          print(statusMessage);
                        });
                      } else if (formButtonLabel == "Sign Up" &&
                          snapshot.hasData) {
                        statusMessage = loginSignUpBloc.submitNewUser();
                        statusMessage.then((statusMessage) {
                          _checkStatusAndNavigate(statusMessage);
                          print(statusMessage);
                        });
                      }
                    },
                    text: Text(
                      formButtonLabel,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.blue,
                  );
                },
              ),
              SizedBox(
                width: 20.0,
                height: 20.0,
              ),
              Text(
                errorMessageString,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkStatusAndNavigate(String statusMessage) {
    if (statusMessage == "None") {
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
          builder: (context) => new HomePage(),
        ),
      );
    } else {
      setState(() {
        errorMessageString = statusMessage;
      });
    }
  }

  Widget _socialMedia() {
    if (_formType == FormType.login) {
      return _createVaryingSocialMedia("Login");
    } else {
      return _createVaryingSocialMedia("Sign Up");
    }
  }

  Widget _createVaryingSocialMedia(String socalMediaFormType) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Text("  " + "Or $socalMediaFormType with Social Media" + "  "),
              Expanded(
                flex: 1,
                child: Divider(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              iconSize: 36.0,
              onPressed: () async {
                // await loginSignUpBloc.signInWithFacebook();
              },
              icon: Icon(
                FontAwesomeIcons.facebook,
                color: Color(0xFF3b5998),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            IconButton(
              iconSize: 36.0,
              onPressed: () async {
                // await loginSignUpBloc.signInWithTwitter();
              },
              icon: Icon(
                FontAwesomeIcons.twitter,
                color: Color(0xFF00aced),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            IconButton(
              iconSize: 36.0,
              onPressed: () async {
                String statusMessage = await loginSignUpBloc.signInWithGoogle();
                _checkStatusAndNavigate(statusMessage);
              },
              icon: Icon(
                FontAwesomeIcons.googlePlus,
                color: Color(0xFFdd4b39),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _switchLoginTypes() {
    if (_formType == FormType.login) {
      return _createVaryingSwitch("Not a member yet?", "Register Now!");
    } else {
      return _createVaryingSwitch("Already a member?", "Login Now!");
    }
  }

  Widget _createVaryingSwitch(String question, String buttonLabel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 36.0,
            right: 36.0,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Text("  " + "$question" + "  "),
              Expanded(
                child: Divider(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        FlatButton(
          textColor: Colors.white,
          color: Colors.blueAccent,
          child: Text("$buttonLabel"),
          onPressed: () {
            if (_formType == FormType.login) {
              _switchToRegister();
            } else {
              _switchToLogin();
            }
          },
        ),
      ],
    );
  }

  void _switchToRegister() {
    setState(() {
      _formType = FormType.register;
      errorMessageString = "";
    });
  }

  void _switchToLogin() {
    setState(() {
      _formType = FormType.login;
      errorMessageString = "";
    });
  }
}
