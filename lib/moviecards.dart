import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nextwatch/flutter_swipable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nextwatch/movie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nextwatch/global.dart';
import 'package:http/http.dart';
import 'dart:collection';

class MovieCards extends StatefulWidget {
  @override
  _MovieCardsState createState() => _MovieCardsState();
}

class _MovieCardsState extends State<MovieCards> {

  List<Card> cards = [];
  int batchCount = 0;

  String baseURL = "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&sort_by=vote_average.desc&vote_count.gte=100";

  Future<void> getUserData() async {
    peopleScore = (await FirebaseFirestore.instance.collection(uid).doc("People Score").get()).data() ?? {};
    genreScore = (await FirebaseFirestore.instance.collection(uid).doc("Genre Score").get()).data() ?? {};
    Watchlist =  (await FirebaseFirestore.instance.collection(uid).doc("Watchlists").get()).data() ?? {};
    LikedMovies = (await FirebaseFirestore.instance.collection(uid).doc("Liked Movies").get()).data() ?? {};
    DislikedMovies = (await FirebaseFirestore.instance.collection(uid).doc("Disliked Movies").get()).data() ?? {'tid' : []};
    isDataLoaded = true;
  }

  bool isRated(int id) {
    return DislikedMovies['tid'].contains(id) || LikedMovies.values.contains(id) || Watchlist.values.contains(id);
  }

  LinkedHashMap getSortedPeopleMap() {
    var sortedKeys = peopleScore.keys.toList(growable:false)
      ..sort((k1, k2) => peopleScore[k2].compareTo(peopleScore[k1]));
    LinkedHashMap sortedMap = LinkedHashMap
        .fromIterable(sortedKeys, key: (k) => k, value: (k) => peopleScore[k]);
    return sortedMap;
  }

  LinkedHashMap getSortedGenreMap() {
    var sortedKeys = genreScore.keys.toList(growable:false)
      ..sort((k1, k2) => genreScore[k2].compareTo(genreScore[k1]));
    LinkedHashMap sortedMap = LinkedHashMap
        .fromIterable(sortedKeys, key: (k) => k, value: (k) => genreScore[k]);
    return sortedMap;
  }

  String top5GenreString() {
    List<dynamic> sortedGenreIDs = getSortedGenreMap().keys.toList();
    String genreString = sortedGenreIDs[0].toString();
    for (int i = 1; i<5; i++) {
      genreString += '|' + sortedGenreIDs[i].toString();
    }
    return genreString;
  }

  bool isPerson(String id) {
    if (id.length > 2) return true;
    return false;
  }


  Future<List<Movie>> getMovies() async {

    List<Movie> movieList = [];
    List<dynamic> sortedPeopleScoreIDs = getSortedPeopleMap().keys.toList();
    int page = 1;
    int totalPages = 1;
    int movieCount = 0;

    Future<Map> getResponse(int i) async {
      Response response;
      if (isPerson(sortedPeopleScoreIDs[i])) {
        response = await get(Uri.parse(baseURL+'&with_people=${sortedPeopleScoreIDs[i]}&with_genres=${top5GenreString()}&page=$page'));
      }
      else {
        response = await get(Uri.parse(baseURL+'&with_original_language=${sortedPeopleScoreIDs[i]}&with_genres=${top5GenreString()}&page=$page'));
        //en fr tr still recommending ja es
      }

      return jsonDecode(response.body);
    }

    for (int i=0; i<sortedPeopleScoreIDs.length && movieCount<9; i++)
    {

      Map data = await getResponse(i);
      totalPages = data['total_pages'];
      int count = 0;

      for (int i = 0; i<data['results'].length && count <3 && movieCount < 9; i++)
      {
        bool isDuplicate = false;
        int id = data['results'][i]['id'];
        if (!isRated(id)) {

          for (int i = 0; i<movieList.length; i++) {
            if (movieList[i].id == id) {
              isDuplicate = true;
              break;
            }
          }

          if (!isDuplicate) {
            List genre_ids = data['results'][i]['genre_ids'];

            List<String> creditIDs = [];
            Response creditResponse = await get(Uri.parse('https://api.themoviedb.org/3/movie/${data['results'][i]['id']}/credits?api_key=${apiKey}'));
            Map creditData = jsonDecode(creditResponse.body);

            creditData['cast'].forEach((cast) {
              creditIDs.add(cast['id'].toString());
            });

            creditData['crew'].forEach((crew) {
              if (['Producer', 'Director', 'Writer'].contains(crew['job'])) {
                creditIDs.add(crew['id'].toString());
              }
            });

            movieList.add(Movie(
                id: data['results'][i]['id'],
                title: data['results'][i]['title'],
                imageURL: data['results'][i]['poster_path'],
                rating: data['results'][i]['vote_average'],
                language: data['results'][i]['original_language'],
                details: data['results'][i]['overview'],
                genreIDs: genre_ids,
                creditIDs: creditIDs
            ));

            count++;
            movieCount++;
            /*if (movieCount == 9) break;
            if (count == 3) break;*/
          }

        }
      }


      if (count < 3 && page < totalPages) {
        page++;
        i--;
        //same loop repeated again with incremented page.
      }

/*      print('count: ${count}');
      movieCount += count;*/

    }

    //print(movieCount);

    return movieList;
  }

