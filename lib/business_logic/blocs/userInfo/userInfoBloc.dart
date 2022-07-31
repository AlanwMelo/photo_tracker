import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoEvent.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoState.dart';

enum UpdateUserInfoStatus { initialUserStatus, updateUserStatus }

class BlocOfUserInfo extends Bloc<UpdateUserEvent, UpdateUserInfoState> {
  BlocOfUserInfo(UpdateUserInfoState initialState)
      : super(UpdateUserInfoState.initialStatus()) {
    on<UpdateUserEventChanged>(_onLoadingCoverScreenState);
  }
}

_onLoadingCoverScreenState(
  UpdateUserEventChanged event,
  Emitter emit,
) {
  switch (event.status) {
    case UpdateUserInfoStatus.initialUserStatus:
      emit(UpdateUserInfoState.initialStatus());
      break;
    case UpdateUserInfoStatus.updateUserStatus:
      emit(UpdateUserInfoState.updateUserStatus(
          event.userName, event.userEmail, event.userProfilePic));
      break;
  }
}
