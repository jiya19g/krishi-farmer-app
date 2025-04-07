import 'package:farmer_app/screens/discussion.dart';
import 'package:farmer_app/screens/news.dart';
import 'package:farmer_app/screens/support.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community Hub'),
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.forum)),
              Tab(icon: Icon(Icons.newspaper)),
              Tab(icon: Icon(Icons.support_agent)),
            ],
            indicatorColor: Colors.green[800], // ✅ Active indicator color
            labelColor: Colors.green[800], // ✅ Selected icon color
            unselectedLabelColor: Colors.grey, // ✅ Unselected icon color
            indicatorWeight: 3,
          ),
        ),
        body: const TabBarView(
          children: [
            DiscussionsTab(),
            NewsTab(),
            SupportTab(),
          ],
        ),
      ),
    );
  }
}
