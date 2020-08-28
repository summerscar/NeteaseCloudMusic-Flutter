import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/state.dart';

class ComponentDrawer extends StatelessWidget {

  Widget _drawerHead(context, state) {
    if (state.userInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(state.userInfo['avatarUrl']),
          ),
          SizedBox(height: 20),
          Text(state.userInfo['nickname'],
              style: TextStyle(color: Colors.white))
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '未登录',
              style: TextStyle(color: Colors.white),
          )
        ],
      );
    }
  }

  List<ListTile> _drawerList (context, state) {
    if (state.userInfo != null) {
      return [
           ListTile(
            title: Text('退出'),
            onTap: () async {
              Provider.of<StateModel>(context, listen: false).setUserInfo(null);
              Navigator.pop(context);
            },
          ),
      ];
    }
    return [
          ListTile(
            title: Text('登录'),
            onTap: () {
              Navigator.pushNamed(context, "login");
            },
          ),
          ListTile(
            title: Text('关于'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.pop(context);
            },
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: Consumer<StateModel>(builder: (context, state, child) {
      return ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: _drawerHead(context, state),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ..._drawerList(context, state)
        ],
      );
    }));
  }
}
