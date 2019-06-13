import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';

class Wallet extends StatefulWidget {
  final String uid;
  Wallet({this.uid});
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  int balane = 0;
  bool loading = true;
  List<dynamic> list = [];
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading == false
        ? Scaffold(
            appBar: AppBar(
              // leading: Icon(Icons.arrow_back_ios, color: Colors.black),
              // backgroundColor: Colors.white,
              title: Text(
                "Wallet",
                // style: TextStyle(color: Colors.black),
              ),
            ),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Transactions",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                list.length > 0
                    ? Expanded(
                        child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return list[index];
                        },
                      ))
                    : Image.asset("assets/images/notfound.png",
                        height: 200, width: 200)
              ],
            ),
            bottomNavigationBar: Container(
              margin: EdgeInsets.all(30),
              height: 50,
              // width:100 ,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFf45d27), Color(0xFFf5851f)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(80))),
              child: Center(
                  child: Text(
                "Redeem  \u20B9$balane",
                style: TextStyle(color: Colors.white),
              )),
            ),
          )
        : Scaffold(
            body: Center(
              child: FlareActor(
                "assets/flare/loading.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: "Untitled",
              ),
            ),
          );
  }

  _loadData() {
    Firestore.instance
        .collection('Txn')
        .where("between", arrayContains: widget.uid)
        .getDocuments()
        .then((docs) {
      docs.documents.forEach((doc) {
        setState(() {
          var date = new DateTime.fromMicrosecondsSinceEpoch(doc.data['time']);
          if (doc.data['donated_by'] == widget.uid) {
            list.add(ListTile(
              leading: Icon(FontAwesomeIcons.donate,color: Colors.pink,),
              isThreeLine: true,
              title: Text("\u20B9 ${doc.data['amnt']}"),
              subtitle: Text("to ${doc.data['donated_to_username']}"),
              // trailing: Text("${date.day}/${date.month}/${date.year}"),
            ));
          } else {
            list.add(ListTile(
              leading: Icon(FontAwesomeIcons.gift,color: Colors.green,),
              isThreeLine: true,
              title: Text("\u20B9 ${doc.data['amnt']}"),
              subtitle: Text("from ${doc.data['donated_by_username']}"),
              // trailing: Text("${date.day}/${date.month}/${date.year}"),
            ));
          }
        });
      });
      Firestore.instance
          .collection("Users")
          .document(widget.uid)
          .get()
          .then((doc) {
        setState(() {
          balane = doc.data['wallet'];
        });
      }).then((onValue) {
        setState(() {
          loading = false;
        });
      });
    });
  }
}
