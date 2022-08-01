class BlocOfUserInfoState {
  const BlocOfUserInfoState._({
    this.userName = '',
    this.userEmail = '',
    this.userProfilePic = '',
  });

  BlocOfUserInfoState.initialStatus() : this._();

  BlocOfUserInfoState.updateUserStatus(
      this.userName, this.userEmail, this.userProfilePic);

  BlocOfUserInfoState.updateUserName(
      this.userName, this.userEmail, this.userProfilePic);

  final String userName;
  final String userEmail;
  final String userProfilePic;
}
