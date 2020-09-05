import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './musicList.dart';
import './../utils/api.dart';
import 'package:dio/dio.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class ExplorerPage extends StatefulWidget {
  @override
  _ExplorerPageState createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Function setRecommendPlayList =
          context.read<StateModel>().setRecommendPlayList;
      List<dynamic> recommendPlayList =
          context.read<StateModel>().recommendPlayList;
      dynamic userInfo = context.read<StateModel>().userInfo;
      if (userInfo != null && recommendPlayList.isEmpty) {
        api().get('/recommend/resource').then((res) {
          if (res.data['code'] == 200) {
            setRecommendPlayList(res.data['recommend']);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    StateModel state = context.watch<StateModel>();

    String _getNum2String(weekday) {
      List<String> list = ['', '一', '二', '三', '四', '五', '六', '日'];
      return list[weekday];
    }

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

    void _getRecommendSongs() {
      EasyLoading.show();
      api().get('/recommend/songs').then((value) {
        print('get recommend song');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return MusicListPage(
                list: value.data['data']['dailySongs'],
                title: '每日推荐',
              );
            },
          ),
        );
        EasyLoading.dismiss();
      }).catchError((e) {
        EasyLoading.dismiss();
        return e;
      });
    }

    void _getTopMusic(int type, String title) async {
      List<dynamic> list;

      EasyLoading.show();
      try {
        Response response = await api().get("/top/song?type=$type");
        list = response.data['data'];

        EasyLoading.dismiss();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return MusicListPage(
                list: list,
                title: '音乐列表',
              );
            },
          ),
        );
      } catch (e) {
        print(e);
      }
    }

    return SingleChildScrollView(
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: GridView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
            ),
            children: [
              InkWell(
                  onTap: () {
                    if (state.userInfo != null) {
                      _getRecommendSongs();
                    } else {
                      Navigator.pushNamed(context, '/');
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Column(children: [
                      Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red,
                          ),
                          child: Center(
                              child: Text(
                            '星期${_getNum2String(DateTime.now().weekday)}',
                            style: TextStyle(color: Colors.white),
                          ))),
                      Expanded(
                          child: Center(
                              child: Text(
                        DateTime.now().day.toString(),
                        style: TextStyle(color: Colors.black87, fontSize: 45),
                      )))
                    ]),
                  )),
              InkWell(
                  onTap: () {
                    _getTopMusic(0, '全站飙升榜');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/top.jpg'),
                      fit: BoxFit.cover,
                    )),
                  )),
              InkWell(
                  onTap: () {
                    _getTopMusic(8, '日语榜');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/top-jp.jpg'),
                            fit: BoxFit.cover)),
                  )),
              ...state.recommendPlayList
                  .map((playList) => InkWell(
                      onTap: () {
                        _musicListClickHandler(playList);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  playList['picUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Container(
                                alignment: Alignment.bottomLeft,
                                color: Colors.black.withOpacity(0.4),
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 6, left: 5),
                                  child: Text(
                                    playList['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8)),
                                  ),
                                ),
                              )))))
                  .toList()
            ],
          ),
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
      ]),
    );
  }
}

class _MusicList extends StatelessWidget {
  void getHttp(BuildContext context) async {
    List<dynamic> list;

    EasyLoading.show();
    try {
      Response response = await api().get("/top/song?type=8");
      list = response.data['data'];

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
      onPressed: () => getHttp(context),
    );
  }
}
