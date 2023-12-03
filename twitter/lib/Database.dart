import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'Tweet.dart';

class DatabaseHelper
{
  DatabaseHelper._privateConstructor();  
    static final DatabaseHelper instance = DatabaseHelper._privateConstructor(); 

    static Database? _database; 

   

    Future<Database> get database async { 
      _database ??= await initializeDatabase();
      return _database!;
    }

    Future<Database> initializeDatabase() async {
   
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/tweet.db';

    var TweetsDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );

    return TweetsDatabase;
  }
  void _createDb(Database db, int newVersion) async {
    await _createTweetsTable(db);
    await _createCommentsTable(db);
  }

Future<void> _createTweetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE table_tweets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userShortName TEXT,
        userLongName TEXT,
        timeString TEXT,
        description TEXT,
        imageURL TEXT,
        numComments INTEGER,
        numRetweets INTEGER,
        numLikes INTEGER,
        isLiked INTEGER,
        isBookmarked INTEGER
        )
    ''');
  }

  Future<void> _createCommentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE table_comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tweetId INTEGER,
        username TEXT,
        name TEXT,
        text TEXT,
        timestamp TEXT,
        FOREIGN KEY (tweetId) REFERENCES table_tweets(id)
      )
    ''');
  }
  Future<int> insertTweet(Tweet t) async {
 

    Database db = await instance.database;
   

    int result = await db.insert('table_tweets', t.toMap());

    return result;
  }

  Future<List<Tweet>> getAllTweets() async {
    List<Tweet> tweets = [];

   
    Database db = await instance.database;
    

    List<Map<String, dynamic>> listMap = await db.query('table_tweets', orderBy:'isBookmarked DESC, timeString DESC');

    for (var TweetMap in listMap) {
      Tweet t = Tweet.fromMap(TweetMap);
      tweets.add(t);
    }

    await Future.delayed(const Duration(seconds: 2));
    return tweets;
  }

Future<List<Tweet>> getAllSearchTweets(String searchTerm) async {
  Database db = await instance.database;

  if (searchTerm.isNotEmpty) {
    List<Map<String, dynamic>> listMap = await db.query(
      'table_tweets',
      where: 'description LIKE ?',
      whereArgs: ['%$searchTerm%'], 
    );

    List<Tweet> tweets = [];

    for (var tweetMap in listMap) {
      Tweet t = Tweet.fromMap(tweetMap);
      tweets.add(t);
    }

    return tweets;
  } else {
    return [];
  }
}

  Future<int> updateTweet(Tweet t) async { 
    Database db = await instance.database;
    
    int result = await db.update('table_tweets', t.toMap(), where: 'id=?', whereArgs: [t.id]);
    return result;
  }

  Future<int> deleteTweet(int id) async { 
    Database db = await instance.database;
    

    int result = await db.delete('table_tweets', where: 'id=?', whereArgs: [id]);
    return result;
  }


  Future<void> incrementCommentCount(int id) async {
    Database db = await instance.database;

    await db.rawUpdate(
      'UPDATE table_tweets SET numComments = numComments + 1 WHERE id = ?',
      [id],
    );
  }

  Future<void> incrementLikes(int id,) async {
    Database db = await instance.database;

    await db.rawUpdate('UPDATE table_tweets SET numLikes = numLikes + 1 WHERE id = ?',
    [id]);
  }

  Future<void> incrementRetweets(int id) async{
    Database db = await instance.database;
    await db.rawUpdate('UPDATE table_tweets SET numRetweets = numRetweets + 1 WHERE id = ?'
    [id]);
  }

  Future <void> decrementCount(int id, String variable) async {
    Database db = await instance.database;
    await db.rawUpdate('UPDATE table_tweets SET $variable = $variable - 1 WHERE ID =?'
    [id]);
  }
 

Future<List<Comment>> getCommentsForTweet(int tweetId) async {
    List<Comment> comments = [];
    Database db = await instance.database;
    List<Map<String, dynamic>> listMap = await db.query(
      'table_comments',
      where: 'tweetId = ?',
      whereArgs: [tweetId],
    );
    for (var CommentMap in listMap) {
      Comment c = Comment.fromMap(CommentMap);
      comments.add(c);
    }
    await Future.delayed(const Duration(seconds: 2));
    return comments;
  }


  Future<int> insertComment(Comment comment) async {
    Database db = await instance.database;
    int result = await db.insert('table_comments', comment.toMap());
    return result;
  }

  Future<void> toggleLike(int id, int currentLikeStatus) async {
  Database db = await instance.database;
  if (currentLikeStatus == 1) {
    await db.rawUpdate('UPDATE table_tweets SET numLikes = numLikes - 1, isLiked = 0 WHERE id = ?', [id]);
  } else {
    await db.rawUpdate('UPDATE table_tweets SET numLikes = numLikes + 1, isLiked = 1 WHERE id = ?', [id]);
  }
}

Future<void> toggleRetweet(int id, int currentRetweetStatus) async {
  Database db = await instance.database;
  if (currentRetweetStatus == 1){
    await db.rawUpdate('UPDATE table_tweets SET numRetweets = numRetweets - 1, numRetweets = 0 WHERE id = ?', [id]);
    }else{
    await db.rawUpdate('UPDATE table_tweets SET numRetweets = numRetweets + 1, numRetweets = 1 WHERE id = ?', [id]);
   }
  }

Future<void> toggleBookmark(int id, int currentBookmarkStatus) async {
  Database db = await instance.database;
  if (currentBookmarkStatus == 1) {
    await db.rawUpdate('UPDATE table_tweets SET isBookmarked = 0 WHERE id = ?', [id]);
  }else{
    await db.rawUpdate('UPDATE table_tweets SET isBookmarked = 1 WHERE id = ?', [id]);

  }
  }
}






