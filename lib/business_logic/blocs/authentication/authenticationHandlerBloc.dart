import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_tracker/business_logic/blocs/authentication/authenticationEvent.dart';
import 'package:photo_tracker/business_logic/blocs/authentication/authenticationState.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class BlocOfAuthentication
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  BlocOfAuthentication(AuthenticationState initialState)
      : super(const AuthenticationState.unknown()) {
    on<AuthenticationStatusChanged>(_onAuthenticationStatusChanged);

    _authenticationStatusSubscription =
        FirebaseAuth.instance.userChanges().listen((event) {
      if (event != null) {
        add(AuthenticationStatusChanged(AuthenticationStatus.authenticated));
      } else {
        add(AuthenticationStatusChanged(AuthenticationStatus.unauthenticated));
      }
    });
    /*_authenticationStatusSubscription = _authenticationRepository.status.listen(
          (status) => add(AuthenticationStatusChanged(status)),
    );*/
  }

  late StreamSubscription _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    return super.close();
  }
}

_onAuthenticationStatusChanged(
  AuthenticationStatusChanged event,
  Emitter<AuthenticationState> emit,
) async {
  switch (event.status) {
    case AuthenticationStatus.unauthenticated:
      return emit(const AuthenticationState.unauthenticated());
    case AuthenticationStatus.authenticated:
      return emit(const AuthenticationState.authenticated());
    /*final user = await _tryGetUser();
      return emit(user != null
          ? AuthenticationState.authenticated(user)
          : const AuthenticationState.unauthenticated());*/
    default:
      return emit(const AuthenticationState.unknown());
  }
}
