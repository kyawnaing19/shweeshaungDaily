class UserRegistrationData {
  String? name;
  String? email;
  String? password;
  String? phone;
  String? semester;
  String? userClass;
  String? major;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
    'semester': semester,
    'userClass': userClass,
    'major': major,
  };
}
