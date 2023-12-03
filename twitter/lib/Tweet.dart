class Tweet{
  late dynamic id;
  late String userShortName;
  late String userLongName;
  late String timeString;
  late String description;
  late String imageURL;
  late int numComments;
  late int numRetweets;
  late int numLikes;
  late int isLiked;
  late int isBookmarked;
  


  Tweet({
    this.id,
    required this.userShortName,
    required this.userLongName,
    required this.timeString,
    required this.description,
    required this.imageURL,
    required this.numComments,
    required this.numRetweets,
    required this.numLikes,
    required this.isLiked,
    required this.isBookmarked});

  Map<String, dynamic> toMap() 
  {
    Map<String, dynamic> map = {};
    map['id'] = id;
    map['userShortName'] = userShortName;
    map['userLongName'] = userLongName;
    map['timeString'] = timeString;
    map['description'] = description;
    map['imageURL'] = imageURL;
    map['numComments'] = numComments;
    map['numRetweets'] = numRetweets;
    map['numLikes'] = numLikes;
    map['isLiked'] = isLiked;
    map['isBookmarked'] = isBookmarked;
    return map;
  }

  Tweet.fromMap(Map<String, dynamic> map) 
  {
    id = map['id'];
    userShortName = map['userShortName'];
    userLongName= map['userLongName'];
    timeString= map['timeString'];
    description = map['description'];
    imageURL = map['imageURL'];
    numComments = map['numComments'] ?? 0;
    numRetweets = map['numRetweets'] ?? 0;
    numLikes = map['numLikes'] ?? 0;
    isLiked = map['isLiked'];
    isBookmarked = map['isBookmarked'];

  }


}

class Comment {
  late int id;
  int tweetId;
  String username;
  String name;
  String text;
  String timestamp;

  Comment({
    required this.tweetId,
    required this.username,
    required this.name,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'tweetId': tweetId,
      'username': username,
      'name': name,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      tweetId: map['tweetId'],
      username: map['username'],
      name: map['name'],
      text: map['text'],
      timestamp: map['timestamp'],
    );
  }
}