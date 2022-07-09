import 'package:fire_project/model/post.dart';
import 'package:fire_project/provider/crudProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user.dart';

class DetailPage extends StatelessWidget {
  final Post post;
  final User user;
  DetailPage(this.post, this.user);
  final _form = GlobalKey<FormState>();
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
        backgroundColor: Colors.purple,
      ),
      body: Form(
        key: _form,
        child: Consumer(builder: (context, ref, child) {
          final postStream = ref.watch(postProvider);
          return ListView(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      post.description,
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none),
                          fillColor: Color(0xFFF2F3F5),
                          filled: true,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          _form.currentState!.save();
                          final comment = Comments(
                              username: user.username,
                              imageUrl: user.imageUrl,
                              comment: commentController.text.trim());
                          ref.read(crudProvider).addComment(
                              postId: post.id,
                              comments: [
                                ...post.comments,
                                comment
                              ] //  old with new comment
                              );
                          commentController.clear();
                        },
                        child: Text('Submit'),
                      ),
                    ),
                    if (post.comments.isNotEmpty)
                      postStream.when(
                        data: (data) {
                          final postData = data
                              .firstWhere((element) => element.id == post.id);
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ListView(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              children: postData.comments.map((e) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Card(
                                    borderOnForeground: false,
                                    shadowColor: Color(0xFFF2F3F5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Color(0xFFF2F3F5)),),
                                    child: ListTile(
                                      tileColor: Color(0xFFF2F3F5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Color(0xFFF2F3F5)),),
                                      leading: CircleAvatar(backgroundImage: NetworkImage(e.imageUrl),),
                                      title: Text(e.username, style: TextStyle(fontWeight: FontWeight.bold),),
                                      subtitle: Text(e.comment),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                        error: (err, stack) => Text('$err'),
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: Colors.purple,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
