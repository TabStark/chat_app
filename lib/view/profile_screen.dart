import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/util/loading.dart';
import 'package:chat_app/view/authscreen/logn_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/APIs/apis.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _image; //for using temporary image to display in UI
  String? _tempUserName; //for using temporary username to display in UI
  String? _tempAbout; //for using temporary about to display in UI

  // To change the edit and Update icon
  bool _forUserName = true;
  bool _forUserAbout = true;

  late final AnimationController _controller =
      AnimationController(duration: const Duration(seconds: 3), vsync: this)
        ..repeat();

  // Logout Function
  Future<void> logoutfromdevice() async {
    ProgressIndication.showProgressBar(context, _controller);

    await apis.updateActiveStatus(false);

    await apis.auth.signOut().then((value) async {
      await GoogleSignIn().signOut().then((value) {
        Navigator.pop(context);

        apis.auth = FirebaseAuth.instance;
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: LoginScreen(), type: PageTransitionType.leftToRight));
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatUser userInfo = widget.user;

    // Select User Image
    void _showModalforImage() {
      showModalBottomSheet(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          context: context,
          builder: (_) {
            return ListView(
              padding: EdgeInsets.only(
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 60),
              shrinkWrap: true,
              children: [
                const Center(
                    child: Text(
                  "Pick Profile Picture",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Choose From Gallery
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor().greyshade200,
                            shape: CircleBorder(),
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * .17,
                                MediaQuery.of(context).size.width * .17)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _image = image.path;
                            });

                            apis.updateProfilePicture(File(_image!));
                            Navigator.pop(context);
                          }
                        },
                        child: Transform.scale(
                          scale: 1.6,
                          child: Icon(
                            Icons.photo_size_select_actual_rounded,
                            color: AppColor().navyblue,
                          ),
                        )),
                    // Choose from camera
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor().greyshade200,
                            shape: CircleBorder(),
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * .17,
                                MediaQuery.of(context).size.width * .17)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (image != null) {
                            setState(() {
                              _image = image.path;
                            });

                            apis.updateProfilePicture(File(_image!));
                            Navigator.pop(context);
                          }
                        },
                        child: Transform.scale(
                          scale: 1.6,
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: AppColor().navyblue,
                          ),
                        ))
                  ],
                )
              ],
            );
          });
    }

    // print("Building ProfileScreen");

    return Scaffold(
      // AppBar
      appBar: AppBar(
        backgroundColor: AppColor().navyblue,
        title: const Text("User Profile"),
        actions: [
          IconButton(
              onPressed: () => logoutfromdevice(),
              icon: Icon(
                Icons.logout_outlined,
                color: AppColor().white,
                size: 28,
              ))
        ],
      ),
      // Body
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.height * .05),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .03,
                ),
                // User Image
                Stack(
                  children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.height * .09),
                            child: Image.file(
                              File(_image!),
                              height: MediaQuery.of(context).size.height * .18,
                              width: MediaQuery.of(context).size.height * .18,
                              fit: BoxFit.cover,
                            ),
                          )
                        :
                        // Image getting from server
                        ClipRRect(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.height * .09),
                            child: CachedNetworkImage(
                              height: MediaQuery.of(context).size.height * .18,
                              width: MediaQuery.of(context).size.height * .18,
                              fit: BoxFit.cover,
                              imageUrl: userInfo.image,
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                child: Icon(
                                  CupertinoIcons.person,
                                  color: AppColor().navyblue,
                                ),
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        elevation: 1,
                        color: AppColor().white,
                        shape: const CircleBorder(),
                        onPressed: () {
                          _showModalforImage();
                        },
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: AppColor().navyblue,
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .03,
                ),

                // User Email
                Text(
                  userInfo.email,
                  style:
                      TextStyle(fontSize: 17, color: AppColor().greyshade800),
                ),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .08,
                ),

                // User Name
                TextFormField(
                  autofocus: true, //for keyboard
                  readOnly: _forUserName,
                  onSaved: (val) => apis.me.name = val ?? "",
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : 'Required field',
                  onChanged: (value) {
                    _tempUserName = value.trim();
                  },
                  initialValue: _tempUserName ?? userInfo.name.trim(),
                  decoration: InputDecoration(
                      hintText: "eg: Salman Khan",
                      hintStyle: TextStyle(color: AppColor().navyblue),
                      labelText: "User Name",
                      labelStyle: TextStyle(color: AppColor().navyblue),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColor().greyshade200)),
                      prefixIcon: Icon(
                        Icons.person,
                        color: AppColor().navyblue,
                      ),
                      suffixIcon: _forUserName
                          ? IconButton(
                              onPressed: () async {
                                setState(() {
                                  _forUserName = !_forUserName;
                                });
                              },
                              icon: Icon(
                                Icons.edit,
                                color: AppColor().navyblue,
                              ))
                          : IconButton(
                              onPressed: () async {
                                if (_tempUserName != null &&
                                    _formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  await apis
                                      .updateUserInformation(0)
                                      .then((value) {
                                    setState(() {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "User Name Successfully Updated")));
                                    });
                                  });
                                }
                                setState(() {
                                  _forUserName = !_forUserName;
                                });
                              },
                              icon: Icon(
                                Icons.arrow_circle_up_rounded,
                                color: AppColor().navyblue,
                              )),
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColor().greyshade200))),
                ),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .04,
                ),

                // User About
                TextFormField(
                  readOnly: _forUserAbout,
                  autofocus: true,
                  onSaved: (val) => apis.me.about = val ?? "",
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : 'Required field',
                  onChanged: (value) {
                    _tempAbout = value.trim();
                  },
                  initialValue: _tempAbout ?? userInfo.about.trim(),
                  decoration: InputDecoration(
                      hintText: "eg: Hey! I am Aspiran",
                      hintStyle: TextStyle(color: AppColor().navyblue),
                      labelText: "About",
                      labelStyle: TextStyle(color: AppColor().navyblue),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColor().greyshade200)),
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: AppColor().navyblue,
                      ),
                      suffixIcon: _forUserAbout
                          ? IconButton(
                              onPressed: () async {
                                setState(() {
                                  _forUserAbout = !_forUserAbout;
                                });
                              },
                              icon: const Icon(Icons.edit))
                          : IconButton(
                              onPressed: () async {
                                if (_tempAbout != null &&
                                    _formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  await apis
                                      .updateUserInformation(1)
                                      .then((value) {
                                    setState(() {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "About Successfully Updated")));
                                    });
                                  });
                                }
                                setState(() {
                                  _forUserAbout = !_forUserAbout;
                                });
                              },
                              icon: Icon(
                                Icons.arrow_circle_up_rounded,
                                color: AppColor().navyblue,
                              )),
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColor().greyshade200))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
