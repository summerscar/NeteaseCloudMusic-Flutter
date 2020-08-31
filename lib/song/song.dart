import '../utils/api.dart';
import 'package:dio/dio.dart';

class Song {
  int id;
  String name;
  int duration;
  List<dynamic> artists;
  Map<String, dynamic> album;
  String picUrl;
  bool canPlay;

  Song(Map song) {
    this.id = song['id'];
    this.name = song['name'];
    this.duration = song['duration'];
    this.artists = song['artists'];
    this.album = song['album'];
  }

  String get songUrl =>
      'https://music.163.com/song/media/outer/url?id=${this.id}.mp3';
  dynamic get artistsList {
    return this.artists.map((artist) => artist['name']);
  }

  String get durationStr {
    String mm = (this.duration / 1000 ~/ 60).toString();
    String ss =
        ((this.duration / 1000) % 60).toInt().toString().padLeft(2, '0');
    return '$mm : $ss';
  }

  Future<String> getPicUrl() async {
    if (this.picUrl != null) {
      return this.picUrl;
    }

    Response res = await api().get('/album?id=${this.album['id']}');
    List<dynamic> songs = res.data['songs'];
    dynamic song = songs.firstWhere((song) => song['id'] == this.id);
    print('pic ${song['al']['picUrl']}');
    this.picUrl = song['al']['picUrl'];
    return this.picUrl;
  }

  Future<bool> check() async {
    if (this.canPlay != null) return this.canPlay;

    Response res = await api().get('/check/music?id=${this.id}');
    this.canPlay = res.data['success'];
    return this.canPlay;
  }
}
