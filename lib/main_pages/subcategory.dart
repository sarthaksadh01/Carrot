import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cardlayout.dart';
import 'package:pk_skeleton/pk_skeleton.dart';

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
      appBar: AppBar(
        title: Text(widget.sub),
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('Live')
              .where('status', isEqualTo: 'online')
              .where('category', isEqualTo: widget.sub)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                // Can be placed alone or in a ListView builder
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
