import 'package:flutter/material.dart';
import 'package:photo_tracker/business_logic/userRelated/googleSingIn.dart';
import 'package:photo_tracker/presentation/Widgets/loginScreen/divisor.dart';
import 'package:photo_tracker/presentation/Widgets/loginScreen/loginFormField.dart';
import 'package:photo_tracker/presentation/Widgets/trackerSimpleButton.dart';
import 'package:photo_tracker/presentation/screens/newPost/tackerSignButton.dart';

class TrackerSignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TrackerSignUpPageState();
}

class _TrackerSignUpPageState extends State<TrackerSignUpPage> {
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
                _nameFormField(),
                _emailFormField(),
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
              'Criar \n'
              '  Conta',
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

  _nameFormField() {
    return TrackerLoginFormField(hint: 'Nome', icon: Icons.person_rounded);
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
        text: 'Continuar',
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
                TrackerGoogleSignIn(context).signInWithGoogle();
              },
              child: _googleButton()),
          InkWell(
              onTap: () {
                TrackerGoogleSignIn(context).signInWithGoogle();
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
            'Already a tracker?',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Text(
              'Login',
              style: TextStyle(color: Colors.yellow),
            ),
          ),
        ],
      ),
    );
  }

  _googleButton() {
    return TrackerSignButton(text: 'Sign Up with Google', imgURL: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/800px-Google_%22G%22_Logo.svg.png',);
  }

  _facebookButton() {
    return TrackerSignButton(text: 'Sign Up with Facebook', imgURL: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Facebook_f_logo_%282019%29.svg/1365px-Facebook_f_logo_%282019%29.svg.png',);
  }
}
