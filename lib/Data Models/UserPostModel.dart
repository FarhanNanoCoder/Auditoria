import 'package:cloud_firestore/cloud_firestore.dart';

class UserPostsModel{
  String uid;
  Map<String,int> posts={};

  UserPostsModel({this.uid, this.posts});

  factory UserPostsModel.fromDocumentSnapshot(DocumentSnapshot userPostsSnapshot){
    var userPostsModel = userPostsSnapshot.data();
    return UserPostsModel(
      uid: userPostsModel['uid'],
      posts: Map.from(userPostsModel['posts']),
    );
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> userPostsModel = Map<String,dynamic>();
    userPostsModel['uid'] = uid;
    userPostsModel['posts'] = posts;
    return userPostsModel;
  }
}