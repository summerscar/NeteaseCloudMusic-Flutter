// Flutter code sample for PageStorage

// This sample shows how to explicitly use a [PageStorage] to
// store the states of its children pages. Each page includes a scrollable
// list, whose position is preserved when switching between the tabs thanks to
// the help of [PageStorageKey].

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fluuter_demo/page/my.dart';
import 'package:fluuter_demo/components/drawer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluuter_demo/page/login.dart';
import 'package:fluuter_demo/page/player.dart';
import 'package:provider/provider.dart';
import './state/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './page/search.dart';
import 'components/bottomPlayer.dart';

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
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
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
          ),
      "player": (context) => FlutterEasyLoading(child: PlayerPage()),
    }, initialRoute: '/', theme: ThemeData(primarySwatch: Colors.red));
  }
}

class MyHomePage extends StatelessWidget {
  final tabs = ['我的', '发现'];

  void _search(BuildContext context) async {
    final dynamic selected = await showSearch<dynamic>(
      context: context,
      delegate: MySearchDelegate(context),
    );
    if (selected != null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('You have selected the songid: ${selected['id']}'),
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
          bottomNavigationBar: BottonPlayer(),
        ));
  }
}
