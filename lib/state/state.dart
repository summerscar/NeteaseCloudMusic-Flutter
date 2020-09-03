import 'dart:developer';

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
  AssetsAudioPlayer _player;
  Song _current;
  List<Song> _songList = [];
  String _currentSongPic;
  int _currentIndex;
  LoopMode _playMode = LoopMode.playlist; // none
  String _currentLyric;
  Playlist _playlist = Playlist(audios: []);
  bool playerInited;
  List<dynamic> _myPlayList = [];

  StateModel() {
    // init player
    this.initPlayer();
  }

  Song get currentSong => _current;
  String get currentSongPic => _currentSongPic;
  bool get isPlaying => _isPlaying;
  int get currentIndex => _currentIndex;
  AssetsAudioPlayer get player => _player;
  dynamic get userInfo => _userInfo;
  List<Song> get songList => _songList;
  LoopMode get playMode => this._playMode;
  String get currentLyric => this._currentLyric;
  Playlist get playlist => this._playlist;
  List<dynamic> get myPlayList => this._myPlayList;

  void setMyPlayList(List<dynamic> data) {
    this._myPlayList = data;
    notifyListeners();
  }

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

  initPlayer() {
    if (this._player != null) {
      this._player.dispose();
      this._player = null;
    }

    this._player = AssetsAudioPlayer();
    this.playerInited = false;

    this._player.current.listen((playingAudio) async {
      Song cur = this
          ._songList
          .firstWhere((song) => song.songUrl == playingAudio.audio.audio.path);
      this.setCurrentSongInfo(cur);
      this.setPlaying(true);
      print('music changed to: ${cur.name}');
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

  toggleLoop() {
    final modeList = [LoopMode.single, LoopMode.playlist, LoopMode.none];
    final nowModeIndex = modeList.indexOf(this.player.currentLoopMode);
    this.player.setLoopMode(
        modeList[nowModeIndex + 1 > modeList.length ? 0 : nowModeIndex + 1]);
  }

  next() {
    this.player.next();
  }

  prev() {
    this.player.previous();
  }

  remove(Song song) {
    if (this.songList.length == 1) {
      this.player.stop();
      this._currentIndex = null;
      this._current = null;
      this._currentLyric = null;
      this._currentSongPic = null;
    }
    int index = this.songList.indexOf(song);
    this._songList.removeAt(index);
    this._playlist.removeAtIndex(index);
    notifyListeners();
  }

  removeAll() {
    this.player.stop();
    this.cleanList();
    this._currentIndex = null;
    this._current = null;
    this._currentLyric = null;
    this._currentSongPic = null;
    notifyListeners();
  }

  Future playSong(Song song) async {
    try {
      // if (!await song.check()) {
      //   throw ('暂无版权无法播放');
      // }
      this.setListAndIndexAfterPlay(song);

      print('play index: $currentIndex');

      if (!playerInited) {
        this.player.open(this.playlist,
            autoStart: false,
            loopMode: LoopMode.playlist,
            showNotification: true //loop the full playlist
            );
        this.playerInited = true;
      }
      this.player.playlistPlayAtIndex(this.currentIndex);
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
    this._currentLyric = await song.getLyric();
    notifyListeners();
  }

  cleanList() {
    this._player.playlistPlayAtIndex(0);
    this._songList.clear();
    this._playlist.audios.clear();
    this.playerInited = false;
    notifyListeners();
  }

  addSong(Song song) async {
    if (this.songList.indexWhere((songinlist) => songinlist.id == song.id) > -1)
      return;

    Audio audio = Audio.network(song.songUrl,
        metas: Metas(
            title: song.name,
            artist: song.artistsList.join(' '),
            album: song.album['name']));

    this._playlist.add(audio);
    this._songList.add(song);
    print('now list: ${this._songList.map((e) => e.name).join('/')}');
    notifyListeners();
    song
        .getPicUrl()
        .then((value) => audio.updateMetas(image: MetasImage.network(value)));
  }

  addSongOrigin(songdata) {
    this.addSong(Song(songdata));
  }

  addList(List<Song> songlist) async {
    if (this.player.isPlaying.value) {
      this.player.stop();
    }
    this.cleanList();
    this._songList.addAll(songlist);

    List<Audio> audios = songlist
        .map((song) => Audio.network(song.songUrl,
            metas: Metas(
                title: song.name,
                artist: song.artistsList.join(' '),
                album: song.album['name'])))
        .toList();
    this._playlist.addAll(audios);
    print('now list: ${this._songList.map((e) => e.name).join('/')}');
    notifyListeners();

    Future.wait(songlist.map((song) => song.getPicUrl()))
        .then((List<String> value) {
      value.asMap().forEach((index, url) {
        audios[index].updateMetas(image: MetasImage.network(url));
      });
    }).catchError((e) {
      print(e);
    });
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
