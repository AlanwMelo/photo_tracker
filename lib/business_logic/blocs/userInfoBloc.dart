import 'package:flutter_bloc/flutter_bloc.dart';

enum UserInfoEvent { updateName, updateEmail, updateProfilePic }

class BlocUserInfo extends Bloc<UserInfoState, List<dynamic>> {
  BlocUserInfo() : super(['1', '2', '3']) {
    on<UserInfoState>((event, emit) {
      print(event.userInfoEvent);
      print(event.updateValue);
      print(state[0]);
      print(state[1]);
      print(state[2]);

      switch (event.userInfoEvent) {
        case UserInfoEvent.updateName:
        case UserInfoEvent.updateEmail:
        case UserInfoEvent.updateProfilePic:
          emit(state[2] = [state[0], state[1], event.updateValue]);
      }

      print(state);
    });
  }
}

class UserInfoState {
  String updateValue;
  UserInfoEvent userInfoEvent;

  UserInfoState({required this.updateValue, required this.userInfoEvent});
}
