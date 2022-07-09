import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// listens to data. If login then user data will be in FirebaseAuth instance. If not then null
final authStatusProvider = StreamProvider.autoDispose((ref) => FirebaseAuth.instance.authStateChanges());

final authProvider = Provider.autoDispose((ref) => AuthProvider());


class AuthProvider {

  CollectionReference dbUser = FirebaseFirestore.instance.collection('users');


  Future<String> userSignUp({required String username, required String email, required String password, required XFile image}) async {
    try{
      final imageId = DateTime.now().toString();
      final ref = FirebaseStorage.instance.ref().child('userImage/$imageId');
      final imageFile = File(image.path);
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      UserCredential response = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      
      await dbUser.add({
        'username' : username,
        'email' : email,
        'imageUrl' : url,
        'userId' : response.user!.uid,
      });

      return 'Success';

    } on FirebaseAuthException catch(err) {
      print(err);
      return '${err.message}';
    }
  }


  Future<String> loginUser({required String email, required String password}) async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      return 'Success';
    }on FirebaseException catch (err){
      print(err);
      return '${err.message}';
    }
  }


  Future<String> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return 'Success';
    } on FirebaseAuthException catch(err) {
      return '';
    }
  }

}