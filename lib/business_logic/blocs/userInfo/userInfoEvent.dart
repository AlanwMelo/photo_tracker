import 'package:equatable/equatable.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoBloc.dart';

abstract class UpdateUserEvent extends Equatable {
  const UpdateUserEvent();

  @override
  List<Object> get props => [];
}

class UpdateUserEventChanged extends UpdateUserEvent {
  const UpdateUserEventChanged(this.status, this.userName, this.userEmail, this.userProfilePic);

  final UpdateUserInfoStatus status;
  final String userName;
  final String userEmail;
  final String userProfilePic;

  @override
  List<Object> get props => [status];
}
