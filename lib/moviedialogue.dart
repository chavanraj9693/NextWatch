import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nextwatch/global.dart';
import 'dart:convert';
import 'package:nextwatch/movie.dart';

class MovieDialogue extends StatefulWidget {

  int id;
  MovieDialogue(this.id);

  @override
  _MovieDialogueState createState() => _MovieDialogueState();
}

class _MovieDialogueState extends State<MovieDialogue> {

  bool isLoaded = false;
  Movie movie = new Movie();

  Future<Movie> loadMovie() async {
    String baseURL = "https://api.themoviedb.org/3/movie/${widget.id}?api_key=$apiKey";

    Response response = await get(Uri.parse(baseURL));
    Map data = jsonDecode(response.body);

    List<int> getGenreIDs()
    {
      List<int> genreList = [];
      data['genres'].forEach((genre){
        genreList.add(genre['id']);
      });

      return genreList;
    }

    return new Movie(
        id: widget.id,
        title: data['title'],
        rating: data['vote_average'],
        details: data['overview'],
        genreIDs: getGenreIDs()
    );
  }

  @override
  void initState() {
    loadMovie().then((data){
      setState(() {
        movie = data;
        isLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> genreList = [];
    movie.genreIDs.forEach((id) {
      genreList.add(genreMap[id].toString());
    });
    return (isLoaded)? AlertDialog(
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
    ) : AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Text("Loading"),
      content: Center(child: CircularProgressIndicator(color: Colors.deepOrange,),),
    );

  }
}
