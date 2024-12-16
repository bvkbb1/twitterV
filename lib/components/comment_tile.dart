/*
  COMMENT TILE

  - a common comment tile shold like this, it can be used below the Post in the
  PostPage & let's make the comment tile look slightly different than the posts

  ______________________________________________________________________________

  To use this widget we need the following :
  - the comment (String)
  - a function
    (when the user want to view the profile of the commented person/user)

 */


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/models/comments.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

import '../services/auth/auth_service.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final Function()? onUserTapped;
  const CommentTile({
    super.key,
    required this.comment,
    required this.onUserTapped
  });

  @override
  Widget build(BuildContext context) {
    // get the primary color
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4),
      
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[

            // top section of a post
            GestureDetector(
              onTap: onUserTapped,
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
                    comment.name,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold
                    )
                  ),
              
                  const SizedBox(width: 4,),
              
                  Text(
                    '@${comment.userName}',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold
                    )
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: () => _showOptions(context),
                    child: Icon(Icons.more_horiz, color: primary,)
                  )
                  

                ]
              ),
            ),
      
            const SizedBox(height: 5,),
      
      
            // message
            Text(
              comment.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold
              )
            ),

          ]
        ),
      );
  }


  void _showOptions(BuildContext context){
    // get the primary color once
    final primary = Theme.of(context).colorScheme.primary;

    // provide the delete option only for the user
    // the posts owner can delete the posts
    final String currentUserId = MyAuthService().getFirebaseUid();

    final bool isOwnerOfThisComment = currentUserId == comment.uid;

    // show the bottom sheet options
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // check this post can deleted by their owner only
            if (isOwnerOfThisComment)
            // delete option
            ListTile(
              leading: Icon(Icons.delete, color: primary,),
              title: Text('Delete', style: TextStyle(color: primary),),
              onTap: () async {
                // pop the bottom sheet
                _toPop(context);

                // on delete button clicked
                await Provider.of<DatabaseProvider>(context, listen: false)
                  .deleteComment(commentId: comment.id, postId: comment.postId);
              },
            ),

            // else block the user and report the user
            if (!isOwnerOfThisComment) ...[
              // report the user
              ListTile(
                leading: Icon(Icons.report, color: primary,),
                title: Text('Report', style: TextStyle(color: primary),),
                onTap: (){

                  // pop the bottom sheet
                  _toPop(context);

                  // handle the report the user

                },
              ),

              ListTile(
                leading: Icon(Icons.block, color: primary,),
                title: Text('Block', style: TextStyle(color: primary),),
                onTap: (){
                  // pop the bottom sheet
                  _toPop(context);

                },
              ),
            ],

            // cancel button
            ListTile(
              leading: Icon(Icons.cancel, color: primary,),
              title: Text('Cancel', style: TextStyle(color: primary),),
              onTap: ()=> _toPop(context),
            )
          ],
        ),
      )
    );
  }


  // to popping the page
  void _toPop(BuildContext context){
    Navigator.pop(context);
  }


}
