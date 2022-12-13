import 'dart:io';
import 'package:auditoria/Authentication/AuthService.dart';
import 'package:auditoria/Data%20Models/AllFollowersAndFollowingsModel.dart';
import 'package:auditoria/Data%20Models/NotificationsModel.dart';
import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Data%20Models/SavedPostModel.dart';
import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Data%20Models/UserPostModel.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DatabaseService{
  final CollectionReference userCollections = FirebaseFirestore.instance.collection('users');
  final CollectionReference allPostCollections = FirebaseFirestore.instance.collection('allPosts');
  final CollectionReference userPostCollections = FirebaseFirestore.instance.collection('userPosts');
  final CollectionReference postLikesCollections = FirebaseFirestore.instance.collection('postLikes');
  final CollectionReference postCommentsCollections = FirebaseFirestore.instance.collection('postComments');
  final CollectionReference userLiveData = FirebaseFirestore.instance.collection('liveData');
  final CollectionReference allFollowersCollection = FirebaseFirestore.instance.collection('allFollowers');
  final CollectionReference allFollowingsCollection = FirebaseFirestore.instance.collection('allFollowings');
  final CollectionReference savedPostsCollection = FirebaseFirestore.instance.collection('savedPosts');
  final CollectionReference notificationsCollection = FirebaseFirestore.instance.collection('notifications');
  final CollectionReference reportedProblemCollection = FirebaseFirestore.instance.collection('reportedProblems');
  final CollectionReference accountDeleteReasonCollection = FirebaseFirestore.instance.collection('accountDeleteReasons');


  Stream<DocumentSnapshot> getUserStreamData(String uid){
    Stream<DocumentSnapshot> documentSnapshot = userCollections.doc(uid).snapshots();
    return documentSnapshot;
  }

  Future<DocumentSnapshot> getUserFutureData(String uid)async {
    DocumentSnapshot documentSnapshot = await userCollections.doc(uid).get();
    if(documentSnapshot.exists){
      return documentSnapshot;
    }else{
      return null;
    }
  }

  Stream<QuerySnapshot> getAllPostsAsStream(){
    Stream<QuerySnapshot> querySnapshot = allPostCollections.orderBy('timestamp',descending: true).snapshots();
    return querySnapshot;
  }

  Future<QuerySnapshot> getAllPostsAsFuture(){
    Future<QuerySnapshot> querySnapshot = allPostCollections.orderBy('timestamp',descending: true).get();
    return querySnapshot;
  }

  Stream<DocumentSnapshot> getSpecificPostAsStream(String pid){
    Stream<DocumentSnapshot> querySnapshot = allPostCollections.doc(pid).snapshots();
    return querySnapshot;
  }

  Future<DocumentSnapshot> getSpecificPostAsFuture(String pid){
    Future<DocumentSnapshot> documentSnapshot = allPostCollections.doc(pid).get();
    return documentSnapshot;
  }

  Future<DocumentSnapshot> getPostLikesAsFuture(String pid){
    Future<DocumentSnapshot> documentSnapshot = postLikesCollections.doc(pid).get();
    return documentSnapshot;
  }

  Stream<DocumentSnapshot> getPostLikesAsStream(String pid){
    Stream<DocumentSnapshot> documentSnapshot = postLikesCollections.doc(pid).snapshots();
    return documentSnapshot;
  }

  Stream<QuerySnapshot> getPostCommentsAsStream(String pid){
    Stream<QuerySnapshot> querySnapshot = postCommentsCollections.doc(pid).
    collection('userComments').orderBy('timestamp',descending: false).snapshots();
    return querySnapshot;
  }

  Stream<DocumentSnapshot> getUserLiveDataAsStream(String uid){
    Stream<DocumentSnapshot> documentSnapshot = userLiveData.doc(uid).snapshots();
    return documentSnapshot;
  }

  Future<DocumentSnapshot> getUserLiveDataAsFuture(String uid){
    Future<DocumentSnapshot> documentSnapshot = userLiveData.doc(uid).get();
    return documentSnapshot;
  }

  Future<DocumentSnapshot> getSavedPostsAsFuture(String uid){
    Future<DocumentSnapshot> documentSnapshot = savedPostsCollection.doc(uid).get();
    return documentSnapshot;
  }

  Future<DocumentSnapshot> getUserPostsListsAsFuture(String uid){
    Future<DocumentSnapshot> documentSnapshot = userPostCollections.doc(uid).get();
    return documentSnapshot;
  }

  Future<QuerySnapshot> getUserNotificationsAsFuture(String uid){
    Future<QuerySnapshot> querySnapshot = notificationsCollection.doc(uid).collection('userNotifications')
        .orderBy('timestamp',descending: true).get();
    return querySnapshot;
  }

  Future<List<UserModel>> getUserFollowersAsUserModelListAsFuture(QuerySnapshot userFollowersSnapshot,String query) async {
    if(userFollowersSnapshot.size==0){
      return null;
    }

    List<UserModel> followers=[];
    for(var entry in userFollowersSnapshot.docs){
      DocumentSnapshot doc = await userCollections.doc(entry.data()['uid']).get();
      if(doc.exists){
        followers.add(UserModel.fromDocumentSnapshot(doc));
      }else{
        await entry.reference.delete();
      }
    }
    if(query!=null || query!=''){
      List<UserModel> expectedFollowers=[];
      for(var user in followers){
        if(user.username.toLowerCase().startsWith(query.toLowerCase())){
          expectedFollowers.add(user);
        }
      }
      return expectedFollowers;
    }else{
      return followers;
    }
  }

  Future<List<UserModel>> getUserFollowingsAsUserModelListAsFuture(QuerySnapshot userFollowingsCollection,String query) async {
    if(userFollowingsCollection.size==0){
      return null;
    }
    List<UserModel> followings=[];
    for(var entry in userFollowingsCollection.docs){

      DocumentSnapshot doc = await userCollections.doc(entry.data()['uid']).get();
      if(doc.exists){
        followings.add(UserModel.fromDocumentSnapshot(doc));
      }else{
        await entry.reference.delete();
      }
    }
    if(query!=null || query!=''){
      List<UserModel> expectedFollowings=[];
      for(var user in followings){
        if(user.username.toLowerCase().startsWith(query.toLowerCase())){
          expectedFollowings.add(user);
        }
      }
      return expectedFollowings;
    }else{
      return followings;
    }
  }


  Future<List<PostModel>> getUserAllPostsAsPostModelList(String uid)async{
    UserPostsModel userPostsModel = UserPostsModel.fromDocumentSnapshot(await getUserPostsListsAsFuture(uid));
    List<PostModel > postModels=[];
    // print('map size : '+userPostsModel.posts.length.toString());

    for(var entry in userPostsModel.posts.entries){
      await getSpecificPostAsFuture(entry.key).then((doc) {
        postModels.add(PostModel.fromDocumentSnapshot(doc));
        // print("Post added");
      });
    };
    // print('postmodel length :'+ postModels.length.toString());
    return postModels;
  }

  Future<List<PostModel>> getUserSavedPostsAsFutureAsPostModelList(String uid)async{
    QuerySnapshot querySnapshot = await  savedPostsCollection.doc(uid).collection('userSavedPosts')
        .orderBy('timestamp',descending: true).get();

    List<PostModel > postModels=[];
    for(var entry in querySnapshot.docs){
      await getSpecificPostAsFuture(entry.data()['pid']).then((doc) {
        if(doc.exists){
          postModels.add(PostModel.fromDocumentSnapshot(doc));
        }else{
          entry.reference.delete();
        }
        // print("Post added");
      });
    }
    return postModels;
  }


  Future updateUserData(UserModel userModel)async{
    return await userCollections.doc(userModel.uid).update(userModel.toMap());
  }

  Future<dynamic> reportProblem({String uid,String problem})async{

    String rid = reportedProblemCollection.doc().id.toString();
    await reportedProblemCollection.doc(rid).set({
      'uid':uid,
      'problem':problem,
      'rid':rid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  Future<dynamic> accountDeleteReason({String cause})async{

    String rid = accountDeleteReasonCollection.doc().id.toString();
    await accountDeleteReasonCollection.doc(rid).set({
      'uid': FirebaseAuth.instance.currentUser.uid,
      'cause':cause,
      'rid':rid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  updateFollowingsAndFollowers({String uid}) async {

    DocumentReference docRef = allFollowingsCollection
        .doc(FirebaseAuth.instance.currentUser.uid).collection('userFollowings').doc(uid);
    DocumentReference docRefFollowed = allFollowersCollection
        .doc(uid).collection('userFollowers').doc(FirebaseAuth.instance.currentUser.uid);
    DocumentSnapshot doc = await docRef.get();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    bool followed = false;

    if(doc.exists){
      docRef.delete();
      docRefFollowed.delete();
    }else{
      docRef.set(AllFollowingsModel(uid: uid,timestamp: timestamp).toMap());
      docRefFollowed.set(AllFollowersModel(uid: FirebaseAuth.instance.currentUser.uid,timestamp: timestamp).toMap());
      followed = true;
    }

    int currentFollowers = UserModelLiveData.fromDocumentSnapshot(await userLiveData
        .doc(uid).get()).followers;
    int currentFollowings = UserModelLiveData.fromDocumentSnapshot(await userLiveData
        .doc(FirebaseAuth.instance.currentUser.uid).get()).followings;
    if(followed){
      await userLiveData.doc(uid).update({'followers': currentFollowers+1});
      await userLiveData.doc(FirebaseAuth.instance.currentUser.uid).update({'followings': currentFollowings+1});
    }else{
      await userLiveData.doc(uid).update({'followers': currentFollowers-1});
      await userLiveData.doc(FirebaseAuth.instance.currentUser.uid).update({'followings': currentFollowings-1});
    }


    if(followed){
      String did  = notificationsCollection.doc(uid)
          .collection('userNotifications').doc().id.toString();

      UserModel userModel = UserModel
          .fromDocumentSnapshot(await userCollections.doc(FirebaseAuth.instance.currentUser.uid).get());

     String username = userModel.username,imageUrl = userModel.photoUrl;

      await notificationsCollection.doc(uid).collection('userNotifications')
          .doc(did).set(FollowNotificationModel(
        uid: FirebaseAuth.instance.currentUser.uid,
        did: did,
        username: username,
        timestamp: timestamp,
        imageUrl: imageUrl,
        isSeen: false,
      ).toMap());
    }
  }


  updatePostLikes({String ownerUid,String pid,PostLikes postLikes})async{
    bool willIncrease=true;
    int dateTime = DateTime.now().millisecondsSinceEpoch;

    if(postLikes.likes[FirebaseAuth.instance.currentUser.uid]==null){
      postLikes.likes[FirebaseAuth.instance.currentUser.uid]=dateTime;
    }else{
      postLikes.likes.remove(FirebaseAuth.instance.currentUser.uid);
      willIncrease=false;
    }

    postLikesCollections.doc(pid).update({'likes' : postLikes.likes});
    allPostCollections.doc(pid).update({'totalLikes':postLikes.likes.length});

    DocumentSnapshot liveDataSnapshot = await getUserLiveDataAsFuture(ownerUid);
    UserModelLiveData liveData = UserModelLiveData.fromDocumentSnapshot(liveDataSnapshot);
    willIncrease?liveData.totalLikes+=1:liveData.totalLikes-=1;

    if(liveData.totalLikes<0){liveData.totalLikes=0;}

    await userLiveData.doc(ownerUid).update({'totalLikes': liveData.totalLikes});
    await userCollections.doc(ownerUid).update({'totalLikes': liveData.totalLikes});

    //notification section
    if(FirebaseAuth.instance.currentUser.uid!=ownerUid && willIncrease){

      String did  = notificationsCollection.doc(ownerUid)
          .collection('userNotifications').doc().id.toString();
      String username = UserModel
          .fromDocumentSnapshot(await userCollections.doc(FirebaseAuth.instance.currentUser.uid).get())
          .username;
      String imageUrl = PostModel.fromDocumentSnapshot(await allPostCollections.doc(pid).get()).imageUrl;

      await notificationsCollection.doc(ownerUid).collection('userNotifications')
          .doc(did).set(LikeNotificationModel(
        uid: FirebaseAuth.instance.currentUser.uid,
        pid: pid,
        did: did,
        username: username,
        timestamp: dateTime,
        imageUrl: imageUrl,
        isSeen: false,
      ).toMap());
    }
  }

  updateSavedPosts({BuildContext context,String pid})async{
   DocumentReference docRef = savedPostsCollection
       .doc(FirebaseAuth.instance.currentUser.uid)
   .collection('userSavedPosts').doc(pid);
   DocumentSnapshot doc = await docRef.get();
   if(doc.exists){
     docRef.delete();
   }else{
     await docRef.set(SavedPostModel(pid: pid,timestamp: DateTime.now().millisecondsSinceEpoch).toMap());
     Toast(context: context).showTextToast('Saved');
   }
  }

  addPostComment({String comment,String pid,int totalComments})async{
    String cid = postCommentsCollections.doc(pid).collection('userComments').doc().id.toString();
    await postCommentsCollections.doc(pid).collection('userComments').doc(cid).set(
        CommentsModel(
          cid : cid,
          comment: comment,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          uid: FirebaseAuth.instance.currentUser.uid,
        ).toMap()
    );
    await allPostCollections.doc(pid).update({'totalComments': (totalComments+1)});
  }

  deletePostComment({String cid,String pid,int totalComments})async{
    await postCommentsCollections.doc(pid).collection('userComments').doc(cid).delete();
    await allPostCollections.doc(pid).update({'totalComments': (totalComments-1)});
  }

  Future deleteUser(String uid)async{
    deleteFile(pathToFile,fileName){
      var ref= FirebaseStorage.instance.ref().child(pathToFile);
      var childRef = ref.child(fileName);
      childRef.delete();
    }
    deleteFolderContents(path){
      var ref = FirebaseStorage.instance.ref().child(path);
      ref.listAll().then((value) => {
        value.items.forEach((fileRef) {
          deleteFile(ref.fullPath,fileRef.name);
        }),
        value.prefixes.forEach((folderRef) {
          deleteFolderContents(folderRef.fullPath);
        })
      }).catchError((error){
        print(error.toString());
      });
    }

    deleteFolderContents(uid);

    UserPostsModel userPostsModel = UserPostsModel.fromDocumentSnapshot(await getUserPostsListsAsFuture(uid));
    if(userPostsModel.posts!=null){

      userPostsModel.posts.forEach((pid, value) async {
        await allPostCollections.doc(pid).delete();
        await postLikesCollections.doc(pid).delete();

        QuerySnapshot querySnapshot = await postCommentsCollections.doc(pid).collection('userComments').get();
          querySnapshot.docs.forEach((c)async{
            await postCommentsCollections.doc(pid).collection('userComments').doc(CommentsModel.fromDocumentSnapshot(c).cid).delete();
          });

      });
    }
    // await followersCollection.doc(uid).delete();
    // await followingsCollection.doc(uid).delete();
    await allFollowingsCollection.doc(uid).collection('userFollowings').get().then((query){
      for( var entry in query.docs){
        entry.reference.delete();
      }
    });
    await allFollowersCollection.doc(uid).collection('userFollowers').get().then((query){
      for( var entry in query.docs){
        entry.reference.delete();
      }
    });
    await savedPostsCollection.doc(uid).collection('userSavedPosts').get().then((query){
      for( var entry in query.docs){
        entry.reference.delete();
      }
    });
    await allFollowersCollection.doc(uid).delete();
    await savedPostsCollection.doc(uid).delete();
    await userPostCollections.doc(uid).delete();
    await userLiveData.doc(uid).delete();
    await userCollections.doc(uid).delete();

  }

  // ignore: missing_return
  Future<String> updateProfileImage({File image,String uid})async{
    String url;
    Reference reference = FirebaseStorage.instance.ref().child('$uid/profilePicture/$uid.jpg');
    UploadTask uploadTask = reference.putFile(image);
    await uploadTask.whenComplete(() async {
      print('File uploaded');
      url = await reference.getDownloadURL();
      //print(url);
    }).catchError((e){
      print(e.toString());
    });
    return url;
  }


  Future<QuerySnapshot> getSearchResults({String query,bool searchByUsername}) async {
    if(query==null || query.isEmpty){
      return null;
    }else if(searchByUsername){
      return await userCollections.where('username',isGreaterThanOrEqualTo: query)
         .where('username',isLessThan: query+'z').get()??null;
        //.orderBy('username').startAt([query.toUpperCase()]).endAt([query+'\uf8ff']).get()??null;
    }else{
      return await userCollections.where('artistType',isGreaterThanOrEqualTo: query)
          .where('artistType',isLessThan: query+'z').get()??null;
    }
  }


  Future createUserdata(UserModel user) async{

    user.emailViewMode= 'Public';
    user.livingPlaceViewMode='Public';
    user.phoneNoViewMode='Public';
    user.birthdayViewMode='Public';
    user.artistType = 'Art-Enthusiast';
    user.gender = 'Male';
    user.androidNotificationToken = await FirebaseMessaging.instance.getToken();
    print('user created in database uid :'+user.uid);

    // await followersCollection.doc(user.uid).set(
    //   Followers(uid: user.uid,followers: {}).toMap()
    // );
    // await followingsCollection.doc(user.uid).set(
    //     Followings(uid: user.uid,followings: {}).toMap()
    // );
    await userLiveData.doc(user.uid).set(
        UserModelLiveData(
          uid: user.uid,
          followings: 0, followers: 0,
          totalPosts: 0, totalLikes: 0,
          recentNotifications: 0,
        ).toMap()
    );
    await userPostCollections.doc(user.uid).set(
        UserPostsModel(uid: user.uid,posts: {}).toMap()
    );
    return await userCollections.doc(user.uid)
        .set(user.toMap());
  }

  Future uploadPostImage({File image,String uid,String pid})async{
    String url;
    Reference reference = FirebaseStorage.instance.ref().child('$uid/posts/$pid.jpg');

    UploadTask uploadTask = reference.putFile(image);
    await uploadTask.whenComplete(() async {
      print('File uploaded');
      url = await reference.getDownloadURL();
      //print(url);
    }).catchError((e){
      print(e.toString());
    });
    return url;
  }

  Future createPost({PostModel postModel,File image}) async{
    String pid = allPostCollections.doc().id.toString();
    postModel.uid = FirebaseAuth.instance.currentUser.uid;
    postModel.pid = pid;
    postModel.imageUrl = await uploadPostImage(image: image,uid: postModel.uid,pid: pid).catchError((error){
      return 1;
    });
    postModel.totalLikes=0;
    postModel.timestamp = DateTime.now().millisecondsSinceEpoch;

    DocumentSnapshot userPostsSnapshot = await userPostCollections.doc(postModel.uid).get();
    UserPostsModel userPostsModel = UserPostsModel.fromDocumentSnapshot(userPostsSnapshot);

    if(userPostsModel.posts!=null){
      userPostsModel.posts[pid] = DateTime.now().millisecondsSinceEpoch;
    }else{
      List<String> posts = [];
      posts.add(pid);
      userPostsModel.posts[pid] = DateTime.now().millisecondsSinceEpoch;
    }

    await postLikesCollections.doc(postModel.pid).set(PostLikes(
      pid: postModel.pid,
      likes: {},
    ).toMap());

    await userPostCollections.doc(postModel.uid).update(userPostsModel.toMap()).catchError((error){
      print(error.toString());
      return 2;
    });
    await allPostCollections.doc(pid).set(postModel.toMap()).catchError((error){
      print(error.toString());
      return 3;
    });
    UserModelLiveData userModelLiveData = UserModelLiveData
        .fromDocumentSnapshot(await getUserLiveDataAsFuture(postModel.uid));
    userLiveData.doc(postModel.uid).update({'totalPosts' : (userModelLiveData.totalPosts+1)});
    return 0;
  }

  Future updatePost({String description,List<String> tags,File file,String pid})async{
    await allPostCollections.doc(pid).update({'description': description}).catchError((error){
      return 1;
    });
    await allPostCollections.doc(pid).update({'tags': tags}).catchError((error){
      return 2;
    });
    if(file!=null){
      String imageUrl = await uploadPostImage(image: file,uid: FirebaseAuth.instance.currentUser.uid.toString(),pid: pid).catchError((error){
        return 3;
      });
      await allPostCollections.doc(pid).update({'imageUrl': imageUrl});
    }
    return 0;
  }

  Future deletePost({BuildContext context,String pid,int totalLikes})async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    UserPostsModel userPostsModel = UserPostsModel.
    fromDocumentSnapshot(await getUserPostsListsAsFuture(uid));
    userPostsModel.posts.remove(pid);
    await userPostCollections.doc(uid).update({'posts': userPostsModel.posts});


    UserModelLiveData liveData = UserModelLiveData
        .fromDocumentSnapshot(await getUserLiveDataAsFuture(uid));
    await userLiveData.doc(uid).update(
        {'totalLikes': (liveData.totalLikes - totalLikes)});
    await userLiveData.doc(uid).update(
        {'totalPosts': (liveData.totalPosts - 1)});

    await userCollections.doc(uid).update(
        {'totalLikes': (liveData.totalLikes - totalLikes)});
    await allPostCollections.doc(pid).delete();
    await postLikesCollections.doc(pid).delete();

    QuerySnapshot querySnapshot = await postCommentsCollections.doc(pid)
        .collection('userComments')
        .get();
    querySnapshot.docs.forEach((c) async {
      await postCommentsCollections.doc(pid).collection('userComments').doc(
          CommentsModel
              .fromDocumentSnapshot(c)
              .cid).delete();
    });
    await FirebaseStorage.instance.ref().child('$uid/posts/$pid.jpg').delete();

    Toast(context: context).showTextToast('Post deleted');
    return 0;
  }
}