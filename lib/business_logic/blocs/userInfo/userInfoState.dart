class BlocOfUserInfoState {
  const BlocOfUserInfoState._({
    this.userName = '',
    this.userEmail = '',
    this.userProfilePic = '',
    this.userID = '',
  });

  BlocOfUserInfoState.initialStatus() : this._();

  BlocOfUserInfoState.updateUserStatus(
      this.userName, this.userEmail, this.userProfilePic, this.userID);

  BlocOfUserInfoState.updateUserName(
      this.userName, this.userEmail, this.userProfilePic, this.userID);

  final String userName;
  final String userEmail;
  final String userProfilePic;
  final String userID;
}
