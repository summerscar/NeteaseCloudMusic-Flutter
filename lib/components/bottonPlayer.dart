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
            top: BorderSide(
              //                   <--- left side
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
              child: state.currentSongPic != null
                  ? Image.network(
                      state.currentSongPic,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                            decoration: new BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
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
                            ? Text(state.currentSong.name)
                            : SizedBox(),
                        state.currentSong != null
                            ? Text(
                                state.currentSong.artistsList.join(' '),
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
                            IconButton(
                                icon: Icon(
                                    state.isPlaying
                                        ? Icons.pause_circle_outline_rounded
                                        : Icons.play_circle_outline_rounded,
                                    size: 30,
                                    color: state.currentSong != null
                                        ? Colors.black54
                                        : Colors.black12),
                                onPressed: state.currentSong != null
                                    ? () {
                                        if (state.isPlaying) {
                                          state.pause();
                                        } else {
                                          state.play();
                                        }
                                      }
                                    : null),
                            IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: state.songList.isEmpty
                                    ? Colors.black12
                                    : Colors.black54,
                              ),
                              onPressed: state.songList.isEmpty
                                  ? () {}
                                  : () => showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            Container(
                                          alignment: Alignment.center,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          child: ListView.builder(
                                              itemCount: state.songList.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return ListTile(
                                                  title: Row(
                                                    children: [
                                                      Text(state.songList[index]
                                                          .name),
                                                      Text(''),
                                                      Text(
                                                        ' - ${state.songList[index].artistsList.join(' ')}',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black38),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    print(state
                                                        .songList[index].name);
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              }),
                                        ),
                                      ),
                            ),
                          ]))
                ]),
              ),
            ),
          ],
        ));
  }
}
