import 'package:flutter/material.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';

class BottonPlayer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    StateModel state = context.watch<StateModel>();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide( //                   <--- left side
            color: Colors.black12,
            width: 1,
          ),
        ),
      ),
      height: 56,
      margin: EdgeInsets.all(0),
      child: Row(
        children: <Widget>[
          Container(
            height: 55,
            width: 55,
            color: Colors.green,
            child: Image.network(
              state.currentSongPic ?? 'https://p1.music.126.net/wdD9S0BorAeBN28hE7WLKA==/3294136838291288.jpg',
              loadingBuilder: (BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: new BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
                  width: 55,
                  height: 55
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        state.currentSong != null ? Text(state.currentSong.name) : SizedBox(),
                        state.currentSong != null ?
                        Text(
                          state.currentSong.artistsList.join(' '),
                          style: TextStyle(
                            color: Colors.black38
                          ),
                        ) : SizedBox()
                      ]
                    )
                  ),
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            state.isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                            size: 30,
                            color: state.currentSong != null ? Colors.black54 : Colors.black12
                          ),
                          onPressed: state.currentSong != null ? () {
                            if (state.isPlaying) {
                              state.pause();
                            } else {
                              state.play();
                            }
                          } : null
                        ),
                        Icon(
                          Icons.playlist_play_rounded,
                          size: 35,
                          color: Colors.black54,
                        ),
                      ]
                    )
                  )
                ]
              ),
            ),
          ),
        ],
      ));
  }
}