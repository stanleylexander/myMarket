class User {
  int id;
  String email;
  String username;
  String password;
  String role;

  User({
    required this.id,
    required this.email,
    required this.username, 
    required this.password,
    required this.role
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['id'], 
      email: json['email'], 
      username: json['username'], 
      password: json['password'], 
      role: json['role']
    );
  }
}