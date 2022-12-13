import 'package:auditoria/Authentication/AuthService.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/MainScreens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

class SearchScreen extends StatefulWidget{
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  bool searchByUsername=true;
  Future<QuerySnapshot> searchResults;

  filterResults(String query){
   // print(query);
    setState(() {
      searchResults =  DatabaseService().getSearchResults(query: query.trim(),searchByUsername: searchByUsername);
    });
  }
  @override
  void dispose() {
    searchController.clear();
    searchController.dispose();
    super.dispose();
  }

  buildResults(){
    return FutureBuilder(
      future: searchResults,
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return SizedBox(
            height: 36,
            width: 36,
            child: CircularProgressIndicator(
              backgroundColor: AppColors().themeBrown,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
            ),
          );
        }else{
          QuerySnapshot results = snapshot.data;
          if(results.size==0){
            return AppText(text: 'No users found',style: 'regular',color: AppColors().themeDarkBlue,size: 16).getText();
          }
          return Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount:  results.size,
              itemBuilder: (context,index){
                String username = results.docs[index].data()['username'],
                    artistType = results.docs[index].data()['artistType'],
                    photoUrl=results.docs[index].data()['photoUrl'];
                bool isUser = FirebaseAuth.instance.currentUser.uid == results.docs[index].data()['uid']?true:false;
                return isUser?SizedBox(height: 0,):InkWell(
                  onTap: (){
                    Navigator.push(context,PageTransition(
                        child: ProfileScreen(uid: results.docs[index].data()['uid'],isViewAs: true,),
                        type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 500)));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 72,
                          child: Row(
                            children: [
                              Container(
                                width: 48,height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: AppColors().white,
                                  border: photoUrl==null?Border.all(width: 1,color: AppColors().grey200):null,
                                ),
                                child: photoUrl==null?
                                Icon(Icons.person_outlined,size: 24, color: AppColors().themeDarkBlue,):
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(photoUrl,
                                    loadingBuilder: (context,child,progress){
                                      return progress==null?child:Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            backgroundColor: AppColors().themeBrown,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 16,),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(text: username,style: 'regular',color: AppColors().themeDarkBlue,size: 16).getText(),
                                    SizedBox(height: 4,),
                                    AppText(text: artistType,style: 'regular',color: AppColors().themeDarkBlue,size: 12).getText(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width,
                          color: AppColors().grey200,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white,
      body: GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal: 24),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(height: 72,),
              AppText(text: 'Search with',size: 12,style: 'regular',color: AppColors().themeDarkBlue).getText(),
              SizedBox(height: 4,),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 56,
                color: AppColors().white,
                child: Row(
                  children: [
                   SizedBox(
                     width: (MediaQuery.of(context).size.width-48)/3,
                     child: Align(
                       alignment: Alignment(-0.2,0),
                       child: AppText(text: 'Username',style: searchByUsername?'bold':'regular',size: 16,color: AppColors().themeDarkBlue ).getText(),
                     ),),
                   SizedBox(
                     width : (MediaQuery.of(context).size.width-48)/3,
                     child: Container(
                       height: 44,
                       padding: EdgeInsets.symmetric(horizontal: 4,vertical: 4),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(24),
                         border: Border.all(width: 1,color: AppColors().grey300),
                         color: AppColors().white
                       ),
                       child: Stack(
                         children: [
                           Align(
                             alignment: Alignment(!searchByUsername?-1:1,0),
                             child: GestureDetector(
                               onTap: (){
                                 setState(() {
                                   searchByUsername = !searchByUsername;
                                   if(searchController.text.trim().isNotEmpty){
                                     filterResults(searchController.text.trim());
                                   }
                                 });
                               },
                               child: Container(
                                 width: (MediaQuery.of(context).size.width-48)/3 -8,
                                 height: 24,
                                 color: AppColors().white,
                               ),
                           ),),
                           AnimatedAlign(
                             alignment: Alignment(searchByUsername?-1:1,0),
                             curve: Curves.easeInOut,
                             duration: Duration(milliseconds: 300),
                             child: Container(
                               width: 32,
                               height: 32,
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(16),
                                   color: AppColors().themeDarkBlue
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                   SizedBox(
                     width: (MediaQuery.of(context).size.width-48)/3,
                     child: Align(
                       alignment: Alignment(-0.2,0),
                       child: AppText(text: 'Type',style: !searchByUsername?'bold':'regular',size: 16,color: AppColors().themeDarkBlue ).getText(),
                     ),),
                 ],
                ),
              ),
              SizedBox(height: 24,),
              TextFormField(
                controller: searchController,
                maxLines: 1,
                cursorColor: AppColors().themeBrown,
                onChanged: filterResults,
                textInputAction: TextInputAction.done,
                style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                decoration: AppInputDecoration(
                  hint: 'Search for a person',prefixIcon: Icons.search_outlined,
                  prefixIconColor: AppColors().grey400,
                  suffixIcon: Icons.close_rounded,
                  suffixIconColor: AppColors().grey400,
                  onSuffixButtonClick: (){
                    setState(() {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      searchController.text='';
                      searchResults = null;
                    });
                  }
                ).getInputDecoration(),
              ),
              SizedBox(height: 24,),
              (searchController.text.trim().isEmpty || searchResults==null)?Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 72,),
                      WebsafeSvg.asset('assets/svg/find_user_.svg',width: MediaQuery.of(context).size.width*0.6),
                      SizedBox(height: 36,),
                      AppText(text: 'Search for other artists',style:'regular',size: 14,color: AppColors().themeOffBlue ).getText(),
                    ],
                  ),
                ),
              ):buildResults(),
            ],
          ),
        ),
      ),
    );
  }
}