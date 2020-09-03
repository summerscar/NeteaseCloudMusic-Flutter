import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:ui';
// import 'dart:developer';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluuter_demo/utils/api.dart';
import 'package:dio/dio.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';
import '../utils/api.dart';

class PageMy extends StatefulWidget {
  @override
  _PageMyState createState() => _PageMyState();
}

class _PageMyState extends State<PageMy> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      dynamic setMyPlayList = context.read<StateModel>().setMyPlayList;
      dynamic userInfo = context.read<StateModel>().userInfo;
      if (userInfo != null) {
        api().get('/user/playlist?uid=${userInfo['userId']}').then((res) {
          if (res.data['code'] == 200) {
            setMyPlayList(res.data['playlist']);
          }
          // debugger();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    StateModel state = context.watch<StateModel>();

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
          state.myPlayList.isNotEmpty
              ? Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: InkWell(
                              onTap: () {},
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        state.myPlayList[0]['coverImgUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(),
                            child: state.myPlayList.getRange(1, 5).length > 0
                                ? GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.0,
                                      mainAxisSpacing: 3.0,
                                      crossAxisSpacing: 3.0,
                                    ),
                                    itemCount:
                                        state.myPlayList.getRange(1, 5).length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                          onTap: () {
                                            print(
                                                '${state.myPlayList.getRange(1, 5).elementAt(index)['name']}');
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(state
                                                          .myPlayList
                                                          .getRange(1, 5)
                                                          .elementAt(index)[
                                                      'coverImgUrl']),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 0, sigmaY: 0),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                  ))));
                                    },
                                  )
                                : SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 3.0,
                crossAxisSpacing: 3.0,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 3.0),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 3.0,
                crossAxisSpacing: 3.0,
              ),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 3.0, color: Colors.blue),
                  ),
                );
              },
            ),
          ),
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

  _BuildMusicList({Key key, @required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StateModel state = context.watch<StateModel>();

    void _clickHandler(songdata) {
      state.playSongOrigin(songdata);
      Navigator.pop(context);
    }

    void _playList() {
      state.playListOrigin(this.items);
      Navigator.pop(context);
    }

    return Column(
      children: [
        InkWell(
          onTap: _playList,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.play_circle_outline),
                Padding(padding: EdgeInsets.only(left: 10), child: Text('播放列表'))
              ],
            ),
          ),
        ),
        Expanded(
            child: ListView.separated(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(items[index]['name']),
              subtitle: Text(items[index]['artists']
                  .map((artist) => artist['name'])
                  .join(' / ')),
              onTap: () => _clickHandler(items[index]),
              trailing: IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () => state.addSongOrigin(items[index])),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(color: Colors.grey);
          },
        ))
      ],
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
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: _BuildMusicList(items: list));
  }
}
