import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_project/model/post.dart';
import 'package:fire_project/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


final crudProvider = Provider.autoDispose((ref) => CrudProvider());
final postProvider = StreamProvider.autoDispose((ref) => CrudProvider().getData());
final userProvider = StreamProvider.autoDispose((ref) => CrudProvider().getUserData());
final userStream = StreamProvider.autoDispose((ref) => CrudProvider().getSingleUser());


class CrudProvider {

  CollectionReference dbPosts = FirebaseFirestore.instance.collection('posts');
  CollectionReference dbUsers = FirebaseFirestore.instance.collection('users');


  Future<String> postAdd({required String title, required String description, required XFile image, required userId}) async {
    try{
      final imageId = DateTime.now().toString();
      final ref = FirebaseStorage.instance.ref().child('postImage/$imageId');
      final imageFile = File(image.path);
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await dbPosts.add({
        'title' : title,
        'description' : description,
        'imageUrl' : url,
        'userId' : userId,
        'imageId' : imageId,
        'likes' : {
          'like' : 0,
          'usernames' : []
        },
        'comments' : []
      });
      return 'Success';
    } on FirebaseException catch(err) {
      print(err);
      return '';
    }
  }


  Stream<List<Post>> getData(){
    return dbPosts.snapshots().map((event) => getPostsData(event));
  }

  List<Post> getPostsData(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((e){
      final json = e.data() as Map<String, dynamic>;
      return Post(
          id: e.id,
          imageId: json['imageId'],
          imageUrl: json['imageUrl'],
          userId: json['userId'],
          title: json['title'],
          description: json['description'],
          likeData: Like.fromJson(json['likes']),
          comments: (json['comments'] as List).map((e) => Comments.fromJson(e as Map<String, dynamic>)).toList()
      );
    }).toList();
  }


  Stream<List<User>> getUserData() {
    return dbUsers.snapshots().map((event) => UserData(event));
  }

  List<User> UserData(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((e) => User.fromJson((e.data() as Map<String, dynamic>))).toList();
  }


  Future<String> postUpdate({required String title, required String description, XFile? image,
    required String postId, String? imageId }) async {
    try{

      if(image != null) {
        final imageFile = File(image.path);
        final ref1 = FirebaseStorage.instance.ref().child('postImage/$imageId');
        await ref1.delete();
        final newImageId = DateTime.now().toString();
        final ref2 = FirebaseStorage.instance.ref().child('postImage/$newImageId');
        await ref2.putFile(imageFile);
        final url = await ref2.getDownloadURL();

        await dbPosts.doc(postId).update({
          'title' : title,
          'description' : description,
          'imageUrl' : url,
          'imageId' : newImageId
        });
      } else {
        await dbPosts.doc(postId).update({
          'title' : title,
          'description' : description,
        });
      }

      return 'Success';
    } on FirebaseException catch(err) {
      print(err);
      return '';
    }
  }




  Future<String> postRemove({required String postId, required String imageId}) async {
    try{
      final ref = FirebaseStorage.instance.ref().child('postImage/$imageId');
      await ref.delete();
      await dbPosts.doc(postId).delete();
      return 'Success';
    } on FirebaseException catch(err) {
      print(err);
      return '';
    }
  }



  Stream<User> getSingleUser() {
    final uid = auth.FirebaseAuth.instance.currentUser!.uid;
    final user = dbUsers.where('userId', isEqualTo: uid).snapshots();
    return user.map((event) => singleUser(event));
  }

  User singleUser(QuerySnapshot querySnapshot) {
    final singleData = querySnapshot.docs[0].data() as Map<String, dynamic>;
    return User.fromJson(singleData);
  }



  Future<void> addlike(Like like, String postId) async {
    try{
      await dbPosts.doc(postId).update({
        'likes' : like.toJson()
      });
    } on FirebaseException catch (err) {
      print(err);
    }

  }



  Future<void> removelike(String postId, String username, int like) async {
    try{
      await dbPosts.doc(postId).update({
        'likes' : {
          'like' : like - 1,
          'usernames' : FieldValue.arrayRemove([username])
        }
      });
    } on FirebaseException catch (err) {
      print(err);
    }

  }



  Future<void> addComment({required String postId, required List<Comments> comments}) async {
    try{
      await dbPosts.doc(postId).update({
        'comments' : comments.map((e) => e.toJson()).toList()
      });
    } on FirebaseException catch (err) {
      print(err);
    }

  }



}

