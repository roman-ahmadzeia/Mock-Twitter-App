import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twitter/Database.dart';
import 'package:twitter/NewTweetPage.dart';
import 'package:twitter/Tweet.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'NewReplyPage.dart';
import 'HomePage.dart';


class SearchPage extends StatefulWidget{
  const SearchPage({Key? key}):super(key: key);

  @override
  State<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage>{
  final GlobalKey<_SearchPage> _homeKey = GlobalKey<_SearchPage>();
  var formKey = GlobalKey<FormState>();
  late TextEditingController _searchController;

  void refreshHomePage() {
    setState(() {
    });
  }

 Future<void> _navigateToHomePage() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => HomePage(),
    ));

    if (result != null) {
      refreshHomePage();
    }
  }


  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }
  
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: Text('Search'),),

      body: Column(children: [Expanded(flex: 1,child:Text('Search for something below')),
      Expanded(child: SizedBox(width: MediaQuery.of(context).size.width * 0.8,
        child: TextFormField(   
                          controller: _searchController,   
                           onChanged: (text) {
                        refreshHomePage(); 
                      },  
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            hintText: 'Search for a tweet',
                          ),
                          validator: (String? text) {
                            if (text == null || text.isEmpty) {
                              return 'Enter text!';
                            }
                            return null;
                          },
                        ),
      )),

      Expanded(flex: 8,child:
      FutureBuilder<List<Tweet>>(
        future:  DatabaseHelper.instance.getAllSearchTweets(_searchController.text),
        builder: (BuildContext context, AsyncSnapshot<List<Tweet>> snapshot)
        {
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

              List<Tweet> tweets_searched = snapshot.data!;
              // tweets = tweets.reversed.toList(); // newest tweets to be seen first


              return Padding(
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  itemCount: tweets_searched.length,
                  itemBuilder: ((context, index){
                    Tweet t = tweets_searched[index];
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
                          SizedBox(height:8),
                    
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
                               _navigateToHomePage();
                              },
                            ),
                              
                              Text('${t.numLikes}'),
              
                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),

              
                              IconButton(icon:Icon(Icons.repeat),
                              color: t.numRetweets == 1? Colors.blue : Colors.black, 
                              onPressed:(){
                                DatabaseHelper.instance.toggleRetweet(t.id, t.numRetweets);
                                _navigateToHomePage();
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
                                  _navigateToHomePage();
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
                                              int result = await DatabaseHelper.instance.deleteTweet(t.id!);
                                              _navigateToHomePage();

                                              if( result > 0 ){
                                                Fluttertoast.showToast(msg: 'Tweet Hidden');
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
      ,)
      )],)
      
      
    );
  }
}

// Padding(padding: EdgeInsets.all(16),
//             child: Column(children: [
//               Text('Search For Something!',style:GoogleFonts.roboto(fontSize: 20),textAlign: TextAlign.left,),
//               TextFormField(
//                       decoration: InputDecoration(
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(20.0),
//                           borderSide: const BorderSide(color: Colors.black),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                           borderSide: const BorderSide(color: Colors.black),
//                         ),
//                         hintText: 'Search for something!',
//                       ),
//                       validator: (String? text) {
//                         if (text == null || text.isEmpty) {
//                           return 'Missing Entry!';
//                         }
//                         searchText = text;
//                         return null;
//                       },
//                     ),
//                     IconButton(icon: Icon(Icons.search), onPressed: (){},)
//             ],))