// Flutter code sample for PageStorage

// This sample shows how to explicitly use a [PageStorage] to
// store the states of its children pages. Each page includes a scrollable
// list, whose position is preserved when switching between the tabs thanks to
// the help of [PageStorageKey].

import 'package:flutter/material.dart';
import 'package:fluuter_demo/page/my.dart';
import 'package:fluuter_demo/components/drawer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluuter_demo/page/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "login": (context) => FlutterEasyLoading(child: LoginPage()),
        "/":(context) => FlutterEasyLoading(
          child: MyHomePage(),
        )
      },
      initialRoute: '/',
      theme: ThemeData(primarySwatch: Colors.red)
    );
  }
}

class MyHomePage extends StatelessWidget {
  final tabs = ['我的', '发现'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          drawer: ComponentDrawer(),
          appBar: AppBar(
            title: TextField(
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(
                  color: Colors.white70
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white70,
                ),
              ),
            ),
            bottom: TabBar(
              isScrollable: true,
              tabs: [Tab(text: '我的'), Tab(text: '发现')],
            ),
          ),
          body: TabBarView(
            children: [
              PageMy(),
              Center(
                child: Text('发现'),
              ),
            ],
          ),
        ));
  }
}
