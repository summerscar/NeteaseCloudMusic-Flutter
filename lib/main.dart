// Flutter code sample for PageStorage

// This sample shows how to explicitly use a [PageStorage] to
// store the states of its children pages. Each page includes a scrollable
// list, whose position is preserved when switching between the tabs thanks to
// the help of [PageStorageKey].

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluuter_demo/page/my.dart';
import 'package:fluuter_demo/components/drawer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluuter_demo/page/login.dart';
import 'package:provider/provider.dart';
import './state/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './page/search.dart';

void main() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0;

  runApp(ChangeNotifierProvider(
    create: (context) => StateModel(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  Future<void> _initState(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String userInfo = prefs.getString('userInfo');
    print('init state');
    if (userInfo != null) {
      Provider.of<StateModel>(context, listen: false)
          .setUserInfo(jsonDecode(userInfo));
    }
  }

  @override
  Widget build(BuildContext context) {
    _initState(context);

    return MaterialApp(routes: {
      "login": (context) => FlutterEasyLoading(child: LoginPage()),
      "/": (context) => FlutterEasyLoading(
            child: MyHomePage(),
          )
    }, initialRoute: '/', theme: ThemeData(primarySwatch: Colors.red));
  }
}

class MyHomePage extends StatelessWidget {
  final tabs = ['我的', '发现'];

  void _search(BuildContext context) async {
    final int selected = await showSearch<int>(
      context: context,
      delegate: MySearchDelegate(),
    );
    if (selected != null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('You have selected the songid: $selected'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          drawer: ComponentDrawer(),
          appBar: AppBar(
            centerTitle: true,
            title: TabBar(
              labelStyle: TextStyle(fontSize: 16),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              isScrollable: true,
              tabs: [Tab(text: '我的'), Tab(text: '发现')],
              indicator: BoxDecoration(),
            ),
            actions: <Widget>[
              Builder(
                  builder: (context) => IconButton(
                        tooltip: 'Search',
                        icon: const Icon(Icons.search),
                        onPressed: () => _search(context),
                      )),
            ],
          ),
          body: TabBarView(
            children: [
              PageMy(),
              Center(
                child: Text('发现'),
              ),
            ],
          ),
          bottomNavigationBar: Container(
              height: 56,
              margin: EdgeInsets.all(0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 66,
                    color: Colors.green,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.chat, color: Colors.white),
                        Text("CHAT", style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                  Container(
                    width: 66,
                    color: Colors.green,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.notifications_active, color: Colors.white),
                        Text("NOTIF", style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.red,
                      child: Text("BUY NOW",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                ],
              )),
        ));
  }
}
