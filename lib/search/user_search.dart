import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../single_user_layout.dart';

class UserSearch extends StatefulWidget {
  final String search;
  UserSearch({this.search});
  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  List<SingleUserLayout> list = [];
  var _lastDocument;
  RefreshController _refreshController;
  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: true);
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
          footer: ClassicFooter(),
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropMaterialHeader(
        backgroundColor: Color(0xfffd6a02),
      ),
      controller: _refreshController,
      onRefresh: _refresh,
      onLoading: _loadMore,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
    );
  }

  _loadMore() async {
    Firestore.instance
        .collection('Users')
        .where('username', isGreaterThanOrEqualTo: widget.search)
        .startAfter([_lastDocument['username']])
        .limit(10)
        .getDocuments()
        .then((docs) {
          setState(() {
            _lastDocument = docs.documents.last;
          });

          docs.documents.forEach((doc) {
            SingleUserLayout singleUserLayout = new SingleUserLayout(
              uid: doc.documentID,
              username: doc['username'],
              followersList: doc['followers'],
            );
            setState(() {
              list.add(singleUserLayout);
            });
          });
          setState(() {
            _refreshController.loadComplete();
          });
        })
        .catchError((onError) {
          _refreshController.loadNoData();
        });
  }

  _load() async {
    Firestore.instance
        .collection('Users')
        .where('username', isGreaterThanOrEqualTo: widget.search)
        .limit(10)
        .getDocuments()
        .then((docs) {
          setState(() {
            list.clear();
            _lastDocument = docs.documents.last;
          });

          docs.documents.forEach((doc) {
            print(doc);
            SingleUserLayout singleUserLayout = new SingleUserLayout(
              uid: doc.documentID,
              username: doc['username'],
              followersList: doc['followers'],
            );
            setState(() {
              list.add(singleUserLayout);
            });
          });
          setState(() {
            _refreshController.refreshCompleted();
          });
        })
        .catchError((onError) {
          _refreshController.refreshFailed();
        });
  }

  _refresh() async {
    setState(() {
      _refreshController.loadComplete();
    });
    _load();
  }
}
