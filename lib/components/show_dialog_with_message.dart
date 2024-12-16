

import 'package:flutter/material.dart';

void showMsgDialog(BuildContext context, String msg){
  showDialog(context: context, builder: (context) => AlertDialog(
    contentPadding: const EdgeInsets.only(
      top: 0, bottom: 0, left: 0, right: 0
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(msg, style: const TextStyle(fontSize: 14),),
        const SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: ()=> Navigator.pop(context),
              child: Text(
                'ok',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14
                ),
              )
            ),

            const SizedBox(width: 20,)
          ],
        )
      ],
    ),
  ));
}