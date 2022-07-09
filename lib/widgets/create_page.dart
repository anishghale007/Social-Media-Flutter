import 'dart:io';

import 'package:fire_project/provider/auth_provider.dart';
import 'package:fire_project/provider/crudProvider.dart';
import 'package:fire_project/provider/image_provider.dart';
import 'package:fire_project/provider/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class CreatePage extends StatelessWidget {

  final titleController = TextEditingController();
  final detailController = TextEditingController();

  final _form = GlobalKey<FormState>();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Page'),
        backgroundColor: Colors.purple,
      ),
      body: Consumer(
          builder: (context, ref, child) {
            final image = ref.watch(imageProvider).image;
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
                      Text('Create Form',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        controller: titleController,
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
                        controller: detailController,
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
                          child: image == null ? Center(child: Text('Select an image'),) : Image.file(File(image.path)),
                        ),
                      ),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: () async {
                        _form.currentState!.save();
                        if(_form.currentState!.validate()) {
                            if (image == null) {
                              Get.dialog(AlertDialog(
                                  title: Center(child: Text('Image required')),
                                  content: Text('Please select an image'),
                                  actions: [
                                    IconButton(onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                      icon: Icon(Icons.close),),
                                  ]
                                ),
                              );
                            } else {
                              final response = await ref.read(crudProvider).postAdd(
                                    title: titleController.text.trim(),
                                    description: detailController.text.trim(),
                                    image: image,
                                    userId: uid
                                );
                              if(response == 'Success') {
                                Navigator.of(context).pop();
                              } else {
                                Get.showSnackbar(GetSnackBar(
                                  duration: Duration(seconds: 8),
                                  title: 'Error',
                                  message: response,
                                ),);
                              }
                            }
                          }
                        },
                        child: Text('Submit'),
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
