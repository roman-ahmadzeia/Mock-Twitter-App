import 'package:flutter/material.dart';
import 'package:twitter/Tweet.dart';
import 'package:twitter/Database.dart';
import 'package:intl/intl.dart';
import 'HomePage.dart';


class NewReplyPage extends StatefulWidget {
  final Tweet originalTweet;
  final Function refreshFunction;

  

    const NewReplyPage({Key? key, required this.originalTweet, required this.refreshFunction})
      : super(key: key);

 

  @override
  _NewReplyPageState createState() => _NewReplyPageState();
}

class _NewReplyPageState extends State<NewReplyPage> {
  var formKey = GlobalKey<FormState>();
  late String replyText, username, name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply to Tweet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Replying to: ${widget.originalTweet.userShortName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              TextFormField(
                autofocus: true,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  hintText: 'Your reply...',
                ),
                validator: (String? text) {
                  if (text == null || text.isEmpty) {
                    return 'Enter your reply!';
                  }
                  replyText = text;
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          hintText: 'Username',
                        ),
                        validator: (String? text) {
                          if (text == null || text.isEmpty) {
                            return 'Enter username!';
                          }
                          username = text;
                          return null;
                        },
                      ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          hintText: 'Name',
                        ),
                        validator: (String? text) {
                          if (text == null || text.isEmpty) {
                            return 'Enter name!';
                          }
                          name = text;
                          return null;
                        },
                      ),
                    ),

                  Spacer(flex: 3),      

                  IconButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        DateTime current = DateTime.now();
                        String stringFormatTime = DateFormat('kk:mm:ss \n EEE d MMM').format(current);
                          // int id;
                          // int tweetId;
                          // String username;
                          // String text;
                          // String timestamp;
                        Comment reply = Comment(
                          tweetId: widget.originalTweet.id,
                          username: username,
                          name: name,
                          text: replyText,
                          timestamp: stringFormatTime);

                        int result = await DatabaseHelper.instance.insertComment(reply);
                        if (result > 0) {
                          await DatabaseHelper.instance.incrementCommentCount(widget.originalTweet.id);
                          widget.refreshFunction();
                          Navigator.pop(context, true);

                        }
                      }
                    
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
