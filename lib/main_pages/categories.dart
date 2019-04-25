import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import './subcategory.dart';

class Categories extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('Live')
              .where('status', isEqualTo: 'online')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return new CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Color(0xfffd6a02),
                ),
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
                              Navigator.of(context).push(new MaterialPageRoute(
                                settings:
                                    const RouteSettings(name: '/Sub'),
                                builder: (context) => new SubCategoryFull(
                                     sub:ds['category']
                                    )));
                          },
                          child: Stack(
                            children: <Widget>[
                              Image.asset(
                                'assets/images/logob.png',
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${ds['category']}",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xfffd6a02)),
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
    );
  }
}
