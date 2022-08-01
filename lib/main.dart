import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_tracker/db/dbManager.dart';
import 'package:photo_tracker/presentation/authenticationHandler.dart';
import 'package:photo_tracker/business_logic/blocs/authentication/authenticationHandlerBloc.dart';
import 'package:photo_tracker/business_logic/blocs/authentication/authenticationState.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenBloc.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenState.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoBloc.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoState.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final DBManager dbManager = DBManager();

  runApp(MyApp(dbManager: dbManager));
}

class MyApp extends StatelessWidget {
  final DBManager dbManager;

  const MyApp({Key? key, required this.dbManager}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<BlocOfUserInfo>(
              create: (BuildContext context) =>
                  BlocOfUserInfo(BlocOfUserInfoState.initialStatus())),
          BlocProvider<BlocOfAuthentication>(create: (BuildContext context) {
            if (FirebaseAuth.instance.currentUser != null) {
              return BlocOfAuthentication(
                  const AuthenticationState.authenticated());
            } else {
              return BlocOfAuthentication(
                  const AuthenticationState.unauthenticated());
            }
          }),
          BlocProvider<BlocOfLoadingCoverScreen>(
              create: (BuildContext context) => BlocOfLoadingCoverScreen(
                  LoadingCoverScreenState.notLoading())),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Photo Tracker',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: handleAuthState(context),
        ));
  }
}
