import 'package:flutter/material.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';
import '../utils/api.dart';

class MusicListPage extends StatelessWidget {
  MusicListPage({
    Key key,
    this.title = '音乐列表',
    @required this.list, // 接收一个text参数
    this.id = 0,
    this.canDel = false
  }) : super(key: key);

  final List list;
  final String title;
  final int id;
  final bool canDel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: _BuildMusicList(items: list, canDel: this.canDel, id: this.id));
  }
}

class _BuildMusicList extends StatelessWidget {
  final List<dynamic> items;
  final bool canDel;
  final int id;

  _BuildMusicList({Key key, @required this.items, this.canDel, this.id}) : super(key: key);

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

    void _removeFromList (int id) {
      api().get('/playlist/tracks?op=del&pid=${this.id}&tracks=$id')
      .then((res) {
        print(res.data);
      })
      .catchError((e) {
        print(e);
      });
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
          physics: const AlwaysScrollableScrollPhysics(), // new,
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              direction: this.canDel ? DismissDirection.endToStart : null,
              key: new Key(items[index]['id'].toString()),
              background: new Container(
                child: Padding(padding: EdgeInsets.only(right: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                  '删除',
                  style: TextStyle(
                    color: Colors.white
                  )
                )),) ,
                color: Colors.red
              ),
              onDismissed: (direction) {
                items.removeAt(index);
                Scaffold.of(context).showSnackBar(
                      new SnackBar(content: new Text("${items[index]['name']} 已移出列表")));
                _removeFromList(items[index]['id']);
              },
              child: ListTile(
                title: Text(items[index]['name']),
                subtitle: Text((items[index]['artists'] ?? items[index]['ar'])
                    .map((artist) => artist['name'])
                    .join(' / ')),
                onTap: () => _clickHandler(items[index]),
                trailing: IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () => state.addSongOrigin(items[index])),
              )
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
