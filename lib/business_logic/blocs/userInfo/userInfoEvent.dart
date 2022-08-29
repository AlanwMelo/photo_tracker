import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoBloc.dart';

abstract class UpdateUserEvent {
  const UpdateUserEvent();
}

class UpdateUserEventChanged extends UpdateUserEvent {
  const UpdateUserEventChanged(
      this.status, this.userName, this.userEmail, this.userProfilePic, this.userID);

  final UpdateUserInfoStatus status;
  final String userName;
  final String userEmail;
  final String userProfilePic;
  final String userID;
}
