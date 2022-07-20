import 'package:flutter/material.dart';
import 'package:photo_tracker/layouts/Widgets/loginScreen/divisor.dart';
import 'package:photo_tracker/layouts/Widgets/loginScreen/loginFormField.dart';
import 'package:photo_tracker/layouts/Widgets/trackerSimpleButton.dart';
import 'package:photo_tracker/layouts/screens/login/signUp.dart';
import 'package:photo_tracker/layouts/screens/new_post/tackerSignButton.dart';
import 'package:photo_tracker/userRelated/googleSingIn.dart';

class TrackerSignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TrackerSignInPageState();
}

class _TrackerSignInPageState extends State<TrackerSignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          color: Colors.blueAccent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _firstText(),
                _icon(),
                SizedBox(height: 30),
                _emailFormField(),
                SizedBox(height: 30),
                _passwordFormField(),
                _continueButton(),
                _divisor(),
                _socialSignUp(),
                _lastText(),
              ],
            ),
          )),
    );
  }

  _firstText() {
    return Container(
      margin: EdgeInsets.only(top: 70),
      child: Row(
        children: [
          SizedBox(width: 20),
          Container(
            child: Text(
              'Welcome \n'
              '  Tracker',
              style: TextStyle(
                fontSize: 35,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _icon() {
    return Container(
      margin: EdgeInsets.all(18),
      height: 250,
      width: 250,
      child: Image.asset('lib/assets/Icon.png'),
    );
  }

  _emailFormField() {
    return TrackerLoginFormField(icon: Icons.email_outlined, hint: 'Email');
  }

  _passwordFormField() {
    return TrackerLoginFormField(
        icon: Icons.lock_outline_rounded, hint: 'Senha');
  }

  _continueButton() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      height: 60,
      width: 120,
      child: TrackerSimpleButton(
        text: 'Conectar',
        pressed: (_) {},
      ),
    );
  }

  _divisor() {
    return TrackerDivisor();
  }

  _socialSignUp() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
              onTap: () {
                TrackerGoogleSignIn().signInWithGoogle();
              },
              child: _googleButton()),
          InkWell(
              onTap: () {
                TrackerGoogleSignIn().signInWithGoogle();
              },
              child: _facebookButton())
        ],
      ),
    );
  }

  _lastText() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Not a tracker?',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TrackerSignUpPage()));
            },
            child: Text(
              'Sign Up',
              style: TextStyle(color: Colors.yellow),
            ),
          ),
        ],
      ),
    );
  }

  _googleButton() {
    return TrackerSignButton(
      text: 'Sign In with Google',
      imgURL:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/800px-Google_%22G%22_Logo.svg.png',
    );
  }

  _facebookButton() {
    return TrackerSignButton(
      text: 'Sign In with Facebook',
      imgURL:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Facebook_f_logo_%282019%29.svg/1365px-Facebook_f_logo_%282019%29.svg.png',
    );
  }
}
