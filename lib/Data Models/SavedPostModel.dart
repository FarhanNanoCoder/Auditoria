import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPostModel {
  String pid;
  int timestamp;

  SavedPostModel({this.pid, this.timestamp});
  factory SavedPostModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    var savedPostMap = documentSnapshot.data();
    return SavedPostModel(
      pid: savedPostMap['pid'],
      timestamp: savedPostMap['timestamp'],
    );
  }

  Map<String,dynamic>toMap(){
    Map<String,dynamic> savedPostMap ={};
    savedPostMap['pid'] = pid;
    savedPostMap['timestamp'] = timestamp;
    return savedPostMap;
  }
}