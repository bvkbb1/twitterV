

/*
  HOME PAGE

  This is the main page of the app: It displays the list of all posts.

  ______________________________________________________________________________

  We can organise this page using a tabbar to split into:
    - for you page
    - following page

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/components/my_drawer.dart';
import 'package:twitter_clone_v/components/my_input_alert_dialog.dart';
import 'package:twitter_clone_v/components/my_post_tile.dart';
import 'package:twitter_clone_v/helper/navigate_pages.dart';
import 'package:twitter_clone_v/models/post.dart';
import 'package:twitter_clone_v/pages/search_page.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // instances of providers
  late final listeningDbProvider =
    Provider.of<DatabaseProvider>(context);
  late final _databaseProvider =
    Provider.of<DatabaseProvider>(context, listen: false);

  // text controllers
  final _postController = TextEditingController();

  // on start up
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // let's load all the posts
    _loadAllPosts();
  }

  // load all the posts
  Future<void> _loadAllPosts() async {
    await _databaseProvider.loadAllPosts();
  }

  // show the post message dialog box
  void _showPostMessageBox(){
    showDialog(
      context: context,
      builder: (context) => MyInputAlertDialog(
        controller: _postController,
        onClick: () async {
          final String message = _postController.text.trim();
          await _postMessage(message: message);
        },
        hintText: "What's on your mind...!",
        buttonLabel: 'Post',
      )
    );
  }

  // user wants to post a message
  Future<void> _postMessage({required String message}) async {
    // try posting
    await _databaseProvider.postMessage(message: message);
  }


  

  @override
  Widget build(BuildContext context) {
    // TAB CONTROLLER 2 OPTIONS-> for you / following
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('H O M E', style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
          foregroundColor: Theme.of(context).colorScheme.primary,

          actions: [
            IconButton(
              onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPage())),
              icon: const Icon(Icons.search)
            ),
            const SizedBox(width: 10,)
          ],

          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: 'For You',),
              Tab(text: 'Following',),
            ]
          ),
        ),
        drawer: MyDrawer(),
      
        body:TabBarView(
          children: [
            _buildPostsList(posts: listeningDbProvider.allPosts),
            _buildPostsList(posts: listeningDbProvider.followingPosts),
          ]
        ),
      
        floatingActionButton: FloatingActionButton(
          onPressed: _showPostMessageBox,
          child: const Icon(Icons.add)
        ),
      ),
    );
  }


  // build posts list
  Widget _buildPostsList({required List<Post> posts}){
    return posts.isEmpty
      ?
      // show the empty list
      const Center(
        child: Text("No posts Yet...!"),
      )

      :
      // if the post list is not empty
      ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          // get each individual post object
          final post = posts[index];

          // return the my post tile
          return MyPostTile(
            post: post,
            onUserTap: () => goToTheUserPage(context: context, uid: post.uid),
            onPostTap: () => goToThePostPage(context: context, post: post),
          );
        }
      );
  }
}