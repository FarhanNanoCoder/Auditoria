import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel _userFromFirebase(User user) {
    return user != null
        ? UserModel(
            uid: user.uid,
            email: user.email,
          )
        : null;
  }

  Stream<UserModel> get user {
    return _auth
        .authStateChanges()
        //.map((User user) => _userFromFirebase(user));
        .map(_userFromFirebase);
  }

  Future registerWithEmailAndPassword({String email, String password}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<dynamic> signInWithEmailAndPassword(
      {String email, String password}) async {
    dynamic result;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = userCredential.user;
      // result=_userFromFirebase(user);

      result = true;

      String token = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({'androidNotificationToken': token});

      return result;
    } catch (e) {
      result = e.toString();
      print(e.toString());
      return result;
    }
  }

  Future passwordReset({String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<dynamic> reAuthenticateUser({String password}) async {
    AuthCredential credentials = EmailAuthProvider.credential(
        email: _auth.currentUser.email, password: password);
    try {
      UserCredential userCredential =
          await _auth.currentUser.reauthenticateWithCredential(credentials);
      return userCredential;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future deleteUserFromAuth({UserCredential userCredential}) async {
    try {
      await userCredential.user.delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
