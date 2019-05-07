import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './other_profile.dart';
import './main_pages/viewlive.dart';

class CardLayout extends StatelessWidget {
  final String uid, username, msgUid, title, category, hashtags;
  CardLayout(
      {this.uid,
      this.username,
      this.msgUid,
      this.title,
      this.category,
      this.hashtags});
  String hash = "";
  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InkWell(
                onTap: () async {
                  FirebaseAuth auth = FirebaseAuth.instance;
                  FirebaseUser user = await auth.currentUser();
                  if (user.uid == uid) {
                    Navigator.of(context).pushNamed('/Profile');
                  } else {
                    Navigator.of(context).push(new MaterialPageRoute(
                        settings: const RouteSettings(name: '/OtherProfile'),
                        builder: (context) => new OtherProfile(
                              uid: uid,
                              fullName: username,
                            )));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    username,
                    style: TextStyle(fontSize: 17, color: Color(0xfffd6a02)),
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          InkWell(
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(
                  settings: const RouteSettings(name: '/ViewLive'),
                  builder: (context) => new ViewLive(
                        channelName: uid,
                        msgUid: msgUid,
                      )));
            },
            child: Stack(
              children: <Widget>[
                Image.asset(
                  'assets/images/logob.png',
                  height: 250,
                  width: 300,
                  fit: BoxFit.fill,
                ),
                Center(
                  child: Icon(Icons.play_arrow),
                )
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                              child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "$title | $category",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(
                              child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "$hashtags",
                       overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
    );
  }
}
