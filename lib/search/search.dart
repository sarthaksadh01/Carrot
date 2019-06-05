import 'package:flutter/material.dart';
import './video_search.dart';
import './user_search.dart';

class Search extends StatefulWidget {
  final String search;
  Search({this.search});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.video_library)),
              Tab(icon: Icon(Icons.people))
            ],
          ),
          title: Text(widget.search),
        ),
        body: TabBarView(
          children: [
            VideoSearch(
              search: "#"+widget.search.toLowerCase(),
            ),
            UserSearch(search:widget.search)
          ],
        ),
      ),
    );
  }
}
