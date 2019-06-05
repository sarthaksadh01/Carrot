import 'package:flutter/material.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../single_user_layout.dart';

class UserSearch extends StatefulWidget {
  final String search;
  UserSearch({this.search});
  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Users')
            .where('username', isGreaterThanOrEqualTo: widget.search)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return PKCardListSkeleton(
              isCircularImage: true,
              isBottomLinesActive: true,
              length: 10,
            );
          }

          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.documents[index];

                return SingleUserLayout(
                  uid: ds.documentID,
                  username: ds['username'],
                  followersList: ds['followers'],
                );
              });
        });
  }
}
