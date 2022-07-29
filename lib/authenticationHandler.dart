import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_tracker/business_logic/blocs/authentication/authenticationHandlerBloc.dart';
import 'package:photo_tracker/business_logic/blocs/authentication/authenticationState.dart';
import 'package:photo_tracker/presentation/screens/homePage.dart';
import 'package:photo_tracker/presentation/screens/login/signIn.dart';

handleAuthState(BuildContext context) {
  return BlocListener<BlocOfAuthentication, AuthenticationState>(
    listener: (context, state) {
      print('listener $state');
    },
    child: BlocBuilder<BlocOfAuthentication, AuthenticationState>(
      builder: (context, state) {
        if (state.status == AuthenticationStatus.authenticated) {
          return TrackerHomePage(title: 'Photo Tracker');
        } else {
          return TrackerSignInPage();
        }
      },
    ),
  );
}
