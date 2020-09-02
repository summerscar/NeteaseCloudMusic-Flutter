import 'package:flutter/material.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:assets_audio_player/assets_audio_player.dart';

class PlayerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<StatefulWidget> {
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
    return Scaffold(
        body: Container(
            decoration: state.currentSongPic != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(state.currentSongPic),
                      fit: BoxFit.cover,
                    ),
                  )
                : BoxDecoration(color: Colors.grey[300]),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                  alignment: Alignment.center,
                  color: Colors.grey.withOpacity(0.1),
                  child: Column(children: [
                    Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: [
                        Image.network(state.currentSongPic),
                        IconButton(
                            icon: Icon(Icons.expand_more),
                            color: Colors.white,
                            onPressed: () => Navigator.pushNamed(context, '/')),
                      ],
                    ),
                    Container(
                        padding:
                            EdgeInsetsDirectional.only(top: 20, bottom: 10),
                        child: Text(
                          state.currentSong.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.normal),
                        )),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          state.currentSong.artistsList.join(' '),
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        )),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(child: state.player.builderCurrentPosition(
                            builder: (context, Duration duration) {
                          String nowTimeStr =
                              '${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white38,
                              trackHeight: 2.0,
                              thumbColor: Colors.white,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 6.0,
                              ),
                              overlayColor: Colors.purple.withAlpha(32),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 14.0),
                            ),
                            child: Column(
                              children: [
                                Slider(
                                    value: isChanged
                                        ? changedVal
                                        : duration.inSeconds.toDouble(),
                                    min: 0,
                                    max: state.currentSong.duration / 1000,
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
                                        isChanged = true;
                                      });
                                      state.player.seek(
                                          Duration(seconds: value.toInt()));
                                    }),
                                Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.favorite_border),
                                  color: Colors.white,
                                  iconSize: 30,
                                  onPressed: () => {}),
                              IconButton(
                                  icon: Icon(Icons.skip_previous),
                                  color: Colors.white,
                                  iconSize: 30,
                                  onPressed: () => state.prev()),
                              state.player.builderIsPlaying(
                                  builder: (context, bool isplaying) {
                                return IconButton(
                                    icon: Icon(isplaying
                                        ? Icons.pause_circle_outline
                                        : Icons.play_circle_outline),
                                    color: Colors.white,
                                    iconSize: 50,
                                    onPressed: () => {
                                          isplaying
                                              ? state.pause()
                                              : state.play()
                                        });
                              }),
                              IconButton(
                                  icon: Icon(Icons.skip_next),
                                  color: Colors.white,
                                  iconSize: 30,
                                  onPressed: () => state.next()),
                              state.player.builderLoopMode(
                                  builder: (context, LoopMode mode) {
                                print('loop mode $mode');

                                return IconButton(
                                    icon: Icon(mode == LoopMode.single
                                        ? Icons.repeat_one
                                        : (mode == LoopMode.playlist
                                            ? Icons.repeat
                                            : Icons.arrow_forward)),
                                    color: Colors.white,
                                    iconSize: 30,
                                    onPressed: () => state.toggleLoop());
                              })
                            ])
                      ],
                    ))
                  ])),
            )));
  }
}
