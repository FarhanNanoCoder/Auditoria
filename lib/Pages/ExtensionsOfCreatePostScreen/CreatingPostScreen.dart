import 'dart:io';
import 'dart:ui';
import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/EditImageViewer.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';

// ignore: must_be_immutable
class CreatingPostScreen extends StatefulWidget{
  String description;
  List<String> tags;
  String existingWorkUrl,pid;

  CreatingPostScreen({this.description, this.tags,this.pid,this.existingWorkUrl});

  @override
  _CreatingPostScreenState createState() => _CreatingPostScreenState();
}

class _CreatingPostScreenState extends State<CreatingPostScreen> {

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
        body: SingleChildScrollView(
          child: GestureDetector(
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
                      SizedBox(height: 44,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: descriptionController,
                              maxLines: 5,
                              cursorColor: AppColors().themeBrown,
                              style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                              decoration: AppInputDecoration(hint: 'Write your post').getInputDecoration(),
                            ),
                            SizedBox(height: 24,),
                            PostTagAdder(
                              tags: tags,
                              onTagsChange: (values){
                                tags=values;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24,),
                      AddImage(
                        existingWorkUrl: widget.existingWorkUrl??null,
                        onWorkUpload: (file){
                          setState(() {
                            uploadedWork = file;
                          });
                        },
                      ),
                      SizedBox(height: 16,),
                      (uploadedWork!=null || widget.existingWorkUrl!=null)?TextButton(
                        style: TextButton.styleFrom(
                          minimumSize:Size(MediaQuery.of(context).size.width-8,56),
                          padding: EdgeInsets.all(0),
                          backgroundColor: AppColors().themeDarkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: ()async{
                         // print(descriptionController.text.trim());
                         // print(tags);
                         // print(uploadedWork.path);
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
                              Navigator.pop(context);
                            }else{
                              print(result);
                              setState(() {
                                showProgress = false;
                                Toast(context: context).showTextToast('Something went wrong');
                              });
                            }
                          }
                        },
                        child: AppText(text: 'Post your work',size: 16, style: 'medium', color: AppColors().white).getText(),
                      ):SizedBox(height: 0,),
                      SizedBox(height: 16,),
                      showProgress?SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          backgroundColor: AppColors().themeBrown,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                        ),
                      ) :SizedBox(height: 8,),
                      (uploadedWork!=null || widget.existingWorkUrl!=null)?SizedBox(height: 44,):SizedBox(height: 0,),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(text: 'Tag : ',size: 16,style: 'medium',color: AppColors().themeDarkBlue).getText(),
              SizedBox(width: 16,),
              Expanded(
                child: TextFormField(
                  controller: tagController,
                  maxLength: 20,
                  maxLines: 1,
                  cursorColor: AppColors().themeBrown,
                  style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                  decoration: AppInputDecoration(hint: 'Write your tag').getInputDecoration(),
                ),
              ),
              SizedBox(width: 16,),
              TextButton(
                style: TextButton.styleFrom(
                    minimumSize:Size(72,56),
                    padding: EdgeInsets.all(0),
                    backgroundColor: AppColors().themeDarkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    )
                ),
                onPressed: (){
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
                child: AppText(text: 'Add',size: 16, style: 'medium', color: AppColors().white).getText(),
              ),
            ],
          ),
          SizedBox(height: 8,),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors().themeDarkBlue,
                                borderRadius: BorderRadius.circular(4),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 36,
                        width: MediaQuery.of(context).size.width-72-16-48,
                        decoration: BoxDecoration(
                            color: AppColors().white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(width: 1,color: AppColors().grey300)
                        ),
                        child: Center(
                          child: AppText(text: 'No tags found',size: 14,
                              style: 'regular', color: AppColors().grey300).getText(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16),
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(width: 1,color: AppColors().grey200),
                  color: AppColors().white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: AppText(text: tags.length.toString()+'/5',size: 16,
                      style: 'regular', color: AppColors().themeDarkBlue).getText(),
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
    return (selectedWork==null && existingWorkUrl==null)?DottedBorder(
      strokeWidth: 1,
      borderType: BorderType.RRect,
      radius: Radius.circular(4),
      dashPattern: [5,10],
      color: AppColors().themeDarkBlue,
      child: Container(
        width: MediaQuery.of(context).size.width-8,
        height: MediaQuery.of(context).size.width-8,
        color: AppColors().white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WebsafeSvg.asset('assets/svg/creative_thinking_.svg',width: MediaQuery.of(context).size.width*0.6),
            SizedBox(height: 16,),
            AppText(text: 'Give your thinking a face',size: 16,
                style: 'regular', color: AppColors().themeOffBlue).getText(),
            SizedBox(height: 56,),
            TextButton(
              style: TextButton.styleFrom(
                  minimumSize:Size(MediaQuery.of(context).size.width-48,56),
                  padding: EdgeInsets.all(0),
                  backgroundColor: AppColors().themeDarkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
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
      ),
    ):Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: selectedWork!=null?Image.file(selectedWork,width:MediaQuery.of(context).size.width-8,):
          Container(
            width: MediaQuery.of(context).size.width-8,
            height: MediaQuery.of(context).size.width-8,
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
        Positioned(
          bottom: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: AppColors().white.withOpacity(0.6),
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
                icon: Icon(Icons.edit_outlined),
                iconSize: 24,
                color: AppColors().themeDarkBlue,
                tooltip: 'Change work',
              ),
            ),
          ),
        ),
      ],
    );
  }
}