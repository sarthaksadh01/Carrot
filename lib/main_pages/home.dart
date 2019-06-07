import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../cardlayout.dart';
import '../ads_layout.dart';

class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  List<CardLayout> list = [];
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
    return Scaffold(
        body: SmartRefresher(
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
    ));
  }

  _loadMore() async {
    Firestore.instance
        .collection('Live')
        .where('status', isEqualTo: 'online')
        .orderBy("start_time", descending: true)
        .startAfter([_lastDocument['start_time']])
        .limit(5)
        .getDocuments()
        .then((docs) {
          setState(() {
            _lastDocument = docs.documents.last;
          });

          docs.documents.forEach((doc) {
            String hashSimplified = "";
            for (int i = 0; i < doc['hashtags'].length; i++) {
              if (doc['hashtags'][i] == "sarthak@sid@monga@carrot@simosa")
                break;
              hashSimplified += doc['hashtags'][i] + " ";
            }
            CardLayout cardLayout = new CardLayout(
              uid: doc['uid'],
              username: doc['username'],
              msgUid: doc['msg_uid'],
              title: doc['title'],
              category: doc['category'],
              hashtags: hashSimplified,
              img: doc['img'],
              docId: doc.documentID,
              likesList: doc['likes'],
              viewers: doc['viewers'],
              commentList: doc['comments'],
            );
            setState(() {
              list.add(cardLayout);
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
        .collection('Live')
        .where('status', isEqualTo: 'online')
        .orderBy("start_time", descending: true)
        .limit(5)
        .getDocuments()
        .then((docs) {
      setState(() {
        list.clear();
        _lastDocument = docs.documents.last;
      });

      docs.documents.forEach((doc) {
        print(doc);
        String hashSimplified = "";
        for (int i = 0; i < doc['hashtags'].length; i++) {
          if (doc['hashtags'][i] == "sarthak@sid@monga@carrot@simosa") break;
          hashSimplified += doc['hashtags'][i] + " ";
        }
        CardLayout cardLayout = new CardLayout(
          uid: doc['uid'],
          username: doc['username'],
          msgUid: doc['msg_uid'],
          title: doc['title'],
          category: doc['category'],
          hashtags: hashSimplified,
          img: doc['img'],
          docId: doc.documentID,
          likesList: doc['likes'],
          viewers: doc['viewers'],
          commentList: doc['comments'],
        );
        setState(() {
          list.add(cardLayout);
        });
      });
      setState(() {
        _refreshController.refreshCompleted();
      });
    }).catchError((onError) {
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
