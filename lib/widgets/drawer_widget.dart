import 'package:fire_project/provider/auth_provider.dart';
import 'package:fire_project/provider/crudProvider.dart';
import 'package:fire_project/provider/login_provider.dart';
import 'package:fire_project/widgets/create_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class DrawerWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    final user = ref.watch(userStream);
    return user.when(
        data: (data) {
          return Drawer(
            child: Consumer(builder: (context, ref, child) {
              return ListView(
                children: [
                  DrawerHeader(
                    padding: EdgeInsets.only(top: 125, left: 20),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      image: DecorationImage(
                        opacity: 0.5,
                          image: NetworkImage(data.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Text(data.email, style: TextStyle(color: Colors.white),),
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle_rounded, size: 30),
                    title: Text(data.username),
                  ),
                  ListTile(
                    onTap: () {
                      Get.to(() => CreatePage(), transition: Transition.leftToRight);
                    },
                    leading: Icon(Icons.add_business_outlined, size: 30,),
                    title: Text('Create Post'),
                  ),
                  ListTile(
                    onTap: () {
                      ref.refresh(loginProvider);
                      ref.refresh(loadingProvider);
                      ref.read(authProvider).signOut();
                    },
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sign Out'),
                  ),
                ],
              );
            }),
          );
        },
        error: (err, stack) => Text('$err'),
        loading: () => CircularProgressIndicator(
          color: Colors.purple,
        ),
    );

  }
}
