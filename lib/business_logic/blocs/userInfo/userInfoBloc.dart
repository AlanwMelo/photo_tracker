import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoEvent.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoState.dart';

enum UpdateUserInfoStatus { initialUserStatus, updateUserStatus }

class BlocOfUserInfo extends Bloc<UpdateUserEvent, BlocOfUserInfoState> {
  BlocOfUserInfo(BlocOfUserInfoState initialState)
      : super(BlocOfUserInfoState.initialStatus()) {
    on<UpdateUserEventChanged>(_onUserInfoState);
  }
}

_onUserInfoState(
  UpdateUserEventChanged event,
  Emitter emit,
) {
  switch (event.status) {
    case UpdateUserInfoStatus.initialUserStatus:
      emit(BlocOfUserInfoState.initialStatus());
      break;
    case UpdateUserInfoStatus.updateUserStatus:
      emit(BlocOfUserInfoState.updateUserStatus(
          event.userName, event.userEmail, event.userProfilePic));
      break;
  }
}
