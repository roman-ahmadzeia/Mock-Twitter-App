import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twitter/Database.dart';
import 'package:twitter/NewTweetPage.dart';
import 'package:twitter/Tweet.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'NewReplyPage.dart';
import 'SearchPage.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}):super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage>{

  final GlobalKey<_HomePage> _homeKey = GlobalKey<_HomePage>();

  var formKey = GlobalKey<FormState>();

  void refreshHomePage() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      // Image.file(File('DirectoryLocation/imageName.jpg')
      appBar: AppBar(title: SizedBox(child: Image.asset('assets/logo.png'), width: 40, height: 40),
      actions: [IconButton(padding:EdgeInsets.only(right:30),icon: Icon(Icons.send),onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return NewTweetPage();
                      }));
                    },)],
                    automaticallyImplyLeading: false,
                    leading: IconButton(padding: EdgeInsets.only(left:20),icon: Icon(Icons.search,size: 35), onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder:(_){
                        return SearchPage();
                      }));
                    })
                    ),

      body: FutureBuilder<List<Tweet>>(
        future: DatabaseHelper.instance.getAllTweets(),
        builder:(BuildContext context, AsyncSnapshot<List<Tweet>> snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.blue));
                 }
            if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
                }
            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No Tweets'));
                } 
            else{

              List<Tweet> tweets = snapshot.data!;
              // tweets = tweets.reversed.toList(); // newest tweets to be seen first (changed to SQL Query implementation)


              return Padding(
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: ((context, index){
                    Tweet t = tweets[index];
                        return Container(
                          color: Color.fromARGB(248, 255, 255, 255),
                          margin: EdgeInsets.only(top: 35),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor:Color(Random().nextInt(0xffffffff)), // sets random color for each usernames profile pic default
                      child:
                      Text(t.userShortName.substring(0,1).toUpperCase(),
                      style: TextStyle(fontSize: 25, color: Colors.white)),
                      radius: 25.0,
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.userLongName.toString()}  @${t.userShortName.toString()}',
                            style: GoogleFonts.roboto(fontSize: 18,fontWeight:FontWeight.bold),
                          ),
                          SizedBox(height:MediaQuery.of(context).size.height*0.01),
                    
                          Text(t.description, style: GoogleFonts.roboto(fontSize: 18)),
                          t.imageURL != null && t.imageURL.isNotEmpty
                          ? Image.network(
                              t.imageURL,
                              width: double.infinity,
                            )
                          : Container(),

                          SizedBox(height:20),
                          Text(t.timeString.toString().substring(0,5), style:TextStyle(fontSize: 16)),
                          SizedBox(height:5),

                         
                          Row(
                            children: [
                              IconButton(
                              icon: Icon(Icons.favorite),
                              color: t.isLiked == 1 ? Colors.red : Colors.black,
                              onPressed: () {
                               DatabaseHelper.instance.toggleLike(t.id, t.isLiked);
                               refreshHomePage();
                              },
                            ),
                              
                              Text('${t.numLikes}'),

                              SizedBox(width: MediaQuery.of(context).size.width * 0.02),

                              IconButton(icon:Icon(Icons.repeat),
                              color: t.numRetweets == 1? Colors.blue : Colors.black, 
                              onPressed:(){
                                DatabaseHelper.instance.toggleRetweet(t.id, t.numRetweets);
                                refreshHomePage();
                              },),

                              Text('${t.numRetweets}'),

                              SizedBox(width:15),

                              IconButton(icon: Icon(Icons.comment), onPressed:()async{
                                   final result = await Navigator.of(context)
                                   .push(MaterialPageRoute(builder: (_) {
                             return NewReplyPage(key: formKey, originalTweet: t,  refreshFunction: refreshHomePage);
                      }));
                              if (result == true) {
                              _homeKey.currentState?.setState(() {});
                              }
                              }),

                              Text('${t.numComments}'),

                              IconButton(icon:Icon(Icons.bookmark),
                              color: t.isBookmarked == 1 ? Colors.yellow:Colors.black ,
                               onPressed: (){
                                  DatabaseHelper.instance.toggleBookmark(t.id, t.isBookmarked);
                                  refreshHomePage();
                               }
                             ,)
                            ],
                          ),

                           FutureBuilder<List<Comment>>(
                    future: DatabaseHelper.instance.getCommentsForTweet(t.id),
                    builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.blue));
                      }
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                        return Container(); // No comments
                      } else {
                        List<Comment> comments = snapshot.data!;
                        return Column(
                          children: comments.map((comment) {
                            return Container(
                              color: Color.fromARGB(248, 255, 255, 255),
                              margin: EdgeInsets.only(left: 10, top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    CircleAvatar(backgroundColor: Color(Random().nextInt(0xffffffff)),
                                    child: Text(comment.name.substring(0,1).toUpperCase().toString(),
                                    )
                                    ),
                                    SizedBox(width: 10),
                                    Text('@${comment.username} ${comment.name}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],),
                                  Text('             ${comment.text}'),
                                  Text('             ${comment.timestamp.substring(0,5)}')
                                 
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      } 
                  })

                        ],
                      ),
                    ),
                  
                    IconButton(
                      icon: Icon(Icons.remove_red_eye),
                      onPressed: ()  {
                        showDialog(
                          barrierDismissible: false,
                          context: context, builder: (context){
                            return AlertDialog(
                              backgroundColor: const Color.fromARGB(255, 0, 140, 255),
                              iconColor: Colors.white,
                                          title: const Text('Confirmation',style: TextStyle(color:Colors.white)),
                                          content: const Text('Are you sure you want to hide tweet?',style:TextStyle(color: Colors.white)),
                                          actions: [
                                            TextButton(onPressed: (){
                                              Navigator.of(context).pop();
                                            }, child: const Text('No',style:TextStyle(color:Colors.white))),
                                            TextButton(onPressed: () async{
                                              Navigator.of(context).pop();

                                              // delete student

                                              int result = await DatabaseHelper.instance.deleteTweet(t.id!);
                                              if( result > 0 ){
                                                Fluttertoast.showToast(msg: 'Tweet Hidden');
                                                setState((){});
                                                // build function will be called
                                              }

                                            }, child: const Text('Yes',style:TextStyle(color:Colors.white))),

                                          ],
                                        );
                          }
                        );
                  
                      },
                    ),

                  ],
                ),
              );
             }

                )
              ));
            }
        }
      )

    );
  }
}