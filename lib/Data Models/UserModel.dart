import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String uid,
      username='',
      artistType='',
      bio='',
      birthdayViewMode='public',birthDate='',
      phoneNo='',phoneNoViewMode='public',
      email='',emailViewMode='public',
      livingPlaceViewMode='public',photoUrl='',country='',city='',address='',gender,androidNotificationToken='';


  UserModel({
      this.uid,
      this.username,
      this.artistType,
      this.bio,
      this.birthdayViewMode,
      this.phoneNo,
      this.phoneNoViewMode,
      this.email,
      this.emailViewMode,
      this.country,
      this.city,
      this.address,
      this.gender,
      this.livingPlaceViewMode,
      this.birthDate,
      this.photoUrl,this.androidNotificationToken});

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot userSnapshot){
      var userMap = userSnapshot.data();
      return UserModel(
          uid: userMap['uid'],
          photoUrl: userMap['photoUrl'],
          username: userMap['username'],
          bio: userMap['bio'],
          artistType: userMap['artistType'],
          birthDate: userMap['birthDate'],
          email: userMap['email'],
          phoneNo: userMap['phoneNo'],
          country: userMap['country'],
          city: userMap['city'],
          address: userMap['address'],
          gender: userMap['gender'],
          birthdayViewMode: userMap['birthdayViewMode'],
          phoneNoViewMode: userMap['phoneNoViewMode'],
          emailViewMode: userMap['emailViewMode'],
          livingPlaceViewMode: userMap['livingPlaceViewMode'],
          androidNotificationToken: userMap['androidNotificationToken']
      );
  }

  Map<String,dynamic> toMap(){
      final userMap = Map<String, dynamic>();
      if(uid!=null){
          userMap['uid'] = uid;
          userMap['photoUrl'] = photoUrl;
          userMap['username'] = username;
          userMap['artistType'] = artistType;
          userMap['bio'] = bio;
          userMap['birthDate'] = birthDate;
          userMap['email'] = email;
          userMap['phoneNo'] = phoneNo;
          userMap['country'] = country;
          userMap['city'] = city;
          userMap['address'] = address;
          userMap['gender'] = gender;
          //viewModes
          userMap['birthdayViewMode'] = birthdayViewMode;
          userMap['phoneNoViewMode'] = phoneNoViewMode;
          userMap['emailViewMode'] = emailViewMode;
          userMap['livingPlaceViewMode'] = livingPlaceViewMode;
          userMap['androidNotificationToken'] = androidNotificationToken;
          return userMap;

      }else{
          print('Uid is null');
          return null;
      }
  }
}

class UserModelLiveData{
    String uid;
    int followers=0,followings=0,totalLikes=0,totalPosts=0,recentNotifications;

    UserModelLiveData({this.uid, this.followers, this.followings, this.totalLikes,
      this.totalPosts,this.recentNotifications});
    factory UserModelLiveData.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
        var userLiveData = documentSnapshot.data();
        return UserModelLiveData(
            uid: userLiveData['uid'],
            followers: userLiveData['followers'],
            followings: userLiveData['followings'],
            totalLikes: userLiveData['totalLikes'],
            totalPosts: userLiveData['totalPosts'],
            recentNotifications: userLiveData['recentNotifications']
        );
    }
    Map<String,dynamic> toMap(){
        Map<String,dynamic> userLiveData={};
        userLiveData['uid'] = uid;
        userLiveData['totalLikes'] = totalLikes;
        userLiveData['totalPosts'] =totalPosts;
        userLiveData['followers'] = followers;
        userLiveData['followings']= followings;
        userLiveData['recentNotifications'] = recentNotifications;

        return userLiveData;
    }
}

class SavedPosts{
    String uid;
    Map<String,int> posts={};

    SavedPosts({this.uid, this.posts});

    factory SavedPosts.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
        var savedPosts = documentSnapshot.data();
        return SavedPosts(
            uid: savedPosts['uid'],
            posts: Map.from(savedPosts['posts']),
        );
    }
    Map<String,dynamic> toMap(){
        Map<String,dynamic> savedPosts={};
        savedPosts['uid'] =uid;
        savedPosts['posts'] = posts;
        return savedPosts;
    }
}

class Followers{
    String uid;
    Map<String,int> followers={};

    Followers({this.uid, this.followers});

    factory Followers.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
        var followersMap = documentSnapshot.data();
        return Followers(
            uid: followersMap['uid'],
            followers: Map.from(followersMap['followers']),
        );
    }
    Map<String,dynamic> toMap(){
        Map<String,dynamic> followersMap={};
        followersMap['uid'] =uid;
        followersMap['followers'] = followers;
        return followersMap;
    }
}

class Followings{
    String uid;
    Map<String,int> followings={};

    Followings({this.uid, this.followings});

    factory Followings.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
        var followingsMap = documentSnapshot.data();
        return Followings(
            uid: followingsMap['uid'],
            followings: Map.from(followingsMap['followings']),
        );
    }
    Map<String,dynamic> toMap(){
        Map<String,dynamic> followingsMap={};
        followingsMap['uid'] =uid;
        followingsMap['followings'] = followings;
        return followingsMap;
    }
}