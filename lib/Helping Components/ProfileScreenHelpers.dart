import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/Converters.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AppColors.dart';

class ProfileBirthdayBox extends StatefulWidget{
  final String birthDate;
  final BuildContext parentContext;
  final Function(String date) getDate;

  ProfileBirthdayBox({this.birthDate,this.parentContext,this.getDate});

  @override
  _ProfileBirthdayBoxState createState() => _ProfileBirthdayBoxState();
}

class _ProfileBirthdayBoxState extends State<ProfileBirthdayBox> {

  String birthDate;
  DateTime dateTime;

  _selectDate(BuildContext context)async{
    DateTime dateTimePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if(dateTimePicked!=null){
      dateTime = dateTimePicked;
      setState(() {
        birthDate = getStringFromDateTime(dateTime);
        widget.getDate(birthDate);
      });
      //print(dateTime);
    }
  }
  String getBirthday(){
    if(birthDate!=null){
      return birthDate;
    }else if(widget.birthDate!=null){
      return widget.birthDate;
    }else{
      return 'Not Found';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.cake_outlined,size: 24,color: AppColors().themeDarkBlue,),
        SizedBox(width: 16,),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16,),
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 1,color: AppColors().grey300),),
            child: Align(
              alignment: Alignment(-1,0),
              child: AppText(
                text: getBirthday(),
                style: 'regular',size: 16,color: AppColors().themeDarkBlue,
              ).getText(),
            ),
          ),
        ),
        SizedBox(width: 16,),
        TextButton(
          style: TextButton.styleFrom(
              minimumSize:Size(56,56),
              padding: EdgeInsets.all(0),
              backgroundColor: AppColors().white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1,color: AppColors().themeDarkBlue),
                borderRadius: BorderRadius.circular(4),
              )
          ),
          onPressed: () {
            _selectDate(context);
          },
          child: Icon(Icons.calendar_today_outlined, size: 24,color: AppColors().themeDarkBlue,),
          /*AppText(text: 'Pick',size: 16, style: 'regular', color: AppColors().white).getText(),*/
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class ProfileDetailsViewer extends StatelessWidget{
  final List<IconData> iconData;
  final List<String> viewMode;
  final List<String> details;
  bool isViewAs = false;
  final BuildContext parentContext;
  String viewerType='User';

  ProfileDetailsViewer({this.iconData, this.viewMode, this.details,
    this.parentContext,this.isViewAs,this.viewerType});

  bool shouldView(int index){
    if(!isViewAs){
      return true;
    }else if(viewMode[index]=='Public'){
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: details.map((e) {
          if(e==null || e.isEmpty){
            return SizedBox(height: 0,);
          }
          int index = details.indexOf(e);
          return shouldView(index)?Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: isViewAs?44:56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(iconData[index],size: 24,color: AppColors().themeDarkBlue,),
                    SizedBox(width: 16,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(text: e,size: 16,style: 'regular',color: AppColors().themeDarkBlue).getText(),
                        isViewAs?SizedBox(height: 0,)
                            :AppText(text: viewMode[index],size: 12,style: 'regular',color: AppColors().themeDarkBlue).getText(),
                      ],
                    ),
                  ],
                ),
              ),
             // SizedBox(height: 2,),
            ],
          ):SizedBox(height: 0,);}).toList());
  }
}

class ProfileGenderBox extends StatefulWidget{
  final String gender;
  final Function(String value) onGenderChange;
  ProfileGenderBox({this.gender,this.onGenderChange});

  @override
  _ProfileGenderBoxState createState() => _ProfileGenderBoxState();
}

class _ProfileGenderBoxState extends State<ProfileGenderBox> {
  String gender;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.person_outlined,size: 24,color: AppColors().themeDarkBlue,),
        SizedBox(width: 16,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16,),
          width: (MediaQuery.of(context).size.width - 48 - 16 -24)*.5,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 1,color: AppColors().grey300),),
          child: Align(
            alignment: Alignment(-1,0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded,color: AppColors().themeDarkBlue,),
                iconSize: 24,
                value: gender!=null?gender:widget.gender,
                onChanged: (value){setState(() {
                  gender = value;
                  widget.onGenderChange(gender);
                });},
                items: [
                  DropdownMenuItem(
                    value: 'Male',
                    child: AppText(text: 'Male',size: 16,style: 'regular',color: AppColors().themeDarkBlue).getText(),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: AppText(text: 'Female',size: 16,style: 'regular',color: AppColors().themeDarkBlue).getText(),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: AppText(text: 'Other',size: 16,style: 'regular',color: AppColors().themeDarkBlue).getText(),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}