import 'dart:io';

import 'package:fire_project/provider/auth_provider.dart';
import 'package:fire_project/provider/image_provider.dart';
import 'package:fire_project/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class AuthScreen extends StatelessWidget {

  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth Screen'),
        backgroundColor: Colors.purple,
      ),
        body: Consumer(
          builder: (context, ref, child) {
            final isLogin = ref.watch(loginProvider);     // used to have the widget/provider listen to a provider
            final image = ref.watch(imageProvider).image;
            final isLoad = ref.watch(loadingProvider);
            return Form(
              key: _form,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Container(
                    height: isLogin ? 350 : 650,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20),
                        Text(isLogin ? 'Login Form' : 'SignUp Form', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                        SizedBox(height: 20,),
                        if(isLogin == false) TextFormField(
                          textCapitalization: TextCapitalization.words,
                          controller: nameController,
                          validator: (val) {
                            if(val!.isEmpty) {
                              return 'Username is required';
                            }
                            if(val.length > 30) {
                              return 'Maximum username length is 30';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Username',
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: mailController,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if(val!.isEmpty) {
                              return 'Email is required';
                            }
                            if(!val.contains('@')) {
                              return 'Please provide a valid email address';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Email',
                          ),
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          validator: (val) {
                            if(val!.isEmpty) {
                              return 'Password is required';
                            }
                            if(val.length > 20) {
                              return 'Maximum password length is 20';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                          ),
                        ),
                        SizedBox(height: 40),
                        if(isLogin == false) InkWell(
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
                        ElevatedButton(onPressed: () async {
                            _form.currentState!.save();
                            ref.read(loadingProvider.notifier).toggle();
                            if(_form.currentState!.validate()) {
                              if(isLogin) {
                                FocusScope.of(context).unfocus();
                                final response = await ref.read(authProvider).loginUser(
                                    email: mailController.text.trim(),
                                    password: passwordController.text.trim(),
                                );
                                if(response != 'Success') {
                                  ref.read(loadingProvider.notifier).toggle();
                                  Get.showSnackbar(GetSnackBar(
                                    duration: Duration(seconds: 2),
                                    title:  'Some error occurred',
                                    message: response,
                                  ));
                                }
                              } else {
                                if (image == null) {
                                  Get.dialog(AlertDialog(
                                      title: Text('Image required'),
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
                                  FocusScope.of(context).unfocus();
                                  await ref.read(authProvider).userSignUp(
                                      username: nameController.text.trim(),
                                      email: mailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      image: image
                                  );
                                  ref.refresh(authProvider);
                                }
                              }
                            }
                        }, child: isLoad ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text('Loading please wait...', style: TextStyle(fontSize: 15),),
                           SizedBox(width: 15,),
                           SizedBox(
                             height: 15,
                               width: 15,
                               child: CircularProgressIndicator(color: Colors.white,)),
                         ],
                        ) : Text('Submit')),
                        Row(
                          children: [
                            Text(isLogin ? 'Don\'t have an account?' : 'Already have an account?'),
                            TextButton(onPressed: () {
                              ref.read(loginProvider.notifier).toggle();   // A way to obtain the state of a provider without listening to it. commonly used inside functions triggered by user interactions.
                            }, child: Text(isLogin ? 'Signup' : 'Login')),
                          ],
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
