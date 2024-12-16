/*
  POST TILE
  All the post will display with this widget tile
  ________________________________________________________________________________
  
  To use this widget, we need the following
  - the post

  - a function for onPostTap()
      go to the individual posts to see the complete post
  - a function for onUserTap()
      got to the users profile page

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/components/my_input_alert_dialog.dart';
import 'package:twitter_clone_v/helper/time_formatter.dart';
import 'package:twitter_clone_v/models/post.dart';
import 'package:twitter_clone_v/services/auth/auth_service.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

class MyPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  const MyPostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {

  @override
  void initState(){
    super.initState();

    // load comments for this post
    _loadAllTheComments();
  }

  // providers
  late final _listeningProvider = Provider.of<DatabaseProvider>(context);
  late final _dbProvider = Provider.of<DatabaseProvider>(context, listen: false);


  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    bool likedBuTheCurrentUser =
        _listeningProvider.isPostLikedByCurrentUser(postId: widget.post.id);


    int likesCount = _listeningProvider.getLikeCount(postId: widget.post.id);

    // listen the likes count
    int commentsCount = _listeningProvider.getComments(postId: widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4),
      
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[

            // top section of a post
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children:[
                  // profile icon
                  Icon(
                    Icons.person,
                    color: primary,
                  ),
              
                  const SizedBox(width: 10,),
              
                  // user name here
                  Text(
                    widget.post.name,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold
                    )
                  ),
              
                  const SizedBox(width: 4,),
              
                  Text(
                    '@${widget.post.userName}',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold
                    )
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: _showOptions,
                    child: Icon(Icons.more_horiz, color: primary,)
                  )
                  

                ]
              ),
            ),
      
            const SizedBox(height: 5,),
      
      
            // message
            Text(
              widget.post.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold
              )
            ),

            const SizedBox(height: 5,),

            Row(
              children: [
                // LIKES SECTION
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: likedBuTheCurrentUser
                        ? const Icon(Icons.favorite, color: Colors.red,)
                        : Icon(Icons.favorite_border, color: Theme.of(context).colorScheme.primary,)
                      ),
                      const SizedBox(width: 5),
                      Text(likesCount.toString())
                    ],
                  ),
                ),


                // COMMENTS SECTION
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _openNewCommentBox,
                        child: Icon(Icons.comment, color: Theme.of(context).colorScheme.primary,)
                      ),
                      const SizedBox(width: 5),
                      Text(commentsCount.toString())
                    ],
                  ),
                ),

                Spacer(),

                Text(
                  formatTimeStamp(
                    timeStamp: widget.post.timeStamp
                  ),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ]
            )

          ]
        ),
      ),
    );
  }

  /*
    SHOW OPTIONS
    
    Case - 1: This post belongs to the current user
    - Delete
    - Cancel

    Case-2 : This post does't belongs to the current user
    - report
    - block
    - cancel


   */


  void _showOptions(){
    // get the primary color once
    final primary = Theme.of(context).colorScheme.primary;

    // provide the delete option only for the user
    // the posts owner can delete the posts
    final String currentUserId = MyAuthService().getFirebaseUid();
    final post = widget.post;

    final bool isOwner = currentUserId == post.uid;

    // show the bottom sheet options
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // check this post can deleted by their owner only
            if (isOwner)
            // delete option
            ListTile(
              leading: Icon(Icons.delete, color: primary,),
              title: Text('Delete', style: TextStyle(color: primary),),
              onTap: () async {
                // pop the bottom sheet
                _toPop();

                // on delete button clicked
                await _dbProvider.deletePost(postId: post.id);
              },
            ),

            // else block the user and report the user
            if (!isOwner) ...[
              // report the user
              ListTile(
                leading: Icon(Icons.report, color: primary,),
                title: Text('Report', style: TextStyle(color: primary),),
                onTap: (){

                  // pop the bottom sheet
                  _toPop();

                  // handle the report the user
                  _reportPostConfirmationBox();

                },
              ),

              ListTile(
                leading: Icon(Icons.block, color: primary,),
                title: Text('Block', style: TextStyle(color: primary),),
                onTap: () async {
                  // pop the bottom sheet
                  _toPop();

                  // block the user
                  _blockUserConfirmationBox();
                },
              ),
            ],

            // cancel button
            ListTile(
              leading: Icon(Icons.cancel, color: primary,),
              title: Text('Cancel', style: TextStyle(color: primary),),
              onTap: _toPop,
            )
          ],
        ),
      )
    );
  }

  void _toPop(){
    Navigator.pop(context);
  }

  // toggle the like button
  void _toggleLike() async {
    try{
      await _dbProvider.toggleLike(postId: widget.post.id);
    } catch(e){
      print(e);
    }
  }

  final _commentsController = TextEditingController();
  // open the comment box
  void _openNewCommentBox(){
    showDialog(context: context, builder: (context)=> MyInputAlertDialog(
      controller: _commentsController,
      onClick: () async {
        // add comment
        await _addComment();
      },
      buttonLabel: 'Comment',
      hintText: 'Comment here...'
      )
    );
  }

  // on comment submit clicked this method is called
  Future<void> _addComment() async {
    // check wheather the comment is empty or not
    if (_commentsController.text.isEmpty) return;

    // try to post the comment
    try{
      await _dbProvider.addComment(postId: widget.post.id, message: _commentsController.text.trim());
    }
    // catch any errors during the commenting
    catch (e){
      print(e);
    }
  }

  // load all the comments
  Future<void> _loadAllTheComments() async{
    await _dbProvider.loadAllComments(postId: widget.post.id);
  }

  // report dialog
  void _reportPostConfirmationBox(){
    showDialog(
      context: context,
      builder: (context)=>
      AlertDialog(
        title: const Text('Report Message'),
        content: const Text('Are you sure, you want to report this post'),
        actions: [
          // cancel button
          TextButton(
            onPressed: (){
              _toPop();
            },
            child: const Text('Cancel')
          ),

          // report button
          TextButton(
            onPressed: () async {
              // repott the user
              await _dbProvider.reportUser(postId: widget.post.id, userId: widget.post.uid);
              _toPop();

              // let the user know that successfully reported
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message Reported!'))
              );

            },
            child: const Text('Report')
          )
        ],
      )
    );
  }


  // block user dialog
  void _blockUserConfirmationBox(){
    showDialog(
      context: context,
      builder: (context)=>
      AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure, you want to Block this user!'),
        actions: [
          // cancel button
          TextButton(
            onPressed: (){
              _toPop();
            },
            child: const Text('Cancel')
          ),

          // report button
          TextButton(
            onPressed: () async {
              // repott the user
              await _dbProvider.blockUser(userId: widget.post.uid,);
              _toPop();

              // let the user know that successfully reported
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User Blocked!'))
              );

            },
            child: const Text('Block')
          )
        ],
      )
    );
  }

}