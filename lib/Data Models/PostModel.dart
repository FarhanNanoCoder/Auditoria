import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel{
  String pid,uid,description='',imageUrl;
  int timestamp;
  List<String> tags=[];
  int totalLikes = 0,totalComments=0;


  PostModel({this.pid, this.uid, this.description, this.imageUrl, this.timestamp,
      this.tags, this.totalLikes=0,this.totalComments=0});

  factory PostModel.fromDocumentSnapshot(DocumentSnapshot postSnapshot){
    var postMap = postSnapshot.data();
    return PostModel(
      pid: postMap['pid'],
      uid: postMap['uid'],
      timestamp: postMap['timestamp'],
      description: postMap['description'],
      imageUrl: postMap['imageUrl'],
      totalLikes: postMap['totalLikes'],
      totalComments: postMap['totalComments'],
      tags: postMap['tags']!=null?List.from(postMap['tags']):[],
    );
  }

  Map<String,dynamic> toMap(){
   final Map<String,dynamic> postMap = Map<String,dynamic>();
   postMap['pid'] =pid;
   postMap['uid'] =uid;
   postMap['timestamp'] = timestamp;
   postMap['description'] = description;
   postMap['imageUrl'] = imageUrl;
   postMap['totalLikes'] = totalLikes;
   postMap['totalComments'] = totalComments;
   postMap['tags'] = tags;
   return postMap;
  }
}

class PostLikes{
  String pid;
  Map<String,int> likes={};

  PostLikes({this.pid, this.likes});

  factory PostLikes.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    var postLikesMap = documentSnapshot.data();
    return PostLikes(
      pid: postLikesMap['pid'],
      likes: Map.from(postLikesMap['likes']),
    );
  }

  Map<String, dynamic> toMap(){
    Map<String,dynamic> postLikesMap={};
    postLikesMap['pid'] = pid;
    postLikesMap['likes'] = likes;
    return postLikesMap;
  }
}

class CommentsModel {
  String comment;
  int timestamp;
  String uid, cid;

  CommentsModel({this.uid, this.comment, this.timestamp, this.cid});

  factory CommentsModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    var postCommentsMap = documentSnapshot.data();
    return CommentsModel(
      comment: postCommentsMap['comment'],
      timestamp: postCommentsMap['timestamp'],
      uid: postCommentsMap['uid'],
      cid: postCommentsMap['cid'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> postCommentsMap = {};
    postCommentsMap['comment'] = comment;
    postCommentsMap['timestamp'] = timestamp;
    postCommentsMap['uid'] = uid;
    postCommentsMap['cid'] = cid;
    return postCommentsMap;
  }
}
