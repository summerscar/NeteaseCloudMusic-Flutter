import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_lyric/lyric_util.dart';
import 'package:flutter_lyric/lyric_widget.dart';
import '../components/bottomSheet.dart';
import '../utils//api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlayerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<StatefulWidget>
    with TickerProviderStateMixin {
  bool isChanged = false;
  double changedVal = 0;
  // _PlayerPageState (BuildContext context)
  //   : state = context.watch<StateModel>();

  // @override
  // void initState() {
  //   super.initState();
  //   if (context.select((StateModel val) => val.currentSong) == null) {
  //     Navigator.pushNamed(context, '/');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    StateModel state = context.watch<StateModel>();

    if (state.currentSong == null) {
      return Scaffold(
        body: Center(
            child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pushNamed(context, '/'))),
      );
    }
    void _likeMusic(int id, bool islike) {
      api().get('/like?id=$id&like=${islike ? 'true' : 'false'}').then((value) {
        state.setLikeList(islike, id);
      });
    }

    void _addTolist() {
      showDialog<int>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
          title: Text('收藏到歌单'),
          children: state.myPlayList
              .where((list) => list['subscribed'] == false)
              .map((list) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(list[
                          'coverImgUrl']), // no matter how big it is, it won't overflow
                    ),
                    title: Text(list['name']),
                    onTap: () => Navigator.pop(context, list['id']),
                  ))
              .toList(),
        ),
      ).then((returnVal) {
        if (returnVal != null) {
          print(returnVal);
          api()
              .get(
                  '/playlist/tracks?op=add&pid=$returnVal&tracks=${state.currentSong.id}')
              .then((value) {
            if (value.data['status'] == 200) {
              Fluttertoast.showToast(
                  msg: "添加成功",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  webPosition: 'center',
                  fontSize: 14.0);
            }
          });
        }
      });
    }

    return Scaffold(
        body: Container(
            decoration: state.currentSongPic == null
                ? BoxDecoration(color: Colors.grey[300])
                : BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(state.currentSongPic),
                      fit: BoxFit.cover,
                    ),
                  ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
              child: Container(
                  alignment: Alignment.center,
                  color: Colors.grey[600].withOpacity(0.1),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.topStart,
                          children: [
                            state.currentSongPic == null
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: state.currentSongPic,
                                    placeholder: (BuildContext context, url) =>
                                        CircularProgressIndicator()),
                            IconButton(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top),
                                icon: Icon(Icons.expand_more),
                                color: Colors.white,
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/')),
                          ],
                        ),
                        Container(
                            padding: EdgeInsetsDirectional.only(top: 15),
                            child: Column(
                              children: [
                                Container(
                                    padding:
                                        EdgeInsetsDirectional.only(bottom: 5),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: Colors.white
                                                    .withOpacity(0.75),
                                                size: 20,
                                              ),
                                              onPressed: _addTolist),
                                          Expanded(
                                              child: Center(
                                                  child: Text(
                                            state.currentSong.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal),
                                          ))),
                                          IconButton(
                                              icon: Icon(
                                                state.likeList.contains(
                                                        state.currentSong.id)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.white
                                                    .withOpacity(0.75),
                                                size: 20,
                                              ),
                                              onPressed: () => {
                                                    _likeMusic(
                                                        state.currentSong.id,
                                                        !state.likeList
                                                            .contains(state
                                                                .currentSong
                                                                .id))
                                                  })
                                        ])),
                                Text(
                                  state.currentSong.artistsList.join(' '),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                )
                              ],
                            )),
                        state.player.builderCurrentPosition(
                          builder: (context, Duration position) {
                            if (state.currentLyric == null) {
                              return Expanded(
                                  child: Center(
                                child: Text(
                                  '暂无歌词',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ));
                            }
                            return Expanded(
                                child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: LyricWidget(
                                  currLyricStyle: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                  size: Size(300, 300),
                                  lyrics:
                                      LyricUtil.formatLyric(state.currentLyric),
                                  vsync: this,
                                  currentProgress:
                                      position.inMilliseconds.toDouble()),
                            ));
                          },
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(child: state.player
                                  .builderCurrentPosition(
                                      builder: (context, Duration duration) {
                                String nowTimeStr =
                                    '${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

                                return SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor:
                                        Colors.white.withOpacity(0.75),
                                    inactiveTrackColor: Colors.white38,
                                    trackHeight: 1.0,
                                    thumbColor: Colors.white.withOpacity(0.85),
                                    thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 6.0,
                                    ),
                                    overlayColor: Colors.purple.withAlpha(32),
                                    overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 14.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Slider(
                                          value: isChanged
                                              ? changedVal
                                              : duration.inSeconds.toDouble(),
                                          min: 0,
                                          max:
                                              state.currentSong.duration / 1000,
                                          onChangeStart: (double val) {
                                            setState(() {
                                              isChanged = true;
                                              changedVal = val;
                                            });
                                          },
                                          onChanged: (double val) {
                                            setState(() {
                                              isChanged = true;
                                              changedVal = val;
                                            });
                                          },
                                          onChangeEnd: (double value) {
                                            setState(() {
                                              isChanged = false;
                                            });
                                            state.player.seek(Duration(
                                                seconds: value.toInt()));
                                          }),
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  nowTimeStr,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                                Text(
                                                  state.currentSong.durationStr,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                ),
                                              ]))
                                    ],
                                  ),
                                );
                                // return Text(duration.toString());
                              })),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    state.player.builderLoopMode(
                                        builder: (context, LoopMode mode) {
                                      print('loop mode $mode');

                                      return IconButton(
                                          icon: Icon(mode == LoopMode.single
                                              ? Icons.repeat_one
                                              : (mode == LoopMode.playlist
                                                  ? Icons.repeat
                                                  : Icons.arrow_forward)),
                                          color: Colors.white.withOpacity(0.75),
                                          iconSize: 30,
                                          onPressed: () => state.toggleLoop());
                                    }),
                                    IconButton(
                                        icon: Icon(Icons.skip_previous),
                                        color: Colors.white.withOpacity(0.75),
                                        iconSize: 30,
                                        onPressed: () => state.prev()),
                                    state.player.builderIsPlaying(
                                        builder: (context, bool isplaying) {
                                      return IconButton(
                                          icon: Icon(isplaying
                                              ? Icons.pause_circle_outline
                                              : Icons.play_circle_outline),
                                          color: Colors.white.withOpacity(0.85),
                                          iconSize: 50,
                                          onPressed: () => {
                                                isplaying
                                                    ? state.pause()
                                                    : state.play()
                                              });
                                    }),
                                    IconButton(
                                        icon: Icon(Icons.skip_next),
                                        color: Colors.white.withOpacity(0.75),
                                        iconSize: 30,
                                        onPressed: () => state.next()),
                                    IconButton(
                                        icon: Icon(Icons.queue_music),
                                        color: Colors.white.withOpacity(0.75),
                                        iconSize: 30,
                                        onPressed: () => showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              StateModel state =
                                                  context.watch<StateModel>();
                                              return BottomSheetComponent(
                                                  state);
                                            }))
                                  ]),
                            ],
                          ),
                        )
                      ])),
            )));
  }
}
