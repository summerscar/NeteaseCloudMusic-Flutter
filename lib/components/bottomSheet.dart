import 'package:flutter/material.dart';
import '../state/state.dart';
// import 'package:provider/provider.dart';

class BottomSheetComponent extends StatelessWidget {
  final StateModel state;
  BottomSheetComponent(this.state);

  @override
  Widget build(BuildContext context) {
    print('list length ${state.songList.length}');
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(right: 18, left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.queue_music,
                        color: Colors.grey[600],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                        ),
                        child: Text('当前播放${state.songList.length}首'),
                      )
                    ],
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.delete_sweep,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        state.removeAll();
                        Navigator.pushNamed(context, '/');
                      })
                ],
              )),
          Expanded(
              child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(), // new,
                  itemCount: state.songList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: state.currentIndex == index
                          ? Icon(
                              Icons.music_note,
                              color: Theme.of(context).primaryColor,
                            )
                          : SizedBox(),
                      title: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(children: [
                          TextSpan(
                            text: state.songList[index].name,
                            style: TextStyle(
                              color: state.currentIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' - ${state.songList[index].artistsList.join(' ')}',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                        ]),
                      ),
                      trailing: state.currentIndex == index &&
                              index == state.songList.length - 1
                          ? SizedBox()
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                state.remove(state.songList[index]);
                              }),
                      onTap: () {
                        state.playSong(state.songList[index]);
                        Navigator.pop(context);
                      },
                    );
                  }))
        ],
      ),
    );
  }
}
