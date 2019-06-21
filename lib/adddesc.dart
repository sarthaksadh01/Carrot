import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_tags/input_tags.dart';
import './golive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './golive_screen.dart';

class AddDescFull extends StatefulWidget {
  final String media;
  AddDescFull({this.media});
  @override
  _AddDescFullState createState() => _AddDescFullState();
}

class _AddDescFullState extends State<AddDescFull> {
  List<String> hash = [];
  List<String> elements1 = [];
  Map<String, String> map = {};
  String title = "";
  String userName = "";
  String upic;
  int level;
  String categoryName;
  bool loading = true;

  @override
  void initState() {
    _loadList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfffd6a02),
        title: Text("Go Live!"),
      ),
      body: loading == false
          ? SingleChildScrollView(
              child: Center(
                  child: Column(children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text("Select Category!"),
                    value: categoryName,
                    onChanged: (String newValue) {
                      setState(() {
                        categoryName = newValue;
                      });
                    },
                    items:
                        elements1.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                  child: Container(
                    decoration: new BoxDecoration(border: new Border.all()),
                    height: 100,
                    padding: EdgeInsets.all(10.0),
                    child: new ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 100.0,
                      ),
                      child: new Scrollbar(
                        child: new SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          child: SizedBox(
                            height: 90.0,
                            child: new TextField(
                              onChanged: (val) {
                                setState(() {
                                  title = val;
                                });
                              },
                              maxLines: 10,
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Describe your stream',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InputTags(
                  placeholder: "Add hashtags",
                  tags: hash,
                  height: 45,
                  inputDecoration: new InputDecoration(
                    border:
                        new OutlineInputBorder(borderSide: new BorderSide()),
                    hintText: 'Add hashtags',
                  ),
                )
              ])),
            )
          : Center(
              child: FlareActor(
                "assets/flare/loading.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: "Untitled",
              ),
            ),
      bottomNavigationBar: MaterialButton(
        height: 45,
        color: Color(0xfffd6a02),
        child: Text(
          "Start",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _golive();
        },
      ),
    );
  }

  _golive() async {
    if (title.trim() == "") {
      Fluttertoast.showToast(
          msg: "Title cannot be empty!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (categoryName == null) {
      Fluttertoast.showToast(
          msg: "Please select a category!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    Firestore.instance.collection('Users').document(user.uid).get().then((doc) {
      setState(() {
        userName = doc.data['username'];
        level = doc.data['level'];
        upic = doc.data['pic'];
      });
      List<String> hashAndTitle = [];
      for (int i = 0; i < hash.length; i++) {
        hash[i] = "#" + hash[i];
      }
      hashAndTitle.addAll(hash);
      hashAndTitle.add("sarthak@sid@monga@carrot@simosa");
      hashAndTitle.add("#" + categoryName.toLowerCase());
      hashAndTitle.add("#" + userName);
      List<String> tempTitle = title.split(" ");
      for (int i = 0; i < tempTitle.length; i++) {
        hashAndTitle.add("#" + tempTitle[i].toLowerCase());
      }
      // await _handleCameraAndMic();

      if (widget.media == "Camera") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GoLive(
                    channelName: user.uid,
                    category: categoryName,
                    hashtags: hashAndTitle,
                    title: title.trim(),
                    img: map[categoryName],
                    username: userName,
                    level: level,
                    uPic: upic,
                  )),
        );
      } else {
        Navigator.of(context).push(new MaterialPageRoute(
            settings: const RouteSettings(name: '/ScreenRecord'),
            builder: (context) => new ScreenRecord(
                  channelName: user.uid,
                  category: categoryName,
                  hashtags: hashAndTitle,
                  title: title.trim(),
                  img: map[categoryName],
                  username: userName,
                  level: level,
                  uPic: upic,
                )));
      }
    });
  }

  _loadList() {
    Firestore.instance
        .collection("Categories")
        .where("type", isEqualTo: widget.media)
        .getDocuments()
        .then((docs) {
      docs.documents.forEach((doc) {
        setState(() {
          // categoryName=doc.data['name'];
          elements1.add(doc.data['name']);
          map[doc.data['name']] = doc.data['image'];
        });
      });

      setState(() {
        loading = false;
      });
      print(map);
    });
  }
}
