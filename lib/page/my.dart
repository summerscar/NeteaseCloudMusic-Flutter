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
import './musicList.dart';

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

    void _musicListClickHandler(dynamic musiclist) async {
      print('${musiclist['name']} ${musiclist['id']}');

      EasyLoading.show();
      Response res = await api().get('/playlist/detail?id=${musiclist['id']}');
      List<dynamic> tracks = res.data['playlist']['tracks'];
      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MusicListPage(
              list: tracks,
              title: musiclist['name'],
            );
          },
        ),
      );
    }

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
                              onTap: () {
                                _musicListClickHandler(state.myPlayList[0]);
                              },
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
                                            _musicListClickHandler(state
                                                .myPlayList
                                                .getRange(1, 5)
                                                .elementAt(index));
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
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: Text(
                                                        state.myPlayList
                                                            .getRange(1, 5)
                                                            .elementAt(
                                                                index)['name'],
                                                        overflow:
                                                            TextOverflow.fade,
                                                        style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.8)),
                                                      ),
                                                    ),
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
            return MusicListPage(
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
