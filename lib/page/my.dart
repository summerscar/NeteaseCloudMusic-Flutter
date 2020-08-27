import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
// import 'dart:developer';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
                    children: [Icon(Icons.download_rounded), Text('下载管理')],
                  ),
                  Column(
                    children: [Icon(Icons.radio), Text('我的电台')],
                  ),
                  Column(
                    children: [Icon(Icons.favorite_rounded), Text('我的收藏')],
                  )
                ]),
          ),
          _MusicList(),
          RaisedButton(
            child: Text('登录'),
            onPressed: () => {
              Navigator.pushNamed(context, "login")
            }
          ),
          Image.asset('assets/images/avatar.jpg'),
          Image.asset('assets/images/avatar.jpg'),
          Image.asset('assets/images/avatar.jpg')
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
    print('clicked');
    EasyLoading.show();
    try {
      Response response =
          await Dio().get("https://music.api.summerscar.me/top/song?type=8");
      print('get response');
      setState(() {
        list = response.data['data'];
      });
      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MusicPage(list: list, title: '最新歌曲',);
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

  _BuildMusicList({Key key, @required this.items, this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: ListTile(
            title: Text(items[index]['name']),
            subtitle: Text(items[index]['artists']
                .map((artist) => artist['name'])
                .join(' / ')),
          ),
          onTap: () => onClick(items[index]['id']),
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
  final assetsAudioPlayer = AssetsAudioPlayer();

  void _clickHandler(id) async {
    print('click $id');
    try {
      if (assetsAudioPlayer.isPlaying.value) {
        assetsAudioPlayer.stop();
      }
      await assetsAudioPlayer.open(
        Audio.network('https://music.163.com/song/media/outer/url?id=$id.mp3'),
      );
    } catch (t) {
      print(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        assetsAudioPlayer.stop();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: _BuildMusicList(items: list, onClick: _clickHandler)),
    );
  }
}
