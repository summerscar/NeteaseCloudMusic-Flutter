import 'package:flutter/material.dart';

class PageMy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [Icon(Icons.music_note), Text('本地音乐')],
                  ),
                  Column(
                    children: [Icon(Icons.download_rounded), Text('下载管理')],
                  ),
                  Column(
                    children: [Icon(Icons.radio), Text('我的电台')],
                  ),
                  Column(
                    children: [Icon(Icons.favorite_rounded), Text('我的收藏')],
                  )
                ]),
          ),
          Image.asset('assets/images/avatar.jpg'),
          Image.asset('assets/images/avatar.jpg'),
          Image.asset('assets/images/avatar.jpg'),
          Image.asset('assets/images/avatar.jpg')
        ],
      ),
    );
  }
}
