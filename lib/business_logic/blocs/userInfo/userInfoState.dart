import 'package:equatable/equatable.dart';

class UpdateUserInfoState extends Equatable {
  const UpdateUserInfoState._({
    this.userName = '',
    this.userEmail = '',
    this.userProfilePic = '',
  });

  UpdateUserInfoState.initialStatus() : this._();

  UpdateUserInfoState.updateUserStatus(
      this.userName, this.userEmail, this.userProfilePic);

  final String userName;
  final String userEmail;
  final String userProfilePic;

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
