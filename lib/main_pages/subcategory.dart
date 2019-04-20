import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class SubCategoryFull extends StatefulWidget {
  final String sub;
  SubCategoryFull({this.sub});
  @override
  _SubCategoryFullState createState() => _SubCategoryFullState();
}

class _SubCategoryFullState extends State<SubCategoryFull> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sub),
      backgroundColor: Color(0xfffd6a02),),
      body: FirebaseAnimatedList(
      query: FirebaseDatabase.instance
          .reference()
          .child("Live")
          .orderByChild('category')
          .equalTo(widget.sub),
      sort: (a, b) => b.key.compareTo(a.key),
      padding: new EdgeInsets.all(8.0),
      itemBuilder:
          (_, DataSnapshot snapshot, Animation<double> animation, int) {
        return new Card(
            elevation: 1.5,
            child: Container(
                width: MediaQuery.of(context).size.width / 1.2,
                height: 300,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Image.network(
                        'https://cdn.pixabay.com/photo/2016/10/27/22/53/heart-1776746_960_720.jpg',
                        height: 230,
                        width: MediaQuery.of(context).size.width / 1.2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                      ),
                      Text(
                        snapshot.value['title'],
                        // cat,
                        style: TextStyle(
                            color: Color(0xfffd6a02),
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                      ),
                      Text(
                        snapshot.value['hashtags'],
                        // sub,
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                )));
      },
    ),
    );
  }
}
