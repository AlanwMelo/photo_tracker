class UpdateUserInfoState {
  const UpdateUserInfoState._({
    this.userName = '',
    this.userEmail = '',
    this.userProfilePic = '',
  });

  UpdateUserInfoState.initialStatus() : this._();

  UpdateUserInfoState.updateUserStatus(
      this.userName, this.userEmail, this.userProfilePic);

  UpdateUserInfoState.updateUserName(
      this.userName, this.userEmail, this.userProfilePic);

  final String userName;
  final String userEmail;
  final String userProfilePic;
}
