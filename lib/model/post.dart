

import 'package:cloud_firestore/cloud_firestore.dart';

class Post{

 late String id;
 late String imageId;
 late String imageUrl;
 late String userId;
 late String title;
 late String description;
 late Like likeData;
 late List<Comments> comments;


 Post({
  required this.id,
  required this.imageId,
  required this.imageUrl,
  required this.userId,
  required this.title,
  required this.description,
  required this.likeData,
  required this.comments
});

}




class Like{

 late int like;
 late List<String> usernames;


 Like({
  required this.usernames,
  required this.like
});

 // Changing the values into a model
 factory Like.fromJson(Map<String, dynamic> json) {
  return Like(
      usernames: (json['usernames'] as List).map((e) => (e as String)).toList(),
      like: json['like']
  );
 }

 // Changing the model into a map
 Map<String, dynamic> toJson() {
  return {
   'usernames': this.usernames,
   'like': this.like
  };
 }

}


class Comments {

 late String imageUrl;
 late String username;
 late String comment;

 Comments({
  required this.username,
  required this.imageUrl,
  required this.comment
});

 factory Comments.fromJson(Map<String, dynamic> json) {
  return Comments(
      username: json['username'],
      imageUrl: json['imageUrl'],
      comment: json['comment']
  );
 }

 Map<String, dynamic> toJson() {
  return {
   'comment' : this.comment,
   'username' : this.username,
   'imageUrl' : this.imageUrl
  };
 }

}