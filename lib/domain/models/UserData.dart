class UserData {
  String login;
  String email;
  String password;

  UserData({
    required this.login,
    required this.email,
    required this.password
});
}

List<UserData> users = [
  UserData(login: '1111', email: '1@1.1', password: '123123'),
  UserData(login: '1', email: '1@1.1', password: '1'),

];

