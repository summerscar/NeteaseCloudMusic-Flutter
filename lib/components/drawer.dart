import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/state.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class ComponentDrawer extends StatelessWidget {
  Widget _drawerHead(context, state) {
    if (state.userInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage:
                CachedNetworkImageProvider(state.userInfo['avatarUrl']),
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

  List<ListTile> _drawerList(context, state) {
    _showBottomSheet() {
      showBottomSheet<String>(
        context: context,
        builder: (BuildContext context) => Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: ListView(
            shrinkWrap: true,
            primary: false,
            children: <Widget>[
              ListTile(
                dense: true,
                title: Text('网易云音乐 Flutter'),
              ),
              ListTile(
                dense: true,
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: TextStyle(color: Colors.black),
                        text: 'by ',
                      ),
                      TextSpan(
                        style: TextStyle(color: Colors.blue[300]),
                        text: 'summerscar',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            String url = 'https://github.com/summerscar';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (state.userInfo != null) {
      return [
        ListTile(
          title: Text('退出'),
          onTap: () async {
            Provider.of<StateModel>(context, listen: false).setUserInfo(null);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('关于'),
          onTap: () {
            // Update the state of the app.
            // ...
            Navigator.pop(context);
            _showBottomSheet();
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
          _showBottomSheet();
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
