import 'dart:math';

import 'package:flutter/material.dart';
import 'Database.dart';
import 'HomePage.dart';
import 'Tweet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class NewTweetPage extends StatefulWidget{
  const NewTweetPage({Key? key}):super(key: key);

  @override
  State<NewTweetPage> createState() => _NewTweetPage();
}

class _NewTweetPage extends State<NewTweetPage>{
  var formKey = GlobalKey<FormState>();
  late String shortName='', longName='', desc='', imageUrl='';

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Twitter',
        style: GoogleFonts.roboto(fontSize: 20, color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(Icons.home, color: Colors.black, size: 30),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return const HomePage();
          }));
        },
      ),
      automaticallyImplyLeading: false,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  hintText: 'Whats Happening?',
                ),
                validator: (String? text) {
                  if (text == null || text.isEmpty) {
                    return 'Tell us about your day!';
                  }
                  desc = text;
                  return null;
                },
              ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Expanded(
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
                          return 'Enter Username!';
                        }
                        shortName = text;
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Expanded(
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
                        longName = text;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
             SizedBox(height: MediaQuery.of(context).size.height* 0.02),
              Row(
                children: [
                  Icon(Icons.camera_alt),
                  Expanded(flex:1, child: Spacer()),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        hintText: 'Image URL',
                      ),
                      onChanged: (String text) {
                        imageUrl = text;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        DateTime current = DateTime.now();
                        String stringFormatTime = DateFormat('kk:mm:ss \n EEE d MMM').format(current);
                        Tweet t = Tweet(
                          userShortName: shortName,
                          userLongName: longName,
                          timeString: stringFormatTime,
                          description: desc,
                          imageURL: imageUrl,
                          numComments: 0,
                          numRetweets: 0,
                          numLikes: 0,
                          isLiked: 0,
                          isBookmarked: 0,
                        );
                        int result = await DatabaseHelper.instance.insertTweet(t);
                        if (result > 0) {
                          Fluttertoast.showToast(msg: "Tweet Posted", backgroundColor: Colors.blue);
                        } else {
                          Fluttertoast.showToast(msg: "Failed To Post", backgroundColor: Colors.black);
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
    ),
  );
}


  
}