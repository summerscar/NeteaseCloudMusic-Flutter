import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './musicList.dart';
import './../utils/api.dart';
import 'package:dio/dio.dart';

 class ExplorerPage extends StatelessWidget {

   @override
   Widget build(BuildContext context) {
     return SingleChildScrollView(
       child: Column(
         children: [
            _MusicList(),
            RaisedButton(
              onPressed: () async {
                print('clicked');
                EasyLoading.show();
                try {
                  Response response = await api().get("/login/status");
                  print('status ok');
                  print(response);
                } catch (e) {
                  print(e);
                }
                EasyLoading.dismiss();
              },
              child: Text('status'),
            ),
         ]
       ),
     );
   }
 }

 class _MusicList extends StatelessWidget {

  void getHttp(BuildContext context) async {
    List<dynamic> list;

    EasyLoading.show();
    try {
      Response response = await api().get("/top/song?type=8");
      list = response.data['data'];

      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MusicListPage(
              list: list,
              title: '最新歌曲',
            );
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('最新歌曲'),
      onPressed: () => getHttp(context),
    );
  }
}