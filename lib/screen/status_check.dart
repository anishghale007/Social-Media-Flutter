import 'package:fire_project/provider/auth_provider.dart';
import 'package:fire_project/screen/auth_screen.dart';
import 'package:fire_project/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          final auth = ref.watch(authStatusProvider);
          return auth.when(
              data: (data){
                if(data == null) {
                  return AuthScreen();
                } else {
                  return MainScreen();
                }
              },
              error: (err, stack) => Text('$err'),
              loading: () => Center(child: CircularProgressIndicator(color: Colors.purple,)),
          );
    });
  }
}
