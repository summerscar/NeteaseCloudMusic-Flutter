import 'package:flutter/material.dart';
// import 'dart:developer';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluuter_demo/utils/api.dart';
import 'package:dio/dio.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';

class PageMy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [Icon(Icons.music_note), Text('本地音乐')],
                  ),
                  Column(
                    children: [Icon(Icons.file_download), Text('下载管理')],
                  ),
                  Column(
                    children: [Icon(Icons.radio), Text('我的电台')],
                  ),
                  Column(
                    children: [Icon(Icons.favorite), Text('我的收藏')],
                  )
                ]),
          ),
          _MusicList(),
          RaisedButton(
            onPressed: () async {
              print('clicked');
              EasyLoading.show();
              try {
                Response response = await api().get("/login/status");
                print('status ok');
                print(response);
              } catch (e) {
                print(e);
              }
              EasyLoading.dismiss();
            },
            child: Text('status'),
          ),
          // Image.asset('assets/images/avatar.jpg'),
          // Image.asset('assets/images/avatar.jpg'),
          // Image.asset('assets/images/avatar.jpg')
        ],
      ),
    );
  }
}

class _MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<_MusicList> {
  List list = [];

  void getHttp() async {
    EasyLoading.show();
    try {
      Response response = await api().get("/top/song?type=8");
      setState(() {
        list = response.data['data'];
      });
      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MusicPage(
              list: list,
              title: '最新歌曲',
            );
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('最新歌曲'),
      onPressed: getHttp,
    );
  }
}

class _BuildMusicList extends StatelessWidget {
  final List<dynamic> items;
  final Function onClick;
  final Function onAdd;

  _BuildMusicList({Key key, @required this.items, this.onClick, this.onAdd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(items[index]['name']),
          subtitle: Text(items[index]['artists']
              .map((artist) => artist['name'])
              .join(' / ')),
          onTap: () => onClick(items[index]),
          trailing: IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () => onAdd(items[index])),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Colors.grey);
      },
    );
  }
}

class MusicPage extends StatelessWidget {
  MusicPage({
    Key key,
    this.title = '音乐列表',
    @required this.list, // 接收一个text参数
  }) : super(key: key);

  final List list;
  final String title;

  @override
  Widget build(BuildContext context) {
    final playSongOrigin =
        context.select((StateModel value) => value.playSongOrigin);
    final addSongOrigin =
        context.select((StateModel value) => value.addSongOrigin);

    void _clickHandler(songdata) {
      playSongOrigin(songdata);
      Navigator.pop(context);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: _BuildMusicList(
            items: list, onClick: _clickHandler, onAdd: addSongOrigin));
  }
}
