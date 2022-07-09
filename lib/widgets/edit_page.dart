import 'dart:io';

import 'package:fire_project/model/post.dart';
import 'package:fire_project/provider/auth_provider.dart';
import 'package:fire_project/provider/crudProvider.dart';
import 'package:fire_project/provider/image_provider.dart';
import 'package:fire_project/provider/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class EditPage extends StatelessWidget {

  final Post post;
  EditPage(this.post);

  final titleController = TextEditingController();
  final detailController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Page'),
        backgroundColor: Colors.purple,
      ),
      body: Consumer(
          builder: (context, ref, child) {
            final db = ref.watch(imageProvider);
            return Form(
              key: _form,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  height: 550,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      Text('Edit Form',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        controller: titleController..text = post.title,
                        validator: (val) {
                          if(val!.isEmpty) {
                            return 'Title is required';
                          }
                          if(val.length > 40) {
                            return 'Maximum username length is 40';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Post Title',
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: detailController..text = post.description,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          if(val!.isEmpty) {
                            return 'Description is required';
                          }
                          if(val.length > 200) {
                            return 'Maximum username length is 200';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Description',
                        ),
                      ),
                      SizedBox(height: 40),
                      InkWell(
                        onTap: () {
                          ref.read(imageProvider).getImage();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          height: 200,
                          child: db.image == null ? Image.network(post.imageUrl) : Image.file(File(db.image!.path), fit: BoxFit.cover,),
                        ),
                      ),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: () async {
                          _form.currentState!.save();
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                          if(_form.currentState!.validate()) {
                            if (db.image == null) {
                              final response = await ref.read(crudProvider).postUpdate(
                                  title: titleController.text.trim(),
                                  description: detailController.text.trim(),
                                  postId: post.id
                              );
                              if(response == 'Success') {
                                Navigator.of(context).pop();
                              }
                            } else {
                              final response = await ref.read(crudProvider).postUpdate(
                                  title: titleController.text.trim(),
                                  description: detailController.text.trim(),
                                  postId: post.id,
                                  imageId: post.imageId,
                                  image: db.image,
                              );
                              if(response == 'Success') {
                                Navigator.of(context).pop();
                              }

                              }
                            }
                          },
                          child: Text('Update Post'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}
