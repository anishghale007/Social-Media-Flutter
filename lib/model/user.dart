

class User {

  final String imageUrl;
  final String userId;
  final String username;
  final String email;


  User({
    required this.imageUrl,
    required this.userId,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {

    return User(
        imageUrl: json['imageUrl'],
        userId: json['userId'],
        username: json['username'],
        email: json['email']
    );

  }


}