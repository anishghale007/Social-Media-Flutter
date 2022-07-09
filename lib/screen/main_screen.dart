import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_project/main.dart';
import 'package:fire_project/model/post.dart';
import 'package:fire_project/provider/crudProvider.dart';
import 'package:fire_project/widgets/detail_page.dart';
import 'package:fire_project/widgets/drawer_widget.dart';
import 'package:fire_project/widgets/edit_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../location service/location_notification.dart';
import '../model/user.dart';

class MainScreen extends StatefulWidget {

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final uid = auth.FirebaseAuth.instance.currentUser!.uid;

  late User user;

  @override
  void initState() {
    super.initState();

    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
          (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    // 2. This method only call when App in foreground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
          (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);

        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );
    getToken();
  }


  Future getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print(token);
  }



    @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final apps = AppBar(
          title: Text('Main Screen'),
          backgroundColor: Colors.purple,
        );
        final appBarHeight = apps.preferredSize.height;
        final topBarHeight = MediaQuery.of(context).padding.top;
        final h = MediaQuery.of(context).size.height;
        final actualHeight = h - appBarHeight - topBarHeight;
        print(actualHeight - 600);
        return Scaffold(
          appBar: apps,
          drawer: DrawerWidget(),
          body: Consumer(
              builder: (context, ref, child) {
                final postStream = ref.watch(postProvider);
                final userStream = ref.watch(userProvider);
                return Column(
                  children: [
                    userStream.when(
                        data: (data) {
                          return Container(
                            margin: EdgeInsets.only(top: 15),
                            height: actualHeight - 600,
                            child: ListView.builder(
                                itemCount: data.length,
                                scrollDirection: Axis.horizontal,
                                // default is vertical
                                itemBuilder: (context, index) {
                                  user = data.firstWhere((element) => element.userId == uid);
                                  final dat = data[index];
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 55,
                                          backgroundImage: NetworkImage(
                                              dat.imageUrl),
                                        ),
                                        SizedBox(height: 13),
                                        Text(dat.username, style: TextStyle(
                                            fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  );
                                }
                            ),
                          );
                        },
                        error: (err, stack) => Text('$err'),
                        loading: () => Container()
                    ),

                    postStream.when(
                        data: (data) {
                          return Container(
                            margin: EdgeInsets.only(top: 15),
                            height: actualHeight - 181 - 31,
                            child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final dat = data[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Expanded(child: Text(dat.title,
                                                  style: TextStyle(
                                                      fontSize: 15),
                                                  overflow: TextOverflow
                                                      .ellipsis,)),
                                                if(uid ==
                                                    dat.userId) IconButton(
                                                    onPressed: () {
                                                      Get.defaultDialog(
                                                          title: 'Customize your post',
                                                          content: Text(
                                                              'Actions'),
                                                          actions: [
                                                            IconButton(
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();
                                                                  Get.to(() => EditPage(dat), transition: Transition.leftToRight);
                                                                },
                                                                icon: Icon(Icons
                                                                    .edit)),
                                                            IconButton(
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();
                                                                  showDialog(context: context, builder: (context) => AlertDialog(
                                                                    title: Text('Are you sure you want to remove the post?'),
                                                                    actions: [
                                                                      TextButton(onPressed: () async {
                                                                        Navigator.of(context).pop();
                                                                        await ref.read(crudProvider).postRemove(
                                                                            postId: dat.id,
                                                                            imageId: dat.imageId);
                                                                      }, child: Text('Yes')),
                                                                      TextButton(onPressed: () {
                                                                         Navigator.of(context).pop();
                                                                      }, child: Text('No')),
                                                                    ],
                                                                  ),
                                                                  );
                                                                },
                                                                icon: Icon(Icons
                                                                    .delete)),
                                                          ]
                                                      );
                                                    },
                                                    icon: Icon(Icons
                                                        .more_horiz_outlined)),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Get.to(() => DetailPage(dat, user), transition: Transition.leftToRight);
                                              },
                                              child: Container(
                                                  height: 400,
                                                  width: double.infinity,
                                                  child: Image.network(
                                                    dat.imageUrl,
                                                    fit: BoxFit.cover,)),
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text(dat.description, maxLines: 3,
                                                  style: TextStyle(
                                                      color: Colors.blueGrey,
                                                      letterSpacing: 1,
                                                      fontSize: 18),),
                                                Spacer(),
                                                Row(
                                                  children: [
                                                    IconButton(onPressed: () async {
                                                      // if(dat.userId != uid) {
                                                        if(dat.likeData.usernames.contains(user.username)){
                                                          // ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                                                          // ScaffoldMessenger.of(context).showSnackBar(
                                                          //     SnackBar(content: Text('You\'ve already liked this post'),
                                                          //       duration: Duration(seconds: 3))
                                                          // );
                                                          // final likes = Like(
                                                          //     usernames: [],
                                                          //     like: dat.likeData.like - 1
                                                          // );
                                                          // ref.read(crudProvider).addlike(likes, dat.id);
                                                          ref.read(crudProvider).removelike(dat.id, user.username, dat.likeData.like);
                                                        } else {
                                                          final likes = Like(
                                                              usernames: [...dat.likeData.usernames, user.username],
                                                              like: dat.likeData.like + 1
                                                          );
                                                          ref.read(crudProvider).addlike(likes, dat.id);
                                                        }
                                                      // }
                                                      // else {
                                                      //   ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                                      //     SnackBar(content: Text('You can\'t like your own post'),
                                                      //         duration: Duration(seconds: 3))
                                                      //   );
                                                      // }
                                                    }, icon: Icon(Icons.thumb_up)),
                                                    if(dat.likeData.like != 0) Text('Like: ${dat.likeData.like}'),
                                                  ],
                                                )
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
                        },
                        error: (err, stack) => Text('$err'),
                        loading: () => Container()
                    ),

                  ],
                );
              }
          ),
        );
      }
    );
  }
}
