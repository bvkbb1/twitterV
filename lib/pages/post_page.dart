/*
  POST PAGE
  _______________________

  This page displays :
  
  - individual post
  - post comments

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/components/comment_tile.dart';
import 'package:twitter_clone_v/components/my_post_tile.dart';
import 'package:twitter_clone_v/helper/navigate_pages.dart';
import 'package:twitter_clone_v/models/post.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({
    super.key,
    required this.post
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // provider instances
  late final _listeningDbProvider = Provider.of<DatabaseProvider>(context);
  late final _dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    // get the post
    final post = widget.post;

    // listen to all the comments for this post
    final allComments = _listeningDbProvider.getComments(postId: post.id);

    
    return Scaffold(
      appBar: AppBar(
        title: Text(post.message),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: ListView(
          children:[
            // post
            MyPostTile(
              post: post,
              onUserTap: () => goToTheUserPage(context: context, uid: post.uid),
              onPostTap: (){}
            ),

            // check the comments are exists
            allComments.isEmpty
            // handle no comments
            ? const Center(
              child: Text('No Comments')
            )

            // if the comments exists
            : ListView.builder(
              itemCount: allComments.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // get each comment
                final comment = allComments[index];

                // return the comment tile UI
                return CommentTile(
                  comment: comment,
                  onUserTapped: () => goToTheUserPage(context: context, uid: comment.uid) 
                );
              }
            )

          ]
        ),
      )
    );
  }
}