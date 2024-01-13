import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/util/cards.dart';
import 'package:chat_app/util/snackbar.dart';
import 'package:chat_app/view/profile_screen.dart';
import 'package:chat_app/view/view_all_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apis.getUserData();

    // this code show that we are active in the app or not
    SystemChannels.lifecycle.setMessageHandler((message) {
      print("Message: ${message}");
      // if messafe is resume is_online will be true
      if (apis.auth.currentUser != null) {
        if (message.toString().contains("resume")) {
          apis.updateActiveStatus(true);
        }
        // if messafe is pause is_online will be false
        if (message.toString().contains("pause")) {
          apis.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          // APP Bar
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColor().navyblue,
            leading: _isSearching
                ? Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Image.asset(
                      "assets/images/logo.png",
                    ),
                  )
                : null,
            leadingWidth: _isSearching ? 48 : 0,
            title: _isSearching
                ? TextField(
                    style: TextStyle(color: AppColor().white),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search",
                        hintStyle: TextStyle(color: AppColor().white)),
                    autofocus: true,
                    onChanged: (val) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val) ||
                            i.email.toLowerCase().contains(val)) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: mq.height * 0.038,
                        height: mq.height * 0.038,
                        child: Image.asset(
                          "assets/images/logo.png",
                        ),
                      ),
                      Text(
                        "SPIRAN Chat",
                        style: TextStyle(
                            fontSize: 23,
                            fontFamily: "Monopoly",
                            color: AppColor().white),
                      )
                    ],
                  ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                    _isSearching ? Icons.clear_rounded : Icons.search_rounded,
                    color: AppColor().white,
                    size: 28,
                  )),

              SizedBox(
                width: mq.width * .02,
              ),

              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: ProfileScreen(user: apis.me),
                          type: PageTransitionType.rightToLeft));
                },
                child: CircleAvatar(
                    backgroundColor: AppColor().purple,
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(apis.me.image),
                      ),
                    )),
              ),

              SizedBox(
                width: mq.width * .04,
              ),
              // PopUpMenu
            ],
          ),

          // Floating Button
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // _showAddPeopleDialog();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewAllUsers()));
            },
            backgroundColor: AppColor().greyshade200,
            child: Transform.flip(
              flipX: true,
              child: Icon(
                Icons.message,
                color: AppColor().navyblue,
              ),
            ),
          ),

          // Body
          body: StreamBuilder(
            stream: apis.getMyUserId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: apis.getAllUser(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return CardWidget(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('Search New Friends',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
    // StreamBuilder(
    //   stream: apis.getMyUserId(),
    //   builder: (context, snapshot) {
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.waiting:
    //       case ConnectionState.none:
    //         return const Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       case ConnectionState.active:
    //       case ConnectionState.done:
    //         return StreamBuilder(
    //           stream: apis.getAllUser(
    //               snapshot.data?.docs.map((e) => e.id).toList() ?? []),
    //           builder: (context, snapShot) {
    //             switch (snapShot.connectionState) {
    //               case ConnectionState.waiting:
    //               case ConnectionState.none:
    //                 return const Center(
    //                   child: CircularProgressIndicator(),
    //                 );
    //               case ConnectionState.active:
    //               case ConnectionState.done:
    //                 final data = snapShot.data?.docs;
    //                 _list = data
    //                         ?.map((e) => ChatUser.fromJson(e.data()))
    //                         .toList() ??
    //                     [];
    //                 if (_list.isNotEmpty) {
    //                   return ListView.builder(
    //                     physics: BouncingScrollPhysics(),
    //                     itemCount: isSearching
    //                         ? searchList.length
    //                         : _list.length,
    //                     itemBuilder: (context, index) {
    //                       return CardWidget(
    //                           user: isSearching
    //                               ? searchList[index]
    //                               : _list[index]);
    //                     },
    //                   );
    //                 } else {
    //                   return Center(
    //                     child: Text("Search New Friend"),
    //                   );
    //                 }
    //             }
    //           },
    //         );
    //     }
    //   },
    // )),
  }

  // Search People
  void _showAddPeopleDialog() {
    String email = "";
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding:
                EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppColor().navyblue,
                ),
                Text(
                  "   Update Message",
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            content: TextFormField(
              maxLines: null,
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                  hintText: "Email id",
                  prefixIcon: Icon(Icons.mail, color: AppColor().navyblue),
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            actions: [
              MaterialButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "cancel",
                  style: TextStyle(color: AppColor().navyblue),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (email.isNotEmpty) {
                    await apis.addChatUser(email).then((value) {
                      if (!value) {
                        Dialogs.showSnackbaraddUser(context, "User not found");
                      }
                    });
                  }
                },
                child: Text(
                  "Add",
                  style: TextStyle(color: AppColor().navyblue),
                ),
              )
            ],
          );
        });
  }
}
