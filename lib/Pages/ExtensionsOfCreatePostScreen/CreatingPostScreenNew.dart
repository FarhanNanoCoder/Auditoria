import 'dart:io';
import 'dart:ui';
import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/EditImageViewer.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:auditoria/Helping%20Components/TopAppBar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';

// ignore: must_be_immutable
class CreatingPostScreenNew extends StatefulWidget{
  BuildContext parentContext;
  String description;
  List<String> tags;
  String existingWorkUrl,pid;

  CreatingPostScreenNew({this.parentContext,this.description, this.tags,this.pid,this.existingWorkUrl});

  @override
  _CreatingPostScreenNewState createState() => _CreatingPostScreenNewState();
}

class _CreatingPostScreenNewState extends State<CreatingPostScreenNew> {

  final descriptionController = TextEditingController();
  File uploadedWork;
  List<String> tags=[];
  bool showProgress = false;
  bool isInitiated = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
  void initiateData(){
    descriptionController.text=widget.description;
    tags = widget.tags;
    isInitiated = true;
  }

  createPost()async{
    PostModel postModel = PostModel(
      description: descriptionController.text.trim(),
      tags: tags,
    );
    int result = await DatabaseService().createPost(postModel: postModel,image: uploadedWork);
    if(result==0){
      setState(() {
        showProgress = false;
        Toast(context: context).showTextToast('Uploaded post');
      });
      Navigator.pop(context);
    }else{
      print(result);
      setState(() {
        showProgress = false;
        Toast(context: context).showTextToast('Something went wrong');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.existingWorkUrl!=null && !isInitiated){
      initiateData();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: GestureDetector(
          onTap: (){
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(
                  children: [
                    TopAppBar(
                      leftButtonIcon: Icons.arrow_back_ios_outlined,
                      onLeftButtonTap: (){
                        Navigator.pop(context);
                      },
                       rightButtonIcon: Icons.inventory_outlined,
                      onRightButtonTap: ()async{
                        if(uploadedWork!=null || widget.existingWorkUrl!=null){
                          setState(() {
                            showProgress = true;
                          });
                          if(widget.existingWorkUrl==null){
                            createPost();
                          }else{
                            int result = await DatabaseService().updatePost(
                              pid: widget.pid,
                              description: descriptionController.text.trim(),
                              tags: tags,
                              file: uploadedWork??null,
                            );
                            if(result==0){
                              setState(() {
                                showProgress = false;
                                Toast(context: context).showTextToast('Updated post');
                              });
                              if(widget.parentContext!=null){
                                Navigator.pop(widget.parentContext);
                              }
                              Navigator.pop(context);
                            }else{
                              print(result);
                              setState(() {
                                showProgress = false;
                                Toast(context: context).showTextToast('Something went wrong');
                              });
                            }
                          }
                        }else{
                          Toast(context: context).showTextToast('No work found');
                        }
                      },
                      pageTitle: 'Creating post',
                    ),
                    showProgress?SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: AppColors().themeBrown,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                      ),
                    ) :SizedBox(height: 4,),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            AddImage(
                              existingWorkUrl: widget.existingWorkUrl??null,
                              onWorkUpload: (file){
                                setState(() {
                                  uploadedWork = file;
                                });
                              },
                            ),
                            SizedBox(height: 16,),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PostTagAdder(
                                    tags: tags,
                                    onTagsChange: (values){
                                      tags=values;
                                    },
                                  ),
                                  SizedBox(height: 24,),
                                  AppText(text: 'Description :',style: 'medium',color: AppColors().themeDarkBlue,size: 16).getText(),
                                  SizedBox(height: 8,),
                                  TextFormField(
                                    controller: descriptionController,
                                    maxLines: 10,
                                    cursorColor: AppColors().themeBrown,
                                    style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                                    decoration: AppInputDecoration(hint: 'Write your post').getInputDecoration(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24,),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ignore: must_be_immutable
class PostTagAdder extends StatefulWidget{
  List<String> tags;
  final Function(List<String> tags) onTagsChange;

  PostTagAdder({this.onTagsChange,this.tags});

  @override
  _PostTagAdderState createState() => _PostTagAdderState();
}

class _PostTagAdderState extends State<PostTagAdder> {
  final tagController = TextEditingController();
  List<String> tags=[];
  bool isInitialized = false;
  @override
  Widget build(BuildContext context) {
    if((widget.tags!=null || widget.tags.length!=0)&& !isInitialized){
      tags=widget.tags;
      isInitialized=true;
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppText(text: '*Tap on the tag to remove it',size: 10,style: 'regular',color: AppColors().themeOffBlue).getText(),
          // SizedBox(height: 8,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(text: 'Tag : ',size: 16,style: 'medium',color: AppColors().themeDarkBlue).getText(),
              SizedBox(width: 16,),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: tags.length!=0?tags.map((e){
                      return Row(
                        children: [
                          InkWell(
                            onTap: (){
                              setState(() {
                                tags.removeAt(tags.indexOf(e));
                                widget.onTagsChange(tags);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors().themeBrown,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: AppText(text: e,size: 14,
                                    style: 'regular', color: AppColors().white).getText(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16,)
                        ],
                      );
                    }).toList():[
                      AppText(text: 'No tags have been added',size: 14,
                          style: 'regular', color: AppColors().themeOffBlue).getText(),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16),
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors().themeDarkBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: AppText(text: tags.length.toString()+'/5',size: 8,
                      style: 'regular', color: AppColors().white).getText(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: tagController,
                  maxLength: 20,
                  maxLines: 1,
                  cursorColor: AppColors().themeBrown,
                  style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                    hintText: 'Write your tags',
                    hintStyle: AppText(style: 'regular', color: AppColors().grey400, size: 16)
                        .getStyle(),
                    helperStyle: AppText(
                        style: 'regular', color: AppColors().grey400, size: 10).getStyle(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: AppText(
                        style: 'regular', color: AppColors().themeOffBlue, size: 16)
                        .getStyle(),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                      BorderSide(color: AppColors().grey200, width: 1),
                    ),
                    errorStyle: AppText(style: 'regular', color: AppColors().red, size: 12)
                        .getStyle(),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppColors().red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppColors().red, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                      BorderSide(color: AppColors().grey200, width: 1),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        if(tags.length<=4){
                          if(tagController.text.isNotEmpty){
                            setState(() {
                              tags.add(tagController.text.trim());
                              widget.onTagsChange(tags);
                              tagController.text='';
                            });
                          }
                        }else{
                          Toast(context: context).showTextToast('Limit exceeded');
                        }
                      },
                      icon: Icon(Icons.add_circle_rounded,color: AppColors().themeDarkBlue,size: 28,),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddImage extends StatefulWidget{
  final Function(File work) onWorkUpload;
  String existingWorkUrl;

  AddImage({this.onWorkUpload,this.existingWorkUrl});

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File selectedWork;
  String existingWorkUrl;
  bool isInitialized = false;
  @override
  Widget build(BuildContext context) {
    if(widget.existingWorkUrl!=null && !isInitialized){
      existingWorkUrl = widget.existingWorkUrl;
      isInitialized = true;
    }
    return (selectedWork==null && existingWorkUrl==null)?Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      color: AppColors().white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WebsafeSvg.asset('assets/svg/design_thinking_.svg',width: MediaQuery.of(context).size.width*0.5),
          SizedBox(height: 16,),
          AppText(text: 'Give your thinking a face',size: 16,
              style: 'regular', color: AppColors().themeOffBlue).getText(),
          SizedBox(height: 56,),
          TextButton(
            style: TextButton.styleFrom(
                minimumSize:Size(MediaQuery.of(context).size.width*0.5,48),
                padding: EdgeInsets.all(0),
                backgroundColor: AppColors().themeDarkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                )
            ),
            onPressed: (){
              PickImage(
                  onImageSelect: (file){
                    setState(() {
                      selectedWork = file;
                      widget.onWorkUpload(selectedWork);
                      print('received by child frame '+ selectedWork.path);
                    });
                  }
              ).chooseFile();
            },
            child: AppText(text: 'Add your work',size: 16, style: 'medium', color: AppColors().white).getText(),
          ),
        ],
      ),
    ):SizedBox(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                selectedWork!=null?Image.file(selectedWork,width:MediaQuery.of(context).size.width,):
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: AppColors().white,),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Image.network(existingWorkUrl,fit: BoxFit.cover,
                      loadingBuilder: (context,child,progress){
                        return progress==null?child:Center(
                          child: SizedBox(
                            width: 56, height: 56,
                            child: CircularProgressIndicator(
                              backgroundColor: AppColors().themeBrown,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);},),),
                ),
              ],
            ),
          ),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Align(
                alignment: Alignment(0,0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: selectedWork!=null?Image.file(selectedWork,width:MediaQuery.of(context).size.width-48,):
                  Container(
                    width: MediaQuery.of(context).size.width-48,
                    height: MediaQuery.of(context).size.width-48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors().white,),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(existingWorkUrl,fit: BoxFit.cover,
                        loadingBuilder: (context,child,progress){
                          return progress==null?child:Center(
                            child: SizedBox(
                              width: 56, height: 56,
                              child: CircularProgressIndicator(
                                backgroundColor: AppColors().themeBrown,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);},),),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            right: 32,
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
              clipBehavior: Clip.antiAlias,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: AppColors().white.withOpacity(0.2),
                      border: Border.all(color: AppColors().white,width: 0.5)
                    ),
                    child: IconButton(
                      splashColor: AppColors().themeDarkBlue,
                      onPressed: (){
                        PickImage(
                            onImageSelect: (file){
                              setState(() {
                                selectedWork = file;
                                widget.onWorkUpload(selectedWork);
                                existingWorkUrl=null;
                                //print('received by child frame '+ selectedWork.path);
                              });
                            }
                        ).chooseFile();
                      },
                      icon: Icon(Icons.change_circle_outlined),
                      iconSize: 24,
                      color: AppColors().white,
                      tooltip: 'Change work',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}