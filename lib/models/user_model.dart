class UserModel {
  final String? email;
  final String? password;
  final bool? stayLoggedIn;
  final String? nickName;
  final String? userName;
  final String? semsester;
  final String? major;
  final String? userClass;

  UserModel({
    this.email,
    this.password,
    this.stayLoggedIn,
    this.nickName,
    this.userName,
    this.semsester,
    this.major,
    this.userClass,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'stayLoggedIn': stayLoggedIn,
    'nickName': nickName,
    'userName': userName,
    'semsester': semsester,
    'major': major,
    'userClass': userClass,
  };
}
