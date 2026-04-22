class UserData {

  static UserData? _authorizedUser;

  int id;
  String login;
  String email;
  String password;
  int roleId;

  static void setUser(UserData user) {
    _authorizedUser = user;
  }

  static UserData? getUser() {
    return _authorizedUser;
  }

  static void clear() {
    _authorizedUser = null;
  }

  UserData({
    required this.id,
    required this.login,
    required this.email,
    required this.password,
    required this.roleId
  });

  factory UserData.fromMap(Map<String, dynamic> row){
    return UserData(
      id: row['id'] as int,
      login: row['name'] as String,
      email: row['email'] as String,
      password: row['password'] as String,
      roleId: row['role_id'] as int,
    );
  }
}


