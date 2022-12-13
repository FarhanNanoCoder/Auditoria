import 'package:cloud_firestore/cloud_firestore.dart';

class AllFollowersModel{
  String uid;
  int timestamp;
  AllFollowersModel({this.uid, this.timestamp});
  factory AllFollowersModel.fromDocumentSnapshot(DocumentSnapshot doc){
    var allFollowersMap = doc.data();
    return AllFollowersModel(
      uid: allFollowersMap['uid'],
      timestamp: allFollowersMap['timestamp'],
    );
  }
  Map<String,dynamic>toMap(){
    Map<String,dynamic> allFollowersMap = {};
    allFollowersMap['uid'] = uid;
    allFollowersMap['timestamp']=timestamp;
    return allFollowersMap;
  }
}


class AllFollowingsModel{
  String uid;
  int timestamp;

  AllFollowingsModel({this.uid, this.timestamp});

  factory AllFollowingsModel.fromDocumentSnapshot(DocumentSnapshot doc){
    var allFollowingsMap = doc.data();
    return AllFollowingsModel(
      uid: allFollowingsMap['uid'],
      timestamp: allFollowingsMap['timestamp'],
    );
  }

  Map<String,dynamic>toMap(){
    Map<String,dynamic> allFollowingsMap = {};
    allFollowingsMap['uid'] = uid;
    allFollowingsMap['timestamp']=timestamp;
    return allFollowingsMap;
  }
}