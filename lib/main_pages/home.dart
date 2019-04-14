import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import './viewlive.dart';

class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return FirebaseAnimatedList(
      query: FirebaseDatabase.instance.reference().child('Live'),
      sort: (a, b) => b.key.compareTo(a.key),
      padding: new EdgeInsets.all(8.0),
      reverse: true,
      itemBuilder:
          (_, DataSnapshot snapshot, Animation<double> animation, int) {
        return InkWell(
          onTap: (){
             Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ViewLive(
            channelName: snapshot.value['uid'],
            msgUid: snapshot.value['msg_uid'],
          )
              ),
    );
          },
          child: ListTile(
          leading: Icon(Icons.live_tv),
          title: Text(snapshot.value['category']),
          subtitle: Text(snapshot.value['hashtags']),
        ),
        );
      },
    );
  }
}
