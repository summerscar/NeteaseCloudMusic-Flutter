import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../song/song.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StateModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  dynamic _userInfo;
  bool _isPlaying = false;
  AssetsAudioPlayer _player = AssetsAudioPlayer();
  Song _current;
  List<Song> _songList = [];
  String _currentSongPic;

  Song get currentSong => _current;
  String get currentSongPic => _currentSongPic;
  bool get isPlaying => _isPlaying;
  int get currentIndex => _songList.indexWhere((song) => song == _current);
  AssetsAudioPlayer get player => _player;
  dynamic get userInfo => _userInfo;
  List<Song> get songList => _songList;

  void setUserInfo(dynamic userInfo) async {
    final prefs = await SharedPreferences.getInstance();

    if (userInfo == null) {
      print('remove storage: userInfo');
      prefs.remove('userInfo');
    } else {
      print('set storage: userInfo');
      prefs.setString('userInfo', jsonEncode(userInfo));
    }
    _userInfo = userInfo;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  pause() {
    if (this.isPlaying) {
      this.player.pause();
      this._isPlaying = false;
    }
    notifyListeners();
  }

  play() {
    if (!this.isPlaying && this._current != null) {
      this.player.play();
      this._isPlaying = true;
    }
    notifyListeners();
  }

  prev() {
    int songIndex = this.currentIndex + 1 > this.songList.length
        ? 0
        : this.currentIndex + 1;

    this.playSong(this.songList[songIndex]);
    notifyListeners();
  }

  next() {
    int songIndex = this.currentIndex - 1 < 0
        ? this.songList.length - 1
        : this.currentIndex - 1;

    this.playSong(this.songList[songIndex]);
    notifyListeners();
  }

  Future playSong(Song song) async {
    if (this.isPlaying) {
      this.player.stop();
    }
    try {
      // if (!await song.check()) {
      //   throw ('暂无版权无法播放');
      // }
      await this.player.open(
            Audio.network(
                'https://music.163.com/song/media/outer/url?id=${song.id}.mp3'),
          );
    } catch (e) {
      Fluttertoast.showToast(
          msg: "暂无版权无法播放",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          webPosition: 'center',
          fontSize: 14.0);
      print(e);
      return;
    }
    this._current = song;
    this._currentSongPic = await this.currentSong.getPicUrl();
    this._isPlaying = true;
  }

  cleanList() {
    this._songList.clear();
    notifyListeners();
  }

  addSong(Song song) {
    this._songList.add(song);
    notifyListeners();
  }

  addSongs(List<Song> list) {
    this._songList.addAll(list);
    notifyListeners();
  }

  cleanThenAddSongsAndPlay(List<dynamic> listdata) async {
    if (listdata.isEmpty) return;

    List<Song> list = listdata.map((songdata) => Song(songdata));
    this.cleanList();
    this.addSongs(list);
    await this.playSong(list[0]);
    notifyListeners();
  }

  cleanThenAddSongAndPlay(dynamic songdata) async {
    Song song = Song(songdata);
    this.cleanList();
    this.addSong(song);
    await this.playSong(song);
    notifyListeners();
  }
}
