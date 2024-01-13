import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/util/loading.dart';
import 'package:chat_app/util/snackbar.dart';
import 'package:chat_app/view/home_screen.dart';
import 'package:chat_app/viewmodel/firebaseauth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(duration: const Duration(seconds: 3), vsync: this)
        ..repeat();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // APP Bar
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Aspiran Login"),
          backgroundColor: AppColor().navyblue,
        ),
        body: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.38,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: AppColor().greyshade200,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Email
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: AppColor().navyblue),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor().navyblue))),
                    ),

                    // Password
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: AppColor().navyblue),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColor().navyblue))),
                    ),

                    // Login Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.78,
                      height: MediaQuery.of(context).size.width * 0.13,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor().navyblue),
                        child: Text(
                          "Login",
                          style:
                              TextStyle(color: AppColor().white, fontSize: 16),
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      thickness: 3,
                    ),
                    const Text("or"),

                    //Login with Google
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.78,
                      height: MediaQuery.of(context).size.width * 0.13,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Calling Progressindicator
                          ProgressIndication.showProgressBar(
                              context, _controller);
                          // Check Firebase Auth
                          firebaseAuth().signInWithGoogle().then((user) async {
                            // Stopping Progress Indicator
                            Navigator.pop(context);
                            // Navigator.pop(context);
                            if (user != null) {
                              print(
                                  'user:${user.user} \n userAdditionalinfo: ${user.additionalUserInfo}');
                              if (await apis.userExists()) {
                                Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                        child: HomeScreen(),
                                        type: PageTransitionType.rightToLeft));
                              } else {
                                await apis.createUser().then((value) {
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          child: HomeScreen(),
                                          type:
                                              PageTransitionType.rightToLeft));
                                });
                              }
                            } else {
                              Dialogs.showSnackbar(context,
                                  "Something went wrong! check Internet or try again later");
                            }
                          });
                        },
                        icon: Image.asset(
                          "assets/images/googleLogo.png",
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        label: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 16),
                            children: [
                              TextSpan(
                                text: "Signin with ",
                              ),
                              TextSpan(
                                  text: "Google",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18))
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor().navyblue),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
