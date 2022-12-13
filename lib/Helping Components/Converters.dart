import 'package:intl/intl.dart';

String getStringFromDateTime(DateTime dateTime){
  List<String> months = ['January','February','March','April','May','June',
    'July','August','September','October','November','December'];
  int monthIndex = dateTime.month-1;
  String date = dateTime.day.toString()+' '+months[monthIndex]
      +', '+dateTime.year.toString();
  return date;
}

String getLivingPlace({String city,String country}){
  String livingPlace;
  if((city!=null && country!=null) && (city.isNotEmpty && country.isNotEmpty)){
    livingPlace = city+', '+country;
  }else if(city!=null && city.isNotEmpty){
    livingPlace = city;
  }else if(country!=null && country.isNotEmpty){
    livingPlace = country;
  }else{
    return null;
  }
  return 'lives in '+livingPlace;
}

String getDateTimeFromMilliEpoch({int time}){
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
  String formattedTime = DateFormat('dd MMMM, yyyy | hh.mm a').format(dateTime);
  return formattedTime;
}