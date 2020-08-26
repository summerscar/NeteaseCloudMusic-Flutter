// Flutter code sample for PageStorage

// This sample shows how to explicitly use a [PageStorage] to
// store the states of its children pages. Each page includes a scrollable
// list, whose position is preserved when switching between the tabs thanks to
// the help of [PageStorageKey].

import 'package:flutter/material.dart';

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
          drawer: _Drawer(),
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
              Center(
                child: Text('我的'),
              ),
              Center(
                child: Text('发现'),
              ),
            ],
          ),
        ));
  }
}

class _Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/images/avatar.jpg'),
                ),
                SizedBox(height: 20),
                Text(
                  'username',
                  style: TextStyle(
                    color: Colors.white
                  )
                )
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
