import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import './cardlayout.dart';

class Search extends StatefulWidget {
  final String search;
  Search({this.search});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.search.substring(1, widget.search.length)),
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('Live')
              .where('status', isEqualTo: 'online')
              .where("hashtags", arrayContains: widget.search)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return PKCardPageSkeleton(
                        totalLines: 5,
                      );
                    }),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  String hashSimplified = "";
                  for (int i = 0; i < ds['hashtags'].length; i++) {
                    if (ds['hashtags'][i] == "sarthak@sid@monga@carrot@simosa")
                      break;
                    hashSimplified += ds['hashtags'][i] + " ";
                    print(hashSimplified);
                  }
                  return CardLayout(
                    uid: ds['uid'],
                    username: ds['username'],
                    msgUid: ds['msg_uid'],
                    title: ds['title'],
                    category: ds['category'],
                    hashtags: hashSimplified,
                    img: ds['img'],
                  );
                });
          }),
    );
  }
}
