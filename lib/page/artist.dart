import 'package:flutter/material.dart';
import '../utils/api.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';

class ArtistPage extends StatefulWidget {
  final String artist;
  final String artistDesc;
  final int artistID;

  ArtistPage(this.artist, this.artistID, this.artistDesc);

  @override
  State<StatefulWidget> createState() {
    return _ArtistPageState(this.artist, this.artistID, this.artistDesc);
  }
}

class _ArtistPageState extends State<ArtistPage> {
  final String artist;
  final String artistDesc;
  final int artistID;
  List<dynamic> songList = [];

  _ArtistPageState(this.artist, this.artistID, this.artistDesc);

  @override
  void initState() {
    super.initState();
    api().get('/artist/top/song?id=$artistID')
    .then((res) {
      setState(() {
        songList = res.data['songs'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Function playSongOrigin = context.select((StateModel value) => value.playSongOrigin);
    Function playListOrigin = context.select((StateModel value) => value.playListOrigin);

    return Scaffold(
      appBar: AppBar(
        title: Text('歌手详情'),
      ),
      body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(15),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(this.artist, style: TextStyle(fontSize: 20),)),
                  Container(
                      padding: EdgeInsetsDirectional.only(top: 5),
                      alignment: Alignment.centerLeft,
                      child: Text(this.artistDesc ?? '', style: TextStyle(color: Colors.grey[800], height: 1.2)
                  ))
                ]
              ),
            ),
            Expanded(child: ListView.builder(
              itemCount: songList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ListTile(
                  leading: Icon(Icons.queue_music),
                  title: Text('播放热门歌曲列表'),
                  onTap: () {
                    playListOrigin(songList);
                    Navigator.pop(context);
                  },
                );
                }
                return ListTile(
                  leading: Icon(Icons.play_circle_outline),
                  onTap: () {
                    playSongOrigin(songList[index - 1]);
                    Navigator.pop(context);
                  },
                  title: Text(songList[index - 1]['name'])
                );
              }
            ))

          ],
        ),
    );
  }
}