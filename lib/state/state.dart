import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../song/song.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

enum LoopMode { none, single, playlist, random }
class StateModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  dynamic _userInfo;
  bool _isPlaying = false;
  AssetsAudioPlayer _player = AssetsAudioPlayer();
  Song _current;
  List<Song> _songList = [];
  String _currentSongPic;
  int _currentIndex;
  LoopMode _playMode = LoopMode.none;   // none

  StateModel () {
    this._player.current.listen((playingAudio){
        // Song cur = this._songList.firstWhere((song) => song.songUrl == playingAudio.audio.audio.path);
        this.setPlaying(true);
    });
    this._player.playlistAudioFinished.listen((Playing playing){
        this.setPlaying(false);
    });
    this._player.playlistFinished.listen((finished){
        this.setPlaying(false);
        if (this.songList.isNotEmpty) {
          this.next();
        }
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

  next() {
    int songIndex = this.currentIndex + 1 > this.songList.length
        ? 0
        : this.currentIndex + 1;
    if (playMode == LoopMode.none && this.currentIndex == this.songList.length - 1) return;

    if (this.playMode == LoopMode.random) {
      songIndex = this.getRandomIndex();
    }
    print('next ${this.songList[songIndex].name}');
    this.playSong(this.songList[songIndex]);
    notifyListeners();
  }

  prev() {
    int songIndex = this.currentIndex - 1 < 0
        ? this.songList.length - 1
        : this.currentIndex - 1;
    if (this.playMode == LoopMode.random) {
      songIndex = this.getRandomIndex();
    }
    this.playSong(this.songList[songIndex]);
    notifyListeners();
  }

  Future playSong(Song song) async {
    if (this.isPlaying) {
      this.player.stop();
    }
    print(song.name);
    print(song.songUrl);
    try {
      // if (!await song.check()) {
      //   throw ('暂无版权无法播放');
      // }
      this.setListAndIndexAfterPlay(song);
      this._currentSongPic = await song.getPicUrl();
      await this.player.open(
            Audio.network(
                song.songUrl,
                metas: Metas(
                  title:  "Country",
                  artist: "Florent Champigny",
                  album: "CountryAlbum",
                  image: MetasImage.network('this._currentSongPic'),
                )
              ),
              showNotification: true
          );
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

  playSongOrigin (songdata) {
    this.playSong(Song(songdata));
  }

  playList (List<Song> songList) {
    this.addList(songList);
    int playIndex = 0;
    if (this.playMode == LoopMode.random) {
      playIndex = this.getRandomIndex();
    }
    this.playSong(this.songList[playIndex]);
  }

  playListOrigin (List<dynamic> songlistdata) {
    List<Song> songlist = songlistdata.map((songdata) => Song(songdata));
    this.playList(songlist);
  }

  setListAndIndexAfterPlay (Song playedsong) {
    int findedIndex = this.songList.indexWhere((song) => song.id == playedsong.id);
    if (findedIndex == -1) {
      this.addSong(playedsong);
      this._currentIndex = this.songList.length - 1;
    } else {
      this._currentIndex = findedIndex;
    }
    this._current = playedsong;
    notifyListeners();
  }

  setPlaying (bool isplaying) {
    this._isPlaying = isplaying;
    notifyListeners();
  }

  setCurrentSong (Song song) {
    this._current = song;
    notifyListeners();
  }

  cleanList() {
    this._songList.clear();
    notifyListeners();
  }
  addSong(Song song) {
    if (this.songList.indexWhere((songinlist) => songinlist.id == song.id) > -1) return;

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
    List<Song> songlist = songlistdata.map((songdata) => (Song(songdata)));
    this.addList(songlist);
  }

  int getRandomIndex () {
    if (songList.isNotEmpty) {
      Random rnd = new Random();
      return rnd.nextInt(songList.length);
    }
    return 0;
  }
}
