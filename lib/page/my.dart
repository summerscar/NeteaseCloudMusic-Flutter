import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:ui';
// import 'dart:developer';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
      List<dynamic> myPlayList = context.read<StateModel>().myPlayList;
      dynamic userInfo = context.read<StateModel>().userInfo;
      if (userInfo != null && myPlayList.isEmpty) {
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
          state.myPlayList.isEmpty ? Container(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'login');
                },
                child: Text('登录'),
              ),
            ),
          ) : SizedBox(),
          state.myPlayList.isNotEmpty
              ? Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 1),
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
                                                          EdgeInsets.only(bottom: 6, left: 5),
                                                      child: Text(
                                                        state.myPlayList
                                                            .getRange(1, 5)
                                                            .elementAt(
                                                                index)['name'],
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
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
          state.myPlayList.isNotEmpty && state.myPlayList.getRange(5, state.myPlayList.length).length > 0 ?
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 3.0,
                crossAxisSpacing: 3.0,
              ),
              itemCount: state.myPlayList.getRange(5, state.myPlayList.length).length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      _musicListClickHandler(state
                          .myPlayList
                          .getRange(5, state.myPlayList.length)
                          .elementAt(index));
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(state
                                    .myPlayList
                                    .getRange(5, state.myPlayList.length)
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
                                    EdgeInsets.only(bottom: 6, left: 5),
                                child: Text(
                                  state.myPlayList
                                      .getRange(5, state.myPlayList.length)
                                      .elementAt(
                                          index)['name'],
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(
                                              0.8)),
                                ),
                              ),
                            ))));
              },
            ),
          ) : SizedBox(),
          // Image.asset('assets/images/avatar.jpg'),
          // Image.asset('assets/images/avatar.jpg'),
          // Image.asset('assets/images/avatar.jpg')
        ],
      ),
    );
  }
}
