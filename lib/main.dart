// Flutter code sample for PageStorage

// This sample shows how to explicitly use a [PageStorage] to
// store the states of its children pages. Each page includes a scrollable
// list, whose position is preserved when switching between the tabs thanks to
// the help of [PageStorageKey].

import 'package:flutter/material.dart';
import 'package:fluuter_demo/page/my.dart';
import 'package:fluuter_demo/components/drawer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      home: MyHomePage(),
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
            title: Text('music'),
            centerTitle: false,
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
