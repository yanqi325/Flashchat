import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id ='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? messageText;
  late StreamSubscription<QuerySnapshot> _messageStreamSubscription;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();

  }

  // void getMessages() async{  //this method will print out all the message each time and cannot keep track of latest live message
  //   final messages = await _firestore.collection('messages').get(); //get a list of all data
  //   for (var message in messages.docs){ //messages.docs mayb is the list of reference number for each document
  //     print(message.data()); // data inside the documents
  //   }
  // }

  //to keep track of new messages in database and reprint all the message, we need to use snapshot
  //stream is a Future but it is meant for a series of upcoming asynchronous event rather than a single/one-time event
  //C:\Users\yanqi\OneDrive\Desktop\flutter\flash-chat-flutter\photoComment\Stream.png
  //C:\Users\yanqi\OneDrive\Desktop\flutter\flash-chat-flutter\photoComment\Stream2.png
  //C:\Users\yanqi\OneDrive\Desktop\flutter\flash-chat-flutter\photoComment\Future vs Stream.p ng
  //C:\Users\yanqi\OneDrive\Desktop\flutter\flash-chat-flutter\photoComment\snapshos() vs listen().png
  //snapshots() is a Stream
  // void messagesStream() async {
  //   _messageStreamSubscription = _firestore.collection('messages').snapshots().listen((QuerySnapshot snapshot) {
  //     for (var message in snapshot.docs) { //this snapshot is belong to Firestore snapshot
  //       print(message.data());
  //     }
  //   });
  // }



  void getCurrentUser() async { // this method is to check if current user who is signed in
    try {
      final user = await _auth.currentUser; //this will be null if nobody is currently signed in, but if something is register, we can tap into the email & password
      if (user != null) { //not equal to null = we have signed in user
        loggedInUser = user;
        //assign the current user into loggedInUser,
        //so we can use the loggedInUser info throughout other part of the class rather than just inside getCurrentUser() method
        print(loggedInUser?.email);
      }
      else{
        print('No user signed in');
      }
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamMessage(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      messageTextController.clear();
                      //save message and user email to firebase
                      _firestore.collection('messages').add({'text':messageText,'sender':loggedInUser?.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreamMessage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //This widget takes a stream and a callback function and rebuilds its UI when the stream emits new data.
      // <QuerySnapshot> specifies the type of data emitted by the stream.
      stream:  _firestore.collection('messages').snapshots(), //where you get the, snapshot is the stream we getting data from
      builder: (context, snapshot) { //this snapshot is different from the above one, the above one is Firebase's query snapshot,
        // this snapshot in this line is Flutter aysnc snapshot but this Flutter AsyncSnapshot contains what is in theFirebase's query snapshot
        //builder need to rebuild all the children in StreamBuilder everything changes have received
        if (!snapshot.hasData){ //if no data
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        else{
          final messages = snapshot.data!.docs!.reversed;
          List<MessageBubbles> messageWidgetS = []; //array list for messages text widget
          for (var message in messages) { //.reversed will pick the earliest msg first and latest msg come later
            //Firestore snapshot is store in the 'data' property of AsyncSnapshot, so snapshot(AysncSnapshot).data == snapshot (Firebase snapshot)
            //
            final messageText = message['text'];
            final messageSender = message['sender'];
            final currentUser = loggedInUser?.email;
            // print('$currentUser');
            // print('$messageSender');

            final messageWidget = MessageBubbles(sender: messageSender, text: messageText, isMe: messageSender == currentUser);
            messageWidgetS.add(messageWidget); //loop and store each text widget message inside the array list
          }
          return Expanded(
              child: ListView(
                reverse: true, //make the view of message always stick to the bottom
                children: messageWidgetS,
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              )
          ); //StreamBuilder must return something everytime and we are returning the messageWidgetS
          //ListView for scrolling screen
        }
      },
    );
  }
}


class  MessageBubbles extends StatelessWidget {
  MessageBubbles({this.sender, this.text, this.isMe});

  String? sender;
  String? text;
  bool? isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe! ? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text('$sender',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54),
          ),
          Material(
            borderRadius: isMe! ? BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)):
            BorderRadius.only(topRight: Radius.circular(30), bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30),),
            elevation: 5.0,
            color: isMe! ? Colors.lightBlueAccent: Colors.white ,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                    fontSize: 15,
                    color: isMe! ? Colors.white: Colors.black87
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

