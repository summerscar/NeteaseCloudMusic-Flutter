import 'package:flutter/material.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import './bottomSheet.dart';

class BottonPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StateModel state = context.watch<StateModel>();

    if (state.songList.isEmpty) {
      return SizedBox();
    }
    return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              //                   <--- left side
              color: Colors.black12,
              width: 1,
            ),
          ),
        ),
        height: 56,
        margin: EdgeInsets.all(0),
        child: InkWell(
          onTap: () => {
            if (state.currentSong != null)
              {Navigator.pushNamed(context, 'player')}
          },
          child: Row(
            children: <Widget>[
              Container(
                height: 55,
                width: 55,
                child: state.currentSongPic != null
                    ? Image.network(
                        state.currentSongPic,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                              decoration: new BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              width: 55,
                              height: 55);
                        },
                      )
                    : SizedBox(),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          state.currentSong != null
                              ? Text(
                                  state.currentSong.name,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : SizedBox(),
                          state.currentSong != null
                              ? Text(
                                  state.currentSong.artistsList.join(' '),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black38),
                                )
                              : SizedBox()
                        ])),
                    Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              state.player.builderIsPlaying(
                                  builder: (BuildContext context, isplaying) {
                                return IconButton(
                                    icon: Icon(
                                        isplaying
                                            ? Icons.pause_circle_outline
                                            : Icons.play_circle_outline,
                                        size: 30,
                                        color: state.currentSong == null &&
                                                state.songList.isEmpty
                                            ? Colors.black12
                                            : Colors.black54),
                                    onPressed: state.currentSong != null
                                        ? () {
                                            if (isplaying) {
                                              state.pause();
                                            } else {
                                              state.play();
                                            }
                                          }
                                        : (state.songList.isNotEmpty
                                            ? () {
                                                state.playSong(
                                                    state.songList[0]);
                                              }
                                            : () {}));
                              }),
                              IconButton(
                                icon: Icon(
                                  Icons.queue_music,
                                  color: state.songList.isEmpty
                                      ? Colors.black12
                                      : Colors.black54,
                                ),
                                onPressed: state.songList.isEmpty
                                    ? () {}
                                    : () => showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            StateModel state =
                                                context.watch<StateModel>();
                                            return BottomSheetComponent(state);
                                          },
                                        ),
                              ),
                            ]))
                  ]),
                ),
              ),
            ],
          ),
        ));
  }
}
