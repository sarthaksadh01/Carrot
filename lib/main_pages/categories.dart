import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pk_skeleton/pk_skeleton.dart';

import './subcategory.dart';

class Categories extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          indicatorColor: Color(0xfffd6a02),
          tabs: [
            Tab(
                icon: Icon(
              Icons.screen_share,
              color: Color(0xfffd6a02),
            )),
            Tab(icon: Icon(Icons.camera, color: Color(0xfffd6a02))),
          ],
        ),
        body: TabBarView(
          children: [
            StreamBuilder(
                stream: Firestore.instance
                    .collection('Categories')
                    .where("type", isEqualTo: "ScreenRecord")
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

                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot ds = snapshot.data.documents[index];
                      return Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        settings:
                                            const RouteSettings(name: '/Sub'),
                                        builder: (context) =>
                                            new SubCategoryFull(
                                                sub: ds['name'])));
                              },
                              child: Stack(
                                children: <Widget>[
                                  Image.network(
                                    ds['image'],
                                    fit: BoxFit.fill,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              new MaterialPageRoute(
                                                  settings: const RouteSettings(
                                                      name: '/Sub'),
                                                  builder: (context) =>
                                                      new SubCategoryFull(
                                                          sub: ds['name'])));
                                        },
                                        child: Text(
                                          "${ds['name']}",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xfffd6a02)),
                                        ),
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
                    },
                    staggeredTileBuilder: (int index) =>
                        new StaggeredTile.fit(2),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  );
                }),
            StreamBuilder(
                stream: Firestore.instance
                    .collection('Categories')
                    .where("type", isEqualTo: "Camera")
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

                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot ds = snapshot.data.documents[index];
                      return Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        settings:
                                            const RouteSettings(name: '/Sub'),
                                        builder: (context) =>
                                            new SubCategoryFull(
                                                sub: ds['name'])));
                              },
                              child: Stack(
                                children: <Widget>[
                                  Image.network(
                                    ds['image'],
                                    fit: BoxFit.fill,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              new MaterialPageRoute(
                                                  settings: const RouteSettings(
                                                      name: '/Sub'),
                                                  builder: (context) =>
                                                      new SubCategoryFull(
                                                          sub: ds['name'])));
                                        },
                                        child: Text(
                                          "${ds['name']}",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xfffd6a02)),
                                        ),
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
                    },
                    staggeredTileBuilder: (int index) =>
                        new StaggeredTile.fit(2),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  );
                }),
          ],
        ),
      ),
    );
  }
}
