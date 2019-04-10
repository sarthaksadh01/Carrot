import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class Categories extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Categories> {
  final reference = FirebaseDatabase.instance.reference().child('categories');
  List<Widget> catgr = [];
  Map<dynamic, dynamic> values;
  @override
  void initState() {
    final db = FirebaseDatabase.instance.reference().child("categories");
    db.once().then((DataSnapshot snapshot) {
      setState(() {
        values = snapshot.value;
        values.forEach((key, values) {
          catgr.add(Card(
              elevation: 1.5,
              child: Container(
                  width: MediaQuery.of(context).size.width / 1.8,
                  height: 300,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Image.network(
                          values,
                          height: 230,
                          width: MediaQuery.of(context).size.width / 2.2,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Text(
                          key,
                          style: TextStyle(
                              color: Color(0xfffd6a02),
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Text(
                          "82.7k viewers",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ))));
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return catgr.length != null
        ? GridView.builder(
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: .65),
            itemCount: catgr.length,
            itemBuilder: (BuildContext context, index) {
              return catgr[index];
            },
          )
        : Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xfffd6a02),
            ),
          );

  }
}