  void checkCardsOver() async { //if any error try removing async
    if (cards.length == 0) //stack elements are deleted not cards... try to delete cards to save ram
    {
      setState(() {
        isMoviesLoaded = false;
      });
      //only setting state for movie cards not for other pages.

      batchCount ++;
      print(batchCount);
      if (batchCount == 10) {
        for (int i =0; i< genreScore.length; i++) {
          genreScore[genreScore.keys.elementAt(i)] =
          (genreScore[genreScore.keys.elementAt(i)] / 4).round();
        }
        for (int i =0; i< peopleScore.length; i++) {
          peopleScore[peopleScore.keys.elementAt(i)] =
          (peopleScore[peopleScore.keys.elementAt(i)] / 4).round();
        }

        await FirebaseFirestore.instance.collection(uid).doc("Genre Score").update(genreScore);
        await FirebaseFirestore.instance.collection(uid).doc("People Score").update(peopleScore);

      }

      getCards();
    }
  }

  void removeFunction(int id) {
    for (int i =0; i<cards.length; i++) {
      if (cards[i].id == id) {
        cards.removeAt(i);
        break;
      }
    }
    //print(cards.length);
    checkCardsOver();   // if any error try await
  }

  void getCards()
  {
    // this (.then) is an async function
    getMovies().then((movies) {
      movies.forEach((movie) {
        cards.add(Card(cards.length, movie, removeFunction));
      });
      setState(() {
        isMoviesLoaded = true;
      });
    });
  }

  @override
  void initState() {

    getUserData().then((data) {
      setLiked();
      setWatchlist();
      getCards();
    });


    super.initState();
  }

  final _random = new Random();
  List<String> loadingStrings = [
    'Getting more Recommendations',
    'Just a sec',
    'Hmm...',
    'I am Learning',
    'You have a nice taste!',
    'Looking for more Movies',
  ];

  @override
  Widget build(BuildContext context) {

    // Stack of cards that can be swiped. Set width, height, etc here.
    return (isMoviesLoaded)? Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      // Important to keep as a stack to have overlay of cards.
      child: Stack(
        children: (cards.isNotEmpty) ? cards: [Center(child: Text("\nNo Recommendations\n      Try Again Later", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),))],
      ),
    ) : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.deepOrange,),
        Text("\n" + loadingStrings[_random.nextInt(loadingStrings.length)], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),)
      ],
    );
  }
}

List<double> angles = [-0.05, -0.02, 0.0, 0.02, 0.05, 0.02, 0.0, -0.02];
int k = 0;
double getAngle()
{
  if (k == 8) k = 0;
  return angles[k++];
}

class Card extends StatelessWidget {

  int id;
  Movie movie; //cant use movie as id as 2 cards in the same batch can have same movie.
  Function removeFunction;
  Card(this.id, this.movie, this.removeFunction);

  double x =0, y=0;

