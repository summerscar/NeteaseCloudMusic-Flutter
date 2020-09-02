import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../song/song.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

class StateModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  dynamic _userInfo;
  bool _isPlaying = false;
  AssetsAudioPlayer _player = AssetsAudioPlayer();
  Song _current;
  List<Song> _songList = [];
  String _currentSongPic;
  int _currentIndex;
  LoopMode _playMode = LoopMode.none; // none

  StateModel() {
    this._player.current.listen((playingAudio) async {
      Song cur = this
          ._songList
          .firstWhere((song) => song.songUrl == playingAudio.audio.audio.path);
      this.setCurrentSongInfo(cur);
      playingAudio.audio.audio.updateMetas(
        title: cur.name,
        artist: cur.artistsList.join(' '),
        album: cur.album['name'],
        image: MetasImage.network(cur.picUrl),
      );
      this.setPlaying(true);
    });
    this._player.playlistAudioFinished.listen((Playing playing) {
      this.setPlaying(false);
    });
    this._player.playlistFinished.listen((finished) {
      this.setPlaying(false);
    });
    this._player.loopMode.listen((loopMode) {
      this._playMode = loopMode;
    });
  }

  Song get currentSong => _current;
  String get currentSongPic => _currentSongPic;
  bool get isPlaying => _isPlaying;
  int get currentIndex => _currentIndex;
  AssetsAudioPlayer get player => _player;
  dynamic get userInfo => _userInfo;
  List<Song> get songList => _songList;
  LoopMode get playMode => this._playMode;

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
    this.player.pause();
    this._isPlaying = false;
    notifyListeners();
  }

  play() {
    if (this._current != null) {
      this.player.play();
      this._isPlaying = true;
    }
    notifyListeners();
  }

  toggleLoop () {
    final modeList = [LoopMode.none, LoopMode.playlist, LoopMode.single];
    final nowModeIndex = modeList.indexOf(this.player.currentLoopMode);
    this.player.setLoopMode(modeList[nowModeIndex + 1 > 2 ? 0 : nowModeIndex + 1]);
  }

  next() {
    this.player.next();
  }

  prev() {
    this.player.previous();
  }

  Future playSong(Song song) async {
    try {
      // if (!await song.check()) {
      //   throw ('暂无版权无法播放');
      // }
      this.setListAndIndexAfterPlay(song);
      this._currentSongPic = await this._current.getPicUrl();
      await this.player.open(
          Playlist(
              startIndex: this.songList.indexOf(this._current),
              audios: this
                  .songList
                  .map((song) => Audio.network(song.songUrl))
                  .toList()),
          loopMode: LoopMode.playlist,
          showNotification: true //loop the full playlist
          );
      print('now playing list: ${this.songList.map((e) => e.name).join('/')}');
    } catch (e) {
      Fluttertoast.showToast(
          msg: "播放出错",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          webPosition: 'center',
          fontSize: 14.0);
      print(e);
      return;
    }
    notifyListeners();
  }

  playSongOrigin(songdata) {
    this.playSong(Song(songdata));
  }

  playList(List<Song> songList) {
    this.addList(songList);
    int playIndex = 0;
    this.playSong(this.songList[playIndex]);
  }

  playListOrigin(List<dynamic> songlistdata) {
    List<Song> songlist =
        songlistdata.map((songdata) => Song(songdata)).toList();
    this.playList(songlist);
  }

  setListAndIndexAfterPlay(Song playedsong) {
    int findedIndex =
        this.songList.indexWhere((song) => song.id == playedsong.id);
    if (findedIndex == -1) {
      this.addSong(playedsong);
      this._currentIndex = this.songList.length - 1;
      this._current = playedsong;
    } else {
      this._currentIndex = findedIndex;
      this._current = this.songList[findedIndex];
    }
    notifyListeners();
  }

  setPlaying(bool isplaying) {
    this._isPlaying = isplaying;
    notifyListeners();
  }

  setCurrentSongInfo(Song song) async {
    this._current = song;
    this._currentIndex = this.songList.indexOf(song);
    this._currentSongPic = await song.getPicUrl();
    notifyListeners();
  }

  cleanList() {
    this._songList.clear();
    notifyListeners();
  }

  addSong(Song song) {
    if (this.songList.indexWhere((songinlist) => songinlist.id == song.id) > -1)
      return;

    this._songList.add(song);
    notifyListeners();
  }

  addSongOrigin(songdata) {
    this.addSong(Song(songdata));
  }

  addList(List<Song> songlist) {
    this.cleanList();
    this._songList.addAll(songlist);
    notifyListeners();
  }

  addListOrigin(List<dynamic> songlistdata) {
    List<Song> songlist =
        songlistdata.map((songdata) => (Song(songdata))).toList();
    this.addList(songlist);
  }

  int getRandomIndex() {
    if (songList.isNotEmpty) {
      Random rnd = new Random();
      return rnd.nextInt(songList.length);
    }
    return 0;
  }
}
