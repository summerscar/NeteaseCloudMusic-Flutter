import 'package:flutter/material.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';

class MusicListPage extends StatelessWidget {
  MusicListPage({
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
              subtitle: Text((items[index]['artists'] ?? items[index]['ar'])
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
