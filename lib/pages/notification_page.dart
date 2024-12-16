import 'package:flutter/material.dart';

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({super.key});

//   @override
//   State<NotificationPage> createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   @override
//   Widget build(BuildContext context) {

//     // get the notification message and display on the screen
//     final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//       ),

//       body: Column(
//         children: [
//           Text("${message.notification!.title}"),
//           Text("${message.notification!.body}"),
//           Text("${message.data}"),
//         ],
//       ),
//     );
//   }
// }





class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications')
      ),
      body: (message != null || message.isNotEmpty)
      ?
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Title: ${message['title']}'),
          Text('Body: ${message['body']}'),
          if (message['extraData'] != null)
            Text('Extra Data: ${message['extraData']}'),
            Text('Check VS code commit')
        ],
      )
      :
      const Center(
        child: Text('No notification data available')
      ),
    );
  }
}
