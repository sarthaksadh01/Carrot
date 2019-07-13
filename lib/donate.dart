import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_upi/flutter_upi.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import './url.dart';

class Donate extends StatefulWidget {
  final String uid;

  Donate({this.uid});
  @override
  _DonateState createState() => _DonateState();
}

class _DonateState extends State<Donate> {
  String amount;
  String msg;
  String username;
  bool loading = true;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading != true
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("Donate"),
            ),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Donate to " + username,
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text("Choose Amount!(INR)"),
                    value: amount,
                    onChanged: (String newValue) {
                      setState(() {
                        amount = newValue;
                      });
                    },
                    items: [
                      '10',
                      '50',
                      '100',
                      '200',
                      '500',
                      '1000',
                      '5000',
                      '10000'
                    ].map<DropdownMenuItem<String>>((String value) {
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
                                  msg = val;
                                });
                              },
                              maxLines: 10,
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Add a short message!',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 20,
                        child: Image.asset(
                          "assets/images/pytm.jpeg",
                          height: 50,
                        ),
                        onPressed: () {
                          _donate(FlutterUpiApps.PayTM);
                        },
                      ),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 20,
                        child: Image.asset(
                          "assets/images/gpay.jpg",
                          height: 50,
                        ),
                        onPressed: () {
                          _donate(FlutterUpiApps.GooglePay);
                        },
                      ),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 20,
                        child: Image.asset(
                          "assets/images/phonepe.png",
                          height: 50,
                        ),
                        onPressed: () {
                          _donate(FlutterUpiApps.PhonePe);
                        },
                      ),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 20,
                        child: Image.asset(
                          "assets/images/bhim.jpg",
                          height: 50,
                        ),
                        onPressed: () {
                          _donate(FlutterUpiApps.BHIMUPI);
                        },
                      ),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 20,
                        child: Image.asset(
                          "assets/images/airtel.png",
                          height: 50,
                        ),
                        onPressed: () {
                          _donate(FlutterUpiApps.MyAirtelUPI);
                        },
                      ),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 20,
                        child: Image.asset(
                          "assets/images/mipay.jpeg",
                          height: 50,
                        ),
                        onPressed: () {
                          _donate(FlutterUpiApps.MiPay);
                        },
                      ),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 20,
                        child: Image.asset(
                          "assets/images/truecaller.jpg",
                          height: 50,
                        ),
                        onPressed: () {
                          _donate(FlutterUpiApps.TrueCallerUPI);
                        },
                      ),
                    ],
                  ),
                )
              ],
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
        .collection("Users")
        .document(widget.uid)
        .get()
        .then((doc) {
      setState(() {
        username = doc.data['username'];
        loading = false;
      });
    });
  }

  _donate(var appName) async {
    print("proccess");
    if (amount == null) {
      Alert(
              context: context,
              title: "Error Occured",
              desc: "Please select a valid amount!")
          .show();
      return;
    }

    String amnt = amount;

    setState(() {
      loading = true;
    });

    String response = await FlutterUpi.initiateTransaction(
      app: appName,
      pa: "8076911425@paytm",
      pn: "Carrot",
      tr: "UniqueTransactionId",
      tn: "donate $amount to $username",
      am: amount,
      mc: "", // optional
      cu: "INR",
      url: "https://www.google.com",
    );

    if (response == "app_not_installed") {
      setState(() {
        loading = false;
      });
      Alert(
              context: context,
              title: "Error Occured",
              desc: "Upi app not installed")
          .show();
      return;
    }
    if (response == "invalid_params" ||
        response == "null_response" ||
        response == "user_canceled") {
      setState(() {
        loading = false;
      });
      Alert(
              context: context,
              title: "Error Occured",
              desc: "Pyment canceled by the user!")
          .show();
      return;
    }

    FlutterUpiResponse flutterUpiResponse = FlutterUpiResponse(response);
    print(response);
    print(flutterUpiResponse.ApprovalRefNo);
    print(flutterUpiResponse.responseCode);
    print(flutterUpiResponse.txnId);
    print(flutterUpiResponse.txnRef);
    print(flutterUpiResponse.Status);
    if (flutterUpiResponse.Status == "SUCCESS")
      _saveTransaction(amnt, flutterUpiResponse.txnId);
    else {
      Alert(
        context: context,
        title: "Error Occured",
      ).show();
       setState(() {
        loading = false;
      });
    }
  }

  _saveTransaction(String amnt, String txID) async {
    String myName;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    Firestore.instance.collection("Users").document(user.uid).get().then((doc) {
      setState(() {
        myName = doc.data['username'];
      });

      Firestore.instance.collection("Txn").add({
        "between": [user.uid, widget.uid],
        "amnt": amnt,
        "donated_by": user.uid,
        "donated_to": widget.uid,
        "msg": msg,
        "donated_by_username": myName,
        "donate_to_username": username,
        "txId": txID,
        "time": DateTime.now().millisecondsSinceEpoch
      }).then((onValue) {
        final DocumentReference walletRef =
            Firestore.instance.collection("Users").document(widget.uid);
        Firestore.instance.runTransaction((Transaction tx) async {
          DocumentSnapshot walletSnapshot = await tx.get(walletRef);
          if (walletSnapshot.exists) {
            await tx.update(walletRef, <String, dynamic>{
              'wallet': walletSnapshot.data['wallet'] + int.parse(amnt)
            }).then((onValue) {
              setState(() {
                loading = false;
              });
              _sendDonateNotification(user.uid, amnt);
              Alert(
                context: context,
                type: AlertType.success,
                title: "Success!",
                buttons: [
                  DialogButton(
                    child: Text(
                      "Cool",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    width: 120,
                  )
                ],
              ).show();
            }).catchError((onError) {
              setState(() {
                loading = false;
              });
              Alert(
                      context: context,
                      title: "Error Occured",
                      desc:
                          "$amnt will be refunded if not in 3 days please contact us with txID: $txID")
                  .show();
            });
          }
        });
      }).catchError((onError) {
        setState(() {
          loading = false;
        });
        Alert(
                context: context,
                title: "Error Occured",
                desc:
                    "$amnt will be refunded if not in 3 days please contact us with txID: $txID")
            .show();
      });
    });
  }

  _sendDonateNotification(String s_uid, String amnt) async {
    var result = await http.post(
        URL+"/donateNotifications/",
        body: {"r_uid": widget.uid, "s_uid": s_uid, "amnt": amnt, "msg": msg});
    print(result.body);
  }
}
