import 'package:flutter/material.dart';

class AppColors{

  //creating Singleton
  static final AppColors _instance = AppColors._internal();
  factory AppColors(){
    return _instance;
  }
  AppColors._internal();

  Color white = Colors.white,
  themeBrown = Color(0xFFE5AC77),
  themeDarkBlue = Colors.blueGrey[900],
  themeOffBlue = Colors.blueGrey[800],
  grey900 = Colors.grey[900],
  grey800 = Colors.grey[800],
  grey400 = Colors.grey[400],
  grey300 = Colors.grey[300],
  grey200 = Colors.grey[200],
  grey100 = Colors.grey[100],
  red = Colors.redAccent
  ;

}