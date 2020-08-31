import 'package:flutter/material.dart'
;
class BottonPlayer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide( //                   <--- left side
            color: Colors.black12,
            width: 1,
          ),
        ),
      ),
      height: 56,
      margin: EdgeInsets.all(0),
      child: Row(
        children: <Widget>[
          Container(
            height: 55,
            width: 55,
            color: Colors.green,
            child: Image.asset('assets/images/avatar.jpg'),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('title'),
                        Text('artist',
                          style: TextStyle(
                            color: Colors.black38
                          ),
                        )
                      ],
                    )
                  ),
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 30,
                          color: Colors.black54
                        ),
                        Icon(
                          Icons.playlist_play_rounded,
                          size: 35,
                          color: Colors.black54,
                        ),
                      ]
                    )
                  )
                ]
              ),
            ),
          ),
        ],
      ));
  }
}