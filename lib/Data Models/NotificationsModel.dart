import 'package:cloud_firestore/cloud_firestore.dart';

class LikeNotificationModel{
  String eventType = 'like';
  String pid,username,imageUrl,did,uid;
  int timestamp;
  bool isSeen = false;
  LikeNotificationModel({this.uid,this.did,this.pid, this.username, this.imageUrl, this.timestamp,this.isSeen});

  factory LikeNotificationModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    var likeNotificationMap = documentSnapshot.data();
    return LikeNotificationModel(
      uid: likeNotificationMap['uid'],
      did :likeNotificationMap['did'],
      pid: likeNotificationMap['pid'],
      username: likeNotificationMap['username'],
      imageUrl: likeNotificationMap['imageUrl'],
      timestamp: likeNotificationMap['timestamp'],
      isSeen: likeNotificationMap['isSeen'],
    );
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> likeNotificationMap ={};
    likeNotificationMap['uid'] = uid;
    likeNotificationMap['did'] = did;
    likeNotificationMap['eventType'] = eventType;
    likeNotificationMap['pid'] = pid;
    likeNotificationMap['username'] =username;
    likeNotificationMap['imageUrl'] = imageUrl;
    likeNotificationMap['timestamp'] = timestamp;
    likeNotificationMap['isSeen'] = isSeen;
    return likeNotificationMap;
  }

  String getMessage(){
    return username+' reacted on your post';
  }
}

class FollowNotificationModel{
  String eventType = 'follow';
  String uid,username,imageUrl,did;
  int timestamp;
  bool isSeen = false;
  FollowNotificationModel({this.did,this.uid, this.username, this.imageUrl, this.timestamp,this.isSeen});

  factory FollowNotificationModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    var followNotificationMap = documentSnapshot.data();
    return FollowNotificationModel(
      did: followNotificationMap['did'],
      uid: followNotificationMap['uid'],
      username: followNotificationMap['username'],
      imageUrl: followNotificationMap['imageUrl'],
      timestamp: followNotificationMap['timestamp'],
      isSeen: followNotificationMap['isSeen'],
    );
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> followNotificationMap ={};
    followNotificationMap['did'] = did;
    followNotificationMap['eventType'] = eventType;
    followNotificationMap['uid'] = uid;
    followNotificationMap['username'] =username;
    followNotificationMap['imageUrl'] = imageUrl;
    followNotificationMap['timestamp'] = timestamp;
    followNotificationMap['isSeen'] = isSeen;
    return followNotificationMap;
  }

  String getMessage(){
    return username+' has started following you';
  }
}

class FollowersPostNotificationModel{
  String eventType = 'followersPost';
  String pid,username,imageUrl,did,uid;
  int timestamp;
  bool isSeen = false;
  FollowersPostNotificationModel({this.uid,this.did,this.pid, this.username, this.imageUrl, this.timestamp,this.isSeen});

  factory FollowersPostNotificationModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    var followersPostMap = documentSnapshot.data();
    return FollowersPostNotificationModel(
      uid: followersPostMap['uid'],
      did :followersPostMap['did'],
      pid: followersPostMap['pid'],
      username: followersPostMap['username'],
      imageUrl: followersPostMap['imageUrl'],
      timestamp: followersPostMap['timestamp'],
      isSeen: followersPostMap['isSeen'],
    );
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> followersPostMap ={};
    followersPostMap['uid'] = uid;
    followersPostMap['did'] = did;
    followersPostMap['eventType'] = eventType;
    followersPostMap['pid'] = pid;
    followersPostMap['username'] =username;
    followersPostMap['imageUrl'] = imageUrl;
    followersPostMap['timestamp'] = timestamp;
    followersPostMap['isSeen'] = isSeen;
    return followersPostMap;
  }

  String getMessage(){
    return username+' posted something. Check it out!';
  }
}