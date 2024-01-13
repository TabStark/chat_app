import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/util/cardwidget_for_viewUser.dart';
import 'package:flutter/material.dart';

class ViewAllUsers extends StatefulWidget {
  const ViewAllUsers({super.key});

  @override
  State<ViewAllUsers> createState() => _ViewAllUsersState();
}

class _ViewAllUsersState extends State<ViewAllUsers> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP Bar
      appBar: AppBar(
        backgroundColor: AppColor().navyblue,
        // leading: _isSearching
        //     ? Padding(
        //         padding: const EdgeInsets.only(left: 18),
        //         child: Image.asset(
        //           "assets/images/logo.png",
        //         ),
        //       )
        //     : null,
        leadingWidth: 30,
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
        ],
      ),

      // body
      body: StreamBuilder(
        stream: apis.viewAllUsers(),
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
              _list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              if (_list.isNotEmpty) {
                return ListView.builder(
                    itemCount: _isSearching ? _searchList.length : _list.length,
                    padding: EdgeInsets.only(top: mq.height * .01),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return cardWidgetforVIewUsers(
                          user:
                              _isSearching ? _searchList[index] : _list[index]);
                    });
              } else {
                return const Center(
                  child: Text('No user found!', style: TextStyle(fontSize: 20)),
                );
              }
          }
        },
      ),
    );
  }
}