  @override
  Widget build(BuildContext context) {
    return Swipable(
      // Set the swipable widget
      threshold: 0.7,
      child: Transform.rotate(
        angle: getAngle(),
        child: GestureDetector(
          onTap: (){
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                List<String> genreList = [];
                movie.genreIDs.forEach((id) {
                  genreList.add(genreMap[id]);
                });
                return AlertDialog(
                  insetPadding: EdgeInsets.all(10),
                  title: Text(movie.title),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text("Rating: ", style: TextStyle(fontWeight: FontWeight.bold),), Text('${movie.rating}')],),
                      Text('\n'),
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text("Genre: ", style: TextStyle(fontWeight: FontWeight.bold),), Expanded(child:Text(genreList.toString()))],),
                      Text("\nOverview", style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(movie.details)
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("CLOSE"),
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(baseImageURL+movie.imageURL),
              ),
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3, //5
                  blurRadius: 5, //7
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      ),

      onPositionChanged: (details){
        x += details.delta.dx;
        y += details.delta.dy;

        if (details.delta.dx > 5 && x >= 30) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(msg: " Like ", backgroundColor: Colors.deepOrange, textColor: Colors.white);
        }

        if (details.delta.dx < -5 && x <= -50) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(msg: "Dislike", backgroundColor: Colors.deepOrange, textColor: Colors.white);
        }

        if (details.delta.dy < - 5 && y <= -80) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(msg: " Skip ", backgroundColor: Colors.deepOrange, textColor: Colors.white);
        }

        if (details.delta.dy > 5 && y >= 30) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(msg: "Watchlist", backgroundColor: Colors.deepOrange, textColor: Colors.white);
        }
      },

      onSwipeRight: (offset){

        removeFunction(id);

        updateLiked(movie.title, movie.id);

        LikedMovies[movie.title] = movie.id;

        movie.genreIDs.forEach((id) {
          genreScore[id.toString()]++;
        });

        movie.creditIDs.forEach((id) {
          if (!peopleScore.keys.contains(id)) {
            peopleScore[id.toString()] = 1;
          } else {
            peopleScore[id.toString()]++;
          }
          peopleScore[movie.language]++;
        });


        FirebaseFirestore.instance.collection(uid).doc("Liked Movies").set(
            {movie.title: movie.id}, SetOptions(merge: true));
        
        FirebaseFirestore.instance.collection(uid).doc("Genre Score").update(genreScore);
        FirebaseFirestore.instance.collection(uid).doc("People Score").update(peopleScore);

      },

      onSwipeLeft: (offset){

        removeFunction(id);

        if (!DislikedMovies['tid'].contains(movie.id)) {
          int len = DislikedMovies['tid'].length;
          if (len < 30) {
            DislikedMovies['tid'].add(movie.id);
          }
          else {
            DislikedMovies['tid'].removeAt(0);
            DislikedMovies['tid'].insert(29, movie.id);
          }

          movie.genreIDs.forEach((id) {
            genreScore[id.toString()]--;
          });

          movie.creditIDs.forEach((id) {
            if (!peopleScore.keys.contains(id)) {
              peopleScore[id.toString()] = -1;
            } else {
              peopleScore[id.toString()]--;
            }
          });

          peopleScore[movie.language]--;

          FirebaseFirestore.instance.collection(uid).doc("Genre Score").update(genreScore);
          FirebaseFirestore.instance.collection(uid).doc("People Score").update(peopleScore);

          FirebaseFirestore.instance.collection(uid).doc("Disliked Movies").set(
              {'tid': FieldValue.arrayUnion(DislikedMovies['tid'])});
        }

      },

      onSwipeDown: (offset){

        removeFunction(id);

        Watchlist[movie.title] = movie.id;
        updateWatchList(movie.title, movie.id);

        FirebaseFirestore.instance.collection(uid).doc("Watchlists").set(
            {movie.title: movie.id}, SetOptions(merge: true));

        Fluttertoast.showToast(msg: "Movie added to Watchlist");

      },

      onSwipeUp: (offset){
        removeFunction(id);
      },
    );
  }
}