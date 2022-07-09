import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifierProvider is used to listen to and expose a StateNotifier
final loginProvider = StateNotifierProvider.autoDispose<LoginProvider, bool>((ref) => LoginProvider());

class LoginProvider extends StateNotifier<bool>{
  LoginProvider() : super(true);


  //if the state is true it will be false. If false then true
  void toggle() {
    state =! state;
  }

}


final loadingProvider = StateNotifierProvider.autoDispose<LoadingProvider, bool>((ref) => LoadingProvider());

class LoadingProvider extends StateNotifier<bool>{
  LoadingProvider() : super(false);


  //if the state is true it will be false. If false then true
  void toggle() {
    state =! state;
  }

}